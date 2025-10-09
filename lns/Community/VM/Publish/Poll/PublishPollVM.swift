//
//  PublishPollVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/12.
//

class PublishPollVM: UIView {
    
    var selfHeight = kFitWidth(44)
    
    var dataSourceArray:[ForumPollModel] = [ForumPollModel]()
    var itemVmArray:[PublishPollItemVM] = [PublishPollItemVM]()
    
    var heightChangeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        
        initUI()
        self.updateUI(dataArray: [ForumPollModel(),ForumPollModel()])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var leftLabel: UILabel = {
        let lab = UILabel()
        lab.text = "图文投票"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var switchButton: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-SwitchButton().selfWidth, y: (kFitWidth(48)-SwitchButton().selfHeight)*0.5, width: 0, height: 0))
        
        return btn
    }()
}

extension PublishPollVM{
    func updateUI(dataArray:[ForumPollModel]) {
        self.dataSourceArray = dataArray
        self.itemVmArray.removeAll()
        
        let itemVmHeight = kFitWidth(30)
        self.selfHeight = kFitWidth(44)+itemVmHeight*CGFloat(self.dataSourceArray.count)
        self.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight)
        
        for i in 0..<self.dataSourceArray.count{
            let vm = PublishPollItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(44)+kFitWidth(30)*CGFloat(i), width: 0, height: 0))
            addSubview(vm)
            self.itemVmArray.append(vm)
        }
        if self.heightChangeBlock != nil{
            self.heightChangeBlock!()
        }
    }
}

extension PublishPollVM{
    func initUI() {
        addSubview(leftLabel)
        addSubview(switchButton)
        
        setConstrait()
    }
    func setConstrait() {
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(-10))
            make.height.equalTo(kFitWidth(20))
        }
    }
}
