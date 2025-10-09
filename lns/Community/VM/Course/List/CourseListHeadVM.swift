//
//  CourseListHeadVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/16.
//

class CourseListHeadVM : UIView{
    
    var selfHeight = WHUtils().getNavigationBarHeight()
    var centerY = kFitWidth(0)
    var controller = WHBaseViewVC()
    
    var headMsgDict = NSDictionary()
    var heightChangeBlock:(()->())?
    var videoPlayBlock:(()->())?
    
//    private var didFinalizeHeight = false
    // ====== 新增：去抖相关 ======
    private var debounceWork: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.06   // 60ms 去抖
    private let heightChangeThreshold: CGFloat = 6       // 变化小于 6pt 不触发
    // ==========================
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        selfHeight = frame.size.height
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .clear
//        self.selfHeight = frame.size.height
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var videoBgView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(14)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.4)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(videoTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var videoPlayIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_play_icon")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var videoDesLabel: UILabel = {
        let lab = UILabel()
        lab.text = "视频介绍"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var bottomWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        vi.isUserInteractionEnabled = true
//        vi.isSkeletonable = true
        vi.layer.cornerRadius = kFitWidth(13)
        vi.clipsToBounds = true
//        vi.alpha = 0
        
        return vi
    }()
    lazy var numberBgView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "626B82", alpha: 0.1)
        
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
}

extension CourseListHeadVM{
    @objc func videoTapAction() {
        self.videoPlayBlock?()
    }
}

extension CourseListHeadVM{
    func updateUI(dict:NSDictionary) {
        self.headMsgDict = dict
        let coverInfo = dict["coverInfo"] as? NSDictionary ?? [:]
        let oldHeight = self.selfHeight
        var finalHeight = kFitHeight(30)
        self.imgView.setImgUrlWithComplete(urlString: coverInfo.stringValueForKey(key: "imageOssUrl")) {
            let imgW = self.imgView.image?.size.width ?? 1
            let imgH = self.imgView.image?.size.height ?? 0
            let coverHeight = imgH / imgW * SCREEN_WIDHT
            let finalHeight = kFitHeight(30) + coverHeight
            if finalHeight != self.selfHeight {
                self.selfHeight = finalHeight
                self.heightChangeBlock?()
            }
        }
        
        numberIconImg.isHidden = false
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
        
        typeIconImg.setImgUrl(urlString: dict.stringValueForKey(key: "iconOssUrl"))
        typeLabel.text = dict.stringValueForKey(key: "briefingText")
        if dict.stringValueForKey(key: "briefingBgRgb").count > 0 {
            typeBgView.backgroundColor = WHColorHex(dict.stringValueForKey(key: "briefingBgRgb"))
        }
        if dict.stringValueForKey(key: "briefingFontRgb").count > 0 {
            typeLabel.textColor = WHColorHex(dict.stringValueForKey(key: "briefingFontRgb"))
        }
    }
}

extension CourseListHeadVM{
    // ====== 关键：高度更新集中到一个方法，并做去抖 + 阈值过滤 ======
    private func scheduleHeightUpdate(_ newHeight: CGFloat) {
        // 小变化直接忽略，防止“抖”
        guard abs(newHeight - self.selfHeight) >= heightChangeThreshold else { return }

        // 取消上一次待执行的高度变更
        debounceWork?.cancel()

        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.selfHeight = newHeight
            self.heightChangeBlock?()
        }
        debounceWork = work
        // 略微延迟执行，聚合短时间内的多次高度变更
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: work)
    }
}

extension CourseListHeadVM{
    func initUI() {
        addSubview(imgView)
        imgView.addSubview(videoBgView)
        videoBgView.addSubview(videoPlayIcon)
        videoBgView.addSubview(videoDesLabel)
        
        addSubview(bottomWhiteView)
        bottomWhiteView.addSubview(numberBgView)
        numberBgView.addSubview(numberIconImg)
        numberBgView.addSubview(numerLabel)
        
        bottomWhiteView.addSubview(typeBgView)
        typeBgView.addSubview(typeIconImg)
        typeBgView.addSubview(typeLabel)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-30))
        }
        videoBgView.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-44))
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(88))
            make.height.equalTo(kFitWidth(28))
        }
        videoPlayIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(8))
            make.height.equalTo(kFitWidth(10))
        }
        videoDesLabel.snp.makeConstraints { make in
            make.left.equalTo(videoPlayIcon.snp.right).offset(kFitWidth(7))
            make.right.equalTo(kFitWidth(-4))
            make.centerY.lessThanOrEqualToSuperview()
        }
        bottomWhiteView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
//            make.bottom.equalTo(kFitWidth(2))
            make.bottom.equalTo(kFitWidth(15))
            make.height.equalTo(kFitWidth(62))
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
    }
}
