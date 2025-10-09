//
//  TutorialVideoVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/23.
//

class TutorialVideoVM: UIView {
    
    var selfHeight = kFitWidth(211)
    var controller = WHBaseViewVC()
    var player = ZFPlayerController()
    var playerManager = ZFAVPlayerManager()
    
    var model = ForumTutorialModel()
    var modelDetail = ForumModel()
//    var controlView = BLPlayerControlView.init(frame: UIScreen.main.bounds)
    
    var heightChanged:((CGFloat)->())?
    var playBlock:(()->())?
    var shareBlock:(()->())?
    
    var videoHeight = CGFloat(211)
    private var lastSaveTime: TimeInterval = 0
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
            NotificationCenter.default.removeObserver(self)
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        
        initUI()
    }
    lazy var videoImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_tutorial_default_cover")
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var coverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_25
        return vi
    }()
    lazy var shareButton: UIButton = {
        let img = UIButton()
        img.isUserInteractionEnabled = true
        img.setImage(UIImage(named: "tutorial_share_icon"), for: .normal)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(shareAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "video_play_icon"), for: .normal)
        btn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return btn
    }()
    lazy var controlView: TutorialVideoControlView = {
        let vi = TutorialVideoControlView()
        vi.portraitControlView.isCalSafeArea = false
//        vi.prepareShowControlView = true
//        vi.autoFadeTimeInterval = 0.5
//        vi.tapFadeTimeInterval = 0
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        vi.horizontalPanShowControlView = false
        vi.fastViewAnimated = true
//        vi.prepareShowLoading = true
        vi.backBtnClickCallback = {()in
            self.controller.backTapAction()
        }
        
        return vi
    }()
    lazy var waterImgView: UIImageView = {
        let img = UIImageView()
        img.setImgUrl(urlString: "http://ve1.leungnutritionsciences.cn/3dbee7d6e49a87c561231da4f4674f61~tplv-9bf6daryby-image.image")
//        img.setImgUrlWithComplete(urlString: "https://ela-test.oss-cn-shenzhen.aliyuncs.com/avatar/user_avatar_5c370914e3297c1263e73c716d593497202507221345.png") {
//            if let image = img.image {
//                img.backgroundColor = UIColor(patternImage: image)
//                img.image = nil
//            }
//        }
        return img
    }()
    private lazy var captureShieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isHidden = true
        let label = UILabel()
        label.text = "录屏无法显示视频内容"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()
}

extension TutorialVideoVM{
    func updateUI(model:ForumTutorialModel) {
//        hideSkeleton()
        self.model = model
//        if self.videoHeight != kFitWidth(211){
//            self.model.contentHeight = videoHeight
//            if self.heightChanged != nil{
//                self.heightChanged!(self.videoHeight)
//            }
//            return
//        }
        let serialQueue = DispatchQueue(label: "com.tutorials.video")
        serialQueue.async {
            DSImageUploader().dealImgUrlSignForOss(urlStr: model.videoUrl) { urlStr in
                if let url = URL(string: urlStr){
                    let videoSize = ForumTutorialModel().dealCellHeight(videoUrl: url)
                    if videoSize.width > 0 || videoSize.height > 0 {
                        self.model.contentHeight = videoSize.height
                        self.model.contentWidth = videoSize.width
                        self.videoHeight = videoSize.height
                    }
                }
            }
        }
        serialQueue.async {
            DispatchQueue.main.async(execute: {
                if self.heightChanged != nil{
                    self.heightChanged!(self.model.contentHeight)
                }
            })
        }
    }
    func updateUIForForumDetail(model:ForumModel) {
        self.modelDetail = model
//        self.videoImageView.image = self.modelDetail.coverImg
    }
    func play() {
        self.playBtn.isHidden = true
        self.shareButton.isHidden = true
        self.coverView.isHidden = true
//        self.player.containerView.isHidden = false
        self.controlView.resetControlView()
        if let url = URL(string: model.videoUrl){
            self.controlView.hideWith(animated: false, isSingleTap: false)
            //如果已缓存，则直接命中缓存，直接播放

            let progress = CourseProgressSQLiteManager.getInstance().queryProgress(tutorialId: model.id)
            DSImageUploader().dealImgUrlSignForOss(urlStr: model.videoUrl) { urlStr in
                DLLog(message: "dealImgUrlSignForOss:\(urlStr)")
                if let realUrl = URL(string: urlStr){
                    self.player.assetURL = realUrl
                    if progress > 0 {
                        self.player.seek(toTime: progress, completionHandler: nil)
                    }
                }
            }
            
            self.controlView.landScapeControlView.titleLabel.text = self.model.title
            self.sendTutorialClickRequest()
        }else{
            
            if (modelDetail.videoUrl != nil) {
                
                let progress = CourseProgressSQLiteManager.getInstance().queryProgress(tutorialId: model.id)
                self.player.assetURL = modelDetail.videoUrl!
                if progress > 0 {
                    self.player.seek(toTime: progress, completionHandler: nil)
                }
            }
            
            self.controlView.landScapeControlView.titleLabel.text = self.modelDetail.title
        }

        self.player.containerView.backgroundColor = .COLOR_GRAY_BLACK_85
    }
    @objc func playAction() {
        self.coverView.isHidden = true
        self.playBtn.isHidden = true
        self.shareButton.isHidden = true
        if self.playBlock != nil{
            self.playBlock!()
        }
    }
    @objc func shareAction(){
        if self.shareBlock != nil{
            self.shareBlock!()
        }
    }
    func vcBack() {
        self.playBtn.isHidden = false

        self.shareButton.isHidden = false
        self.coverView.isHidden = false
    }
}

extension TutorialVideoVM{
    func initUI() {
        addSubview(videoImageView)
        addSubview(coverView)
        addSubview(playBtn)
        addSubview(shareButton)
        
        controlView.addSubview(captureShieldView)
        controlView.addSubview(waterImgView)
        captureShieldView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupCaptureProtection()
        
        videoImageView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        coverView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        playBtn.snp.makeConstraints { make in
            make.center.equalTo(videoImageView)
            make.width.height.equalTo(kFitWidth(54))
        }
        shareButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.height.equalTo(kFitWidth(44))
        }
        waterImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        initVideo()
    }
    
    func initVideo() {
        playerManager = ZFAVPlayerManager()
        playerManager.scalingMode = .aspectFit
//        playerManager.player.automaticallyWaitsToMinimizeStalling = false
//        playerManager.playerItem.preferredForwardBufferDuration = 10
        self.player = ZFPlayerController.player(withPlayerManager: playerManager, containerView: self)
        self.player.controlView = self.controlView
        
        self.player.shouldAutoPlay = false
        self.player.customAudioSession = true
        self.player.playThePrevious()
        
        self.player.scrollView?.backgroundColor = .black
        if #available(iOS 16.0, *) {
            self.player.forceDeviceOrientation = true
            self.player.allowOrentitaionRotation = false
        } else {
//            self.player.forceDeviceOrientation = false
            self.player.allowOrentitaionRotation = false
        }
        
        weak var ws = self
        
        self.player.playerPrepareToPlay = {(asset ,assertUrl)in
//            self.player
            
        }
        self.player.playerPlayFailed = {(asset,error)in
            DLLog(message: "playerPlayFailed:\(asset)-- error:\(error)")
            self.player.currentPlayerManager.replay?()
        }
        player.playerPlayStateChanged = { asset, state in
            DLLog(message: "playerPlayStateChanged : \(state)")
            if state == .playStatePlaying{
                DLLog(message: "playerPlayStateChanged : playStatePlaying")
//                self.controlView.autoFadeOutControlView()
            }else{
                DLLog(message: "playerPlayStateChanged : playStatePlaying   ----  other")
                self.controlView.showWithAnimatedForPlayEnd()
//                self.controlView.cancelAutoFadeOutControlView()
            }
        }
        
        player.playerDidToEnd = { asset in
            DLLog(message: "playerDidToEnd : ")
            ws?.controlView.portraitControlView.playOrPauseBtn.isSelected = false
            ws?.controlView.landScapeControlView.playOrPauseBtn.isSelected = false
            self.controlView.showWithAnimatedForPlayEnd()
            CourseProgressSQLiteManager.getInstance().updateProgress(tutorialId: self.model.id, courseId: self.model.courseId, progress: 0, duration: self.player.totalTime)
        }
        player.playerPlayTimeChanged = { asset, time, duration in
            if time > 0.05{
                self.videoImageView.isHidden = true
                self.player.containerView.alpha = 1
            }
            let now = Date().timeIntervalSince1970
            if now - self.lastSaveTime > 1 && time >= 5{
                self.lastSaveTime = now
                CourseProgressSQLiteManager.getInstance().updateProgress(tutorialId: self.model.id, courseId: self.model.courseId, progress: time, duration: duration)
            }
        }
//        player.playerBufferTimeChanged = { asset, bufferTime in
//            DLLog(message: "setBufferValue playerBufferTimeChanged:\(bufferTime)")
//        }
    }
}

extension TutorialVideoVM{
    //教程视频播放统计
    func sendTutorialClickRequest() {
        let param = ["id":self.model.id]
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_click_count, parameters: param as [String:AnyObject]) { responseObject in
            
        }
    }
}

extension TutorialVideoVM {
    private func setupCaptureProtection() {
        NotificationCenter.default.addObserver(self, selector: #selector(captureStatusChanged), name: UIScreen.capturedDidChangeNotification, object: nil)
        updateCaptureShield()
    }

    @objc private func captureStatusChanged() {
        updateCaptureShield()
    }

    private func updateCaptureShield() {
//        let capturing = UIScreen.main.isCaptured
//        captureShieldView.isHidden = !capturing
        
//        if capturing{
//            self.player.currentPlayerManager.pause?()
//        }
    }

}
