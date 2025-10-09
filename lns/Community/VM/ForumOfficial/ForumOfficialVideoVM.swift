//
//  ForumOfficialVideoVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/30.
//


class ForumOfficialVideoVM: UIView {
    
    var selfHeight = kFitWidth(200)
    var videoWidth = kFitWidth(200)
    var controller = WHBaseViewVC()
//    var player = ZFPlayerController()
    
    var modelDetail = ForumModel()
    
    var heightChanged:((CGFloat)->())?
    var playBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .clear
        self.clipsToBounds = true
        selfHeight = frame.size.height
        
        initUI()
    }
    lazy var videoImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
//        img.tag = 3888
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
        vi.prepareShowControlView = true
        vi.autoFadeTimeInterval = 0.05
        vi.portraitControlView.shareVideoBtn.isHidden = true
        vi.portraitControlView.backBtn.isHidden = true
//        vi.landScapeControlView.backBtn.isHidden = true
        vi.fastViewAnimated = true
        vi.prepareShowLoading = true
        vi.portraitControlView.nextBtn.isHidden = true
        vi.landScapeControlView.nextBtn.isHidden = true
        vi.customDisablePanMovingDirection = true
        vi.backBtnClickCallback = {()in
            self.controller.backTapAction()
        }
        
        return vi
    }()
}

extension ForumOfficialVideoVM{
    func updateUIForForumDetail(model:ForumModel) {
        self.modelDetail = model
        self.videoImageView.image = self.modelDetail.coverImg
        var videoSizeResult = CGSize(width: 0, height: 0)
        if modelDetail.videoUrl != nil{
            DSImageUploader().dealImgUrlSignForOss(urlStr: modelDetail.videoUrl!.absoluteString) { signUrlString in
                guard let signUrl = URL(string: signUrlString) else { return  }
                VideoUtils.getVideoSizeAsync(url: signUrl) { videoSize in
                    let imgWidth = SCREEN_WIDHT
                    
                    if videoSize.width <= 0{
                        return
                    }
                    
                    if videoSize.height > videoSize.width{
                        videoSizeResult = CGSize(width: imgWidth, height: imgWidth)
                    }else{
                        let videoHeight = imgWidth*(videoSize.height)/videoSize.width
                        videoSizeResult = CGSize.init(width: imgWidth, height: videoHeight)
                    }
                    self.selfHeight = videoSizeResult.height
                    
                    self.videoImageView.snp.remakeConstraints { make in
                        make.top.equalToSuperview()
                        make.centerX.lessThanOrEqualToSuperview()
                        make.width.equalTo(videoSizeResult.width)
                        make.height.equalTo(videoSizeResult.height)
                    }
                    
                    if self.heightChanged != nil{
                        self.heightChanged!(videoSizeResult.height)
                    }
                }
            }
        }
    }
    func play() {
//        self.playBtn.isHidden = true
//        self.player.assetURL = modelDetail.videoUrl!
//        self.controlView.resetControlView()
    }
    @objc func playAction() {
        if self.playBlock != nil{
            self.playBlock!()
        }
    }
    func dealCellHeight(videoUrl:URL) -> CGSize {
        let imgWidth = SCREEN_WIDHT
        let videoSize = VideoUtils.getVideoSize(by: videoUrl)
        
        let maxHeight = imgWidth//SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-kFitWidth(56)-WHUtils().getBottomSafeAreaHeight() - kFitWidth(40)
        
        if videoSize.height > videoSize.width{
            return CGSize(width: imgWidth, height: imgWidth)
        }else{
            var videoHeight = imgWidth*(videoSize.height)/videoSize.width
            return CGSize.init(width: imgWidth, height: videoHeight)
        }
    }
}

extension ForumOfficialVideoVM{
    func initUI() {
        addSubview(videoImageView)
        
        videoImageView.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
//            make.width.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
}
