//
//  CoursePayOrderCouponVM.swift
//  lns
//  优惠券
//  Created by Elavatine on 2025/7/17.
//


class CoursePayOrderCouponVM : UIView{
    
    var selfHeight = kFitHeight(55)
    let maxLength = 8
    
    var deleteCouponBlock:(()->())?
    var couponApplyBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var noCouponView: FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.alpha = 1
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(inputTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var addCouponLabel: UILabel = {
        let lab = UILabel()
        lab.text = "添加优惠码"
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var addCounponTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var couponInputView: UIView = {
        let vi = UIView()
        vi.alpha = 0
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var codeInputText : ChineseTextField = {
        let text = ChineseTextField()
//        text.placeholder = "请输入优惠券码"
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.returnKeyType = .search
        text.clearButtonMode = .always
        text.keyboardType = .asciiCapable
        text.delegate = self
        text.textContentType = nil
        text.textNumber = maxLength
        
        return text
    }()
    lazy var couponApplyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("应用", for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(6)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(applyCouponTapAction), for: .touchUpInside)
        
        
        return btn
    }()
    lazy var cancelApplyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_TEXT_TITLE_0f1214_10), for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(6)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(cancelInputTapAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
    
    lazy var couponDetailView: UIView = {
        let vi = UIView()
        vi.alpha = 0
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var couponLab: UILabel = {
        let lab = UILabel()
        lab.text = "已优惠："
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return lab
    }()
    lazy var couponLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return lab
    }()
    lazy var couponDeleteButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "course_coupon_delete_icon"), for: .normal)
//        btn.addTarget(self, action: #selector(deleteTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var deleteTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(deleteTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension CoursePayOrderCouponVM{
    @objc func inputTapAction() {
        codeInputText.becomeFirstResponder()
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.noCouponView.alpha = 0
            self.couponInputView.alpha = 1
        }
    }
    @objc func cancelInputTapAction() {
        codeInputText.resignFirstResponder()
        self.deleteCouponBlock?()
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.couponInputView.alpha = 0
            self.noCouponView.alpha = 1
        }
    }
    @objc func deleteTapAction() {
        codeInputText.resignFirstResponder()
        codeInputText.text = ""
        self.deleteCouponBlock?()
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.couponInputView.alpha = 0
            self.couponDetailView.alpha = 0
            self.noCouponView.alpha = 1
        }
    }
    func showCouponMsg(dict:NSDictionary) {
        codeInputText.resignFirstResponder()
        couponLabel.text = "¥ \(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "discountAmount"))") ?? "")"
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.noCouponView.alpha = 0
            self.couponInputView.alpha = 0
            self.couponDetailView.alpha = 1
        }
    }
    @objc func applyCouponTapAction() {
        self.couponApplyBlock?()
    }
}

extension CoursePayOrderCouponVM{
    func initUI() {
        addSubview(noCouponView)
        noCouponView.addSubview(addCouponLabel)
        noCouponView.addSubview(addCounponTapView)
        
        addSubview(couponInputView)
        couponInputView.addSubview(codeInputText)
        couponInputView.addSubview(couponApplyButton)
        couponInputView.addSubview(cancelApplyButton)
        
        addSubview(couponDetailView)
        couponDetailView.addSubview(couponLab)
        couponDetailView.addSubview(couponLabel)
        couponDetailView.addSubview(couponDeleteButton)
        couponDetailView.addSubview(deleteTapView)
        
        setConstrati()
    }
    func setConstrati()  {
        noCouponView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        addCouponLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        addCounponTapView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        couponInputView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        codeInputText.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
            make.height.equalTo(kFitWidth(22))
            make.right.equalTo(kFitWidth(-145))
        }
        couponApplyButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-78))
            make.width.equalTo(kFitWidth(52))
            make.height.equalTo(kFitWidth(28))
        }
        cancelApplyButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(52))
            make.height.equalTo(kFitWidth(28))
        }
        couponDetailView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        couponLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        couponLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-46))
            make.centerY.lessThanOrEqualToSuperview()
        }
        couponDeleteButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        deleteTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(couponDeleteButton)
            make.width.height.equalTo(kFitWidth(50))
        }
    }
}

extension CoursePayOrderCouponVM:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textStr = (textField.text ?? "").replacingOccurrences(of: " ", with: "")
        if textStr.count > 0 {
            self.applyCouponTapAction()
        }else{
            self.cancelInputTapAction()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        var textString = textField.text ?? ""
        
        if string == ""{
            return true
        }
        if string == " "{
            return false
        }
        if textField.text?.count ?? 0 >= maxLength{
            return false
        }
        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        return true
    }
    //textField内容改变通知响应
    @objc func greetingTextFieldChanged(obj: Notification) {
//        DLLog(message: "greetingTextFieldChanged")
        //非markedText才继续往下处理
        guard let _: UITextRange = codeInputText.markedTextRange else{
            //当前光标的位置（后面会对其做修改）
            let cursorPostion = codeInputText.offset(from: codeInputText.endOfDocument,
                                                 to: codeInputText.selectedTextRange!.end)
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9]"//"[^A-Za-z0-9\\u0020\\u4E00-\\u9FA5]"
            var str = self.codeInputText.text!.pregReplace(pattern: pattern, with: "")
            if str.count > maxLength {
                str = String(str.prefix(maxLength))
            }
            self.codeInputText.text = str
             
            //让光标停留在正确位置
            let targetPostion = codeInputText.position(from: codeInputText.endOfDocument,
                                                   offset: cursorPostion)!
            codeInputText.selectedTextRange = codeInputText.textRange(from: targetPostion,
                                                              to: targetPostion)
            return
        }
    }
}
