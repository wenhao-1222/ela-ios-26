//
//  HabitTodayGoalVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//


class HabitTodayGoalVM: UIView {
    
    let selfHeight = kFitWidth(305)
    var timer: Timer?
    var remainSeconds = 3
    
    var itemModels:[HabitItemModel] = [HabitItemModel]()
    let vmOriginY:[CGFloat] = [kFitWidth(65),kFitWidth(125),kFitWidth(185),kFitWidth(245)]
    
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
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "今日目标"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        return lab
    }()
    lazy var remainTimeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    
    lazy var journalMsgVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[0], width: 0, height: 0))
        vm.titleLabel.text = "记录当日完整饮食"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_journal_icon")
        return vm
    }()
    lazy var proteinMsgVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[1], width: 0, height: 0))
        vm.titleLabel.text = "当日蛋白质达标"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_protein_icon")
        return vm
    }()
    lazy var bodyDataMsgVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[2], width: 0, height: 0))
        vm.titleLabel.text = "提交身体数据"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_body_data_icon")
        return vm
    }()
    lazy var fitnessMsgVm: HabitItemVM = {
        let vm = HabitItemVM.init(frame: CGRect.init(x: 0, y: vmOriginY[3], width: 0, height: 0))
        vm.titleLabel.text = "记录力量训练"
        vm.leftIconImgView.setImgLocal(imgName: "haibit_fitness_icon")
        return vm
    }()
}

extension HabitTodayGoalVM{
    func updateUI(dict:NSDictionary) {
        itemModels = [HabitItemModel().createModel(vm: journalMsgVm,
                                                   isComplete: dict.stringValueForKey(key: "isLoggedFood") == "1",
                                                   type: .log_food,
                                                   point: dict.stringValueForKey(key: "loggedFoodPoint")),
                      HabitItemModel().createModel(vm: proteinMsgVm,
                                                 isComplete: dict.stringValueForKey(key: "isProteinIntakeOnTarget") == "1",
                                                   type: .protein_target,
                                                   point: dict.stringValueForKey(key: "proteinIntakeOnTargetPoint")),
                      HabitItemModel().createModel(vm: bodyDataMsgVm,
                                                 isComplete: dict.stringValueForKey(key: "isLoggedBodyData") == "1",
                                                   type: .log_bodydata,
                                                   point: dict.stringValueForKey(key: "loggedBodyDataPoint")),
                      HabitItemModel().createModel(vm: fitnessMsgVm,
                                                 isComplete: dict.stringValueForKey(key: "isLoggedFitness") == "1",
                                                   type: .log_fitness,
                                                   point: dict.stringValueForKey(key: "loggedFitnessPoint"))]
        remainSeconds = dict.stringValueForKey(key: "secondsToMidnight").intValue
        countDownAction()
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
        for i in 0..<itemModels.count{
            let model = itemModels[i]
            let vmFrame = model.vm.frame
            model.vm.frame = CGRect.init(x: vmFrame.origin.x, y: vmOriginY[i], width: vmFrame.width, height: vmFrame.height)
            model.vm.updateUI(isComplete: model.isComplete,point: model.point)
        }
    }
    private func updateRemainTimeLabel() {
        if remainSeconds <= 0 {
            remainTimeLabel.text = "剩余时间 00:00:00"
            remainTimeLabel.isHidden = true
            self.timer?.invalidate()
            self.timer = nil
            return
        }
        
        let hours = remainSeconds / 3600
        let minutes = (remainSeconds % 3600) / 60
        let seconds = remainSeconds % 60
        remainTimeLabel.text = String(format: "剩余时间 %02d:%02d:%02d", hours, minutes, seconds)
        remainSeconds -= 1
    }
    func countDownAction() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateRemainTimeLabel()
        }
    }
}

extension HabitTodayGoalVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(remainTimeLabel)
        whiteView.addSubview(journalMsgVm)
        whiteView.addSubview(proteinMsgVm)
        whiteView.addSubview(bodyDataMsgVm)
        whiteView.addSubview(fitnessMsgVm)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.height.equalTo(kFitWidth(24))
        }
        remainTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-39))
            make.centerY.lessThanOrEqualTo(titleLab)
        }
    }
}
