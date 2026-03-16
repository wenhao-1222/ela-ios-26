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
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .COLOR_CARD_BG_WHITE
        contentView.backgroundColor = .COLOR_CARD_BG_WHITE

        contentView.addSubview(bgView)
        bgView.addSubview(degreeImgView)
        bgView.addSubview(rankLabel)
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
        degreeImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(30))
        }
        rankLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(27))
            make.centerY.equalToSuperview()
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
        rankLabel.text = "\(rankInt)"

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
        switch rankInt {
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
    func currentAvatarImage() -> UIImage? {
        return avatarImageView.image
    }

    func applyAvatarImage(_ image: UIImage?) {
        avatarImageView.image = image
    }
}

private extension HabitRankTableViewCell {
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
