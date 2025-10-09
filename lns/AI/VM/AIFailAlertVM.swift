//
//  AIFailAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/10.
//


class AIFailAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(296)+kFitWidth(55)+kFitWidth(16)+WHUtils().getBottomSafeAreaHeight()
    var whiteViewOriginY = kFitWidth(67)
    
    var isFirstLoad = true
    
    var cancelBlock:(()->())?
    var retryBlock:(()->())?
    var hiddenBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        initUI()
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
        
//        let tap = UITapGestureRecognizer.init(target: self, action:#selector(hiddenView))
//        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(67) + SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
//        
//        // 将手势识别器添加到view
//        vi.addGestureRecognizer(panGestureRecognizer)
        
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var failImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "ai_identify_fail_img")
        return img
    }()
    lazy var failTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.text = "识别失败"
        return lab
    }()
    lazy var numLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var failContentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "图片中不存在可使用的食物"
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var bottomFuncVm: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: whiteViewHeight-kFitWidth(55)-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16), width: SCREEN_WIDHT, height: kFitWidth(55)+WHUtils().getBottomSafeAreaHeight()))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.layer.borderColor = UIColor.COLOR_GRAY_BLACK_85.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()
    lazy var retryBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitle("重试", for: .normal)
        btn.backgroundColor = .THEME
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        
        return btn
    }()
}

extension AIFailAlertVM{
    @objc func nothingToDo() {
        
    }
    @objc func cancelAction() {
        self.cancelBlock?()
        self.hiddenView()
    }
    @objc func retryAction() {
        self.retryBlock?()
        self.hiddenView()
    }
    @objc func showView() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }
   }
   @objc func hiddenView() {
       self.hiddenBlock?()
       UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
           self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
           self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
       }completion: { t in
           self.isHidden = true
       }
  }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: view)
                DLLog(message: "translation.y:\(translation.y)")
                if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                    self.hiddenView()
                }else{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                    }
                }
            default:
                break
            }
        }
    }
}

extension AIFailAlertVM{
    func updateForFailReason() {
        numLabel.setLineSpace(lineSpcae: kFitWidth(2), textString: "1. \n2. \n3. ", lineHeight: 1.3)
        failContentLabel.setLineSpace(lineSpcae: kFitWidth(2), textString: "请确保食物完整位于识别框内\n避免拍摄光线过暗\nAI功能测试阶段，使用人数较多可能影响识别性能，请稍后重试或手动搜索添加",lineHeight: 1.3)
    }
}
extension AIFailAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(failImgView)
        whiteView.addSubview(failTitleLabel)
        whiteView.addSubview(numLabel)
        whiteView.addSubview(failContentLabel)
        
        whiteView.addSubview(bottomFuncVm)
        bottomFuncVm.addSubview(cancelBtn)
        bottomFuncVm.addSubview(retryBtn)
        
        setConstrait()
        bottomFuncVm.addShadow()
        
        updateForFailReason()
    }
    func setConstrait() {
        failImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(27))
            make.width.equalTo(kFitWidth(100))
            make.height.equalTo(kFitWidth(91))
        }
        failTitleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(failImgView.snp.bottom).offset(kFitWidth(10))
        }
        numLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(55))
            make.top.equalTo(failTitleLabel.snp.bottom).offset(kFitWidth(6))
        }
        failContentLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(55))
            make.left.equalTo(numLabel.snp.right)
            make.top.equalTo(numLabel)
            make.right.equalTo(kFitWidth(-55))
//            make.top.equalTo(failTitleLabel.snp.bottom).offset(kFitWidth(6))
        }
        let btnWidth = (SCREEN_WIDHT-kFitWidth(32)-kFitWidth(15))*0.5
        cancelBtn.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(5))
            make.width.equalTo(btnWidth)
            make.height.equalTo(kFitWidth(44))
        }
        retryBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(cancelBtn)
            make.centerY.lessThanOrEqualTo(cancelBtn)
        }
    }
}
