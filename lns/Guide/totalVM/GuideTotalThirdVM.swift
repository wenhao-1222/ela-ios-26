//
//  GuideTotalThirdVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//

class GuideTotalThirdVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
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
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.text = "记录今天的饮食"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
//        lab.backgroundColor = WHColor_ARC()
        return lab
    }()
    lazy var imgBottomView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        return vi
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_img_step_3")
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(18)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(11)
        vi.clipsToBounds = true
        return vi
    }()
    
    lazy var addImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_third_add_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    
    lazy var ripple: RippleView = {
        let ripple = RippleView(frame: CGRect(x: 0, y: 0, width: kFitWidth(40), height: kFitWidth(40)))
        return ripple
    }()
    lazy var addTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(addTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension GuideTotalThirdVM{
    @objc func addTapAction() {
        self.nextBlock?()
    }
}

extension GuideTotalThirdVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.frame = CGRect.init(x: 0, y: statusBarHeight+kFitWidth(30), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-statusBarHeight-kFitWidth(30))
        
        scrollView.addSubview(titleLab)
        scrollView.addSubview(imgBottomView)
        imgBottomView.addSubview(imgView)
        imgView.addSubview(ripple)
        imgView.addSubview(whiteView)
        imgView.addSubview(addImgView)
        imgView.addSubview(addTapView)
        
        setConstrait()

        ripple.center = CGPoint(x: kFitWidth(281.5)+kFitWidth(5.7), y: kFitWidth(266.5)+kFitWidth(5.7))
//        ripple.startRipple()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(42))
        }
        imgBottomView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(335))
            make.top.equalTo(kFitWidth(141))
        }
        //658  1206
        imgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(5))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(325))
            make.height.equalTo(kFitWidth(603))
//            make.bottom.equalToSuperview()
            make.bottom.equalToSuperview().offset(kFitWidth(-5))
        }
        addImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(281.5))
            make.top.equalTo(kFitWidth(266.5))
            make.width.height.equalTo(kFitWidth(11.4))
        }
        whiteView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(addImgView)
            make.width.height.equalTo(kFitWidth(22))
        }
        addTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(addImgView)
            make.width.height.equalTo(kFitWidth(44))
        }
    }
}

extension GuideTotalThirdVM {
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0,
                                   y: statusBarHeight + kFitWidth(30),
                                   width: bounds.width,
                                   height: bounds.height - statusBarHeight - kFitWidth(30))
        layoutIfNeeded()
        if WHUtils().getBottomSafeAreaHeight() == 0 {
            let extra = kFitWidth(-20) //+ WHUtils().getBottomSafeAreaHeight()
            scrollView.contentSize = CGSize(width: 0, height: imgBottomView.frame.maxY + extra)
        }
    }
}
extension GuideTotalThirdVM {
    /// Prepares subviews for entrance animation
    func prepareEntranceAnimation() {
        titleLab.alpha = 0
        imgBottomView.alpha = 0
        self.scrollView.setContentOffset(.zero, animated: false)
    }

    /// Sequentially fades in the title and image views
    func startEntranceAnimation() {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.titleLab.alpha = 1
        }completion: { _ in
            UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                self.imgBottomView.alpha = 1
            }completion: { _ in
                self.isUserInteractionEnabled = true
            }
        }
        
    }
}
