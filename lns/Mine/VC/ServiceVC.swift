//
//  ServiceVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/16.
//

import Foundation
import PhotosUI
//import ShowBigImg
import MCToast
import IQKeyboardManagerSwift

class ServiceVC: WHBaseViewVC {
    
    let imgUlrs = NSMutableArray()
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = true
////        IQKeyboardManager.shared.enableAutoToolbar = true
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
//    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidLoad() {
        
        initUI()
        sendOssStsRequest()
        sendMsgListRequest()
    }
    
    lazy var text: ServiceTextView = {
        let text = ServiceTextView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        text.inputBlock = {(content)in
            let string = content.replacingOccurrences(of: " ", with: "")
            if string.count > 0 {
                self.submitButton.isEnabled = true
            }else{
                self.text.textView.text = ""
                self.text.placeholderLabel.isHidden = false
                self.submitButton.isEnabled = false
            }
        }
        return text
    }()
    lazy var imgsVm: ServiceImgView = {
        let vm = ServiceImgView.init(frame: CGRect.init(x: 0, y: self.text.frame.maxY, width: 0, height: 0))
        vm.addImgButton.addTarget(self, action: #selector(choiceImgAction), for: .touchUpInside)
        
        vm.imgTapBlock = {(image)in
//            let showController = ShowBigImgController(urls: [dict["imgurl"]as? String ?? ""], url: dict["imgurl"]as? String ?? "")
            let vc = ShowBigImgController(imgs: [image], img: image,isNavi: true)
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: false, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        return vm
    }()
    lazy var submitButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight(), width: kFitWidth(343), height: kFitWidth(48))
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .disabled)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("提交", for: .normal)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        
        return btn
    }()
}

extension ServiceVC{
    @objc func choiceImgAction() {
        // 创建一个PHPickerConfiguration对象
        var configuration = PHPickerConfiguration()

        // 设置选择器的过滤条件
        configuration.filter = .images // 只显示图片
        // configuration.filter = .videos // 只显示视频
        // configuration.filter = .any // 显示图片和视频，默认值为.any

        // 设置选择的限制条件
        configuration.selectionLimit = 3 // 最多允许选择的数量，默认值为1

        // 设置预览是否可用
        configuration.preferredAssetRepresentationMode = .automatic // 自动根据设备和资源类型选择最佳预览模式
        // configuration.preferredAssetRepresentationMode = .inline // 内联模式，缩略图与选择器一起显示
        // configuration.preferredAssetRepresentationMode = .aspectFit // 等比缩放以适应预览区域

        // 创建PHPickerViewController实例
        let picker = PHPickerViewController(configuration: configuration)
        picker.modalPresentationStyle = .overFullScreen
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    @objc func submitAction(){
        imgUlrs.removeAllObjects()
        if self.imgsVm.imgArray.count > 0 {
            MCToast.mc_loading(text: "图片上传中...")
            self.uploadImgData(image: self.imgsVm.imgArray[0], index: 0)
        }else{
            sendSuggestionRequest()
        }
    }
    func uploadImgData(image:UIImage,index:Int) {
//        let imageData = image.pngData()
        let imageData = WH_DESUtils.compressImage(toData: image)
        DSImageUploader().uploadImage(imageData: imageData!, imgType: .other) { text, value in
            DLLog(message: "\(text)")
            DLLog(message: "\(value)")
            MCToast.mc_remove()
            if value == true{
                self.imgUlrs.add("\(text)")
                if index < self.imgsVm.imgArray.count-1{
                    self.uploadImgData(image: self.imgsVm.imgArray[index+1], index: index+1)
                }else{
                    self.sendSuggestionRequest()
                }
            }else{
                MCToast.mc_text("图片上传失败")
            }
        }
        
//        DSImageUploader.shared.uploadImages(_image: imageData!,imgType: .other) { text, value in
//            DLLog(message: "\(text)")
//            DLLog(message: "\(value)")
//            if value == true{
//                self.imgUlrs.add("\(text)")
//                if index < self.imgsVm.imgArray.count-1{
//                    self.uploadImgData(image: self.imgsVm.imgArray[index+1], index: index+1)
//                }else{
//                    self.sendSuggestionRequest()
//                }
//            }else{
//                MCToast.mc_text("图片上传失败")
//            }
//        }
    }
}

extension ServiceVC{
    func initUI() {
        initNavi(titleStr: "联系我们")
        view.backgroundColor = .white
        
        view.addSubview(text)
        view.addSubview(imgsVm)
        view.addSubview(submitButton)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ServiceVC: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        self.presentedViewController?.dismiss(animated: true)
        self.imgsVm.setImgs(results: results)
    }
}


extension ServiceVC{
    func sendSuggestionRequest() {
        let param = ["suggestion":"\(text.textView.text ?? "")",
                     "images":imgUlrs] as [String : Any]
        WHNetworkUtil.shareManager().POST(urlString: URL_Uer_sugestion, parameters: param as [String:AnyObject]) { responseObject in
            self.presentAlertVc(confirmBtn: "确定", message: "Elavatine已收到您的讯息，客服将尽快处理哦~", title: "", cancelBtn: nil, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }, viewController: self)
        }
    }
    func sendSuggestionImgsRequest() {
        let param = ["images":imgUlrs] as [String : Any]
        WHNetworkUtil.shareManager().POST(urlString: URL_Uer_sugestion, parameters: param as [String:AnyObject]) { responseObject in
//            self.presentAlertVc(confirmBtn: "确定", message: "Elavatine已收到您的讯息，客服将尽快处理哦~", title: "", cancelBtn: nil, handler: { action in
//                self.navigationController?.popViewController(animated: true)
//            }, viewController: self)
        }
    }
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
    func sendMsgListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Service_Msg_List, parameters: nil) { responseObject in
            DLLog(message: "\(responseObject)")
        }
    }
}
