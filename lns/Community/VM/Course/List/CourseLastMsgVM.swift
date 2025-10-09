//
//  CourseLastMsgVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/16.
//

class CourseLastMsgVM : UIView{
    
    var selfHeight = kFitHeight(104)
    
    var tapBlock:(()->())?
    var hasLastRecordBlock:(()->())?
    
    var id = ""
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT+selfHeight, width: SCREEN_WIDHT, height: selfHeight))
//        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-WHUtils().getBottomSafeAreaHeight()-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var whiteBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var videoImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var videoPlayImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_last_play_icon")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var videoDurationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .COLOR_GRAY_BLACK_25
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = kFitWidth(6)
        label.clipsToBounds = true
        return label
    }()
    lazy var lastTagLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = WHColor_16(colorStr: "FF8725")
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.textAlignment = .center
        lab.text = "上次观看"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 9, weight: .medium)
        
        return lab
    }()
    lazy var closeImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_last_close_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(closeAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    lazy var progressBgView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_C4C4C4
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        vi.isHidden = true
        
        return vi
    }()
    lazy var progressView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME//WHColor_16(colorStr: "FF8725")
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension CourseLastMsgVM{
    func showView(parentId:String) {
        let lastArray = UserDefaults.getCourseMsg()
        for i in 0..<lastArray.count{
            let dict = lastArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "parentId") == parentId{
                self.id = dict.stringValueForKey(key: "id")
                DispatchQueue.main.async {
                    self.videoImgView.setImgUrl(urlString: dict.stringValueForKey(key: "coverUrl"))
                    self.titleLab.text = dict.stringValueForKey(key: "title")
                    self.contentLabel.text = dict.stringValueForKey(key: "subTitle")
                    
                    if dict.stringValueForKey(key: "videoDuration").count > 0 {
                        self.videoDurationLabel.text = dict.stringValueForKey(key: "videoDuration")
                    }else{
                        self.videoDurationLabel.isHidden = true
                    }
                    self.updateProgress(dict: dict)
                        
                    self.isHidden = false
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.center = CGPoint(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-WHUtils().getBottomSafeAreaHeight()-self.selfHeight*0.5)
                    }
                    self.hasLastRecordBlock?()
                }
                break
            }
        }
    }
    func updateProgress(dict: NSDictionary) {
        let progress = CourseProgressSQLiteManager.getInstance().queryProgress(tutorialId: dict.stringValueForKey(key: "id"))
        let duration = CourseProgressSQLiteManager.getInstance().queryDuration(tutorialId: dict.stringValueForKey(key: "id"))
        if progress > 0 {
            let percent = progress/duration
            progressBgView.isHidden = false
            progressView.frame = CGRect.init(x: 0, y: 0, width: (SCREEN_WIDHT-kFitWidth(22)-kFitWidth(18))*percent, height: kFitWidth(2))
        } else {
            progressBgView.isHidden = true
        }
    }
    @objc func closeAction() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.center = CGPoint(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT+self.selfHeight*0.5)
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension CourseLastMsgVM{
    func initUI() {
        addSubview(whiteBgView)
        whiteBgView.addSubview(videoImgView)
        videoImgView.addSubview(videoDurationLabel)
        videoImgView.addSubview(videoPlayImgView)
        
        whiteBgView.addSubview(lastTagLabel)
        whiteBgView.addSubview(titleLab)
        whiteBgView.addSubview(contentLabel)
        whiteBgView.addSubview(closeImgView)
        
        whiteBgView.addSubview(progressBgView)
        progressBgView.addSubview(progressView)
        
        setConstrait()
        whiteBgView.addShadow()
    }
    func setConstrait() {
        whiteBgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(22))
            make.height.equalTo(kFitWidth(80))
        }
        videoImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(10))
            make.width.equalTo(kFitWidth(110))
            make.height.equalTo(kFitWidth(60))
        }
        videoPlayImgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(14))
            make.height.equalTo(kFitWidth(18))
        }
        lastTagLabel.snp.makeConstraints { make in
            make.top.equalTo(videoImgView).offset(kFitWidth(-3))
            make.right.equalTo(videoImgView).offset(kFitWidth(3))
            make.width.equalTo(kFitWidth(42))
            make.height.equalTo(kFitWidth(15))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(138))
            make.right.equalTo(kFitWidth(-42))
            make.top.equalTo(kFitWidth(19))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.right.equalTo(kFitWidth(-42))
            make.top.equalTo(kFitWidth(44))
        }
        closeImgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(10))
            make.right.equalTo(kFitWidth(-10))
            make.width.height.equalTo(kFitWidth(30))
        }
        videoDurationLabel.snp.makeConstraints { make in
            make.right.bottom.equalTo(kFitWidth(-4))
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(18))
        }
        progressBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.height.equalTo(kFitWidth(2))
            make.bottom.equalToSuperview()
        }
    }
}
