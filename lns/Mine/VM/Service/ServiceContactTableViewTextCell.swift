//
//  ServiceContactTableViewTextCell.swift
//  lns
//
//  Created by LNS2 on 2024/6/12.
//

import Foundation
import Kingfisher

class ServiceContactTableViewTextCell: UITableViewCell {
    
    var imgWidth = kFitWidth(112)
    var imgHeight = kFitWidth(241)
    var imgGap = kFitWidth(6)
    
    var imgTapBlock:((UIImage?)->())?
    var addressTapBlock:(()->())?
    var viewModules:[HeroBrowserViewModule] = []
    
    private var avatarRequestID = UUID()
    private var addressTapGesture: UITapGestureRecognizer?
    private var hasAddressLink = false

    override func prepareForReuse() {
        super.prepareForReuse()
        headImgView.kf.cancelDownloadTask()
        headImgView.image = nil
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
        img.layer.cornerRadius = kFitWidth(18)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var msgLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
//        lab.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.8)
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        
        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.backgroundColor = .clear
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)
    
        return img
    }()
    lazy var msgRectView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension ServiceContactTableViewTextCell{
    func updateUI(dict:NSDictionary) {
        self.viewModules.removeAll()
        if dict.stringValueForKey(key: "suggestion").count > 0 {
            msgLabel.isHidden = false
            msgRectView.isHidden = false
            imgView.isHidden = true
            self.updateTextContent(dict: dict)
        }else{
            msgLabel.isHidden = true
            msgRectView.isHidden = true
            imgView.isHidden = false
            self.updateImgContent(dict: dict)
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    func updateTextContent(dict:NSDictionary) {
        let msgString = "\(dict.stringValueForKey(key: "suggestion"))"
        let isAdmin = dict.stringValueForKey(key: "createdby") == "admin"
        let containsAddress = false//msgString.contains("收货地址")
        hasAddressLink = isAdmin && containsAddress
        var textBottomGap = kFitWidth(-10)
        var labelWidth = WHUtils().getWidthOfString(string: msgString, font: UIFont.systemFont(ofSize: 14, weight: .regular), height: kFitWidth(14))
//        var labelWidth = msgString.mc_getWidth(font: .systemFont(ofSize: 14, weight: .regular), height: kFitWidth(14))
        labelWidth = labelWidth + kFitWidth(6)
        if labelWidth > kFitWidth(260){
            labelWidth = kFitWidth(26)
        }else if labelWidth < kFitWidth(30){
            labelWidth = kFitWidth(30)
            textBottomGap = kFitWidth(-26)
        }else{
            textBottomGap = kFitWidth(-26)
        }
        var labelHeight = msgString.mc_getHeight(font: .systemFont(ofSize: 14, weight: .regular), width: labelWidth-kFitWidth(6))
        
        var imgBottomGap = kFitWidth(-10)
        
        if labelHeight < kFitWidth(24){
            labelHeight = kFitWidth(24)
        }else if labelHeight > kFitWidth(43){
            imgBottomGap = -(labelHeight + kFitWidth(20) - kFitWidth(41))
            if labelWidth < kFitWidth(200){
                labelWidth = kFitWidth(260)
            }
        }
        headImgView.kf.cancelDownloadTask()
        headImgView.image = nil
        
        configureAvatar(isAdmin: isAdmin)

        if !isAdmin{
            headImgView.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-10))
                make.top.equalTo(kFitWidth(5))
                make.width.height.equalTo(kFitWidth(36))
            }
            msgLabel.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(10))
                make.right.equalTo(kFitWidth(-60))
                make.bottom.equalTo(textBottomGap)
                make.width.equalTo(labelWidth)
            }
            msgLabel.textAlignment = .right
            msgRectView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        }else{
            headImgView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(10))
                make.top.equalTo(kFitWidth(5))
                make.width.height.equalTo(kFitWidth(36))
            }
            msgLabel.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(10))
                make.left.equalTo(kFitWidth(60))
                make.bottom.equalTo(textBottomGap)
                make.width.equalTo(labelWidth)
            }
            msgLabel.textAlignment = .left
            msgRectView.backgroundColor = .COLOR_CARD_BG_WHITE.withAlphaComponent(0.55)//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.55)
        }
        
        let attr = NSMutableAttributedString(string: msgString)
        attr.yy_minimumLineHeight = kFitWidth(18)
        attr.yy_lineSpacing = kFitWidth(2)
        if containsAddress {
            let range = (msgString as NSString).range(of: "收货地址")
            attr.addAttribute(.foregroundColor, value: WHColor_16(colorStr: "007AFF"), range: range)
        }
        msgLabel.attributedText = attr
        msgLabel.isUserInteractionEnabled = hasAddressLink
//        if hasAddressLink {
//            addAddressTapGestureIfNeeded()
//        }else{
//            removeAddressTapGesture()
//        }
    }
    func updateImgContent(dict:NSDictionary) {
        let imagesStr = dict.stringValueForKey(key: "images")
        let imagesArr = WHUtils.getArrayFromJSONString(jsonString: imagesStr)
        let imgBottomGap = -imgHeight+kFitWidth(41)-kFitWidth(10)
        
        let isAdmin = dict.stringValueForKey(key: "createdby") == "admin"

        configureAvatar(isAdmin: isAdmin)

        headImgView.snp.remakeConstraints { make in
//            make.right.equalTo(kFitWidth(-10))
            if isAdmin {
                make.left.equalTo(kFitWidth(10))
            } else {
                make.right.equalTo(kFitWidth(-10))
            }
            make.top.equalTo(kFitWidth(5))
            make.width.height.equalTo(kFitWidth(36))
            make.bottom.equalTo(imgBottomGap)
        }
        
        if imagesArr.count > 0 {
//            imgView.setImgUrl(urlString: imagesArr[0] as? String ?? "")
//            imgHeight = kFitWidth(241)
            guard let imgUrl = URL(string: imagesArr[0] as? String ?? "") else { return }
            DSImageUploader().dealImgUrlSignForOss(urlStr: imagesArr[0] as? String ?? "") { signUrl in
                guard let resourceUrl = URL(string: signUrl) else{
                    return
                }
//                HeroBrowserLocalImageViewModule(image: <#T##UIImage#>)
                self.viewModules.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: signUrl, originImgUrl: signUrl))
                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: imagesArr[0] as? String ?? "")
                self.imgView.kf.setImage(with: resource,options: [.transition(.fade(0.2))]) { [self] result in
                    DLLog(message: "result:\(result)")
                    
                    var imgOriSize = imgView.image?.size
    //                let imgOriginH = imgWidth * ((imgOriSize?.height ?? 0) / (imgOriSize?.width ?? 1))
                    var imgOriginW = imgHeight * ((imgOriSize?.width ?? 0) / (imgOriSize?.height ?? 1))
                    if imgOriginW > SCREEN_WIDHT - kFitWidth(120){
                        imgOriginW = SCREEN_WIDHT - kFitWidth(120)
//                        imgHeight = imgOriginW * ((imgOriSize?.height ?? 0) / (imgOriSize?.width ?? 1))
                    }
                    let imgRect = CGRect.init(x: 0, y: 0, width: imgOriginW, height: imgHeight)
                    
                    imgView.frame = imgRect
                    DLLog(message: "index:\(index)--imgView---\(imgView.frame.origin.y)")
//                    if dict.stringValueForKey(key: "createdby") != "admin"{
//                        headImgView.setImgUrl(urlString: UserInfoModel.shared.headimgurl)
////                        headImgView.snp.remakeConstraints { make in
////                            make.right.equalTo(kFitWidth(-10))
////                            make.top.equalTo(kFitWidth(5))
////                            make.width.height.equalTo(kFitWidth(36))
////                            make.bottom.equalTo(imgBottomGap)
////                        }
                        
                    if !isAdmin{
                        imgView.snp.remakeConstraints { make in
                            make.right.equalTo(kFitWidth(-60))
                            make.top.equalTo(kFitWidth(10))
                            make.width.equalTo(imgOriginW)
                            make.height.equalTo(imgHeight)
                        }
                    }else{
//                        headImgView.setImgLocal(imgName: "avatar_default")
////                        headImgView.snp.remakeConstraints { make in
////                            make.left.equalTo(kFitWidth(10))
////                            make.top.equalTo(kFitWidth(5))
////                            make.width.height.equalTo(kFitWidth(36))
////                            make.bottom.equalTo(imgBottomGap)
////                        }
                        imgView.snp.remakeConstraints { make in
                            make.left.equalTo(kFitWidth(60))
                            make.top.equalTo(kFitWidth(5))
                            make.width.equalTo(imgOriginW)
                            make.height.equalTo(imgHeight)
                        }
                    }
                }
            }
        }
    }
    @objc func imgTapAction(){
        guard let vc = UIApplication.topViewController() else { return }
        if let img = self.imgView.image {
            vc.hero.browserPhoto(viewModules: [HeroBrowserLocalImageViewModule(image: self.imgView.image!)], initIndex: 0) {
                [
                    .pageControlType(.pageControl),
                    .heroView(self.imgView)
                ]
            }
        }else{
            if self.imgTapBlock != nil{
                self.imgTapBlock!(self.imgView.image ?? nil)
            }
        }
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
        contentView.addSubview(msgRectView)
        contentView.addSubview(msgLabel)
        contentView.addSubview(imgView)
        
        msgRectView.snp.makeConstraints { make in
            make.right.equalTo(msgLabel).offset(kFitWidth(4))
//            make.top.bottom.equalTo(msgLabel)
            make.top.equalTo(msgLabel).offset(kFitWidth(-4))
            make.bottom.equalTo(msgLabel).offset(kFitWidth(4))
            make.left.equalTo(msgLabel).offset(kFitWidth(-4))
        }
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
