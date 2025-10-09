//
//  CoursePayOrderPayTypeVM.swift
//  lns
//  支付方式   默认微信
//  没有微信的时候，默认支付宝
//  Created by Elavatine on 2025/7/17.
//


enum PAY_TYPE {
    case wechat
    case alipay
}

class CoursePayOrderPayTypeVM : UIView{
    
    var selfHeight = kFitHeight(43)+kFitWidth(129)
    var payType = PAY_TYPE.wechat
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        selfHeight = WXApi.isWXAppInstalled() ? (kFitHeight(43)+kFitWidth(129)) : (kFitHeight(43)+kFitWidth(57)+kFitWidth(15))
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(16), height: kFitWidth(43)))
        lab.text = "选择支付方式"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        
        return lab
    }()
    lazy var cancelBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        btn.isHidden = true
//        btn.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(43), width: SCREEN_WIDHT, height: kFitWidth(1)))
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
    lazy var bottomLineView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: self.selfHeight-kFitWidth(1), width: SCREEN_WIDHT, height: kFitWidth(1)))
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
    lazy var wechatItemVm: CoursePayOrderPayTypeItemVM = {
        let vm = CoursePayOrderPayTypeItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(58), width: 0, height: 0))
        vm.titleLab.text = "微信支付"
        vm.isUserInteractionEnabled = false
        vm.payTypeIconImgView.setImgLocal(imgName: "course_pay_type_wechat")
//        vm.selectImgView.setImgLocal(imgName: "course_pay_type_select")
        vm.selectImgView.setCheckState(true,
                                  checkedImageName: "course_pay_type_select",
                                  uncheckedImageName: "course_pay_type_normal",
                                  animated: false)
        vm.tapBlock = {()in
            self.payType = .wechat
            self.updatePayType()
        }
        return vm
    }()
    lazy var alipayItemVm: CoursePayOrderPayTypeItemVM = {
        let vm = CoursePayOrderPayTypeItemVM.init(frame: CGRect.init(x: 0, y: self.wechatItemVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "支付宝支付"
        vm.payTypeIconImgView.setImgLocal(imgName: "course_pay_type_alipay")
//        vm.selectImgView.setImgLocal(imgName: "course_pay_type_select")
        vm.tapBlock = {()in
            self.payType = .alipay
            self.updatePayType()
        }
        return vm
    }()
    
}

extension CoursePayOrderPayTypeVM{
    func initUI() {
        addSubview(titleLab)
        addSubview(cancelBtn)
        addSubview(lineView)
        addSubview(bottomLineView)
        
        if WXApi.isWXAppInstalled(){
            payType = .wechat
            addSubview(wechatItemVm)
            addSubview(alipayItemVm)
        }else{
            payType = .alipay
            addSubview(alipayItemVm)
            alipayItemVm.frame = wechatItemVm.frame
//            alipayItemVm.selectImgView.setImgLocal(imgName: "course_pay_type_select")
            
            alipayItemVm.selectImgView.setCheckState(true,
                                             checkedImageName: "course_pay_type_select",
                                             uncheckedImageName: "course_pay_type_normal",
                                             animated: false)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(43))
        }
    }
    func updatePayType() {
        wechatItemVm.isUserInteractionEnabled = payType != .wechat
        alipayItemVm.isUserInteractionEnabled = payType != .alipay
        
        wechatItemVm.selectImgView.setCheckState(payType == .wechat,
                                                checkedImageName: "course_pay_type_select",
                                                uncheckedImageName: "course_pay_type_normal")
        alipayItemVm.selectImgView.setCheckState(payType == .alipay,
                                               checkedImageName: "course_pay_type_select",
                                               uncheckedImageName: "course_pay_type_normal")
//        switch payType{
//        case .wechat:
//            alipayItemVm.selectImgView.setImgLocal(imgName: "course_pay_type_normal")
//            wechatItemVm.selectImgView.setImgLocal(imgName: "course_pay_type_select")
//            break
//        case .alipay:
//            alipayItemVm.selectImgView.setImgLocal(imgName: "course_pay_type_select")
//            wechatItemVm.selectImgView.setImgLocal(imgName: "course_pay_type_normal")
//            break
//        }
    }
}
