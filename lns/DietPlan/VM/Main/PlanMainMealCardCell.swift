//
//  PlanMainMealCardCell.swift
//  lns
//
//  Created by LNS2 on 2026/3/12.
//

import SnapKit

class PlanMainMealCardCell: UICollectionViewCell {
    var changeButtonTapBlock: (() -> Void)?
    private var imageHeightConstraint: Constraint?
    private var imageLoadToken = ""
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
    
    private let changeButton: UIButton = {
        let button = UIButton(type: .custom)
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
        mealImgView.image = nil
        mealImgView.removeSkeletonImmediately()
    }
    
    func updateUI(typeText: String,
                  imageUrl: String,
                  nameText: String,
                  macroText: String,
                  kcalText: String,
                  isLarge: Bool) {
        typeLabel.text = typeText
        nameLabel.text = "\(nameText)金佛"
        macroLabel.text = macroText
        kcalLabel.text = kcalText
        
        let placeHolderName = isLarge ? "Image 1" : "Image"
        let placeHolder = UIImage(named: placeHolderName)
        
        if imageUrl.count > 0{
            imageLoadToken = UUID().uuidString
            let currentToken = imageLoadToken

            mealImgView.removeSkeletonImmediately()
            mealImgView.showSkeleton(cfg)
            skeletonStartTime = Date().timeIntervalSince1970

            mealImgView.setImgUrlWithComplete(urlString: imageUrl, placeHolder: nil) { [weak self] in
                guard let self = self else { return }
                guard self.imageLoadToken == currentToken else { return }
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
            mealImgView.removeSkeletonImmediately()
            UIView.transition(with: mealImgView,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.mealImgView.image = placeHolder
                              },
                              completion: nil)
        }
        imageHeightConstraint?.update(offset: isLarge ? kFitWidth(192) : kFitWidth(93))
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
