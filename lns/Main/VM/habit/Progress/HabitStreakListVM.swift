//
//  HabitStreakListVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/19.
//


class HabitStreakListVM: UIView {
    
    var selfHeight = kFitWidth(32)+kFitWidth(40)
    var heightChangeBlock:((CGFloat)->())?
    var recieveBlock:((String, HabitItemVM, String)->())?
    var controller = WHBaseViewVC()
    
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
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
//    lazy var firstOnTargetVm: HabitItemVM = {
//        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[0], width: 0, height: 0))
//        vm.titleLabel.text = "初次与好友达成目标"
//        vm.leftIconImgView.setImgLocal(imgName: "haibit_friend_icon")
//        return vm
//    }()
}

extension HabitStreakListVM{
    func updateUI(listArray:NSArray) {
        for vi in whiteView.subviews{
            vi.removeFromSuperview()
        }
        if listArray.count > 0 {
            self.selfHeight = kFitWidth(32)+kFitWidth(40)*CGFloat(listArray.count)+kFitWidth(20)*CGFloat(listArray.count-1)
            self.heightChangeBlock?(kFitWidth(32)+kFitWidth(40)*CGFloat(listArray.count))
            
            for i in 0..<listArray.count{
                let dict = listArray[i]as? NSDictionary ?? [:]
                let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(16)+kFitWidth(60)*CGFloat(i), width: 0, height: 0))
                vm.titleLabel.text = dict.stringValueForKey(key: "streakRewardName")
                vm.leftIconImgView.image = UIImage(named: "haibit_streak_normal_icon")
                
                let tipsStr = NSAttributedString(string: "（不计入排行榜）",
                                                 attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50])
                if dict.stringValueForKey(key: "isClaimed") == "1"{
                    vm.leftIconImgView.alpha = 0.5
                    vm.showButton.setTitle("已领取", for: .normal)
                    vm.showButton.isEnabled = false
                    vm.titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
                    vm.showButton.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
                    let pointAttr = NSMutableAttributedString(string: "+\(dict.stringValueForKey(key: "streakRewardPoint"))",
                                                              attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50])
                    pointAttr.append(tipsStr)
                    vm.pointLabel.attributedText = pointAttr
                }else{
                    vm.showButton.setTitle("领取", for: .normal)
                    vm.showButton.isEnabled = true
                    let pointAttr = NSMutableAttributedString(string: "+\(dict.stringValueForKey(key: "streakRewardPoint"))",
                                                              attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214])
                    pointAttr.append(tipsStr)
                    vm.pointLabel.attributedText = pointAttr
                    
                    vm.tapBlock = {()in
                        vm.showButton.isUserInteractionEnabled = false
                        self.recieveBlock?(
                            dict.stringValueForKey(key: "streakRewardId"),
                            vm,
                            dict.stringValueForKey(key: "streakRewardPoint")
                        )
                    }
                }
                whiteView.addSubview(vm)
            }
        }else{
            self.selfHeight = 0
            self.heightChangeBlock?(0)
        }
    }
}

extension HabitStreakListVM{
    func initUI() {
        addSubview(whiteView)
        
        setConstrait()
    }
    func setConstrait(){
        whiteView.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }
    }
}
