//
//  LoginPhoneButton.swift
//  lns
//
//  Created by LNS2 on 2024/4/3.
//

import Foundation
import UIKit

class LoginPhoneButton: UIView {
    
    let selfHeight = kFitWidth(56)
    var controller = WHBaseViewVC()
    var idc = "86"
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT - frame.origin.x*2, height: selfHeight))
//        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(327), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = kFitWidth(1)
        
        initUI()
        sendIdcListRequest()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var idcImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "idc_icon_china")
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        lab.text = "+86"
        lab.textColor = WHColor_16(colorStr: "262626")
//        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    lazy var downArrowImg : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "login_arrow_down_icon")
//        img.isHidden = true
        
        return img
    }()
    lazy var numTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(numTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var phoneTextField : NumericTextField = {
        let text = NumericTextField()
        text.keyboardType = .numberPad
        text.font = .systemFont(ofSize: 18, weight: .medium)
        text.placeholder = "请输入手机号"
        text.delegate = self
        text.textContentType = nil
        
        return text
    }()
    lazy var typeAlertVm: LoginPhoneTypeAlertVM = {
        let vm = LoginPhoneTypeAlertVM.init(frame: .zero)
        vm.choiceBlock = {(dict)in
            self.idc = dict.stringValueForKey(key: "idc")
            self.numberLabel.text = "+\(dict.stringValueForKey(key: "idc"))"
            if dict.stringValueForKey(key: "flags").count > 0{
                self.idcImgView.setImgUrl(urlString: dict.stringValueForKey(key: "flags"))
            }else{
                self.idcImgView.setImgLocal(imgName: "idc_icon_china")
            }
        }
        return vm
    }()
}

extension LoginPhoneButton{
    @objc func numTapAction() {
        typeAlertVm.showSelf()
        self.phoneTextField.resignFirstResponder()
    }
}
extension LoginPhoneButton{
    func initUI() {
        addSubview(idcImgView)
        addSubview(numberLabel)
        addSubview(downArrowImg)
        addSubview(phoneTextField)
        addSubview(numTapView)
        
//        self.controller.view.bringSubviewToFront(typeAlertVm)
//        UIApplication.shared.keyWindow?.addSubview(typeAlertVm)

        setConstrait()
    }
    func setConstrait() {
        idcImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(36))
        }
        numberLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(24))
            make.left.equalTo(idcImgView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualToSuperview()
        }
        downArrowImg.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(12))
        }
        phoneTextField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(116))
            make.right.equalTo(kFitWidth(-20))
            make.top.height.equalToSuperview()
//            make.left.equalTo(downArrowImg.snp.right).offset(kFitWidth(10))
        }
        numTapView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(115))
//            make.right.equalTo(downArrowImg).offset(kFitWidth(10))
        }
    }
}

extension LoginPhoneButton:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if range.length > 0 {
            return true
        }
        if textField.text?.count ?? 0 > 10 {
            return false
        }
        
        return true
    }
}

extension LoginPhoneButton{
    func sendIdcListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_idc_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "\(dataArray)")
            self.typeAlertVm.setDataArray(dataArray: dataArray, originY: self.frame.maxY+kFitWidth(6), selectedIndex: 0)
        }
    }
}
