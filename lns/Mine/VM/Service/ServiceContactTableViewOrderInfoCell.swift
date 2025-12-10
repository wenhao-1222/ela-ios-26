//
//  ServiceContactTableViewOrderInfoCell.swift
//  lns
//ServiceContactTableViewOrderInfoCell
//  Created by LNS2 on 2025/12/10.
//
import Foundation
import Kingfisher
import SnapKit


class ServiceContactTableViewOrderInfoCell: UITableViewCell {
    
    private var avatarRequestID = UUID()
    
    var tapBlock:(()->())?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarRequestID = UUID()
        goodsImgView.kf.cancelDownloadTask()
        goodsImgView.image = nil
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
        
        self.isUserInteractionEnabled = true
    }
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(19)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var goodgBgView: UIView = {
        let vi = UIView()
        
        return vi
    }()
    private lazy var goodsImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(10)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        
        return img
    }()

    private lazy var goodsNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 2
        return lab
    }()

    private lazy var goodsSubtitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 2
        return lab
    }()

    private lazy var orderNoLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.numberOfLines = 2
        return lab
    }()
}

extension ServiceContactTableViewOrderInfoCell{
    func updateUI(dict:NSDictionary) {
        let orderInfo = dict["orderInfoCard"] as? NSDictionary ?? [:]
        let isAdmin = dict.stringValueForKey(key: "createdby") == "admin" || dict.stringValueForKey(key: "createdBy") == "admin"

        configureAvatar(isAdmin: isAdmin)
        layoutForRole(isAdmin: isAdmin)
        
        let orderNo = "订单号 \(orderInfo.stringValueForKey(key: "orderId"))"
        orderNoLabel.text = orderNo
        orderNoLabel.isHidden = false
        goodsNameLabel.text = ""
        goodsSubtitleLabel.text = ""
        
        let goodsList = orderInfo["goodsList"]as? NSArray ?? []
        
        if goodsList.count > 0{
            let goodsInfo = goodsList[0]as? NSDictionary ?? [:]
            goodsNameLabel.text = goodsInfo.stringValueForKey(key: "name")
            goodsSubtitleLabel.text = goodsInfo.stringValueForKey(key: "spec")
            
            if let imagesArr = goodsInfo["images"] as? [String], let first = imagesArr.first {
                loadGoodsImage(urlString: first)
            }else if let imagesArr = goodsInfo["images"] as? NSArray, let first = imagesArr.firstObject as? String{
                loadGoodsImage(urlString: first)
            }
        }else{
            let tutorialInfo = orderInfo["tutorial"]as? NSDictionary ?? [:]
            goodsNameLabel.text = tutorialInfo.stringValueForKey(key: "name")
            goodsSubtitleLabel.text = tutorialInfo.stringValueForKey(key: "subtitle")
            if let imagesArr = tutorialInfo["images"] as? [String], let first = imagesArr.first {
                loadGoodsImage(urlString: first)
            }else if let imagesArr = tutorialInfo["images"] as? NSArray, let first = imagesArr.firstObject as? String{
                loadGoodsImage(urlString: first)
            }
        }
    }
}

private extension ServiceContactTableViewOrderInfoCell {
    @objc func tapAction() {
        self.tapBlock?()
    }
}

private extension ServiceContactTableViewOrderInfoCell {
    func initUI() {
        contentView.addSubview(headImgView)
        contentView.addSubview(whiteView)
        whiteView.addSubview(goodgBgView)
        whiteView.addSubview(orderNoLabel)
        goodgBgView.addSubview(goodsImgView)

        let infoStack = UIStackView(arrangedSubviews: [goodsNameLabel, goodsSubtitleLabel])
        infoStack.axis = .vertical
        infoStack.spacing = kFitWidth(4)
        infoStack.alignment = .leading
        goodgBgView.addSubview(infoStack)

        goodgBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: kFitWidth(35), left: kFitWidth(12), bottom: kFitWidth(12), right: kFitWidth(12)))
        }

        goodsImgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(80))
            make.bottom.lessThanOrEqualToSuperview()
        }
        orderNoLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.height.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(10))
//            make.top.equalTo(kFitWidth(96))
        }

        infoStack.snp.makeConstraints { make in
            make.left.equalTo(goodsImgView.snp.right).offset(kFitWidth(12))
            make.top.equalTo(goodsImgView)
            make.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    func loadGoodsImage(urlString: String) {
        guard !urlString.isEmpty else { return }

        if urlString.contains("aliyuncs.com") {
            DSImageUploader().dealImgUrlSignForOss(urlStr: urlString) { [weak self] signUrl in
                guard let self = self else { return }
                self.setGoodsImage(urlString: signUrl, cacheKey: urlString)
            }
        } else {
            setGoodsImage(urlString: urlString, cacheKey: urlString)
        }
    }

    func setGoodsImage(urlString: String, cacheKey: String) {
        guard let url = URL(string: urlString) else { return }
        let resource = KF.ImageResource(downloadURL: url, cacheKey: cacheKey)
        goodsImgView.kf.setImage(with: resource, placeholder: createImageWithColor(color: .COLOR_TEXT_TITLE_0f1214_05), options: [.transition(.fade(0.2))])
    }

    func layoutForRole(isAdmin: Bool) {
        headImgView.snp.remakeConstraints { make in
            make.top.equalTo(kFitWidth(10))
            make.width.height.equalTo(kFitWidth(38))
            if isAdmin {
                make.left.equalTo(kFitWidth(16))
            } else {
                make.right.equalTo(kFitWidth(-16))
            }
        }

        whiteView.snp.remakeConstraints { make in
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(-kFitWidth(10))
            make.width.equalTo(kFitWidth(256))
            if isAdmin {
                make.left.equalTo(kFitWidth(62))
//                make.right.lessThanOrEqualToSuperview().offset(-kFitWidth(57))
            } else {
                make.right.equalTo(kFitWidth(-62))
//                make.left.greaterThanOrEqualToSuperview().offset(kFitWidth(57))
            }
        }
    }

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
