//
//  CoursePayOrderPayDesVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/17.
//


class CoursePayOrderPayDesVM : UIView{
    
    var controller = WHBaseViewVC()
    
    var tipsTapBlock:(()->())?
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var topWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        
        return vi
    }()
    lazy var logoIconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_pay_icon")
        
        return img
    }()
    lazy var desLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "课程收入全部用于产品研发与维护"
        lab.numberOfLines = 0
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "tips_gray_icon_w")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var iconTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tipsTapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var protocalLabel: YYLabel = {
        let lab = YYLabel()
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        let fullText = "点击支付即同意《课程购买协议》"
        let highlightText = "《课程购买协议》"
        let attributedString = NSMutableAttributedString(string: fullText)
//        attributedString.yy_font = UIFont.systemFont(ofSize: 16)
        attributedString.yy_color = UIColor.black

        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)

            // 设置颜色
            attributedString.yy_setColor(UIColor.systemBlue, range: nsRange)

            // 添加高亮点击事件
            let highlight = YYTextHighlight()
            highlight.setColor(.THEME)
            highlight.tapAction = { [weak self] _, _, _, _ in
                print("点击了《xxx服务协议》")
                let vc = WHCommonH5VC()
                vc.urlString = URL_turorial_purchase_agreement as NSString
                if self?.controller.navigationController != nil {
                    self?.controller.navigationController?.pushViewController(vc, animated: true)
                }else{
                    vc.modalPresentationStyle = .overFullScreen
                    self?.controller.present(vc, animated: true)
                }
            }

            attributedString.yy_setTextHighlight(highlight, range: nsRange)
        }

        lab.attributedText = attributedString
        return lab
    }()
}

extension CoursePayOrderPayDesVM{
    @objc func tipsTapAction() {
        self.tipsTapBlock?()
    }
}

extension CoursePayOrderPayDesVM{
    func initUI() {
        addSubview(topWhiteView)
        topWhiteView.addSubview(logoIconImgView)
        topWhiteView.addSubview(desLabel)
        topWhiteView.addSubview(iconImgView)
        topWhiteView.addSubview(iconTapView)
        
        addSubview(protocalLabel)
        setConstrait()
    }
    func setConstrait()  {
        topWhiteView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(73))
        }
        logoIconImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(61))
            make.height.equalTo(kFitWidth(11))
        }
        desLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(34))
            make.right.equalTo(kFitWidth(-50))
//            make.right.equalTo(kFitWidth(-16))
        }
        iconImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-18))
            make.width.height.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualTo(desLabel)
        }
        iconTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(iconImgView)
            make.width.height.equalTo(kFitWidth(50))
        }
        protocalLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-30))
        }
    }
    func refreshFrame(){
        protocalLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-12))
        }
    }
}
