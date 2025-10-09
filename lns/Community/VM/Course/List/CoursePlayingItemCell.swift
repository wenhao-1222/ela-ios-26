//
//  CoursePlayingItemCell.swift
//  lns
//
//  Created by Elavatine on 2025/4/15.
//

import Kingfisher

class CoursePlayingItemCell: UITableViewCell {
    
    var imgLoadBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(9)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .COLOR_BG_F5
        
        return img
    }()
    lazy var videoDurationLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .COLOR_GRAY_BLACK_25
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.layer.cornerRadius = kFitWidth(6)
        lab.clipsToBounds = true
        lab.isHidden = true
        return lab
    }()
    lazy var courseTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var progressBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_C4C4C4
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()
    lazy var progressView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "FF8725")
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension CoursePlayingItemCell{
    func updateSelectStatus(model:ForumTutorialModel,isPlaying:Bool) {
        if isPlaying{
            let attr = WHUtils().createAttributedStringWithImage(image: UIImage(named: "course_video_playing_icon")!, text: "\(model.title) ")
            courseTitleLabel.attributedText = attr
            courseTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        }else{
            courseTitleLabel.text = model.title
            courseTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }
    }
    func updateUI(model:ForumTutorialModel,isPlaying:Bool,isFirstLoad:Bool) {
//        DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [self] in
            // 3) 最后统一把骨架优雅淡出 + 内容淡入
            [imgView, courseTitleLabel].forEach { $0.hideSkeletonWithCrossfade() }
            courseTitleLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(146))
                make.centerY.lessThanOrEqualTo(imgView)
                make.right.equalTo(kFitWidth(-26))
            }
            if model.coverImg != nil{
                imgView.image = model.coverImg
            }else{
                imgView.setImgUrlWithComplete(urlString: model.coverUrl) {
                    self.imgLoadBlock?()
                }
            }
            if isPlaying{
                let attr = WHUtils().createAttributedStringWithImage(image: UIImage(named: "course_video_playing_icon")!, text: "\(model.title) ")
                courseTitleLabel.attributedText = attr
                courseTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            }else{
                courseTitleLabel.text = model.title
                courseTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            }
            
            if model.videoDuration > 0 {
                videoDurationLabel.isHidden = false
                videoDurationLabel.text = model.videoDurationShow
            }else{
                videoDurationLabel.isHidden = true
            }
            let progress = CourseProgressSQLiteManager.getInstance().queryProgress(tutorialId: model.id)
            let duration = CourseProgressSQLiteManager.getInstance().queryDuration(tutorialId: model.id)
            if progress > 0 {
                let percent = progress/duration
                progressBottomView.isHidden = false
                progressView.frame = CGRect.init(x: 0, y: 0, width: (kFitWidth(110)-kFitWidth(18))*percent, height: kFitWidth(2))
            } else {
                progressBottomView.isHidden = true
            }
//        })
        
    }
    func createAttributedStringWithImage(image: UIImage, text: String) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 11, weight: .regular).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        
        let string = NSMutableAttributedString(string: text)
        string.append(attachmentString)
        
        return string
    }
}

extension CoursePlayingItemCell{
    func initUI() {
        contentView.addSubview(imgView)
        contentView.addSubview(courseTitleLabel)
        imgView.addSubview(videoDurationLabel)
        imgView.addSubview(progressBottomView)
        progressBottomView.addSubview(progressView)
        setConstrait()
        
        // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
        let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                 highlightColorLight: .COLOR_GRAY_E2,
                                 cornerRadius: kFitWidth(4),
                                 shimmerWidth: 0.22,
                                 shimmerDuration: 1.15)
        
        [imgView, courseTitleLabel].forEach { $0.showSkeleton(cfg) }
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(110))
            make.height.equalTo(kFitWidth(60))
            make.bottom.equalToSuperview()
        }
        progressBottomView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(9))
            make.right.equalTo(kFitWidth(-9))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(2))
        }
        courseTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(146))
            make.centerY.lessThanOrEqualTo(imgView)
            make.right.equalTo(kFitWidth(-26))
            make.height.equalTo(kFitWidth(28))
        }
        videoDurationLabel.snp.makeConstraints { make in
            make.right.bottom.equalTo(kFitWidth(-4))
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(18))
        }
    }
}
