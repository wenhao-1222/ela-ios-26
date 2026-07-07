//
//  GuideTotalProgressVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//


class GuideTotalProgressVM: UIView {
    
    let progressWidth = SCREEN_WIDHT-kFitWidth(110)
    private var totalStep = CGFloat(6)
    var stepWidth = kFitWidth(55)
    
    var backBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: 44))
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
//        img.setImgLocal(imgName: "guide_back_button")
        img.image = UIImage(named: "habit_guide_back_icon")
//        img.image = UIImage(named: "guide_back_button")?.withTintColor(.COLOR_TEXT_TITLE_0f1214)
        img.isUserInteractionEnabled = true
        img.alpha = 0
        
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
        vi.alpha = 0
        
        return vi
    }()
    lazy var progressView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: stepWidth, height: kFitWidth(6)))
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        vi.alpha = 0
        
        return vi
    }()
}

extension GuideTotalProgressVM{
    func setBackOnlyMode(_ isBackOnly: Bool, animated: Bool = false) {
        let updateProgressVisibility = {
            self.progressBottomView.alpha = isBackOnly ? 0 : 1
            self.progressView.alpha = isBackOnly ? 0 : 1
        }
        let completion: (Bool) -> Void = { finished in
            guard finished else { return }
            self.progressBottomView.isHidden = isBackOnly
            self.progressView.isHidden = isBackOnly
        }
        
        if isBackOnly == false {
            progressBottomView.isHidden = false
            progressView.isHidden = false
            if animated, progressBottomView.alpha == 0 {
                progressBottomView.alpha = 0
                progressView.alpha = 0
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: updateProgressVisibility, completion: completion)
        } else {
            updateProgressVisibility()
            completion(true)
        }
        
        backImg.alpha = isBackOnly ? 1 : backImg.alpha
    }

    @objc func backTapAction() {
        self.backBlock?()
    }
}

extension GuideTotalProgressVM{
    func setTotalSteps(_ totalSteps: Int) {
        totalStep = CGFloat(max(totalSteps, 1))
        stepWidth = progressWidth / totalStep
        progressView.frame.size.width = stepWidth
    }

    func setStep(step: Int, animated: Bool = true, duration: TimeInterval = 0.25, showsBackButton: Bool? = nil) {
        setBackOnlyMode(false, animated: animated)
        let shouldShowBackButton = showsBackButton ?? (step > 0)
        if shouldShowBackButton {
            UIView.animate(withDuration: 0.35) {
                self.backImg.alpha = 1
            }
        } else {
            self.backImg.alpha = 0
        }
        
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
        
        setStep(step: 0, animated: false)
    }
    func setConstrait() {
        backImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(35))
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
