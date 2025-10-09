//
//  PersonalBottomFuncVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/20.
//


class PersonalBottomFuncVM: UIView {
    
    var selfHeight = kFitWidth(50)*3
    
    var frameChangeBlock : (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: kFitWidth(16), y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(12)
        self.clipsToBounds = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var contactVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: .zero)
        vm.titleLab.text = "联系我们"
        vm.iconImgView.setImgLocal(imgName: "mine_func_service")
        return vm
    }()
    lazy var tutorialsVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.contactVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "使用教程"
        vm.iconImgView.setImgLocal(imgName: "mine_func_tutorials")
        return vm
    }()
    lazy var msgVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.tutorialsVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "消息通知"
        vm.iconImgView.setImgLocal(imgName: "mine_func_forum_msg_icon")
        return vm
    }()
    lazy var inviteVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.msgVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "邀请奖励"
        vm.iconImgView.setImgLocal(imgName: "mine_func_invite")
        vm.lineView.isHidden =  true
        vm.isHidden = true
        return vm
    }()
}

extension PersonalBottomFuncVM{
    func initUI() {
        addSubview(contactVm)
        addSubview(tutorialsVm)
        addSubview(msgVm)
        addSubview(inviteVm)
    }
}

extension PersonalBottomFuncVM{
    func updateUI()  {
        if UserInfoModel.shared.uLevel != "1" && UserInfoModel.shared.uLevel != "2"{
            inviteVm.isHidden = true
            msgVm.lineView.isHidden = true
            selfHeight = PersonalTopFuncItemVM().selfHeight*3
        }else{
            inviteVm.isHidden = false
            msgVm.lineView.isHidden = false
            selfHeight = PersonalTopFuncItemVM().selfHeight*4
        }
        
        let selfFrame = self.frame
        self.frame = CGRect.init(x: selfFrame.origin.x, y: selfFrame.origin.y, width: selfFrame.width, height: selfHeight)
        
        contactVm.redView.isHidden = !UserInfoModel.shared.msgUnRead
        
        self.frameChangeBlock?()
    }
    
    func updateForumUnReadNum(unReadNum:String) {
        if unReadNum.intValue > 0{
            UserInfoModel.shared.newsListHasUnRead = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgUnRead"), object: nil)
            msgVm.unreadNumLabel.isHidden = false
            if unReadNum.intValue > 99{
                msgVm.unreadNumLabel.text = "99+"
            }else{
                msgVm.unreadNumLabel.text = unReadNum
            }
        }else{
            UserInfoModel.shared.newsListHasUnRead = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgRead"), object: nil)
            msgVm.unreadNumLabel.isHidden = true
        }
    }
}
