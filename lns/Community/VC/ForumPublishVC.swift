//
//  ForumPublishVC.swift
//  lns
//
//  Created by Elavatine on 2024/12/5.
//

import Photos
import MCToast

typealias ImgUploadFailCallback = (_ value:Bool) -> Void

class ForumPublishVC: WHBaseViewVC {
    var photoAssets:[PHAsset] = [PHAsset]()
    var photoUrls = NSMutableArray()
    var saveAssetIds:[String] = [String]()
    
    var isPoll = false//是否为投票贴
    var forumTitle = ""
    var forumContent = ""
    var pollTitle = ""
    var pollHasImage = false//投票选项是否带图
    var choiceNum = 1
    var pollDataArray:[ForumPollModel] = [ForumPollModel]()
    var imagesForUpload:[UIImage] = [UIImage]()
    var videoAsset : AVAsset?
    var videoUrl : URL?
    var videoCoverImage : UIImage?
    var videoRect = CGRect()
    var videoUrlString = ""//上传给后台的，从OSS获取的路径
    var contentType = SELECT_ALBUM_TYPE.IMAGE
    
    var group = DispatchGroup()
    // 创建 PHCachingImageManager 实例
    let imageManager = PHCachingImageManager.default()
    let option = PHImageRequestOptions.init()
    let optionVideo = PHVideoRequestOptions()
    let videoEditVc = VideoEditVC()
    
    override func viewWillAppear(_ animated: Bool) {
        UserConfigModel.shared.selectType = contentType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendOssStsRequest()
        UserConfigModel.shared.selectType = .IMAGE
        UserConfigModel.shared.photsSelectCount = 0
        
        initUI()
        
        option.resizeMode = .exact
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
        
        optionVideo.version = .current
        optionVideo.deliveryMode = .automatic
        
        self.videoEditVc.cropDoneBlock = {(image)in
            self.videoCoverImage = image
            VideoEditModel.shared.videoCoverImage = image
//            ForumPublishManager.shared.saveVideoCoverImg(image: image)
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PublishVideoCell
            cell?.updateVideo(img: image)
            
        }
    }
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()-kFitWidth(66)-getBottomSafeAreaHeight()), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .white//WHColor_16(colorStr: "FAFAFA")
        vi.register(PublishVideoCell.classForCoder(), forCellReuseIdentifier: "PublishVideoCell")
        vi.register(PublishImagesCellCollection.classForCoder(), forCellReuseIdentifier: "PublishImagesCellCollection")
        vi.register(PublishTitleCell.classForCoder(), forCellReuseIdentifier: "PublishTitleCell")
        vi.register(PublishContentCell.classForCoder(), forCellReuseIdentifier: "PublishContentCell")
        vi.register(PublishImagesCell.classForCoder(), forCellReuseIdentifier: "PublishImagesCell")
        vi.register(PublishWidgetCell.classForCoder(), forCellReuseIdentifier: "PublishWidgetCell")
        vi.register(PublishPollItemCell.classForCoder(), forCellReuseIdentifier: "PublishPollItemCell")
//        vi.register(PublishPollSettingCell.classForCoder(), forCellReuseIdentifier: "PublishPollSettingCell")
//        vi.register(PublishPollItemCell.classForCoder(), forCellReuseIdentifier: "PublishPollItemCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        return vi
    }()
    lazy var footView: PublishPollVM = {
        let vm = PublishPollVM.init(frame: .zero)
        vm.heightChangeBlock = {()in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        return vm
    }()
    lazy var saveButton : UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: kFitWidth(20), y: SCREEN_HEIGHT - getBottomSafeAreaHeight() - kFitWidth(55), width: kFitWidth(335), height: kFitWidth(44)))
        btn.setTitle("发布帖子", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
//        btn.isEnabled = false
        btn.backgroundColor = .THEME
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(publishAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var previewButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("预览", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .white), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .WIDGET_COLOR_GRAY_BLACK_06), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.layer.borderColor = UIColor.THEME.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        
        btn.addTarget(self, action: #selector(previewTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension ForumPublishVC:RITLPhotosViewControllerDelegate{
    func photosViewController(_ viewController: UIViewController, assetIdentifiers identifiers: [String]) {
        self.saveAssetIds = identifiers
    }
//    func photosViewController(_ viewController: UIViewController, thumbnailImages: [UIImage], infos: [[AnyHashable : Any]]) {
////        self.photoAssets = thumbnailImages
//    }
    func photosViewController(_ viewController: UIViewController, assets: [PHAsset]) {
        self.photoAssets = assets
        self.imagesForUpload.removeAll()
        UserConfigModel.shared.photsSelectCount = self.photoAssets.count
        if self.photoAssets.count > 0 {
            let firstAsset = self.photoAssets.first
            
            DLLog(message: "isVideo:\(firstAsset?.mediaType == .video)")
            UserConfigModel.shared.selectType = firstAsset?.mediaType == .video ? .VIDEO : .IMAGE
            self.contentType = firstAsset?.mediaType == .video ? .VIDEO : .IMAGE
            if UserConfigModel.shared.selectType == .VIDEO{
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PublishImagesCellCollection
                cell?.updateImages(imgs: [])
            }
        }
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        self.tableView.endUpdates()
        DLLog(message: "VideoCompress: photosViewController")
        if UserConfigModel.shared.selectType == .VIDEO{
            if self.photoAssets.count > 0 {
                self.dealVideoAsset(asset: self.photoAssets[0],retry: 0) {videoUrl in
                    if let url = videoUrl{
                        DLLog(message: "\(url)")
                        self.videoUrl = url
                        self.contentType = .VIDEO
                        
                        DLLog(message: "fetchFramesFromVideo:(keyFrames)--- startTime \(Date().currentSeconds)")
                        VideoUtils().getKeyFrameFromUrl(videoUrl: self.videoUrl) { imgArray in
                            DLLog(message: "fetchFramesFromVideo:(keyFrames)--- endTime \(Date().currentSeconds)")
                            DLLog(message: "fetchFramesFromVideo:(keyFrames)---\(VideoEditModel.shared.keyFrames.count)")
                        }
//                        DLLog(message: "fetchFramesFromVideo:(allFrames)--- startTime \(Date().currentSeconds)")
//                        VideoUtils().fetchFramesFromVideo(url: self.videoUrl!) { imgArray in
//                            DLLog(message: "fetchFramesFromVideo:(allFrames)--- endTime \(Date().currentSeconds)")
//                            DLLog(message: "fetchFramesFromVideo:(allFrames)---\(VideoEditModel.shared.allFrames.count)")
//                        }
                        DispatchQueue.main.async {
                            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PublishVideoCell
                            cell?.updateVideo(assetUrl: url)
                        }
                    }else{
                        UserConfigModel.shared.selectType = .IMAGE
                        self.contentType = .IMAGE
                        UserConfigModel.shared.photsSelectCount = 0
                        DLLog(message: "获取视频URL 失败 ")
                    }
                }
            }
        }else{
            if self.imagesForUpload.count == 0{
                self.dealChoiceImg(index:0)
            }else{
                self.dealChoiceImg(index:self.imagesForUpload.count)
            }
        }
    }
}
extension ForumPublishVC{
    func addImgAction() {
        self.view.becomeFirstResponder()
        self.videoUrl = nil
        self.videoCoverImage = nil
        VideoEditModel.shared.videoCoverImage = nil
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_origin_url", data: "")
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_compress_progress", data: "")
        ForumPublishManager.shared.saveVideoCoverImg(image: nil)
        self.videoRect = CGRect()
        if photoAssets.count == 1{
            let asstes = photoAssets.first
            if asstes?.mediaType == .video{
                UserConfigModel.shared.selectType = .VIDEO
                contentType = .VIDEO
            }
        }else{
            UserConfigModel.shared.selectType = .IMAGE
            contentType = .IMAGE
        }
        UserConfigModel.shared.photsSelectCount = photoAssets.count
        
        let vc = RITLPhotosViewController()
        vc.configuration.maxCount = UserConfigModel.shared.forumPictureNumMax//(UserConfigModel.shared.forumPictureNumMax-self.photoAssets.count)
        vc.configuration.containVideo = true
        vc.configuration.hiddenGroupWhenNoPhotos = true
        vc.photo_delegate = self
        vc.thumbnailSize = CGSize.init(width: SCREEN_WIDHT*0.7*0.333, height: SCREEN_WIDHT*0.7*0.333)
        vc.defaultIdentifers = self.saveAssetIds
        self.present(vc, animated: true)
    }
    func imgTapAction() {
        self.view.becomeFirstResponder()
        self.videoUrl = nil
        self.videoCoverImage = nil
        VideoEditModel.shared.videoCoverImage = nil
        ForumPublishManager.shared.saveVideoCoverImg(image: nil)
        if photoAssets.count == 1{
            let asstes = photoAssets.first
            if asstes?.mediaType == .video{
                UserConfigModel.shared.selectType = .VIDEO
                contentType = .VIDEO
            }
        }else{
            UserConfigModel.shared.selectType = .IMAGE
            contentType = .IMAGE
        }
        UserConfigModel.shared.photsSelectCount = photoAssets.count
        //开始选择照片，最多允许选择9张
        _ = self.presentHGImagePicker(maxSelected:(UserConfigModel.shared.forumPictureNumMax-self.photoAssets.count)) { (assets) in
            //结果处理
            print("共选择了\(assets.count)张图片，分别如下：")
            for asset in assets {
                DLLog(message: "\(asset)")
                self.photoAssets.append(asset)
            }
            UserConfigModel.shared.photsSelectCount = self.photoAssets.count
            
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            self.tableView.endUpdates()
            if UserConfigModel.shared.selectType == .VIDEO{
                if self.photoAssets.count > 0 {
                    self.dealVideoAsset(asset: self.photoAssets[0],retry: 0) {videoUrl in
                        if let url = videoUrl{
                            DLLog(message: "\(url)")
                            self.videoUrl = url
                            self.contentType = .VIDEO
                            DispatchQueue.main.async {
                                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PublishVideoCell
                                cell?.updateVideo(assetUrl: url)
                            }
                        }else{
                            UserConfigModel.shared.selectType = .IMAGE
                            self.contentType = .IMAGE
                            UserConfigModel.shared.photsSelectCount = 0
                            DLLog(message: "获取视频URL 失败 ")
                        }
                    }
                }
            }else{
                if self.imagesForUpload.count == 0{
                    self.dealChoiceImg(index:0)
                }else{
                    self.dealChoiceImg(index:self.imagesForUpload.count)
                }
            }
        }
    }
    func dealChoiceImg(index:Int) {
        if index < photoAssets.count{
            let asset = photoAssets[index]
            imageManager.requestImage(for: asset, targetSize: CGSize(width: SCREEN_WIDHT*UIScreen.main.scale, height: SCREEN_WIDHT*UIScreen.main.scale), contentMode: .aspectFit, options: option) { image, info in
//                DispatchQueue.main.async {
                    self.imagesForUpload.append(image!)
                self.dealChoiceImg(index: index + 1)
//                }
            }
        }else{
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PublishImagesCellCollection
            cell?.updateImages(imgs: self.imagesForUpload as NSArray)
        }
    }
//    func dealVideoAsset(asset:PHAsset,completion: @escaping (URL?) -> Void) {
//        imageManager.requestAVAsset(forVideo: asset, options: optionVideo) { avAsset, auduoMix, info in
//            guard let avUrlasset = avAsset as? AVURLAsset else{
//                completion(nil)
//                return
//            }
//            self.videoAsset = avUrlasset
////            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_origin_url", data: asset.url.path)
//            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_origin_url", data: asset.localIdentifier)
//            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_compress_progress", data: "")
//            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video", data: "", cTime: ForumPublishManager.shared.cTime)
//            let videoUrl = avUrlasset.url
//            completion(videoUrl)
//        }
//    }
    func dealVideoAsset(asset: PHAsset,
                        retry: Int = 0,
                        completion: @escaping (URL?) -> Void) {

        imageManager.requestAVAsset(forVideo: asset, options: optionVideo) { avAsset, _, _ in
            if let urlAsset = avAsset as? AVURLAsset {
                self.videoAsset = urlAsset
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_origin_url", data: asset.localIdentifier)
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_compress_progress", data: "")
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video", data: "", cTime: ForumPublishManager.shared.cTime)
                let videoUrl = urlAsset.url
                completion(videoUrl)
//                completion(urlAsset.url)                 // ✅ 视频可用
            } else {
                // AirDrop / iCloud 正在写文件：再等等，最多重试 10 次（约 5 秒）
                if retry < 10 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        self.dealVideoAsset(asset: asset,
                                            retry: retry + 1,
                                            completion: completion)
                    }
                } else {
                    DispatchQueue.main.async {
                        MCToast.mc_failure("视频仍在导入中，请稍后再试")
                    }
                    completion(nil)                      // ❌ 放弃，本次不降级
                }
            }
        }
    }
    @objc func publishAction() {
//        ForumPublishManager.shared.saveVideo(asset: self.videoAsset!, named: "videoTestSave\(arc4random()%100)")
//        return
        DLLog(message: "\(UserConfigModel.shared.selectType)")
        DLLog(message: "publishAction selectType:\(UserConfigModel.shared.selectType) videoUrl:\(String(describing: self.videoUrl))     imagesForUpload:\(imagesForUpload.count)")
        if self.isPoll == false{
            if UserConfigModel.shared.selectType == .VIDEO{
                if self.videoUrl == nil{
                    MCToast.mc_text("请选择图片")
                    return
                }
            }else{
                if imagesForUpload.count == 0{
                    MCToast.mc_text("请选择图片")
                    return
                }
            }
        }
        
//        let cellTitle = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PublishTitleCell
//        if (cellTitle?.remarkTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) == ""{
//            MCToast.mc_text("请输入帖子标题")
//            return
//        }

        if forumTitle.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            MCToast.mc_text("请输入帖子标题")
            return
        }
        if UserConfigModel.shared.selectType == .VIDEO{
            guard let _ = self.videoUrl else {
                MCToast.mc_failure("视频尚未准备好，无法发布")
                return
            }
        }
        self.saveDataToSQLite()
//        photoUrls.removeAllObjects()
////        var imgUploadSuccess = true
//        group = DispatchGroup()
//        
//        for _ in imagesForUpload{
//            group.enter()
//        }
//        
//        if self.isPoll && self.pollHasImage{
//            for _ in pollDataArray{
//                group.enter()
//            }
//        }
//        if UserConfigModel.shared.selectType == .VIDEO{
//            MCToast.mc_loading(text: "视频上传中...")
//            group.enter()
//            DSImageUploader().uploadMovie(fileUrl: self.videoUrl!) { percent in
//                
//            } completion: { text, value in
//                DLLog(message: "DSImageUploader().uploadMovie(fileUrl:\(text)")
//                DLLog(message: "DSImageUploader().uploadMovie(fileUrl:\(value)")
//                if value == true{
//                    self.videoUrlString = "\(text)"
//                    self.group.leave()
//                }else{
//                    MCToast.mc_failure("视频上传失败...")
//                    return
//                }
//            }
//        }else {
//            MCToast.mc_loading(text: "图片上传中...")
//            self.uploadImgData(index: 0) { value in
//    //            imgUploadSuccess = false
//            }
//        }
//        
//        if self.isPoll && self.pollHasImage {
//            self.uploadPollImgData(index: 0) { value in
////                imgUploadSuccess = false
//            }
//        }
//        group.notify(queue: .main) {
//            self.sendForumAddRequest()
//        }
    }
    func uploadPollImgData(index:Int,fail:@escaping ImgUploadFailCallback) {
        if pollDataArray.count > index{
            let model = pollDataArray[index]
            let imageData = WH_DESUtils.compressImage(toData: model.image)
            DSImageUploader().uploadImage(imageData: imageData!, imgType: .forum_post) { bytesSent, totalByteSent, totalByteExpectedToSend in
                DLLog(message: "\(bytesSent)   ---   \(totalByteSent)  --- \(totalByteExpectedToSend)")
            } completion: { text, value in
                DLLog(message: "\(text)")
                DLLog(message: "\(value)")
                self.group.leave()
                if value == true{
                    DLLog(message: "\(text)")
                    model.imageUrl = "\(text)"
                    self.pollDataArray[index] = model
                }else{
                    MCToast.mc_text("图片上传失败")
                }
                self.uploadPollImgData(index: index+1,fail: fail)
            }
        }else{
            DLLog(message: "图片上传完毕")
        }
    }
    //上传帖子图片
    func uploadImgData(index:Int,fail:@escaping ImgUploadFailCallback) {
        if imagesForUpload.count > index{
            let imageData = WH_DESUtils.compressImage(toData: imagesForUpload[index])
            DSImageUploader().uploadImage(imageData: imageData!, imgType: .forum_post) { bytesSent, totalByteSent, totalByteExpectedToSend in
                DLLog(message: "\(bytesSent)   ---   \(totalByteSent)  --- \(totalByteExpectedToSend)")
                
            } completion: { text, value in
                DLLog(message: "\(text)")
                DLLog(message: "\(value)")
//                MCToast.mc_remove()
                self.group.leave()
                if value == true{
                    DLLog(message: "\(text)")
                    self.photoUrls.add(["sn":"\(index)",
                                        "ossUrl":"\(text)"])
                }else{
                    MCToast.mc_text("图片上传失败")
                }
                self.uploadImgData(index: index+1,fail: fail)
            }
        }else{
            DLLog(message: "图片上传完毕")
        }
    }
    //点击投票，跳转投票页面，编辑投票选项
    func setPollMsgAction(cell:PublishWidgetCell) {
        let vc = ForumPublishPollVC()
        vc.pollIsMultiple = self.choiceNum > 1 ? true : false
        vc.pollDataArray = self.pollDataArray
        vc.choiceNum = self.choiceNum > 1 ? self.choiceNum : 2
        vc.pollHasImage = self.pollHasImage
        vc.pollTitle = self.pollTitle
        self.navigationController?.pushViewController(vc, animated: true)
        vc.deletePollBlock = {()in
            self.isPoll = false
            self.pollDataArray.removeAll()
            cell.updateStatus(isPoll: self.isPoll)
            self.tableView.reloadData()
        }
        vc.saveBlock = {(array)in
            self.isPoll = true
            self.pollTitle = vc.pollTitle
            cell.updateStatus(isPoll: self.isPoll)
            self.pollDataArray = array
            self.pollHasImage = vc.pollHasImage
            self.choiceNum = vc.pollIsMultiple ? vc.choiceNum : 1
            self.tableView.reloadData()
        }
    }
    @objc func previewTapAction() {
//        let cellTitle = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PublishTitleCell
//        let cellContent = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? PublishContentCell
        
        if forumTitle.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
            forumContent.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
            pollDataArray.count == 0{
            MCToast.mc_text("请先编辑帖子标题")
            return
        }
        MCToast.mc_text("预览生成中...")
//        photoUrls.removeAllObjects()
//        group = DispatchGroup()
        
//        for image in imagesForUpload{
//            group.enter()
//        }
//        self.uploadImgData(index: 0) { value in
//            
//        }
        let previewModel = ForumModel()
        previewModel.title = forumTitle
        previewModel.content = forumContent
        previewModel.headImgUrl = UserInfoModel.shared.headimgurl
        previewModel.createBy = UserInfoModel.shared.nickname
        previewModel.showTime = "刚刚"
        
        let pollConfigModel = ForumDetailPollMsgModel()
        pollConfigModel.pollType = self.choiceNum > 1 ? .multiple : .single
        pollConfigModel.optionThreshold = self.choiceNum
        pollConfigModel.hasImage = self.pollHasImage ? .pass : .refuse
        pollConfigModel.pollArray = self.pollDataArray
        
        previewModel.pollModel = pollConfigModel
        previewModel.type = self.isPoll ? .poll : .common
        
        if UserConfigModel.shared.selectType == .VIDEO{
            previewModel.contentType = .VIDEO
            previewModel.videoUrl = self.videoUrl
            previewModel.coverImg = VideoUtils.getFirstFrameFromVideo(url: self.videoUrl!)
        }else{
            previewModel.contentType = .IMAGE
        }
        
        let vc = ForumPublishPreviewVC()
//        group.notify(queue: .main) {
//            var imgsUrl:[String] = [String]()
//            
//            for i in 0..<self.photoUrls.count{
//                let dict = self.photoUrls[i]as? NSDictionary ?? [:]
//                imgsUrl.append(dict.stringValueForKey(key: "ossUrl"))
//            }
//            previewModel.imgsContent = imgsUrl
            vc.model = previewModel
//            vc.photoAssets = self.photoAssets
        vc.imagesForUpload = self.imagesForUpload
            MCToast.mc_remove()
            self.navigationController?.pushViewController(vc, animated: true)
            
//        }
    }
}

extension ForumPublishVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return pollDataArray.count > 0 ? 2 : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }else{
            return pollDataArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                if UserConfigModel.shared.selectType == .VIDEO{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PublishVideoCell") as? PublishVideoCell
                    cell?.clearImgBlock = {()in
                        UserConfigModel.shared.selectType = .IMAGE
                        self.contentType = .IMAGE
                        UserConfigModel.shared.photsSelectCount = 0
                        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_origin_url", data: "")
                        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_compress_progress", data: "")
                        ForumPublishManager.shared.removeLocalVideo()
                        self.photoAssets.removeAll()
                        self.saveAssetIds.removeAll()
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    }
                    cell?.editCoverBlock = {()in
                        if self.videoEditVc.videoUrl != self.videoUrl{
                            self.videoEditVc.videoRect = self.videoRect
                            self.videoEditVc.videoUrl = self.videoUrl
                            self.videoEditVc.bottomVm.keyFrameVm.initUI()
                        }else{
//                            self.videoEditVc.backArrowButton.isHidden = false
                        }
                        self.navigationController?.pushViewController(self.videoEditVc, animated: true)
                    }
                    cell?.refreshHeightBlock = {(videoRect)in
                        self.videoRect = videoRect
                        self.tableView.beginUpdates()
//                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                        self.tableView.endUpdates()
                    }
                    return cell ?? PublishVideoCell()
                }else{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PublishImagesCellCollection") as? PublishImagesCellCollection
    //                let cell = tableView.dequeueReusableCell(withIdentifier: "PublishImagesCell") as? PublishImagesCell
                    
                    cell?.heightChangeBlock = {()in
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                    cell?.addImgBlock = {()in
//                        self.imgTapAction()
                        self.addImgAction()
                    }
                    cell?.deleteImgBlock = {(index)in
                        if self.photoAssets.count > index{
                            self.photoAssets.remove(at: index)
                            self.imagesForUpload.remove(at: index)
                            self.saveAssetIds.remove(at: index)
        //                    self.imagesForUpload.removeAll()
                            UserConfigModel.shared.photsSelectCount = self.photoAssets.count
                            if self.photoAssets.count == 0 {
                                UserConfigModel.shared.selectType = .IMAGE
                                self.contentType = .IMAGE
                            }
        //                    cell?.updateUI(assts: self.photoAssets)
                            cell?.updateImages(imgs: self.imagesForUpload as NSArray)
                        }
                    }
                    cell?.loadImgBlock = {(image,index)in
    //                    if !self.imagesForUpload.contains(image){
    //                        self.imagesForUpload.append(image)
    //                    }
                    }
                    cell?.changeImgIndexBlock = {(assets,sourceIndex,destinationIndex)in
    //                    self.photoAssets = assets
                        self.imagesForUpload = assets
                        if sourceIndex >= 0{
                            let img = self.photoAssets[sourceIndex]
                            self.photoAssets.remove(at: sourceIndex)
                            self.photoAssets.insert(img, at: destinationIndex)
                        }
                    }
                    cell?.imgTapBlock = {(index)in
                        let showController = ShowBigImgController(imgs: self.imagesForUpload, img: self.imagesForUpload[index],isNavi: true)
//                        showController.modalPresentationStyle = .overFullScreen
                        showController.isDelete = true
//                        self.present(showController, animated: false, completion: nil)
                        self.navigationController?.pushViewController(showController, animated: true)
                        showController.deleteBlock = {(index)in
                            self.photoAssets.remove(at: index)
                            self.imagesForUpload.remove(at: index)
                            self.saveAssetIds.remove(at: index)
                            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PublishImagesCellCollection
    //                        cell?.updateUI(assts: self.photoAssets)
                            cell?.updateImages(imgs: self.imagesForUpload as NSArray)
                            if self.photoAssets.count == 0 {
                                UserConfigModel.shared.selectType = .IMAGE
                                self.contentType = .IMAGE
                            }
                        }
                    }
                    return cell ?? PublishImagesCellCollection()
                }
            }else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PublishTitleCell") as? PublishTitleCell
                cell?.heightChangeBlock = {(remark)in
                    self.forumTitle = remark
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                return cell ?? PublishTitleCell()
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PublishContentCell") as? PublishContentCell
                cell?.heightChangeBlock = {(remark)in
                    self.forumContent = remark
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                return cell ?? PublishContentCell()
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PublishWidgetCell") as? PublishWidgetCell
                cell?.updateStatus(isPoll: self.isPoll,title: self.pollTitle)
                cell?.tapBlock = {()in
                    self.setPollMsgAction(cell: cell!)
                }
                cell?.heightChangeBlock = {(remark)in
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                return cell ?? PublishWidgetCell()
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublishPollItemCell") as? PublishPollItemCell
            let model = pollDataArray[indexPath.row]
            cell?.pollTitleText.isUserInteractionEnabled = false
            cell?.updateUIForPublish(model: model, index: indexPath.row, hasImage: self.pollHasImage)
//            cell?.updateUIForHasImage(hasImage: self.pollHasImage)
            
            cell?.imgTapBlock = {()in
                let showController = ShowBigImgController(imgs: [model.image], img: model.image,isNavi: true)
//                showController.modalPresentationStyle = .overFullScreen
//                showController.isDelete = true
//                self.present(showController, animated: false, completion: nil)
                self.navigationController?.pushViewController(showController, animated: true)
            }
            
            return cell ?? PublishPollItemCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublishWidgetCell") as? PublishWidgetCell
            self.setPollMsgAction(cell: cell!)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.estimatedRowHeight
        }else{
            if self.pollHasImage{
                return kFitWidth(88)
            }else{
                return kFitWidth(56)
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView{//} && self.isLoadMoreComment == false{
            if scrollView.contentOffset.y < 0{
                scrollView.contentOffset.y = 0
            }
        }
//        DLLog(message: "scrollViewBase.contentOffset.y:\(scrollViewBase.contentOffset.y)")
    }
    func dealVideoFrame(img:UIImage) -> CGRect {
        let videoMaxWidth = kFitWidth(343)
        let imgOriginWidth = img.size.width > 0 ? img.size.width : 1
        let imgOriginHeight = img.size.height > 0 ? img.size.height : 1
        
        if imgOriginHeight > imgOriginWidth{
            let imgWidth = imgOriginWidth/imgOriginHeight*videoMaxWidth
            return CGRect.init(x: (SCREEN_WIDHT-imgWidth)*0.5, y: 0, width: imgWidth, height: videoMaxWidth)
        }
        if imgOriginWidth > videoMaxWidth{
            let imgHeight = imgOriginHeight*videoMaxWidth/imgOriginWidth
            return CGRect.init(x: kFitWidth(16), y: 0, width: videoMaxWidth, height: imgHeight)
        }
        
        return CGRect.init(x: (SCREEN_WIDHT-imgOriginWidth)*0.5, y: 0, width: imgOriginWidth, height: imgOriginHeight)
    }
}

extension ForumPublishVC{
    func initUI() {
        initNavi(titleStr: "发帖")
        
        view.addSubview(tableView)
        view.addSubview(previewButton)
        view.addSubview(saveButton)
        
        if #available(iOS 17.4, *) {
            tableView.bouncesVertically = true
        }
        previewButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(88))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(-getBottomSafeAreaHeight()-kFitWidth(6))
        }
        saveButton.snp.makeConstraints { make in
            make.left.equalTo(previewButton.snp.right).offset(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(-getBottomSafeAreaHeight()-kFitWidth(6))
        }
    }
}

extension ForumPublishVC{
    func saveDataToSQLite() {
        if UserConfigModel.shared.selectType == .VIDEO{//视频 + 文
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "content_type", data: "2")
//            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_origin_url", data: self.videoAsset.url.path)
//            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_compress_progress", data: "")
//            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video", data: "", cTime: ForumPublishManager.shared.cTime)
        }else if self.imagesForUpload.count == 0{//纯文字帖子
            if self.isPoll == false{
                MCToast.mc_loading(text: "添加图片后才能发布")
                return
            }
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "content_type", data: "3")
        }else{//图 + 文
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "content_type", data: "1")
        }
//        let cellTitle = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PublishTitleCell
//        let cellContent = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? PublishContentCell
        
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "isUpload", data: "1")
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "title", data: forumTitle.trimmingCharacters(in: .whitespacesAndNewlines))
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "content", data: forumContent.trimmingCharacters(in: .whitespacesAndNewlines))
//        ForumPublishSqlite.getInstance().updateSingleData(columnName: "title", data: (cellTitle?.remarkTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
//        ForumPublishSqlite.getInstance().updateSingleData(columnName: "content", data: (cellContent?.remarkTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "type", data: self.isPoll ? "2" : "1")
//        ForumPublishManager.shared.saveImageToLocal(imgs: imagesForUpload, imgType: "content")
        ForumPublishManager.shared.saveForumContentImages(imgs: imagesForUpload)
        
        if self.isPoll{
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "ispoll", data: "1")
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "poll_type", data: self.choiceNum > 1 ? "2" : "1")
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "poll_has_image", data: self.pollHasImage ? "1" : "0")
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "optionthreshold", data: "\(self.choiceNum)")
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "poll_title", data: "\(self.pollTitle)")
            
            let pollOption = NSMutableArray()
            
            for i in 0..<self.pollDataArray.count{
                let model = self.pollDataArray[i]
                
                if self.pollHasImage{
                    if let imgData = model.image.pngData(){
                        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let imgName = "\(UserInfoModel.shared.phone)_poll_item_\(i).png"
                        let filePath = documentsPath.appendingPathComponent(imgName)
                        try? imgData.write(to: filePath)
                        pollOption.add(["sn":"\(i+1)",
                                        "content":model.title,
                                        "imagePath":imgName])
                    }
                }else{
                    pollOption.add(["sn":"\(i+1)",
                                    "content":model.title])
                }
            }
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "polls", data: "\(WHUtils.getJSONStringFromArray(array: pollOption))")
        }else{
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "ispoll", data: "0")
        }
        self.backTapAction()
    }
    func sendForumAddRequest() {
        let coverDict = photoUrls.firstObject as? NSDictionary ?? [:]
        
        var param = ["type":self.isPoll ? "2" : "1",
                     "title":"\(forumTitle)",
                     "content":"\(forumContent)",
//                     "title":"\(cellTitle?.remarkTextField.text ?? "")",
//                     "content":"\(cellContent?.remarkTextField.text ?? "")",
                     "commentable":"1",
                     "contentType":"1",
                     "cover":[coverDict.stringValueForKey(key: "ossUrl")],
                     "material":["image":self.photoUrls]] as [String : Any]
        
        if UserConfigModel.shared.selectType == .VIDEO{
            param = ["type":self.isPoll ? "2" : "1",
                     "title":"\(forumTitle)",
                     "content":"\(forumContent)",
//                     "title":"\(cellTitle?.remarkTextField.text ?? "")",
//                     "content":"\(cellContent?.remarkTextField.text ?? "")",
                     "commentable":"1",
                     "contentType":"2",
                     "cover":[self.videoUrlString],
                     "material":["video":["sn":"1",
                                          "ossUrl":"\(self.videoUrlString)"],
                                 "image":[]],
                     "coverInfo":["ossUrl":"",
                                  "width":VideoEditModel.shared.videoCoverImageSize?.width ?? 1,
                                  "height":VideoEditModel.shared.videoCoverImageSize?.height ?? 1]] as [String : Any]
        }else if self.imagesForUpload.count == 0{//纯文字帖子
            param = ["type":self.isPoll ? "2" : "1",
                     "title":"\(forumTitle)",
                     "content":"\(forumContent)",
//                     "title":"\(cellTitle?.remarkTextField.text ?? "")",
//                     "content":"\(cellContent?.remarkTextField.text ?? "")",
                         "commentable":"1",
                         "contentType":"3"] as [String : Any]
        }
        
        if param["type"]as? String ?? "" == "1" && param["contentType"]as? String ?? "" == "3"{
            MCToast.mc_loading(text: "添加图片后才能发布")
            return
        }
        MCToast.mc_loading(text: "帖子发布中...")
        if self.isPoll{
            let pollType = self.choiceNum > 1 ? "2" : "1" //投票类型  2 多选   1 单选
            let haveImage = self.pollHasImage ? "1" : "0" //是否图文  1  带图   0  无图
            
            let pollOption = NSMutableArray()
            
            for i in 0..<self.pollDataArray.count{
                let model = self.pollDataArray[i]
                
                if self.pollHasImage{
                    pollOption.add(["sn":"\(i+1)",
                                    "content":model.title,
                                    "image":model.imageUrl])
                }else{
                    pollOption.add(["sn":"\(i+1)",
                                    "content":model.title])
                }
            }
            
            param["pollJson"] = ["pollType":pollType,
                                 "pollTitle":self.pollTitle,
                                 "haveImage":haveImage,
                                 "showResult":"1",
                                 "optionThreshold":"\(self.choiceNum)",
                                 "pollOption":pollOption]
        }
        
        DLLog(message: "sendForumAddRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_add, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            MCToast.mc_text("帖子已发布")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                self.backTapAction()
            })
        }
    }
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
}
