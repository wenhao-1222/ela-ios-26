//
//  MealsCreatePhotoVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/24.
//

import Foundation
import UIKit
import MCToast

class MealsCreatePhotoVM: UIView {
    
    var selfHeight = kFitWidth(152) + statusBarHeight + 44
    var controller = WHBaseViewVC()
    
    var imgUrlString = ""
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = WHColorWithAlpha(colorStr: "001833", alpha: 0.85)//.white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.setImgLocal(imgName: "meals_top_bg")
        img.isUserInteractionEnabled = true
        img.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(takePickture))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var cameraButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "meals_create_camera"), for: .normal)
        btn.setTitle("添加照片", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        
        btn.addTarget(self, action: #selector(takePickture), for: .touchUpInside)
        
        return btn
    }()
}

extension MealsCreatePhotoVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(cameraButton)
        
        setConstrait()
        cameraButton.imagePosition(style: .top, spacing: kFitWidth(4))
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        cameraButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT)
            make.height.equalTo(kFitWidth(152))
            make.bottom.equalToSuperview()
        }
    }
    func updateUI(dict:NSDictionary) {
        if dict.stringValueForKey(key: "image").count > 0{
            self.bgImgView.setImgUrl(urlString: dict.stringValueForKey(key: "image"))
            self.cameraButton.isHidden = true
            self.imgUrlString = dict.stringValueForKey(key: "image")
        }
    }
}

extension MealsCreatePhotoVM:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @objc func takePickture(){
        let alertController=UIAlertController(title: "请选择照片来源", message: nil, preferredStyle: .actionSheet)
        // MARK: - iPad 专属配置
        if let popover = alertController.popoverPresentationController {
            // 锚点设置为触发按钮
            popover.sourceView = self.cameraButton
            // 允许箭头方向（可选）
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
                self.controller.present(cameraPicker, animated: true, completion: nil)
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
                self.controller.present(cameraPicker, animated: true, completion: nil)
            } else {
                print("不支持拍照")
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
//        let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage)!

        let img = self.controller.fixOrientation(image)
        
//        let imageData = img.pngData()
        let imageData = WH_DESUtils.compressImage(toData: image)
        DSImageUploader().uploadImage(imageData: imageData!, imgType: .meals) { text, value in
            DLLog(message: "\(text)")
            DLLog(message: "\(value)")
            MCToast.mc_remove()
            if value == true{
                DLLog(message: "\(text)")
                self.bgImgView.setImgUrl(urlString: "\(text)")
                self.imgUrlString = "\(text)"
                self.cameraButton.isHidden = true
            }else{
                MCToast.mc_text("图片上传失败")
            }
        }
    }
}
