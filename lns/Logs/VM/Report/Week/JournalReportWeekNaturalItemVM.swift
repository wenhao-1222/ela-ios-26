//
//  JournalReportWeekNaturalItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/14.
//


class JournalReportWeekNaturalItemVM: UIView {
    
    let selfHeight = kFitWidth(50)
    let selfWidth = kFitWidth(140)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isSkeletonable = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var numberUnitLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true

        return vi
    }()
    lazy var numberTypeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
}

extension JournalReportWeekNaturalItemVM{
    func initUI() {
        addSubview(numberLabel)
        addSubview(numberUnitLabel)
        addSubview(numberTypeLabel)
        addSubview(circleView)
        
        setConstrait()
    }
    func setConstrait()  {
        numberLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(kFitWidth(40))
            make.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(kFitWidth(15.5))
        }
        numberUnitLabel.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right)
            make.bottom.equalTo(numberLabel)
        }
        circleView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-7))
            make.width.height.equalTo(kFitWidth(5))
        }
        numberTypeLabel.snp.makeConstraints { make in
            make.left.equalTo(circleView.snp.right).offset(kFitWidth(7))
            make.centerY.lessThanOrEqualTo(circleView)
        }
    }
    func hideSkeletonForFrame() {
        numberLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.lessThanOrEqualTo(kFitWidth(15.5))
        }
    }
}
