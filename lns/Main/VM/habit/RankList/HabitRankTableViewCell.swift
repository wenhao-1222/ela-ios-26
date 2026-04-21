//
//  HabitRankTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//

import UIKit
import SnapKit
import Kingfisher

class HabitRankTableViewCell: UITableViewCell {

    static let identifier = "HabitRankTableViewCell"
    private var avatarRequestID = UUID()
    private var currentAvatarURL = ""
    private var currentDisplayedRank = 0

    // MARK: - UI
    
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    
    lazy var degreeImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_ranklist_one")
        
        return img
    }()
    private let rankContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont().DDInFontMedium(fontSize: 20)
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 22
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        return label
    }()

    private let fireIcon: UIImageView = {
        let iv = UIImageView()
        iv.setImgLocal(imgName: "habit_ranklist_heart_icon")
        return iv
    }()

    private let fireLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .right
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return label
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont().DDInFontSemiBold(fontSize: 17)
        label.textAlignment = .right
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var nameStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            nameLabel,
            fireIcon,
            fireLabel
        ])
        stack.axis = .horizontal
        stack.spacing = kFitWidth(2)
        stack.alignment = .center
        return stack
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarRequestID = UUID()
        currentAvatarURL = ""
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
        rankContainerView.alpha = 1
        rankContainerView.transform = .identity
        rankContainerView.layer.sublayers?
            .filter { $0.name == "HabitRankSweepLayer" }
            .forEach { $0.removeFromSuperlayer() }
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .COLOR_CARD_BG_WHITE
        contentView.backgroundColor = .COLOR_CARD_BG_WHITE

        contentView.addSubview(bgView)
        bgView.addSubview(rankContainerView)
        rankContainerView.addSubview(degreeImgView)
        rankContainerView.addSubview(rankLabel)
        bgView.addSubview(avatarImageView)
        bgView.addSubview(nameStackView)
        bgView.addSubview(scoreLabel)
        // setupUI() 里
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        fireLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        fireLabel.setContentHuggingPriority(.required, for: .horizontal)

        bgView.snp.makeConstraints { make in
            make.left.top.width.bottom.equalToSuperview()
//            make.bottom.equalTo(kFitWidth(-25))
        }
        rankContainerView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(13))
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(46))
            make.height.equalTo(kFitWidth(32))
        }
        degreeImgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(30))
        }
        rankLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(59))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        nameStackView.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(kFitWidth(12))
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(scoreLabel.snp.left).offset(kFitWidth(-4))
        }

        fireIcon.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(15))
        }

        scoreLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(kFitWidth(-20))
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(37))
        }
    }

    // MARK: - Config
    func configure(
        rank: String,
        avatar: String,
        name: String,
        fireCount: Int?,
        score: String,
        needAvatarTransition: Bool = false,
        isCurrentUser: Bool = false
    ) {
        let previousAvatarURL = currentAvatarURL
        let shouldKeepCurrentAvatar = previousAvatarURL == avatar && avatarImageView.image != nil
        avatarRequestID = UUID()
        currentAvatarURL = avatar

        let rankInt = rank.intValue
        applyRankDisplay(rankInt)

        loadAvatar(urlString: avatar,
                   needTransition: needAvatarTransition,
                   keepCurrentImage: shouldKeepCurrentAvatar)
        
        nameLabel.text = name
        scoreLabel.text = "\(score)"
        
        fireIcon.isHidden = fireCount ?? 0 > 0 ? false : true
        fireLabel.isHidden = fireCount ?? 0 > 0 ? false : true
        if fireCount ?? 0 > 0 {
            fireLabel.text = "\(fireCount ?? 0)"
        }else{
            fireLabel.text = ""
        }
        
        bgView.backgroundColor = isCurrentUser ? .COLOR_CELL_HIGHLIGHT_BG : .clear
    }
    func currentAvatarImage() -> UIImage? {
        return avatarImageView.image
    }

    func applyAvatarImage(_ image: UIImage?) {
        avatarImageView.image = image
    }

    func animateRankTransition(to rank: Int,
                               duration: TimeInterval = 0.28,
                               completion: (() -> Void)? = nil) {
        guard rank != currentDisplayedRank else {
            completion?()
            return
        }

        addRankSweepLayer(duration: duration)

        UIView.animate(withDuration: 0.14,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.rankContainerView.transform = CGAffineTransform(scaleX: 1.14, y: 1.14)
                .translatedBy(x: 0, y: -1)
        }

        UIView.transition(with: rankContainerView,
                          duration: duration,
                          options: [.transitionCrossDissolve, .curveEaseInOut, .beginFromCurrentState, .showHideTransitionViews]) {
            self.applyRankDisplay(rank)
        } completion: { _ in
            UIView.animate(withDuration: 0.18,
                           delay: 0,
                           options: [.curveEaseOut, .beginFromCurrentState]) {
                self.rankContainerView.transform = .identity
            } completion: { _ in
                completion?()
            }
        }
    }

    func animateRankRefreshReveal(delay: TimeInterval = 0,
                                  duration: TimeInterval = 0.24) {
        rankContainerView.alpha = 0
        rankContainerView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            .translatedBy(x: 0, y: 2)
        addRankSweepLayer(duration: duration, beginTimeDelay: delay)

        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.rankContainerView.alpha = 1
            self.rankContainerView.transform = .identity
        }
    }

    func setRankVisualAlpha(_ alpha: CGFloat) {
        rankContainerView.alpha = alpha
    }
}

private extension HabitRankTableViewCell {
    func applyRankDisplay(_ rank: Int) {
        currentDisplayedRank = rank
        rankLabel.text = "\(rank)"

        switch rank {
        case 1:
            degreeImgView.isHidden = false
            rankLabel.isHidden = true
            degreeImgView.setImgLocal(imgName: "habit_ranklist_one")
        case 2:
            degreeImgView.isHidden = false
            rankLabel.isHidden = true
            degreeImgView.setImgLocal(imgName: "habit_ranklist_two")
        case 3:
            degreeImgView.isHidden = false
            rankLabel.isHidden = true
            degreeImgView.setImgLocal(imgName: "habit_ranklist_three")
        default:
            degreeImgView.isHidden = true
            rankLabel.isHidden = false
            degreeImgView.image = nil
        }
    }

    func addRankSweepLayer(duration: TimeInterval,
                           beginTimeDelay: TimeInterval = 0) {
        rankContainerView.layer.sublayers?
            .filter { $0.name == "HabitRankSweepLayer" }
            .forEach { $0.removeFromSuperlayer() }

        let sweepLayer = CAGradientLayer()
        sweepLayer.name = "HabitRankSweepLayer"
        sweepLayer.frame = rankContainerView.bounds.insetBy(dx: -kFitWidth(10), dy: 0)
        sweepLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.9).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        sweepLayer.locations = [0, 0.5, 1]
        sweepLayer.startPoint = CGPoint(x: 0, y: 0.5)
        sweepLayer.endPoint = CGPoint(x: 1, y: 0.5)
        sweepLayer.compositingFilter = "screenBlendMode"
        rankContainerView.layer.addSublayer(sweepLayer)

        let travel = rankContainerView.bounds.width + sweepLayer.bounds.width
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -travel * 0.5
        animation.toValue = travel * 0.5
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + beginTimeDelay
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            sweepLayer.removeFromSuperlayer()
        }
        sweepLayer.add(animation, forKey: "rank.sweep")
        CATransaction.commit()
    }

    func loadAvatar(urlString: String,
                    needTransition: Bool,
                    keepCurrentImage: Bool) {
        avatarImageView.kf.cancelDownloadTask()

        let requestID = avatarRequestID
        let placeholder = UIImage(named: "control_widget_icon")
        var options: KingfisherOptionsInfo = [.keepCurrentImageWhileLoading, .transition(.fade(0.2))]
        if !needTransition {
            options = [.keepCurrentImageWhileLoading]
        }

        guard !urlString.isEmpty else {
            avatarImageView.image = placeholder
            return
        }

        if keepCurrentImage {
            return
        }

        if let memoryImage = ImageCache.default.retrieveImageInMemoryCache(forKey: urlString) {
            avatarImageView.image = memoryImage
            return
        }

        avatarImageView.image = nil

        let applyCachedImage: (UIImage?) -> Bool = { [weak self] image in
            guard let self = self,
                  self.avatarRequestID == requestID,
                  self.currentAvatarURL == urlString,
                  let image = image else { return false }
            self.avatarImageView.image = image
            return true
        }

        let setImage: (Source) -> Void = { [weak self] source in
            guard let self = self else { return }
            self.avatarImageView.kf.setImage(
                with: source,
                placeholder: nil,
                options: options
            ) { [weak self] result in
                guard let self = self,
                      self.avatarRequestID == requestID,
                      self.currentAvatarURL == urlString else { return }
                if case .failure = result {
                    self.avatarImageView.image = placeholder
                }
            }
        }

        ImageCache.default.retrieveImage(forKey: urlString) { [weak self] result in
            guard let self = self,
                  self.avatarRequestID == requestID,
                  self.currentAvatarURL == urlString else { return }
            switch result {
            case .success(let value):
                if applyCachedImage(value.image) {
                    return
                }
                self.loadAvatarFromNetwork(urlString: urlString,
                                           placeholder: placeholder,
                                           requestID: requestID,
                                           setImage: setImage)
            case .failure:
                self.loadAvatarFromNetwork(urlString: urlString,
                                           placeholder: placeholder,
                                           requestID: requestID,
                                           setImage: setImage)
            }
        }
    }

    func loadAvatarFromNetwork(urlString: String,
                               placeholder: UIImage?,
                               requestID: UUID,
                               setImage: @escaping (Source) -> Void) {
        if urlString.contains("aliyuncs.com") {
            DSImageUploader().dealImgUrlSignForOss(urlStr: urlString) { [weak self] signedUrl in
                guard let self = self,
                      self.avatarRequestID == requestID,
                      self.currentAvatarURL == urlString else { return }
                guard let resourceURL = URL(string: signedUrl) else {
                    self.avatarImageView.image = placeholder
                    return
                }
                let resource = KF.ImageResource(downloadURL: resourceURL, cacheKey: urlString)
                setImage(.network(resource))
            }
            return
        }

        guard let url = URL(string: urlString) else {
            avatarImageView.image = placeholder
            return
        }
        setImage(.network(url))
    }
}
