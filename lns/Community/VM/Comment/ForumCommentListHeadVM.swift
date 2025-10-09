//
//  ForumCommentListHeadVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/13.
//


class ForumCommentListHeadVM: UIView {

    var longPressBlock:(()->())?
    var thumbBlock:(()->())?
    var tapBlock:(()->())?
    var imgTapBlock:((UIImage)->())?
    var imgLoadBlock:(()->())?

    var isTap = false

    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true

        let pressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        pressGes.minimumPressDuration = 0.5
        self.addGestureRecognizer(pressGes)

        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var highLightView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
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
        lab.layer.cornerRadius = kFitWidth(10)
        lab.clipsToBounds = true
        lab.isHidden = true
        lab.isUserInteractionEnabled = true
        return lab
    }()

    lazy var thumbsUpButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("", for: .normal)
        btn.alpha = 0
        btn.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        btn.addTarget(self, action: #selector(thumbAction), for: .touchUpInside)
        return btn
    }()
    lazy var thumbTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(thumbAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var commentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.lineBreakMode = .byWordWrapping
        lab.numberOfLines = 2
        lab.isUserInteractionEnabled = true

        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.isHidden = true
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(4)
        img.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapAction))
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
    lazy var authorLikeLabel : UILabel = {
        let lab = UILabel()
        lab.text = "作者赞过"
        lab.isHidden = true
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textAlignment = .center
        lab.layer.cornerRadius = kFitWidth(10)
        lab.clipsToBounds = true
        lab.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return lab
    }()
    lazy var isTopLabel: UILabel = {
        let lab = UILabel()
        lab.text = "置顶评论"
        lab.isHidden = true
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textAlignment = .center
        lab.layer.cornerRadius = kFitWidth(10)
        lab.clipsToBounds = true
        lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.3)
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
}

extension ForumCommentListHeadVM{
    func updateUI(model:ForumCommentModel) {
        if model.nickName.count == 0 && model.headImgUrl.count < 2{
            headImgView.image = nil
            nameLabel.text = nil
            timeLabel.text = nil
//            thumbsUpButton.imageView?.image = nil
            commentLabel.text = nil
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [headImgView, nameLabel,timeLabel, thumbsUpButton,commentLabel].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [headImgView, nameLabel,thumbsUpButton,timeLabel, commentLabel].forEach { $0.hideSkeletonWithCrossfade() }
        
        // 渲染真实数据
        self.refreshUIForData()
        commentLabel.numberOfLines = 0

        headImgView.setImgUrlWithComplete(urlString: model.headImgUrl) {
            self.imgLoadBlock?()
        }
        nameLabel.text = model.nickName
        timeLabel.text = "\(model.timeForShow) \(model.addressIp)  回复"
        updateThumbButton(model: model)
        updateAuthLabel(model: model)

        if model.commentString.count > 0 {
            commentLabel.isHidden = false
            commentLabel.text = model.commentString
        }else{
            commentLabel.isHidden = true
        }

        if model.isTop == .pass{
            authorLikeLabel.isHidden = true
            isTopLabel.isHidden = false
            timeLabel.snp.remakeConstraints { make in
                make.left.equalTo(commentLabel)
                make.bottom.equalTo(kFitWidth(-30))
            }
        }else{
            isTopLabel.isHidden = true
            if model.isAuthorLike == .pass{
                authorLikeLabel.isHidden = false
                timeLabel.snp.remakeConstraints { make in
                    make.left.equalTo(commentLabel)
                    make.bottom.equalTo(kFitWidth(-30))
                }
            }else{
                authorLikeLabel.isHidden = true
                timeLabel.snp.remakeConstraints { make in
                    make.left.equalTo(commentLabel)
                    make.bottom.equalTo(kFitWidth(-2))
                }
            }
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
        UIView.animate(withDuration: 0.15) {
            self.thumbsUpButton.alpha = 1
//            self.timeLabel.alpha = 1
        }
        
    }

    @objc func longPressAction(gesture:UILongPressGestureRecognizer) {
        if gesture.state != .began { return }
        highLightView.backgroundColor = .clear
        isTap = false
        longPressBlock?()
    }
    @objc func tapAction() {
        highLightView.backgroundColor = .clear
        isTap = false
        tapBlock?()
    }
    @objc func imgTapAction() { if let img = imgView.image { imgTapBlock?(img) } }
    @objc func thumbAction() { thumbBlock?() }

    func updateThumbButton(model:ForumCommentModel) {
        if model.upvoteCount.intValue > 0 { thumbsUpButton.setTitle("\(model.upvoteCount)", for: .normal) }
        else { thumbsUpButton.setTitle("", for: .normal) }
        if model.upvote == .pass{
            thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_highlight"), for: .normal)
            thumbsUpButton.setTitleColor(WHColor_16(colorStr: "F5BA18"), for: .normal)
        }else{
            thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
            thumbsUpButton.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        }
        thumbsUpButton.imagePosition(style: .top, spacing: kFitWidth(3))
    }
    func updateAuthLabel(model:ForumCommentModel) {
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
    func showSelectAction() {
        highLightView.backgroundColor = WHColor_16(colorStr: "EFEFEF")
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            if self.isTap == false { self.highLightView.backgroundColor = .clear }
        }
    }
}

extension ForumCommentListHeadVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(highLightView)
        bgView.addSubview(headImgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(verifyImgView)
        bgView.addSubview(authorLabel)
        bgView.addSubview(thumbsUpButton)
        bgView.addSubview(thumbTapView)
        bgView.addSubview(commentLabel)
        bgView.addSubview(imgView)
        bgView.addSubview(timeLabel)
        bgView.addSubview(authorLikeLabel)
        bgView.addSubview(isTopLabel)
        bgView.addSubview(lineView)

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
            make.height.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(200))
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
            make.left.equalTo(kFitWidth(64))
            make.top.equalTo(kFitWidth(36))
            make.width.equalTo(kFitWidth(220))
            make.height.equalTo(kFitWidth(18))
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(commentLabel)
            make.top.equalTo(commentLabel.snp.bottom).offset(kFitWidth(5))
//            make.bottom.equalTo(kFitWidth(-2))
//            make.bottom.equalTo(authorLikeLabel.snp.top).offset(kFitWidth(-6))
            make.width.equalTo(kFitWidth(140))
            make.height.equalTo(kFitWidth(16))
        }
        authorLikeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.width.equalTo(kFitWidth(56))
            make.height.equalTo(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(-5))
        }
        isTopLabel.snp.makeConstraints { make in
            make.left.width.height.bottom.equalTo(authorLikeLabel)
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(headImgView)
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(kFitWidth(5))
        }
        highLightView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(4))
        }
    }
    func refreshUIForData() {
        nameLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.top.equalTo(kFitWidth(17))
        }
        commentLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.top.equalTo(kFitWidth(36))
            make.right.equalTo(kFitWidth(-58))
        }
        timeLabel.snp.remakeConstraints { make in
            make.left.equalTo(commentLabel)
            make.bottom.equalTo(kFitWidth(-2))
//            make.bottom.equalTo(authorLikeLabel.snp.top).offset(kFitWidth(-6))
        }
        commentLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.top.equalTo(kFitWidth(36))
            make.width.equalTo(kFitWidth(220))
        }
    }
}

extension ForumCommentListHeadVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        highLightView.backgroundColor = WHColor_16(colorStr: "EFEFEF")
        isTap = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        highLightView.backgroundColor = .clear
        isTap = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        highLightView.backgroundColor = .clear
        isTap = false
    }
}


