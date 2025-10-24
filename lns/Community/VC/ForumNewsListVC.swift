//
//  ForumNewsListVC.swift
//  lns
//
//  Created by Elavatine on 2025/1/8.
//

import MJRefresh
import MCToast
import IQKeyboardManagerSwift

class ForumNewsListVC: WHBaseViewVC {
    
    var pageNum = 1
    var pageSize = 30
    var deadline = ""
    var isLoadingData = true
    var isLoadingMoreData = true
    
    var dataSourceArray:[ForumCommentNewsModel] = [ForumCommentNewsModel]()
    var isDisplayArray:[Int] = [Int]()
    
    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.sendNewsListRequest()
//        })
    }
    
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()), style: .plain)
        vi.delegate = self
        vi.dataSource = self
//        vi.prefetchDataSource = self
        vi.separatorStyle = .none
        vi.isUserInteractionEnabled = true
        vi.showsVerticalScrollIndicator = false
//        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .white//WHColor_16(colorStr: "FAFAFA")
        vi.register(ForumNewsListCell.classForCoder(), forCellReuseIdentifier: "ForumNewsListCell")
        vi.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
            if self.isLoadingMoreData {
                return
            }
            self.pageNum += 1
            self.sendNewsListRequest()
        })
        return vi
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
//        vi.backgroundColor = .THEME
        vi.noDataLabel.text = "- 暂无消息 -"
//        vi.noDataLabel.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        return vi
    }()
    lazy var commomAlertVm: ForumCommentAlertVM = {
        let vm = ForumCommentAlertVM.init(frame: .zero)
        vm.controller = self
        vm.inputBlock = {()in
//            self.bottomFuncVm.textField.textField.text = self.commomAlertVm.textView.text
        }
        vm.commonBlock = {()in
            self.sendCommentReplyRequest(commentId: self.commomAlertVm.reModel.commentId, parentId: self.commomAlertVm.reModel.parentId,postId: self.commomAlertVm.reModel.postId)
        }
        return vm
    }()
}

extension ForumNewsListVC{
    func initUI() {
        initNavi(titleStr: "消息通知")
        view.addSubview(tableView)
        tableView.addSubview(noDataView)
//        tableView.prefetchDataSource = self
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: self.tableView.frame.height*0.5)
        
        view.addSubview(self.commomAlertVm)
        
        tableView.isUserInteractionEnabled = true
        initSkeletonData()
    }
    func initSkeletonData() {
        dataSourceArray.append(ForumCommentNewsModel())
        dataSourceArray.append(ForumCommentNewsModel())
        dataSourceArray.append(ForumCommentNewsModel())
        dataSourceArray.append(ForumCommentNewsModel())
        dataSourceArray.append(ForumCommentNewsModel())
        dataSourceArray.append(ForumCommentNewsModel())
        tableView.reloadData()
    }
}

extension ForumNewsListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DLLog(message: "ForumNewsListVC numberOfRowsInSection:\(dataSourceArray.count)")
        noDataView.isHidden = dataSourceArray.count > 0 ? true : false
        
        return self.dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataSourceArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumNewsListCell") as? ForumNewsListCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumNewsListCell\(model.id)") as? ForumNewsListCell
        
        cell?.updateUI(model: model)
        cell?.likeBlock = {()in
            if model.like == .refuse{

            }
            self.sendThumbsUpRequest(model: model, indexPath: indexPath)
        }
        cell?.replyBlock = {()in
            if model.type == .comment || model.type == .reply{
                let replyModel = ForumCommentReplyModel()
                replyModel.parentId = model.replyId
                replyModel.commentId = model.commentId
                replyModel.postId = model.postId
                self.commomAlertVm.reModel = replyModel
                self.commomAlertVm.showView()
            }
        }
        
        return cell ?? ForumNewsListCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isLoadingData ? kFitWidth(160) : tableView.estimatedRowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataSourceArray[indexPath.row]
        if model.type == .report || isLoadingData{
            return
        }
        if UserConfigModel.shared.canPushForumDetail == false{
            return
        }
        UserConfigModel.shared.canPushForumDetail = false
        if model.postType == .customer{
            let forumModel = ForumModel()
            forumModel.id = model.postId
            forumModel.title = model.postTitle
            forumModel.coverType = model.coverType
            forumModel.contentType = model.contentType
            forumModel.poster = .customer
            forumModel.contentHeight = kFitWidth(150)
//            forumModel.coverImg = model.coverImg
            forumModel.contentHeight = model.contentHeight
            forumModel.contentWidth = model.contentWidth
            forumModel.videoUrl = model.videoUrl
            forumModel.coverImgWidth = model.coverImgWidth
            forumModel.coverImgHeight = model.coverImgHeight
            
            let vc = ForumOfficialDetailVC()
            vc.model = forumModel
            vc.playIsPlay = false
            vc.isFromNewsList = true
            if model.isDelete == false{
                if model.type == .comment{
                    vc.commentId = model.commentId
                }else if model.type == .reply{
                    vc.replyId = model.replyId
                }else if model.type == .like{
                    if model.replyId.count > 0 {
                        vc.replyId = model.replyId
                    }else if model.commentId.count > 0{
                        vc.commentId = model.commentId
                    }
                }
            }else{
                vc.commentDeleteString = model.content
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = ForumDetailVC()
            vc.model.id = model.postId
            if model.isDelete == false{
                if model.type == .comment{
                    vc.commentId = model.commentId
                }else if model.type == .reply{
                    vc.replyId = model.replyId
                }else if model.type == .like{
                    if model.replyId.count > 0 {
                        vc.replyId = model.replyId
                    }else if model.commentId.count > 0{
                        vc.commentId = model.commentId
                    }
                }
            }else{
                vc.commentDeleteString = model.content
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
       
//        self.sendCommentListRequest(model: model)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let model = self.dataSourceArray[indexPath.row]
            self.sendDeleteMsgRequest(ids: model.id, indexPath: indexPath)
//            let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
//            self.sendDeleteDataRequest(dict: dict)
//            sendDeleteMsgRequest
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.isDisplayArray.count > indexPath.row{
            let isDisplay = self.isDisplayArray[indexPath.row]
            if isDisplay == 0 {
                cell.alpha = 0
                self.isDisplayArray[indexPath.row] = 1
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
                    cell.alpha = 1
                    cell.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        // 当滑动到底部20%以内，且不是正在加载的时候，自动加载
        if offsetY > contentHeight - screenHeight * 1.2 && !tableView.mj_footer!.isRefreshing {
            if !self.isLoadingMoreData {
                self.pageNum += 1
                self.sendNewsListRequest()
            }
        }
    }
}
extension ForumNewsListVC{
    func sendNewsListRequest() {
        isLoadingMoreData = true
        let param = ["page":"\(pageNum)",
                     "pageSize":"\(pageSize)",
                     "deadline":"\(deadline)"]
        DLLog(message: "sendNewsListRequest param:\(param)")
        
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_msg_list, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendNewsListRequest:\(dataArray)")
            self.tableView.mj_footer!.endRefreshing()
            
            // 提示没有更多数据
            if dataArray.count < self.pageSize {
                self.tableView.mj_footer!.endRefreshingWithNoMoreData()
            }

            if self.pageNum == 1{
                self.dataSourceArray.removeAll()
                self.isDisplayArray.removeAll()
            }
            
            self.dealDataSource(dataArr: dataArray)
        }
    }
    func sendDeleteMsgRequest(ids:String,indexPath:IndexPath) {
        let param = ["ids":[ids]]
        DLLog(message: "sendDeleteMsgRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_msg_delete, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            self.dataSourceArray.remove(at: indexPath.row)
            self.isDisplayArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func sendCommentListRequest(model:ForumCommentNewsModel) {
        var param = ["commentId":model.commentId]
        if model.type == .comment{
            param = ["commentId":model.commentId]
        }else if model.type == .reply{
            param = ["replyId":model.replyId]
        }else if model.type == .like{
            if model.replyId.count > 0 {
                param = ["replyId":model.replyId]
            }else if model.commentId.count > 0{
                param = ["commentId":model.commentId]
            }
        }
        DLLog(message: "sendCommentListRequest: \(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_comment_list_push, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendCommentListRequest:\(dataArray)")
        }
    }
    func sendThumbsUpRequest(model:ForumCommentNewsModel,indexPath:IndexPath) {
        let upvote = model.like == .pass ? "0" : "1"
        var bizType = ""
        var id = ""
        switch model.type{
        case .comment:
            bizType = "2"
            id = model.commentId
        case .reply:
            bizType = "3"
            id = model.replyId
        case .like:
            return
        case .report:
            return
        case .follow:
            return
        }
        let param = ["id":"\(id)",
                     "bizType":"\(bizType)",
                     "like":"\(upvote)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_thumb, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendThumbsUpRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
//            let dataString = responseObject["data"]as? Int ?? 0
            DLLog(message: "sendThumbsUpRequest:\(dataString ?? "")")
            if dataString == "1"{
                model.like = .pass
            }else{
                model.like = .refuse
            }
            
            if self.dataSourceArray.count > indexPath.row{
                let cell = self.tableView.cellForRow(at: indexPath) as? ForumNewsListCell
                cell?.updateThumbsUpStatu(model: model)
//                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    func sendCommentReplyRequest(commentId:String,parentId:String,postId:String) {
        let imgString = self.commomAlertVm.commonImgUrl.count > 0 ? self.getJSONStringFromArray(array: [self.commomAlertVm.commonImgUrl])
                                                                    : ""
        
        var param = ["id":"\(postId)",
                     "commentId":"\(commentId)",
//                     "parentId":"\(parentId)",
                     "content":"\(self.commomAlertVm.textView.text ?? "")",
                     "image":imgString]
       
        if parentId.count > 0 {
            param.updateValue("\(parentId)", forKey: parentId)
        }
        DLLog(message: "sendCommentReplyRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_reply_add, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendCommentReplyRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCommentReplyRequest:\(dataObj)")
            
            self.commomAlertVm.clearMSg()
            MCToast.mc_text("你的评论已发布",duration: 1.0,respond: .allow)
        }
    }
}

extension ForumNewsListVC{
    func dealDataSource(dataArr:NSArray) {
        for i in 0..<dataArr.count{
            let dict = dataArr[i]as? NSDictionary ?? [:]
            if i == 0 && self.deadline == ""{
                self.deadline = dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " ")
            }
            let model = ForumCommentNewsModel().dealModelWithDict(dict: dict)
            if model.type != .follow{
                self.dataSourceArray.append(model)
                self.isDisplayArray.append(0)
//                self.tableView.register(ForumNewsListCell.classForCoder(), forCellReuseIdentifier: "ForumNewsListCell\(dict.stringValueForKey(key: "id"))")
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            self.isLoadingData = false
            self.isLoadingMoreData = false
        if self.dataSourceArray.count == 0{
            self.tableView.mj_footer?.isHidden = true
        }
        
            self.tableView.reloadData()
//        })
    }
}
