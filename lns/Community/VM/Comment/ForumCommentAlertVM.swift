//
//  ForumCommentAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/11.
//


import Foundation
import MCToast

class ForumCommentAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    
    var model = ForumCommentModel()
    var reModel = ForumCommentReplyModel()
    
    var maxLength = 400
    var contentWhiteHeight = kFitWidth(120) + kFitWidth(16)
    
    var commonImgUrl = ""
    
    var commonBlock:(()->())?
    var inputBlock:(()->())?
    
    var brower = HeroBrowser()//HeroBrowser(viewModules: list, index: 0, heroImageView: self.commomImageView)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.35)
        self.isUserInteractionEnabled = true
//        self.alpha = 1.0
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: contentWhiteHeight))
//        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-contentWhiteHeight, width: SCREEN_WIDHT, height: contentWhiteHeight))
        //SCREEN_HEIGHT-(self.contentWhiteHeight - kFitWidth(32))*0.5
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var textView : UITextView = {
        let text = UITextView()
        text.font = .systemFont(ofSize: 16, weight: .regular)
        text.textColor = .COLOR_GRAY_BLACK_85
        text.backgroundColor = .clear
        text.delegate = self
//        text.returnKeyType = .next
        text.textContentType = nil
        
        // 创建一个自定义的按钮用作return按钮
//        let doneButton = UIButton(type: .system)
//        doneButton.setTitle("换行", for: .normal)
//        doneButton.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
////        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
//        
//        text.inputAccessoryView = doneButton
        
        return text
    }()
    
    lazy var placeholderLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.text = "说点什么"
        return lab
    }()
    lazy var limitCountLabel: UILabel = {
        let lab = UILabel()
        lab.isHidden = true
        return lab
    }()
    lazy var imgIconImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_commom_img_icon")
        img.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(takePicktureAction))
        img.addGestureRecognizer(tap)
        return img
    }()
    lazy var commomImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        img.isHidden = true
        img.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(takePicktureAction))
        img.addGestureRecognizer(tap)
        return img
    }()
    lazy var imgCloseIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_commom_img_close_icon")
        img.isHidden = true
        
        img.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(clearImgAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("发送", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(18)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
}

extension ForumCommentAlertVM:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @objc func clearImgAction() {
        self.showImgView(isShow: false)
    }
    @objc func takePicktureAction(){
        if self.commonImgUrl.count > 0 {
            if let img = self.commomImageView.image{
                var list: [HeroBrowserViewModule] = []
                list.append(HeroBrowserLocalImageViewModule(image: img))
                brower = HeroBrowser(viewModules: list, index: 0, heroImageView: self.commomImageView)
                brower.heroBrowserDidLongPressHandle = {(browser,vm)in
//                    self.longPressHandle(vm: vm)
//                    self.takePicture()
                }
                brower.show(with: self.controller, animationType: .hero)
            }
        }else{
            if UserInfoModel.shared.ossAccessKeyId.count > 0 {
                self.takePicture()
            }else{
                self.sendOssStsRequest()
            }
        }
    }
    func takePicture() {
        let alertController=UIAlertController(title: "请选择照片来源", message: nil, preferredStyle: .actionSheet)
        if let popover = alertController.popoverPresentationController {
            // 锚点设置为触发按钮
            popover.sourceView = self.commomImageView
            popover.permittedArrowDirections = [.down]
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { action in
            self.textView.becomeFirstResponder()
        }
        
        let takingPictures=UIAlertAction(title:"拍照", style: .default){ action in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let  cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
//                cameraPicker.allowsEditing = true
                cameraPicker.sourceType = .camera
                //在需要的地方present出来
                self.controller.present(cameraPicker, animated: true, completion: nil)
            } else {
                print("不支持拍照")
            }
        }
        let photoPictures=UIAlertAction(title:"相册", style: .default){ action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let  cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
//                cameraPicker.allowsEditing = true
                cameraPicker.sourceType = .photoLibrary
                //在需要的地方present出来
                self.controller.present(cameraPicker, animated: true, completion: nil)
            } else {
                print("无相册权限")
            }
        }
        
        alertController.addAction(cancel)
        alertController.addAction(takingPictures)
        alertController.addAction(photoPictures)
        
        self.controller.present(alertController, animated:true, completion:nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("获得照片============= \(info)")
        self.controller.dismiss(animated: true, completion: nil)
        MCToast.mc_loading()
        let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let img = self.controller.fixOrientation(image)
        
        let imageData = WH_DESUtils.compressImage(toData: img)
//        self.showView()
        self.textView.becomeFirstResponder()
        DSImageUploader().uploadImage(imageData: imageData!, imgType: .common) { text, value in
            DLLog(message: "\(text)")
            DLLog(message: "\(value)")
            MCToast.mc_remove()
            if value == true{
                DLLog(message: "\(text)")
                
                self.commonImgUrl = "\(text)"
                self.commomImageView.setImgUrl(urlString: self.commonImgUrl)
                self.showImgView(isShow: true)
            }else{
                MCToast.mc_text("图片上传失败")
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.controller.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.textView.becomeFirstResponder()
        })
    }
    
    func longPressHandle(vm: HeroBrowserViewModuleBaseProtocol) {
//        PHPhotoLibrary.requestAuthorization { (status) in
//            if status == PHAuthorizationStatus.authorized || status == PHAuthorizationStatus.notDetermined {
                //保存图片 actionSheet 使用我另一个库 JFPopup 实现，有兴趣欢迎star.
                JFPopupView.popup.actionSheet {
                    [
                        JFPopupAction(with: "拍照", subTitle: nil) {
                            
                            if UIImagePickerController.isSourceTypeAvailable(.camera){
                                self.controller.dismiss(animated: true) {
                                    let  cameraPicker = UIImagePickerController()
                                    cameraPicker.delegate = self
                    //                cameraPicker.allowsEditing = true
                                    cameraPicker.sourceType = .camera
                                    //在需要的地方present出来
                                    self.controller.present(cameraPicker, animated: true, completion: nil)
                                }
                            } else {
                                JFPopupView.popup.toast(hit: "无拍照权限!")
                            }
                        },
                        JFPopupAction(with: "相册", subTitle: nil, clickActionCallBack: {
                            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                                self.controller.dismiss(animated: true) {
                                    let  cameraPicker = UIImagePickerController()
                                    cameraPicker.delegate = self
                    //                cameraPicker.allowsEditing = true
                                    cameraPicker.sourceType = .photoLibrary
                                    //在需要的地方present出来
                                    self.controller.present(cameraPicker, animated: true, completion: nil)
                                }
                            } else {
                                JFPopupView.popup.toast(hit: "无相册权限!")
                            }
                        }),
                    ]
                }
//            }else{
//                //去设置
//                self.openSystemSettingPhotoLibrary()
//            }
//        }
    }
}

extension ForumCommentAlertVM {
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(bgView)
        bgView.addSubview(textView)
        bgView.addSubview(placeholderLabel)
        bgView.addSubview(limitCountLabel)
        whiteView.addSubview(imgIconImageView)
        whiteView.addSubview(commomImageView)
        whiteView.addSubview(imgCloseIcon)
        whiteView.addSubview(confirmButton)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
//            make.centerY.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(275))
            make.height.equalTo(kFitWidth(48))
        }
        textView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.height.equalToSuperview()
        }
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(textView).offset(kFitWidth(4))
            make.top.equalTo(textView).offset(kFitWidth(8))
            make.right.equalTo(kFitWidth(-28))
        }
        limitCountLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(171))
        }
        imgIconImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(bgView.snp.bottom).offset(kFitWidth(18))
            make.width.height.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualTo(confirmButton)
        }
        commomImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualTo(confirmButton)
            make.width.height.equalTo(kFitWidth(42))
        }
        imgCloseIcon.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(commomImageView.snp.right)
            make.centerY.lessThanOrEqualTo(commomImageView.snp.top)
            make.width.height.equalTo(kFitWidth(16))
        }
        confirmButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
//            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(36))
            make.width.equalTo(kFitWidth(72))
            make.top.equalTo(bgView.snp.bottom).offset(kFitWidth(12))
        }
    }
    
    func updateCountLabel(num:String) {
        let numAttr = NSMutableAttributedString(string: "\(num)")
        let totalAttr = NSMutableAttributedString(string: "/\(maxLength)")
        
        numAttr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        numAttr.yy_color = .COLOR_GRAY_BLACK_85
        totalAttr.yy_font = .systemFont(ofSize: 12, weight: .regular)
        totalAttr.yy_color = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        numAttr.append(totalAttr)
        limitCountLabel.attributedText = numAttr
        
        self.placeholderLabel.isHidden = (num == "0" ? false : true)
    }
}

extension ForumCommentAlertVM{
    @objc func showView() {
        self.isHidden = false
        self.whiteView.alpha = 1
//        self.alpha = 1
        
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        //是回复别人的评论
        if self.model.id.count > 0 {
            placeholderLabel.text = "@\(self.model.nickName)"
        }else if self.reModel.id.count > 0 {
            placeholderLabel.text = "@\(self.reModel.nickName)"
        }else{
            placeholderLabel.text = "说点什么"
        }
        
        self.textView.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//            self.alpha = 1
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.35)
        }
    }
    @objc func hiddenView() {
        self.textView.resignFirstResponder()
        
        if self.inputBlock != nil{
            self.inputBlock!()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//            self.alpha = 0.3
            self.whiteView.alpha = 0
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        }completion: { t in
            self.isHidden = true
        }
    }
    func clearMSg() {
        self.textView.text = ""
        self.commonImgUrl = ""
        self.placeholderLabel.isHidden = false
        self.showImgView(isShow: false)
    }
    @objc func nothingToDo() {
        
    }
    @objc func confirmAction(){
        var name = self.textView.text ?? ""
        name = name.replacingOccurrences(of: " ", with: "")
        
        if name.count == 0 && commonImgUrl == ""{
            MCToast.mc_text("请输入评论内容!",offset: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()+kFitWidth(10))
            return
        }
        
        if self.commonBlock != nil{
            self.commonBlock!()
        }
        
        self.hiddenView()
    }
    func showImgView(isShow:Bool) {
        if isShow{
            self.imgIconImageView.isHidden = true
            self.commomImageView.isHidden = false
            self.imgCloseIcon.isHidden = false
        }else{
            self.imgIconImageView.isHidden = false
            self.commomImageView.isHidden = true
            self.imgCloseIcon.isHidden = true
            self.commonImgUrl = ""
        }
    }
}

extension ForumCommentAlertVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-(self.contentWhiteHeight - kFitWidth(32))*0.5)
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-(self.contentWhiteHeight - kFitWidth(32))*0.5)
        }completion: { t in
//            self.hiddenView()
        }
    }
}

extension ForumCommentAlertVM : UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > maxLength {
            // 获得已输出字数与正输入字母数
            let selectRange = textView.markedTextRange
            
            // 获取高亮部分 － 如果有联想词则解包成功
            if let selectRange = selectRange {
                let position =  textView.position(from: (selectRange.start), offset: 0)
                if (position != nil) {
                    return
                }
            }
            
            let textContent = textView.text ?? ""
            let textNum = textContent.count
            
            // 截取
            if textNum > maxLength && maxLength > 0 {
                textView.text = string_prefix(index: maxLength, text: textContent)
            }
        }
//        self.limitCountLabel.text =  "\(textView.text.count)/\(limitCount)"
        updateCountLabel(num: "\(textView.text.count)")
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        self.placeholderLabel.isHidden = true
        return true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
//        if self.inputBlock != nil{
//            self.inputBlock!(textView.text ?? "")
//        }
    }

//    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//            return true
//        }
        
//        if text.isNineKeyBoard() {
//            return true
//        }else{
//            if text.hasEmoji() || text.containsEmoji() {
//                return false
//            }
//        }

//        if textView.textInputMode?.primaryLanguage == "emoji" || !((textView.textInputMode?.primaryLanguage) != nil){
//            return false
//        }
//        return true
//    }
    
    // 字符串的截取 从头截取到指定index
    private func string_prefix(index:Int,text:String) -> String {
        if text.count <= index {
            return text
        } else {
            let index = text.index(text.startIndex, offsetBy: index)
            let str = text.prefix(upTo: index)
            return String(str)
        }
    }
}

extension ForumCommentAlertVM{
    func sendOssStsRequest() {
        MCToast.mc_loading()
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts,vc: self.controller) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? ""))
            self.takePicture()
        }
    }
}
