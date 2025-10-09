//
//  PersonalTopFuncVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/20.
//


class PersonalTopFuncVM: UIView {
    
    let selfHeight = kFitWidth(50)*3
    
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
    lazy var planVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: .zero)
        vm.titleLab.text = "我的计划"
        vm.iconImgView.setImgLocal(imgName: "mine_func_plan")
        return vm
    }()
    lazy var bodyDataVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.planVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "体重维度"//"身体数据"
        vm.iconImgView.setImgLocal(imgName: "mine_boday_data")
        return vm
    }()
    lazy var orderVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.bodyDataVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "我的订单"
        vm.iconImgView.setImgLocal(imgName: "mine_func_order_list")
        return vm
    }()
    lazy var settingVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.orderVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "个性化"
        vm.iconImgView.setImgLocal(imgName: "mine_func_personal_setting")
        vm.lineView.isHidden =  true
        return vm
    }()
}

extension PersonalTopFuncVM{
    func initUI() {
        addSubview(planVm)
        addSubview(bodyDataVm)
        addSubview(orderVm)
//        addSubview(settingVm)
    }
}
