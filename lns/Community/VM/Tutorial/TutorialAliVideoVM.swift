//
//  TutorialAliVideoVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/11.
//

import AliyunPlayer
import UIKit

class TutorialAliVideoVM: UIView {
    
    var selfHeight = kFitWidth(211)
    var controller = WHBaseViewVC()
    var mAliPlayer: AliPlayer? = AliPlayer()
    var mediaLoader = AliMediaLoader()
//    private var sizeAliPlayer: AliPlayer?
    var controlView: TutorialVideoSwiftControlView?
    
    var model = ForumTutorialModel()
    var modelDetail = ForumModel()
    
    var heightChanged:((CGFloat)->())?
    var playBlock:(()->())?
    var shareBlock:(()->())?
    var nextVideoBlock:(()->())?
    var fullChangeBlock:((Bool)->())?
    
    var videoHeight = CGFloat(211)
    private var lastSaveTime: TimeInterval = 0
    private var originalFrame: CGRect = .zero
    private var hasStartedPlaying = false
    
    private var needsReplayAfterForeground = false
    private var pendingReplayPosition: Int64 = 0

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
            NotificationCenter.default.removeObserver(self)
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .black
        self.clipsToBounds = true
        originalFrame = self.frame
        
        initUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    lazy var videoImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_tutorial_default_cover")
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .black
        return img
    }()
    lazy var coverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_25
        return vi
    }()
    private lazy var progressBackgroundView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        vi.isHidden = true
        return vi
    }()
    private lazy var progressView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        return vi
    }()
}

extension TutorialAliVideoVM{
    func updateUI(model:ForumTutorialModel) {
        self.model = model
        
        self.controlView?.tutorialId = self.model.id
        self.controlView?.bottomToolVm.resetRate()
        if !model.videoVID.isEmpty && model.videoVID.count > 4{
            DispatchQueue.global().async {
                let source = AVPVidStsSource()
                source.region = "cn-shanghai"
                source.vid = model.videoVID//"b01caf5e8eb371f0aa3e5017e1f80102"
                source.securityToken = UserInfoModel.shared.ossSecurityToken
                source.accessKeyId = UserInfoModel.shared.ossAccessKeyId
                source.accessKeySecret = UserInfoModel.shared.ossAccessKeySecret
                
                self.mAliPlayer?.setStsSource(source)
                self.mAliPlayer?.prepare()
            }
        } else {
            DispatchQueue.global().async {
                DSImageUploader().dealImgUrlSignForOss(urlStr: model.videoUrl) { urlStr in
                    if let url = URL(string: urlStr){
                        let videoSize = ForumTutorialModel().dealCellHeight(videoUrl: url)
                        if videoSize.width > 0 || videoSize.height > 0 {
                            self.model.contentHeight = videoSize.height
                            self.model.contentWidth = videoSize.width
                            self.videoHeight = videoSize.height
                        }
                    }
                    DispatchQueue.main.async {
                        self.heightChanged?(self.model.contentHeight)
                    }
                }
            }
        }
    }
    func updateUIForForumDetail(model:ForumModel) {
        self.modelDetail = model
//        self.videoImageView.image = self.modelDetail.coverImg
    }
    func play() {
//        hasStartedPlaying = false
////        self.videoImageView.isHidden = false
//        self.coverView.isHidden = false
        hasStartedPlaying = true
        self.videoImageView.isHidden = true
        self.coverView.isHidden = true
        progressView.snp.updateConstraints { make in
            make.width.equalTo(0)
        }
        self.layoutIfNeeded()
        ensureValidOssParams { [weak self] in
            self?.startPlayback(resumePosition: nil, shouldQueryProgress: true, triggerStatistic: true)
        }
    }
    @objc func playAction() {
        self.coverView.isHidden = true
        self.videoImageView.isHidden = true
        if self.playBlock != nil{
            self.playBlock!()
        }
    }
}

extension TutorialAliVideoVM{
    func initUI() {
        mAliPlayer?.playerView = self
        mAliPlayer?.scalingMode = AVP_SCALINGMODE_SCALEASPECTFILL
        mAliPlayer?.setTraceID(UserInfoModel.shared.uId)
//        mAliPlayer?.delegate = self
//        let cacheConfig = AVPCacheConfig()
//        cacheConfig.enable = true
//        cacheConfig.maxDuration = 10
//        cacheConfig.path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
//        mAliPlayer?.setCacheConfig(cacheConfig)
        
        let config = AVPPreloadConfig()
        config.preloadDuration = 10000
//        mAliPlayer?.setsec
        
        AliPlayerGlobalSettings.enableLocalCache(true)
        self.mediaLoader = AliMediaLoader.shareInstance()
        self.mediaLoader.setAliMediaLoaderStatusDelegate(self)
        
        
        mAliPlayer?.enableHardwareDecoder = false
        
        addSubview(videoImageView)
        addSubview(coverView)
        videoImageView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        coverView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        addSubview(progressBackgroundView)
        progressBackgroundView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        progressBackgroundView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        initVideo()
    }
    
    func initVideo() {
        controlView = TutorialVideoSwiftControlView(player: mAliPlayer,frame: self.bounds)
        controlView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controlView?.playStatusChanged = { [weak self] playing in
            if playing {
                self?.hasStartedPlaying = true
            }
            let showCover = !playing && !(self?.hasStartedPlaying ?? false)
//            self?.videoImageView.isHidden = !showCover
//            self?.coverView.isHidden = !showCover
        }
        controlView?.heightChanged = {(contentHeight)in
            self.videoHeight = contentHeight
            self.model.contentHeight = contentHeight
            DispatchQueue.main.async {
                self.heightChanged?(contentHeight)
            }
        }
        addSubview(controlView!)
        controlView?.toolVisibilityChanged = { [weak self] hidden in
           self?.progressBackgroundView.isHidden = !hidden
       }
        controlView?.fullTapBlock = {(isFullScreen)in
            if isFullScreen{
                self.fullChangeBlock?(true)
                self.progressBackgroundView.alpha = 0
                self.progressView.alpha = 0
                self.originalFrame = self.frame
                self.frame = CGRect.init(x: 0, y: 0, width: SCREEN_HEIGHT, height: SCREEN_WIDHT)
                self.controlView?.frame = self.bounds
                UserConfigModel.shared.userInterfaceOrientation = .landscapeRight
                UserConfigModel.shared.allowedOrientations = .landscape
                if #available(iOS 16.0, *) {
                    self.controller.setNeedsUpdateOfSupportedInterfaceOrientations()
                } else {
                    UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
                }
            }else{
                self.fullChangeBlock?(false)
                self.frame = self.originalFrame
                self.progressBackgroundView.alpha = 1
                self.progressView.alpha = 1
                self.controlView?.frame = self.bounds
                UserConfigModel.shared.userInterfaceOrientation = .portrait
                UserConfigModel.shared.allowedOrientations = .portrait
                if #available(iOS 16.0, *) {
                    self.controller.setNeedsUpdateOfSupportedInterfaceOrientations()
                } else {
                    UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
                }
            }
        }
        controlView?.positionDidUpdate = { [weak self] time, duration in
            guard let self = self else { return }
            if time > 0.05 {
                self.videoImageView.isHidden = true
                self.coverView.isHidden = true
            }
            if duration > 0 {
                let ratio = CGFloat(time / duration)
                self.progressView.snp.updateConstraints { make in
                    make.width.equalTo(self.bounds.width * ratio)
                }
                self.layoutIfNeeded()
            }
            let now = Date().timeIntervalSince1970
            if now - self.lastSaveTime > 1 && time >= 5 {
                self.lastSaveTime = now
                CourseProgressSQLiteManager.getInstance().updateProgress(tutorialId: self.model.id, courseId: self.model.courseId, progress: time, duration: duration)
            }
        }
        controlView?.playbackCompleted = { [weak self] in
            guard let self = self else { return }
            let duration = Double(self.mAliPlayer?.duration ?? 0) / 1000.0
            CourseProgressSQLiteManager.getInstance().updateProgress(tutorialId: self.model.id, courseId: self.model.courseId, progress: 0, duration: duration)
            self.controlView?.showControls()
        }
        controlView?.backTapBlock = {()in
//            self.backTapAction()
            self.saveCurrentProgress()
            self.mAliPlayer?.stop()
            self.mAliPlayer?.destroy()
            self.mAliPlayer = nil
            self.controller.backTapAction()
        }
        controlView?.shareBlock = {()in
            self.shareBlock?()
        }
        controlView?.nextVideoBlock = {()in
            self.nextVideoBlock?()
        }
    }
}

extension TutorialAliVideoVM{
    //教程视频播放统计
    func sendTutorialClickRequest() {
        let param = ["id":self.model.id]
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_click_count, parameters: param as [String:AnyObject]) { responseObject in
            
        }
    }
}
private extension TutorialAliVideoVM {
    func saveCurrentProgress() {
        guard let player = mAliPlayer else { return }
        let time = Double(player.currentPosition) / 1000.0
        if time >= 5 {
            let duration = Double(player.duration) / 1000.0
            CourseProgressSQLiteManager.getInstance().updateProgress(tutorialId: model.id, courseId: model.courseId, progress: time, duration: duration)
        }
    }
}
extension TutorialAliVideoVM{
    func aliVidStsPlay()  {
        let source = AVPVidStsSource()
        source.region = "cn-shanghai"
        source.vid = "40c7fab671ab71f080086632b68f0102"//40c7fab671ab71f080086632b68f0102
        //c093a4a772a071f0bff54531958c0102   drm加密
        source.securityToken = UserInfoModel.shared.ossSecurityToken
        source.accessKeySecret = UserInfoModel.shared.ossAccessKeySecret
        source.accessKeyId = UserInfoModel.shared.ossAccessKeyId
        
        self.mAliPlayer?.setStsSource(source)
        self.mAliPlayer?.prepare()
    }
}

extension TutorialAliVideoVM{
    /// Stop and release the AliPlayer instance
    func releasePlayer() {
        saveCurrentProgress()
        needsReplayAfterForeground = false
        pendingReplayPosition = 0
        hasStartedPlaying = false
        mAliPlayer?.stop()
        mAliPlayer?.destroy()
        mAliPlayer = nil
    }
}

extension TutorialAliVideoVM:AliMediaLoaderStatusDelegate{
    func onCanceled(_ url: String!) {
        DLLog(message: "预加载----取消：\(url ?? "")")
    }
    func onErrorV2(_ url: String!, errorModel: AVPErrorModel!) {
        DLLog(message: "预加载----失败：\(url ?? "")")
        DLLog(message: "预加载----失败：\(errorModel)")
    }
    
    func onCompleted(_ url: String!) {
        DLLog(message: "预加载----完成：\(url ?? "")")
    }
}

extension TutorialAliVideoVM {
    func ensureValidOssParams(completion: @escaping () -> Void) {
        if UserInfoModel.shared.ossParamIsValid() {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        DSImageUploader().sendOssStsRequest { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func startPlayback(resumePosition: Int64?, shouldQueryProgress: Bool, triggerStatistic: Bool) {
        guard mAliPlayer != nil else { return }
        if !model.videoVID.isEmpty && model.videoVID.count > 4 {
            startVidPlayback(resumePosition: resumePosition, triggerStatistic: triggerStatistic)
        } else if let _ = URL(string: model.videoUrl) {
            startOssUrlPlayback(resumePosition: resumePosition, shouldQueryProgress: shouldQueryProgress, triggerStatistic: triggerStatistic)
        } else if let detailUrl = modelDetail.videoUrl {
            startDetailUrlPlayback(detailUrl: detailUrl, resumePosition: resumePosition, shouldQueryProgress: shouldQueryProgress)
        }
    }

    func startVidPlayback(resumePosition: Int64?, triggerStatistic: Bool) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let player = self.mAliPlayer else { return }
            player.stop()
            let source = AVPVidStsSource()
            source.region = "cn-shanghai"
            source.vid = self.model.videoVID
            source.securityToken = UserInfoModel.shared.ossSecurityToken
            source.accessKeyId = UserInfoModel.shared.ossAccessKeyId
            source.accessKeySecret = UserInfoModel.shared.ossAccessKeySecret
            player.setStsSource(source)
            player.prepare()
            if let resumePosition, resumePosition > 0 {
                player.seek(toTime: resumePosition, seekMode: AVP_SEEKMODE_ACCURATE)
            }
            player.start()
            if triggerStatistic {
                DispatchQueue.main.async {
                    self.sendTutorialClickRequest()
                }
            }
        }
    }

    func startOssUrlPlayback(resumePosition: Int64?, shouldQueryProgress: Bool, triggerStatistic: Bool) {
        let storedProgress: Double = shouldQueryProgress ? CourseProgressSQLiteManager.getInstance().queryProgress(tutorialId: model.id) : 0
        let resumeMs: Int64
        if let resumePosition, resumePosition > 0 {
            resumeMs = resumePosition
        } else if storedProgress > 0 {
            resumeMs = Int64(storedProgress * 1000)
        } else {
            resumeMs = 0
        }
        mAliPlayer?.stop()
        DSImageUploader().dealImgUrlSignForOss(urlStr: model.videoUrl) { [weak self] urlStr in
            guard let self = self else { return }
            guard let player = self.mAliPlayer else { return }
            DLLog(message: "dealImgUrlSignForOss:\(urlStr)")
            if let _ = URL(string: urlStr) {
                let urlSource = AVPUrlSource().url(with: urlStr)
                player.setUrlSource(urlSource)
                player.prepare()
                self.mediaLoader.load(urlStr, duration: 3*1000)
                if resumeMs > 0 {
                    player.seek(toTime: resumeMs, seekMode: AVP_SEEKMODE_ACCURATE)
                }
                player.start()
                if triggerStatistic {
                    self.sendTutorialClickRequest()
                }
            }
        }
    }

    func startDetailUrlPlayback(detailUrl: URL, resumePosition: Int64?, shouldQueryProgress: Bool) {
        let storedProgress: Double = shouldQueryProgress ? CourseProgressSQLiteManager.getInstance().queryProgress(tutorialId: model.id) : 0
        let resumeMs: Int64
        if let resumePosition, resumePosition > 0 {
            resumeMs = resumePosition
        } else if storedProgress > 0 {
            resumeMs = Int64(storedProgress * 1000)
        } else {
            resumeMs = 0
        }
        mAliPlayer?.stop()
        let urlSource = AVPUrlSource().url(with: detailUrl.absoluteString)
        mAliPlayer?.setUrlSource(urlSource)
        mAliPlayer?.prepare()
        mediaLoader.load(detailUrl.absoluteString, duration: 3*1000)
        if resumeMs > 0 {
            mAliPlayer?.seek(toTime: resumeMs, seekMode: AVP_SEEKMODE_ACCURATE)
        }
        mAliPlayer?.start()
    }

    @objc private func handleAppDidEnterBackground() {
        guard hasStartedPlaying else { return }
        pendingReplayPosition = mAliPlayer?.currentPosition ?? 0
        needsReplayAfterForeground = true
        saveCurrentProgress()
    }

    @objc private func handleAppDidBecomeActive() {
        guard hasStartedPlaying, needsReplayAfterForeground else { return }
        needsReplayAfterForeground = false
        let resumeMs = pendingReplayPosition
        pendingReplayPosition = 0
        guard mAliPlayer != nil else { return }
        ensureValidOssParams { [weak self] in
            guard let self = self else { return }
            if resumeMs > 0 {
                self.startPlayback(resumePosition: resumeMs, shouldQueryProgress: false, triggerStatistic: false)
            } else {
                self.startPlayback(resumePosition: nil, shouldQueryProgress: false, triggerStatistic: false)
            }
        }
    }
}
