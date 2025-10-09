//
//  GuideTotalProgressVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//


class GuideTotalProgressVM: UIView {
    
    let progressWidth = SCREEN_WIDHT-kFitWidth(110)
    let totalStep = CGFloat(7)
    var stepWidth = kFitWidth(55)
    
    var backBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: kFitWidth(30)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        stepWidth = progressWidth/totalStep
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_back_button")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var backTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(backTapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var progressBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_06
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var progressView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: stepWidth*CGFloat(2), height: kFitWidth(6)))
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension GuideTotalProgressVM{
    @objc func backTapAction() {
        self.backBlock?()
    }
}

extension GuideTotalProgressVM{
    func setStep(step: Int, animated: Bool = true, duration: TimeInterval = 0.25) {
        let targetWidth = stepWidth * CGFloat(step + 1)
        
        if animated {
            UIView.animate(withDuration: duration) {
                // 直接修改 frame，UIKit 会自动做动画插值
                self.progressView.frame.size.width = targetWidth
            }
        } else {
            // 立刻更新
            self.progressView.frame.size.width = targetWidth
        }
    }
}

extension GuideTotalProgressVM{
    func initUI() {
        addSubview(backImg)
        addSubview(backTapView)
        addSubview(progressBottomView)
        progressBottomView.addSubview(progressView)
        
        setConstrait()
        
        setStep(step: 1)
    }
    func setConstrait() {
        backImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(30))
        }
        backTapView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(60))
        }
        progressBottomView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(55))
            make.right.equalTo(kFitWidth(-55))
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(6))
        }
    }
}
