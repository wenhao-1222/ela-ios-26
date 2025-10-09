//
//  JournalShareMsgVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/30.
//


class JournalShareMsgVM: UIView {
    
    let selfHeight = kFitWidth(29)+kFitWidth(46)+kFitWidth(194)+kFitWidth(61)
    //SCREEN_HEIGHT-frame.origin.y-kFitWidth(105)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
//        selfHeight = SCREEN_HEIGHT-frame.origin.y-kFitWidth(105)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var nameMsgVm: JournalShareMsgNameVM = {
        let vm = JournalShareMsgNameVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT-kFitWidth(84), height: 0))
        return vm
    }()
    lazy var caloriesVm: JournalShareMsgCaloriesVM = {
        let  vm = JournalShareMsgCaloriesVM.init(frame: CGRect.init(x: 0, y: self.nameMsgVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var naturalVm: JournalShareMsgNaturalVM = {
        let vm = JournalShareMsgNaturalVM.init(frame: CGRect.init(x: 0, y: self.caloriesVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
}

extension JournalShareMsgVM{
    func initUI() {
        addSubview(bgWhiteView)
        bgWhiteView.addSubview(nameMsgVm)
        bgWhiteView.addSubview(caloriesVm)
        bgWhiteView.addSubview(naturalVm)
        
        setConstrait()
    }
    func setConstrait() {
        bgWhiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(42))
            make.right.equalTo(kFitWidth(-42))
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
