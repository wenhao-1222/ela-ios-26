//
//  PersonalTopFuncVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/20.
//


class PersonalTopFuncVM: UIView {
    
    private let itemHeight = kFitWidth(50)
    private var shouldShowElaPro = false
    private var shouldShowDietPlan = false
    var frameChangeBlock:(()->())?
    var selfHeight: CGFloat {
        itemHeight * CGFloat(6 + (shouldShowElaPro ? 1 : 0) + (shouldShowDietPlan ? 1 : 0))
    }
    
    private func itemY(at index: Int) -> CGFloat {
        itemHeight * CGFloat(index)
    }
    
    override init(frame: CGRect) {
        let shouldShowElaPro = UserInfoModel.shared.vipModel.isMembershipStatusValid
        let shouldShowDietPlan = UserInfoModel.shared.abTestModel.isTrial
        let itemHeight = kFitWidth(50)
        let selfHeight = itemHeight * CGFloat(6 + (shouldShowElaPro ? 1 : 0) + (shouldShowDietPlan ? 1 : 0))
        self.shouldShowElaPro = shouldShowElaPro
        self.shouldShowDietPlan = shouldShowDietPlan
        super.init(frame: CGRect.init(x: kFitWidth(16), y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        self.backgroundColor = .COLOR_CARD_BG_WHITE
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(12)
        self.clipsToBounds = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var elaproVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: .zero)
        vm.titleLab.text = ""
        vm.iconImgView.setImgLocal(imgName: "mine_func_ela_pro")
        vm.titleImgView.isHidden = false
        return vm
    }()
    lazy var planVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.itemY(at: shouldShowElaPro ? 1 : 0), width: 0, height: 0))
        vm.titleLab.text = "自定义计划"
        vm.iconImgView.setImgLocal(imgName: "mine_func_plan")
        return vm
    }()
    lazy var dietPlanVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.itemY(at: shouldShowElaPro ? 2 : 1), width: 0, height: 0))
        vm.titleLab.text = "饮食计划"
        
        vm.iconImgView.setImgLocal(imgName: "mine_func_diet")
        return vm
    }()
    
    lazy var bodyDataVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.itemY(at: shouldShowElaPro ? 2 : 1), width: 0, height: 0))
        vm.titleLab.text = "体重围度"//"身体数据"
        vm.iconImgView.setImgLocal(imgName: "mine_boday_data")
        return vm
    }()
    lazy var fastingVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.itemY(at: shouldShowElaPro ? 3 : 2), width: 0, height: 0))
        vm.titleLab.text = "轻断食"
        vm.iconImgView.setImgLocal(imgName: "mine_func_fasting")
        return vm
    }()
    lazy var communityVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.itemY(at: shouldShowElaPro ? 4 : 3), width: 0, height: 0))
        vm.titleLab.text = "课程干货"
        vm.iconImgView.setImgLocal(imgName: "mine_func_community")
        return vm
    }()
    lazy var orderVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.itemY(at: shouldShowElaPro ? 5 : 4), width: 0, height: 0))
        vm.titleLab.text = "我的订单"
        vm.iconImgView.setImgLocal(imgName: "mine_func_order_list")
        return vm
    }()
    lazy var honorVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.itemY(at: shouldShowElaPro ? 6 : 5), width: 0, height: 0))
        vm.titleLab.text = "我的荣誉"
        vm.iconImgView.setImgLocal(imgName: "mine_func_honor")
        vm.lineView.isHidden =  true
        return vm
    }()
}

extension PersonalTopFuncVM{
    func initUI() {
        addSubview(elaproVm)
        addSubview(planVm)
        addSubview(dietPlanVm)
        addSubview(bodyDataVm)
        addSubview(fastingVm)
        addSubview(communityVm)
        addSubview(orderVm)
        addSubview(honorVm)
        
        updateUI(notifyFrameChange: false)
    }
    
    func updateUI(notifyFrameChange: Bool = true) {
        shouldShowElaPro = UserInfoModel.shared.vipModel.isMembershipStatusValid
        shouldShowDietPlan = UserInfoModel.shared.abTestModel.isTrial
        let planIndex = shouldShowElaPro ? 1 : 0
        let dietPlanIndex = planIndex + 1
        let bodyDataIndex = dietPlanIndex + (shouldShowDietPlan ? 1 : 0)
        
        let selfFrame = self.frame
        self.frame = CGRect.init(x: selfFrame.origin.x, y: selfFrame.origin.y, width: selfFrame.width, height: selfHeight)
        
        elaproVm.isHidden = !shouldShowElaPro
        elaproVm.frame.origin.y = itemY(at: 0)
        planVm.frame.origin.y = itemY(at: planIndex)
        dietPlanVm.isHidden = !shouldShowDietPlan
        dietPlanVm.frame.origin.y = itemY(at: dietPlanIndex)
        bodyDataVm.frame.origin.y = itemY(at: bodyDataIndex)
        fastingVm.frame.origin.y = itemY(at: bodyDataIndex + 1)
        communityVm.frame.origin.y = itemY(at: bodyDataIndex + 2)
        orderVm.frame.origin.y = itemY(at: bodyDataIndex + 3)
        honorVm.frame.origin.y = itemY(at: bodyDataIndex + 4)
        
        if notifyFrameChange {
            frameChangeBlock?()
        }
    }
}
