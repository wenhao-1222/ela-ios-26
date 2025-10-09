//
//  ForumCommentReplyListCell.swift
//  lns
//
//  Created by Elavatine on 2024/11/13.
//

import Kingfisher


class ForumCommentReplyListCell: UITableViewCell {
    
    var longPressBlock:(()->())?
    var thumbBlock:(()->())?
    var tapBlock:(()->())?
    var imgTapBlock:((UIImage)->())?
    var layoutBlock:((CGRect,String)->())?
    
    var isTap = false
    var isSelectCell = false
    
    var replyModel = ForumCommentReplyModel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    override func layoutSubviews() {
        if self.isSelectCell{
            if self.layoutBlock != nil{
                self.layoutBlock!(self.frame,self.replyModel.commentString)
            }
            DLLog(message: "ForumCommentReplyListCell:\(self.frame) -- \(self.replyModel.commentString)")
        }
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        let pressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(sender: )))
        pressGes.minimumPressDuration = 0.5
        vi.addGestureRecognizer(pressGes)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var bgContentView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(12)
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
        btn.setTitle("", for: .normal)
//        btn.setTitle("点赞", for: .normal)
        btn.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        btn.alpha = 0
        
        btn.addTarget(self, action: #selector(thumbAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var thumbTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        vi.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(thumbAction))
        vi.addGestureRecognizer(tap)
        return vi
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
        img.layer.cornerRadius = kFitWidth(4)
        img.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)
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

extension ForumCommentReplyListCell{
    func updateUI(model:ForumCommentReplyModel) {
        self.replyModel = model

       if model.id.isEmpty {
           headImgView.image = nil
           nameLabel.text = nil
           commentLabel.text = nil
           timeLabel.text = nil
           imgView.image = nil
           imgView.isHidden = true
//           timeLabel.alpha = 0
//           thumbsUpButton.imageView?.image = nil

           let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                    highlightColorLight: .COLOR_GRAY_E2,
                                    cornerRadius: kFitWidth(4),
                                    shimmerWidth: 0.22,
                                    shimmerDuration: 1.15)
           [headImgView, nameLabel, commentLabel, timeLabel].forEach { $0.showSkeleton(cfg) }
           return
       }
        refreshConstrait()
//        timeLabel.alpha = 0
       [headImgView, nameLabel, commentLabel, timeLabel].forEach { $0.hideSkeletonWithCrossfade() }
        
        
        thumbTapView.isHidden = false
//        thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
        
        headImgView.kf.cancelDownloadTask()
        headImgView.image = nil
        headImgView.setImgUrl(urlString: model.headImgUrl)
        nameLabel.text = model.nickName
        timeLabel.text = "\(model.timeForShow) \(model.addressIp)  回复"
        
        updateThumbButton(model: model)
        udpateContent(model: model)
        updateAuthLabel(model: model)
        updateImgView(model: model)
        
    }
    //评论图片
    func updateImgView(model:ForumCommentReplyModel) {
        if model.imgUrl.count > 0 {
            imgView.isHidden = false
            if commentLabel.text?.count ?? 0 > 0 {
                imgView.snp.remakeConstraints { make in
                    make.left.equalTo(commentLabel)
                    make.top.equalTo(commentLabel.snp.bottom).offset(kFitWidth(8))
                    make.width.equalTo(model.imgWidth)
                    make.height.equalTo(model.imgHeight)
                }
            }else{
                imgView.snp.remakeConstraints { make in
                    make.left.equalTo(commentLabel)
                    make.top.equalTo(commentLabel)
                    make.width.equalTo(model.imgWidth)
                    make.height.equalTo(model.imgHeight)
                }
            }
            imgView.setImgUrl(urlString: model.imgUrl)
        }else{
            imgView.snp.remakeConstraints { make in
                make.left.equalTo(commentLabel)
                make.top.equalTo(commentLabel.snp.bottom)
                make.width.equalTo(model.imgWidth)
                make.height.equalTo(0)
            }
            imgView.isHidden = true
        }
        timeLabel.snp.remakeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(7))
            make.left.equalTo(commentLabel)
            make.bottom.equalTo(kFitWidth(-2))
        }
    }
    //评论内容
    func udpateContent(model:ForumCommentReplyModel) {
        var attr = NSMutableAttributedString(string: "回复")
        let nameAttr = NSMutableAttributedString(string: " \(model.nickNameTo)")
        nameAttr.yy_color = .COLOR_GRAY_BLACK_45
        attr.append(nameAttr)
        
        var sclaString = ":"
        if model.parentId.count == 0{
            attr = NSMutableAttributedString(string: "")
            sclaString = ""
        }
        
        if model.commentString.count > 0 {
            commentLabel.isHidden = false
            if model.nickNameTo.count > 0 {
                let contentAttr = NSMutableAttributedString(string: "\(sclaString)\(model.commentString)")
                attr.append(contentAttr)
                
                commentLabel.attributedText = attr
            }else{
                commentLabel.text = model.commentString
            }
        }else{
            if model.nickNameTo.count > 0 {
                commentLabel.attributedText = attr
            }else{
                commentLabel.isHidden = true
            }
        }
    }
    //点赞按钮
    func updateThumbButton(model:ForumCommentReplyModel) {
        if model.upvoteCount.intValue > 0 {
            thumbsUpButton.setTitle("\(model.upvoteCount)", for: .normal)
        }else{
            thumbsUpButton.setTitle("", for: .normal)
//            thumbsUpButton.setTitle("点赞", for: .normal)
        }
        if model.upvote == .pass{
            thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_highlight"), for: .normal)
            thumbsUpButton.setTitleColor(WHColor_16(colorStr: "F5BA18"), for: .normal)
        }else{
            thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
            thumbsUpButton.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        }
        thumbsUpButton.imagePosition(style: .top, spacing: kFitWidth(3))
    }
    
    func updateAuthLabel(model:ForumCommentReplyModel) {
        authorLabel.isHidden = model.isAuthor == .refuse
        verifyImgView.isHidden = model.isKeyUser == .refuse
        
        if model.isKeyUser == .pass{
            authorLabel.snp.remakeConstraints { make in
                make.left.equalTo(verifyImgView.snp.right).offset(kFitWidth(4))
                make.centerY.lessThanOrEqualTo(nameLabel)
                make.width.equalTo(kFitWidth(36))
                make.height.equalTo(kFitWidth(20))
            }
        }else{
            authorLabel.snp.remakeConstraints { make in
                make.left.equalTo(nameLabel.snp.right).offset(kFitWidth(4))
                make.centerY.lessThanOrEqualTo(nameLabel)
                make.width.equalTo(kFitWidth(36))
                make.height.equalTo(kFitWidth(20))
            }
        }
    }
    @objc func longPressAction(sender:UILongPressGestureRecognizer) {
        if sender.state == .began{
            bgContentView.backgroundColor = .clear
            isTap = false
            if self.longPressBlock != nil{
                self.longPressBlock!()
            }
        }else{
            bgContentView.backgroundColor = .clear
            isTap = false
        }
    }
    @objc func thumbAction() {
        if self.thumbBlock != nil{
            self.thumbBlock!()
        }
    }
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    
    @objc func imgTapAction() {
        if self.imgTapBlock != nil && imgView.image != nil{
            self.imgTapBlock!(imgView.image!)
        }
    }
    ///站内信点帖子详情，查看评论/回复的时候，将评论/回复高亮显示一下
    func showSelectAction() {
//        self.isSelectCell = true
        bgView.backgroundColor = WHColor_16(colorStr: "EFEFEF")
        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            if self.isTap == false{
                self.bgView.backgroundColor = .clear
            }
        })
    }
}

extension ForumCommentReplyListCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(bgContentView)
        bgView.addSubview(headImgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(verifyImgView)
        bgView.addSubview(authorLabel)
        bgView.addSubview(thumbsUpButton)
        bgView.addSubview(thumbTapView)
        bgView.addSubview(commentLabel)
        bgView.addSubview(imgView)
        bgView.addSubview(timeLabel)
        
        setConstrait()
        
        thumbsUpButton.imagePosition(style: .top, spacing: kFitWidth(3))
    }
    func setConstrait() {
        bgView.snp.remakeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
//            make.height.equalTo(model.contentHeight)
        }
        bgContentView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(60))
            make.top.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-4))
            make.bottom.equalTo(kFitWidth(0))
        }
        headImgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(16))
            make.left.equalTo(kFitWidth(64))
            make.width.height.equalTo(kFitWidth(24))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(100))
            make.top.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(180))
            make.height.equalTo(kFitWidth(18))
        }
        verifyImgView.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(nameLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        authorLabel.snp.makeConstraints { make in
            make.left.equalTo(verifyImgView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(nameLabel)
            make.width.equalTo(kFitWidth(36))
            make.height.equalTo(kFitWidth(20))
        }
        thumbsUpButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(0))
            make.width.equalTo(kFitWidth(54))
            make.height.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(16))
        }
        thumbTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(thumbsUpButton)
            make.width.height.equalTo(kFitWidth(100))
        }
        commentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(100))
            make.top.equalTo(kFitWidth(36))
            make.right.equalTo(kFitWidth(-58))
            make.height.equalTo(kFitWidth(18))
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(commentLabel)
            make.bottom.equalTo(kFitWidth(-2))
            make.width.equalTo(kFitWidth(120))
            make.height.equalTo(kFitWidth(16))
        }
    }
    func refreshConstrait() {
        nameLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(100))
            make.top.equalTo(kFitWidth(16))
        }
        commentLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(100))
            make.top.equalTo(kFitWidth(36))
            make.right.equalTo(kFitWidth(-58))
        }
        timeLabel.snp.remakeConstraints { make in
            make.left.equalTo(commentLabel)
            make.bottom.equalTo(kFitWidth(-2))
        }
    }
}

extension ForumCommentReplyListCell{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgContentView.backgroundColor = WHColor_16(colorStr: "EFEFEF")
        isTap = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgContentView.backgroundColor = .clear
        isTap = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgContentView.backgroundColor = .clear
        isTap = false
    }
}
extension ForumCommentReplyListCell{
    override func prepareForReuse() {
        super.prepareForReuse()
        headImgView.kf.cancelDownloadTask()
        imgView.kf.cancelDownloadTask()
        headImgView.image = nil
        imgView.image = nil
    }
}
