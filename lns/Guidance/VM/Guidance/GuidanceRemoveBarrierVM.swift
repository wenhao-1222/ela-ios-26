//
//  GuidanceRemoveBarrierVM.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

class GuidanceRemoveBarrierVM: UIView {

    private let collageHeight = kFitWidth(524)
    private let leftSpeed: CGFloat = 20
    private let rightSpeed: CGFloat = 45
    private let scrollerInitialProgresses: [CGFloat] = [0.2, 0.45, 0.2, 0.49]
    private var hasStartedScrolling = false

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_WHITE
        isUserInteractionEnabled = true
        clipsToBounds = true
        initUI()
        updateGradientMaskColors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            updateGradientMaskColors()
        }
    }

    lazy var collageContainerView: UIView = {
        let vi = UIView()
        vi.clipsToBounds = true
        return vi
    }()

    lazy var scrollerOne: InfiniteImageScroller = {
        let scro = InfiniteImageScroller(
            frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(131)),
            imageName: "guide_second_img_1",
            direction: .left,
            speed: leftSpeed,
            initialProgress: scrollerInitialProgresses[0]
        )
        return scro
    }()

    lazy var scrollerTwo: InfiniteImageScroller = {
        let scro = InfiniteImageScroller(
            frame: CGRect(x: 0, y: kFitWidth(131), width: SCREEN_WIDHT, height: kFitWidth(131)),
            imageName: "guide_second_img_2",
            direction: .left,
            speed: rightSpeed,
            initialProgress: scrollerInitialProgresses[1]
        )
        return scro
    }()

    lazy var scrollerThree: InfiniteImageScroller = {
        let scro = InfiniteImageScroller(
            frame: CGRect(x: 0, y: kFitWidth(262), width: SCREEN_WIDHT, height: kFitWidth(131)),
            imageName: "guide_second_img_3",
            direction: .left,
            speed: leftSpeed,
            initialProgress: scrollerInitialProgresses[2]
        )
        return scro
    }()

    lazy var scrollerFour: InfiniteImageScroller = {
        let scro = InfiniteImageScroller(
            frame: CGRect(x: 0, y: kFitWidth(393), width: SCREEN_WIDHT, height: kFitWidth(131)),
            imageName: "guide_second_img_4",
            direction: .left,
            speed: rightSpeed,
            initialProgress: scrollerInitialProgresses[3]
        )
        return scro
    }()

    lazy var gradientMaskView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()

    lazy var gradientMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.locations = [0, 0.5, 1]
        return layer
    }()

//    lazy var logoLabel: UILabel = {
//        let lab = UILabel()
//        lab.text = "elavatine"
//        lab.textAlignment = .center
//        lab.textColor = .THEME
//        lab.font = .systemFont(ofSize: 30, weight: .bold)
//        return lab
//    }()
    
    lazy var logoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_first_page_logo_icon")
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "会帮助你消除这些阻碍"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var zhuanyeImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "guide_second_zhuanye_gray")
//        img.setImgLocal(imgName: "guide_second_zhuanye_gray")
//        img.tintColor = .COLOR_TEXT_TITLE_0f1214_20
        return img
    }()

    lazy var zhunayeLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.text = "与传奇运动员和营养师合作\n结合美国USDA等\n权威数据库"
        return lab
    }()

    lazy var jijianImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "guide_second_jijian_gray")
//        img.setImgLocal(imgName: "guide_second_jijian_gray")
//        img.tintColor = .COLOR_TEXT_TITLE_0f1214_20
        return img
    }()

    lazy var jijianLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "针对健身人习惯设计\n将每餐记录时间拉低到<30秒\n再忙也能记录"
        return lab
    }()
}

extension GuidanceRemoveBarrierVM {
    func updateGradientMaskColors() {
        let baseColor: UIColor
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            baseColor = UIColor(hex: "0f1219")
        } else {
            baseColor = .white
        }
        gradientMaskLayer.colors = [
            baseColor.withAlphaComponent(0).cgColor,
            baseColor.cgColor,
            baseColor.cgColor
        ]
    }

    func startScrollersIfNeeded() {
        guard !hasStartedScrolling else { return }
        scrollerOne.startScrolling()
        scrollerTwo.startScrolling()
        scrollerThree.startScrolling()
        scrollerFour.startScrolling()
        hasStartedScrolling = true
    }

    func stopScrollers() {
        scrollerOne.stopScrolling()
        scrollerTwo.stopScrolling()
        scrollerThree.stopScrolling()
        scrollerFour.stopScrolling()
        hasStartedScrolling = false
    }

    func initUI() {
        addSubview(collageContainerView)
        collageContainerView.addSubview(scrollerOne)
        collageContainerView.addSubview(scrollerTwo)
        collageContainerView.addSubview(scrollerThree)
        collageContainerView.addSubview(scrollerFour)
        addSubview(gradientMaskView)
        gradientMaskView.layer.addSublayer(gradientMaskLayer)

//        addSubview(logoLabel)
        addSubview(logoImgView)
        addSubview(titleLabel)
        addSubview(zhuanyeImg)
        addSubview(zhunayeLabel)
        addSubview(jijianImg)
        addSubview(jijianLabel)

        setConstraint()
    }

    func setConstraint() {
        collageContainerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(collageHeight)
        }

        scrollerOne.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(131))
        }

        scrollerTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollerOne.snp.bottom)
            make.height.equalTo(kFitWidth(131))
        }

        scrollerThree.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollerTwo.snp.bottom)
            make.height.equalTo(kFitWidth(131))
        }

        scrollerFour.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollerThree.snp.bottom)
            make.height.equalTo(kFitWidth(131))
        }

        gradientMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

//        logoLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(collageContainerView.snp.bottom).offset(kFitWidth(-66))
//        }
        
        logoImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(chart.snp.bottom).offset(kFitWidth(50))
            make.top.equalTo(collageContainerView.snp.bottom).offset(kFitWidth(-66))
            make.width.equalTo(kFitWidth(111))
//            make.bottom.equalTo(tipsLabel.snp.top).offset(kFitWidth(-50))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImgView.snp.bottom).offset(kFitWidth(18))
        }

        zhuanyeImg.snp.makeConstraints { make in
            make.centerX.equalTo(SCREEN_WIDHT * 0.25)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(40))
            make.width.equalTo(kFitWidth(157))
            make.height.equalTo(kFitWidth(45))
        }

        jijianImg.snp.makeConstraints { make in
            make.centerX.equalTo(SCREEN_WIDHT * 0.75)
            make.centerY.equalTo(zhuanyeImg)
            make.width.height.equalTo(zhuanyeImg)
        }

        zhunayeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(zhuanyeImg)
            make.top.equalTo(zhuanyeImg.snp.bottom).offset(kFitWidth(12))
        }

        jijianLabel.snp.makeConstraints { make in
            make.centerX.equalTo(jijianImg)
            make.top.equalTo(jijianImg.snp.bottom).offset(kFitWidth(12))
        }
    }
}

extension GuidanceRemoveBarrierVM {
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientMaskLayer.frame = gradientMaskView.bounds
        let logoTopLocation = max(0, min(1, logoImgView.frame.minY / max(bounds.height, 1)))
        gradientMaskLayer.locations = [0, NSNumber(value: Float(logoTopLocation)), 1]
    }
}
