//
//  AITypeVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITypeVM: UIView {
    
    let selfHeight = kFitHeight(43)
    
    var typeChangeBlock:((Int)->())?
    var tapIndex = 0
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: (SCREEN_WIDHT-kFitWidth(320))*0.5, y: frame.origin.y, width: kFitWidth(320), height: selfHeight))
        self.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.8)
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = selfHeight*0.5
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var foodsItemVm : AITypeItemVM = {
        let vm = AITypeItemVM.init(frame: CGRect.init(x: kFitWidth(4), y: kFitHeight(4), width: kFitWidth(156), height: kFitHeight(35)))
        vm.iconImgView.setImgLocal(imgName: "ai_type_foods_icon")
        vm.titleLab.text = "食物"
        vm.updateUI(isSelect: true, isFoods: true)
        vm.tapBlock = {()in
            if self.tapIndex != 0 {
                self.tapIndex = 0
                vm.updateUI(isSelect: true, isFoods: true)
                self.ingredientItemVm.updateUI(isSelect: false, isFoods: false)
                self.typeChangeBlock?(self.tapIndex)
            }
        }
        return vm
    }()
    lazy var ingredientItemVm : AITypeItemVM = {
        let vm = AITypeItemVM.init(frame: CGRect.init(x: kFitWidth(160), y: kFitHeight(4), width: kFitWidth(156), height: kFitHeight(35)))
        vm.iconImgView.setImgLocal(imgName: "ai_type_ingredient_normal_icon")
        vm.titleLab.text = "成分表"
        vm.updateUI(isSelect: false, isFoods: false)
        vm.tapBlock = {()in
            if self.tapIndex != 1 {
                self.tapIndex = 1
                vm.updateUI(isSelect: true, isFoods: false)
                self.foodsItemVm.updateUI(isSelect: false, isFoods: true)
                self.typeChangeBlock?(self.tapIndex)
            }
        }
        return vm
    }()
}

extension AITypeVM{
    func initUI() {
        addSubview(foodsItemVm)
        addSubview(ingredientItemVm)
    }
}

extension AITypeVM{
    func refreshShowStatus(isShow:Bool) {
        if isShow{
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.alpha = 1
            }
        }else{
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.alpha = 0
            }
        }
    }
}
