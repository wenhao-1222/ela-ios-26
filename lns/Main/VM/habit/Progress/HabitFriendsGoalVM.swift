//
//  HabitFriendsGoalVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/24.
//


class HabitFriendsGoalVM: UIView {
    
    var selfHeight = kFitWidth(132)
    var heightChangeBlock:((CGFloat)->())?
    var controller = WHBaseViewVC()
    
    var itemModels:[HabitItemModel] = [HabitItemModel]()
    let vmOriginY:[CGFloat] = [kFitWidth(16),kFitWidth(76),kFitWidth(136),kFitWidth(196)]
    
    var friendCount = 0
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
//        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var firstOnTargetVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[0], width: 0, height: 0))
        vm.titleLabel.text = "初次与好友达成蛋白质目标"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_icon")
        return vm
    }()
    lazy var proteinFirstVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[1], width: 0, height: 0))
        vm.titleLabel.text = "与好友一起达成蛋白质目标"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_protein_icon")
        
        vm.showButton.addTarget(self, action: #selector(firstFriendTapAction), for: .touchUpInside)
        
        return vm
    }()
    lazy var proteinSecondVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[2], width: 0, height: 0))
        vm.titleLabel.text = "与两位好友一起达成蛋白质目标"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_protein_icon")
        vm.isHidden = true
        vm.showButton.addTarget(self, action: #selector(firstFriendTapAction), for: .touchUpInside)
        return vm
    }()
    lazy var proteinThirdVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[3], width: 0, height: 0))
        vm.titleLabel.text = "与三位好友一起达成蛋白质目标"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_protein_icon")
        vm.showButton.addTarget(self, action: #selector(firstFriendTapAction), for: .touchUpInside)
        vm.isHidden = true
        return vm
    }()
}

extension HabitFriendsGoalVM{
    @objc func firstFriendTapAction() {
        if friendCount > 0{
            let vc = FriendRankingVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = FriendListVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
    }
//    @objc func secondFriendTapAction() {
//        if friendCount > 1{
//            let vc = FriendRankingVC()
//            self.controller.navigationController?.pushViewController(vc, animated: true)
//        }else{
//            let vc = FriendListVC()
//            self.controller.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//    @objc func thirdFriendTapAction() {
//        if friendCount > 2{
//            let vc = FriendRankingVC()
//            self.controller.navigationController?.pushViewController(vc, animated: true)
//        }else{
//            let vc = FriendListVC()
//            self.controller.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
}

extension HabitFriendsGoalVM{
    func updateUI(dict:NSDictionary) {
        itemModels.removeAll()
        firstOnTargetVm.isHidden = true
        proteinSecondVm.isHidden = true
        proteinThirdVm.isHidden = true
        /*
         这里又改了，变成4种状态了。

         1：未达成的时候，灰色文案“领取”
         2：达成了，但后台不要自动给用户加分，显示蓝色“领取”，用户点击了才加分，跟连胜一样
         3：领取了，变成灰色“已领取”。
         4：已经领取，超过24小时/第二天再打开这个页面，就直接不显示这条
         */
        if dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendFirstTimeStatus").count > 0{
            firstOnTargetVm.isHidden = false
            firstOnTargetVm.showButton.isHidden = false
            itemModels.append(HabitItemModel().createModel(vm: firstOnTargetVm,
                                                           isComplete: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendFirstTimeStatus") != "2",
                                                           type: .protein_target_friend_first,
                                                           point: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendFirstTimePoint"),
                                                           proteinFriendFirstStatus:dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendFirstTimeStatus")))
        }
        
        var buttenText = "添加好友"
        friendCount = dict.stringValueForKey(key: "friendCount").intValue
        buttenText = friendCount > 0 ? "好友摄入" : "添加好友"
        itemModels.append(HabitItemModel().createModel(vm: proteinFirstVm,
                                                       isComplete: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue > 0,
                                                       type: .protein_target_friend,
                                                       point: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendPoint1"),
                                                      buttonText: buttenText))
        if dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue >= 1{
            proteinSecondVm.isHidden = false
//            buttenText = friendCount > 1 ? "好友摄入" : "添加好友"
            itemModels.append(HabitItemModel().createModel(vm: proteinSecondVm,
                                                           isComplete: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue > 1,
                                                             type: .protein_target_friend,
                                                             point: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendPoint2"),
                                                          buttonText: buttenText))
        }
        if dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue >= 2{
            proteinThirdVm.isHidden = false
//            buttenText = friendCount > 2 ? "好友摄入" : "添加好友"
            itemModels.append(HabitItemModel().createModel(vm: proteinThirdVm,
                                                           isComplete: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue > 2,
                                                             type: .protein_target_friend,
                                                             point: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendPoint3"),
                                                           buttonText: buttenText))
        }
        
        var tempModels = [HabitItemModel]()
        
        for i in 0..<itemModels.count{
            let model = itemModels[i]
            if model.isComplete{
                tempModels.append(model)
            }else{
                tempModels.insert(model, at: 0)
            }
        }
        
        itemModels = tempModels
        updateFrame()
    }
    private func updateFrame() {
        selfHeight = vmOriginY[itemModels.count-1] + firstOnTargetVm.selfHeight + kFitWidth(16)
        self.heightChangeBlock?(self.selfHeight)
        let selfFrame = self.frame
        self.frame = CGRect.init(x: selfFrame.origin.x, y: selfFrame.origin.y, width: selfFrame.width, height: selfHeight)
        
        for i in 0..<itemModels.count{
            let model = itemModels[i]
            let vmFrame = model.vm.frame
            model.vm.frame = CGRect.init(x: vmFrame.origin.x, y: vmOriginY[i], width: vmFrame.width, height: vmFrame.height)
            if model.type == .protein_target_friend_first{
                model.vm.updateUIForProteinFriendFirst(point: model.point,
                                                       buttonText: model.buttonText,
                                                       status: model.proteinFriendFirstStatus)
            }else{
                model.vm.updateUI(isComplete: model.isComplete,
                                  point: model.point,
                                  buttonText: model.buttonText)
            }
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

extension HabitFriendsGoalVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(firstOnTargetVm)
        whiteView.addSubview(proteinFirstVm)
        whiteView.addSubview(proteinSecondVm)
        whiteView.addSubview(proteinThirdVm)
        
        whiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }
    }
}
