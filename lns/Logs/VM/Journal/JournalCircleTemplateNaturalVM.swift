//
//  JournalCircleTemplateNaturalVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/1.
//


class JournalCircleTemplateNaturalVM: UIView {
    
    let selfWidth = kFitWidth(70)
    let selfHeight = kFitWidth(49)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var typeLabel: UILabel = {
        let lab  = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = UIFont().DDInFontSemiBold(fontSize: 20)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
}

extension JournalCircleTemplateNaturalVM{
    func initUI() {
        addSubview(circleView)
        addSubview(typeLabel)
        addSubview(numberLabel)
        
        setConstrait()
    }
    func setConstrait() {
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(6))
            make.top.equalTo(kFitWidth(6.5))
            make.width.height.equalTo(kFitWidth(4))
        }
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(13))
            make.centerY.lessThanOrEqualTo(circleView)
            make.right.equalToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(30))
        }
    }
}
