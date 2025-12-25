//
//  HabitExchangeMsgVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/25.
//


class HabitExchangeMsgVM: UIView {
    
    var selfHeight = kFitWidth(235)
    
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
        lab.text = "累计捐赠"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.text = "0"
        lab.textColor = .THEME
        lab.font = UIFont().DDInFontSemiBold(fontSize: 50)
        
        return lab
    }()
    lazy var numberLab: UILabel = {
        let lab = UILabel()
        lab.text = "份饭"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        
        return vi
    }()
    lazy var currentPointLab: UILabel = {
        let lab = UILabel()
        lab.text = "剩余积分"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return lab
    }()
    lazy var currentPointLabel: UILabel = {
        let lab = UILabel()
        lab.text = "0"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 25)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var pointPerLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.text = "900积分/1餐"
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        return lab
    }()
    lazy var exchangeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("立即兑换", for: .normal)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(15)
        btn.clipsToBounds = true
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        return btn
    }()
}

extension HabitExchangeMsgVM{
    func updateUI(dict:NSDictionary) {
        currentPointLabel.text = dict.stringValueForKey(key: "pointBalance")
//        pointPerLab.text = dict.stringValueForKey(key: "pointCostPerDonate")
        numberLabel.text = dict.stringValueForKey(key: "donateCount")
    }
}

extension HabitExchangeMsgVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(numberLabel)
        whiteView.addSubview(numberLab)
        whiteView.addSubview(lineView)
        whiteView.addSubview(currentPointLab)
        whiteView.addSubview(currentPointLabel)
        whiteView.addSubview(pointPerLab)
        whiteView.addSubview(exchangeButton)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(27))
            make.height.equalTo(kFitWidth(24))
        }
        numberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(65))
        }
        numberLab.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(5))
            make.bottom.equalTo(numberLabel).offset(kFitWidth(-5))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(155))
            make.height.equalTo(kFitWidth(1))
        }
        currentPointLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(15.5))
            make.height.equalTo(kFitWidth(18))
        }
        currentPointLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(37.5))
        }
        pointPerLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-30))
            make.centerY.lessThanOrEqualTo(currentPointLab)
        }
        exchangeButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(pointPerLab)
            make.width.equalTo(kFitWidth(84))
            make.height.equalTo(kFitWidth(30))
            make.centerY.lessThanOrEqualTo(currentPointLabel)
        }
    }
}
