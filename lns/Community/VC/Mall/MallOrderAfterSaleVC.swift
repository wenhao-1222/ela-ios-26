//
//  MallOrderAfterSaleVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/19.
//

import Photos
import MCToast

class MallOrderAfterSaleVC: WHBaseViewVC {
    
    var orderDict = NSDictionary()
    var orderModel = MallDetailModel()
    var number = 1
    
    var cellNumber = 5
    
    var returnType = 0
    var returnReason = ""
    var photoAssets:[PHAsset] = [PHAsset]()
    var saveAssetIds:[String] = [String]()
    var imagesForUpload:[UIImage] = [UIImage]()
    var imageUploadProgress:[CGFloat] = []
    var uploadedImageUrls:[String] = []
    var isSubmitting = false
    let imageManager = PHCachingImageManager.default()
    let option = PHImageRequestOptions.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        option.resizeMode = .exact
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
    }
    
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-(self.getNavigationBarHeight()+kFitWidth(1)+self.bottomVm.selfHeight)), style: .plain)
        vi.separatorStyle = .none
        vi.delegate = self
        vi.dataSource = self
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .COLOR_BG_F2
        vi.contentInsetAdjustmentBehavior = .never
        vi.sectionFooterHeight = 0
        vi.register(MallPaySuccessTopCell.classForCoder(), forCellReuseIdentifier: "MallPaySuccessTopCell")
        vi.register(MallOrderAfterSaleNotSupportCell.classForCoder(), forCellReuseIdentifier: "MallOrderAfterSaleNotSupportCell")
        vi.register(MallOrderAfterSaleTypeCell.classForCoder(), forCellReuseIdentifier: "MallOrderAfterSaleTypeCell")
        vi.register(MallOrderAfterSaleReasonCell.classForCoder(), forCellReuseIdentifier: "MallOrderAfterSaleReasonCell")
        vi.register(MallOrderAfterSaleImgsCell.classForCoder(), forCellReuseIdentifier: "MallOrderAfterSaleImgsCell")
        
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }
        

        return vi
    }()
    lazy var bottomVm: MallPaySuccessBottomVM = {
        let vm = MallPaySuccessBottomVM.init(frame: .zero)
        vm.payButton.setTitle("提交售后", for: .normal)
        vm.payButton.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_C4C4C4), for: .disabled)
        vm.payButton.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        vm.payButton.isEnabled = false
        vm.payBlocK = {()in
            self.presentAlertVc(confirmBtn: "确定", message: "提交完成后，自动跳转订单列表查看状态", title: "是否提交售后", cancelBtn: "取消", handler: { action in
//                self.sendRefundOrderRequest()
                self.startSubmitAfterSale()
            }, viewController: self)
        }
        
        return vm
    }()
}


extension MallOrderAfterSaleVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellNumber
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessTopCell")as? MallPaySuccessTopCell
            cell?.updateUI(model: self.orderModel, number: self.number)
            cell?.dottedLineView.isHidden = true
            
            return cell ?? MallPaySuccessTopCell()
        }else if indexPath.row == 1{// indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderAfterSaleTypeCell")as? MallOrderAfterSaleTypeCell
            cell?.typeBlock = {(type)in
                self.returnType = type
                self.judgeButtonStatus()
            }
            return cell ?? MallOrderAfterSaleTypeCell()
        }else if indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderAfterSaleReasonCell")as? MallOrderAfterSaleReasonCell
            cell?.onTextChanged = {(text) in
                DLLog(message: "\(text)")
                self.returnReason = text
                self.judgeButtonStatus()
            }
            return cell ?? MallOrderAfterSaleReasonCell()
        }else if indexPath.row == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderAfterSaleImgsCell")as? MallOrderAfterSaleImgsCell
            cell?.addImgBlock = {()in
                self.addImgAction()
            }
            cell?.deleteImgBlock = {(index)in
                if self.isSubmitting { return }
                self.saveAssetIds.remove(at: index)
                self.photoAssets.remove(at: index)
                self.imagesForUpload.remove(at: index)
                if self.imageUploadProgress.count > index {
                    self.imageUploadProgress.remove(at: index)
                }
                if self.uploadedImageUrls.count > index {
                    self.uploadedImageUrls.remove(at: index)
                }
                cell?.updateImages(imgs: self.imagesForUpload as NSArray)
                cell?.updateUploadProgresses(progresses: self.imageUploadProgress)
                self.judgeButtonStatus()
            }
            
            cell?.updateImages(imgs: self.imagesForUpload as NSArray)
            cell?.updateUploadProgresses(progresses: self.imageUploadProgress)
            return cell ?? MallOrderAfterSaleImgsCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderAfterSaleNotSupportCell")as? MallOrderAfterSaleNotSupportCell
            cell?.updateUI(titleStr: "退货换货规则", detailString: "1、不支持退换货的情况有哪些；\n2、哪些情况支持退换货")
            
            return cell ?? MallOrderAfterSaleNotSupportCell()
        }
    }
}

extension MallOrderAfterSaleVC{
    func addImgAction() {
        if self.isSubmitting { return }
        self.view.becomeFirstResponder()
        
        UserConfigModel.shared.selectType = .IMAGE
        UserConfigModel.shared.photsSelectCount = photoAssets.count
        
        let vc = RITLPhotosViewController()
        vc.configuration.maxCount = 3//UserConfigModel.shared.forumPictureNumMax//(UserConfigModel.shared.forumPictureNumMax-self.photoAssets.count)
        vc.configuration.containVideo = false
        vc.configuration.hiddenGroupAllVideo = true
        vc.configuration.hiddenGroupWhenNoPhotos = true
        vc.photo_delegate = self
        vc.thumbnailSize = CGSize.init(width: SCREEN_WIDHT*0.7*0.333, height: SCREEN_WIDHT*0.7*0.333)
        vc.defaultIdentifers = self.saveAssetIds
        self.present(vc, animated: true)
    }
}
extension MallOrderAfterSaleVC:RITLPhotosViewControllerDelegate{
    func photosViewController(_ viewController: UIViewController, assetIdentifiers identifiers: [String]) {
        self.saveAssetIds = identifiers
    }
    func photosViewController(_ viewController: UIViewController, assets: [PHAsset]) {
        self.photoAssets = assets
        self.imagesForUpload.removeAll()
        self.imageUploadProgress.removeAll()
        self.uploadedImageUrls.removeAll()
//        UserConfigModel.shared.photsSelectCount = self.photoAssets.count
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        self.tableView.endUpdates()
        DLLog(message: "VideoCompress: photosViewController")
        if self.imagesForUpload.count == 0{
            self.dealChoiceImg(index:0)
        }else{
            self.dealChoiceImg(index:self.imagesForUpload.count)
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
            let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? MallOrderAfterSaleImgsCell
            self.imageUploadProgress = Array(repeating: CGFloat(-1), count: self.imagesForUpload.count)
            self.uploadedImageUrls = Array(repeating: "", count: self.imagesForUpload.count)
            cell?.updateImages(imgs: self.imagesForUpload as NSArray)
            cell?.updateUploadProgresses(progresses: self.imageUploadProgress)
            self.judgeButtonStatus()
        }
    }
}
extension MallOrderAfterSaleVC{
    func initUI() {
        initNavi(titleStr: "售后服务")
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(tableView)
        view.addSubview(bottomVm)
    }
    func judgeButtonStatus() {
//        if self.returnType > 0 && self.returnReason.trimmingCharacters(in: .whitespacesAndNewlines).count > 0{
//            self.bottomVm.payButton.isEnabled = true
//        }else{
//            self.bottomVm.payButton.isEnabled = false
//        }
        let hasType = self.returnType > 0
        let hasReason = self.returnReason.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
        let hasImages = !self.imagesForUpload.isEmpty
        self.bottomVm.payButton.isEnabled = hasType && hasReason && hasImages && !self.isSubmitting
        if !hasImages && hasType && hasReason && !self.isSubmitting {
            self.bottomVm.payButton.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_C4C4C4), for: .disabled)
        }
    }
}

extension MallOrderAfterSaleVC{
    func startSubmitAfterSale() {
        if self.imagesForUpload.isEmpty {
            MCToast.mc_text("请先上传相关图片")
            return
        }
        if self.isSubmitting {
            return
        }
        self.isSubmitting = true
        self.judgeButtonStatus()
        self.imageUploadProgress = Array(repeating: CGFloat(-1), count: self.imagesForUpload.count)
        self.uploadedImageUrls = Array(repeating: "", count: self.imagesForUpload.count)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? MallOrderAfterSaleImgsCell {
            cell.updateUploadProgresses(progresses: self.imageUploadProgress)
        }
        MCToast.mc_loading(text: "图片上传中...",respond: .allowNav)
        self.uploadImagesSequentially(at: 0)
    }

    func uploadImagesSequentially(at index: Int) {
        guard index < self.imagesForUpload.count else {
            let urls = self.uploadedImageUrls.filter { !$0.isEmpty }
            guard urls.count == self.imagesForUpload.count else {
                self.handleUploadFailure(message: "图片上传失败，请重试")
                return
            }
            MCToast.mc_loading(text: "提交中...",respond: .allowNav)
            self.sendRefundOrderRequest(imageUrls: urls)
            return
        }
        if index >= self.imageUploadProgress.count {
            self.imageUploadProgress.append(CGFloat(-1))
        }
        self.imageUploadProgress[index] = 0
        self.updateImageUploadProgress(progress: 0, index: index)

        guard let imageData = WH_DESUtils.compressImage(toData: self.imagesForUpload[index]) else {
            self.handleUploadFailure(message: "图片处理失败，请重试")
            return
        }

        DSImageUploader().uploadImage(imageData: imageData, imgType: .after_sale) { [weak self] bytesSent, totalByteSent, totalByteExpectedToSend in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let expected = CGFloat(totalByteExpectedToSend)
                let progress = expected > 0 ? CGFloat(totalByteSent) / expected : 0
                if index < self.imageUploadProgress.count {
                    self.imageUploadProgress[index] = progress
                }
                self.updateImageUploadProgress(progress: progress, index: index)
            }
        } completion: { [weak self] text, value in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if value {
                    if index < self.uploadedImageUrls.count {
                        self.uploadedImageUrls[index] = text
                    }
                    self.imageUploadProgress[index] = CGFloat(-1)
                    self.updateImageUploadProgress(progress: CGFloat(-1), index: index)
                    self.uploadImagesSequentially(at: index + 1)
                } else {
                    self.handleUploadFailure(message: "图片上传失败，请重试")
                }
            }
        }
    }

    func updateImageUploadProgress(progress: CGFloat, index: Int) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? MallOrderAfterSaleImgsCell {
            cell.updateProgress(progress: progress, index: index)
        }
    }

    func handleUploadFailure(message: String) {
        MCToast.mc_remove()
        MCToast.mc_text(message)
        self.imageUploadProgress = Array(repeating: CGFloat(-1), count: self.imagesForUpload.count)
        self.uploadedImageUrls = Array(repeating: "", count: self.imagesForUpload.count)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? MallOrderAfterSaleImgsCell {
            cell.updateUploadProgresses(progresses: self.imageUploadProgress)
        }
        self.isSubmitting = false
        self.judgeButtonStatus()
    }
    func sendRefundOrderRequest(imageUrls: [String]) {
        let param = ["bizType":"2",
                     "id":self.orderModel.id,
                     "image":imageUrls,
                     "afterSaleBizType":self.returnType,
                     "reason":self.returnReason] as [String : AnyObject]
        DLLog(message: "sendRefundOrderRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_order_refund, parameters: param) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendRefundOrderRequest:\(dataDict)")
            
            let vc = MallOrderAfterSaleSubmitVC()
            vc.type = self.returnType == 1 ? "退货退款" : "换货"
            vc.reason = self.returnReason
            vc.images = self.imagesForUpload
            vc.time = dataDict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " ")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
