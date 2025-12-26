//
//  HabitProgressVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//


class HabitProgressVM: UIView {
    
    var controller = WHBaseViewVC()
    
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
        vm.journalMsgVm.showButton.addTarget(self, action: #selector(showJournalRuleAction), for: .touchUpInside)
        vm.tipsTapBlock = {()in
            self.ruleJournalAlertVm.showSelf()
        }
        return vm
    }()
    lazy var friendMsgVm: HabitFriendsGoalVM = {
        let vm = HabitFriendsGoalVM.init(frame: CGRect.init(x: 0, y: self.todayMsgVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.heightChangeBlock = {(height)in
            self.scrollView.contentSize = CGSize.init(width: 0, height: self.todayMsgVm.frame.maxY+height+kFitWidth(20))
        }
        
        return vm
    }()
    lazy var ruleJournalAlertVm: HabitRuleJournalAlertVM = {
        let vm = HabitRuleJournalAlertVM.init(frame: .zero)
        return vm
    }()
}

extension HabitProgressVM{
    func updateUI(dict:NSDictionary) {
        self.topMsgVm.numberLabel.text = dict.stringValueForKey(key: "pointBalance")
        self.todayMsgVm.updateUI(dict: dict)
        self.friendMsgVm.updateUI(dict: dict)
    }
}

extension HabitProgressVM{
    @objc func showJournalRuleAction(){
        ruleJournalAlertVm.showSelf()
    }
}

extension HabitProgressVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.addSubview(topMsgVm)
        scrollView.addSubview(todayMsgVm)
        scrollView.addSubview(friendMsgVm)
        
        scrollView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(ruleJournalAlertVm)
    }
}

