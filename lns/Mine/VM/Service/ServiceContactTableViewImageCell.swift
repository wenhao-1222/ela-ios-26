//
//  ServiceContactTableViewImageCell.swift
//  lns
//
//  Created by LNS2 on 2025/12/3.
//


import Foundation
import Kingfisher

class ServiceContactTableViewImageCell: UITableViewCell {
    
    var imgWidth = kFitWidth(112)
    var imgHeight = kFitWidth(241)
    var imgGap = kFitWidth(6)
    
    var imgTapBlock:((UIImage?)->())?
    var onImageLoaded: (() -> Void)?
//    var viewModules:[HeroBrowserViewModule] = []
    
    private var avatarRequestID = UUID()

    override func prepareForReuse() {
        super.prepareForReuse()
        headImgView.kf.cancelDownloadTask()
        headImgView.image = nil
        imgView.kf.cancelDownloadTask()
        imgView.image = nil
//        viewModules.removeAll()
        avatarRequestID = UUID()
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
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.backgroundColor = .clear
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.layer.cornerRadius = kFitWidth(12)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)
    
        return img
    }()
}

extension ServiceContactTableViewImageCell{
    func updateUI(dict:NSDictionary) {
        imgHeight = kFitWidth(241)
        self.updateImgContent(dict: dict)
    }
    func updateImgContent(dict:NSDictionary) {
        let imagesStr = dict.stringValueForKey(key: "images")
        let imagesArr = WHUtils.getArrayFromJSONString(jsonString: imagesStr)
        
        let isAdmin = dict.stringValueForKey(key: "createdby") == "admin"

        configureAvatar(isAdmin: isAdmin)

        headImgView.snp.remakeConstraints { make in
            if isAdmin {
                make.left.equalTo(kFitWidth(10))
            } else {
                make.right.equalTo(kFitWidth(-10))
            }
            make.top.equalTo(kFitWidth(5))
            make.width.height.equalTo(kFitWidth(36))
        }
        
        if imagesArr.count > 0 {
            guard URL(string: imagesArr[0] as? String ?? "") != nil else { return }
            DSImageUploader().dealImgUrlSignForOss(urlStr: imagesArr[0] as? String ?? "") { signUrl in
                guard let resourceUrl = URL(string: signUrl) else{
                    return
                }
                
//                self.viewModules.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: signUrl, originImgUrl: signUrl))
                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: imagesArr[0] as? String ?? "")
                self.imgView.kf.setImage(with: resource,options: [.transition(.fade(0.2))]) { [self] result in
                    DLLog(message: "result:\(result)")
                    
                    let imgOriSize = imgView.image?.size

                    var imgOriginW = imgHeight * ((imgOriSize?.width ?? 0) / (imgOriSize?.height ?? 1))
                    if imgOriginW > SCREEN_WIDHT - kFitWidth(120){
                        imgOriginW = SCREEN_WIDHT - kFitWidth(120)
                        imgHeight = imgOriginW * ((imgOriSize?.height ?? 0) / (imgOriSize?.width ?? 1))
                    }
                    DispatchQueue.main.async {
                        if !isAdmin{
                            self.imgView.snp.remakeConstraints { make in
                                make.right.equalTo(kFitWidth(-60))
                                make.top.equalTo(kFitWidth(10))
                                make.width.equalTo(imgOriginW)
                                make.height.equalTo(self.imgHeight)
                                make.bottom.equalTo(kFitWidth(-10))
                            }
                        }else{
                            self.imgView.snp.remakeConstraints { make in
                                make.left.equalTo(kFitWidth(60))
                                make.top.equalTo(kFitWidth(5))
                                make.width.equalTo(imgOriginW)
                                make.height.equalTo(self.imgHeight)
                                make.bottom.equalTo(kFitWidth(-10))
                            }
                        }
                        self.onImageLoaded?()
                    }
                }
            }
        }
    }
    @objc func imgTapAction(){
        guard let vc = UIApplication.topViewController() else { return }
        if self.imgView.image != nil {
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
}
extension ServiceContactTableViewImageCell{
    func initUI() {
        contentView.addSubview(headImgView)
        contentView.addSubview(imgView)
    }
}

private extension ServiceContactTableViewImageCell {
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
