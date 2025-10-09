//
//  CourseMenuHeadVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/11.
//

import SkeletonView

class CourseMenuHeadVM : UIView{
    
    var selfHeight = WHUtils().getNavigationBarHeight()
    
    var headMsgDict = NSDictionary()
    var heightChangeBlock:(()->())?
    var playTapBlock:(()->())?
    var player = ZFPlayerController()
    var playerManager = ZFAVPlayerManager()
    var isManualPause = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        self.selfHeight = frame.size.height
        
        initUI()
        initVideo()
    }
    lazy var coverImgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        img.backgroundColor = .COLOR_GRAY_F7F8FA
        
        return img
    }()
    lazy var videoPlayImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
//        img.setImgLocal(imgName: "course_video_play_icon")
        img.setImgLocal(imgName: "video_play_icon")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoPlayAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var bottomWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
//        vi.isSkeletonable = true
        
        return vi
    }()
    lazy var numberBgView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "626B82", alpha: 0.1)
        vi.isSkeletonable = true
        
        return vi
    }()
    lazy var numberIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_number_icon")
        img.isHidden = true
        
        return img
    }()
    lazy var numerLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .medium)
        
        return lab
    }()
    lazy var typeBgView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        vi.isSkeletonable = true
        
        vi.updateSkeleton(usingColor: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.05))
//        vi.showSkeleton(usingColor: [WHColorWithAlpha(colorStr: "007AFF", alpha: 0.05),WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08)])
//        vi.showAnimatedSkeleton(usingColor: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.05),animation: true)
        
        return vi
    }()
    lazy var typeIconImg: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var typeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "007AFF")
        lab.font = .systemFont(ofSize: 11, weight: .medium)
        
        return lab
    }()
//    lazy var progressBottomView: UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .COLOR_GRAY_F7F8FA
//        
//        return vi
//    }()
    lazy var progressBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LIGHT_GREY
        vi.isHidden = true
        return vi
    }()
    lazy var progressView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        
        return vi
    }()
    lazy var controlView: CourseCoverControlView = {
        let vi = CourseCoverControlView()
        vi.prepareShowControlView = true
//        vi.autoFadeTimeInterval = 0.2
        vi.portraitControlView.shareVideoBtn.isHidden = true
        vi.portraitControlView.backBtn.isHidden = true
//        vi.landScapeControlView.backBtn.isHidden = true
        vi.fastViewAnimated = true
        vi.prepareShowLoading = true
        vi.portraitControlView.nextBtn.isHidden = true
        vi.landScapeControlView.nextBtn.isHidden = true
        vi.customDisablePanMovingDirection = true
        vi.portraitControlView.updateUIForCourseCover()
        vi.portraitControlView.pauseManualTapBlock = {(isPlay)in
            if isPlay == false{
                self.isManualPause = false
            }else{
                self.isManualPause = true
            }
        }
        return vi
    }()
}

extension CourseMenuHeadVM{
    @objc func videoPlayAction() {
        self.videoPlayImgView.isHidden = true
//        self.coverImgView.isHidden = true
//        self.playTapBlock?()
        
        let coverInfo = self.headMsgDict["coverInfo"]as? NSDictionary ?? [:]
        DSImageUploader().dealImgUrlSignForOss(urlStr: coverInfo.stringValueForKey(key: "videoOssUrl"), completion: { str in
            DLLog(message: "视频播放URL:\(str)")
            if let strURL = URL(string: str){
//                    ZFPlayerModel.shared.player.assetURL = strURL
                self.player.assetURL = strURL
            }
        })
    }
}

extension CourseMenuHeadVM{
    func updateUI(dict:NSDictionary) {
//        hideSkeleton()
        self.headMsgDict = dict
        let coverInfo = dict["coverInfo"]as? NSDictionary ?? [:]
        
        if self.selfHeight < kFitWidth(65) && coverInfo.doubleValueForKey(key: "height") > 0 && coverInfo.doubleValueForKey(key: "width") > 0{
            let coverHeight = coverInfo.doubleValueForKey(key: "height")/coverInfo.doubleValueForKey(key: "width") * SCREEN_WIDHT
            self.selfHeight = kFitHeight(58) + coverHeight
            self.heightChangeBlock?()
        }
        numberIconImg.isHidden = false
        progressBottomView.frame = CGRect.init(x: 0, y: selfHeight-kFitWidth(61), width: SCREEN_WIDHT, height: kFitHeight(1))
        numberBgView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(22))
        }
        typeBgView.snp.remakeConstraints { make in
            make.left.equalTo(numberBgView.snp.right).offset(kFitWidth(10))
            make.top.height.equalTo(numberBgView)
        }
        numerLabel.text = "\(dict.stringValueForKey(key: "tutorialCount"))节"
        coverImgView.setImgUrl(urlString: coverInfo.stringValueForKey(key: "imageOssUrl"))
        
        typeIconImg.setImgUrl(urlString: dict.stringValueForKey(key: "iconOssUrl"))
        typeLabel.text = dict.stringValueForKey(key: "briefingText")
        
        if coverInfo.stringValueForKey(key: "videoOssUrl").count > 0 {
            videoPlayImgView.isHidden = false
        }else{
            videoPlayImgView.isHidden = true
        }
//
//        numberIconImg.setImgUrl(urlString: coverInfo.stringValueForKey(key: "iconOssUrl"))
        bottomWhiteView.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(13))
    }
    func updateProgress(current:Float,total:Float) {
        self.progressBottomView.isHidden = false
        
        let progressWidth = Float(SCREEN_WIDHT) * current/total
        
//        UIView.animate(withDuration: 0.2, delay: 0) {
            self.progressView.frame = CGRect.init(x: 0, y: 0, width: CGFloat(progressWidth), height: kFitWidth(1))
//        }
    }
}

extension CourseMenuHeadVM{
    func initVideo() {
        playerManager = ZFAVPlayerManager()
        playerManager.scalingMode = .aspectFit
//        playerManager.player.automaticallyWaitsToMinimizeStalling = false
//        playerManager.playerItem.preferredForwardBufferDuration = 10
        self.player = ZFPlayerController.player(withPlayerManager: playerManager, containerView: self.coverImgView)
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
        player.playerDidToEnd = {(asset)in
            DLLog(message: "playerDidToEnd:")
            self.isManualPause = true
            self.controlView.portraitControlView.playBtnSelectedState(false)
            self.controlView.showWithAnimatedForPlayEnd()
            self.controlView.cancelAutoFadeOutControlView()
        }
        player.playerPlayStateChanged = { asset, state in
            DLLog(message: "playerPlayStateChanged : \(state)")
            if state == .playStatePaused{
                self.controlView.showWithAnimatedForPlayEnd()
                self.controlView.cancelAutoFadeOutControlView()
            }else{
                self.isManualPause = false
//                self.controlView.autoFadeOutControlView()
            }
        }
        player.playerPlayTimeChanged = {asset,current,total in
            if current > 0.05{
                self.updateProgress(current: Float(current), total: Float(total))
            }
        }
    }
}

extension CourseMenuHeadVM{
    func initUI() {
        addSubview(coverImgView)
        coverImgView.addSubview(videoPlayImgView)
        
        addSubview(bottomWhiteView)
        bottomWhiteView.addSubview(numberBgView)
        numberBgView.addSubview(numberIconImg)
        numberBgView.addSubview(numerLabel)
        
        bottomWhiteView.addSubview(typeBgView)
        typeBgView.addSubview(typeIconImg)
        typeBgView.addSubview(typeLabel)
        
        addSubview(progressBottomView)
        progressBottomView.addSubview(progressView)
        
        setConstrait()
//        bottomWhiteView.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(13))
    }
    func setConstrait() {
        coverImgView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-45))
        }
        videoPlayImgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(28))
//            make.height.equalTo(kFitWidth(35))
            make.width.height.equalTo(kFitWidth(54))
        }
        bottomWhiteView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(60))
        }
        numberBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(22))
            make.width.equalTo(kFitWidth(54))
        }
        numberIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(7))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(14))
        }
        numerLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(27))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-7))
        }
        typeBgView.snp.makeConstraints { make in
            make.left.equalTo(numberBgView.snp.right).offset(kFitWidth(10))
            make.top.height.equalTo(numberBgView)
            make.width.equalTo(kFitWidth(54))
        }
        typeIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(7))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(14))
        }
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(27))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-7))
        }
//        progressBottomView.snp.makeConstraints { make in
//            make.left.width.equalToSuperview()
//            make.height.equalTo(kFitWidth(1))
//            make.bottom.equalTo(bottomWhiteView.snp.top)
//        }
//        progressView.snp.makeConstraints { make in
//            make.left.top.height.equalToSuperview()
//        }
    }
}
