//
//  HabitFriendsGoalVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/24.
//


class HabitFriendsGoalVM: UIView {
    
    var selfHeight = kFitWidth(132)
    var heightChangeBlock:((CGFloat)->())?
    
    var itemModels:[HabitItemModel] = [HabitItemModel]()
    let vmOriginY:[CGFloat] = [kFitWidth(16),kFitWidth(76),kFitWidth(136),kFitWidth(196)]
    
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
        vm.titleLabel.text = "初次与好友达成目标"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_icon")
        return vm
    }()
    lazy var proteinFirstVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[1], width: 0, height: 0))
        vm.titleLabel.text = "与好友一起达成蛋白质目标"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_protein_icon")
        return vm
    }()
    lazy var proteinSecondVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[2], width: 0, height: 0))
        vm.titleLabel.text = "与好友一起达成蛋白质目标2"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_protein_icon")
        vm.isHidden = true
        return vm
    }()
    lazy var proteinThirdVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[3], width: 0, height: 0))
        vm.titleLabel.text = "与好友一起达成蛋白质目标3"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_protein_icon")
        vm.isHidden = true
        return vm
    }()
}


extension HabitFriendsGoalVM{
    func updateUI(dict:NSDictionary) {
        itemModels.removeAll()
        itemModels.append(HabitItemModel().createModel(vm: firstOnTargetVm,
                                                       isComplete: dict.stringValueForKey(key: "isProteinIntakeOnTargetWithFriendFirstTime") == "1",
                                                       type: .protein_target_friend_first,
                                                       point: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendFirstTimePoint")))
        itemModels.append(HabitItemModel().createModel(vm: proteinFirstVm,
                                                       isComplete: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue > 0,
                                                       type: .protein_target_friend,
                                                       point: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendPoint1")))
        proteinSecondVm.isHidden = true
        proteinThirdVm.isHidden = true
        if dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue >= 1{
            proteinSecondVm.isHidden = false
            itemModels.append(HabitItemModel().createModel(vm: proteinSecondVm,
                                                           isComplete: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue > 1,
                                                             type: .protein_target_friend,
                                                             point: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendPoint2")))
        }
        if dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue >= 2{
            proteinThirdVm.isHidden = false
            itemModels.append(HabitItemModel().createModel(vm: proteinThirdVm,
                                                           isComplete: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendCount").intValue > 2,
                                                             type: .protein_target_friend,
                                                             point: dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendPoint3")))
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
            model.vm.updateUI(isComplete: model.isComplete,point: model.point)
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
