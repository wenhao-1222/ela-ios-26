//
//  CoursePayOrderPayTypeItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/17.
//


class CoursePayOrderPayTypeItemVM : UIView{
    
    var selfHeight = kFitHeight(57)
    
    var tapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var payTypeIconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var selectImgView : UIImageView  = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_pay_type_normal")//course_pay_type_select
        img.isUserInteractionEnabled = true
        
        return img
    }()
}

extension CoursePayOrderPayTypeItemVM{
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension CoursePayOrderPayTypeItemVM{
    func initUI() {
        addSubview(payTypeIconImgView)
        addSubview(titleLab)
        addSubview(selectImgView)
        
        setConstrait()
    }
    func setConstrait() {
        payTypeIconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(5))
            make.width.height.equalTo(kFitWidth(32))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(payTypeIconImgView.snp.right).offset(kFitWidth(12))
            make.centerY.lessThanOrEqualTo(payTypeIconImgView)
        }
        selectImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(payTypeIconImgView)
            make.width.height.equalTo(kFitWidth(19))
        }
    }
}
