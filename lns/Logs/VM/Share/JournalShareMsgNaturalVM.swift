//
//  JournalShareMsgNaturalVM.swift
//  lns
//  碳水、蛋白质、脂肪
//  Created by Elavatine on 2025/4/30.
//


class JournalShareMsgNaturalVM: UIView {
    
    var selfHeight = kFitWidth(61)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(16), y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32)-kFitWidth(84), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: GradientView = {
        let vi = GradientView()
        vi.isUserInteractionEnabled = true
        vi.addGradientBackground(startColor: WHColor_16(colorStr: "F5F5F5"), endColor: WHColorWithAlpha(colorStr: "F5F5F5", alpha: 0))
        vi.layer.cornerRadius = kFitWidth(7)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var carboItemVm: JournalShareMsgNaturalItemVM = {
        let vm = JournalShareMsgNaturalItemVM.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var proteinItemVm: JournalShareMsgNaturalItemVM = {
        let vm = JournalShareMsgNaturalItemVM.init(frame: CGRect.init(x: self.carboItemVm.frame.maxX+kFitWidth(23), y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var fatItemVm: JournalShareMsgNaturalItemVM = {
        let vm = JournalShareMsgNaturalItemVM.init(frame: CGRect.init(x: self.proteinItemVm.frame.maxX+kFitWidth(23), y: 0, width: 0, height: 0))
        return vm
    }()
}

extension JournalShareMsgNaturalVM{
    func updateUI(dict:NSDictionary) {
        carboItemVm.updateUI(type: .carbo, currentNum: dict.doubleValueForKey(key: "carbohydrate"), totalNum: dict.doubleValueForKey(key: "carbohydrateden"))
        proteinItemVm.updateUI(type: .protein, currentNum: dict.doubleValueForKey(key: "protein"), totalNum: dict.doubleValueForKey(key: "proteinden"))
        fatItemVm.updateUI(type: .fat, currentNum: dict.doubleValueForKey(key: "fat"), totalNum: dict.doubleValueForKey(key: "fatden"))
    }
}

extension JournalShareMsgNaturalVM{
    func initUI() {
        addSubview(bgView)
        addSubview(carboItemVm)
        addSubview(proteinItemVm)
        addSubview(fatItemVm)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
}
