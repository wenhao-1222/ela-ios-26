//
//  ServiceContactVC.swift
//  lns
//
//  Created by LNS2 on 2024/6/12.
//

import AVFoundation
import Foundation
import PhotosUI
//import ShowBigImg
import IQKeyboardManagerSwift
import MCToast
import Reachability
import AVKit
import QuartzCore

class ServiceContactVC: WHBaseViewVC {
    
    var dataSourceArray = NSMutableArray()
    var dataSourceArrayForShow = NSMutableArray()
    var imgUrl = ""
    var lastSendTest = ""
    var relatedOrderId = ""
    
    var photoAssets:[PHAsset] = [PHAsset]()
    var videoUrl : URL?
    private var videoUploadLocalURLMap: [String: URL] = [:]
    private var videoCoverImageMap: [String: UIImage] = [:]
    private var videoMessages: [String: NSMutableDictionary] = [:]
    private var videoAssetMap: [String: AVAsset] = [:]
    private var videoProgressUpdateTracker: [String: (value: CGFloat, timestamp: CFTimeInterval)] = [:]

    var saveAssetIds:[String] = [String]()
    private var previousOnlyVideoSetting = false
    
    let defaultDict = ["createdby":"admin",
                       "suggestion":"\(UserInfoModel.shared.serviceWelcome)"]
    let responeDict = ["createdby":"admin",
                       "suggestion":"\(UserInfoModel.shared.serviceResponce)"]
    
    let reachability = try! Reachability()
    
    enum MediaPickerType {
        case image
        case video
    }
    enum VideoUploadState: String {
       case preparing
       case uploading
       case paused
       case completed
       case failed
   }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = true
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
//    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        checkNetWork()
//        sendOssStsRequest()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgRead"), object: nil)
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is MallOrderAfterSaleNotSupportVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.isUserInteractionEnabled = false
        
        return vi
    }()
    lazy var msgInputView: ServiceInputVM = {
        let vi = ServiceInputVM.init(frame: .zero)
        vi.imgChoiceBlock = {()in
            self.choiceImgAction()
        }
        vi.textSendBlock = {()in
            self.sendSuggestionTextRequest()
        }
        vi.textDidInputBlock = {(keyboardSizeOriginY)in
            if keyboardSizeOriginY > 0{
//                self.tableView.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight()-keyboardSizeOriginY+self.getBottomSafeAreaHeight()-kFitWidth(1))
                self.tableView.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: keyboardSizeOriginY-self.getNavigationBarHeight()-kFitWidth(64)-kFitWidth(1))
            }else{
                self.tableView.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight()-kFitWidth(64)-kFitWidth(1))
            }
            
//            self.tableView.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight()-self.msgInputView.frame.minY)
            self.scrollToBottom()
        }
        return vi
    }()
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()-kFitWidth(64)-getBottomSafeAreaHeight()-kFitWidth(1)), style: .grouped)
        
        vi.delegate = self
        vi.dataSource = self
        vi.register(ServiceContactTableViewTextCell.classForCoder(), forCellReuseIdentifier: "ServiceContactTableViewTextCell")
        vi.register(ServiceContactTableViewVideoCell.classForCoder(), forCellReuseIdentifier: "ServiceContactTableViewVideoCell")
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.isHidden = true
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        
        return vi
    }()
}

extension ServiceContactVC{
    @objc func choiceImgAction() {
        self.view.becomeFirstResponder()
        if self.relatedOrderId.count > 0{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "发送照片", style: .default, handler: { [weak self] _ in
                self?.choiceAlbumAction()
            }))
            alert.addAction(UIAlertAction(title: "发送视频", style: .default, handler: { [weak self] _ in
                self?.choiceVideoAction()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            if let pop = alert.popoverPresentationController {
                pop.sourceView = msgInputView.addBgView
                pop.sourceRect = msgInputView.addBgView.bounds
            }
            present(alert, animated: true)
        }else{
            choiceAlbumAction()
        }
    }
    func choiceAlbumAction() {
        // 创建一个PHPickerConfiguration对象
        var configuration = PHPickerConfiguration()
        // 设置选择器的过滤条件
        configuration.filter = .images // 只显示图片
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
    func choiceVideoAction() {
        UserConfigModel.shared.selectType = .VIDEO
        UserConfigModel.shared.photsSelectCount = 0//photoAssets.count
        
        let vc = RITLPhotosViewController()
        vc.configuration.videoMaxSeconds = 30
        vc.configuration.maxCount = 1//UserConfigModel.shared.forumPictureNumMax//(UserConfigModel.shared.forumPictureNumMax-self.photoAssets.count)
        vc.configuration.containVideo = true
        vc.configuration.hiddenGroupWhenNoPhotos = true
        previousOnlyVideoSetting = vc.configuration.onlyVideo
        vc.configuration.onlyVideo = true
        vc.photo_delegate = self
        vc.thumbnailSize = CGSize.init(width: SCREEN_WIDHT*0.7*0.333, height: SCREEN_WIDHT*0.7*0.333)
//        vc.defaultIdentifers = self.saveAssetIds
        self.saveAssetIds.removeAll()
        vc.defaultIdentifers = []
        self.present(vc, animated: true)
    }
    func dealDataSource(animated:Bool?=true){
        let dataArr = NSMutableArray()
        if self.dataSourceArray.count == 0 {
            let dict = ["date":"\(Date().todayDate)",
                        "msgList":[defaultDict]] as [String : Any]
            dataArr.add(dict)
        }else{
            let firstMsgDict = self.dataSourceArray[0]as? NSDictionary ?? [:]
            var firstCtime = firstMsgDict["ctime"]as? String ?? "\(Date().todayDate)"
            firstCtime = firstCtime.replacingOccurrences(of: "T", with: " ")
            firstCtime = Date().changeDateFormatter(dateString: firstCtime, formatter: "yyyy-MM-dd HH:mm:ss", targetFormatter: "yyyy-MM-dd")
            
            let sectionMsgArray = NSMutableArray()
            sectionMsgArray.add(defaultDict)
            for i in 0..<self.dataSourceArray.count{
                let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
                var msgCtime = dict["ctime"]as? String ?? "\(Date().todayDate)"
                msgCtime = msgCtime.replacingOccurrences(of: "T", with: " ")
                msgCtime = Date().changeDateFormatter(dateString: msgCtime, formatter: "yyyy-MM-dd HH:mm:ss", targetFormatter: "yyyy-MM-dd")
                
                if msgCtime == firstCtime{
                    sectionMsgArray.add(dict)
                    if i == self.dataSourceArray.count - 1 {
                        let dictT = ["date":"\(firstCtime)",
                                    "msgList":NSArray(array: sectionMsgArray)] as [String : Any]
                        dataArr.add(dictT)
                    }
                }else{
                    if i < self.dataSourceArray.count - 1 {
                        let dictT = ["date":"\(firstCtime)",
                                    "msgList":NSArray(array: sectionMsgArray)] as [String : Any]
                        dataArr.add(dictT)
                        sectionMsgArray.removeAllObjects()
                        sectionMsgArray.add(defaultDict)
                        sectionMsgArray.add(dict)
                        firstCtime = msgCtime
                    }else{
                        let dictT1 = ["date":"\(firstCtime)",
                                    "msgList":NSArray(array: sectionMsgArray)] as [String : Any]
                        dataArr.add(dictT1)
                        sectionMsgArray.removeAllObjects()
                        sectionMsgArray.add(defaultDict)
                        sectionMsgArray.add(dict)
                        
                        let dictT = ["date":"\(msgCtime)",
                                    "msgList":NSArray(array: sectionMsgArray)] as [String : Any]
                        dataArr.add(dictT)
                    }
                }
            }
        }
        self.dataSourceArrayForShow = NSMutableArray(array: dataArr)
//        self.judgeFirstMsgForToday()
        self.tableView.reloadData()
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.scrollToBottom(animated: animated)
//        })
    }
    
    //校验是不是用户发的第一条信息，如果是，则插入自动回复消息
    func judgeFirstMsgForToday() {
        for i in 0..<self.dataSourceArrayForShow.count{
//            let dataDict = NSMutableDictionary(dictionary: self.dataSourceArrayForShow.lastObject as? NSDictionary ?? [:])
            let dataDict = NSMutableDictionary(dictionary: self.dataSourceArrayForShow[i] as? NSDictionary ?? [:])
//            let dateString = dataDict.stringValueForKey(key: "date")
//            if dateString == Date().todayDate{
                let msgListArray = NSMutableArray.init(array: dataDict["msgList"]as? NSArray ?? [])
                for j in 0..<msgListArray.count{
                    let dict = msgListArray[j]as? NSDictionary ?? [:]
                    if dict.stringValueForKey(key: "createdby") != "admin"{
                        if msgListArray.count > j + 1{
                            msgListArray.insert(responeDict, at: j+1)
                        }else{
                            msgListArray.add(responeDict)
                        }
                        dataDict.setValue(msgListArray, forKey: "msgList")
                        self.dataSourceArrayForShow.replaceObject(at: i, with: dataDict)
                        break
                    }
                }
            
//            }
            
            if i == self.dataSourceArrayForShow.count - 1 {
                let dateString = dataDict.stringValueForKey(key: "date")
                if dateString != Date().todayDate{
                    let dict = ["date":"\(Date().todayDate)",
                                "msgList":[defaultDict]] as [String : Any]
                    self.dataSourceArrayForShow.add(dict)
                }
            }
        }
    }
    
    func scrollToBottom(animated:Bool?=true) {
        if self.dataSourceArrayForShow.count > 0 {
            let dataDict = self.dataSourceArrayForShow.lastObject as? NSDictionary ?? [:]
            let dataArr = dataDict["msgList"]as? NSArray ?? []
            if dataArr.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: dataArr.count-1, section: self.dataSourceArrayForShow.count-1), at: .bottom, animated: animated ?? true)
            }else{
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.dataSourceArrayForShow.count-1), at: .bottom, animated: animated ?? true)
            }
//            if animated == false{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
                    self.tableView.isHidden = false
                })
//            }
        }
    }
    func checkNetWork(){
        self.sendOssStsRequest()
            
        reachability.whenReachable = { reachability in
            reachability.stopNotifier()
            self.sendOssStsRequest()
            self.sendMsgListRequest()
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            self.naviTitleLabel.text = "联系我们"
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            let attr = NSMutableAttributedString(string: "联系我们")
            let detailAttr = NSMutableAttributedString(string: "(无网络)")
            attr.yy_font = .systemFont(ofSize: 18, weight: .medium)
            detailAttr.yy_font = .systemFont(ofSize: 15, weight: .regular)
//            attr.yy_color = WHColor_16(colorStr: "222222")
            attr.append(detailAttr)
            self.naviTitleLabel.attributedText = attr
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

extension ServiceContactVC{
    func initUI() {
        initNavi(titleStr: "联系我们")
        self.navigationView.backgroundColor = .clear
        
        view.insertSubview(bottomView, belowSubview: self.navigationView)
        view.addSubview(tableView)
        view.addSubview(msgInputView)
    }
}

extension ServiceContactVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceArrayForShow.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataDict = dataSourceArrayForShow[section]as? NSDictionary ?? [:]
        let dataArr = dataDict["msgList"]as? NSArray ?? []
        return dataArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataDict = dataSourceArrayForShow[indexPath.section]as? NSDictionary ?? [:]
        let dataArr = dataDict["msgList"]as? NSArray ?? []
        let dict = dataArr[indexPath.row]as? NSDictionary ?? [:]
        
        if dict.stringValueForKey(key: "contentType") == "3"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceContactTableViewVideoCell") as? ServiceContactTableViewVideoCell
            cell?.delegate = self
            cell?.updateUI(dict: dict)
            
            return cell ?? ServiceContactTableViewVideoCell()
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceContactTableViewTextCell") as? ServiceContactTableViewTextCell
            cell?.updateUI(dict: dict)
            
            cell?.imgTapBlock = {(image)in
                self.msgInputView.textView.resignFirstResponder()
                if image != nil{
                    let showController = ShowBigImgController(imgs: [image!], img: image!,isNavi: true)
                    
                    self.navigationController?.pushViewController(showController, animated: true)
                }
            }
            
            return cell ?? ServiceContactTableViewTextCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(30)))
        vi.backgroundColor = .clear
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(30)))
        label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        vi.addSubview(label)
        
        let dataDict = dataSourceArrayForShow[section]as? NSDictionary ?? [:]
        label.text = dataDict["date"]as? String ?? ""
        
        return vi
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(20)))
        vi.backgroundColor = .clear
        
        if dataSourceArrayForShow.count > 1 {
            return dataSourceArrayForShow.count - 1 == section ? vi : nil
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if dataSourceArrayForShow.count > 1 {
            return dataSourceArrayForShow.count - 1 == section ? kFitWidth(20) : kFitWidth(0)
        }
        return kFitWidth(0)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(30)
    }
}

extension ServiceContactVC{
    func sendMsgListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Service_Msg_List, parameters: nil,isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = self.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendMsgListRequest:\(dataArray)")
            
            self.dataSourceArray.removeAllObjects()
            self.dataSourceArray.addObjects(from: dataArray as! [Any])
            self.dealDataSource(animated: true)
        }
    }
    
    func uploadImgData(image:UIImage) {
//        let imageData = image.pngData()
        let imageData = WH_DESUtils.compressImage(toData: image)
//        MCToast.mc_loading()
        let type = self.relatedOrderId.count > 0 ? IMAGE_TYPE.after_sale : IMAGE_TYPE.suggestion
        DSImageUploader().uploadImage(imageData: imageData!, imgType: type) { text, value in
            DLLog(message: "\(text)")
            DLLog(message: "\(value)")
            MCToast.mc_remove()
            if value == true{
//                self.imgUrl = "\(text)"
                self.sendSuggestionImgsRequest(imgUrlString:"\(text)")
            }else{
                MCToast.mc_text("图片上传失败")
            }
        }
    }
    
    func sendSuggestionImgsRequest(imgUrlString:String) {
        var param = ["images":[imgUrlString],
                     "contentType": "2"] as [String : Any]
        if self.relatedOrderId.count > 0 {
            param = ["images":[imgUrlString],
                     "bizType":"2",
                     "relatedOrderId":self.relatedOrderId,
                     "contentType": "2"] as [String : Any]
        }
            
        WHNetworkUtil.shareManager().POST(urlString: URL_Uer_sugestion, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            let dict = ["createdby":"\(UserInfoModel.shared.nickname)",
                        "ctime":"\(Date().currentSeconds)",
                        "images":"\(self.getJSONStringFromArray(array: [imgUrlString]))"]
            self.dataSourceArray.add(dict)
            self.dealDataSource()
            
        }
    }
    func sendSuggestionTextRequest() {
        let text = self.msgInputView.textView.text.disable_emoji(text: self.msgInputView.textView.text! as NSString)
        if self.lastSendTest == text{
            return
        }
        self.lastSendTest = text
        var param = ["suggestion":self.msgInputView.textView.text.disable_emoji(text: self.msgInputView.textView.text! as NSString),
                     "contentType": "1"]
        if self.relatedOrderId.count > 0 {
            param = ["suggestion":self.msgInputView.textView.text.disable_emoji(text: self.msgInputView.textView.text! as NSString),
                     "bizType":"2",
                     "relatedOrderId":self.relatedOrderId,
                     "contentType": "1"]
        }
        WHNetworkUtil.shareManager().POST(urlString: URL_Uer_sugestion, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            let dict = ["createdby":"\(UserInfoModel.shared.nickname)",
                        "ctime":"\(Date().currentSeconds)",
                        "suggestion":"\(self.msgInputView.textView.text.disable_emoji(text: self.msgInputView.textView.text! as NSString))"]
            self.dataSourceArray.add(dict)
            self.dealDataSource()
            
            self.msgInputView.textView.text = ""
        }
    }
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ServiceContactVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        self.presentedViewController?.dismiss(animated: true)
        self.setImgs(results: results)
    }
    func setImgs(results: [PHPickerResult]) {
        for result in results{
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    
                    guard let self = self else { return }
                    guard let image = image as? UIImage else {
                        /// 错误处理
                        return
                    }
                    self.uploadImgData(image: image)
                }
            } else {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier,
                                                           completionHandler: { url, error  in
                    do {
                        if let url = url {
                            let imageData = try Data(contentsOf: url)
                            if let image = UIImage(data: imageData) {
                                self.uploadImgData(image: image)
                            } else {
                                /// 错误处理
                            }
                        } else {
                            /// 错误处理
                        }
                    } catch let error {
                        /// 错误处理
                    }
                })
            }
        }
    }
}

extension ServiceContactVC:RITLPhotosViewControllerDelegate{
    func photosViewController(_ viewController: UIViewController, assetIdentifiers identifiers: [String]) {
        self.saveAssetIds = identifiers
    }
//    func photosViewController(_ viewController: UIViewController, thumbnailImages: [UIImage], infos: [[AnyHashable : Any]]) {
////        self.photoAssets = thumbnailImages
//    }
    func photosViewController(_ viewController: UIViewController, assets: [PHAsset]) {
        self.photoAssets = assets
//        self.imagesForUpload.removeAll()
//        UserConfigModel.shared.photsSelectCount = self.photoAssets.count
//        if self.photoAssets.count > 0 {
//            let firstAsset = self.photoAssets.first
//            
//            DLLog(message: "isVideo:\(firstAsset?.mediaType == .video)")
//            UserConfigModel.shared.selectType = firstAsset?.mediaType == .video ? .VIDEO : .IMAGE
//            self.contentType = firstAsset?.mediaType == .video ? .VIDEO : .IMAGE
//            if UserConfigModel.shared.selectType == .VIDEO{
//                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PublishImagesCellCollection
//                cell?.updateImages(imgs: [])
//            }
//        }
        
//        self.tableView.beginUpdates()
//        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
//        self.tableView.endUpdates()
        DLLog(message: "VideoCompress: photosViewController")
        if self.photoAssets.count > 0 {
            ServiceContactVideoManager.shared.dealVideoAsset(asset: self.photoAssets[0],retry: 0) {videoUrl in
                if let url = videoUrl{
                    DLLog(message: "\(url)")
                    self.videoUrl = url
                    let asset = ServiceContactVideoManager.shared.videoAsset ?? AVAsset(url: url)
                    DLLog(message: "fetchFramesFromVideo:(keyFrames)--- startTime \(Date().currentSeconds)")
                    VideoUtils().getKeyFrameFromUrl(videoUrl: self.videoUrl) { _ in
                        DLLog(message: "fetchFramesFromVideo:(keyFrames)--- endTime \(Date().currentSeconds)")
                        DLLog(message: "fetchFramesFromVideo:(keyFrames)---\(VideoEditModel.shared.keyFrames.count)")
                        
                        if VideoEditModel.shared.keyFramesLoad == true{
                            self.handleSelectedVideo(asset: asset, url)
//                            let dict = ["createdby":"\(UserInfoModel.shared.nickname)",
//                                        "ctime":"\(Date().currentSeconds)",
//                                        "contentType":"3",
//                                        "material":[["coverImageOssUrl":"",
//                                                     "localImg":VideoEditModel.shared.videoCoverImage,
//                                                     "videoOssUrl":"",
//                                                     "videoWidth":"\(VideoEditModel.shared.videoCoverImageSize?.width ?? 1280)",
//                                                     "videoHeight":"\(VideoEditModel.shared.videoCoverImageSize?.height ?? 720)",
//                                                     "videoDuration":""]]]
//                            self.dataSourceArray.add(dict)
//                            self.dealDataSource()
                        }
                    }
                    DispatchQueue.main.async {
                        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PublishVideoCell
                        cell?.updateVideo(assetUrl: url)
                    }
                }
            }
        }
    }
    func photosViewControllerWillDismiss(_ viewController: UIViewController) {
        if let photosVC = viewController as? RITLPhotosViewController {
            photosVC.configuration.onlyVideo = previousOnlyVideoSetting
        } else {
            RITLPhotosConfiguration.default().onlyVideo = false//previousOnlyVideoSetting
        }
    }
    private func playVideo(messageId: String, urlString: String?) {
//        var url: URL?
//        if let message = messageDictionary(for: messageId) {
//            let remote = message.stringValueForKey(key: "videoOssUrl")
//            if !remote.isEmpty, let remoteURL = URL(string: remote) {
//                url = remoteURL
//            } else {
//                let localPath = message.stringValueForKey(key: "videoLocalPath")
//                if !localPath.isEmpty {
//                    url = URL(fileURLWithPath: localPath)
//                }
//            }
//        }
//        if url == nil, let urlString = urlString, !urlString.isEmpty {
//            if urlString.hasPrefix("http") || urlString.hasPrefix("https") {
//                url = URL(string: urlString)
//            } else {
//                url = URL(fileURLWithPath: urlString)
//            }
//        }
//        guard let playURL = url else { return }
//        
        if urlString?.count ?? 0 > 0 {
            DSImageUploader().dealImgUrlSignForOss(urlStr: urlString ?? "") { signUrl in
                let playURLT = URL(string: signUrl)
                guard let playURL = playURLT else { return }
                DispatchQueue.main.async {
                    let player = AVPlayer(url: playURL)
                    let playerVC = AVPlayerViewController()
                    playerVC.player = player
                    self.present(playerVC, animated: true) {
                        player.play()
                    }
                }
            }
        }
    }
}

extension ServiceContactVC{
    private func handleVideoResult(_ result: PHPickerResult?) {
        guard let result = result else { return }
        if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                guard let self = self else { return }
                if let error = error {
                    DLLog(message: "video load error: \(error.localizedDescription)")
                    return
                }
                guard let url = url else { return }
//                self.prepareVideoForUpload(from: url)
            }
        }
    }
}
extension ServiceContactVC {
    private func handleSelectedVideo(asset: AVAsset, _ originalURL: URL) {
        let messageId = UUID().uuidString
        let messageDict = createVideoMessagePlaceholder(messageId: messageId, asset: asset)
        videoMessages[messageId] = messageDict
        videoAssetMap[messageId] = asset
        if let coverImage = VideoEditModel.shared.videoCoverImage {
            videoCoverImageMap[messageId] = coverImage
        }
        dataSourceArray.add(messageDict)
        dealDataSource()
        scrollToBottom()
        prepareVideoForUpload(asset: asset, messageId: messageId)
    }

    private func createVideoMessagePlaceholder(messageId: String, asset: AVAsset) -> NSMutableDictionary {
        let messageDict = NSMutableDictionary()
        messageDict.setValue(messageId, forKey: "messageId")
        messageDict.setValue(UserInfoModel.shared.nickname, forKey: "createdby")
        messageDict.setValue(Date().currentSeconds, forKey: "ctime")
        messageDict.setValue("3", forKey: "contentType")
        messageDict.setValue(VideoUploadState.preparing.rawValue, forKey: "videoUploadState")
        messageDict.setValue(NSNumber(value: 0), forKey: "videoUploadProgress")

        let materialDict = NSMutableDictionary()
        if let coverImage = VideoEditModel.shared.videoCoverImage {
            materialDict.setValue(coverImage, forKey: "localImg")
        }
        materialDict.setValue("", forKey: "coverImageOssUrl")
        materialDict.setValue("", forKey: "videoOssUrl")
        let size = resolvedVideoSize(from: asset)
        materialDict.setValue(String(format: "%.0f", size.width), forKey: "videoWidth")
        materialDict.setValue(String(format: "%.0f", size.height), forKey: "videoHeight")
        let durationValue = CMTimeGetSeconds(asset.duration)
        let durationSeconds = (durationValue.isFinite && durationValue > 0) ? durationValue : 0
        materialDict.setValue(String(format: "%.0f", durationSeconds*1000), forKey: "videoDuration")

        let materialArray = NSMutableArray(object: materialDict)
        messageDict.setValue(materialArray, forKey: "material")

        return messageDict
    }

    private func resolvedVideoSize(from asset: AVAsset) -> CGSize {
        if let coverSize = VideoEditModel.shared.videoCoverImageSize,
           coverSize.width > 0,
           coverSize.height > 0 {
            return coverSize
        }
        if let track = asset.tracks(withMediaType: .video).first {
            let transformed = track.naturalSize.applying(track.preferredTransform)
            return CGSize(width: abs(transformed.width), height: abs(transformed.height))
        }
        return CGSize(width: 720, height: 1280)
    }

    private func prepareVideoForUpload(asset: AVAsset, messageId: String) {
        updateVideoMessage(messageId: messageId, state: .preparing, progress: 0)
        let sanitizedId = messageId.replacingOccurrences(of: "-", with: "")
        let outputName = "service_contact_video_\(sanitizedId)"
        ServiceContactVideoManager.shared.exportVideoToSandbox(asset: asset,
                                                               outputFileName: outputName) { [weak self] exportedURL in
            guard let self = self else { return }
            guard let exportedURL = exportedURL else {
                self.updateVideoMessage(messageId: messageId, state: .failed, progress: 0)
                MCToast.mc_text("视频处理失败")
                return
            }
            self.videoUploadLocalURLMap[messageId] = exportedURL
            self.startUploadingVideo(at: exportedURL, messageId: messageId)
        }
    }

    private func startUploadingVideo(at url: URL, messageId: String) {
        if FileManager.default.fileExists(atPath: url.path) == false {
            if let asset = videoAssetMap[messageId] {
                prepareVideoForUpload(asset: asset, messageId: messageId)
            }
            return
        }
        updateVideoMessage(messageId: messageId, state: .uploading, progress: 0)
        DSImageUploader().uploadMovie(fileUrl: url,targetPath: "after_sale") { [weak self] percent in
            guard let self = self else { return }
            self.updateVideoMessage(messageId: messageId, progress: CGFloat(percent))
        } completion: { [weak self] text, value in
            guard let self = self else { return }
            if value {
                self.updateVideoMessage(messageId: messageId, progress: 1, videoURL: text)
                self.uploadVideoCover(for: messageId, videoURL: text)
            } else {
                self.updateVideoMessage(messageId: messageId, state: .failed)
                MCToast.mc_text("视频上传失败")
            }
        }
    }

    private func uploadVideoCover(for messageId: String, videoURL: String) {
        guard let coverImage = videoCoverImageMap[messageId],
              let imageData = WH_DESUtils.compressImage(toData: coverImage) else {
            sendVideoMessage(videoURL: videoURL, coverURL: "", messageId: messageId)
            return
        }

        DSImageUploader().uploadImage(imageData: imageData, imgType: .suggestion) { [weak self] text, value in
            guard let self = self else { return }
            if value {
                self.updateVideoMessage(messageId: messageId, coverURL: text)
                self.sendVideoMessage(videoURL: videoURL, coverURL: text, messageId: messageId)
            } else {
                self.updateVideoMessage(messageId: messageId, state: .failed)
                MCToast.mc_text("封面上传失败")
            }
        }
    }

    private func sendVideoMessage(videoURL: String, coverURL: String, messageId: String) {
        guard let message = videoMessages[messageId],
              let materialArray = message["material"] as? NSArray,
              let materialDict = materialArray.firstObject as? NSDictionary else {
            return
        }

        let width = materialDict.doubleValueForKey(key: "videoWidth")
        let height = materialDict.doubleValueForKey(key: "videoHeight")
        let duration = materialDict.doubleValueForKey(key: "videoDuration")

        let payload: [NSDictionary] = [[
            "videoOssUrl": videoURL,
            "coverImageOssUrl": coverURL,
            "videoWidth": String(format: "%.0f", width),
            "videoHeight": String(format: "%.0f", height),
            "videoDuration": String(format: "%.0f", duration)
        ]]

        let params: [String: Any] = [
            "bizType":"2",
            "relatedOrderId":self.relatedOrderId,
            "contentType": "3",
            "material": payload
        ]
        DLLog(message: "URL_Uer_sugestion:\(params)")
        WHNetworkUtil.shareManager().POST(urlString: URL_Uer_sugestion,
                                           parameters: params as [String : AnyObject],
                                           isNeedToast: true,
                                           vc: self) { [weak self] _ in
            guard let self = self else { return }
            self.updateVideoMessage(messageId: messageId, state: .completed, progress: 1)
            if let localURL = self.videoUploadLocalURLMap.removeValue(forKey: messageId) {
                ServiceContactVideoManager.shared.removeFileIfExists(at: localURL)
            }
            self.videoCoverImageMap.removeValue(forKey: messageId)
            self.videoAssetMap.removeValue(forKey: messageId)
            self.videoMessages.removeValue(forKey: messageId)
        } failure: { [weak self] _ in
            guard let self = self else { return }
            self.updateVideoMessage(messageId: messageId, state: .failed, progress: 1)
        }
    }

    private func updateVideoMessage(messageId: String,
                                    state: VideoUploadState? = nil,
                                    progress: CGFloat? = nil,
                                    videoURL: String? = nil,
                                    coverURL: String? = nil) {
        // ---- ① 仅进度更新并且需要节流时，直接返回（你已有逻辑）----
        if state == nil, videoURL == nil, coverURL == nil, let p = progress,
           shouldThrottleProgressUpdate(for: messageId, progress: p) {
            return
        }

        // ---- ② 如果是“仅进度更新”，且该 cell 当前可见：直接更新 UI，不 reload ----
        if state == nil, videoURL == nil, coverURL == nil, let p = progress {
            DispatchQueue.main.async {
                if let indexPath = self.indexPath(forMessageId: messageId),
                   let cell = self.tableView.cellForRow(at: indexPath) as? ServiceContactTableViewVideoCell {
                    // 读当前状态（如果没有，按 uploading 处理）
                    let dict = self.messageDictionary(for: messageId)
                    let stateStr = dict?.stringValueForKey(key: "videoUploadState") ?? VideoUploadState.uploading.rawValue
                    let s = VideoUploadState(rawValue: stateStr) ?? .uploading
                    cell.updateProgressUI(state: s, progress: CGFloat(p))
                }
            }
            // 同步内存模型（不触发布局/不 reload）
            if let message = self.videoMessages[messageId] {
                message.setValue(NSNumber(value: Double(p)), forKey: "videoUploadProgress")
            }
            // 进度 < 1 直接 return；让后续 tick 继续走这个“快路径”
            if (progress ?? 0) < 1 { return }
            // 走到这里说明 =1 了，继续往下做最终态的 UI 收口（比如切 completed）
        }

        // ---- ③ 有结构变化：更新模型 + 选择性 reload ----
        DispatchQueue.main.async {
            guard let message = self.videoMessages[messageId] else { return }
            if let state = state {
                message.setValue(state.rawValue, forKey: "videoUploadState")
            }
            if let progress = progress {
                message.setValue(NSNumber(value: Double(progress)), forKey: "videoUploadProgress")
            }
            if let materialArray = message["material"] as? NSMutableArray,
               let materialDict = materialArray.firstObject as? NSMutableDictionary {
                if let videoURL = videoURL {
                    materialDict.setValue(videoURL, forKey: "videoOssUrl")
                }
                if let coverURL = coverURL {
                    materialDict.setValue(coverURL, forKey: "coverImageOssUrl")
                    materialDict.setValue(coverURL, forKey: "videoCover")
                    materialDict.removeObject(forKey: "localImg")
                }
            }

            // 只有在「状态终结」或「URL/封面发生变化」时才 reload
            let needReload = (state == .completed || state == .failed) || (videoURL != nil) || (coverURL != nil)
            if needReload, let indexPath = self.indexPath(forMessageId: messageId) {
                UIView.performWithoutAnimation {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }

            // 终结后清理节流记录
            if let s = state, s == .completed || s == .failed {
                self.videoProgressUpdateTracker.removeValue(forKey: messageId)
            }
            if let p = progress, p >= 1 {
                self.videoProgressUpdateTracker.removeValue(forKey: messageId)
            }
        }
    }

    private func shouldThrottleProgressUpdate(for messageId: String, progress: CGFloat) -> Bool {
        let clampedProgress = max(0, min(progress, 1))
        if clampedProgress >= 1 {
            videoProgressUpdateTracker.removeValue(forKey: messageId)
            return false
        }

        let now = CACurrentMediaTime()
        if let record = videoProgressUpdateTracker[messageId] {
            let delta = abs(clampedProgress - record.value)
            let interval = now - record.timestamp
            if delta < 0.02 && interval < 0.15 {
                return true
            }
        }

        videoProgressUpdateTracker[messageId] = (clampedProgress, now)
        return false
    }
    private func indexPath(forMessageId messageId: String) -> IndexPath? {
        for section in 0..<dataSourceArrayForShow.count {
            guard let sectionDict = dataSourceArrayForShow[section] as? NSDictionary,
                  let msgList = sectionDict["msgList"] as? NSArray else { continue }
            for row in 0..<msgList.count {
                if let dict = msgList[row] as? NSDictionary,
                   dict.stringValueForKey(key: "messageId") == messageId {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }

    private func messageDictionary(for messageId: String) -> NSDictionary? {
        if let message = videoMessages[messageId] {
            return message
        }
        for section in 0..<dataSourceArrayForShow.count {
            guard let sectionDict = dataSourceArrayForShow[section] as? NSDictionary,
                  let msgList = sectionDict["msgList"] as? NSArray else { continue }
            for case let dict as NSDictionary in msgList {
                if dict.stringValueForKey(key: "messageId") == messageId {
                    return dict
                }
            }
        }
        return nil
    }
}
extension ServiceContactVC: ServiceContactTableViewVideoCellDelegate {
    func serviceContactVideoCellDidTogglePause(_ cell: ServiceContactTableViewVideoCell) {
        let messageId = cell.messageId
        guard !messageId.isEmpty else { return }
        guard let dict = messageDictionary(for: messageId),
              let state = VideoUploadState(rawValue: dict.stringValueForKey(key: "videoUploadState")) else { return }
        switch state {
        case .failed, .paused:
            if let localURL = videoUploadLocalURLMap[messageId] {
                startUploadingVideo(at: localURL, messageId: messageId)
            } else if let asset = videoAssetMap[messageId] {
                prepareVideoForUpload(asset: asset, messageId: messageId)
            } else {
                MCToast.mc_text("视频资源已丢失，请重新选择")
            }
        case .preparing, .uploading:
            MCToast.mc_text("视频正在上传，请稍后")
        case .completed:
            break
        }
    }

    func serviceContactVideoCellDidTapPlay(_ cell: ServiceContactTableViewVideoCell) {
        DSImageUploader().dealImgUrlSignForOss(urlStr: cell.videoURLString ?? "") { signUrl in
            self.playVideo(messageId: cell.messageId, urlString: cell.videoURLString)
        }
        
//        let messageId = cell.messageId
//        guard !messageId.isEmpty else { return }
//        guard let materialArray = messageDictionary(for: messageId)?["material"] as? NSArray,
//              let info = materialArray.firstObject as? NSDictionary else { return }
//        let videoURL = info.stringValueForKey(key: "videoOssUrl")
//        if videoURL.count < 3 {
//            MCToast.mc_text("视频正在上传，请稍后再试")
//        } else {
//            MCToast.mc_text("视频已上传，后续版本将支持播放")
//        }
    }
}
