//
//  CoursePayResultTopVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/22.
//


class CoursePayResultTopVM : UIView{
    
    var selfHeight = kFitHeight(159)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var topLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var detailLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 3
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(20), y: kFitWidth(158), width: SCREEN_WIDHT-kFitWidth(40), height: kFitHeight(1)))
        
        return vi
    }()
    
}

extension CoursePayResultTopVM{
    func updateUI(dict:NSDictionary) {
        let coverInfo = dict["coverInfo"]as? NSDictionary ?? [:]
        imgView.setImgUrl(urlString: coverInfo.stringValueForKey(key: "placeOrderImageOssUrl"))
        
        titleLab.text = dict.stringValueForKey(key: "title")
        detailLab.text = dict.stringValueForKey(key: "subtitle")
    }
}

extension CoursePayResultTopVM{
    func initUI() {
        addSubview(topLineView)
        addSubview(imgView)
        addSubview(titleLab)
        addSubview(detailLab)
        addSubview(dottedLineView)
        
        setConstrait()
    }
    func setConstrait() {
        topLineView.snp.makeConstraints { make in
            make.left.width.top.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(25))
            make.width.equalTo(kFitWidth(90))
            make.height.equalTo(kFitWidth(114))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(130))
            make.top.equalTo(kFitWidth(40))
            make.right.equalTo(kFitWidth(-20))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(130))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(7))
        }
    }
}
