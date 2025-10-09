//
//  GuideTotalSecondNewVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//


class GuideTotalSecondNewVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    /// speed for views moving right to left (points per second)
    var leftSpeed: CGFloat = 20
    /// speed for views moving left to right (points per second)
    var rightSpeed: CGFloat = 45
    /// Called when user taps to proceed to the next page
    var nextBlock:(() -> Void)?
    
    /// The time when the page became visible
    var pageDisplayDate:Date?
    /// Ensures navigation only happens once
    private var hasScheduledNext = false
    
    private var scroller: InfiniteImageScroller!
    /// Ensure scrolling only starts once
    private var hasStartedScrolling = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = WHColor_16(colorStr: "252B3B")
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextTapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.bounces = false
        scro.alwaysBounceVertical = true
        scro.showsVerticalScrollIndicator = false
        return scro
    }()
    lazy var scrollerOne: InfiniteImageScroller = {
        let scro = InfiniteImageScroller(
            frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: kFitWidth(131)),
            imageName: "guide_second_img_1",
            direction: .left,
            speed: leftSpeed
        )
        return scro
    }()
    lazy var scrollerTwo: InfiniteImageScroller = {
        let scro = InfiniteImageScroller(
            frame: CGRect(x: 0, y: scrollerOne.frame.maxY, width: self.bounds.width, height: kFitWidth(131)),
            imageName: "guide_second_img_2",
            direction: .left,
            speed: rightSpeed
        )
        return scro
    }()
    lazy var scrollerThree: InfiniteImageScroller = {
        let scro = InfiniteImageScroller(
            frame: CGRect(x: 0, y: scrollerTwo.frame.maxY, width: self.bounds.width, height: kFitWidth(131)),
            imageName: "guide_second_img_3",
            direction: .left,
            speed: leftSpeed
        )
        return scro
    }()
    lazy var scrollerFour: InfiniteImageScroller = {
        let scro = InfiniteImageScroller(
            frame: CGRect(x: 0, y: scrollerThree.frame.maxY, width: self.bounds.width, height: kFitWidth(131)),
            imageName: "guide_second_img_4",
            direction: .left,
            speed: rightSpeed
        )
        return scro
    }()
    lazy var zhuanyeImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_second_zhuanye")
        
        return img
    }()
    lazy var zhunayeLabel: UILabel = {
        let lab = UILabel()
        lab.text = "与传奇运动员和营养师合作\n结合美国USDA等\n权威数据库"
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .white
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var jijianImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_second_jijian")
        
        return img
    }()
    lazy var jijianLabel: UILabel = {
        let lab = UILabel()
        lab.text = "针对健身人习惯设计，将每\n餐记录时间拉低到<30秒，\n再忙也能记录"
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .white
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    /// Overlay capturing taps
    lazy var nextTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextTapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    
    /// Starts all image scrollers once the view becomes visible
    func startScrollersIfNeeded() {
        guard !hasStartedScrolling else { return }
        scrollerOne.startScrolling()
        scrollerTwo.startScrolling()
        scrollerThree.startScrolling()
        scrollerFour.startScrolling()
        hasStartedScrolling = true
    }
}

extension GuideTotalSecondNewVM{
    @objc private func nextTapAction() {
//        nextBlock?()
        
//        guard !hasScheduledNext else { return }
        if pageDisplayDate == nil{
            return
        }
        hasScheduledNext = true
        let elapsed = Date().timeIntervalSince(pageDisplayDate!)
        let delay = max(0, 2.5 - elapsed)
        if delay <= 0 {
            nextBlock?()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.nextBlock?()
            }
        }
    }
}
extension GuideTotalSecondNewVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollView.addSubview(scrollerOne)
        scrollView.addSubview(scrollerTwo)
        scrollView.addSubview(scrollerThree)
        scrollView.addSubview(scrollerFour)
        scrollView.addSubview(zhuanyeImg)
        scrollView.addSubview(jijianImg)
        scrollView.addSubview(zhunayeLabel)
        scrollView.addSubview(jijianLabel)
//        scrollView.addSubview(nextTapView)

        // 启动滚动
//        scrollerOne.startScrolling()
//        scrollerTwo.startScrolling()
//        scrollerThree.startScrolling()
//        scrollerFour.startScrolling()
        
        setConstrait()
//        pageDisplayDate = Date()
        hasScheduledNext = false
    }
    func setConstrait() {
        zhuanyeImg.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(SCREEN_WIDHT*0.25+kFitWidth(5))
            make.top.equalTo(scrollerFour.snp.bottom).offset(kFitWidth(50))
            make.width.equalTo(kFitWidth(157))
            make.height.equalTo(kFitWidth(61))
        }
        jijianImg.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(zhuanyeImg)
            make.centerX.lessThanOrEqualTo(SCREEN_WIDHT*0.75-kFitWidth(5))
            make.width.height.equalTo(zhuanyeImg)
        }
        zhunayeLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(zhuanyeImg)
            make.top.equalTo(zhuanyeImg.snp.bottom).offset(kFitWidth(12))
        }
        jijianLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(jijianImg)
            make.top.equalTo(jijianImg.snp.bottom).offset(kFitWidth(12))
        }
//        nextTapView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
}

extension GuideTotalSecondNewVM {
    override func layoutSubviews() {
        super.layoutSubviews()
//        scrollView.frame = CGRect(x: 0,
//                                   y: 0,
//                                   width: bounds.width,
//                                   height: bounds.height)
        layoutIfNeeded()
        let extra = WHUtils().getBottomSafeAreaHeight() + kFitWidth(20)
        scrollView.contentSize = CGSize(width: 0, height: zhunayeLabel.frame.maxY + extra)
    }
}
