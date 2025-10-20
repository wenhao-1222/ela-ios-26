//
//  CourseItemCell.swift
//  lns
//
//  Created by Elavatine on 2025/4/14.
//
import UIKit

class CourseItemCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .COLOR_BG_F5
        selectionStyle = .none
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    lazy var bgView: GradientView = {
        let view = GradientView()
        view.backgroundColor = .white
        view.layer.cornerRadius = kFitWidth(13)
        view.clipsToBounds = true
        
        return view
    }()
    
    lazy var coverImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(9)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .COLOR_BG_F5

        return img
    }()
    lazy var lockedBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "FF8725")
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var lockedImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_locked_icon")
        
        return img
    }()
    lazy var lockCoverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.3)
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isHidden = true
        
        return vi
    }()
    lazy var videoPlayImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_last_play_icon")
        img.isUserInteractionEnabled = true
        return img
    }()
    
    lazy var videoDurationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear//.COLOR_GRAY_BLACK_25
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = kFitWidth(6)
        label.clipsToBounds = true
        label.isHidden = true
        
        return label
    }()
    lazy var progressBgView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_C4C4C4
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        vi.isHidden = true
        
        return vi
    }()
    lazy var progressView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "FF8725")
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping

        return label
    }()
    
    lazy var detailLab: LineHeightLabel = {
        let label = LineHeightLabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping

        return label
    }()
}

extension CourseItemCell{
    // MARK: - Public Methods
    func updateUI(dict: NSDictionary) {
        if dict.stringValueForKey(key: "title").isEmpty {
            coverImgView.image = nil
            titleLab.text = nil
            detailLab.text = nil
            lockCoverView.isHidden = true
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [coverImgView, titleLab,detailLab].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [coverImgView, titleLab,detailLab].forEach { $0.hideSkeletonWithCrossfade() }
        
        titleLab.snp.remakeConstraints { make in
            make.left.equalTo(coverImgView.snp.right).offset(kFitWidth(15))
            make.centerY.lessThanOrEqualTo(coverImgView)
            make.right.equalToSuperview().offset(kFitWidth(-15))
        }
        
        detailLab.snp.remakeConstraints { make in
            make.left.equalTo(coverImgView)
            make.top.equalTo(coverImgView.snp.bottom).offset(kFitWidth(12))
            make.right.equalToSuperview().offset(kFitWidth(-15))
            make.bottom.lessThanOrEqualToSuperview().offset(kFitWidth(-10))
        }
        detailLab.numberOfLines = 0
        titleLab.numberOfLines = 0
        titleLab.text = dict.stringValueForKey(key: "title")
        detailLab.text = dict.stringValueForKey(key: "subtitle")
        
        let covers = dict["cover"] as? [String] ?? []
        coverImgView.image = nil
//        coverImgView.backgroundColor = .COLOR_BG_F5
        if let cover = covers.first {
            coverImgView.isHidden = false
            coverImgView.setImgUrl(urlString: cover)
        } else {
            coverImgView.isHidden = true
        }
        
        let material = dict["material"] as? NSDictionary ?? [:]
        let videos = material["video"] as? NSArray ?? []
        
        videoDurationLabel.isHidden = true
        if let videoDict = videos.firstObject as? NSDictionary {
            let duration = videoDict.stringValueForKey(key: "videoDuration").intValue / 1000
            if duration > 0 {
                let minutes = duration / 60
                let seconds = duration % 60
                videoDurationLabel.text = String(format: "%02d:%02d", minutes, seconds)
                videoDurationLabel.isHidden = false
            }
        }
        updateProgress(dict: dict)
    }
    func updateProgress(dict: NSDictionary) {
        let progress = CourseProgressSQLiteManager.getInstance().queryProgress(tutorialId: dict.stringValueForKey(key: "id"))
        let duration = CourseProgressSQLiteManager.getInstance().queryDuration(tutorialId: dict.stringValueForKey(key: "id"))
        if progress > 0 {
            let percent = progress/duration
            progressBgView.isHidden = false
            progressView.frame = CGRect.init(x: 0, y: 0, width: (kFitWidth(110)-kFitWidth(18))*percent, height: kFitWidth(2))
        } else {
            progressBgView.isHidden = true
        }
    }
    func lockedUI() {
        lockCoverView.isHidden = false
    }
    func unlockUI() {
//        bgView.bringSubviewToFront(coverImgView)
        coverImgView.bringSubviewToFront(videoPlayImgView)
        coverImgView.bringSubviewToFront(progressBgView)
        coverImgView.bringSubviewToFront(videoDurationLabel)
        lockCoverView.isHidden = false
        lockedBgView.isHidden = true
//        UIView.animate(withDuration: 0.25, delay: 0) {
//            self.lockCoverView.alpha = 0
//        }completion: { _ in
//            self.lockCoverView.isHidden = true
//        }
    }
}

extension CourseItemCell{
    private func initUI() {
        isSkeletonable = true
        contentView.isSkeletonable = true
        contentView.addSubview(bgView)
        bgView.addSubview(coverImgView)
        
        coverImgView.addSubview(videoPlayImgView)
        
        coverImgView.addSubview(videoDurationLabel)
//        coverImgView.addSubview(progressLabel)
        coverImgView.addSubview(progressBgView)
        
        coverImgView.addSubview(lockCoverView)
        lockCoverView.addSubview(lockedBgView)
        lockedBgView.addSubview(lockedImgView)
        progressBgView.addSubview(progressView)
        bgView.addSubview(titleLab)
        bgView.addSubview(detailLab)
        
        setConstraints()
    }
    
    private func setConstraints() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(12))
            make.bottom.equalToSuperview()
        }
        
        coverImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(15))
            make.width.equalTo(kFitWidth(110))
            make.height.equalTo(kFitWidth(60))
        }
        progressBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(9))
            make.right.equalTo(kFitWidth(-9))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(2))
        }
//        progressView.snp.makeConstraints { make in
//            make.left.top.height.equalToSuperview()
//        }
        lockCoverView.snp.makeConstraints { make in
            make.left.top.width.height.equalTo(coverImgView)
        }
        lockedBgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(-8))
            make.right.equalTo(kFitWidth(8))
            make.width.equalTo(kFitWidth(30))
            make.height.equalTo(kFitWidth(22))
        }
        lockedImgView.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(12))
            make.height.equalTo(kFitWidth(12))
//            make.center.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(5))
            make.bottom.equalTo(kFitWidth(-1))
        }
        
        videoDurationLabel.snp.makeConstraints { make in
            make.right.bottom.equalTo(kFitWidth(-4))
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(18))
        }
        videoPlayImgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(14))
            make.height.equalTo(kFitWidth(18))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(coverImgView.snp.right).offset(kFitWidth(15))
//            make.top.equalTo(coverImgView)
            make.centerY.lessThanOrEqualTo(coverImgView)
            make.right.equalToSuperview().offset(kFitWidth(-15))
            make.height.equalTo(kFitWidth(18))
        }
        
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(coverImgView)
            make.top.equalTo(coverImgView.snp.bottom).offset(kFitWidth(12))
            make.right.equalToSuperview().offset(kFitWidth(-15))
            make.height.equalTo(kFitWidth(94))
            make.bottom.lessThanOrEqualToSuperview().offset(kFitWidth(-10))
        }
    }
}
