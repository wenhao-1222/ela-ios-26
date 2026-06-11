//
//  PlanMainMealCardCell.swift
//  lns
//
//  Created by LNS2 on 2026/3/12.
//

import SnapKit
import Kingfisher
import ObjectiveC

class PlanMainMealCardCell: UICollectionViewCell {
    private static let loadedImageCache = NSCache<NSString, UIImage>()
    private static var loadedImageURLs = Set<String>()

    private struct RenderState: Equatable {
        let typeText: String
        let imageUrl: String
        let nameText: String
        let macroText: String
        let kcalText: String
        let isLarge: Bool
    }
    
    var changeButtonTapBlock: (() -> Void)?
    private var imageHeightConstraint: Constraint?
    private var imageLoadToken = ""
    private var renderState: RenderState?
    private var skeletonStartTime: TimeInterval = 0
    private let minSkeletonDisplayDuration: TimeInterval = 0.35
//    private let imageSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
//                                                     highlightColorLight: .COLOR_BG_F5,
//                                                     baseColorDark: .COLOR_LIGHT_GREY,
//                                                     highlightColorDark: .COLOR_BG_F5,
//                                                     cornerRadius: 0,
//                                                     shimmerWidth: 0.22,
//                                                     shimmerDuration: 1.05,
//                                                     skeletonFadeInDuration: 0.12,
//                                                     contentFadeInDuration: 0.22)
    // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
    let cfg = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                             highlightColorLight: .COLOR_GRAY_D6D6D6,
                             cornerRadius: kFitWidth(4),
                             shimmerWidth: 0.22,
                             shimmerDuration: 1.0,
                             skeletonFadeInDuration: 0.0,
                             contentFadeInDuration: 0.18)
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(12)
        view.clipsToBounds = true
        return view
    }()
    
    private let mealImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
//        imgView.backgroundColor = WHColor_16(colorStr: "F6F7F8")
        return imgView
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 11, weight: .regular)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let macroLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private let kcalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let changeButton: ElaExpandedTapButton = {
        let button = ElaExpandedTapButton(type: .custom)
        button.hitTestEdgeInsets = .init(top: -30, left: -30, bottom: -30, right: -30)
        if let icon = UIImage(named: "dietplan_plan_change_icon"){//}.withRenderingMode(.alwaysTemplate) {
            button.setImage(icon, for: .normal)
        }
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        changeButtonTapBlock = nil
        imageLoadToken = ""
        renderState = nil
        mealImgView.cancelReusableImgUrlLoad()
        mealImgView.image = nil
        mealImgView.removeSkeletonImmediately()
    }
    
    func updateUI(typeText: String,
                  imageUrl: String,
                  nameText: String,
                  macroText: String,
                  kcalText: String,
                  isLarge: Bool) {
        let newRenderState = RenderState(typeText: typeText,
                                         imageUrl: imageUrl,
                                         nameText: nameText,
                                         macroText: macroText,
                                         kcalText: kcalText,
                                         isLarge: isLarge)
        let previousRenderState = renderState
        renderState = newRenderState
        
        typeLabel.text = typeText
        nameLabel.text = "\(nameText)"
        macroLabel.text = macroText
        kcalLabel.text = kcalText
        
        imageHeightConstraint?.update(offset: isLarge ? kFitWidth(192) : kFitWidth(93))
        
        if previousRenderState == newRenderState, mealImgView.image != nil {
            mealImgView.removeSkeletonImmediately()
            return
        }
        
        let placeHolder = createImageWithColor(color: .COLOR_TEXT_TITLE_0f1214_10)
        let shouldReuseCurrentImage = previousRenderState?.imageUrl == imageUrl && mealImgView.image != nil
        let cachedLoadedImage = Self.loadedImageCache.object(forKey: imageUrl as NSString)
        let hasLoadedBefore = Self.loadedImageURLs.contains(imageUrl)
        
        if imageUrl.count > 0 {
            if shouldReuseCurrentImage {
                imageLoadToken = ""
                mealImgView.removeSkeletonImmediately()
                return
            }

            if let cachedLoadedImage = cachedLoadedImage {
                imageLoadToken = ""
                mealImgView.cancelReusableImgUrlLoad()
                mealImgView.image = cachedLoadedImage
                mealImgView.removeSkeletonImmediately()
                return
            }
            
            imageLoadToken = UUID().uuidString
            let currentToken = imageLoadToken
            let shouldShowSkeleton = !hasLoadedBefore

            mealImgView.removeSkeletonImmediately()
            if shouldShowSkeleton {
                mealImgView.showSkeleton(cfg)
                skeletonStartTime = Date().timeIntervalSince1970
            } else {
                mealImgView.image = placeHolder
            }

            mealImgView.setReusableImgUrlWithComplete(urlString: imageUrl, placeHolder: placeHolder) { [weak self] in
                guard let self = self else { return }
                guard self.imageLoadToken == currentToken else { return }
                if let image = self.mealImgView.image {
                    Self.loadedImageCache.setObject(image, forKey: imageUrl as NSString)
                    Self.loadedImageURLs.insert(imageUrl)
                }
                guard shouldShowSkeleton else {
                    self.mealImgView.removeSkeletonImmediately()
                    return
                }
                let elapsed = Date().timeIntervalSince1970 - self.skeletonStartTime
                let delay = max(0, self.minSkeletonDisplayDuration - elapsed)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    guard let self = self else { return }
                    guard self.imageLoadToken == currentToken else { return }
                    self.mealImgView.hideSkeletonWithCrossfade()
                }
            }
        } else {
            imageLoadToken = ""
            mealImgView.cancelReusableImgUrlLoad()
            mealImgView.removeSkeletonImmediately()
            UIView.transition(with: mealImgView,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.mealImgView.image = placeHolder
                              },
                              completion: nil)
        }
    }
}

extension PlanMainMealCardCell {
    func initUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(mealImgView)
        cardView.addSubview(typeLabel)
        cardView.addSubview(nameLabel)
        cardView.addSubview(macroLabel)
        cardView.addSubview(kcalLabel)
        cardView.addSubview(changeButton)
        changeButton.addTarget(self, action: #selector(changeButtonTapAction), for: .touchUpInside)
        
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mealImgView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            imageHeightConstraint = make.height.equalTo(kFitWidth(93)).constraint
        }
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.lessThanOrEqualTo(kFitWidth(-12))
            make.top.equalTo(mealImgView.snp.bottom).offset(kFitWidth(8))
            make.height.equalTo(kFitWidth(16))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(typeLabel)
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(typeLabel.snp.bottom).offset(kFitWidth(6))
        }
        macroLabel.snp.makeConstraints { make in
            make.left.equalTo(typeLabel)
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(6))
            make.height.equalTo(kFitWidth(15))
        }
        kcalLabel.snp.makeConstraints { make in
            make.left.equalTo(typeLabel)
//            make.top.equalTo(macroLabel.snp.bottom).offset(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-12))
            make.height.equalTo(kFitWidth(18))
        }
        changeButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.bottom.equalTo(kFitWidth(-12))
            make.width.height.equalTo(kFitWidth(20))
        }
    }
    
    @objc func changeButtonTapAction() {
        changeButtonTapBlock?()
    }
}

private var planMainMealCardImageLoadIdentifierKey: UInt8 = 0

private extension UIImageView {
    var planMainMealCardImageLoadIdentifier: String? {
        get {
            objc_getAssociatedObject(self, &planMainMealCardImageLoadIdentifierKey) as? String
        }
        set {
            objc_setAssociatedObject(self,
                                     &planMainMealCardImageLoadIdentifierKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    func isCurrentPlanMainMealCardImageLoad(_ urlString: String) -> Bool {
        planMainMealCardImageLoadIdentifier == urlString
    }

    func beginPlanMainMealCardImageLoad(_ urlString: String) {
        if planMainMealCardImageLoadIdentifier != urlString {
            kf.cancelDownloadTask()
        }
        planMainMealCardImageLoadIdentifier = urlString
    }

    func cancelReusableImgUrlLoad() {
        planMainMealCardImageLoadIdentifier = nil
        kf.cancelDownloadTask()
    }

    func setReusableImgUrlWithComplete(urlString:String,
                                       placeHolder:UIImage?=nil,
                                       completeHandler: @escaping () -> ()){
        beginPlanMainMealCardImageLoad(urlString)
        ImageCache.default.retrieveImage(forKey: urlString) { [weak self] result in
            guard let self = self else { return }
            guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
            switch result {
            case .success(let value):
                if let image = value.image{
                    DLLog(message: "setImgUrl(urlString:   找到了缓存的图片  \(image)  --- \(urlString)")
                    DispatchQueue.main.async {
                        guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
                        self.image = image
                        completeHandler()
                    }
                }else{
                    self.loadPlanMainMealCardImage(urlString: urlString, placeHolder: placeHolder, completeHandler: {
                        guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
                        completeHandler()
                    })
                }
            case .failure(let error):
                DLLog(message: "setImgUrl(urlString:\(error)  --- \(urlString)")
                self.loadPlanMainMealCardImage(urlString: urlString, placeHolder: placeHolder, completeHandler: {
                    guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
                    completeHandler()
                })
                break
            }
        }
    }

    func loadPlanMainMealCardImage(urlString:String,
                                   placeHolder:UIImage?=nil,
                                   needTransiton:Bool?=true,
                                   completeHandler: @escaping () -> ()) {
        guard isCurrentPlanMainMealCardImageLoad(urlString) else { return }
        var signUrl = urlString
        var optionsInfo: KingfisherOptionsInfo = [.cacheOriginalImage,
                                                  .keepCurrentImageWhileLoading,
                                                  .transition(.fade(0.2))]
        if needTransiton == false{
            optionsInfo = [.cacheOriginalImage,
                           .keepCurrentImageWhileLoading]
        }

        DLLog(message: "setImgUrl(urlString:加载图片  \(urlString)")
        let setImageOnMain: (_ task: @escaping () -> Void) -> Void = { task in
            if Thread.isMainThread {
                task()
            } else {
                DispatchQueue.main.async { task() }
            }
        }
        if urlString.contains("aliyuncs.com"){
            DSImageUploader().dealImgUrlSignForOss(urlStr: urlString) { [weak self] str in
                guard let self = self else { return }
                guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
                signUrl = str
                guard let resourceUrl = URL(string: signUrl) else{
                    return
                }

                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: urlString)
                DLLog(message: "图片加载地址 私有桶链接：\(signUrl)")
                setImageOnMain {
                    guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
                    self.kf.setImage(with: resource, placeholder: placeHolder, options: optionsInfo) { _ in
                        guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
                        completeHandler()
                    }
                }
            }
        }else{
            guard let imgUrl = URL(string: signUrl) else { return }
            setImageOnMain {
                guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
                self.kf.setImage(with: imgUrl, placeholder: nil, options: optionsInfo) { _ in
                    guard self.isCurrentPlanMainMealCardImageLoad(urlString) else { return }
                    completeHandler()
                }
            }
        }
    }
}
