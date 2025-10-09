//
//  DataAddImageVM.swift
//  lns
//
//  Created by Elavatine on 2024/9/28.
//


import UIKit
import MCToast

class DataAddImageVM: UIView {
    
    let selfHeight = kFitWidth(112)
    var cTime = ""
    var controller = WHBaseViewVC()
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var imgTapBlock:(()->())?
    var clearImgBlock:(()->())?
    
    var imgTapIndex = -1
    
    var imgUrlOne = ""
    var imgUrlTwo = ""
    var imgUrlThree = ""
    
    var imagesPath:[String] = [String]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var leftTitleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.text = "照片"
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var firstImgVm: DataAddImageItemVM = {
        let vm = DataAddImageItemVM.init(frame: CGRect(x: SCREEN_WIDHT-DataAddImageItemVM().selfWidth*3 - kFitWidth(16) - kFitWidth(8)*2, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "角度一"
        vm.imgTapBlock = {()in
            self.imgTapIndex = 1
//            self.takePickture()
            if self.imgUrlOne.count > 0 {
                self.previewImage(imgUrl: self.imgUrlOne, imageView: vm.imageView)
            }else{
                self.takePickture()
            }
        }
        vm.clearImgBlock = {()in
            self.imgUrlOne = ""
            self.imgChangeAction()
        }
        return vm
    }()
    lazy var secondImgVm: DataAddImageItemVM = {
        let vm = DataAddImageItemVM.init(frame: CGRect(x: self.firstImgVm.frame.maxX + kFitWidth(8), y: 0, width: 0, height: 0))
        vm.titleLabel.text = "角度二"
        vm.imgTapBlock = {()in
            self.imgTapIndex = 2
//            self.takePickture()
            if self.imgUrlTwo.count > 0 {
                self.previewImage(imgUrl: self.imgUrlTwo, imageView: vm.imageView)
            }else{
                self.takePickture()
            }
        }
        vm.clearImgBlock = {()in
            self.imgUrlTwo = ""
            self.imgChangeAction()
        }
        return vm
    }()
    lazy var thirdImgVm: DataAddImageItemVM = {
        let vm = DataAddImageItemVM.init(frame: CGRect(x: self.secondImgVm.frame.maxX + kFitWidth(8), y: 0, width: 0, height: 0))
        vm.titleLabel.text = "角度三"
        vm.imgTapBlock = {()in
            self.imgTapIndex = 3
//            self.takePickture()
            if self.imgUrlThree.count > 0 {
                self.previewImage(imgUrl: self.imgUrlThree, imageView: vm.imageView)
            }else{
                self.takePickture()
            }
        }
        vm.clearImgBlock = {()in
            self.imgUrlThree = ""
            self.imgChangeAction()
        }
        return vm
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
}

extension DataAddImageVM{
    func imgChangeAction() {
        if self.imgTapBlock != nil{
            self.imgTapBlock!()
        }
    }
    func updateUIForUpdate(images:String) {
        let imgArr = WHUtils.getArrayFromJSONString(jsonString: images)
        
        for i in 0..<imgArr.count{
            let dict = imgArr[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "sn") == "1"{
                self.firstImgVm.updateUI(imgUrl: "\(dict.stringValueForKey(key: "url"))")
                self.imgUrlOne = "\(dict.stringValueForKey(key: "url"))"
            }else if dict.stringValueForKey(key: "sn") == "2"{
                self.secondImgVm.updateUI(imgUrl: "\(dict.stringValueForKey(key: "url"))")
                self.imgUrlTwo = "\(dict.stringValueForKey(key: "url"))"
            }else if dict.stringValueForKey(key: "sn") == "3"{
                self.thirdImgVm.updateUI(imgUrl: "\(dict.stringValueForKey(key: "url"))")
                self.imgUrlThree = "\(dict.stringValueForKey(key: "url"))"
            }
        }
        
//        if imgArr.count > 0 {
//            let dict = imgArr[0]as? NSDictionary ?? [:]
//            self.firstImgVm.updateUI(imgUrl: "\(dict.stringValueForKey(key: "url"))")
//            self.imgUrlOne = "\(dict.stringValueForKey(key: "url"))"
//        }
//        if imgArr.count > 1 {
//            let dict = imgArr[1]as? NSDictionary ?? [:]
//            self.secondImgVm.updateUI(imgUrl: "\(dict.stringValueForKey(key: "url"))")
//            self.imgUrlTwo = "\(dict.stringValueForKey(key: "url"))"
//        }
//        if imgArr.count > 2 {
//            let dict = imgArr[2]as? NSDictionary ?? [:]
//            self.thirdImgVm.updateUI(imgUrl: "\(dict.stringValueForKey(key: "url"))")
//            self.imgUrlThree = "\(dict.stringValueForKey(key: "url"))"
//        }
    }
    func previewImage(imgUrl: String, imageView: UIImageView) {
        var list: [HeroBrowserViewModule] = []
        if imgUrl.hasPrefix("http") {
            list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: imgUrl, originImgUrl: imgUrl))
        } else {
            let fileUrl = documentsUrl.appendingPathComponent(imgUrl)
            if let data = try? Data(contentsOf: fileUrl) {
                list.append(HeroBrowserDataImageViewModule(data: data))
            } else if let img = imageView.image {
                list.append(HeroBrowserLocalImageViewModule(image: img))
            }
        }
        let brower = HeroBrowser(viewModules: list, index: 0, heroImageView: imageView)
        brower.show(with: self.controller, animationType: .hero)
    }
}

extension DataAddImageVM{
    func initUI() {
        addSubview(leftTitleLabel)
        addSubview(firstImgVm)
        addSubview(secondImgVm)
        addSubview(thirdImgVm)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(0.5))
            make.bottom.equalToSuperview()
        }
    }
}


extension DataAddImageVM:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @objc func takePickture(){
        let alertController=UIAlertController(title: "请选择照片来源", message: nil, preferredStyle: .actionSheet)
        
        // MARK: - iPad 专属配置
        if let popover = alertController.popoverPresentationController {
            // 锚点设置为触发按钮
//            var bounds = CGRect(
//                x: self.bounds.midX,
//                y: self.bounds.midY,
//                width: 0,
//                height: 0
//            )
            if self.imgTapIndex == 1{
                popover.sourceView = self.firstImgVm
//                popover.bounds = self.firstImgVm.bounds
            }else if self.imgTapIndex == 2{
                popover.sourceView = self.secondImgVm
//                popover.bounds = self.secondImgVm.bounds
            }else{
                popover.sourceView = self.thirdImgVm
//                popover.bounds = self.thirdImgVm.bounds
            }
            
//            popover.sourceRect = bounds
            // 允许箭头方向（可选）
            popover.permittedArrowDirections = [.up,.down]
        }
        
        let cancel=UIAlertAction(title:"取消", style: .cancel, handler: nil)
        
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
//        MCToast.mc_loading()
        let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let img = self.controller.fixOrientation(image)
        
//        self.saveImgToLocal(img: img, index: self.imgTapIndex-1)
//        if self.imgTapIndex == 1{
//            self.firstImgVm.updateUI(localImg: img)
//        }else if self.imgTapIndex == 2{
//            self.secondImgVm.updateUI(localImg: img)
//        }else if self.imgTapIndex == 3{
//            self.thirdImgVm.updateUI(localImg: img)
//        }
//        self.imgChangeAction()

        let imageData = WH_DESUtils.compressImage(toData: img)
        DSImageUploader().uploadImage(imageData: imageData!, imgType: .bodyData) { text, value in
            DLLog(message: "\(text)")
            DLLog(message: "\(value)")
            MCToast.mc_remove()
            if value == true{
                DLLog(message: "\(text)")
                if self.imgTapIndex == 1{
                    self.firstImgVm.updateUI(imgUrl: "\(text)")
                    self.imgUrlOne = "\(text)"
                }else if self.imgTapIndex == 2{
                    self.secondImgVm.updateUI(imgUrl: "\(text)")
                    self.imgUrlTwo = "\(text)"
                }else if self.imgTapIndex == 3{
                    self.thirdImgVm.updateUI(imgUrl: "\(text)")
                    self.imgUrlThree = "\(text)"
                }
                self.imgChangeAction()
            }else{
                MCToast.mc_text("图片上传失败")
            }
        }
    }
}

extension DataAddImageVM{
    func saveImgToLocal(img:UIImage,index:Int) {
        let localImgs = NSMutableArray(array: BodyDataSQLiteManager.shared.queryLocalImgs(sDate: self.cTime))
        BodyDataUploadManager().removeFile(filePath: localImgs[index] as? String ?? "") { t in
            if let data = img.pngData() {
                do{
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileName = "\(UserInfoModel.shared.phone)_\(self.cTime)_body_\(index).png"
                    let filePath = documentsPath.appendingPathComponent(fileName)
                    try data.write(to: filePath)
                    localImgs.replaceObject(at: index, with: ["sn":"\(self.imgTapIndex)","localUrl":fileName])
                    
                    if self.imgTapIndex == 1 {
                        self.imgUrlOne = fileName
                    }else if self.imgTapIndex == 2 {
                        self.imgUrlTwo = fileName
                    }else if self.imgTapIndex == 3 {
                        self.imgUrlThree = fileName
                    }
                    
                    BodyDataSQLiteManager.shared.updateLocalImgData(localImgString: WHUtils.getJSONStringFromArray(array: localImgs), cTime: self.cTime)
//                    BodyDataSQLiteManager.shared.updateSingleData(columnName: "images_local_paths", data: WHUtils.getJSONStringFromArray(array: localImgs), cTime: self.cTime)
                }catch{
                    DLLog(message:"file write Error :\(error)")
                }
            }
        }
    }
    func saveForumContentImages(imgs:[UIImage]) {
        let dict = ForumPublishSqlite.getInstance().queryContentImgsPath()
        let imagesPaths = dict.stringValueForKey(key: "images")
        if imagesPaths.count > 6 {
            let imagesFilePath = WHUtils.getArrayFromJSONString(jsonString: imagesPaths)
            for i in 0..<imagesFilePath.count{
                let filePath = imagesFilePath[i]as? String ?? ""
                let oldFilePath = documentsUrl.appendingPathComponent(filePath).path
                self.removeFile(filePath: oldFilePath) { t in
                    
                }
            }
        }
        self.saveImageToLocal(imgs: imgs, imgType: "body",index: 0)
    }
    
    func saveImageToLocal(imgs:[UIImage],imgType:String,index:Int?=0) {
        if index ?? 0 == 0 {
            imagesPath.removeAll()
        }
        DLLog(message: "saveImageToLocal: \(index ?? 0)")
        if imgs.count > index ?? 0{
            if let data = imgs[index ?? 0].pngData() {
                do{
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileName = "\(UserInfoModel.shared.phone)_\(self.cTime)_\(imgType)_\(index ?? 0).png"
                    let filePath = documentsPath.appendingPathComponent(fileName)
                    try data.write(to: filePath)
                    
                    imagesPath.append(fileName)
                }catch{
                    DLLog(message:"file write Error :\(error)")
                }
            }
            self.saveImageToLocal(imgs: imgs, imgType: imgType,index: (index ?? 0)+1)
        }else{
            DLLog(message: "saveImageToLocal:  success!")
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "images", data: WHUtils.getJSONStringFromArray(array: imagesPath as NSArray))
        }
    }
    ///删除本地文件
    func removeFile(filePath:String,completion: @escaping (Bool?) -> Void) {
        if filePath.count < 3 || filePath == documentsUrl.path{
            completion(false)
            return
        }
        let fileRouteArray = filePath.components(separatedBy: "Documents/")
        if fileRouteArray.last == "" || fileRouteArray.count <= 1{
            completion(false)
            return
        }
        
        DLLog(message: "removeFile -- filePath:\(filePath)")
        if FileManager.default.fileExists(atPath: filePath){
            do{
                try FileManager.default.removeItem(atPath: filePath)
            }catch{
                DLLog(message: "MRVueUpdateLog: Remove [\(filePath)] fail:[\(error)]")
                completion(false)
                return
            }
            completion(true)
            return
        }else{
            completion(true)
        }
    }
}
