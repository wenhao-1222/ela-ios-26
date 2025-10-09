//
//  ForumListTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2024/11/1.
//


import Kingfisher

protocol ZFTableViewCellDelegate {
    func zf_playTheVideoAtIndexPath(indexPath:IndexPath)
}

class ForumListTableViewCell: UITableViewCell {
    
    var imgLoadBlock:((CGSize)->())?
    var imgTapBlock:(()->())?
    var shareTapBlock:(()->())?
    var commentTapBlock:(()->())?
    var thumbTapBlock:(()->())?
    var videoPlayTapBlock:(()->())?
    var videoTapBlock:(()->())?
    var mutedTapBlock:(()->())?
    var videoLoadBlock:(()->())?
    
    var videoUrlStr = ""
    var imgWidth = kFitWidth(343)
    var imgHeight = kFitWidth(0)
    
    var delegate : ZFTableViewCellDelegate?
    var indexPath = IndexPath()
    var isMuted = false
    var imgIsLoaded = false
    
    var forumModel = ForumModel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMuteStatu), name: NSNotification.Name(rawValue: "mutedStatusChanged"), object: nil)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")//.white
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(18)
        img.clipsToBounds = true
        img.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08)
        
        return img
    }()
    lazy var authorLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        
        return lab
    }()
    lazy var verifyImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_user_verify_icon")
        img.isHidden = true
        return img
    }()
    lazy var isTopImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_top_icon")
        img.isHidden = true
        
        return img
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .bold)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        img.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08)
        
        return img
    }()
    lazy var videoPlayerView: UIImageView = {
        let vi = UIImageView()
        vi.isHidden = true
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.backgroundColor = .clear//.WIDGET_COLOR_GRAY_BLACK_06
        vi.contentMode = .scaleAspectFill
        vi.isUserInteractionEnabled = true
        vi.tag = playerViewTag
        vi.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(videoViewTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var videoDurationLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .COLOR_GRAY_BLACK_25
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.layer.cornerRadius = kFitWidth(9)
        lab.clipsToBounds = true
        return lab
    }()
    lazy var mutedImgView: UIImageView = {
        let img = UIImageView()
        img.isHidden = true
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "forum_player_mute_yes_icon")
    
        return img
    }()
    lazy var mutedTapView: UIView = {
        let vi = UIView()
        vi.isHidden = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(mutedTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    //浏览量
    lazy var pageViewNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.isHidden = true
        return lab
    }()
    lazy var shareBtn: ForumListButton = {
        let btn = ForumListButton.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        btn.iconImgView.setImgLocal(imgName: "forum_share_icon")
        btn.contentLab.text = "分享"
        btn.tapBlock = {()in
            self.shareTapAction()
        }
        
        return btn
    }()
    lazy var commentBtn: ForumListButton = {
        let btn = ForumListButton.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        btn.iconImgView.setImgLocal(imgName: "forum_comment_icon")
        btn.iconImgView.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(17))
        }
        btn.contentLab.text = "评论"
        btn.tapBlock = {()in
            self.commentTapAction()
        }
        
        return btn
    }()
    lazy var likeBtn: ForumListButton = {
        let btn = ForumListButton.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        btn.iconImgView.setImgLocal(imgName: "forum_thumbs_up_normal")
        btn.contentLab.text = "点赞"
        btn.tapBlock = {()in
            self.thumbTapAction()
        }
        
        return btn
    }()
}

extension ForumListTableViewCell{
    @objc func videoViewTapAction() {
        if self.videoTapBlock != nil{
            self.videoTapBlock!()
        }
    }
    @objc func thumbTapAction() {
        if self.thumbTapBlock != nil{
            self.thumbTapBlock!()
        }
    }
    @objc func shareTapAction() {
        if self.shareTapBlock != nil{
            self.shareTapBlock!()
        }
    }
    @objc func commentTapAction() {
        if self.commentTapBlock != nil{
            self.commentTapBlock!()
        }
    }
    
    @objc func imgTapAction(){
        if self.imgTapBlock != nil{
            self.imgTapBlock!()
        }
    }
    @objc func mutedTapAction(){
        self.isMuted = !self.isMuted
        if self.isMuted{
            self.mutedImgView.setImgLocal(imgName: "forum_player_mute_yes_icon")
        }else{
            self.mutedImgView.setImgLocal(imgName: "forum_player_mute_no_icon")
        }
        if self.mutedTapBlock != nil{
            self.mutedTapBlock!()
        }
    }
    
    func setDelegate(delegate:ZFTableViewCellDelegate , indexPath:IndexPath) {
        self.delegate = delegate
        self.indexPath = indexPath
    }
    @objc func updateMuteStatu() {
        if UserConfigModel.shared.isMuted{
            self.mutedImgView.setImgLocal(imgName: "forum_player_mute_yes_icon")
        }else{
            self.mutedImgView.setImgLocal(imgName: "forum_player_mute_no_icon")
        }
    }
}

extension ForumListTableViewCell{
    func updateUI(model:ForumModel) {
        forumModel = model
        imgView.isHidden = true
        imgView.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(forumModel.contentWidth)
            make.height.equalTo(0)
        }
        videoPlayerView.isHidden = true
        videoPlayerView.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(forumModel.contentWidth)
            make.height.equalTo(0)
        }
        resetConstrait()
//        headImgView.image = createImageWithColor(color: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08))
        
        if let cacheImg = ImageCache.default.retrieveImageInMemoryCache(forKey: forumModel.headImgUrl) {
//            self.imgView.image = cacheImg
            headImgView.setImgUrl(urlString: forumModel.headImgUrl)
        }else{
            ImageCache.default.retrieveImage(forKey: forumModel.headImgUrl) { result in
                switch result {
                    case .success(let value):
                        if let image = value.image {
                            // 成功获取磁盘缓存图片
                            DispatchQueue.main.async {
                                self.headImgView.image = image
                            }
                        } else {
                            // 没有找到缓存图片（image 为 nil）
                            DispatchQueue.main.async {
                                self.headImgView.image = nil
                                self.headImgView.setImgUrl(urlString: self.forumModel.headImgUrl)
                            }
                        }
                    case .failure(let error):
                        // 读取缓存失败，可能是找不到或读取失败
                        print("读取缓存失败: \(error)")
                        DispatchQueue.main.async {
                            self.headImgView.image = nil
                            self.headImgView.setImgUrl(urlString: self.forumModel.headImgUrl)
                        }
                    }
            }
//            headImgView.image = nil
//            if forumModel.headImgUrl == ""{
//                headImgView.image = createImageWithColor(color: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08))
//            }else{
//                headImgView.setImgUrl(urlString: forumModel.headImgUrl)
//            }
        }
        
        authorLabel.text = forumModel.createBy
        timeLabel.text = forumModel.showTime
        titleLabel.text = forumModel.title
        verifyImgView.isHidden = !(forumModel.keyUser == .pass)
        isTopImgView.isHidden = !(forumModel.isTop == .pass)
        
        self.updateThumbsUpStatu(model: forumModel)
        self.updateCommentNum(model: forumModel)
        
        if model.covers.count > 0{
            imgView.isHidden = false
//            imgView.image =
//            imgView.image = nil
            imgWidth = SCREEN_WIDHT-kFitWidth(32)
            if model.coverType == .IMAGE{
                shareBtn.snp.remakeConstraints { make in
                    make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(6))
                    make.right.equalToSuperview()
                    make.width.equalTo(kFitWidth(64))
                    make.height.equalTo(kFitWidth(28))
                    make.bottom.equalTo(kFitWidth(-6))
                }
                imgView.snp.remakeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
                    make.left.equalTo(kFitWidth(16))
                    make.width.equalTo(imgWidth)
                    make.height.equalTo(forumModel.coverImgHeight)
                }
//                self.updateImgView(imgUrlString: forumModel.covers[0]as? String ?? "",titleHeight:self.forumModel.titleHeight,model:self.forumModel)
                if let cachedImg = model.coverImg {
                    self.imgView.image = cachedImg
                }else{
//                    self.imgView.image = nil
                    self.updateImgView(imgUrlString: forumModel.covers[0]as? String ?? "",titleHeight:self.forumModel.titleHeight,model:self.forumModel)
                }
            }else{
                imgView.isHidden = true
                videoPlayerView.isHidden = false
                getVideoDuration()
//                self.videoPlayerView.image = nil
//                if model.coverThumbImgUrl.count > 0 {
//                    self.videoPlayerView.setImgUrl(urlString: model.coverThumbImgUrl)
//                }else{
//                    self.videoPlayerView.image = createImageWithColor(color: .COLOR_LIGHT_GREY)
//                }
                if let cacheImg = ImageCache.default.retrieveImageInMemoryCache(forKey: model.coverThumbImgUrl) {
//                    headImgView.setImgUrl(urlString: forumModel.headImgUrl)
                    self.videoPlayerView.image = cacheImg
                }else{
                    ImageCache.default.retrieveImage(forKey: model.coverThumbImgUrl) { result in
                        switch result {
                            case .success(let value):
                                if let image = value.image {
                                    // 成功获取磁盘缓存图片
                                    DispatchQueue.main.async {
                                        self.videoPlayerView.image = image
                                    }
                                } else {
                                    // 没有找到缓存图片（image 为 nil）
                                    DispatchQueue.main.async {
                                        self.videoPlayerView.image = nil
                                        self.videoPlayerView.setImgUrl(urlString: self.forumModel.coverThumbImgUrl)
                                    }
                                }
                            case .failure(let error):
                                // 读取缓存失败，可能是找不到或读取失败
                                print("读取缓存失败: \(error)")
                                DispatchQueue.main.async {
                                    self.videoPlayerView.image = nil
                                    self.headImgView.setImgUrl(urlString: self.forumModel.coverThumbImgUrl)
                                }
                            }
                    }
        //            headImgView.image = nil
        //            if forumModel.headImgUrl == ""{
        //                headImgView.image = createImageWithColor(color: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08))
        //            }else{
        //                headImgView.setImgUrl(urlString: forumModel.headImgUrl)
        //            }
                }
                
                imgView.snp.remakeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom)
                    make.height.equalTo(0)
                }
                self.videoPlayerView.snp.remakeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
                    make.centerX.lessThanOrEqualToSuperview()
                    make.width.equalTo(forumModel.contentWidth)
                    make.height.equalTo(forumModel.contentHeight)
                }
                shareBtn.snp.remakeConstraints { make in
                    make.top.equalTo(videoPlayerView.snp.bottom).offset(kFitWidth(6))
                    make.right.equalToSuperview()
                    make.width.equalTo(kFitWidth(64))
                    make.height.equalTo(kFitWidth(28))
                    make.bottom.equalTo(kFitWidth(-6))
                }
            }
        }else{
            imgView.isHidden = true
            videoPlayerView.isHidden = true
            imgView.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom)
                make.height.equalTo(0)
            }
            shareBtn.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
                make.right.equalToSuperview()
                make.width.equalTo(kFitWidth(64))
                make.height.equalTo(kFitWidth(28))
                make.bottom.equalTo(kFitWidth(-6))
            }
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func updateThumbsUpStatu(model:ForumModel) {
        if model.likable == .pass{
            likeBtn.isHidden = false
        }else{
            likeBtn.isHidden = true
        }
        if model.upvote == .pass{
            likeBtn.contentLab.text = "\(model.upvoteCount)"
            likeBtn.iconImgView.setImgLocal(imgName: "forum_thumbs_up_highlight")
            likeBtn.contentLab.textColor = WHColor_16(colorStr: "F5BA18")
            likeBtn.contentLab.font = .systemFont(ofSize: 14, weight: .medium)
        }else{
            likeBtn.contentLab.textColor = .COLOR_GRAY_BLACK_45
            likeBtn.iconImgView.setImgLocal(imgName: "forum_thumbs_up_normal")
            if model.upvoteCount.intValue > 0 {
                likeBtn.contentLab.text = "\(model.upvoteCount)"
                likeBtn.contentLab.font = .systemFont(ofSize: 14, weight: .medium)
            }else{
                likeBtn.contentLab.text = "点赞"
                likeBtn.contentLab.font = .systemFont(ofSize: 12, weight: .medium)
            }
        }
    }
    
    func updateCommentNum(model:ForumModel) {
        if model.commentable == .pass{
            commentBtn.isHidden = false
            likeBtn.snp.remakeConstraints { make in
                make.right.equalTo(commentBtn.snp.left).offset(kFitWidth(-8))
                make.centerY.width.height.equalTo(shareBtn)
            }
        }else{
            commentBtn.isHidden = true
            likeBtn.snp.remakeConstraints { make in
                make.right.equalTo(shareBtn.snp.left).offset(kFitWidth(-8))
                make.centerY.width.height.equalTo(shareBtn)
            }
            return
        }
        if model.commentCount.intValue > 0 {
            commentBtn.contentLab.text = "\(model.totalCommentCount)"
            commentBtn.contentLab.font = .systemFont(ofSize: 14, weight: .medium)
        }else{
            commentBtn.contentLab.text = "评论"
            commentBtn.contentLab.font = .systemFont(ofSize: 12, weight: .medium)
        }
    }
    func getVideoDuration() {
        if forumModel.videoDuration > 0 {
            videoDurationLabel.text = forumModel.videoDurationForShow
            videoDurationLabel.isHidden = forumModel.videoDurationForShow.count == 0 ? true : false
        }else{
            videoDurationLabel.isHidden = true
            if forumModel.videoUrl != nil{
                videoDurationLabel.text = ""
                DSImageUploader().dealImgUrlSignForOss(urlStr: forumModel.videoUrl!.absoluteString) { signUrl in
                    ForumModel().getVideoDuration(from: URL(string: signUrl)!) {result in
                        switch result{
                        case .success(let seconds):
//                            DLLog(message: "获取视频时长:\(seconds)")
                            self.forumModel.videoDuration = Int(seconds)
                            let minute = self.forumModel.videoDuration/60
                            let second = self.forumModel.videoDuration%60
                            if minute < 10 {
                                self.forumModel.videoDurationForShow = "0\(minute):"
                            }else{
                                self.forumModel.videoDurationForShow = "\(minute):"
                            }
                            if second < 10 {
                                self.forumModel.videoDurationForShow = self.forumModel.videoDurationForShow + "0\(second)"
                            }else{
                                self.forumModel.videoDurationForShow = self.forumModel.videoDurationForShow + "\(second)"
                            }
                            self.videoDurationLabel.isHidden = false
                            self.videoDurationLabel.text = self.forumModel.videoDurationForShow
                            self.videoDurationLabel.isHidden = self.forumModel.videoDurationForShow.count == 0 ? true : false
                        case .failure(let error):
                            DLLog(message: "获取视频时长:error \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func updateImgView(imgUrlString:String?,titleHeight:CGFloat,model:ForumModel) {
        guard URL(string: imgUrlString ?? "") != nil else { return }
        guard let urlString = imgUrlString else { return }
//        self.imgView.image = nil
        // 优先读取内存缓存，避免频繁地先显示占位图再加载图片造成闪烁
        if let cacheImg = ImageCache.default.retrieveImageInMemoryCache(forKey: urlString) {
            self.imgView.image = cacheImg
            model.coverImg = cacheImg
            let imgOriSize = cacheImg.size
            var imgOriginH = imgWidth * (imgOriSize.height / imgOriSize.width)
            if imgOriginH / imgWidth > 5/4 {
                imgOriginH = imgWidth * 5/4
            }
            imgView.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
                make.left.equalTo(kFitWidth(16))
                make.width.equalTo(imgWidth)
                make.height.equalTo(imgOriginH)
            }
            shareBtn.snp.remakeConstraints { make in
                make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(6))
                make.right.equalToSuperview()
                make.width.equalTo(kFitWidth(64))
                make.height.equalTo(kFitWidth(28))
                make.bottom.equalTo(kFitWidth(-6))
            }
            if let block = self.imgLoadBlock, model.imgIsLoaded == false {
                model.imgIsLoaded = true
                self.imgIsLoaded = true
                block(CGSize(width: imgOriSize.width, height: imgOriSize.height))
                model.coverImgHeight = imgOriginH
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            return
        }
        ImageCache.default.retrieveImage(forKey: urlString) { result in
            switch result {
            case .success(let value):
                // 获取到缓存图片
                if let image = value.image{
                    DLLog(message: "setImgUrl(urlString:   找到了缓存的图片(\(model.title)）  \(image)")
                    DispatchQueue.main.async {
                        self.imgView.image = image
                        model.coverImg = image
                    }
                }else{
                    self.imgView.image = nil
                    DLLog(message: "setImgUrl(urlString:   找到了缓存的图片(\(model.title)） ----- nil")
                    self.loadImg(imgUrlString: imgUrlString, titleHeight: titleHeight, model: model)
                }
            case .failure(let error):
                DLLog(message: "setImgUrl(urlString: (\(model.title)） \(error)")
                self.imgView.image = nil
                self.loadImg(imgUrlString: imgUrlString, titleHeight: titleHeight, model: model)
                break
            }
        }
    }
    func loadImg(imgUrlString:String?,titleHeight:CGFloat,model:ForumModel) {
        DLLog(message: "setImgUrl(urlString:   loadImg(imgUrlString (\(model.title)）")
        guard let urlString = imgUrlString else { return }
        
        self.imgView.image = createImageWithColor(color: .COLOR_LIGHT_GREY)
//        let optionsInfo: KingfisherOptionsInfo = [.cacheOriginalImage,
////                                                  .keepCurrentImageWhileLoading,
//                                                  .transition(.fade(0.2))]
        // 保持当前图片直到新图片加载完成，避免闪烁
        let optionsInfo: KingfisherOptionsInfo = [
            .cacheOriginalImage,
            .keepCurrentImageWhileLoading
        ]
        DSImageUploader().dealImgUrlSignForOss(urlStr: imgUrlString ?? "") { signUrl in
            guard let resourceUrl = URL(string: signUrl) else{
                return
            }
            
            let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: urlString)
            
            self.imgView.kf.setImage(with: resource,placeholder: createImageWithColor(color: .COLOR_LIGHT_GREY),options: optionsInfo)
            { [self] result in
                DLLog(message: "result:\(result)")
                let imgOriSize = imgView.image?.size
                var imgOriginH = imgWidth * ((imgOriSize?.height ?? 0) / (imgOriSize?.width ?? 1))
                
                if imgOriginH/imgWidth > 5/4{
                    imgOriginH = imgWidth * 5/4
                }
                imgView.snp.remakeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
                    make.left.equalTo(kFitWidth(16))
                    make.width.equalTo(imgWidth)
                    make.height.equalTo(imgOriginH)
//                    make.bottom.equalTo(kFitWidth(-40))
                }
                shareBtn.snp.remakeConstraints { make in
                    make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(6))
                    make.right.equalToSuperview()
                    make.width.equalTo(kFitWidth(64))
                    make.height.equalTo(kFitWidth(28))
                    make.bottom.equalTo(kFitWidth(-6))
                }
                if self.imgLoadBlock != nil && model.imgIsLoaded == false{
                    model.imgIsLoaded = true
                    self.imgIsLoaded = true
                    self.imgLoadBlock!(CGSize(width: imgOriSize?.width ?? 1, height: imgOriSize?.height ?? 1))
                    model.coverImgHeight = imgOriginH
                    
                    model.coverImg = self.imgView.image
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
            }
        }
    }
}

extension ForumListTableViewCell{
    func initUI() {
        contentView.addSubview(bgView)
        contentView.addSubview(headImgView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(verifyImgView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(isTopImgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imgView)
//        contentView.addSubview(bgImgView)
//        bgImgView.addSubview(effectView)
        contentView.addSubview(videoPlayerView)
//        videoPlayerView.addSubview(playIcon)
        videoPlayerView.addSubview(mutedImgView)
        videoPlayerView.addSubview(mutedTapView)
        videoPlayerView.addSubview(videoDurationLabel)
        contentView.addSubview(pageViewNumLabel)
        
        contentView.addSubview(likeBtn)
        contentView.addSubview(commentBtn)
        contentView.addSubview(shareBtn)
        setConstrait()
        
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(kFitWidth(6))
        }
        headImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(36))
        }
        authorLabel.snp.makeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(kFitWidth(8))
            make.top.equalTo(headImgView)
        }
        verifyImgView.snp.makeConstraints { make in
            make.left.equalTo(authorLabel.snp.right).offset(kFitWidth(3))
            make.centerY.lessThanOrEqualTo(authorLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(authorLabel)
            make.bottom.equalTo(headImgView)
        }
        isTopImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(headImgView)
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(22))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(58))//.priority(.high)
            make.right.equalTo(kFitWidth(-16))
//            make.bottom.equalTo(kFitWidth(-44))
        }
        imgView.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(8))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(imgWidth)
            make.height.equalTo(kFitWidth(150))
            make.bottom.equalTo(kFitWidth(-40))
        }
        pageViewNumLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-16))
        }
        shareBtn.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.right.equalToSuperview()
            make.width.equalTo(kFitWidth(64))
            make.height.equalTo(kFitWidth(28))
            make.bottom.equalTo(kFitWidth(-6))
        }
        commentBtn.snp.makeConstraints { make in
            make.right.equalTo(shareBtn.snp.left).offset(kFitWidth(-8))
            make.width.height.bottom.equalTo(shareBtn)
        }
        likeBtn.snp.makeConstraints { make in
            make.right.equalTo(commentBtn.snp.left).offset(kFitWidth(-8))
            make.width.height.bottom.equalTo(shareBtn)
        }
        videoPlayerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(150))
//            make.bottom.equalTo(kFitWidth(-40))
        }
        mutedImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-8))
            make.bottom.equalTo(kFitWidth(-8))
            make.width.height.equalTo(18)
        }
        mutedTapView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(44))
            make.center.lessThanOrEqualTo(mutedImgView)
        }
        videoDurationLabel.snp.makeConstraints { make in
            make.right.bottom.equalTo(kFitWidth(-8))
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(18))
        }
    }
    func resetConstrait() {
        bgView.snp.remakeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(kFitWidth(6))
        }
        headImgView.snp.remakeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(36))
        }
        authorLabel.snp.remakeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(kFitWidth(8))
            make.top.equalTo(headImgView)
        }
        verifyImgView.snp.remakeConstraints { make in
            make.left.equalTo(authorLabel.snp.right).offset(kFitWidth(3))
            make.centerY.lessThanOrEqualTo(authorLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        timeLabel.snp.remakeConstraints { make in
            make.left.equalTo(authorLabel)
            make.bottom.equalTo(headImgView)
        }
        isTopImgView.snp.remakeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(headImgView)
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(22))
        }
        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(58))//.priority(.high)
            make.right.equalTo(kFitWidth(-16))
//            make.bottom.equalTo(kFitWidth(-44))
        }
        imgView.snp.remakeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(8))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(imgWidth)
            make.height.equalTo(kFitWidth(150))
            make.bottom.equalTo(kFitWidth(-40))
        }
        pageViewNumLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-16))
        }
        shareBtn.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.right.equalToSuperview()
            make.width.equalTo(kFitWidth(64))
            make.height.equalTo(kFitWidth(28))
            make.bottom.equalTo(kFitWidth(-6))
        }
        commentBtn.snp.remakeConstraints { make in
            make.right.equalTo(shareBtn.snp.left).offset(kFitWidth(-8))
            make.width.height.bottom.equalTo(shareBtn)
        }
        likeBtn.snp.remakeConstraints { make in
            make.right.equalTo(commentBtn.snp.left).offset(kFitWidth(-8))
            make.width.height.bottom.equalTo(shareBtn)
        }
        videoPlayerView.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(150))
//            make.bottom.equalTo(kFitWidth(-40))
        }
        mutedImgView.snp.remakeConstraints { make in
            make.right.equalTo(kFitWidth(-8))
            make.bottom.equalTo(kFitWidth(-8))
            make.width.height.equalTo(18)
        }
        mutedTapView.snp.remakeConstraints { make in
            make.width.height.equalTo(kFitWidth(44))
            make.center.lessThanOrEqualTo(mutedImgView)
        }
        videoDurationLabel.snp.remakeConstraints { make in
            make.right.bottom.equalTo(kFitWidth(-8))
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(18))
        }
    }
}
