//
//  ForumCommentFuncAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/13.
//

import MCToast

class ForumCommentFuncAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    //帖子作者id
    var authorId = ""
    
    var whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*4 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
    var whiteViewOriginY = kFitWidth(0)
    
    var commentModel = ForumCommentModel()
    var replyModel = ForumCommentReplyModel()
    
    var replyCommentBlock:((ForumCommentModel)->())?
    var replyReplyBlock:((ForumCommentReplyModel)->())?
    var deleteCommentBlock:((ForumCommentModel)->())?
    var deleteReplyBlock:((ForumCommentReplyModel)->())?
    var reportCommentBlock:((ForumCommentModel)->())?
    var reportReplyBlock:((ForumCommentReplyModel)->())?
    var setTopBlock:((ForumCommentModel)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
//        self.addGestureRecognizer(tap)
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColor_16(colorStr: "EFEFEF")
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        return vi
    }()
    lazy var topLineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        vi.layer.cornerRadius = kFitWidth(2)
        
        return vi
    }()
    lazy var topCloseTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    //回复
    lazy var replayItemVm: ForumCommentFuncAlertItemVM = {
        let vm = ForumCommentFuncAlertItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(44), width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "forum_commone_icon")
        vm.titleLabel.text = "回复"
        vm.tapBlock = {()in
            self.replyAction()
        }
        return vm
    }()
    //评论 置顶
    lazy var setTopItemVm: ForumCommentFuncAlertItemVM = {
        let vm = ForumCommentFuncAlertItemVM.init(frame: CGRect.init(x: 0, y: self.replayItemVm.frame.maxY, width: 0, height: 0))
//        vm.iconImgView.setImgLocal(imgName: "comment_func_copy_icon")
        vm.iconImgView.image = UIImage(named: "forum_set_top_icon")?.WHImageWithTintColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.55))
//        vm.iconImgView.image = UIImage(systemName: "arrow.up.square")//?.WHImageWithTintColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.55))
        vm.titleLabel.text = "置顶"
        vm.whiteView.layer.cornerRadius = 0
        vm.tapBlock = {()in
            self.setTopAction()
        }
        return vm
    }()
    //复制
    lazy var copyItemVm: ForumCommentFuncAlertItemVM = {
        let vm = ForumCommentFuncAlertItemVM.init(frame: CGRect.init(x: 0, y: self.setTopItemVm.frame.maxY, width: 0, height: 0))
//        vm.iconImgView.setImgLocal(imgName: "comment_func_copy_icon")
        vm.iconImgView.image = UIImage(named: "comment_func_copy_icon")?.WHImageWithTintColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.55))
        vm.titleLabel.text = "复制"
        vm.tapBlock = {()in
            self.copyAction()
        }
        return vm
    }()
    //举报
    lazy var reportItemVm: ForumCommentFuncAlertItemVM = {
        let vm = ForumCommentFuncAlertItemVM.init(frame: CGRect.init(x: 0, y: self.copyItemVm.frame.maxY + kFitWidth(8), width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "comment_func_report_icon")
        vm.titleLabel.text = "举报"
        vm.tapBlock = {()in
            self.reportAction()
        }
        return vm
    }()
    //删除
    lazy var deleteItemVm: ForumCommentFuncAlertItemVM = {
        let vm = ForumCommentFuncAlertItemVM.init(frame: CGRect.init(x: 0, y: self.copyItemVm.frame.maxY + kFitWidth(8), width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "comment_func_delete_icon")
        vm.titleLabel.text = "删除"
        vm.titleLabel.textColor = WHColor_16(colorStr: "e83018")
        
        vm.tapBlock = {()in
            self.deleteAction()
        }
        
        return vm
    }()
}

extension ForumCommentFuncAlertVM{
    @objc func deleteAction() {
        if self.commentModel.id.count > 0 {
            if self.deleteCommentBlock != nil{
                self.deleteCommentBlock!(self.commentModel)
            }
        }else if self.replyModel.id.count > 0 {
            if self.deleteReplyBlock != nil{
                self.deleteReplyBlock!(self.replyModel)
            }
        }
        self.hiddenView()
    }
    @objc func replyAction() {
        if self.commentModel.id.count > 0 {
            if self.replyCommentBlock != nil{
                self.replyCommentBlock!(self.commentModel)
            }
        }else if self.replyModel.id.count > 0 {
            if self.replyReplyBlock != nil{
                self.replyReplyBlock!(self.replyModel)
            }
        }
        self.hiddenView()
    }
    @objc func reportAction() {
        if self.commentModel.id.count > 0 {
            if self.reportCommentBlock != nil{
                self.reportCommentBlock!(self.commentModel)
            }
        }else if self.replyModel.id.count > 0 {
            if self.reportReplyBlock != nil{
                self.reportReplyBlock!(self.replyModel)
            }
        }
        self.hiddenView()
    }
    @objc func copyAction() {
        if self.commentModel.id.count > 0 {
//            if commentModel.commentString.count > 0 {
                UIPasteboard.general.string = commentModel.commentString
//                MCToast.mc_success("评论已复制",respond: .allow)
//            }else{
////                UIPasteboard.general.image = commentModel.commentImg
////                MCToast.mc_success("图片已复制",respond: .allow)
//            }
        }else if self.replyModel.id.count > 0 {
//            if replyModel.commentString.count > 0 {
                UIPasteboard.general.string = replyModel.commentString
//                MCToast.mc_success("文案已复制",respond: .allow)
//            }else{
////                UIPasteboard.general.image = replyModel.commentImg
////                MCToast.mc_success("图片已复制",respond: .allow)
//            }
        }
        MCToast.mc_success("已复制到剪切板",respond: .allow)
        self.hiddenView()
    }
    @objc func setTopAction() {
        if self.commentModel.id.count > 0 {
            if self.setTopBlock != nil{
                self.setTopBlock!(self.commentModel)
            }
        }
        self.hiddenView()
    }
}

extension ForumCommentFuncAlertVM{
    @objc func showView() {
        self.isHidden = false
//        judgeSelf()
        checkFuncItem()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }
   }
   @objc func hiddenView() {
       UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
           self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
           self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
       }completion: { t in
           self.isHidden = true
       }
  }
    //判断是不是自己发的评论
    func judgeSelf() {
        var isSelf = UserInfoModel.shared.uId == authorId
        if isSelf == false{
            if self.commentModel.id.count > 0 && self.commentModel.userId == UserInfoModel.shared.uId{
                isSelf = true
            }else if self.replyModel.id.count > 0 && self.replyModel.userId == UserInfoModel.shared.uId {
                isSelf = true
            }
        }
        
        if isSelf {
            deleteItemVm.isHidden = false
            reportItemVm.isHidden = true
        }else{
            deleteItemVm.isHidden = true
            reportItemVm.isHidden = false
        }
    }
    func checkFuncItem() {
        whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*4 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
        
        reportItemVm.isHidden = false
        deleteItemVm.isHidden = false
        setTopItemVm.isHidden = false
        
        //是否为帖子作者
        let isForumAuthor = UserInfoModel.shared.uId == authorId
        
        let comUid = self.commentModel.id.count > 0 ? self.commentModel.userId : self.replyModel.userId
        //如果是评论
        //如果自己是帖子作者，则有所有的功能
        if isForumAuthor{
            if comUid == UserInfoModel.shared.uId{
                reportItemVm.isHidden = true
                if self.commentModel.id.count > 0 {
                    whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*5 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
                    self.copyItemVm.mj_y = self.setTopItemVm.mj_y+kFitWidth(44)
//                    self.copyItemVm.mj_y = self.replayItemVm.mj_y+kFitWidth(44)
                    self.deleteItemVm.mj_y = self.copyItemVm.mj_y+kFitWidth(44) + kFitWidth(4)
                }else{
                    setTopItemVm.isHidden = true
                    whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*4 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
                    self.copyItemVm.mj_y = self.replayItemVm.mj_y+kFitWidth(44)
                    self.deleteItemVm.mj_y = self.copyItemVm.mj_y+kFitWidth(44) + kFitWidth(4)
                }
            }else{
                if self.commentModel.id.count > 0 {
                    whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*6 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
                    self.copyItemVm.mj_y = self.setTopItemVm.mj_y+kFitWidth(44)
//                    self.copyItemVm.mj_y = self.replayItemVm.mj_y+kFitWidth(44)
                    self.reportItemVm.mj_y = self.copyItemVm.mj_y+kFitWidth(44) + kFitWidth(4)
                    self.deleteItemVm.mj_y = self.reportItemVm.mj_y+kFitWidth(44) + kFitWidth(4)
                }else{
                    setTopItemVm.isHidden = true
                    whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*5 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
                    
                    self.copyItemVm.mj_y = self.replayItemVm.mj_y+kFitWidth(44)
                    self.reportItemVm.mj_y = self.copyItemVm.mj_y+kFitWidth(44) + kFitWidth(4)
                    self.deleteItemVm.mj_y = self.reportItemVm.mj_y+kFitWidth(44) + kFitWidth(4)
                }
            }
        }else{
            setTopItemVm.isHidden = true
            if comUid == UserInfoModel.shared.uId{
                reportItemVm.isHidden = true
                self.copyItemVm.mj_y = self.replayItemVm.mj_y+kFitWidth(44)
                self.deleteItemVm.mj_y = self.copyItemVm.mj_y+kFitWidth(44) + kFitWidth(8)
                whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*4 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
            }else{
                deleteItemVm.isHidden = true
                self.copyItemVm.mj_y = self.replayItemVm.mj_y+kFitWidth(44)
                self.reportItemVm.mj_y = self.copyItemVm.mj_y+kFitWidth(44) + kFitWidth(8)
                whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*4 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
            }
        }
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
        whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight)
        if self.commentModel.isTop == .pass{
            setTopItemVm.titleLabel.text = "取消置顶"
            setTopItemVm.iconImgView.image = UIImage(named: "forum_set_top_cancel_icon")?.WHImageWithTintColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.55))
        }else{
            setTopItemVm.titleLabel.text = "置顶"
            setTopItemVm.iconImgView.image = UIImage(named: "forum_set_top_icon")?.WHImageWithTintColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.55))
        }
    }
    @objc func nothingToDo() {
        
    }
     @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
         // 获取当前手势所在的view
         if let view = gesture.view {
             // 根据手势移动view的位置
             switch gesture.state {
             case .changed:
                 let translation = gesture.translation(in: view)
                 DLLog(message: "translation.y:\(translation.y)")
                 if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                     return
                 }
                 view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                 gesture.setTranslation(.zero, in: view)
                 
             case .ended:
                 if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                     self.hiddenView()
                 }else{
                     UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                         self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                     }
                 }
             default:
                 break
             }
         }
     }
}
extension ForumCommentFuncAlertVM{
    func initUI(){
        addSubview(topCloseTapView)
        addSubview(whiteView)
        
        whiteView.addSubview(topLineView)
        whiteView.addSubview(replayItemVm)
        whiteView.addSubview(copyItemVm)
        whiteView.addSubview(setTopItemVm)
        whiteView.addSubview(reportItemVm)
        whiteView.addSubview(deleteItemVm)
        
        setConstrait()
        
        replayItemVm.addCorners(corners: [.topLeft,.topRight])
        copyItemVm.addCorners(corners: [.bottomLeft,.bottomRight])
    }
    
    func setConstrait() {
//        whiteView.snp.remakeConstraints { make in
//            make.left.width.equalToSuperview()
//            make.height.equalTo(whiteViewHeight)
//            make.bottom.equalTo(kFitWidth(16)+SCREEN_HEIGHT)
//        }
        topCloseTapView.snp.remakeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT-whiteViewHeight+kFitWidth(40))
        }
        topLineView.snp.remakeConstraints { make in
            make.top.equalTo(kFitWidth(18))
            make.width.equalTo(kFitWidth(43))
            make.height.equalTo(kFitWidth(4))
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
}
