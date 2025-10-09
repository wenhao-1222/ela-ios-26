//
//  CourseItemHeadVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/14.
//


class CourseItemHeadVM : UIView{
    
    var selfHeight = kFitHeight(35)
    
    var heightChangeBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true

        initUI()
    }
    lazy var topLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_E2
        vi.isHidden = true
        
        return vi
    }()
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
}

extension CourseItemHeadVM{
    func initUI() {
        addSubview(topLineView)
//        addSubview(circleView)
        addSubview(titleLab)
        
        setConstrait()
    }
    func setConstrait() {
        topLineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(2))
            make.height.equalTo(kFitWidth(1))
        }
        titleLab.snp.makeConstraints { make in
//            make.left.equalTo(circleView.snp.right).offset(kFitWidth(5))
//            make.centerY.lessThanOrEqualTo(circleView)
            make.bottom.equalTo(kFitWidth(-2))
//            make.left.equalTo(kFitWidth(26))
            make.left.equalTo(kFitWidth(16))
        }
//        circleView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
////            make.top.equalTo(topLineView.snp.bottom).offset(kFitWidth(16))
//            make.width.height.equalTo(kFitWidth(5))
//            make.centerY.lessThanOrEqualTo(titleLab)
//        }
    }
}
