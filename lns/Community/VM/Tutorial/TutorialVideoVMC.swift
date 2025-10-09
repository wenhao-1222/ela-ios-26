//
//  TutorialVideoVMC.swift
//  lns
//
//  Created by Elavatine on 2024/12/23.
//

class TutorialVideoVMC: UIView {
    
    var selfHeight = kFitWidth(200)
    var controller = WHBaseViewVC()
    var player = ZFPlayerController()
    
    var model = ForumTutorialModel()
    var modelDetail = ForumModel()
//    var controlView = BLPlayerControlView.init(frame: UIScreen.main.bounds)
    
    var heightChanged:((CGFloat)->())?
    var playBlock:(()->())?
    var shareBlock:(()->())?
    
    var videoHeight = CGFloat(0)
    
    // 新增缓存相关
    private var resourceLoader: CachingPlayerItemLoader?
    private var currentPreloadTime: CMTime = .zero
    private var preloadQueue = DispatchQueue(label: "com.video.preload.queue")
    private var playerManager: ZFAVPlayerManager!
    private var lastSaveTime: TimeInterval = 0

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

extension TutorialVideoVMC{
    func updateUI(model:ForumTutorialModel) {
        self.model = model
        if self.videoHeight > 0{
            self.model.contentHeight = videoHeight
            if self.heightChanged != nil{
                self.heightChanged!(self.videoHeight)
            }
            return
        }
        let serialQueue = DispatchQueue(label: "com.tutorials.video")
        serialQueue.async {
            DSImageUploader().dealImgUrlSignForOss(urlStr: model.videoUrl) { urlStr in
                if let url = URL(string: urlStr){
                    let videoSize = ForumTutorialModel().dealCellHeight(videoUrl: url)
                    self.model.contentHeight = videoSize.height
                    self.model.contentWidth = videoSize.width
                    self.videoHeight = videoSize.height
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
            DSImageUploader().dealImgUrlSignForOss(urlStr: model.videoUrl) { urlStr in
                self.controlView.hideWith(animated: false, isSingleTap: false)
//                self.player.assetURL = URL(string: urlStr)!
                // 创建带缓存的Asset
//                let asset = self.createCachedAsset(url: url)
                // 2. 获取视频时长用于预加载量计算
//                let duration = try? await asset.load(.duration).seconds
//                let preloadLength = self.resourceLoader?.calculatePreloadLength(
//                    for: asset,
//                    duration: duration ?? 10 // 默认预加载10秒
//                )
                // 替换播放源
//                let playerItem = AVPlayerItem(asset: asset)
//                self.player.currentPlayerManager.replaceCurrentPlayerItem(playerItem)
//
                // 初始预加载
                self.switchVideoSource(url: URL(string: urlStr)!)
                self.preloadFrom(time: .zero)
                self.controlView.landScapeControlView.titleLabel.text = self.model.title
                self.sendTutorialClickRequest()
            }
        }else{
            
            if (modelDetail.videoUrl != nil) {
                self.player.assetURL = modelDetail.videoUrl!
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
//        self.player.stop()
        self.shareButton.isHidden = false
        self.coverView.isHidden = false
    }
}

extension TutorialVideoVMC{
    func initUI() {
        addSubview(videoImageView)
        addSubview(coverView)
        addSubview(playBtn)
        addSubview(shareButton)
        
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
//            make.right.equalTo(kFitWidth(-12))
            make.right.equalToSuperview()
//            make.top.equalTo(statusBarHeight)
            make.width.height.equalTo(kFitWidth(44))
        }
        initVideo()
    }
    
    func initVideo() {
        playerManager = ZFAVPlayerManager()
        playerManager.scalingMode = .aspectFit
        // 初始化缓存加载器
        resourceLoader = CachingPlayerItemLoader()
        self.player = ZFPlayerController.player(withPlayerManager: playerManager, containerView: self)
        self.player.controlView = self.controlView
        self.player.addPlayerView(toContainerView: self)
        // 添加时间观察器
//        if let avPlayerManager = player.currentPlayerManager as? ZFAVPlayerManager {
//            avPlayerManager.player?.addPeriodicTimeObserver(
//                forInterval: CMTime(seconds: 1, preferredTimescale: 1),
//                queue: .main
//            ) { [weak self] time in
//                self?.checkShouldPreload(time: time)
//            }
//        }
        // 添加时间监听
        playerManager.player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 1),
            queue: .main
        ) { [weak self] time in
            self?.checkShouldPreload(time: time)
        }
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
                self.controlView.autoFadeOutControlView()
            }else{
                DLLog(message: "playerPlayStateChanged : playStatePlaying   ----  other")
                self.controlView.showWithAnimatedForPlayEnd()
                self.controlView.cancelAutoFadeOutControlView()
            }
        }
        
        player.playerDidToEnd = { asset in
            DLLog(message: "playerDidToEnd : ")
            ws?.controlView.portraitControlView.playOrPauseBtn.isSelected = false
            ws?.controlView.landScapeControlView.playOrPauseBtn.isSelected = false
            self.controlView.showWithAnimatedForPlayEnd()
        }
        player.playerPlayTimeChanged = { asset, time, duration in
            if time > 0.05{
                self.videoImageView.isHidden = true
                self.player.containerView.alpha = 1
            }
        }
        player.playerBufferTimeChanged = { asset, bufferTime in
            DLLog(message: "setBufferValue playerBufferTimeChanged:\(bufferTime)")
        }
    }
}


extension TutorialVideoVMC{
    //教程视频播放统计
    func sendTutorialClickRequest() {
        let param = ["id":self.model.id]
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_click_count, parameters: param as [String:AnyObject]) { responseObject in
            
        }
    }
}
extension TutorialVideoVMC {
    private func checkShouldPreload(time: CMTime) {
        let preloadEnd = CMTimeAdd(currentPreloadTime, CMTime(seconds: 10, preferredTimescale: 1))
        guard CMTimeCompare(time, preloadEnd) > 0 else { return }
            
        preloadFrom(time: time)
//        let preloadEndTime = CMTimeAdd(time, CMTime(seconds: 10, preferredTimescale: 1))
        // 当超出当前预加载范围时触发
//        if !CMTimeRangeContainsTime(currentPreloadTime...CMTimeAdd(currentPreloadTime, CMTime(seconds: 10, preferredTimescale: 1)), time) {
//            preloadFrom(time: time)
//        }
    }
    
    private func preloadFrom(time: CMTime) {
        guard let asset = getCurrentAVURLAsset() else { return }
        
        preloadQueue.async { [weak self] in
            guard let self = self else { return }
           let startByte = self.calculateStartByte(time: time, asset: asset)
           let preloadLength = self.resourceLoader?.calculatePreloadLength(for: asset, duration: 10) ?? 10_000_000
            self.resourceLoader?.preload(
                url: asset.url,
                startOffset: startByte,
                length: preloadLength
            )
            self.currentPreloadTime = time
        }
    }
    private func createCachedAsset(url: URL) -> AVURLAsset {
            // 每次切换URL时创建新的Loader
        resourceLoader?.cancelCurrentLoading()
        let newLoader = CachingPlayerItemLoader()
        resourceLoader = newLoader
        
        // 自定义URL Scheme（需要处理URL转换）
        let proxyURL = url.absoluteString.replacingOccurrences(
            of: "http",
            with: "customscheme"
        )
        let asset = AVURLAsset(url: URL(string: proxyURL)!)
        asset.resourceLoader.setDelegate(newLoader, queue: .main)
        
        return asset
    }
}
extension TutorialVideoVMC {
    private func getCurrentAVURLAsset() -> AVURLAsset? {
        // 转换为具体的播放器管理器类型
        guard let avPlayerManager = player.currentPlayerManager as? ZFAVPlayerManager else {
            print("当前播放器不是 AVPlayer 实现")
            return nil
        }
        
        // 获取 AVPlayer 的当前播放项
        guard let currentItem = avPlayerManager.player?.currentItem else {
            print("当前没有加载的播放项")
            return nil
        }
        
        // 转换为 AVURLAsset
        return currentItem.asset as? AVURLAsset
    }
    private func calculateStartByte(time: CMTime, asset: AVURLAsset) -> Int64 {
        guard let track = asset.tracks(withMediaType: .video).first else { return 0 }
        let bitsPerSecond = track.estimatedDataRate
        let bytesPerSecond = bitsPerSecond / 8
        return Int64(time.seconds * Double(bytesPerSecond))
    }
    // 切换视频源的正确方式
    func switchVideoSource(url: URL) {
        // 1. 停止当前播放
        player.currentPlayerManager.stop?()
        
        guard let asset = resourceLoader?.createCachedAsset(with: url) else { return }

        // 3. 设置播放器URL为代理后的URL，确保走自定义的resourceLoader
        player.assetURL = asset.url

        // 4. 更新预加载起始时间
        currentPreloadTime = .zero
        preloadFrom(time: .zero)
        
//        // 2. 创建新的带缓存的Asset
//        let asset = resourceLoader?.createCachedAsset(with: url)
//        
//        // 3. 重新创建播放管理器
////        playerManager = ZFAVPlayerManager()
////        playerManager.scalingMode = .aspectFit
//        playerManager.assetURL = url // 使用原始URL（ResourceLoader会自动拦截）
//        
//        // 4. 替换播放器管理器
////        player.replacePlayerManager(newManager)
////        initVideo()
//        
//        // 5. 更新预加载
//        preloadFrom(time: .zero)
    }
}
