//
//  HabitRankListHeadVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//

class HabitRankListHeadVM: UIView {
    
    let selfHeight = kFitWidth(192) + kFitWidth(25)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F2
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var degreeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        
        return lab
    }()
    lazy var pointLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    
    lazy var bottomWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: selfHeight-kFitWidth(25), width: SCREEN_WIDHT, height: kFitWidth(50)))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension HabitRankListHeadVM{
    func updateUI(champion:String,runnerUp:String,thirdPlace:String) {
        degreeLabel.text = "青铜"

        let attr = NSMutableAttributedString(string: "周结算奖励：冠军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50])
        attr.append(NSAttributedString(string: "+\(champion)", attributes: [.foregroundColor:UIColor.THEME]))
        attr.append(NSAttributedString(string: " 分｜亚军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50]))
        attr.append(NSAttributedString(string: "+\(runnerUp)", attributes: [.foregroundColor:UIColor.THEME]))
        attr.append(NSAttributedString(string: " 分｜季军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50]))
        attr.append(NSAttributedString(string: "+\(thirdPlace)", attributes: [.foregroundColor:UIColor.THEME]))
        attr.append(NSAttributedString(string: " 分", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50]))
        pointLabel.attributedText = attr
//        pointLabel.setLineHeight(attr: attr ,lineHeight: kFitWidth(20))
    }
}

extension HabitRankListHeadVM{
    func initUI() {
        addSubview(degreeLabel)
        addSubview(pointLabel)
        addSubview(bottomWhiteView)
        
        setConstrait()
        updateUI(champion: "3", runnerUp: "2", thirdPlace: "1")
    }
    func setConstrait() {
        degreeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(23))
        }
        pointLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(49))
            make.height.equalTo(kFitWidth(20))
        }
    }
}
