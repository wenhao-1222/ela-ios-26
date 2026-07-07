//
//  GuideTotalProVM.swift
//  lns
//
//  Created by Codex on 2026/7/6.
//

class GuideTotalProVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(() -> Void)?
    
    override init(frame:CGRect){
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
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
        lab.text = "记录饮食只是第一步"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        return lab
    }()
    
    lazy var proImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_pro_diet_record")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return btn
    }()
}

extension GuideTotalProVM {
    @objc private func nextButtonAction() {
        nextBlock?()
    }
}

extension GuideTotalProVM {
    func initUI() {
        addSubview(scrollView)
        addSubview(nextButton)
        
        scrollView.addSubview(titleLab)
        scrollView.addSubview(proImgView)
        
        setConstrait()
    }
    
    func setConstrait() {
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(kFitWidth(-18))
        }
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }
        titleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(25))
        }
        proImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(170))
            make.width.equalTo(kFitWidth(308))
            make.height.equalTo(kFitWidth(250))
            make.bottom.equalToSuperview().offset(kFitWidth(-24))
        }
    }
}

extension GuideTotalProVM {
    func prepareEntranceAnimation() {
        scrollView.setContentOffset(.zero, animated: false)
        titleLab.alpha = 0
        proImgView.alpha = 0
        nextButton.alpha = 0
    }
    
    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.55, delay: 0, options: .curveLinear) {
            self.titleLab.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.55, delay: 0.1, options: .curveLinear) {
                self.proImgView.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
}
