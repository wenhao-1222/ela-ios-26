//
//  MaterialVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/11.
//

import Foundation
import MCToast
import IQKeyboardManagerSwift

public enum MATERIAL_TYPE {
    case avatar
    case nickname
    case gender
    case birthday
}

class MaterialVC: WHBaseViewVC {
    
    var headImgUrl = "\(UserInfoModel.shared.headimgurl)"
    var nickName = "\(UserInfoModel.shared.nickname)"
    var gender = "\(UserInfoModel.shared.gender)"
    var birthDay = "\(UserInfoModel.shared.birthDay)"
    
    var materialType = MATERIAL_TYPE.avatar
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
//        self.nameAlertVm.startCountdown()
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = true
//        self.nameAlertVm.disableTimer()
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
//    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = true
//        self.nameAlertVm.disableTimer()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        sendOssStsRequest()
    }
    lazy var avatarVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(8), width: 0, height: 0))
        vm.leftLabel.text = "头像"
        vm.detailLabel.isHidden = true
        vm.headImgView.isHidden = false
        vm.avatarStatusLabel.isHidden = UserInfoModel.shared.avatarStatus == .pass
        vm.headImgView.setImgUrl(urlString: "\(UserInfoModel.shared.headimgurl)")
//        vm.addTarget(self, action: #selector(takePickture), for: .touchUpInside)
        
        vm.tapBlock = {()in
            self.takePickture()
        }
        
        return vm
    }()
    lazy var idVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.avatarVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "ID"
        vm.arrowImgView.isHidden = true
        vm.detailLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        vm.isUserInteractionEnabled = false
        vm.detailLabel.text = "\(UserInfoModel.shared.id)"
        
        return vm
    }()
    lazy var nickNameVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.idVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "昵称"
        vm.detailLabel.text = "\(UserInfoModel.shared.nickname)"
        vm.tapBlock = {()in
            self.nameAlertVm.showView()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.nameAlertVm.startCountdown()
            })
        }
        
        return vm
    }()
    lazy var sexVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.nickNameVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "性别"
        vm.detailLabel.text = "\(UserInfoModel.shared.sex)"
        vm.tapBlock = {()in
            self.sexAlertVm.showView()
        }
        
        return vm
    }()
    lazy var birthDayVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.sexVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "生日"
        vm.detailLabel.text = "\(UserInfoModel.shared.birthDay)"
        vm.tapBlock = {()in
            self.dateFilterAlertVm.showView()
        }
        
        return vm
    }()
    lazy var ageVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.birthDayVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "年龄"
        vm.arrowImgView.isHidden = true
        vm.detailLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        vm.isUserInteractionEnabled = false
        vm.isHidden = true
        
        return vm
    }()
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(72)-getBottomSafeAreaHeight(), width: SCREEN_WIDHT, height: kFitWidth(72)+getBottomSafeAreaHeight()))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        return vi
    }()
    lazy var sexAlertVm: MaterialSexAlertVM = {
        let vm = MaterialSexAlertVM.init(frame: .zero)
        vm.confirmBlock = {(gender)in
            self.gender = gender
            self.materialType = .gender
            self.sendSaveMaterialRequest()
        }
        return vm
    }()
    lazy var dateFilterAlertVm : DataAddDateAlertVM = {
        let vm = DataAddDateAlertVM.init(frame: .zero)
        vm.isWeekDay = false
        vm.todayButton.isHidden = true
        vm.datePicker.minimumDate = nil
        vm.datePicker.maximumDate = Date()
        vm.confirmBlock = {(weekDay)in
            self.materialType = .birthday
            self.birthDay = self.dateFilterAlertVm.dateStringYear
            self.sendSaveMaterialRequest()
        }
        return vm
    }()
    lazy var nameAlertVm: MaterialNickNameAlertVM = {
        let vm = MaterialNickNameAlertVM.init(frame: .zero)
        vm.confirmBlock = {(name)in
            if name == "" || name.count == 0{
                MCToast.mc_failure("昵称不能为空！")
                return
            }
            self.nameAlertVm.disableTimer()
            self.materialType = .nickname
            self.nickName = self.nameAlertVm.textField.text ?? ""
            self.sendSaveMaterialNickNameRequest()
//            self.sendSaveMaterialRequest()
        }
        return vm
    }()
}

extension MaterialVC{
    func initUI()  {
        initNavi(titleStr: "编辑资料")
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        
        view.addSubview(avatarVm)
        view.addSubview(idVm)
        view.addSubview(nickNameVm)
        view.addSubview(sexVm)
        view.addSubview(birthDayVm)
        self.view.addSubview(self.ageVm)
        
        //优化页面加载速度
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.calculateAge()
            self.view.addSubview(self.sexAlertVm)
            self.view.addSubview(self.dateFilterAlertVm)
            self.view.addSubview(self.nameAlertVm)
        })
    }
    func calculateAge() {
        if self.birthDay.count > 6 {
            let currentYear = Int(Date().currenYearMonth[0] as? String ?? "0")
            let bornYear = self.birthDay.mc_clipFromPrefix(to: 4)
            DLLog(message: "bornYear:\(bornYear)")
            self.ageVm.isHidden = false
            self.ageVm.detailLabel.text = "\(Int(currentYear ?? 0) - (Int(bornYear) ?? 0))岁"
        }else{
            self.ageVm.isHidden = true
        }
    }
}

extension MaterialVC{
    @objc func sendSaveMaterialAvatarRequest() {
        MCToast.mc_loading()
        let param = ["headimgurl":"\(headImgUrl)"]
        
       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
           self.updateUI()
        }
    }
    @objc func sendSaveMaterialRequest() {
        MCToast.mc_loading()
        let param = ["gender":"\(gender)",
                     "birthday":"\(birthDay)"]
        
       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
           self.updateUI()
        }
    }
    @objc func sendSaveMaterialNickNameRequest() {
        MCToast.mc_loading()
        let param = ["nickname":"\(nickName)"]
        
       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
           self.updateUI()
        }
    }
    
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
    func updateUI() {
        switch materialType{
            case.avatar:
                self.avatarVm.headImgView.setImgUrl(urlString: "\(self.headImgUrl)")
                UserInfoModel.shared.headimgurl = self.headImgUrl
            case .birthday:
                self.birthDayVm.detailLabel.text = "\(self.birthDay)"
                UserInfoModel.shared.birthDay = self.birthDay
                self.calculateAge()
            case .gender:
                self.sexVm.detailLabel.text = "\(self.sexAlertVm.sex)"
                UserInfoModel.shared.gender = self.gender
                UserInfoModel.shared.sex = self.sexAlertVm.sex
            case .nickname:
                self.nickNameVm.detailLabel.text = "\(self.nickName)"
                UserInfoModel.shared.nickname = self.nickName
            break
        }
    }
}

extension MaterialVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @objc func takePickture(){
        let alertController=UIAlertController(title: "请选择照片来源", message: nil, preferredStyle: .actionSheet)
        if let popover = alertController.popoverPresentationController {
            // 锚点设置为触发按钮
            popover.sourceView = self.avatarVm.headImgView
            popover.permittedArrowDirections = [.up]
        }
        let cancel=UIAlertAction(title:"取消", style: .cancel, handler: nil)
        
        let takingPictures=UIAlertAction(title:"拍照", style: .default){ action in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let  cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                cameraPicker.allowsEditing = true
                cameraPicker.sourceType = .camera
                //在需要的地方present出来
                self.present(cameraPicker, animated: true, completion: nil)
            } else {
                print("不支持拍照")
            }
        }
        let photoPictures=UIAlertAction(title:"相册", style: .default){ action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let  cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                cameraPicker.allowsEditing = true
                cameraPicker.sourceType = .photoLibrary
                //在需要的地方present出来
                self.present(cameraPicker, animated: true, completion: nil)
            } else {
                print("不支持拍照")
            }
        }
        
        alertController.addAction(cancel)
        alertController.addAction(takingPictures)
        alertController.addAction(photoPictures)
        
        self.present(alertController, animated:true, completion:nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("获得照片============= \(info)")
        self.dismiss(animated: true, completion: nil)
        MCToast.mc_loading()
        let image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage)!
        let img = self.fixOrientation(image)
        
//        let imageData = img.pngData()
        let imageData = WH_DESUtils.compressImage(toData: img)
//        let imageData = image.jpegData(compressionQuality: 1.0)
        
        DSImageUploader().uploadImage(imageData: imageData!, imgType: .avatar) { text, value in
            DLLog(message: "\(text)")
            DLLog(message: "\(value)")
            MCToast.mc_remove()
            if value == true{
                self.headImgUrl = "\(text)"
                self.materialType = .avatar
                self.sendSaveMaterialAvatarRequest()
            }else{
                MCToast.mc_text("图片上传失败")
            }
        }
    }
}
