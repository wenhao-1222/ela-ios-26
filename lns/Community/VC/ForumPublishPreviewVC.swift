//
//  ForumPublishPreviewVC.swift
//  lns
//  帖子预览
//  Created by Elavatine on 2024/12/20.
//

import MCToast
import Photos

class ForumPublishPreviewVC: WHBaseViewVC {
    
    // 创建 PHCachingImageManager 实例
//    let imageManager = PHCachingImageManager.default()
//    let option = PHImageRequestOptions.init()
//    
//    var photoAssets:[PHAsset] = [PHAsset]()
    var imagesForUpload:[UIImage] = [UIImage]()
    
    var model = ForumModel()
    var thumbBlock:((ForumModel)->())?
    
    var group = DispatchGroup()
    var bannerHeight = kFitWidth(0)
    
    var pollSelectCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        option.resizeMode = .exact
//        option.deliveryMode = .highQualityFormat
//        option.isSynchronous = true
        
        initUI()
    }
    lazy var naviVm: ForumNaviVM = {
        let vm = ForumNaviVM.init(frame: .zero)
        vm.updateUI(model: self.model)
        vm.backArrowButton.tapBlock = {()in
            self.backTapAction()
        }
        vm.shareBlock = {()in
            MCToast.mc_text("预览模式无法操作",respond: .allow)
        }
        return vm
    }()
    lazy var tableView: ForumCommentListTableView = {
        let vm = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()-kFitWidth(56)-WHUtils().getBottomSafeAreaHeight()), style: .grouped)
        vm.delegate = self
        vm.dataSource = self
        vm.backgroundColor = .white
        vm.separatorStyle = .none
        vm.register(ForumOfficialTextCell.classForCoder(), forCellReuseIdentifier: "ForumOfficialTextCell")
        vm.register(ForumOfficialPollCell.classForCoder(), forCellReuseIdentifier: "ForumOfficialPollCell")
        if #available(iOS 15.0, *) {
            vm.sectionHeaderTopPadding = 0
        }
        vm.reloadCompletion = {()in
            let size = self.tableView.contentSize
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: size.height)
            self.scrollViewBase.contentSize = CGSize.init(width: 0, height: size.height)
        }
        return vm
    }()
//    lazy var bannerVm: BannerVM = {
//        let vm = BannerVM.init(frame: CGRect.init(x: 0, y: naviVm.frame.maxY, width: SCREEN_WIDHT, height: bannerHeight))
////        vm.setDataSource(dataSourceArr: self.model.imgsContent as NSArray)
//        vm.setDataSourcePreview(dataSourceArr: self.imagesForUpload)
////        photoAssets
//        return vm
//    }()
    lazy var bannerImgVm: ForumOfficialImgsVM = {
        let vm = ForumOfficialImgsVM.init(frame: CGRect.init(x: 0, y: naviVm.frame.maxY, width: SCREEN_WIDHT, height: bannerHeight))
        vm.setDataSourcePreview(dataSourceArr: self.imagesForUpload)
        return vm
    }()
    lazy var videoVm: ForumOfficialVideoVM = {
        let vm = ForumOfficialVideoVM.init(frame: .zero)
        vm.backgroundColor = .clear
        vm.controller = self
        vm.updateUIForForumDetail(model: model)
        vm.controlView.resetViewForPreview()
        
        vm.playBlock = {()in
            self.backArrowButton.isHidden = true
            self.videoVm.play()
        }
        vm.heightChanged = {(videoHeight)in
            self.videoVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: videoHeight)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        return vm
    }()
    lazy var pollHeadVm: ForumPollTableHeadVM = {
        let vm = ForumPollTableHeadVM.init(frame: .zero)
        if model.pollModel.optionThreshold == 1{
            vm.titleLab.text = "投票选项（单选）"
        }else{
            vm.titleLab.text = "投票选项（最多选择\(model.pollModel.optionThreshold)项）"
        }
//        vm.submitButton.addTarget(self, action: #selector(submitPollMultipleAction), for: .touchUpInside)
        return vm
    }()
    lazy var pollFootVm: ForumPollTableFootVM = {
        let vm = ForumPollTableFootVM.init(frame: .zero)
        if model.pollModel.optionThreshold <= 1{
            vm.selfHeight = kFitWidth(40)
        }
        vm.submitButton.addTarget(self, action: #selector(submitPollMultipleAction), for: .touchUpInside)
        return vm
    }()
    lazy var bottomFuncVm: ForumCommentVM = {
        let vm = ForumCommentVM.init(frame: .zero)
        vm.textField.tapBlock = {()in
//            self.commentListVm.replyIndexPath = IndexPath()
            self.showCommentAlertVm(coModel: ForumCommentModel(), reModle: ForumCommentReplyModel())
        }
        vm.thumbUpTapBlock = {()in
            MCToast.mc_text("预览模式无法操作",respond: .allow)
        }
        vm.commomTapBlock = {()in
            MCToast.mc_text("预览模式无法操作",respond: .allow)
        }
        return vm
    }()
}

extension ForumPublishPreviewVC{
    func updateThumbStatus() {
        if model.upvoteCount.intValue > 0 {
            bottomFuncVm.thumbsUpButton.setTitle("\(model.upvoteCount)", for: .normal)
        }else{
            bottomFuncVm.thumbsUpButton.setTitle("点赞", for: .normal)
        }
        if model.upvote == .pass{
            bottomFuncVm.thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_highlight"), for: .normal)
            bottomFuncVm.thumbsUpButton.setTitleColor(WHColor_16(colorStr: "F5BA18"), for: .normal)
        }else{
            bottomFuncVm.thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
            bottomFuncVm.thumbsUpButton.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        }
        bottomFuncVm.thumbsUpButton.imagePosition(style: .top, spacing: kFitWidth(3))
    }
    func updateCommentCount() {
        if model.commentCount.count > 0 && model.commentCount.intValue > 0{
            bottomFuncVm.commonButton.setTitle("\(model.commentCount)", for: .normal)
        }else{
            bottomFuncVm.commonButton.setTitle("评论", for: .normal)
        }
        bottomFuncVm.commonButton.imagePosition(style: .top, spacing: kFitWidth(3))
    }
    func showCommentAlertVm(coModel:ForumCommentModel,reModle:ForumCommentReplyModel) {
        MCToast.mc_text("预览模式无法操作",respond: .allow)
    }
    @objc func submitPollMultipleAction() {
        MCToast.mc_text("预览模式无法操作",respond: .allow)
    }
}

extension ForumPublishPreviewVC:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.type == .poll ? 2 : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            var rowsNum = 0
            if model.title.count > 0 {
                rowsNum += 1
            }
            if model.content.count > 0 {
                rowsNum += 1
            }
            return rowsNum//model.content.count > 0 ? 2 : 1
        }else{
            return model.pollModel.pollArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForumOfficialTextCell") as? ForumOfficialTextCell
            
            if indexPath.row == 0 {
                if model.title.count > 0 {
                    cell?.updateContent(text: self.model.title)
                }else{
                    cell?.updateContentText(text: self.model.content)
                }
            }else{
                cell?.updateContentText(text: self.model.content)
            }
            
            return cell ?? PublishPollItemCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForumOfficialPollCell") as? ForumOfficialPollCell
            let pollItemmodel = model.pollModel.pollArray[indexPath.row]
            cell?.updateUIForPreview(model: pollItemmodel, index: indexPath.row, hasImage: model.pollModel.hasImage == .pass)
//            if model.pollModel.showResult == .pass && model.forumPostPollModel.isPoll {
//                cell?.updatePercent(model: model.pollResultModel, hasImage: model.pollModel.hasImage == .pass)
//                cell?.updateSelfChoice(model: model.forumPostPollModel)
//            }
            return cell ?? PublishPollItemCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if self.model.forumPostPollModel.isPoll == false{
                if self.model.pollModel.pollType == .multiple{
                    let pollItemmodel = model.pollModel.pollArray[indexPath.row]
                    if self.pollSelectCount >= self.model.pollModel.optionThreshold && pollItemmodel.isSelect == false{
                        MCToast.mc_text("最多选择 \(self.model.pollModel.optionThreshold) 项",respond: .allow)
                    }else{
                        pollItemmodel.isSelect = !pollItemmodel.isSelect
                        
                        if pollItemmodel.isSelect {
                            self.pollSelectCount += 1
                        }else{
                            self.pollSelectCount -= 1
                        }
                        
                        let cell = self.tableView.cellForRow(at: indexPath) as? ForumOfficialPollCell
                        cell?.updateMultipleSelectStatus(isSelect: pollItemmodel.isSelect)
                        
                        if self.pollSelectCount > 0 {
                            self.pollFootVm.submitButton.isEnabled = true
                        }else{
                            self.pollFootVm.submitButton.isEnabled = false
                        }
                    }
                }else{
                    MCToast.mc_text("预览模式无法操作",respond: .allow)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.estimatedRowHeight
        }else{
            if model.pollModel.hasImage == .pass{
                return kFitWidth(74)
            }else{
                return kFitWidth(48)
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if self.model.contentType == .VIDEO{
                return videoVm
            }else{
                return bannerImgVm
            }
//            return bannerVm
        }else {
            return pollHeadVm
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.model.contentType == .VIDEO{
                return videoVm.selfHeight
            }else{
                return bannerHeight
            }
//            return bannerHeight
        }else {
            return pollHeadVm.selfHeight
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if model.type == .poll{
            if section == 0 {
                return nil
            }else {
//                if self.model.pollResultModel.participants > 0 {
//                    pollFootVm.leftTipsLabel.isHidden = true
//                    pollFootVm.numberLabel.text = "\(self.model.pollResultModel.participants) 人参与"
//                }else{
//                    pollFootVm.leftTipsLabel.isHidden = false
//                    pollFootVm.numberLabel.text = ""
//                }
                return pollFootVm
            }
        }else{
            return nil
        }
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if model.type == .poll{
            if section == 0 {
                return 0
            }else {
                return pollFootVm.selfHeight
            }
        }else{
            return 0
        }
    }
}
extension ForumPublishPreviewVC{
    func initUI() {
        view.addSubview(naviVm)
        view.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-naviVm.selfHeight-bottomFuncVm.selfHeight)
        
        group = DispatchGroup()
        group.enter()
        getImgSize()
        
        group.notify(queue: .main) {
            self.scrollViewBase.addSubview(self.tableView)
            self.view.addSubview(self.bottomFuncVm)
        }
    }
}

extension ForumPublishPreviewVC{
    func getImgSize() {
        if imagesForUpload.count > 0 {
            let image = imagesForUpload[0]
            let imgOriSize = image.size
            let imgOriginH = SCREEN_WIDHT * (imgOriSize.height)/(imgOriSize.width)
            if imgOriginH > SCREEN_WIDHT*1.2{
                self.bannerHeight = SCREEN_WIDHT*1.2
            }else{
                self.bannerHeight = imgOriginH
            }
            self.group.leave()
        }else{
            group.leave()
        }
    }
}

