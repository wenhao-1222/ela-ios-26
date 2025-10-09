//
//  ForumNoticeItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/2/12.
//


class ForumNoticeItemVM : UIView{
    
    let selfHeight = kFitWidth(40)
    
    var tapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(24), height: selfHeight))
        self.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
        self.isUserInteractionEnabled = true
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    lazy var noticeFlagLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.layer.borderWidth = kFitWidth(1)
        lab.layer.borderColor = UIColor.THEME.cgColor
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 10, weight: .medium)
        lab.text = "公告"
        return lab
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.isUserInteractionEnabled = true
        lab.numberOfLines = 2
        
        return lab
    }()
    lazy var newLabel: UILabel = {
        let lab = UILabel()
        lab.text = "新"
        lab.textColor = .white
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.backgroundColor = WHColor_16(colorStr: "FF943D")
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_notice_arrow_icon")
        img.isUserInteractionEnabled = true
        return img
    }()
}

extension ForumNoticeItemVM{
    func updateUI(model:ForumModel) {
        titleLab.text = "\(model.title)"
//        titleLab.text = "\(model.title)及哦额否额我哦发价位哦服务i哦发i哦额外哦i我就佛i我阿胶佛IE"
        titleLab.sizeToFit()
        let labWidht = min(titleLab.frame.width,SCREEN_WIDHT-kFitWidth(24)-kFitWidth(48)-kFitWidth(50))
        titleLab.snp.remakeConstraints { make in
            make.left.equalTo(noticeFlagLabel.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(noticeFlagLabel)
            make.width.equalTo(labWidht)
        }
        newLabel.snp.makeConstraints { make in
            make.left.equalTo(labWidht+kFitWidth(50))
            make.centerY.lessThanOrEqualTo(titleLab)
            make.width.height.equalTo(kFitWidth(16))
        }
    }
    func updateNewFlag(idT:String) {
        let tapIds = UserDefaults.getTapNoticeIds()
        for i in 0..<tapIds.count{
            let id = tapIds[i]as? String ?? ""
            if id == idT{
                self.newLabel.isHidden = true
                return
            }
        }
    }
    @objc func tapAction() {
        self.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
        self.newLabel.isHidden = true
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension ForumNoticeItemVM{
    func initUI() {
        addSubview(noticeFlagLabel)
        addSubview(titleLab)
        addSubview(arrowImgView)
        addSubview(newLabel)
        
        setConstrait()
    }
    func setConstrait(){
        noticeFlagLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(12))
            make.width.equalTo(kFitWidth(28))
            make.height.equalTo(kFitWidth(16))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(noticeFlagLabel.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(noticeFlagLabel)
            make.right.equalTo(kFitWidth(-36))
        }
        newLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLab.snp.right).offset(kFitWidth(2))
            make.centerY.lessThanOrEqualTo(titleLab)
            make.width.height.equalTo(kFitWidth(16))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.centerY.lessThanOrEqualTo(noticeFlagLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
    }
}

extension ForumNoticeItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .COLOR_GRAY_BLACK_10
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
    }
}
