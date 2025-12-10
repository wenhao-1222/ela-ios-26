//
//  ServiceContactTableViewTextCell.swift
//  lns
//
//  Created by LNS2 on 2024/6/12.
//

import Foundation
import Kingfisher

class ServiceContactTableViewTextCell: UITableViewCell {
    var addressTapBlock:(()->())?
    
    private var avatarRequestID = UUID()
    private var addressTapGesture: UITapGestureRecognizer?
    private var hasAddressLink = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarRequestID = UUID()
        hasAddressLink = false
        removeAddressTapGesture()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(19)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var msgLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.layer.cornerRadius = kFitWidth(12)
        lab.clipsToBounds = true
        lab.textInsets = UIEdgeInsets(top: kFitWidth(6), left: kFitWidth(11), bottom: kFitWidth(6), right: kFitWidth(11))
        lab.customLineHeight = lab.font.lineHeight * 1.2
        
        return lab
    }()
}

extension ServiceContactTableViewTextCell{
    func updateUI(dict:NSDictionary) {
        self.updateTextContent(dict: dict)
        setNeedsLayout()
        layoutIfNeeded()
    }
    func updateUIForMarket(dict:NSDictionary) {
        self.updateTextContent(dict: dict,keyString: "text")
        setNeedsLayout()
        layoutIfNeeded()
    }
    func updateTextContent(dict:NSDictionary,keyString:String = "suggestion") {
        let msgString = "\(dict.stringValueForKey(key: keyString))"
        let isAdmin = dict.stringValueForKey(key: "createdby") == "admin" || dict.stringValueForKey(key: "createdBy") == "admin"
        let containsAddress = msgString.contains("收货地址")
        hasAddressLink = isAdmin && containsAddress

        // 头像
        configureAvatar(isAdmin: isAdmin)

        // 先设置文本（很重要）
        if containsAddress {
            let attr = NSMutableAttributedString(string: msgString)
            let range = (msgString as NSString).range(of: "收货地址")
            attr.addAttribute(.foregroundColor, value: UIColor.THEME, range: range)
            msgLabel.attributedText = attr
        } else {
            msgLabel.text = msgString
        }

        let maxBubbleWidth = kFitWidth(250)
        // ⭐ 关键：根据当前这条消息内容，算出“应该有多宽”的气泡
        let bubbleWidth = bubbleWidthForCurrentMessage(maxBubbleWidth: maxBubbleWidth)
        let msgHeight = msgLabel.sizeThatFits(CGSize(width: bubbleWidth, height: .greatestFiniteMagnitude)).height
        let headHeight = kFitWidth(38)
        let isMsgTallerThanHead = msgHeight > headHeight
        if !isAdmin {    // 右侧（用户）
            headImgView.snp.remakeConstraints { make in
                make.right.equalTo(-kFitWidth(16))
//                make.top.equalTo(msgLabel)
                make.top.equalTo(kFitWidth(10))
                make.width.height.equalTo(kFitWidth(38))
                if !isMsgTallerThanHead {
                    make.bottom.equalTo(-kFitWidth(10))
                }
            }

            msgLabel.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(10))
                // 气泡紧挨头像左侧，留一点间距
//                make.right.equalTo(headImgView.snp.left).offset(-kFitWidth(8))
                make.right.equalTo(kFitWidth(-62))
//                make.bottom.equalTo(-kFitWidth(10))
                // ⭐ 这里用 equalTo，而不是 lessThanOrEqualTo
                make.width.equalTo(bubbleWidth)
                if isMsgTallerThanHead {
                    make.bottom.equalTo(-kFitWidth(10))
                }
            }

            msgLabel.textAlignment = .left
            msgLabel.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)

        } else {         // 左侧（管理员）
            headImgView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
//                make.top.equalTo(msgLabel)
                make.top.equalTo(kFitWidth(10))
                make.width.height.equalTo(kFitWidth(38))
                if isMsgTallerThanHead {
                    make.bottom.equalTo(-kFitWidth(10))
                }
            }

            msgLabel.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(10))
//                make.left.equalTo(headImgView.snp.right).offset(kFitWidth(8))
                make.left.equalTo(kFitWidth(62))
//                make.bottom.equalTo(-kFitWidth(10))
                make.width.equalTo(bubbleWidth)
                if isMsgTallerThanHead {
                    make.bottom.equalTo(-kFitWidth(10))
                }
            }

            msgLabel.textAlignment = .left
            msgLabel.backgroundColor = .COLOR_CARD_BG_WHITE
        }

        msgLabel.isUserInteractionEnabled = hasAddressLink
        if hasAddressLink { addAddressTapGestureIfNeeded() }
        else { removeAddressTapGesture() }
    }

    @objc private func addressTapAction() {
          guard hasAddressLink else { return }
          addressTapBlock?()
      }

      private func addAddressTapGestureIfNeeded() {
          if addressTapGesture == nil {
              let tap = UITapGestureRecognizer(target: self, action: #selector(addressTapAction))
              msgLabel.addGestureRecognizer(tap)
              addressTapGesture = tap
          }
      }

      private func removeAddressTapGesture() {
          if let tap = addressTapGesture {
              msgLabel.removeGestureRecognizer(tap)
              addressTapGesture = nil
          }
      }
}
extension ServiceContactTableViewTextCell{
    func initUI() {
        contentView.addSubview(headImgView)
        contentView.addSubview(msgLabel)
        // 只控制竖直方向，让高度跟内容走
        msgLabel.setContentHuggingPriority(.required, for: .vertical)
        msgLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}

private extension ServiceContactTableViewTextCell {
    func configureAvatar(isAdmin: Bool) {
        avatarRequestID = UUID()
        let requestID = avatarRequestID

        headImgView.kf.cancelDownloadTask()

        guard !isAdmin else {
            headImgView.image = UIImage(named: "avatar_default")
            return
        }

        let placeholder = UIImage(named: "avatar_default")
        let avatarUrl = UserInfoModel.shared.headimgurl

        guard !avatarUrl.isEmpty else {
            headImgView.image = placeholder
            return
        }

        let setImage: (URL) -> Void = { [weak self] url in
            guard let self = self else { return }
            self.headImgView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.keepCurrentImageWhileLoading, .transition(.fade(0.2))]
            ) { [weak self] result in
                guard let self = self, self.avatarRequestID == requestID else { return }
                if case .failure = result {
                    self.headImgView.image = placeholder
                }
            }
        }

        if avatarUrl.contains("aliyuncs.com") {
            DSImageUploader().dealImgUrlSignForOss(urlStr: avatarUrl) { [weak self] signedUrl in
                guard let self = self, self.avatarRequestID == requestID else { return }
                guard let resourceUrl = URL(string: signedUrl) else {
                    self.headImgView.image = placeholder
                    return
                }
                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: avatarUrl)
                self.headImgView.kf.setImage(
                    with: resource,
                    placeholder: placeholder,
                    options: [.keepCurrentImageWhileLoading, .transition(.fade(0.2))]
                ) { [weak self] result in
                    guard let self = self, self.avatarRequestID == requestID else { return }
                    if case .failure = result {
                        self.headImgView.image = placeholder
                    }
                }
            }
        } else if let url = URL(string: avatarUrl) {
            setImage(url)
        } else {
            headImgView.image = placeholder
        }
    }
}

private extension ServiceContactTableViewTextCell {

    /// 微信式：最大宽度 maxBubbleWidth，不够就按实际宽度来
    func bubbleWidthForCurrentMessage(maxBubbleWidth: CGFloat) -> CGFloat {
        // 允许的最大宽度（包含 textInsets）
        let maxSize = CGSize(width: maxBubbleWidth, height: .greatestFiniteMagnitude)

        // 会调用你重写过的 sizeThatFits，里面已经考虑了 textInsets / customLineHeight
        let fittingSize = msgLabel.sizeThatFits(maxSize)

        // fittingSize.width 本身不会超过 maxBubbleWidth，再保护一下
        let width = min(fittingSize.width + kFitWidth(1), maxBubbleWidth)

        // 可选：给个最小宽度，防止“牛头”两个字太窄
        let minBubbleWidth = msgLabel.text?.count ?? 0 > 1 ? kFitWidth(50) : kFitWidth(30)
        return max(minBubbleWidth, width)
    }
}
