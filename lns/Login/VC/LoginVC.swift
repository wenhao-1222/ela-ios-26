//
//  LoginVC.swift
//  lns
//  欢迎页 的登录
//  Created by LNS2 on 2024/3/22.
//

import Foundation
import MCToast

class LoginVC: WHBaseViewVC {
    
    var isCodeShow = false
    var edgePanChangeX = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
        panGes.edges = .left
        view.addGestureRecognizer(panGes)
    }
    lazy var closeImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "login_close_img")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "262626")
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.text = "登录 elavatine"
        return lab
    }()
    
    lazy var phoneVm : LoginPhoneButton = {
        let vm = LoginPhoneButton.init(frame: CGRect.init(x: kFitWidth(24), y: kFitWidth(163)+getNavigationBarHeight(), width: 0, height: 0))
        vm.controller = self
        return vm
    }()
    lazy var getCodeBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("获取验证码", for: .normal)
//        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.backgroundColor = .THEME
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(getCodeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var codeVm : LoginCodeVerifyVM = {
        let vm = LoginCodeVerifyVM.init(frame: .zero)
        vm.controller = self
        vm.hasPlan = false
        vm.saveSurveyBlock = {()in
            self.changeRootVcToTabbar()
        }
        vm.closeBlock = {()in
            self.isCodeShow = false
        }
        vm.showBlock = {()in
            self.isCodeShow = true
        }
        return vm
    }()
    lazy var notRegistVm : NotRegistTipsVM = {
        let vm = NotRegistTipsVM.init(frame: .zero)
        vm.hiddenBlock = {()in
            self.backTapAction()
        }
        return vm
    }()
}

extension LoginVC{
    @objc func getCodeAction() {
//        if !judgePhoneNumber(phoneNum: phoneVm.phoneTextField.text){
//            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(-100),respond: .respond)
//            return
//        }
        if phoneVm.phoneTextField.text?.count ?? 0 < 7 {
            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        self.phoneVm.phoneTextField.resignFirstResponder()
        UserInfoModel.shared.idc = self.phoneVm.idc
        sendJudgePhoneRegist()
    }
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.edgePanChangeX = CGFloat(0)
        case .changed:
            let translation = gesture.translation(in: view)
//            DLLog(message: "translation.x:\(translation.x)")
            self.edgePanChangeX = self.edgePanChangeX + translation.x
            if self.isCodeShow{
                self.codeVm.center = CGPoint.init(x: self.edgePanChangeX+SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
            }
            
            gesture.setTranslation(.zero, in: view)
        case .ended:
            if self.isCodeShow == false{
                self.backTapAction()
            }else{
                self.codeVm.hiddenSelfAction()
            }
            
            break
        default:
            break
        }
    }
}

extension LoginVC{
    func initUI() {
        view.addSubview(closeImgView)
        view.addSubview(titleLabel)
        view.addSubview(phoneVm)
        view.addSubview(getCodeBtn)
        
        view.addSubview(codeVm)
        view.addSubview(notRegistVm)
        
        setConstrait()
    }
    func setConstrait() {
        closeImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(10))
            make.width.height.equalTo(kFitWidth(24))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(79)+getNavigationBarHeight())
        }
        getCodeBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(240)+getNavigationBarHeight())
//            make.width.equalTo(kFitWidth(327))
            make.width.equalTo(self.phoneVm.frame.width)
            make.height.equalTo(kFitWidth(56))
        }
    }
}

extension LoginVC{
    func sendJudgePhoneRegist() {
        MCToast.mc_loading()
        let param = ["phone":"\(phoneVm.phoneTextField.text ?? "")",
                     "idc":"\(UserInfoModel.shared.idc)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_judge_phone_regist, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            let respData = responseObject["data"]as? NSDictionary ?? [:]
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let respData = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            if respData["registered"] as? String ?? "" == "no"{
                self.notRegistVm.showView()
            }else{
                if respData.stringValueForKey(key: "state") == "1" {
                    self.phoneVm.phoneTextField.becomeFirstResponder()
                    self.codeVm.sendGetCodeRequest(phone: self.phoneVm.phoneTextField.text ?? "")
                    self.isCodeShow = true
                }else{
//                    MCToast.mc_text("用户已注销！")
                    self.presentAlertVc(confirmBtn: "确定", message: "Elavatine 作为一款免费软件，致力于在有限资源下为用户提供最佳体验。为了防止频繁重复注册占用服务器资源，注销后需等待约24小时才能重新注册，由此带来的不便，敬请谅解。", title: "提示", cancelBtn: nil, handler: { action in
                        
                    }, viewController: self)
                }
            }
        }
    }
}
