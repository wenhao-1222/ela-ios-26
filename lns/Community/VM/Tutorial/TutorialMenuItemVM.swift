//
//  TutorialMenuItemVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/26.
//

class TutorialMenuItemVM: UIView {
    
    var selfHeight = kFitWidth(58)
    
    var tapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: (SCREEN_WIDHT-kFitWidth(32))*0.5, height: selfHeight))
        self.backgroundColor = .clear//.WIDGET_COLOR_GRAY_BLACK_04//WHColor_16(colorStr: "2C2C2C")
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        self.isSkeletonable = true
        
        initUI()
    }
    lazy var leftArrowImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_left_arrow_icon")
        img.isUserInteractionEnabled = true
//        img.isSkeletonable = true
        
        return img
    }()
    lazy var rightArrowImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_right_arrow_icon")
        img.isUserInteractionEnabled = true
        img.isHidden = true
//        img.isSkeletonable = true
        
        return img
    }()
    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "上一个"
        lab.isSkeletonable = true
        return lab
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.isSkeletonable = true
//        lab.numberOfLines = 2
//        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
}

extension TutorialMenuItemVM{
    func updateUI(model:ForumTutorialModel) {
        if model.title.count > 0 {
            titleLabel.text = model.title
            detailLabel.isHidden = false
        }else{
            detailLabel.isHidden = true
            titleLabel.text = ""
        }
    }
    func hiddenSelf(isHidden:Bool) {
        if isHidden {
            self.titleLabel.isHidden = true
            self.detailLabel.isHidden = true
            self.isUserInteractionEnabled = false
        }else{
            self.titleLabel.isHidden = false
            self.detailLabel.isHidden = false
            self.isUserInteractionEnabled = true
        }
    }
    @objc func tapAction()  {
        detailLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension TutorialMenuItemVM{
    func initUI() {
        addSubview(detailLabel)
        addSubview(titleLabel)
        addSubview(leftArrowImg)
        addSubview(rightArrowImg)
        
        setConstrait()
    }
    func setConstrait() {
        leftArrowImg.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.lessThanOrEqualTo(detailLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        rightArrowImg.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.lessThanOrEqualTo(detailLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.right.equalTo(kFitWidth(-18))
            make.top.equalTo(kFitWidth(8))
        }
        titleLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(12))
//            make.right.equalTo(kFitWidth(-12))
//            make.top.equalTo(detailLabel.snp.bottom).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(kFitWidth(38))
            make.left.width.equalToSuperview()
        }
    }
}

extension TutorialMenuItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        detailLabel.textColor = .COLOR_TEXT_TITLE_0f1214_25
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        detailLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        detailLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
    }
}
