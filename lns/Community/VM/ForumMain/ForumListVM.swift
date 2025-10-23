//
//  ForumListVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/1.
//

import MJRefresh

class ForumListVM : UIView{
    
    var selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-WHUtils().getTabbarHeight()
    var centerY = kFitWidth(0)
    var controller = WHBaseViewVC()
    var dataSourceArray:[ForumModel] = [ForumModel]()
    var dataSourceArrayTemp:[ForumModel] = [ForumModel]()
    var insertRows:[IndexPath] = [IndexPath]()
    var currentVideoModel = ForumModel()
    
    var pageNum = 1
    var pageSize = 10
    var lastRequestIndex = 0
    var isFirstLoad = true
    
    var impressionArray:[String] = [String]()
    var urls = NSMutableArray()
    
    var tapTableViewCell = ForumListTableViewCell()
    let zoomAnimator = ZoomAnimator()
    /**
     *  进入下个控制器前保存当前NSIndexPath
     *
     *  @NSIndexPath
     */
    var tapIndexPath = -1
    var readyPlayIndex = NSInteger(0)
    
    let autFooter = MJRefreshAutoFooter()
    
    var isScrolling = false
    var isRefreshHead = false
//    static var requestPageNum = 1
    
    var scrollOffBlock:((CGFloat)->())?
    
    var noticeDispatchGroup = DispatchGroup()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        if #available(iOS 26.0, *) {
            selfHeight = SCREEN_HEIGHT//-WHUtils().getNavigationBarHeight()
        }
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        
        self.noticeDispatchGroup = DispatchGroup()
        
        initData()
        initUI()
//        sendNoticeListRequest()
        self.centerY = WHUtils().getNavigationBarHeight() + selfHeight*0.5
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresVideoView(notify: )), name: NSNotification.Name(rawValue: "forumListVideoGetFirstFrame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUploadAlertVm), name: NSNotification.Name(rawValue: "uploadForumThreadStart"), object: nil)
        
//        self.noticeDispatchGroup.enter()
        
        noticeDispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    lazy var publishAlertVm: ForumPublishAlertVM = {
        let vm = ForumPublishAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var tableView: ForumCommentListTableView = {
//        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight-kFitWidth(1)))
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight-kFitWidth(1)), style: .grouped)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .white//WHColor_16(colorStr: "FAFAFA")
        vi.register(ForumListTableViewCell.classForCoder(), forCellReuseIdentifier: "ForumListTableViewCell")
        vi.mj_header = CustomRefreshHeader.init(refreshingBlock: {
            // 如果当前有正在播放，则停止并清除 IndexPath
//            ZFPlayerModel.shared.playerManager.pause()
//            ZFPlayerModel.shared.player.stopCurrentPlayingCell()
            self.pageNum = 1
            self.footVm.resetStatus()
//            ForumListVM.requestPageNum = 1
            self.dataSourceArrayTemp.removeAll()
//            self.pageSize = 10
            self.lastRequestIndex = 0
            self.isRefreshHead = true
//            self.noticeDispatchGroup = DispatchGroup()
            self.noticeDispatchGroup.enter()
            self.sendNoticeListRequest()
            self.sendDataListRequest()
        })
//        vi.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
//
//        })
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
//            UITableView.appearance().isPrefetchingEnabled = false
        }
//        if #available(iOS 26.0, *) {
//            vi.mj_header?.ignoredScrollViewContentInsetTop = WHUtils().getNavigationBarHeight()
//        }
        if #available(iOS 26.0, *) {
            let navigationHeight = WHUtils().getNavigationBarHeight()
            var inset = vi.contentInset
            if inset.top < navigationHeight {
                inset.top = navigationHeight
            }
            vi.contentInset = inset
            var indicatorInset = vi.scrollIndicatorInsets
            if indicatorInset.top < navigationHeight {
                indicatorInset.top = navigationHeight
            }
            vi.scrollIndicatorInsets = indicatorInset
            if vi.contentOffset.y == 0 {
                vi.setContentOffset(CGPoint(x: 0, y: -navigationHeight), animated: false)
            }
        }
        vi.reloadCompletion = {()in
//            self.tableView.zf_filterShouldPlayCellWhileScrolling()
        }
        return vi
    }()
    lazy var headNoticeVm: ForumNoticeVM = {
        let vm = ForumNoticeVM.init(frame: .zero)
        vm.noticeTapBlock = {(forumModel)in
            UserDefaults.setNoticeTapId(idT: forumModel.id)
            self.pushToDetailForNotice(model: forumModel)
        }
        return vm
    }()
    lazy var footVm: ForumListFooterVM = {
        let vm = ForumListFooterVM()
        return vm
    }()
    lazy var controlView: ForumListVideoControlView = {
        let vi = ForumListVideoControlView()
        vi.backgroundColor = .clear
        vi.bgImgView.backgroundColor = .clear
//        vi.autoHiddenTimeInterval = 1200
        vi.fastViewAnimated = true
        vi.prepareShowControlView = true
        vi.portraitControlView.isHidden = true
        vi.landScapeControlView.isHidden = true
        vi.effectViewShow = false
        vi.tapClickCallback = {()in
            DLLog(message: "tapClickCallback")
            let vc = ForumOfficialDetailVC()
            vc.model = self.currentVideoModel
            vc.sendForumDetailRequest()
//            vc.currentSeekTime = Int(self.player.currentTime)
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        vi.mutedCallback = {()in
//            self.refreshMutedStatus()
        }
        return vi
    }()
    lazy var shareAlertVm: ForumShareVM = {
        let vm = ForumShareVM.init(frame: .zero)
        vm.updateForShare()
        return vm
    }()
}

extension ForumListVM{
    func autoLoadData() {
        if isFirstLoad {
            isFirstLoad = false
            self.tableView.mj_header?.beginRefreshingWithoutAnimation()
        }
    }
    func showSelf() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.centerY)
        }
    }
    func hiddenSelf() {
//        ZFPlayerModel.shared.player.stopCurrentPlayingCell()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: self.centerY)
        }
    }
    func pushToDetailForNotice(model:ForumModel) {
        if model.poster == .platform{
//            ZFPlayerModel.shared.playerManager.pause()
            let vc = ForumDetailVC()
            vc.model = model
            self.tapIndexPath = -1
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = ForumOfficialDetailVC()
            vc.model = model
            vc.playIsPlay = false
            self.tapIndexPath = -1
            self.controller.navigationController?.pushViewController(vc, animated: true)
            vc.deleteBlock = {(mo)in
//                UIView.performWithoutAnimation {
//                    self.dataSourceArray.remove(at: indexPath.row)
//                    self.tableView.deleteRows(at: [indexPath], with: .none)
//                }
            }
        }
    }
    func pushToDetail(model:ForumModel,indexPath:IndexPath,isComment:Bool?=false) {
        if UserConfigModel.shared.canPushForumDetail == false{
            return
        }
        UserConfigModel.shared.canPushForumDetail = false
        if model.poster == .platform{
//            ZFPlayerModel.shared.playerManager.pause()
            let vc = ForumDetailVC()
            vc.model = model
            self.tapIndexPath = -1
            vc.isToComment = isComment ?? false
            self.controller.navigationController?.pushViewController(vc, animated: true)
            
            vc.thumbBlock = {(mo)in
                if self.dataSourceArray.count > indexPath.row && mo.id == model.id{
                    let cell = self.tableView.cellForRow(at: indexPath) as? ForumListTableViewCell
                    self.dataSourceArray[indexPath.row] = mo
                    cell?.updateThumbsUpStatu(model: mo)
                }
            }
        }else{
            let vc = ForumOfficialDetailVC()
            vc.model = model
            
//            if model.coverImgHeight > 0 && model.coverImgWidth > 0 {
//                vc.bannerHeight = SCREEN_WIDHT * model.coverImgHeight / model.coverImgWidth
//            }

            vc.isToComment = isComment ?? false
//            var currentCoverImg = UIImage()
            vc.thumbBlock = {(mo)in
                if self.dataSourceArray.count > indexPath.row && mo.id == model.id{
                    let cell = self.tableView.cellForRow(at: indexPath) as? ForumListTableViewCell
                    self.dataSourceArray[indexPath.row] = mo
                    cell?.updateThumbsUpStatu(model: mo)
                }
            }
            vc.deleteBlock = {(mo)in
                if mo.id == model.id{
                    UIView.performWithoutAnimation {
                        self.dataSourceArray.remove(at: indexPath.row)
                        self.dataSourceArrayTemp = self.dataSourceArray
                        self.tableView.deleteRows(at: [indexPath], with: .none)
                    }
                }
            }
            vc.detailBackBlock = {(seekTime,playerManager)in
//                self.controlView.isHidden = false
//                if self.tapIndexPath >= 0{
//                    ZFPlayerModel.shared.playerManager.scalingMode = .aspectFill
//                    ZFPlayerModel.shared.player.controlView = self.controlView
//                    ZFPlayerModel.shared.player.addPlayerViewToCell()
//                    ZFPlayerModel.shared.playerManager.play()
//                }else{
//                    ZFPlayerModel.shared.addToTableView(tableView: self.tableView, tag: playerViewTag)
//                    ZFPlayerModel.shared.player.controlView = self.controlView
//
//                    self.playTheVideoAtIndexPath(indexPath: indexPath, animated: false)
//                }
//                self.zfplayerBlock()
//                self.tapIndexPath = -1
//                self.controlView.mutedImgView.isHidden = false
//                self.controlView.bgImgView.contentMode = .scaleAspectFill
//                self.controlView.coverImageView.contentMode = .scaleAspectFill
            }
            if model.contentType == .VIDEO{
//                self.controlView.bgImgView.contentMode = .scaleAspectFit
//                self.controlView.coverImageView.contentMode = .scaleAspectFit
//                self.controlView.mutedImgView.isHidden = true
//                self.controlView.resetControlView()
//                DLLog(message: "\(ZFPlayerModel.shared.player.playingIndexPath?.row)")
//                if indexPath.row == ZFPlayerModel.shared.player.playingIndexPath?.row{
//                    self.tapIndexPath = indexPath.row
//                    vc.playIsPlay = true
//                    ZFPlayerModel.shared.player.addPlayerView(toContainerView: vc.videoVm)
//                }else{
                    self.tapIndexPath = -1
//                    ZFPlayerModel.shared.playerManager.stop()
//                    self.controlView.isHidden = true
//                    currentCoverImg = self.controlView.coverImageView.image ?? UIImage()
                    vc.playIsPlay = false
//                }
//                ZFPlayerModel.shared.playerManager.scalingMode = .aspectFill
            }else{
                self.tapIndexPath = -1
            }
            self.tapTableViewCell = self.tableView.cellForRow(at: indexPath) as? ForumListTableViewCell ?? ForumListTableViewCell()
//            if model.covers.count > 0 {
//                self.controller.navigationController?.delegate = self
//            }
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func refreshMutedStatus() {
        UserConfigModel.shared.isMuted = !UserConfigModel.shared.isMuted
        if let managerPlayer = ZFPlayerModel.shared.playerManager.player{
            if UserConfigModel.shared.isMuted{
                managerPlayer.volume = 0
            }else{
                managerPlayer.volume = 1.0
            }
        }
        var imgName = "forum_player_mute_yes_icon"
        if !UserConfigModel.shared.isMuted{
            imgName = "forum_player_mute_no_icon"
        }
        self.controlView.mutedImgView.setImgLocal(imgName: imgName)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mutedStatusChanged"), object: nil)
    }
    @objc func showUploadAlertVm() {
        self.publishAlertVm.showView()
    }
}

extension ForumListVM:UITableViewDelegate,UITableViewDataSource{
    func initData() {
        let serialQueue = DispatchQueue(label: "com.forum.list.cachedata")
        var noticeDataArray = [ForumModel]()
        serialQueue.async {
            let cacheDataArray = UserDefaults.getArray(forKey: .forumListData) ?? []
            let noticeSourceArray = UserDefaults.getArray(forKey: .forumNoticeListData) ?? []
            for i in 0..<noticeSourceArray.count{
                let dict = noticeSourceArray[i]as? NSDictionary ?? [:]
                let model = ForumModel().initWithDictCoverInfo(dict: dict)
                noticeDataArray.append(model)
            }
            if cacheDataArray.count > 0 {
                for i in 0..<cacheDataArray.count{
                    let dict = cacheDataArray[i]as? NSDictionary ?? [:]
                    let model = ForumModel().initWithDictCoverInfo(dict: dict)
                    self.dataSourceArray.append(model)
                }
            }else{
//                self.noticeDispatchGroup = DispatchGroup()
                self.noticeDispatchGroup.enter()
                self.sendNoticeListRequest()
                self.sendDataListRequest()
            }
        }
        serialQueue.async {
            if self.dataSourceArray.count > 0 {
                DispatchQueue.main.async(execute: {
                    self.headNoticeVm.updateUI(dataArray: noticeDataArray)
                    self.tableView.reloadData()
                })
            }else{
                DispatchQueue.main.async(execute: {
                    self.headNoticeVm.updateUI(dataArray: noticeDataArray)
                    self.noticeDispatchGroup.enter()
                    self.sendNoticeListRequest()
                    self.sendDataListRequest()
                })
            }
        }
    }
    func zfplayerBlock() {
        ZFPlayerModel.shared.player.zf_filterShouldPlayCellWhileScrolling { indexpath in
            DLLog(message: "player.zf_filterShouldPlayCellWhileScrolling")
            self.playTheVideoAtIndexPath(indexPath: indexpath, animated: false)
        }
        ZFPlayerModel.shared.player.zf_playerShouldPlayInScrollView = {(indexPath)in
//            DLLog(message: "player.zf_playerShouldPlayInScrollView  -- \(ZFPlayerModel.shared.player.playingIndexPath)")
            let string = "\(indexPath)"
            if string.count > 3{
                if indexPath != ZFPlayerModel.shared.player.playingIndexPath{
                    self.playTheVideoAtIndexPath(indexPath: indexPath, animated: false)
                }
            }
        }
        ZFPlayerModel.shared.player.playerDidToEnd = {(asset)in
            DLLog(message: "player.playerDidToEnd")
            ZFPlayerModel.shared.playerManager.replay()
        }
        ZFPlayerModel.shared.player.playerReadyToPlay = {asset ,assetUrl in
            DLLog(message: "player.playerReadyToPlay")
            ZFPlayerModel.shared.player.currentPlayerManager.view.alpha = 0
        }
        ZFPlayerModel.shared.player.playerPlayTimeChanged = {asset,current,total in
            if current > 0.05{
                ZFPlayerModel.shared.player.currentPlayerManager.view.alpha = 1
                if ZFPlayerModel.shared.player.playingIndexPath?.row ?? 0 < 4{
                    ZFPlayerModel.shared.player.addPlayerViewToCell()
                }
            }
        }
    }
    func initUI() {
//        ZFPlayerModel.shared.addToTableView(tableView: self.tableView, tag: playerViewTag)
//        ZFPlayerModel.shared.player.controlView = self.controlView
//        zfplayerBlock()
        self.backgroundColor = .white
        addSubview(tableView)
        
        addSubview(publishAlertVm)
        
        tableView.tableFooterView = footVm
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.getKeyWindow().addSubview(self.shareAlertVm)
        })
    }
    @objc func refresVideoView(notify:Notification) {
        let videoMsg = notify.object as? NSDictionary ?? [:]
        for i in 0..<self.dataSourceArray.count{
            let model = self.dataSourceArray[i]
            
            if model.id == videoMsg["id"]as? String ?? ""{
//                DLLog(message: "forumListVideoGetFirstFrame:\(videoMsg)")
                let contentHeight = videoMsg["contentHeight"]as? CGFloat ?? kFitWidth(0)
//                DLLog(message: "contentHeight:-----*******----- \(contentHeight) --- model.id")
//                DLLog(message: "\(model.title) ----   contentHeight:\(contentHeight)  ---变化前")
                if contentHeight > 0 {
//                    DLLog(message: "\(model.title) ----   \(model.contentHeight)  ---变化前")
                    model.contentHeight = contentHeight
                }
                if let img = videoMsg["coverImg"]as? UIImage{
                    model.coverImg = img
                }
//                videoMsg["contentHeight"]as? CGFloat ?? kFitWidth(180)
//                model.coverImg = videoMsg["coverImg"]as? UIImage ?? UIImage()
                self.dataSourceArray[i] = model
                UIView.performWithoutAnimation {
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//                        self.tableView.beginUpdates()
//                        DLLog(message: "\(model.title) ----   \(model.contentHeight)  ---***")
                        self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
//                        self.tableView.endUpdates()
                    })
                }
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSourceArray.count > indexPath.row{
            let model = self.dataSourceArray[indexPath.row]
            var cell = tableView.dequeueReusableCell(withIdentifier: "ForumListTableViewCell",for: indexPath) as? ForumListTableViewCell
            if cell == nil{
                cell = ForumListTableViewCell.init(style: .default, reuseIdentifier: "ForumListTableViewCell")
            }
//            cell?.updateUI(model: model)
//            if UserConfigModel.shared.isMuted{
//                cell?.mutedImgView.setImgLocal(imgName: "forum_player_mute_yes_icon")
//            }else{
//                cell?.mutedImgView.setImgLocal(imgName: "forum_player_mute_no_icon")
//            }
//            
//            if model.coverType == .VIDEO && model.covers.count > 0{
//                cell?.videoUrlStr = model.covers[0]as? String ?? ""
//            }
            cell?.imgLoadBlock = {(imgSize)in
                model.imgIsLoaded = true
                model.coverImgHeight = imgSize.height
                model.coverImgWidth = imgSize.width
                self.dataSourceArray[indexPath.row] = model
                if model.coverImgHeight < kFitWidth(343){
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                }
            }
            cell?.updateUI(model: model)
            if model.coverType == .VIDEO && model.covers.count > 0{
                cell?.videoUrlStr = model.covers[0]as? String ?? ""
            }
            cell?.thumbTapBlock = {()in
                self.sendThumbsUpRequest(model: model, indexPath: indexPath)
                if model.upvote == .refuse{
                    TouchGenerator.shared.touchGenerator()
                    model.upvote = .pass
                    model.upvoteCount = "\(model.upvoteCount.intValue + 1)"
                }else{
                    model.upvote = .refuse
                    model.upvoteCount = "\(model.upvoteCount.intValue - 1)"
                }
                cell?.updateThumbsUpStatu(model: model)
            }
            cell?.commentTapBlock = {()in
                self.pushToDetail(model: model, indexPath: indexPath,isComment: true)
            }
            cell?.shareTapBlock = {()in
                if model.webLink.count > 0 {
                    self.shareAlertVm.showView(model: model)
                    self.sendCreateShareLink(model: model,isShowShareView: false)
                }else{
                    self.sendCreateShareLink(model: model,isShowShareView: true)
                }
            }
            cell?.imgTapBlock = {()in
                self.pushToDetail(model: model, indexPath: indexPath)
            }
            cell?.videoTapBlock = {()in
                self.pushToDetail(model: model, indexPath: indexPath)
            }
            cell?.mutedTapBlock = {()in
//                self.refreshMutedStatus()
            }
//            cell?.videoLoadBlock = {()in
//                self.tableView.beginUpdates()
//                self.tableView.reloadRows(at: [indexPath], with: .fade)
//                self.tableView.endUpdates()
//            }
            return cell ?? ForumListTableViewCell()
        }else{
            return ForumListTableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataSourceArray[indexPath.row]
        self.pushToDetail(model: model, indexPath: indexPath)
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return tableView.estimatedRowHeight
//    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row != lastRequestIndex {//}&& (indexPath.row == self.dataSourceArrayTemp.count - 7){
            if (self.pageNum == 1 && (indexPath.row == self.dataSourceArrayTemp.count - 2)) || (indexPath.row == self.dataSourceArrayTemp.count - 5){
                lastRequestIndex = indexPath.row
                self.pageNum += 1
                self.sendDataListRequest()
            }
        }
        if indexPath.row < self.dataSourceArray.count - 1{
            let model = self.dataSourceArray[indexPath.row]
            self.sendForumImpressionRequest(model: model)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headNoticeVm.selfHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headNoticeVm
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.dataSourceArray.count != self.dataSourceArrayTemp.count && self.pageNum > 1{
            if self.insertRows.isEmpty {
                // 兜底处理，避免 data 与 tableView 不一致导致闪退
                self.dataSourceArray = self.dataSourceArrayTemp
                self.tableView.reloadData()
                self.isScrolling = false
                return
            }

            let oldOffset = self.tableView.contentOffset
            self.tableView.beginUpdates()
            self.dataSourceArray = self.dataSourceArrayTemp
            self.tableView.insertRows(at: self.insertRows, with: .bottom)
            self.tableView.endUpdates()
            self.tableView.setContentOffset(oldOffset, animated: false)
            self.insertRows.removeAll()
            self.isScrolling = false
        }
    }
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        scrollView.zf_scrollViewDidEndDraggingWillDecelerate(decelerate)
//    }
//    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
//        scrollView.zf_scrollViewDidScrollToTop()
//    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        scrollView.zf_scrollViewDidScroll()
        self.isScrolling = true
        let offsetY = scrollView.contentOffset.y
        self.scrollOffBlock?(offsetY)
    }
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        scrollView.zf_scrollViewWillBeginDragging()
//    }
}
extension ForumListVM:ZFTableViewCellDelegate{
    func playTheVideoAtIndexPath(indexPath:IndexPath,animated:Bool) {
        if indexPath.row >= self.dataSourceArray.count{
            return
        }
        let model = self.dataSourceArray[indexPath.row]
        self.currentVideoModel = model
        if model.coverType == .VIDEO && model.covers.count > 0{
            DLLog(message: "playTheVideoAtIndexPath: \(indexPath) -- \(model.title) --\(model.covers[0]as? String ?? "")")
            let videoUrl = URL(string: model.covers[0]as? String ?? "")!
            
            if animated{
                ZFPlayerModel.shared.player.playTheIndexPath(indexPath, assetURL: videoUrl, scrollPosition: .top, animated: true)
            }else{
                ZFPlayerModel.shared.player.playTheIndexPath(indexPath, assetURL: videoUrl)
            }
            if let coverImg = model.coverImg{
            self.controlView.showTitle("", cover: coverImg, fullScreenMode: .portrait)
            }else{
                self.controlView.showTitle("", cover: createImageWithColor(color: WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.01)), fullScreenMode: .portrait)
            }
            if UserConfigModel.shared.isMuted {
                ZFPlayerModel.shared.playerManager.player.volume = 0
            }else{
                ZFPlayerModel.shared.playerManager.player.volume = 1.0
            }
        }
    }
    func zf_playTheVideoAtIndexPath(indexPath: IndexPath) {
        self.playTheVideoAtIndexPath(indexPath: indexPath, animated: false)
    }
}
extension ForumListVM{
    func sendNoticeListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_notice_list, parameters: nil) { responseObject in
            
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendNoticeListRequest:\(dataArr)")
            if dataArr.count > 0 {
                UserDefaults.set(value: dataArr, forKey: .forumNoticeListData)
                
                let serialQueue = DispatchQueue(label: "com.forum.list.notice")
                var noticeDataArray = [ForumModel]()
                serialQueue.async {
                    for i in 0..<dataArr.count{
                        let dict = dataArr[i]as? NSDictionary ?? [:]
                        let model = ForumModel().initWithDictCoverInfo(dict: dict)
                        noticeDataArray.append(model)
                    }
                }
                serialQueue.async {
                    DispatchQueue.main.async(execute: {
                        self.headNoticeVm.updateUI(dataArray: noticeDataArray)
                        self.noticeDispatchGroup.leave()
                    })
                }
            }else{
                DispatchQueue.main.async(execute: {
                    self.noticeDispatchGroup.leave()
                })
            }
        })
            
        }
    }
    func sendDataListRequest() {
        let param = ["page":"\(pageNum)",
                     "pageSize":"\(pageSize)"]
        DLLog(message: "sendDataListRequest : --- param --- \(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_list, parameters: param as [String:AnyObject]) { responseObject in
            DispatchQueue.global(qos: .userInitiated).async(execute: {
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendDataListRequest:\(dataArr)")
                DLLog(message: "sendDataListRequest : --- param ---  \(self.pageNum) - \(self.pageSize) - \(dataArr.count)")
                
                let serialQueue = DispatchQueue(label: "com.forum.list.data")
                var dataArrayTemp = [ForumModel]()
                var dataArrayT = [ForumModel]()
                var pageOneDataIsSame = true//第一页的数据，是否完全一致
                
                serialQueue.async {
                    for i in 0..<dataArr.count{
                        let dict = dataArr[i]as? NSDictionary ?? [:]
                        let model = ForumModel().initWithDictCoverInfo(dict: dict)
//                        let model = ForumModel().initWithDict(dict: dict)
                        dataArrayT.append(model)
                    }
                }
                serialQueue.async {
                    if self.pageNum == 1{
                        
                        for i in 0..<dataArrayT.count{
                            let tMo = dataArrayT[i]
                            if self.dataSourceArray.count > i{
                                let sMo = self.dataSourceArray[i]
                                if tMo.id != sMo.id{
                                    pageOneDataIsSame = false
                                    break
                                }
                            }
                        }
                        
                        UserDefaults.set(value: dataArr, forKey: .forumListData)
                        self.dataSourceArrayTemp.removeAll()
    //                    self.dataSourceArray.removeAll()
                        dataArrayTemp = dataArrayT
                    }else{
                        for model in dataArrayT{
                            var hasDul = false
                            for mo in self.dataSourceArrayTemp{
                                if model.id == mo.id{
                                    hasDul = true
                                    break
                                }
                            }
                            if hasDul == false{
                                dataArrayTemp.append(model)
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: {
//                        self.tableView.mj_footer?.endRefreshing()
                        self.tableView.mj_header?.endRefreshing()
                        
                        // 提示没有更多数据
                        if dataArr.count < self.pageSize {
                            self.footVm.endRefreshingNoMoreData()
                        }
                        self.insertRows.removeAll()
                        for i in 0..<dataArrayTemp.count{
                            let model = dataArrayTemp[i]
                            self.dataSourceArrayTemp.append(model)
                            self.insertRows.append(IndexPath(row: self.dataSourceArrayTemp.count-1, section: 0))
                        }
                        if self.isScrolling == false || self.pageNum == 1 || dataArr.count < self.pageSize{
                            let oldCount = self.dataSourceArray.count
                            self.dataSourceArray = self.dataSourceArrayTemp
                            if self.pageNum == 1 {
                                if pageOneDataIsSame && oldCount <= 10 {
                                    let needsDelete = oldCount > dataArrayTemp.count
                                    let tableCount = self.tableView.numberOfRows(inSection: 0)
                                    if needsDelete && tableCount == oldCount {
                                        let deleteIndexPaths = (dataArrayTemp.count..<oldCount).map { IndexPath(row: $0, section: 0) }
                                        if !deleteIndexPaths.isEmpty {
                                            self.tableView.performBatchUpdates({
                                                self.tableView.deleteRows(at: deleteIndexPaths, with: .none)
                                            }, completion: { _ in
                                                if self.tableView.numberOfRows(inSection: 0) != self.dataSourceArray.count {
                                                    self.tableView.reloadData()
                                                }
                                            })
                                        } else {
                                            UIView.performWithoutAnimation {
                                                self.tableView.reloadData()
                                                self.tableView.deleteRows(at: deleteIndexPaths, with: .none)
                                            }
                                        }
                                    } else {
                                        UIView.performWithoutAnimation {
                                            self.tableView.reloadData()
                                        }
                                    }
                                } else {
                                    UIView.performWithoutAnimation {
                                        self.tableView.reloadData()
                                    }
                                }
                            }else{
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: self.insertRows, with: .bottom)
                                self.tableView.endUpdates()
                                self.insertRows.removeAll()
                            }
                        }
                    })
                }
            })
        }
    }
    func sendThumbsUpRequest(model:ForumModel,indexPath:IndexPath) {
        let upvote = model.upvote == .pass ? "0" : "1"
        let param = ["id":"\(model.id)",
                     "bizType":"1",
                     "like":"\(upvote)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_thumb, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendThumbsUpRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendThumbsUpRequest:\(dataString ?? "")")
//            if dataString == "1"{
//                model.upvote = .pass
//                model.upvoteCount = "\(model.upvoteCount.intValue + 1)"
//            }else{
//                model.upvote = .refuse
//                model.upvoteCount = "\(model.upvoteCount.intValue - 1)"
//            }
//
//            if self.dataSourceArray.count > indexPath.row{
//                let cell = self.tableView.cellForRow(at: indexPath) as? ForumListTableViewCell
//                cell?.updateThumbsUpStatu(model: model)
////                self.tableView.reloadRows(at: [indexPath], with: .fade)
//            }
        }
    }
    func sendCreateShareLink(model:ForumModel,isShowShareView:Bool) {
        let param = ["id":"\(model.id)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_share_create, parameters: param as [String:AnyObject]) { responseObject in
            if isShowShareView{
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                DLLog(message: "sendCreateShareLink:\(dataString ?? "")")
                let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                model.webLink = dataDict.stringValueForKey(key: "weblink")
                self.shareAlertVm.showView(model: model)
            }
        }
    }
    func sendForumImpressionRequest(model:ForumModel){
        if impressionArray.contains(model.id){
            return
        }
        impressionArray.append(model.id)
        let param = ["ids":[model.id]]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_impression, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendForumImpressionRequest:\(responseObject)")
        }
    }
}

extension ForumListVM: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push, toVC is ForumOfficialDetailVC, self.tapTableViewCell.imgView.image != nil {
            return zoomAnimator
        }
        return nil
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let nav = navigationController as? LLNaviViewController {
            nav.delegate = nav
        }
    }
}
