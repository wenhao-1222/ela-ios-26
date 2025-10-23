//
//  CameraViewController.swift
//  lns
//  ai_alert_close_icon
//  Created by Elavatine on 2025/3/6.
//
import AVFoundation
import UIKit
import MCToast
import AliyunOSSiOS

class CameraViewController: WHBaseViewVC {
    
    var isFromPlan = false
    var sourceType = ADD_FOODS_SOURCE.logs
    
    var controller = WHBaseViewVC()
    
    private var cachedDevice: AVCaptureDevice?
    private var lastKnownDevicePosition: AVCaptureDevice.Position = .back
    
    /// 专门用于相机会话相关操作的串行队列，避免多线程下的并发问题
    private let sessionQueue = DispatchQueue(label: "com.camera.session.queue",
                                            qos: .userInitiated)
//    private let sessionQueue = DispatchQueue(label: "com.camera.session.queue",
//                                            qos: .userInteractive,
//                                            attributes: .concurrent)
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var overlayView = UIView()
    private var cropFrame = CGRect(x: kFitWidth(55),
                                   y: WHUtils().getNavigationBarHeight() + kFitWidth(80),
                                   width: kFitWidth(265),
                                   height: kFitWidth(359)) // 自定义取景框尺寸
    
    // 其他UI组件（可以按需保留或移除）
    private let flashButton = UIButton()
    private let captureButton = UIButton()
    private let albumButton = UIButton()
    
    var isFirstLoad = true
    private var foodsImg = UIImage()
    
    var putTask = OSSPutObjectRequest()
    var taskModels:[AIResultStatusModel] = [AIResultStatusModel]()//上传后台的网络任务id  ：  本地是否已取消
    
    // 后台/中断/错误通知的观察者
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?
    
    // ————— 你的视图模型 / 其他 UI 组件 —————
    lazy var overLayImgView: UIImageView = {
        let img = UIImageView(frame: self.cropFrame)
        img.setImgLocal(imgName: "ai_camera_box_foods")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var overLayImgViewIngredient: UIImageView = {
        let img = UIImageView(frame: self.cropFrame)
        img.setImgLocal(imgName: "ai_camera_box_ingredient")
        img.isUserInteractionEnabled = true
        img.clipsToBounds = true
        img.alpha = 0
        return img
    }()
    
    lazy var naviVm: AINaviVM = {
        let vm = AINaviVM(frame: .zero)
        vm.backBlock = {() in
            self.stopCapture()
            self.backTapAction()
        }
        vm.tipsBlock = {() in
            self.tipsAlertVM.showView()
        }
        return vm
    }()
    lazy var typeVm: AITypeVM = {
        let vm = AITypeVM(frame: CGRect(x: 0,
                                        y: SCREEN_HEIGHT - kFitHeight(43) - kFitHeight(127) - WHUtils().getBottomSafeAreaHeight(),
                                        width: 0,
                                        height: 0))
        vm.typeChangeBlock = { tapIndex in
            self.refreshOverLayView()
        }
        return vm
    }()
    lazy var funcVm: AIBottomFuncVM = {
        let vm = AIBottomFuncVM(frame: CGRect(x: 0,
                                              y: SCREEN_HEIGHT - WHUtils().getBottomSafeAreaHeight() - kFitHeight(26),
                                              width: 0,
                                              height: 0))
        vm.flashBlock = {() in
            self.toggleFlash()
        }
        vm.captureBlock = {() in
            self.capturePhoto()
        }
        vm.albumBlock = {() in
            self.openAlbum()
        }
        return vm
    }()
    lazy var captureResultVm: AICapturePhotoVM = {
        let vm = AICapturePhotoVM(frame: .zero)
        vm.closeBlock = {() in
            self.resetCancelStatus(cancelStatus: .showAlert)
            self.showCancelAlertVm()
        }
        return vm
    }()
    lazy var tipsAlertVM: AITipsAlertVM = {
        let vm = AITipsAlertVM(frame: .zero)
        vm.aiTipsBlock = {() in
            self.aiLimitationAlertVm.showView()
        }
        return vm
    }()
    lazy var failAlertVm: AIFailAlertVM = {
        let vm = AIFailAlertVM(frame: .zero)
        vm.cancelBlock = {() in
            self.stopCapture()
            self.backTapAction()
        }
        vm.retryBlock = {() in
            self.captureResultVm.resetProgress()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.overLayImgViewIngredient.setImgLocal(imgName: "ai_camera_box_ingredient")
            }
            self.putTask.cancel()
            self.captureResultVm.hiddenView()
            self.naviVm.refreshShowStatus(isShow: true)
            self.typeVm.refreshShowStatus(isShow: true)
            self.funcVm.refreshShowStatus(isShow: true)
        }
        vm.hiddenBlock = {() in
            self.captureResultVm.closeImgView.isUserInteractionEnabled = true
        }
        return vm
    }()
    lazy var aiLimitationAlertVm: AILimitationTipsAlertVm = {
        let vm = AILimitationTipsAlertVm(frame: .zero)
        return vm
    }()
    
    // MARK: - Life Cycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
            name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self,
            name: UIApplication.didBecomeActiveNotification, object: nil)
        funcVm.updateFlashStatus(isOn: false)
        DLLog(message: "CameraViewController  viewWillDisappear ")
        self.stopCaptureSession()
        self.stopCapture()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DLLog(message: "CameraViewController  viewDidDisappear ")
        self.stopCaptureSession()
        self.stopCapture()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        // iPad适配
        if isIpad() {
            cropFrame = CGRect(x: SCREEN_WIDHT * 0.5 - kFitWidth(150),
                               y: WHUtils().getNavigationBarHeight() + kFitWidth(80),
                               width: kFitWidth(300),
                               height: kFitWidth(300) * 1.4)
        }
//        let dataObj = ["balance":"98",
//                       "calories":"315",
//                       "carbohydrate":"68",
//                       "contentType":"2",
//                       "energyUnit":"KJ",
//                       "fat":"1",
//        
//                       "fname":"枸杞",
//                       "measurementNum":"100",
//                       "measurementUnit":"g",
//                       "protein":"12.8"]
//        let vc = PropotionResultVC()
//        vc.msgDict = dataObj as NSDictionary
//        vc.isFromPlan = self.isFromPlan
//        vc.sourceType = self.sourceType
//        self.navigationController?.pushViewController(vc, animated: true)
        
        setupNotifications()
        initUI()
    }
    
    // MARK: - 前后台 & 会话中断通知
    private func setupNotifications() {
        // App前后台切换
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.stopCaptureSession()
        }
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self,
                    self.isViewLoaded,
                    self.view.window != nil else { return }
            self.restartCaptureSession()
        }
    }
    private func showCameraAccessDeniedAlert() {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(
                title: "无法访问相机",
                message: "请在“设置 > 隐私 > 相机”中启用访问权限。",
                preferredStyle: .alert
            )
//            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
                self.backTapAction()
            }))
            alert.addAction(UIAlertAction(title: "前往设置", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                self.backTapAction()
            })
            self.present(alert, animated: true)
        })
    }
    func updateUI() {
        // OK，继续
        self.setupCamera()
        self.view.insertSubview(captureResultVm, belowSubview: overLayImgView)
        view.addSubview(naviVm)
        view.addSubview(typeVm)
        view.addSubview(funcVm)
        view.addSubview(failAlertVm)
        view.addSubview(tipsAlertVM)
        view.addSubview(aiLimitationAlertVm)
        // 首次提示
        if UserDefaults.getString(forKey: .isShowAiTipsAlert)?.count ?? 0 == 0
            || UserDefaults.getString(forKey: .isShowAiTipsAlert)?.intValue == 2 {
            isFirstLoad = true
//            self.tipsAlertVM.refreshAlert()
//            self.tipsAlertVM.showView()
//            self.tipsAlertVM.confirmVm.startCountdown()
        }
    }
    // MARK: - 初始化 UI
    func initUI() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.updateUI()
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async { [self] in
                        self.updateUI()
                    }
                } else {
                    self.showCameraAccessDeniedAlert()
                    // 提示用户授权
                }
            }
            return
        default:
            // 用户拒绝授权或受限，提示用户去设置里开启权限
            self.showCameraAccessDeniedAlert()
//            return
        }
////        setupCamera()
//        
//        // 将预览层之下、结果视图之上插入
////        view.insertSubview(captureResultVm, at: 1)
////        view.insertSubview(captureResultVm, belowSubview: overLayImgView)
//        
//        // 其余UI按需添加
//        view.addSubview(naviVm)
//        view.addSubview(tipsAlertVM)
////        view.addSubview(typeVm)
////        view.addSubview(funcVm)
////        view.addSubview(failAlertVm)
////        view.addSubview(aiLimitationAlertVm)
//        
//        // 首次提示
//        if UserDefaults.getString(forKey: .isShowAiTipsAlert)?.count ?? 0 == 0
//            || UserDefaults.getString(forKey: .isShowAiTipsAlert)?.intValue == 2 {
//            isFirstLoad = true
//            self.tipsAlertVM.refreshAlert()
//            self.tipsAlertVM.showView()
//            self.tipsAlertVM.confirmVm.startCountdown()
//        }
    }
}

// MARK: - 相机核心逻辑
extension CameraViewController {
    private func bestMacroDevice() -> AVCaptureDevice? {
        // 在 iOS 15.4+ 上，“超广角镜头 + Macro” 同时可用
        // 这里先做一个 DiscoverySession 查找
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        )
        
        // iPhone 13 Pro/14 Pro等机型中，.builtInUltraWideCamera 才具备 Macro 能力
        let devices = discovery.devices
        let ultraWide = devices.first { $0.deviceType == .builtInUltraWideCamera }
        
        // 如果找不到，就退回 .builtInWideAngleCamera
        return ultraWide ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    private func setupCamera() {
        captureSession = AVCaptureSession()
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        
        // 这里仅演示用 builtInWideAngleCamera
        // 如果你想兼容近距离/微距可参考前面给你的 bestBackVideoDevice() 实现
        guard let device = bestMacroDevice(),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        // 配置对焦/曝光
        do {
            try device.lockForConfiguration()
            
            // 连续自动对焦
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            } else if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }
            
            // 若硬件支持近距离对焦
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }
            
            // 曝光
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            device.isSubjectAreaChangeMonitoringEnabled = true
            device.unlockForConfiguration()
        } catch {
            print("Camera configuration error: \(error)")
        }
        
        // 添加输入
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // 添加输出
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // 监听会话中断
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: captureSession)
        // 监听运行时错误
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: captureSession)
        
        // 预览图层
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        addCropOverlay()
        
        // 启动会话
        sessionQueue.async {
            self.captureSession.startRunning()
        }
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.captureSession.startRunning()
//        }
    }
    
    // MARK: - 会话被中断
    @objc private func sessionWasInterrupted(_ notification: Notification) {
        guard let info = notification.userInfo,
              let reasonValue = info[AVCaptureSessionInterruptionReasonKey] as? Int,
              let reason = AVCaptureSession.InterruptionReason(rawValue: reasonValue) else { return }
        
        print("AVCaptureSession Was Interrupted. Reason: \(reason)")
        // 暂时不做特殊处理，恢复逻辑会在 appDidBecomeActive / restartCaptureSession 里
    }
    
    // MARK: - 运行时错误
    @objc private func sessionRuntimeError(_ notification: Notification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print("AVCaptureSession Runtime Error: \(error)")
        
        // 出现错误后，通常尝试重新启动
        sessionQueue.async { [weak self] in
            guard let session = self?.captureSession else { return }
            if !session.isRunning {
                session.startRunning()
            }
        }
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let session = self?.captureSession else { return }
//            if !session.isRunning {
//                session.startRunning()
//            }
//        }
    }
    
    // MARK: - 添加取景框
    private func addCropOverlay() {
        overlayView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        overlayView.backgroundColor = .clear
        overlayView.isUserInteractionEnabled = true
        
        let path = UIBezierPath(rect: overlayView.bounds)
        let cropPath = UIBezierPath(rect: cropFrame)
        path.append(cropPath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        view.addSubview(overlayView)
        view.addSubview(overLayImgView)
        view.addSubview(overLayImgViewIngredient)
    }
    
    // MARK: - 停止、重启会话
    private func stopCaptureSession() {
        DLLog(message: "CameraViewController  stopCaptureSession  1111 ")
        guard captureSession?.isRunning == true else { return }
        
            DLLog(message: "CameraViewController  stopCaptureSession  2222 ")
        sessionQueue.async {
            [weak self] in
               DLLog(message: "CameraViewController  stopCaptureSession  333 ")
               self?.captureSession?.stopRunning()
        }
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            DLLog(message: "CameraViewController  stopCaptureSession  333 ")
//            self?.captureSession?.stopRunning()
//        }
    }
    
    private func restartCaptureSession() {
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        sessionQueue.async { [weak self] in
            guard let self = self, let session = self.captureSession else { return }
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    // 如果需要彻底释放相机占用，可在 push 其他界面时使用下列方法
    func stopCapture() {
        DLLog(message: "CameraViewController  stopCapture  1111 ")
        guard captureSession?.isRunning == true else { return }
        DLLog(message: "CameraViewController  stopCapture  2222 ")
        
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            DLLog(message: "CameraViewController  stopCapture  3333 ")
            // 可选：移除输入、释放硬件
            if let inputs = self?.captureSession?.inputs {
                DLLog(message: "CameraViewController  stopCapture  4444 ")
                for case let input as AVCaptureDeviceInput in inputs {
                    DLLog(message: "CameraViewController  stopCapture  5555 ")
                    self?.captureSession?.removeInput(input)
                    try? input.device.lockForConfiguration()
                    input.device.unlockForConfiguration()
                }
            }
        }
    }
}

// MARK: - 拍照/相册 逻辑
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    // 刷新取景框
    func refreshOverLayView() {
        if self.typeVm.tapIndex == 0 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.overLayImgView.alpha = 1
                self.overLayImgViewIngredient.alpha = 0
                self.overlayView.backgroundColor = .clear
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.overLayImgView.alpha = 0
                self.overLayImgViewIngredient.alpha = 1
                self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            }
        }
    }
    
    @objc private func capturePhoto() {
       guard captureSession?.isRunning == true,
       let connection = photoOutput.connection(with: .video),
           connection.isEnabled,
           connection.isActive else {
            restartCaptureSession()
            return
        }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // 相机拍照完成回调
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        DLLog(message: "photoOutput error: \(String(describing: error))")
        guard let imageData = photo.fileDataRepresentation(),
              var image = UIImage(data: imageData) else {
//            self.captureSession.startRunning()
            // 出现错误后，通常尝试重新启动
//            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            sessionQueue.async { [weak self] in
                guard let session = self?.captureSession else { return }
                if !session.isRunning {
                    session.startRunning()
                }
            }
            return
        }
        
        image = image.fixOrientation()
        captureResultVm.showView(img: image)
        naviVm.refreshShowStatus(isShow: false)
        typeVm.refreshShowStatus(isShow: false)
        funcVm.refreshShowStatus(isShow: false)
        funcVm.updateFlashStatus(isOn: false)
        
        // 转换坐标系并进行裁剪
        let cropRect = convertCropRectToImageCoordinates(image: image)
        if let croppedImage = image.cgImage?.cropping(to: cropRect) {
            let finalImage = UIImage(cgImage: croppedImage)
            self.sendImgForAiRequest(img: finalImage)
        } else {
            self.sendImgForAiRequest(img: image)
        }
    }
    
    // 相册
    func openAlbum() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // 坐标系转换
    private func convertCropRectToImageCoordinates(image: UIImage) -> CGRect {
        let imageSize = image.size
        let previewSize = previewLayer.bounds.size
        
        let scaleWidth = imageSize.width / previewSize.width
        let scaleHeight = imageSize.height / previewSize.height
        let scale = max(scaleWidth, scaleHeight)
        
        let visibleRect = CGRect(
            x: (previewSize.width * scale - imageSize.width) / 2,
            y: (previewSize.height * scale - imageSize.height) / 2,
            width: imageSize.width,
            height: imageSize.height
        )
        
        let cropRect = CGRect(
            x: (cropFrame.origin.x - visibleRect.origin.x) * scale,
            y: (cropFrame.origin.y - visibleRect.origin.y) * scale,
            width: cropFrame.width * scale,
            height: cropFrame.height * scale
        )
        return cropRect
    }
}

// MARK: - UIImagePickerController
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        
        captureResultVm.showView(img: image)
        naviVm.refreshShowStatus(isShow: false)
        typeVm.refreshShowStatus(isShow: false)
        funcVm.refreshShowStatus(isShow: false)
        funcVm.updateFlashStatus(isOn: false)
        
        self.sendImgForAiRequest(img: image)
    }
}

// MARK: - 闪光灯
extension CameraViewController {
    @objc private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            return
        }
        try? device.lockForConfiguration()
        device.torchMode = (device.torchMode == .on) ? .off : .on
        device.unlockForConfiguration()
    }
}

// MARK: - 网络/AI 逻辑 (保持原逻辑)
extension CameraViewController {
    func showCancelAlertVm() {
        let currentProgress = self.captureResultVm.progressView.progressLast
        self.captureResultVm.maxSimulatedProgressPause = currentProgress - 0.01
        
        let alertVm = UIAlertController(title: "取消不会保存当前识别进度",
                                        message: "",
                                        preferredStyle: .actionSheet)
        if let popover = alertVm.popoverPresentationController {
            popover.sourceView = self.captureResultVm.closeImgView
            popover.permittedArrowDirections = [.down]
        }
        
        let noAction = UIAlertAction(title: "否", style: .default) { action in
            self.captureResultVm.maxSimulatedProgressPause = currentProgress
            self.resetCancelStatus(cancelStatus: .normal)
        }
        let yesAciton = UIAlertAction(title: "是", style: .default) { action in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.overLayImgViewIngredient.setImgLocal(imgName: "ai_camera_box_ingredient")
            }
            self.resetCancelStatus(cancelStatus: .canceled)
            self.putTask.cancel()
            self.captureResultVm.cancelSimulation()
            self.captureResultVm.resetProgress()
            self.captureResultVm.hiddenView()
            self.naviVm.refreshShowStatus(isShow: true)
            self.typeVm.refreshShowStatus(isShow: true)
            self.funcVm.refreshShowStatus(isShow: true)
            self.stopCapture()
            self.backTapAction()
        }
        
        alertVm.addAction(noAction)
        alertVm.addAction(yesAciton)
        self.present(alertVm, animated: true)
    }
    
    func resetCancelStatus(cancelStatus: RESULT_CANCEL_STATUS) {
        for i in 0..<self.taskModels.count {
            let model = self.taskModels[i]
            if model.taskId == self.captureResultVm.currentTaskId {
                model.cancelStatus = cancelStatus
                self.taskModels[i] = model
                self.dealNetTask()
                break
            }
        }
    }
    
    func dealNetTask() {
        for i in 0..<self.taskModels.count {
            let model = self.taskModels[i]
            if model.taskId == self.captureResultVm.currentTaskId && model.cancelStatus == .normal {
                let obj = model.resultObj
                let code = obj["code"] as? Int ?? -1
                if code == 200 {
                    self.dealNetResutl(responseObject: obj)
                }else {
                    self.captureResultVm.hiddenView()
                    self.naviVm.refreshShowStatus(isShow: true)
                    self.typeVm.refreshShowStatus(isShow: true)
                    self.funcVm.refreshShowStatus(isShow: true)
                    MCToast.mc_text(obj["message"] as? String ?? "网络异常，请稍后重试")
                }
                break
            }
        }
    }
    
    func dealNetResutl(responseObject:NSDictionary) {
        let code = responseObject["code"] as? Int ?? -1
        self.captureResultVm.closeImgView.isUserInteractionEnabled = true
        if code == -1 {
            return
        }
        if code == 404{
            MCToast.mc_text("今日识别次数已用完，请明天再来\n（识图功能测试期间，每天可使用 10 次）")
            return
        }
        if code == 503{//AI识别功能维护中
            ConstantModel.shared.ai_identify_image_status = false
            self.presentAlertVc(confirmBtn: "确定",
                                message: "",
                                title: "\(responseObject["message"] as? String ?? "AI识别升级维护中，请稍后重试")",
                                cancelBtn: nil,
                                handler: { action in
                self.stopCapture()
                self.backTapAction()
            }, viewController: self)
        }
        if code == 400 {
            self.captureResultVm.rippleView.stopAnimation()
            self.captureResultVm.progressView.isHidden = true
            self.captureResultVm.progressLabel.isHidden = true
            self.captureResultVm.statusLabel.isHidden = true
            self.presentAlertVc(confirmBtn: "确定",
                                message: "",
                                title: "\(responseObject["message"] as? String ?? "网络异常，请稍后重试")",
                                cancelBtn: nil,
                                handler: { action in
                self.stopCapture()
                self.backTapAction()
            }, viewController: self)
            return
        }
        if code == 200 {
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendAiIdentifyRequest:\(String(describing: dataDict))")
            self.captureResultVm.completeBlock = {() in
                self.judgeAiResult(dataObj: dataDict)
            }
            self.captureResultVm.completeWithSuccess()
        } else {
            self.captureResultVm.completeWithFailure(failType:"2")
            self.failAlertVm.showView()
        }
        
        self.captureResultVm.rippleView.stopAnimation()
    }
    
    func sendImgForAiRequest(img: UIImage) {
        guard let imageData = WH_DESUtils.compressImage(toData: img) else { return }
        self.captureResultVm.startSimulation()
        self.overLayImgViewIngredient.setImgLocal(imgName: "ai_camera_box_ingredient_tran")
        self.foodsImg = img
        putTask = OSSPutObjectRequest()
        DLLog(message: "\(Date().currentSeconds)")
        DSImageUploader().uploadImage(imageData: imageData,
                                      imgType: .ai_photo,
                                      timeoutIntervalForRequest: 5,
                                      put: putTask) { bytesSent, totalByteSent, totalByteExpectedToSend in
            // 上传进度
        } completion: { text, value in
            if value == true {
                DLLog(message: "\(text)")
                self.sendAiIdentifyRequest(imgUrl: "\(text)")
            } else {
                self.overLayImgViewIngredient.setImgLocal(imgName: "ai_camera_box_ingredient")
                if !self.putTask.isCancelled {
                    self.captureResultVm.completeWithFailure(failType:"1")
                    self.captureResultVm.rippleView.stopAnimation()
                    self.failAlertVm.failContentLabel.text = "网络不佳，识别失败"
                    self.failAlertVm.numLabel.text = ""
                    self.failAlertVm.showView()
                } else {
                    DLLog(message: "取消图片上传")
                }
            }
        }
    }
    
    func sendAiIdentifyRequest(imgUrl: String) {
        self.captureResultVm.statusLabel.text = "正在分析营养成分"
        let param = ["ossUrl": imgUrl]
        let taskId = Date().timeStampMill
        let model = AIResultStatusModel().initWithTaskId(taskId: taskId)
        self.taskModels.append(model)
        self.captureResultVm.currentTaskId = taskId
        
        DLLog(message: "sendAiIdentifyRequest:\(param)")
        WHNetworkUtil.shareManager().POST(
            urlString: URL_foods_ai_identify,
            parameters: param as [String : AnyObject],
            isNeedToast: true,
            vc: self,
            taskId: taskId
        ) { responseObject in
            var currentModel = self.taskModels[0]
            var modelIndex = 0
            for i in 0..<self.taskModels.count {
                let statusModel = self.taskModels[i]
                if statusModel.taskId == self.captureResultVm.currentTaskId {
                    currentModel = statusModel
                    modelIndex = i
                    break
                }
            }
            
            if currentModel.cancelStatus == .normal {
                self.dealNetResutl(responseObject: responseObject as NSDictionary)
            } else if currentModel.cancelStatus == .showAlert {
                currentModel.resultObj = responseObject as NSDictionary
                self.taskModels[modelIndex] = currentModel
            }
        }
    }
    
    func judgeAiResult(dataObj: NSDictionary) {
        if dataObj.stringValueForKey(key: "contentType") == "1" {
            UserDefaults.set(value: "1", forKey: .isShowAiTipsAlert)
            self.stopCapture()
            let vc = AIResultVC()
            vc.foodsImg = self.foodsImg
            vc.msgDict = dataObj
            vc.isFromPlan = self.isFromPlan
            vc.sourceType = self.sourceType
            self.navigationController?.pushViewController(vc, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.overLayImgViewIngredient.setImgLocal(imgName: "ai_camera_box_ingredient")
            }
            self.resetCancelStatus(cancelStatus: .canceled)
            self.putTask.cancel()
            self.captureResultVm.hiddenView()
            self.naviVm.refreshShowStatus(isShow: true)
            self.typeVm.refreshShowStatus(isShow: true)
            self.funcVm.refreshShowStatus(isShow: true)
        }
        else if dataObj.stringValueForKey(key: "contentType") == "2" {
            UserDefaults.set(value: "1", forKey: .isShowAiTipsAlert)
            self.stopCapture()
            let vc = PropotionResultVC()
            vc.msgDict = dataObj
            vc.isFromPlan = self.isFromPlan
            vc.sourceType = self.sourceType
            self.navigationController?.pushViewController(vc, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.overLayImgViewIngredient.setImgLocal(imgName: "ai_camera_box_ingredient_tran")
            }
            self.resetCancelStatus(cancelStatus: .canceled)
            self.putTask.cancel()
            self.captureResultVm.hiddenView()
            self.naviVm.refreshShowStatus(isShow: true)
            self.typeVm.refreshShowStatus(isShow: true)
            self.funcVm.refreshShowStatus(isShow: true)
        }
        else {
            self.captureResultVm.completeWithFailure(failType:"0")
            self.failAlertVm.updateForFailReason()
            self.failAlertVm.showView()
            
            // 显示AI识别剩余次数提示
            if dataObj.stringValueForKey(key: "balance") == "3"{
                MCToast.mc_text("今日识别次数还剩 3 次\n（识图功能测试期间，每天可使用 10 次）")
            }else if dataObj.stringValueForKey(key: "balance") == "0"{
                MCToast.mc_text("今日识别次数已用完，请明天再来\n（识图功能测试期间，每天可使用 10 次）")
            }
        }
    }
}
