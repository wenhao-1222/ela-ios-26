//
//  HabitProgressVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//


class HabitProgressVM: UIView {
    
    
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.backgroundColor = .clear
        
        return scro
    }()
    lazy var topMsgVm: HabitTopMsgVM = {
        let vm = HabitTopMsgVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        
        return vm
    }()
    lazy var todayMsgVm: HabitTodayGoalVM = {
        let vm = HabitTodayGoalVM.init(frame: CGRect.init(x: 0, y: kFitWidth(170), width: 0, height: 0))
        return vm
    }()
}

extension HabitProgressVM{
    func updateUI(dict:NSDictionary) {
        self.topMsgVm.numberLabel.text = dict.stringValueForKey(key: "pointBalance")
        self.todayMsgVm.updateUI(dict: dict)
    }
}

extension HabitProgressVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.addSubview(topMsgVm)
        scrollView.addSubview(todayMsgVm)
        
        scrollView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        
    }
}

