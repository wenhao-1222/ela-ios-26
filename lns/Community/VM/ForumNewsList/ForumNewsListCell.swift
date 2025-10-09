//
//  ForumNewsListCell.swift
//  lns
//
//  Created by Elavatine on 2025/1/8.
//

class ForumNewsListCell: UITableViewCell {
    
    var likeBlock:(()->())?
    var replyBlock:(()->())?
    
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
        
        return vi
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(22)
        img.clipsToBounds = true
        img.isUserInteractionEnabled = true
        img.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_01
//        img.isSkeletonable = true
        
        return img
    }()
    lazy var nickNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
//        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 10, weight: .regular)
//        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)

        return lab
    }()
    lazy var forumImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = kFitWidth(4)
        imgView.clipsToBounds = true
        imgView.isUserInteractionEnabled = true
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_01
//        imgView.isSkeletonable = true
        return imgView
    }()
    lazy var contenLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.lineBreakMode = .byTruncatingTail
        lab.font = .systemFont(ofSize: 14, weight: .regular)
//        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var contentImgLabel: UILabel = {
        let lab = UILabel()
        lab.text = "[图片]"
        lab.isHidden = true
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var commentImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.isUserInteractionEnabled = true
        img.isHidden = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        vi.isHidden = true
        
        return vi
    }()
    lazy var parentContenLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_45
        
        return lab
    }()
    lazy var parentImgLabel: UILabel = {
        let lab = UILabel()
        lab.text = "[图片]"
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.isHidden = true
        
        return lab
    }()
    lazy var bottomLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
    lazy var likeButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitleColor(.COLOR_GRAY_BLACK_65, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        btn.layer.cornerRadius = kFitWidth(13)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_BLACK_25), for: .highlighted)
        
        btn.addTarget(self, action: #selector(likeBtnAction), for: .touchUpInside)
        return btn
    }()
    lazy var replyButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitleColor(.COLOR_GRAY_BLACK_65, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        btn.layer.cornerRadius = kFitWidth(13)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_BLACK_25), for: .highlighted)
        
        btn.addTarget(self, action: #selector(replyBtnAction), for: .touchUpInside)
        
        return btn
    }()
}

extension ForumNewsListCell{
    @objc func likeBtnAction() {
        if self.likeBlock != nil{
            self.likeBlock!()
        }
    }
    @objc func replyBtnAction() {
        if self.replyBlock != nil{
            self.replyBlock!()
        }
    }
}

extension ForumNewsListCell{
    func updateUI(model:ForumCommentNewsModel) {
        if model.timeForShow.count < 2 {
            headImgView.image = nil
            forumImgView.image = nil
            nickNameLabel.text = nil
            titleLab.text = nil
            contenLabel.text = nil
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [headImgView, nickNameLabel,titleLab,forumImgView,contenLabel,likeButton,replyButton].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [headImgView, nickNameLabel,titleLab,forumImgView,contenLabel,likeButton,replyButton].forEach { $0.hideSkeletonWithCrossfade() }
        
        updateConstrait()
        contenLabel.numberOfLines = 3
        lineView.isHidden = false
        likeButton.setTitle("赞", for: .normal)
        likeButton.setImage(UIImage(named: "forum_thumbs_up_normal_min"), for: .normal)
        
        replyButton.setTitle("回复", for: .normal)
        replyButton.setImage(UIImage(named: "forum_comment_icon_min"), for: .normal)
        
        headImgView.setImgUrl(urlString: model.fromAvatar)
        timeLabel.text = model.timeForShow
        contenLabel.text = model.content
        
        if model.isDelete {
            contenLabel.textColor = .COLOR_GRAY_BLACK_45
        }else{
            contenLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        
        if model.type == .report{
            self.updateUIForReport(model: model)
            return
        }
        if model.parentImageUrl.count > 0 {
            let conString = WHUtils().truncatedText(model.parentContentShow, toWidth: kFitWidth(200), font: .systemFont(ofSize: 14, weight: .regular))
            DLLog(message: "\(model.parentContentShow)")
            parentContenLabel.text = "\(conString)[图片]"
        }else{
            parentContenLabel.text = "\(model.parentContentShow)"
        }
        if model.postCoverUrl.count > 0 {
            forumImgView.isHidden = false
            forumImgView.setImgUrl(urlString: model.postCoverUrl)
//            if model.contentType == .VIDEO{
//                forumImgView.image = model.coverImg
//            }else{
//                forumImgView.setImgUrl(urlString: model.postCoverUrl)
//            }
        }else{
            forumImgView.isHidden = true
        }
        if model.type == .like{
            self.updateUIForLike(model: model)
            return
        }
        contenLabel.numberOfLines = 3
        lineView.isHidden = false
        contentImgLabel.isHidden = false
        likeButton.isHidden = false
        replyButton.isHidden = false
        nickNameLabel.text = model.fromNickname
        timeLabel.snp.remakeConstraints { make in
            make.left.equalTo(titleLab.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(titleLab)
        }
        titleLab.text = model.title
        updateThumbsUpStatu(model: model)
        if model.isDelete{
            likeButton.isHidden = true
            replyButton.isHidden = true
        }
        if model.imageUrl.count > 0{
            contentImgLabel.isHidden = false
            lineView.snp.remakeConstraints { make in
                make.left.equalTo(nickNameLabel)
                make.top.equalTo(contentImgLabel.snp.bottom).offset(kFitWidth(10))
                make.width.equalTo(kFitWidth(4))
                make.height.equalTo(kFitWidth(16))
            }
        }else{
            contentImgLabel.isHidden = true
            lineView.snp.remakeConstraints { make in
                make.left.equalTo(nickNameLabel)
                make.top.equalTo(contenLabel.snp.bottom).offset(kFitWidth(10))
                make.width.equalTo(kFitWidth(4))
                make.height.equalTo(kFitWidth(16))
            }
        }
        contenLabel.snp.remakeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.right.equalTo(nickNameLabel)
            make.top.equalTo(kFitWidth(64))
            make.bottom.equalTo(-model.bottomGap)
        }
    }
    func updateUIForReport(model:ForumCommentNewsModel) {
        contenLabel.numberOfLines = 0
        nickNameLabel.text = model.title
        timeLabel.snp.remakeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(kFitWidth(8))
        }
        contenLabel.snp.makeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.right.equalTo(nickNameLabel)
//            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
            make.top.equalTo(kFitWidth(64))
            make.bottom.equalTo(kFitWidth(-10))
        }
        lineView.snp.remakeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(contenLabel.snp.bottom).offset(kFitWidth(10))
            make.width.equalTo(kFitWidth(4))
            make.height.equalTo(kFitWidth(16))
        }
        forumImgView.isHidden = true
        lineView.isHidden = true
        likeButton.isHidden = true
        replyButton.isHidden = true
        contentImgLabel.isHidden = true
    }
    ///点赞的站内信
    func updateUIForLike(model:ForumCommentNewsModel) {
        contenLabel.numberOfLines = 0
        nickNameLabel.text = model.fromNickname//model.title
        timeLabel.text = "\(model.title)  \(model.timeForShow)"
//        if model.parentImageUrl.count > 0 {
//            let conString = WHUtils().truncatedText(model.parentContentShow, toWidth: kFitWidth(200), font: .systemFont(ofSize: 14, weight: .regular))
//            parentContenLabel.text = "\(conString)[图片]"
//        }else{
//            parentContenLabel.text = "\(model.parentContentShow)"
//        }
        timeLabel.snp.remakeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(kFitWidth(8))
        }
        contenLabel.snp.makeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.right.equalTo(nickNameLabel)
//            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
            make.top.equalTo(kFitWidth(64))
            make.bottom.equalTo(kFitWidth(-40))
        }
        lineView.snp.remakeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(contenLabel.snp.bottom).offset(kFitWidth(10))
            make.width.equalTo(kFitWidth(4))
            make.height.equalTo(kFitWidth(16))
        }
//        forumImgView.isHidden = true
        likeButton.isHidden = true
        replyButton.isHidden = true
        contentImgLabel.isHidden = true
    }
    func updateThumbsUpStatu(model:ForumCommentNewsModel) {
        if model.like == .pass{
            likeButton.setImage(UIImage(named: "forum_thumbs_up_highlight_min"), for: .normal)
            likeButton.setTitleColor(WHColor_16(colorStr: "F5BA18"), for: .normal)
            likeButton.setTitleColor(WHColorWithAlpha(colorStr: "F5BA18", alpha: 0.45), for: .highlighted)
        }else{
            likeButton.setImage(UIImage(named: "forum_thumbs_up_normal_min"), for: .normal)
            likeButton.setTitleColor(.COLOR_GRAY_BLACK_65, for: .normal)
        }
        likeButton.imagePosition(style: .left, spacing: kFitWidth(3))
    }
}

extension ForumNewsListCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(headImgView)
        bgView.addSubview(nickNameLabel)
        bgView.addSubview(titleLab)
        bgView.addSubview(timeLabel)
        bgView.addSubview(forumImgView)
        bgView.addSubview(contenLabel)
        bgView.addSubview(contentImgLabel)
        bgView.addSubview(commentImgView)
        bgView.addSubview(lineView)
        bgView.addSubview(parentContenLabel)
        bgView.addSubview(bottomLineView)
        bgView.addSubview(likeButton)
        bgView.addSubview(replyButton)
        
        setConstrait()
        
        likeButton.imagePosition(style: .left, spacing: kFitWidth(4))
        replyButton.imagePosition(style: .left, spacing: kFitWidth(4))
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        headImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(44))
        }
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(kFitWidth(8))
            make.top.equalTo(headImgView).offset(kFitWidth(2))
//            make.right.equalTo(forumImgView.snp.left).offset(kFitWidth(-20))
            make.height.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(180))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(kFitWidth(8))
            make.width.equalTo(kFitWidth(220))
            make.height.equalTo(kFitWidth(14))
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(kFitWidth(144))
            make.centerY.lessThanOrEqualTo(titleLab)
            make.width.equalTo(kFitWidth(100))
            make.height.equalTo(kFitWidth(18))
        }
        contenLabel.snp.makeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.right.equalTo(nickNameLabel)
            make.top.equalTo(kFitWidth(64))
            make.bottom.equalTo(kFitWidth(-100))
            make.height.equalTo(kFitWidth(18))
        }
        contentImgLabel.snp.makeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(contenLabel.snp.bottom).offset(kFitWidth(6))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(contentImgLabel.snp.bottom).offset(kFitWidth(10))
            make.width.equalTo(kFitWidth(4))
            make.height.equalTo(kFitWidth(16))
        }
        parentContenLabel.snp.makeConstraints { make in
            make.left.equalTo(lineView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(lineView)
            make.right.equalTo(contenLabel)
            make.height.equalTo(kFitWidth(18))
        }
        forumImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(headImgView)
            make.width.equalTo(kFitWidth(54))
            make.height.equalTo(kFitWidth(54))
        }
        bottomLineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        likeButton.snp.makeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.width.equalTo(kFitWidth(56))
            make.height.equalTo(kFitWidth(26))
            make.bottom.equalTo(kFitWidth(-10))
        }
        replyButton.snp.makeConstraints { make in
            make.left.equalTo(likeButton.snp.right).offset(kFitWidth(10))
            make.centerY.lessThanOrEqualTo(likeButton)
            make.width.height.equalTo(likeButton)
        }
    }
    func updateConstrait() {
        nickNameLabel.snp.remakeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(kFitWidth(8))
            make.top.equalTo(headImgView).offset(kFitWidth(2))
            make.right.equalTo(forumImgView.snp.left).offset(kFitWidth(-20))
        }
        titleLab.snp.remakeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(kFitWidth(8))
        }
        timeLabel.snp.remakeConstraints { make in
            make.left.equalTo(titleLab.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(titleLab)
        }
        contenLabel.snp.remakeConstraints { make in
            make.left.equalTo(nickNameLabel)
            make.right.equalTo(nickNameLabel)
            make.top.equalTo(kFitWidth(64))
            make.bottom.equalTo(kFitWidth(-100))
        }
        parentContenLabel.snp.remakeConstraints { make in
            make.left.equalTo(lineView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(lineView)
            make.right.equalTo(contenLabel)
        }
    }
}
