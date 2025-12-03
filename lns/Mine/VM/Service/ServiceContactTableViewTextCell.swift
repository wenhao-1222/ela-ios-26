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
        lab.textInsets = UIEdgeInsets(top: kFitWidth(6), left: kFitWidth(11), bottom: kFitWidth(10), right: kFitWidth(11))
        lab.customLineHeight = lab.font.lineHeight * 1.2
        
        return lab
    }()
}

extension ServiceContactTableViewTextCell{
    func updateUI(dict:NSDictionary) {
        self.updateTextContent(dict: dict)
//        setNeedsLayout()
//        layoutIfNeeded()
    }
    func updateTextContent(dict:NSDictionary) {

        let msgString = "\(dict.stringValueForKey(key: "suggestion"))"
        let isAdmin = dict.stringValueForKey(key: "createdby") == "admin"
        let containsAddress = msgString.contains("收货地址")
        hasAddressLink = isAdmin && containsAddress

        var textBottomGap = kFitWidth(-10)

        // 计算文字宽度（不再额外加 6）
        var labelWidth = WHUtils().getWidthOfString(
            string: msgString,
            font: UIFont.systemFont(ofSize: 14),
            height: kFitWidth(14)
        )
        labelWidth = labelWidth + kFitWidth(8)
        // 限制最大/最小宽度
        if labelWidth > kFitWidth(250) {
            labelWidth = kFitWidth(258)
        } else if labelWidth < kFitWidth(30) {
            labelWidth = kFitWidth(30)
            textBottomGap = kFitWidth(-26)
        } else {
            textBottomGap = kFitWidth(-26)
        }
        
        // 设置头像
        configureAvatar(isAdmin: isAdmin)

        // 头像 & 气泡布局
        if !isAdmin {
            // 右侧（用户）
            headImgView.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-16))
                make.top.equalTo(msgLabel)
                make.width.height.equalTo(kFitWidth(38))
            }
            msgLabel.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(10))
                make.right.equalTo(kFitWidth(-65))
                make.bottom.equalTo(kFitWidth(-10))
                make.width.equalTo(labelWidth)
            }
            msgLabel.textAlignment = .right
            msgLabel.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)

        } else {
            // 左侧（管理员）
            headImgView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(msgLabel)
                make.width.height.equalTo(kFitWidth(38))
            }
            msgLabel.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(10))
                make.left.equalTo(kFitWidth(65))
                make.bottom.equalTo(textBottomGap)
                make.width.equalTo(labelWidth) // ←★ 关键修改
            }
            msgLabel.textAlignment = .left
            msgLabel.backgroundColor = .COLOR_CARD_BG_WHITE.withAlphaComponent(0.55)
        }

        // 富文本（高亮“收货地址”）
        let attr = NSMutableAttributedString(string: msgString)
        if containsAddress {
            let range = (msgString as NSString).range(of: "收货地址")
            attr.addAttribute(.foregroundColor, value: UIColor.THEME, range: range)
            msgLabel.attributedText = attr
        }else{
            msgLabel.text = msgString
        }
        // 点击事件
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
