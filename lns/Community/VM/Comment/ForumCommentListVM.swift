//
//  ForumCommentListVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/12.
//
import MJRefresh
import MCToast
import Photos

class ForumCommentListVM: UIView {

    var controller = WHBaseViewVC()

    let labelHeight = kFitWidth(40)
    var model = ForumModel()
    var dataSourceArray:[ForumCommentListModel] = [ForumCommentListModel]()
//    var sectionHeaders = [Int:(modelId:String,view:ForumCommentListHeadVM)]()
    var sectionHeaders = [Int:ForumCommentListHeadVM]()
    var sectionFootVms = [Int:ForumCommentListFootVM]()

    var hasLoadData = false
    var isShowSkeleton = true
    var commentPageNum = 1
    var commentPageSize = 10
    var commentDeadline = ""
    var replyPageNum = 1
    var replyPageSize = 1
    var replyDeadline = ""
    var lastRequestIndex = 0
    var hasMoreData = true
    var isLoadinData = false

    var replyIndexPath = IndexPath()
    var selectRect = CGRect()

    var isFromNewsVC = false
    var newsCommentId = ""
    var newsReplyIds:[String] = [String]()

    var tapBlock:((ForumCommentModel)->())?
    var tapReplyBlock:((ForumCommentReplyModel)->())?
    var longPressCommentBlock:((ForumCommentModel)->())?
    var longPressReplyBlock:((ForumCommentReplyModel)->())?
    var scrollToOffsetY:((CGRect)->())?
    var setTopOffsetY:((CGRect)->())?

    var loadMoreDataBlock:((Bool)->())?
    var loadMoreReply = false

    ///站内信跳转进来的时候，查询评论列表，需要传参
    var commentId = ""
    ///站内信跳转进来的时候，查询评论列表，需要传参
    var replyId = ""
    //是否已经高亮过
    var isHightlghted = false

    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true

        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var topLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
    lazy var commentCountLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "评论"
        return lab
    }()
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView(frame: CGRect(x: 0, y: labelHeight, width: SCREEN_WIDHT, height: self.bounds.height - labelHeight), style: .grouped)
        vi.delegate = self
        vi.dataSource = self
        vi.bounces = false
        vi.separatorStyle = .none
        vi.sectionFooterHeight = 0
        vi.showsVerticalScrollIndicator = false
        vi.showsHorizontalScrollIndicator = false
        vi.backgroundColor = .white
        vi.register(ForumCommentReplyListCell.classForCoder(), forCellReuseIdentifier: "ForumCommentReplyListCell")
//        vi.register(ForumCommentSkeletonCell.self, forCellReuseIdentifier: "ForumCommentSkeletonCell")
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }
        return vi
    }()
}

extension ForumCommentListVM{
    func dealDataSource(dataArray:NSArray,needRefresh:Bool?=true) {
        if self.commentPageNum == 1 && isFromNewsVC == false {
            self.dataSourceArray.removeAll()
        }

        if self.dataSourceArray.count > 0 {
            let model = self.dataSourceArray[0]
            if model.commentModel.id.count == 0 {
                self.dataSourceArray.removeAll()
            }
        }

        for i in 0..<dataArray.count{
            let dict = dataArray[i] as? NSDictionary ?? [:]
            if self.newsCommentId == dict.stringValueForKey(key: "id"){ continue }
            let model = ForumCommentModel().dealData(dict: dict)
            let replyList = dict["replyList"] as? NSArray ?? []
            let dataModel = ForumCommentListModel()

            for j in 0..<replyList.count{
                let replyDict = replyList[j] as? NSDictionary ?? [:]
                let replyModel = ForumCommentReplyModel().dealData(dict: replyDict)
                dataModel.replyModels.append(replyModel)
            }

            model.replyCountSurplus = "\(model.replyCount.intValue - dataModel.replyModels.count)"
            dataModel.commentModel = model
            dataSourceArray.append(dataModel)

            if self.replyDeadline == ""{
                self.replyDeadline = dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " ")
            }
            if self.commentDeadline == ""{
                self.commentDeadline = dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " ")
            }
        }

        // 数据到了，关闭骨架
//        self.isShowSkeleton = false
//        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            // 3) 最后统一把骨架优雅淡出 + 内容淡入
//            [self.tableView].forEach { $0.hideSkeletonWithCrossfade() }
            if needRefresh ?? true {
//                DispatchQueue.main.async {
                    self.tableView.reloadData()
    //                self.tableView.setNeedsDisplay()
    //                self.tableView.layoutIfNeeded()
//                }
            }
//        })
    }

    func dealReplyDataArray(dataArr:NSArray,section:Int) {
        let model = self.dataSourceArray[section]

        var indexPaths = [IndexPath]()
        var firstIndex = 0
        if model.commentModel.replyPage == 1 && self.isFromNewsVC == false {
            if model.commentModel.replyPageSize > model.replyModels.count {
                firstIndex = model.replyModels.count
            }else{
                model.replyModels.removeAll()
            }
        }

        var insertIndexPaths:[IndexPath] = []
        for j in firstIndex..<dataArr.count{
            let replyDict = dataArr[j] as? NSDictionary ?? [:]
            var hasData = false
            for newsReplyId in self.newsReplyIds {
                if newsReplyId == replyDict.stringValueForKey(key: "id"){
                    hasData = true
                    break
                }
            }
            if hasData { continue }

            let replyModel = ForumCommentReplyModel().dealData(dict: replyDict)
            if !model.replyModelIds().contains(replyModel.id){
                model.replyModels.append(replyModel)
                insertIndexPaths.append(IndexPath(row: model.replyModels.count-1, section: section))
            }

            let indexPath = IndexPath(row: model.replyModels.count-1, section: section)
            indexPaths.append(indexPath)
        }

        model.commentModel.replyCountSurplus = "\(model.commentModel.replyCount.intValue - model.replyModels.count)"
        model.commentModel.replyPage = model.commentModel.replyPage + 1
        self.dataSourceArray[section] = model

        let footVm = self.sectionFootVms[section]
        footVm?.contentLabel.text = "展开 \(model.commentModel.replyCountSurplus) 条回复"

        self.tableView.insertRows(at: insertIndexPaths, with: .none)
        self.loadMoreReply = false
    }

    func addComment(coModel:ForumCommentModel) {
        let modelT = ForumCommentListModel()
        modelT.commentModel = coModel
        self.dataSourceArray.insert(modelT, at: 0)
        self.tableView.reloadData()
    }
    func addReply(reModel:ForumCommentReplyModel) {
        let model = self.dataSourceArray[self.replyIndexPath.section]
        var replyModels = model.replyModels
        replyModels.append(reModel)
        model.replyModels = replyModels
        self.dataSourceArray[self.replyIndexPath.section] = model
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: replyModels.count-1, section: self.replyIndexPath.section)], with: .fade)
        self.tableView.endUpdates()
    }
    func deleteComment() {
        _ = self.dataSourceArray[self.replyIndexPath.section]
        self.dataSourceArray.remove(at: self.replyIndexPath.section)
        self.tableView.reloadData()
    }
    func deleteCommentReply() {
        let model = self.dataSourceArray[self.replyIndexPath.section]
        var replyModels = model.replyModels
        replyModels.remove(at: self.replyIndexPath.row)
        model.replyModels = replyModels
        self.dataSourceArray[self.replyIndexPath.section] = model

        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet(integer: self.replyIndexPath.section), with: .fade)
        self.tableView.endUpdates()
    }
    func longPressForReplyAction(model:ForumCommentReplyModel) { longPressReplyBlock?(model) }
    func longPressForCommentAction(model:ForumCommentModel) { longPressCommentBlock?(model) }

    func loadMoreAction(){
        if self.isShowSkeleton {
            self.loadMoreDataBlock?(true)
            return
        }
        if self.hasMoreData && self.isLoadinData == false{
            self.isLoadinData = true
            let serialQueue = DispatchQueue(label: "com.forum.comment.request")
            serialQueue.async {
                self.commentPageNum += 1
                self.sendCommentListRequest()
            }
        }
    }
    func getSelectCell(indexPath: IndexPath) {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ForumCommentReplyListCell", for: indexPath)
        DLLog(message: "getSelectCell(indexPath:\(cell.frame)")
    }
}

extension ForumCommentListVM{
    func longPressHandle(vm: HeroBrowserViewModuleBaseProtocol) {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == PHAuthorizationStatus.authorized || status == PHAuthorizationStatus.notDetermined {
                JFPopupView.popup.actionSheet {
                    [
                        JFPopupAction(with: "保存", subTitle: nil) {
                            if let imgVM = vm as? HeroBrowserViewModule {
                                JFPopupView.popup.loading(hit: "图片保存中")
                                imgVM.asyncLoadRawSource { result in
                                    JFPopupView.popup.hideLoading()
                                    switch result {
                                    case let .success(image):
                                        self.savePhotos(image: image, data: nil)
                                    default:
                                        break
                                    }
                                }
                            }
                        },
                    ]
                }
            }else{
                self.openSystemSettingPhotoLibrary()
            }
        }
    }
    func savePhotos(image: UIImage?,data: Data?) {
        PHPhotoLibrary.shared().performChanges {
            if let imgData = data {
                let req = PHAssetCreationRequest.forAsset()
                req.addResource(with: .photo, data: imgData, options: nil)
            }else if let img = image{
                _ = PHAssetChangeRequest.creationRequestForAsset(from: img)
            }else{
                MBProgressHUD.xy_hide()
                return
            }
        } completionHandler: { (finish, _) in
            DispatchQueue.main.async {
                if finish { JFPopupView.popup.toast(hit: "保存成功") }
                else { JFPopupView.popup.toast(hit: "保存失败") }
            }
        };
    }

    func openSystemSettingPhotoLibrary() {
        let alert = UIAlertController(title:"未获得权限访问您的照片", message:"请在设置选项中允许访问您的照片", preferredStyle: .alert)
        let confirm = UIAlertAction(title:"去设置", style: .default) { (_)in
            let url = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancel = UIAlertAction(title:"取消", style: .cancel, handler:nil)
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.controller.present(alert, animated:true, completion:nil)
    }
}

extension ForumCommentListVM{
    func initUI() {
        addSubview(commentCountLabel)
        addSubview(topLineView)
        addSubview(tableView)
        
        commentCountLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
            make.height.equalTo(labelHeight)
        }
        topLineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }

        initSkeletonData()
    }

    func initSkeletonData() {
        // 占位 5 条
//        dataSourceArray = (0..<5).map { _ in ForumCommentListModel() }
        // 占位 5 条，每条包含一个空回复用于显示骨架
        dataSourceArray.removeAll()
        sectionHeaders.removeAll()
        for _ in 0..<5 {
            let listModel = ForumCommentListModel()
            listModel.replyModels = [ForumCommentReplyModel()]
            dataSourceArray.append(listModel)
        }
        isShowSkeleton = true
        tableView.reloadData()
    }
}

// MARK: - Table & Skeleton
extension ForumCommentListVM:UITableViewDelegate,UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
//        return isShowSkeleton ? max(5, dataSourceArray.count) : dataSourceArray.count
        return dataSourceArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 骨架期间：每个 section 放 1 个“卡片骨架”
//        if isShowSkeleton { return 0 }
        let model = dataSourceArray[section]
        return model.replyModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumCommentReplyListCell", for: indexPath) as? ForumCommentReplyListCell
        let model = dataSourceArray[indexPath.section]
        let models = model.replyModels
        let replyMo = models[indexPath.row]
        cell?.updateUI(model: replyMo)

        if self.isFromNewsVC && self.replyId.count > 0  && isHightlghted == false && newsReplyIds.count > 0 {
            if let lastReplyId = newsReplyIds.last , lastReplyId == replyMo.id{
                self.isHightlghted = true
                cell?.isSelectCell = true
                cell?.layoutBlock = {(cellFrame,comment)in
                    if replyMo.commentString == comment{
                        if self.scrollToOffsetY != nil { self.scrollToOffsetY!(cellFrame) }
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) { cell?.showSelectAction() }
                    }
                }
            }
        }

        cell?.longPressBlock = {()in
            self.replyIndexPath = indexPath
            self.longPressForReplyAction(model: models[indexPath.row])
        }
        cell?.thumbBlock = {()in
            self.replyIndexPath = indexPath
            self.sendThumbsUpReplyRequest(reModel: models[indexPath.row])
        }
        cell?.tapBlock = {()in
            if self.tapReplyBlock != nil{
                self.replyIndexPath = indexPath
                let models = model.replyModels
                self.tapReplyBlock!(models[indexPath.row])
            }
        }
        cell?.imgTapBlock = {(img)in
            var list: [HeroBrowserViewModule] = []
            list.append(HeroBrowserLocalImageViewModule(image: img))
            let brower = HeroBrowser(viewModules: list, index: 0, heroImageView: cell?.imgView)
            brower.heroBrowserDidLongPressHandle = {(browser,vm)in
                self.longPressHandle(vm: vm)
            }
            brower.show(with: self.controller, animationType: .hero)
        }
        return cell ?? ForumCommentReplyListCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if isShowSkeleton { return nil } // 骨架时不渲染 header，避免空白/横线
        let model = dataSourceArray[section]

//        if let cache = sectionHeaders[section],
//           cache.modelId == model.commentModel.id {
////            cache.view.updateUI(model: model.commentModel)
//            return cache.view
//        }
        let vm: ForumCommentListHeadVM
        if let cache = sectionHeaders[section] {
            vm = cache
            vm.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: model.commentModel.contentHeight)
            vm.updateUI(model: model.commentModel)
        } else {
            vm = ForumCommentListHeadVM(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: model.commentModel.contentHeight))
            vm.updateUI(model: model.commentModel)
            sectionHeaders[section] = vm
        }

        vm.lineView.isHidden = (section == 0)
//        let vm = ForumCommentListHeadVM(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: model.commentModel.contentHeight))
//        vm.updateUI(model: model.commentModel)
//        if section == 0 { vm.lineView.isHidden = true }
//
//        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
//            self.sectionHeaders[section] = (model.commentModel.id,vm)
//        }

        if self.isFromNewsVC && isHightlghted == false && newsCommentId.count > 0 && commentId.count > 0 {
            if newsCommentId == model.commentModel.id && section == 0{
                self.isHightlghted = true
                if self.scrollToOffsetY != nil { self.scrollToOffsetY!(vm.frame) }
                DispatchQueue.main.asyncAfter(deadline: .now()+1) { vm.showSelectAction() }
            }
        }

        vm.longPressBlock = {[weak self]in
            if model.commentModel.headImgUrl == "" { return }
            guard let self  = self else { return }
            self.replyIndexPath = IndexPath(row: 0, section: section)
            self.longPressForCommentAction(model: model.commentModel)
        }
        vm.tapBlock = {[weak self]in
            if model.commentModel.headImgUrl == "" { return }
            guard let self  = self else { return }
            if self.tapBlock != nil{
                self.replyIndexPath = IndexPath(row: 0, section: section)
                self.tapBlock!(model.commentModel)
            }
        }
        vm.thumbBlock = {[weak self]in
            guard let self  = self else { return }
            self.sendThumbsUpRequest(coModel: model.commentModel,section: section)
        }
        vm.imgTapBlock = {(img)in
            var list: [HeroBrowserViewModule] = []
            list.append(HeroBrowserLocalImageViewModule(image: img))
            let brower = HeroBrowser(viewModules: list, index: 0, heroImageView: vm.imgView)
            brower.heroBrowserDidLongPressHandle = {(browser,vm)in
                self.longPressHandle(vm: vm)
            }
            brower.show(with: self.controller, animationType: .hero)
        }

        return vm
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isShowSkeleton { return kFitWidth(80) }   // 骨架时隐藏 header
        let model = dataSourceArray[section]
        if model.commentModel.headImgUrl.count > 0 {
            return model.commentModel.contentHeight
        }else{
            return kFitWidth(140)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isShowSkeleton { return nil } // 骨架时隐藏 footer
        let model = dataSourceArray[section]
        if model.commentModel.replyCountSurplus.intValue > 0 {
            let vi = ForumCommentListFootVM(frame: .zero)
            vi.contentLabel.text = "展开 \(model.commentModel.replyCountSurplus) 条回复"
            if !hasMoreData && section == self.dataSourceArray.count-1 {
                vi.lineView.isHidden = true
            }
            vi.tapBlock = {()in
                self.sendReplyListRequest(coListModel: model,section: section,vm: vi)
            }
            self.sectionFootVms[section] = vi
            return vi
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isShowSkeleton { return 0 }
        let model = dataSourceArray[section]
        if model.commentModel.replyCountSurplus.intValue > 0 { return kFitWidth(46) }
        return kFitWidth(0)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isShowSkeleton { return }
        let model = self.dataSourceArray[indexPath.section]
        if self.tapReplyBlock != nil{
            self.replyIndexPath = indexPath
            let models = model.replyModels
            self.tapReplyBlock!(models[indexPath.row])
        }
    }

    // 行高：骨架时给一块“卡片高度”
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isShowSkeleton { return kFitWidth(80) }
        return UITableView.automaticDimension
    }
}

extension ForumCommentListVM{
    func sendCommentListRequest() {
        let param = ["id":"\(model.id)",
                     "commentPage":"\(commentPageNum)",
                     "commentPageSize":"\(commentPageSize)",
                     "commentDeadline":"\(commentDeadline)",
                     "replyPage":"\(replyPageNum)",
                     "replyPageSize":"\(replyPageSize)",
                     "replyDeadline":"\(replyDeadline)"]
        DLLog(message: "sendCommentListRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_comment_list, parameters: param as [String: AnyObject]) { responseObject in
            self.isLoadinData = false
            self.isShowSkeleton = false
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCommentListRequest:\(dataArray)")

            if dataArray.count < self.commentPageSize {
                self.hasMoreData = false
                self.loadMoreDataBlock?(false)
            }else{
                self.loadMoreDataBlock?(true)
            }

//            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.dealDataSource(dataArray: dataArray)
//            })
            
        }
    }

    func sendCommentSetTopRequest(commentId:String,isTop:Bool) {
        let param = ["id":commentId,"top":"\(isTop ? 1 : 0)"]
        DLLog(message: "sendCommentSetTopRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_comment_set_top, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "sendCommentSetTopRequest:\(responseObject)")
            self.commentPageNum = 1
            let cellFrame = self.tableView.rectForHeader(inSection: self.replyIndexPath.section)
            self.sendCommentListRequest()
            if self.setTopOffsetY != nil{
                self.setTopOffsetY!(CGRect(x: 0, y: self.labelHeight, width: cellFrame.width, height: cellFrame.height))
            }
        }
    }

    func sendCommentListRequest(commentId:String,replyId:String) {
        var param = ["commentId":commentId,"replyId":replyId]
        if commentId.count > 0 { param = ["commentId":commentId] }
        else if replyId.count > 0 { param = ["replyId":replyId] }

        DLLog(message: "sendCommentListRequest: \(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_comment_list_push, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCommentListRequest:\(dataArray)")

            self.dealDataSource(dataArray: dataArray,needRefresh:false)

            if self.dataSourceArray.count > 0 {
                let model = self.dataSourceArray[0]
                self.newsCommentId = model.commentModel.id
                for replyMo in model.replyModels { self.newsReplyIds.append(replyMo.id) }
            }else{
                JFPopupView.popup.toast(hit: "原评论已删除")
            }

            self.commentPageNum = 1
            self.replyDeadline = ""
            self.commentDeadline = ""
            self.sendCommentListRequest()
        }
    }

    func sendReplyListRequest(coListModel:ForumCommentListModel,section: Int,vm:ForumCommentListFootVM) {
        let param = ["id":"\(coListModel.commentModel.id)",
                     "replyPage":"\(coListModel.commentModel.replyPage)",
                     "replyPageSize":"\(coListModel.commentModel.replyPageSize)",
                     "replyDeadline":"\(replyDeadline)"]
        DLLog(message: "sendReplyListRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_reply_list, parameters: param as [String: AnyObject]) { responseObject in
            DLLog(message: "sendReplyListRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendReplyListRequest:\(dataArray)")
            self.dealReplyDataArray(dataArr: dataArray, section: section)
            vm.showLoadingSpinner(isShow: false)
        }
    }

    @objc func sendThumbsUpRequest(coModel:ForumCommentModel,section:Int) {
        if coModel.upvote == .refuse { TouchGenerator.shared.touchGenerator() }
        let upvote = coModel.upvote == .pass ? "0" : "1"
        let param = ["id":"\(coModel.id)","bizType":"2","like":"\(upvote)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_thumb, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            if dataString == "1"{
                coModel.upvote = .pass
                if coModel.upvoteCount.intValue > 0 { coModel.upvoteCount = "\(coModel.upvoteCount.intValue + 1)" }
                else { coModel.upvoteCount = "1" }
            }else{
                coModel.upvote = .refuse
                coModel.upvoteCount = "\(coModel.upvoteCount.intValue - 1)"
            }
            let modelT = self.dataSourceArray[section]
            modelT.commentModel = coModel
            self.dataSourceArray[section] = modelT
            self.tableView.reloadData()
        }
    }

    @objc func sendThumbsUpReplyRequest(reModel:ForumCommentReplyModel) {
        if reModel.upvote == .refuse { TouchGenerator.shared.touchGenerator() }
        let upvote = reModel.upvote == .pass ? "0" : "1"
        let param = ["id":"\(reModel.id)","bizType":"3","like":"\(upvote)"]

        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_thumb, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            if dataString == "1"{
                reModel.upvote = .pass
                if reModel.upvoteCount.intValue > 0 { reModel.upvoteCount = "\(reModel.upvoteCount.intValue + 1)" }
                else { reModel.upvoteCount = "1" }
            }else{
                reModel.upvote = .refuse
                reModel.upvoteCount = "\(reModel.upvoteCount.intValue - 1)"
            }
            let model = self.dataSourceArray[self.replyIndexPath.section]
            var models = model.replyModels
            models[self.replyIndexPath.row] = reModel
            model.replyModels = models
            self.dataSourceArray[self.replyIndexPath.section] = model

            let cell = self.tableView.cellForRow(at: self.replyIndexPath) as? ForumCommentReplyListCell
            cell?.updateThumbButton(model: reModel)
        }
    }
}
