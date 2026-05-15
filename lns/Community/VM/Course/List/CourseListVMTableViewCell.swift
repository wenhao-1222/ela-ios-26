//
//  CourseListVMTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/7/15.
//


class CourseListVMTableViewCell: UITableViewCell {
    
    var imgHeight = kFitWidth(130)
    private let imageSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                     highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                     cornerRadius: 0,
                                                     shimmerWidth: 0.2,
                                                     shimmerDuration: 1.0,
                                                     skeletonFadeInDuration: 0.0,
                                                     contentFadeInDuration: 0.18)
    private let textSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                    highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                    cornerRadius: kFitWidth(6),
                                                    shimmerWidth: 0.2,
                                                    shimmerDuration: 1.0,
                                                    skeletonFadeInDuration: 0.0,
                                                    contentFadeInDuration: 0.18)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        imgHeight = (SCREEN_WIDHT-kFitWidth(32))*(kFitWidth(130)/kFitWidth(343))
        
        initUI()
    }
    lazy var bgView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        
        return vi
    }()
    lazy var coverImgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        
        return img
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
//        lab.numberOfLines = 0
//        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var detailLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
//        lab.numberOfLines = 0
//        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImgView.image = nil
        titleLab.text = nil
        detailLab.text = nil
        [coverImgView, titleLab, detailLab].forEach {
            $0.alpha = 1
        }
    }
}

extension CourseListVMTableViewCell{
    func updateUI(dict: NSDictionary, isLoading: Bool = false) {
        if isLoading {
            coverImgView.image = nil
            titleLab.text = "                                    "
            detailLab.text = "                          "
            coverImgView.showSkeleton(imageSkeletonConfig)
            [titleLab, detailLab].forEach { $0.showSkeleton(textSkeletonConfig) }
            return
        }
        
        prepareContentFadeInIfNeeded()
//        let coverInfoDict = dict["coverInfo"]as? NSDictionary ?? [:]
//        coverImgView.setImgUrl(urlString: coverInfoDict.stringValueForKey(key: "imageOssUrl"))
        
        let materialDict = dict["material"]as? NSDictionary ?? [:]
        let imgArray = materialDict["image"]as? NSArray ?? []
        if imgArray.count > 0{
            let imgDict = imgArray[0]as? NSDictionary ?? [:]
            coverImgView.setImgUrl(urlString: imgDict.stringValueForKey(key: "ossUrl"))
        }
        
        titleLab.text = dict.stringValueForKey(key: "title")
        detailLab.text = dict.stringValueForKey(key: "subtitle")
        
        [coverImgView, titleLab, detailLab].forEach { $0.hideSkeletonWithCrossfade() }
    }
    
    func hideLoadingSkeleton() {
        prepareContentFadeInIfNeeded()
        [coverImgView, titleLab, detailLab].forEach { $0.hideSkeletonWithCrossfade() }
    }
}

private extension CourseListVMTableViewCell {
    func prepareContentFadeInIfNeeded() {
        [coverImgView, titleLab, detailLab].forEach { view in
            guard view.isSkeletonActive else { return }
            view.alpha = 0
        }
    }
}

extension CourseListVMTableViewCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(coverImgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(detailLab)
     
        setConstrait()
        bgView.addShadow()
//        bgView.addShadow(opacity: 0.05)
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-12))
            make.top.equalToSuperview()
        }
        coverImgView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(imgHeight)
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(coverImgView.snp.bottom).offset(kFitWidth(12))
            make.right.equalTo(kFitWidth((-16)))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(4))
            make.bottom.equalTo(kFitWidth(-12))
        }
    }
}
