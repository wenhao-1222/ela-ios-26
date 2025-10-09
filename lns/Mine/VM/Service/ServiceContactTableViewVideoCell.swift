//
//  ServiceContactTableViewVideoCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/25.
//

import UIKit
import SnapKit
import Kingfisher

protocol ServiceContactTableViewVideoCellDelegate: AnyObject {
    func serviceContactVideoCellDidTogglePause(_ cell: ServiceContactTableViewVideoCell)
    func serviceContactVideoCellDidTapPlay(_ cell: ServiceContactTableViewVideoCell)
}

class ServiceContactTableViewVideoCell: UITableViewCell {

    weak var delegate: ServiceContactTableViewVideoCellDelegate?
    var refreshHeightBlock:((CGRect)->())?
    var playBlock:(()->())?

    private(set) var messageId: String = ""
    var videoURLString: String?

    private let videoContainerView = UIView()
    private let thumbnailImageView = UIImageView()
    private let playIconView = UIImageView(image: UIImage(named: "video_play_icon"))
    private let durationLabel = UILabel()
    private let progressRing = ServiceVideoProgressRing()

    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?
    private var widthConstraint: Constraint?
    private var heightConstraint: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(18)
        img.clipsToBounds = true
        
        return img
    }()
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        messageId = ""
        videoURLString = nil
        playIconView.isHidden = false
        progressRing.displayState = .hidden
        durationLabel.text = nil
        durationLabel.isHidden = true
    }

    func updateUI(dict:NSDictionary) {
        DLLog(message: "视频消息体：\(dict)")
        headImgView.image = nil
        messageId = dict.stringValueForKey(key: "messageId")
        let material = dict["material"]as? NSArray ?? []
        if material.count > 0{
            let materialDict = material[0]as? NSDictionary ?? [:]
            updateThumbnail(from: materialDict)
            updateVideoSize(using: materialDict)
            updateDuration(from: materialDict)
            videoURLString = materialDict.stringValueForKey(key: "videoOssUrl")
        }
        
        if dict.stringValueForKey(key: "createdby") != "admin"{
            updateAlignment(isOutgoing: true)
            headImgView.setImgUrl(urlString: UserInfoModel.shared.headimgurl)
            headImgView.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-10))
                make.top.equalTo(kFitWidth(5))
                make.width.height.equalTo(kFitWidth(36))
            }
        }else{
            updateAlignment(isOutgoing: false)
            headImgView.setImgLocal(imgName: "avatar_default")
            headImgView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(10))
                make.top.equalTo(kFitWidth(5))
                make.width.height.equalTo(kFitWidth(36))
            }
        }
        let progressValue = CGFloat(dict.doubleValueForKey(key: "videoUploadProgress"))
        let stateString = dict.stringValueForKey(key: "videoUploadState")
        let state = ServiceContactVC.VideoUploadState(rawValue: stateString) ?? .completed
        apply(state: state, progress: progressValue)
    }
    // MARK: - Public, progress-only update (no layout/thumbnail changes)
    func updateProgressUI(state: ServiceContactVC.VideoUploadState, progress: CGFloat) {
        apply(state: state, progress: progress) // 你已有的内部方法
    }
    func configure(with dict: NSDictionary, videoURLString: String?, currentUserAvatar _: String) {
        messageId = dict.stringValueForKey(key: "messageId")
        self.videoURLString = videoURLString

        let isOutgoing = dict.stringValueForKey(key: "createdby") != "admin"
        updateAlignment(isOutgoing: isOutgoing)
        updateThumbnail(from: dict)
        updateDuration(from: dict)
        updateVideoSize(using: dict)

        let progressValue = CGFloat(dict.doubleValueForKey(key: "videoUploadProgress"))
        let stateString = dict.stringValueForKey(key: "videoUploadState")
        let state = ServiceContactVC.VideoUploadState(rawValue: stateString) ?? .completed
        apply(state: state, progress: progressValue)
    }
    func updateVideo(assetUrl:URL) {
        let img = VideoUtils().gp_getVideoPreViewImage(path: assetUrl)
        
        self.thumbnailImageView.image = img
//        self.timeLabel.text = VideoUtils().wm_getFileDuration(assetUrl)
        DLLog(message: "获取视频第一帧：\(assetUrl)")
        DLLog(message: "获取视频第一帧： 尺寸\(img.size.width) -- \(img.size.height)")
        let videoRect = self.dealVideoFrame(img: img)
        DLLog(message: "获取视频第一帧： 尺寸\(videoRect.width) -- \(videoRect.height)")
        ForumPublishManager.shared.saveVideoCoverImg(image: img)
        VideoEditModel.shared.videoCoverImage = img
        VideoEditModel.shared.videoCoverImageSize = CGSize.init(width: videoRect.width, height: videoRect.height)
        
//        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_w", data: "\(Int(videoRect.width))", cTime: ForumPublishManager.shared.cTime)
//        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_h", data: "\(Int(videoRect.height))", cTime: ForumPublishManager.shared.cTime)
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_w", data: "\(Int(img.size.width))", cTime: ForumPublishManager.shared.cTime)
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_h", data: "\(Int(img.size.height))", cTime: ForumPublishManager.shared.cTime)
        DLLog(message: "updateVideo(assetUrl: \(videoRect.width) --- \(videoRect.height)")
        thumbnailImageView.snp.remakeConstraints { make in
            make.height.equalTo(videoRect.height)
            make.width.equalTo(videoRect.width)
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(0))
            make.top.equalTo(kFitWidth(0))
        }
        self.refreshHeightBlock?(videoRect)
    }
    func dealVideoFrame(img:UIImage) -> CGRect {
        let videoMaxWidth = kFitWidth(343)
        let imgOriginWidth = img.size.width > 0 ? img.size.width : 1
        let imgOriginHeight = img.size.height > 0 ? img.size.height : 1
        
        if imgOriginHeight > imgOriginWidth{
            let imgWidth = imgOriginWidth/imgOriginHeight*videoMaxWidth
            return CGRect.init(x: (SCREEN_WIDHT-imgWidth)*0.5, y: 0, width: imgWidth, height: videoMaxWidth)
        }
        if imgOriginWidth > videoMaxWidth{
            let imgHeight = imgOriginHeight*videoMaxWidth/imgOriginWidth
            return CGRect.init(x: kFitWidth(16), y: 0, width: videoMaxWidth, height: imgHeight)
        }
        
        return CGRect.init(x: (SCREEN_WIDHT-imgOriginWidth)*0.5, y: 0, width: imgOriginWidth, height: imgOriginHeight)
    }

    private func setupUI() {
        contentView.addSubview(headImgView)
        contentView.addSubview(videoContainerView)
        videoContainerView.backgroundColor = .black
        videoContainerView.layer.cornerRadius = kFitWidth(8)
        videoContainerView.clipsToBounds = true

        videoContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kFitWidth(6))
            make.bottom.equalToSuperview().offset(-kFitWidth(6))
            widthConstraint = make.width.equalTo(0).constraint
            heightConstraint = make.height.equalTo(0).constraint
            leadingConstraint = make.left.equalToSuperview().offset(kFitWidth(60)).constraint
            trailingConstraint = make.right.equalToSuperview().offset(-kFitWidth(60)).constraint
        }
        trailingConstraint?.deactivate()

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.isUserInteractionEnabled = true
        videoContainerView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(playTapped))
        thumbnailImageView.addGestureRecognizer(tap)

        playIconView.contentMode = .scaleAspectFit
        videoContainerView.addSubview(playIconView)
        playIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(44))
        }

        durationLabel.font = .systemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = .white
        durationLabel.textAlignment = .center
        durationLabel.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        durationLabel.layer.cornerRadius = kFitWidth(12)
        durationLabel.clipsToBounds = true
        durationLabel.isHidden = true
        videoContainerView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kFitWidth(8))
            make.bottom.equalToSuperview().offset(-kFitWidth(8))
            make.height.equalTo(kFitWidth(24))
            make.width.greaterThanOrEqualTo(kFitWidth(48))
        }

        progressRing.isHidden = true
        progressRing.addTarget(self, action: #selector(progressRingTapped), for: .touchUpInside)
        videoContainerView.addSubview(progressRing)
        progressRing.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(56))
        }
    }

    private func updateAlignment(isOutgoing: Bool) {
        if isOutgoing {
            leadingConstraint?.deactivate()
            trailingConstraint?.activate()
        } else {
            trailingConstraint?.deactivate()
            leadingConstraint?.activate()
        }
    }

    private func updateThumbnail(from dict: NSDictionary) {
        if let thumbnail = dict.object(forKey: "localImg") as? UIImage {
            thumbnailImageView.image = thumbnail
        } else if let coverString = dict.object(forKey: "coverImageOssUrl") as? String,
                  !coverString.isEmpty,
                  let encoded = coverString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: encoded) {
            thumbnailImageView.setImgUrl(urlString: coverString)
//            let resource = KF.ImageResource(downloadURL: url, cacheKey: coverString)
//            thumbnailImageView.kf.setImage(with: resource, placeholder: createImageWithColor(color: .COLOR_BG_F5))
        } else {
            thumbnailImageView.image = createImageWithColor(color: .COLOR_BG_F5)
        }
    }

    private func updateDuration(from dict: NSDictionary) {
        var duration = dict.doubleValueForKey(key: "videoDuration")
        duration = duration*0.001
        if duration <= 0 {
            duration = dict.doubleValueForKey(key: "duration")
        }
        if duration > 0 {
            durationLabel.isHidden = false
            durationLabel.text = Self.formattedDuration(duration)
        } else {
            durationLabel.isHidden = true
        }
    }

    private func updateVideoSize(using dict: NSDictionary) {
        let displaySize = Self.displaySize(from: dict)
        widthConstraint?.update(offset: displaySize.width)
        heightConstraint?.update(offset: displaySize.height)
    }

    private func apply(state: ServiceContactVC.VideoUploadState, progress: CGFloat) {
        let updateUI = { [weak self] in
            guard let self else { return }
            let clamped = max(0, min(1, progress))
            switch state {
            case .completed:
                self.progressRing.displayState = .hidden
                self.progressRing.isHidden = true
                self.playIconView.isHidden = false
            case .preparing:
                self.progressRing.displayState = .preparing
                self.playIconView.isHidden = true
            case .uploading:
                self.progressRing.displayState = .uploading(progress: clamped)
                self.playIconView.isHidden = true
                if progress == 1{
                    self.progressRing.displayState = .hidden
                    self.progressRing.isHidden = true
                    self.playIconView.isHidden = false
                }
            case .paused:
                self.progressRing.displayState = .paused(progress: clamped)
                self.playIconView.isHidden = true
            case .failed:
                self.progressRing.displayState = .failed(progress: clamped)
                self.playIconView.isHidden = true
            }
        }

        if Thread.isMainThread {
            updateUI()
        } else {
            DispatchQueue.main.async(execute: updateUI)
        }
//        let clamped = max(0, min(1, progress))
//        switch state {
//        case .completed:
//            progressRing.displayState = .hidden
//            playIconView.isHidden = false
//        case .preparing:
//            progressRing.displayState = .preparing
//            playIconView.isHidden = true
//        case .uploading:
//            progressRing.displayState = .uploading(progress: clamped)
//            playIconView.isHidden = true
//        case .paused:
//            progressRing.displayState = .paused(progress: clamped)
//            playIconView.isHidden = true
//        case .failed:
//            progressRing.displayState = .failed(progress: clamped)
//            playIconView.isHidden = true
//        }
    }

    @objc private func progressRingTapped() {
        delegate?.serviceContactVideoCellDidTogglePause(self)
    }

    @objc private func playTapped() {
        self.playBlock?()
        delegate?.serviceContactVideoCellDidTapPlay(self)
    }

    private static func displaySize(from dict: NSDictionary) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width * 0.55
        let originalSize = resolvedVideoSize(from: dict)
        guard let original = originalSize else {
            return CGSize(width: maxWidth, height: maxWidth * 9 / 16)
        }
        var width = CGFloat(original.width)
        var height = CGFloat(original.height)
        if width <= 0 || height <= 0 {
            return CGSize(width: maxWidth, height: maxWidth * 9 / 16)
        }
        if width > maxWidth {
            let scale = maxWidth / width
            width = maxWidth
            height *= scale
        }
        return CGSize(width: width, height: height)
    }

    private static func resolvedVideoSize(from dict: NSDictionary) -> CGSize? {
        let widthKeys = ["videoWidth", "width", "videoW", "coverWidth"]
        let heightKeys = ["videoHeight", "height", "videoH", "coverHeight"]

        var width: Double = 0
        for key in widthKeys {
            let value = dict.doubleValueForKey(key: key)
            if value > 0 {
                width = value
                break
            }
        }

        var height: Double = 0
        for key in heightKeys {
            let value = dict.doubleValueForKey(key: key)
            if value > 0 {
                height = value
                break
            }
        }

        if width > 0, height > 0 {
            return CGSize(width: width, height: height)
        }

        if let thumbnail = dict.object(forKey: "localImg") as? UIImage,
           thumbnail.size.width > 0,
           thumbnail.size.height > 0 {
            return thumbnail.size
        }

        return nil
    }

    private static func formattedDuration(_ duration: Double) -> String {
        guard duration.isFinite else { return "00:00" }
        let totalSeconds = max(0, Int(duration.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
