//
//  MineFuncVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/11.
//

import Foundation

class MineFuncVM: UIView {
    
    var selfHeight = MineFuncItemVM().selfHeight*8
    var bgViewHeight = MineFuncItemVM().selfHeight*8
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        if selfHeight > (SCREEN_HEIGHT-WHUtils().getTabbarHeight()-self.frame.origin.y-kFitWidth(10)){
            bgViewHeight = (SCREEN_HEIGHT-WHUtils().getTabbarHeight()-self.frame.origin.y-kFitWidth(10))
        }else {
            bgViewHeight = selfHeight
        }
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: bgViewHeight))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
//        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var scrollView : UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: bgViewHeight))
        scro.showsVerticalScrollIndicator = false
        scro.backgroundColor = .clear
        scro.layer.cornerRadius = kFitWidth(12)
        scro.bounces = false
        
        return scro
    }()
    lazy var foodsVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: .zero)
        vm.leftIconImgView.setImgLocal(imgName: "mine_func_foods")
        vm.titleLab.text = "我的食物"
        vm.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(12))
        
        return vm
    }()
    
    lazy var naturalStatVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: CGRect.init(x: 0, y: self.foodsVm.frame.maxY, width: 0, height: 0))
        vm.leftIconImgView.setImgLocal(imgName: "mine_func_stat")
        vm.titleLab.text = "数据统计"
        
        return vm
    }()
    lazy var goalVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: CGRect.init(x: 0, y: self.naturalStatVm.frame.maxY, width: 0, height: 0))
        vm.leftIconImgView.setImgLocal(imgName: "mine_func_goal")
        vm.titleLab.text = "我的目标"
        
        return vm
    }()
    lazy var bodyDataVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: CGRect.init(x: 0, y: self.goalVm.frame.maxY, width: 0, height: 0))
        vm.leftIconImgView.setImgLocal(imgName: "mine_boday_data")
        vm.titleLab.text = "身体数据"
        
        return vm
    }()
    lazy var courseOrderListVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: CGRect.init(x: 0, y: self.bodyDataVm.frame.maxY, width: 0, height: 0))
        vm.leftIconImgView.setImgLocal(imgName: "mine_func_order_list")
        vm.titleLab.text = "我的订单"
        
        return vm
    }()
    lazy var serviceVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: CGRect.init(x: 0, y: self.courseOrderListVm.frame.maxY, width: 0, height: 0))
        vm.leftIconImgView.setImgLocal(imgName: "mine_func_service")
        vm.titleLab.text = "联系我们"
        
        return vm
    }()
    lazy var tutorialsVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: CGRect.init(x: 0, y: self.serviceVm.frame.maxY, width: 0, height: 0))
        vm.leftIconImgView.setImgLocal(imgName: "mine_func_tutorials")
        vm.titleLab.text = "使用教程"
//        vm.detailLabel.text = "新功能：小组件"
        
        return vm
    }()
    lazy var forumMsgVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: CGRect.init(x: 0, y: self.tutorialsVm.frame.maxY, width: 0, height: 0))
        vm.leftIconImgView.setImgLocal(imgName: "mine_func_forum_msg_icon")
        vm.titleLab.text = "消息通知"
        
        return vm
    }()
    
    lazy var inviteVm: MineFuncItemVM = {
        let vm = MineFuncItemVM.init(frame: CGRect.init(x: 0, y: self.forumMsgVm.frame.maxY, width: 0, height: 0))
        vm.leftIconImgView.setImgLocal(imgName: "mine_func_invite")
        vm.titleLab.text = "邀请奖励"
        vm.detailLabel.text = "得现金"
        vm.addClipCorner(corners: [.bottomLeft,.bottomRight], radius: kFitWidth(12))
        
        return vm
    }()
}

extension MineFuncVM{
    func initUI() {
        addSubview(bgView)
        
        bgView.addSubview(scrollView)
        scrollView.addSubview(foodsVm)
        scrollView.addSubview(naturalStatVm)
        scrollView.addSubview(goalVm)
        scrollView.addSubview(forumMsgVm)
        scrollView.addSubview(bodyDataVm)
        scrollView.addSubview(courseOrderListVm)
        scrollView.addSubview(serviceVm)
        scrollView.addSubview(tutorialsVm)
        scrollView.addSubview(inviteVm)
        
        bgView.addShadow()
        scrollView.contentSize = CGSize.init(width: 0, height: selfHeight)
    }
    func updateUI()  {
        if UserInfoModel.shared.uLevel != "1" && UserInfoModel.shared.uLevel != "2"{
            inviteVm.isHidden = true
            selfHeight = MineFuncItemVM().selfHeight*8
            if selfHeight > (SCREEN_HEIGHT-WHUtils().getTabbarHeight()-self.frame.origin.y-kFitWidth(10)){
                bgViewHeight = (SCREEN_HEIGHT-WHUtils().getTabbarHeight()-self.frame.origin.y-kFitWidth(10))
            }else {
                bgViewHeight = selfHeight
            }
            tutorialsVm.addClipCorner(corners: [.bottomLeft,.bottomRight], radius: kFitWidth(12))
            
            bgView.frame = CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: bgViewHeight)
            scrollView.contentSize = CGSize.init(width: 0, height: selfHeight)
        }else{
            selfHeight = MineFuncItemVM().selfHeight*9
            if selfHeight > (SCREEN_HEIGHT-WHUtils().getTabbarHeight()-self.frame.origin.y-kFitWidth(10)){
                bgViewHeight = (SCREEN_HEIGHT-WHUtils().getTabbarHeight()-self.frame.origin.y-kFitWidth(10))
            }else {
                bgViewHeight = selfHeight
            }
            tutorialsVm.addClipCorner(corners: [.bottomLeft,.bottomRight], radius: kFitWidth(12))
            bgView.frame = CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: bgViewHeight)
            scrollView.contentSize = CGSize.init(width: 0, height: selfHeight)
        }
        
        let selfFrame = self.frame
//        selfFrame.height = bgViewHeight
        scrollView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: bgViewHeight)
        self.frame = CGRect.init(x: selfFrame.origin.x, y: selfFrame.origin.y, width: selfFrame.size.width, height: bgViewHeight)
        
        serviceVm.redView.isHidden = !UserInfoModel.shared.msgUnRead
        tutorialsVm.redView.isHidden = UserInfoModel.shared.widgetNewFuncRead
//        naturalStatVm.redView.isHidden = UserInfoModel.shared.statNewFuncRead
    }
    func updateForumUnReadNum(unReadNum:String) {
        if unReadNum.intValue > 0{
            UserInfoModel.shared.newsListHasUnRead = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgUnRead"), object: nil)
            forumMsgVm.unreadNumLabel.isHidden = false
            if unReadNum.intValue > 99{
                forumMsgVm.unreadNumLabel.text = "99+"
            }else{
                forumMsgVm.unreadNumLabel.text = unReadNum
            }
        }else{
            UserInfoModel.shared.newsListHasUnRead = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgRead"), object: nil)
            forumMsgVm.unreadNumLabel.isHidden = true
        }
    }
}
