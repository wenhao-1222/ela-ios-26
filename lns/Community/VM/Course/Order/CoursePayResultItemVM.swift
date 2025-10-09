//
//  CoursePayResultItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/22.
//


class CoursePayResultItemVM : UIView{
    
    var selfHeight = kFitHeight(30)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var leftTitleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var rightDesLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .right
        
        return lab
    }()
    lazy var rightDetailLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .right
        
        return lab
    }()
}

extension CoursePayResultItemVM{
    func initUI() {
        addSubview(leftTitleLab)
        addSubview(rightDetailLab)
     
        setConstrait()
    }
    func setConstrait() {
        leftTitleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualToSuperview()
        }
        rightDetailLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(240))
        }
    }
}
