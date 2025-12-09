//
//  ServiceCameraCaptureViewController.swift
//  lns
//
//  Created by LNS2 on 2025/12/9.
//
import UIKit
import AVFoundation

protocol ServiceCameraCaptureViewControllerDelegate: AnyObject {
    func cameraCapture(_ controller: ServiceCameraCaptureViewController,
                       didCapturePhoto image: UIImage)
    func cameraCapture(_ controller: ServiceCameraCaptureViewController,
                       didCaptureVideoAt url: URL)
    func cameraCaptureDidCancel(_ controller: ServiceCameraCaptureViewController)
}

/// 类似微信拍摄：
/// - 点击拍照
/// - 长按录视频（按钮外圈显示30秒进度）
/// - 拍完 / 录完先在页面预览，用户点击“发送”才真正回调给外部
class ServiceCameraCaptureViewController: UIViewController {
    
    weak var delegate: ServiceCameraCaptureViewControllerDelegate?
    
    // MARK: Capture
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isSessionRunning = false
    private var isRecording = false
    private let maxVideoDuration: TimeInterval = 15   // 最长 30 秒
    
    // MARK: UI - 顶部关闭按钮 & 中间拍摄按钮
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()
    
    /// 中间的大圆按钮容器
    private let captureButton = UIView()
    /// 中间的实心圆
    private let captureInnerView = UIView()
    
    // MARK: 录制进度圈（按钮外圈）
    
    /// 灰色底圈（始终是完整圆）
    private let recordTrackLayer = CAShapeLayer()
    /// 白色进度圈（根据时间转动）
    private let recordProgressLayer = CAShapeLayer()
    private var recordStartTime: CFTimeInterval?
    private var recordDisplayLink: CADisplayLink?
    
    // MARK: 预览 UI（拍照 & 视频共用）
    
    private let previewContainer = UIView()
    private let imagePreviewView = UIImageView()
    private let sendButton = UIButton(type: .system)
    private let retakeButton = UIButton(type: .system)
    
    private var previewPlayer: AVPlayer?
    private var previewPlayerLayer: AVPlayerLayer?
    
    private var lastRecordedVideoURL: URL?
    private var capturedPhotoImage: UIImage?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupShootUI()
        setupPreviewUI()
        view.addSubview(closeButton)
        checkCameraPermissionAndStart()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer?.frame = view.bounds
        
        // 关闭按钮布局
        let topInset = view.safeAreaInsets.top
        closeButton.frame = CGRect(x: 16,
                                   y: topInset + 30,
                                   width: 60,
                                   height: 30)
        
        // 拍摄按钮布局 & 进度圈路径
        layoutCaptureButton()
        updateProgressLayerPath()
        
        // 预览 UI 布局
        layoutPreviewUI()
        previewPlayerLayer?.frame = previewContainer.bounds
        imagePreviewView.frame = previewContainer.bounds
    }
    
    deinit {
        stopRecordProgressTimer()
        stopSession()
    }
}

// MARK: - 拍摄 UI & 手势
extension ServiceCameraCaptureViewController {
    
    private func setupShootUI() {
        view.addSubview(closeButton)
//        view.insertSubview(closeButton, at: 100)
        
        // 外圈按钮：不用 border，当作纯容器
        captureButton.backgroundColor = .clear
        captureButton.layer.borderWidth = 0
        captureButton.clipsToBounds = true
        
        // 内圈
        captureInnerView.backgroundColor = .white
        captureButton.addSubview(captureInnerView)
        view.addSubview(captureButton)
        
        // 底圈：灰色完整圆
        recordTrackLayer.strokeColor = UIColor.white.withAlphaComponent(0.25).cgColor
        recordTrackLayer.fillColor = UIColor.clear.cgColor
        recordTrackLayer.lineWidth = 4
        recordTrackLayer.strokeEnd = 1
        recordTrackLayer.isHidden = false
        
        // 进度圈：白色，默认 0
        recordProgressLayer.strokeColor = UIColor.white.cgColor
        recordProgressLayer.fillColor = UIColor.clear.cgColor
        recordProgressLayer.lineWidth = 4
        recordProgressLayer.strokeEnd = 0
        recordProgressLayer.isHidden = true
        
        captureButton.layer.addSublayer(recordTrackLayer)
        captureButton.layer.addSublayer(recordProgressLayer)
        
        // 手势：点击拍照 / 长按录制
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCaptureTap))
        let longPress = UILongPressGestureRecognizer(target: self,
                                                     action: #selector(handleCaptureLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        tap.require(toFail: longPress)
        
        captureButton.addGestureRecognizer(tap)
        captureButton.addGestureRecognizer(longPress)
    }
    
    private func layoutCaptureButton() {
        let bottomInset = view.safeAreaInsets.bottom
        let size: CGFloat = 80
        
        captureButton.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        captureButton.layer.cornerRadius = size / 2
        
        let centerY = view.bounds.height - bottomInset - 40 - size / 2
        captureButton.center = CGPoint(x: view.bounds.midX, y: centerY)
        
        captureInnerView.bounds = CGRect(x: 0, y: 0, width: size - 16, height: size - 16)
        captureInnerView.layer.cornerRadius = captureInnerView.bounds.width / 2
        captureInnerView.center = CGPoint(x: captureButton.bounds.midX,
                                          y: captureButton.bounds.midY)
        
        // 让进度圈的 frame 跟着按钮
        recordTrackLayer.frame = captureButton.bounds
        recordProgressLayer.frame = captureButton.bounds
    }
    
    /// 更新进度圈路径
    private func updateProgressLayerPath() {
        let bounds = captureButton.bounds
        guard bounds.width > 0 else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.width / 2 - recordProgressLayer.lineWidth / 2
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + CGFloat.pi * 2
        
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        recordTrackLayer.path = path.cgPath
        recordProgressLayer.path = path.cgPath
    }
}

// MARK: - 录制进度控制
extension ServiceCameraCaptureViewController {
    
    private func startRecordProgressTimer() {
        recordStartTime = CACurrentMediaTime()
        recordProgressLayer.strokeEnd = 0
        recordProgressLayer.isHidden = false
        
        recordDisplayLink?.invalidate()
        let link = CADisplayLink(target: self, selector: #selector(handleRecordProgressTick))
        link.add(to: .main, forMode: .common)
        recordDisplayLink = link
    }
    
    private func stopRecordProgressTimer() {
        recordDisplayLink?.invalidate()
        recordDisplayLink = nil
        recordStartTime = nil
        recordProgressLayer.strokeEnd = 0
        recordProgressLayer.isHidden = true
    }
    
    @objc private func handleRecordProgressTick() {
        guard let start = recordStartTime else { return }
        let elapsed = CACurrentMediaTime() - start
        let ratio = min(elapsed / maxVideoDuration, 1)
        
        recordProgressLayer.strokeEnd = CGFloat(ratio)
        
        if elapsed >= maxVideoDuration {
            // 时间到，自动停止录制
            stopRecording()
        }
    }
}

// MARK: - 权限 & Session
extension ServiceCameraCaptureViewController {
    
    private func checkCameraPermissionAndStart() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch videoStatus {
        case .authorized:
            setupSessionAndStartRunning()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if granted {
                        self.setupSessionAndStartRunning()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
            
        default:
            showPermissionAlert()
        }
    }
    
    private func setupSessionAndStartRunning() {
        guard !isSessionRunning else { return }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // 视频输入
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else {
            showPermissionAlert()
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("camera input error: \(error)")
            showPermissionAlert()
            return
        }
        
        // 音频输入
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            } catch {
                print("audio input error: \(error)")
            }
        }
        
        // 输出
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        captureSession.commitConfiguration()
        
        // 预览层
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        previewLayer = layer
        view.layer.insertSublayer(layer, at: 0)
        
        // 启动 session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
            self.isSessionRunning = true
        }
    }
    
    private func stopSession() {
        guard isSessionRunning else { return }
        captureSession.stopRunning()
        isSessionRunning = false
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "无法使用相机",
            message: "请在系统设置中允许访问相机后再试。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.cameraCaptureDidCancel(self)
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - 预览 UI（拍照 & 视频共用）
extension ServiceCameraCaptureViewController {
    
    private func setupPreviewUI() {
        previewContainer.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        previewContainer.isHidden = true
        view.addSubview(previewContainer)
        
        // 图片预览
        imagePreviewView.contentMode = .scaleAspectFit
        imagePreviewView.clipsToBounds = true
        previewContainer.addSubview(imagePreviewView)
        
        // 重拍按钮
        retakeButton.setTitle("重拍", for: .normal)
        retakeButton.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        retakeButton.backgroundColor = .COLOR_CARD_BG_WHITE
        retakeButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        retakeButton.layer.cornerRadius = 4
//        retakeButton.layer.borderWidth = 1
//        retakeButton.layer.borderColor = UIColor.white.cgColor
        retakeButton.addTarget(self, action: #selector(handleRetake), for: .touchUpInside)
        
        // 发送按钮
        sendButton.setTitle("发送", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        sendButton.backgroundColor = .THEME
        sendButton.layer.cornerRadius = 4
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        previewContainer.addSubview(retakeButton)
        previewContainer.addSubview(sendButton)
    }
    
    private func layoutPreviewUI() {
        previewContainer.frame = view.bounds
        imagePreviewView.frame = previewContainer.bounds
        
        let bottomInset = view.safeAreaInsets.bottom
        let buttonHeight: CGFloat = kFitWidth(40)
        let buttonWidth: CGFloat = kFitWidth(66)
        let spacing: CGFloat = 40
        
        let centerY = captureButton.jf_centerY//view.bounds.height - bottomInset - 30 - buttonHeight / 2
        
        retakeButton.frame = CGRect(
            x: spacing,
            y: centerY - buttonHeight / 2,
            width: buttonWidth,
            height: buttonHeight
        )
        
        sendButton.frame = CGRect(
            x: SCREEN_WIDHT - spacing - buttonWidth,
            y: centerY - buttonHeight / 2,
            width: buttonWidth,
            height: buttonHeight
        )
        
        previewPlayerLayer?.frame = previewContainer.bounds
    }
    
    /// 显示视频预览
    private func showVideoPreview(with url: URL) {
        lastRecordedVideoURL = url
        capturedPhotoImage = nil
        
        previewContainer.isHidden = false
        imagePreviewView.image = nil
        
        // 播放器
        let player = AVPlayer(url: url)
        previewPlayer = player
        
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        previewPlayerLayer?.removeFromSuperlayer()
        previewPlayerLayer = layer
        previewContainer.layer.insertSublayer(layer, below: retakeButton.layer)
        layer.frame = previewContainer.bounds
        
        player.play()
    }
    
    /// 显示照片预览
    private func showPhotoPreview(_ image: UIImage) {
        capturedPhotoImage = image
        lastRecordedVideoURL = nil
        
        // 停掉视频相关
        previewPlayer?.pause()
        previewPlayer = nil
        previewPlayerLayer?.removeFromSuperlayer()
        previewPlayerLayer = nil
        
        imagePreviewView.image = image
        previewContainer.isHidden = false
    }
    
    /// 隐藏预览（用于重拍）
    private func hidePreview() {
        previewContainer.isHidden = true
        imagePreviewView.image = nil
        
        previewPlayer?.pause()
        previewPlayer = nil
        previewPlayerLayer?.removeFromSuperlayer()
        previewPlayerLayer = nil
        
        lastRecordedVideoURL = nil
        capturedPhotoImage = nil
    }
    
    @objc private func handleRetake() {
        // 隐藏预览，回到拍摄状态
        hidePreview()
    }
    
    @objc private func handleSend() {
        if let image = capturedPhotoImage {
            // 拍照：点发送才回调给外部
            delegate?.cameraCapture(self, didCapturePhoto: image)
        } else if let url = lastRecordedVideoURL {
            // 视频：点发送才回调给外部
            delegate?.cameraCapture(self, didCaptureVideoAt: url)
        }
    }
}

// MARK: - 拍照 / 录制 操作
extension ServiceCameraCaptureViewController {
    
    @objc private func closeTapped() {
        delegate?.cameraCaptureDidCancel(self)
    }
    
    /// 点击：拍照（拍完不立即发，先预览）
    @objc private func handleCaptureTap() {
        guard !movieOutput.isRecording else { return } // 正在录制时不拍照
        takePhoto()
    }
    
    /// 长按：开始 / 结束 录制
    @objc private func handleCaptureLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startRecording()
        case .ended, .cancelled, .failed:
            stopRecording()
        default:
            break
        }
    }
    
    private func takePhoto() {
        let settings = AVCapturePhotoSettings()
        if photoOutput.isHighResolutionCaptureEnabled {
            settings.isHighResolutionPhotoEnabled = true
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func startRecording() {
        guard !movieOutput.isRecording else { return }
        
        movieOutput.maxRecordedDuration = CMTime(seconds: maxVideoDuration,
                                                 preferredTimescale: 600)
        
        if let connection = movieOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
        }
        
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = tempDir.appendingPathComponent("service_capture_\(UUID().uuidString).mp4")
        
        movieOutput.startRecording(to: fileURL, recordingDelegate: self)
        isRecording = true
        
        // 外圈进度开启
        startRecordProgressTimer()
        
        // 动画：录制时缩小内圆
        UIView.animate(withDuration: 0.2) {
            self.captureInnerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    private func stopRecording() {
        guard movieOutput.isRecording else { return }
        movieOutput.stopRecording()
        isRecording = false
        
        stopRecordProgressTimer()
        
        UIView.animate(withDuration: 0.2) {
            self.captureInnerView.transform = .identity
        }
    }
}

// MARK: - AVCapture Delegates
extension ServiceCameraCaptureViewController: AVCapturePhotoCaptureDelegate,
                                             AVCaptureFileOutputRecordingDelegate {
    
    // 拍照结果：不立刻发，先预览
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("photo error: \(error)")
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.showPhotoPreview(image)
        }
    }
    
    // 视频录制结束：不立刻发，先预览
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        stopRecordProgressTimer()
        
        if let error = error {
            print("record error: \(error)")
            DispatchQueue.main.async {
                self.delegate?.cameraCaptureDidCancel(self)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.showVideoPreview(with: outputFileURL)
        }
    }
}


