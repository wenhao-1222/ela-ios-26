//
//  ForumCommentListCellHead.swift
//  lns
//
//  Created by Elavatine on 2024/11/12.
//


class ForumCommentListCellHead: UITableViewCell {
    
    var longPressBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        let pressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        pressGes.minimumPressDuration = 0.5
        vi.addGestureRecognizer(pressGes)
        return vi
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(18)
        img.clipsToBounds = true
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var verifyImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_user_verify_icon")
        img.isHidden = true
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var authorLabel: UILabel = {
        let lab = UILabel()
        lab.text = "作者"
        lab.textColor = .THEME
        lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 10, weight: .bold)
        lab.layer.cornerRadius = kFitWidth(8)
        lab.clipsToBounds = true
        lab.isHidden = true
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    
    //点赞
    lazy var thumbsUpButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("点赞", for: .normal)
        btn.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        
//        btn.addTarget(self, action: #selector(thumbTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var commentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.lineBreakMode = .byWordWrapping
        lab.numberOfLines = 0
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.isHidden = true
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
}

extension ForumCommentListCellHead{
    func updateUI(model:ForumCommentModel) {
        headImgView.setImgUrl(urlString: model.headImgUrl)
        nameLabel.text = model.nickName
        timeLabel.text = model.timeForShow
        
        if model.commentString.count > 0 {
            commentLabel.isHidden = false
            commentLabel.text = model.commentString
        }else{
            commentLabel.isHidden = true
        }
        
        if model.imgUrl.count > 0 {
            imgView.isHidden = false
            imgView.setImgUrl(urlString: model.imgUrl)
            imgView.snp.remakeConstraints { make in
                make.left.equalTo(commentLabel)
                make.top.equalTo(commentLabel.snp.bottom).offset(kFitWidth(8))
                make.width.equalTo(model.imgWidth)
                make.height.equalTo(model.imgHeight)
            }
        }else{
            imgView.isHidden = true
        }
        bgView.snp.remakeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
            make.height.equalTo(model.contentHeight)
        }
    }
    @objc func longPressAction() {
        if self.longPressBlock != nil{
            self.longPressBlock!()
        }
    }
}

extension ForumCommentListCellHead{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(headImgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(verifyImgView)
        bgView.addSubview(authorLabel)
        bgView.addSubview(thumbsUpButton)
        bgView.addSubview(commentLabel)
        bgView.addSubview(imgView)
        bgView.addSubview(timeLabel)
        
        setConstrait()
        
        thumbsUpButton.imagePosition(style: .top, spacing: kFitWidth(3))
    }
    func setConstrait() {
        headImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(36))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.top.equalTo(kFitWidth(17))
        }
        verifyImgView.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(nameLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        thumbsUpButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(0))
            make.width.equalTo(kFitWidth(54))
            make.height.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(16))
        }
        commentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.top.equalTo(kFitWidth(36))
            make.right.equalTo(kFitWidth(-58))
        }
        
    }
}
