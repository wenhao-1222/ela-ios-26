//
//  JournalReportWeekCalendarMonthVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/16.
//


class JournalReportWeekCalendarMonthVM: UIView {
    
    let selfHeight = kFitWidth(178)
    let selfWidth = SCREEN_WIDHT - kFitWidth(278)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: selfWidth, height: selfHeight))
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        self.isSkeletonable = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var monthLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var yearLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "control_widget_icon")
        img.layer.cornerRadius = kFitWidth(4)
        img.clipsToBounds = true
        
        return img
    }()
}

extension JournalReportWeekCalendarMonthVM{
    func updateUI(){
        
    }
}
extension JournalReportWeekCalendarMonthVM{
    func initUI() {
        addSubview(monthLabel)
        addSubview(yearLabel)
        addSubview(iconImgView)
        
        setConstrait()
    }
    func setConstrait() {
        monthLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(5))
            make.right.equalTo(kFitWidth(-5))
            make.top.equalTo(kFitWidth(18))
        }
        yearLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(5))
            make.right.equalTo(kFitWidth(-5))
            make.top.equalTo(kFitWidth(78))
        }
        iconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(134))
            make.width.height.equalTo(kFitWidth(25))
        }
    }
}
