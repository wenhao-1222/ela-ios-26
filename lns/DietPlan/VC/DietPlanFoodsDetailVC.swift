//
//  DietPlanFoodsDetailVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/13.
//

import UIKit
import SnapKit
import MCToast

private struct DietPlanFoodsDetailFoodItem {
    let name: String
    let quantityText: String
    let unitText: String
    
    var displayAmount: String {
        let value = quantityText.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = unitText.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(value)\(unit)"
    }
}

private final class DietPlanDashedSeparatorView: UIView {
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.18).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [3, 3]
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        let path = UIBezierPath()
        let y = bounds.height * 0.5
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: bounds.width, y: y))
        shapeLayer.path = path.cgPath
    }
}

private final class DietPlanMacroItemView: UIView {
    private let dotView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dotView, titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = kFitWidth(4)
        return stack
    }()
    
    init(dotColor: UIColor, title: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        
        dotView.backgroundColor = dotColor
        dotView.layer.cornerRadius = kFitWidth(2.5)
        
        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        valueLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        valueLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        addSubview(contentStack)
        
        dotView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(5))
        }
        
        contentStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateValue(_ value: String) {
        valueLabel.text = "\(value)g"
    }
}

class DietPlanFoodsDetailVC: WHBaseViewVC {
    var sdate = ""
    var mealId = ""
    var replacePlanItemId = ""
    var replaceSuccessBlock: ((NSDictionary) -> Void)?
    
    private let imageHeight = kFitWidth(209)
    private var foodItems: [DietPlanFoodsDetailFoodItem] = []
    private var detailFoodsSource = NSArray()
    private let scrollContentGradientLayer = CAGradientLayer()
    private let scrollTopOverlayGradientLayer = CAGradientLayer()
    private let imageSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                     highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                     cornerRadius: 0,
                                                     shimmerWidth: 0.24,
                                                     shimmerDuration: 1.0,
                                                     skeletonFadeInDuration: 0.0,
                                                     contentFadeInDuration: 0.18)
    private let blockSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                     highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                     cornerRadius: kFitWidth(8),
                                                     shimmerWidth: 0.2,
                                                     shimmerDuration: 1.0,
                                                     skeletonFadeInDuration: 0.0,
                                                     contentFadeInDuration: 0.18)
    private let buttonSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                      highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                      cornerRadius: kFitWidth(26),
                                                      shimmerWidth: 0.22,
                                                      shimmerDuration: 1.0,
                                                      skeletonFadeInDuration: 0.0,
                                                      contentFadeInDuration: 0.18)
    
    private lazy var topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .COLOR_CARD_BG_WHITE
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.contentInsetAdjustmentBehavior = .never
        view.delegate = self
        view.backgroundColor = .clear
        return view
    }()

    private lazy var loadingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var scrollBackgroundView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = kFitWidth(20)
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var scrollTopOverlayView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = kFitWidth(24)
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var contentCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = kFitWidth(24)
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var ingredientsTitleLabel: UILabel = makeSectionTitleLabel(text: "食材")
    private lazy var stepsTitleLabel: UILabel = makeSectionTitleLabel(text: "步骤")
    
    private lazy var foodsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    private lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var nutritionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(13)
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var caloriesIconView: UIImageView = {
//        let imageView = UIImageView(image: UIImage(systemName: "flame.fill"))
        let imageView =  UIImageView()
        imageView.image = UIImage(named: "journal_share_calories_icon")
//        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var caloriesValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private lazy var caloriesUnitLabel: UILabel = {
        let label = UILabel()
        label.text = "千卡"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 11, weight: .regular)
        return label
    }()
    
    private lazy var macroStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [carbohydrateItemView, proteinItemView, fatItemView])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    private lazy var carbohydrateItemView = DietPlanMacroItemView(dotColor: .COLOR_CARBOHYDRATE, title: "碳水")
    private lazy var proteinItemView = DietPlanMacroItemView(dotColor: .COLOR_PROTEIN, title: "蛋白质")
    private lazy var fatItemView = DietPlanMacroItemView(dotColor: .COLOR_FAT, title: "脂肪")
    
    private lazy var bottomActionContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_BG_F2
        return view
    }()
    
    private lazy var chooseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(self.replacePlanItemId.count > 0 ? "选择替换" : "添加到日志" , for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.backgroundColor = .THEME
        button.layer.cornerRadius = kFitWidth(26)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(buttonTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var chooseButtonSkeletonView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var foodsAddAlertVm: DietPlanFoodsAddAlertVM = {
        let vm = DietPlanFoodsAddAlertVM(frame: .zero)
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        showLoadingSkeletonIfNeeded()
        preloadFoodsAddAlertSelectionIfNeeded()
//        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            self.sendFoodsDetaiLRequest()
//        })

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollContentGradientLayer.frame = scrollBackgroundView.bounds
        scrollTopOverlayGradientLayer.frame = scrollTopOverlayView.bounds
    }
}

extension DietPlanFoodsDetailVC {
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(scrollView)
        view.addSubview(loadingContainerView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(topImageView)
        scrollContentView.addSubview(scrollBackgroundView)
        scrollContentView.addSubview(scrollTopOverlayView)
        scrollContentView.addSubview(contentCardView)
        view.addSubview(bottomActionContainer)
        bottomActionContainer.addSubview(chooseButton)
        bottomActionContainer.addSubview(chooseButtonSkeletonView)
        
        scrollContentGradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        scrollContentGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        scrollContentGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        scrollBackgroundView.layer.insertSublayer(scrollContentGradientLayer, at: 0)
        
        scrollTopOverlayGradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        scrollTopOverlayGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        scrollTopOverlayGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        scrollTopOverlayView.layer.insertSublayer(scrollTopOverlayGradientLayer, at: 0)
        
        contentCardView.addSubview(titleLabel)
        contentCardView.addSubview(ingredientsTitleLabel)
        contentCardView.addSubview(foodsStackView)
        contentCardView.addSubview(stepsTitleLabel)
        contentCardView.addSubview(notesLabel)
        contentCardView.addSubview(nutritionCardView)
        
        nutritionCardView.addSubview(caloriesIconView)
        nutritionCardView.addSubview(caloriesValueLabel)
        nutritionCardView.addSubview(caloriesUnitLabel)
        nutritionCardView.addSubview(macroStackView)
        
        topImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(imageHeight)
        }
        
        bottomActionContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        chooseButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview().offset(kFitWidth(12))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalTo(-(getBottomSafeAreaHeight() + kFitWidth(12)))
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(bottomActionContainer.snp.top)
        }

        loadingContainerView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
        }

        scrollContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        chooseButtonSkeletonView.snp.makeConstraints { make in
            make.edges.equalTo(chooseButton)
        }
        
        scrollBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom).offset(-kFitWidth(24))
            make.bottom.equalToSuperview()
        }
        
        scrollTopOverlayView.snp.makeConstraints { make in
            make.left.right.equalTo(scrollBackgroundView)
            make.top.equalTo(scrollBackgroundView)
            make.height.equalTo(kFitWidth(28))
        }
        
        contentCardView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom).offset(-kFitWidth(24))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(24))
        }
        
        ingredientsTitleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }
        
        foodsStackView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(ingredientsTitleLabel.snp.bottom).offset(kFitWidth(14))
        }
        
        stepsTitleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(foodsStackView.snp.bottom).offset(kFitWidth(22))
        }
        
        notesLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(stepsTitleLabel.snp.bottom).offset(kFitWidth(14))
        }
        
        nutritionCardView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(notesLabel.snp.bottom).offset(kFitWidth(28))
            make.bottom.equalTo(kFitWidth(-24))
        }
        
        caloriesIconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(24))
            make.width.height.equalTo(kFitWidth(16))
        }
        
        caloriesValueLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesIconView.snp.right).offset(kFitWidth(10))
            make.centerY.equalTo(caloriesIconView.snp.centerY).offset(kFitWidth(1))
        }
        
        caloriesUnitLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesValueLabel.snp.right).offset(kFitWidth(6))
            make.centerY.equalTo(caloriesValueLabel.snp.centerY).offset(kFitWidth(4))
        }
        
        macroStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(caloriesValueLabel.snp.bottom).offset(kFitWidth(22))
            make.bottom.equalTo(kFitWidth(-18))
            make.height.equalTo(kFitWidth(32))
        }
        
        initNavi(titleStr: "", naviBgColor: .clear)
        navigationView.backgroundColor = .clear
        navigationView.isHidden = true
        backArrowButton.removeFromSuperview()
        view.addSubview(backArrowButton)
        backArrowButton.snp.remakeConstraints { make in
            make.width.height.equalTo(kFitWidth(44))
            make.top.equalTo(statusBarHeight)
            make.left.equalTo(kFitWidth(2))
        }

        setupLoadingUI()
    }
}

extension DietPlanFoodsDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else { return }
        
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            let fixedTransform = CGAffineTransform(translationX: 0, y: offsetY)
            topImageView.transform = fixedTransform
            scrollBackgroundView.transform = fixedTransform
            scrollTopOverlayView.transform = fixedTransform
        } else {
            topImageView.transform = .identity
            scrollBackgroundView.transform = .identity
            scrollTopOverlayView.transform = .identity
        }
    }
}

extension DietPlanFoodsDetailVC {
    @objc func buttonTapAction() {
        if replacePlanItemId.count > 0 {
            sendReplaceFoodsRequest()
        }else{
            guard detailFoodsSource.count > 0 else {
                MCToast.mc_text("食材信息为空")
                return
            }
            
            showFoodsAddAlert()
        }
    }
    @objc func chooseReplaceAction() {
        guard !mealId.isEmpty else {
            MCToast.mc_text("餐食信息异常")
            return
        }
        guard !replacePlanItemId.isEmpty else {
            MCToast.mc_text("替换信息异常")
            return
        }
        
    }
    
    
    func sendFoodsDetaiLRequest() {
        let param = ["mealId": mealId]
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_foods_detail, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendFoodsDetaiLRequest:\(dataObj)")
            self.updateUI(dataObj)
        } failure: { [weak self] isError in
            if isError {
                MCToast.mc_text("获取食谱详情失败，请稍后重试")
            }
            self?.hideLoadingSkeletonIfNeeded()
        }
    }
    
    func sendReplaceFoodsRequest() {
        let param = ["userMealPlanItemId": replacePlanItemId,
                     "mealId": mealId]
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_foods_replace, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendReplaceFoodsRequestFromDetail:\(dataString)")
            
            self.replaceSuccessBlock?(dataObj)
            self.popBackToDietPlanPage()
        } failure: { isError in
            if isError {
                MCToast.mc_text("替换食谱失败，请稍后重试")
            }
        }
    }
}

private extension DietPlanFoodsDetailVC {
    func updateUI(_ dict: NSDictionary) {
        titleLabel.text = dict.stringValueForKey(key: "mealName")
        caloriesValueLabel.text = displayNumberText(from: dict["calories"])
        updateMacroItem(carbohydrateItemView, value: displayNumberText(from: dict["carbohydrate"]))
        updateMacroItem(proteinItemView, value: displayNumberText(from: dict["protein"]))
        updateMacroItem(fatItemView, value: displayNumberText(from: dict["fat"]))
        
        let imageUrl = dict.stringValueForKey(key: "mealImage")
        let placeholder = UIImage(named: "Image")
        if imageUrl.isEmpty {
            topImageView.image = placeholder
        } else {
            topImageView.setImgUrlWithComplete(urlString: imageUrl, placeHolder: placeholder) { }
        }
        
        detailFoodsSource = dict["foods"] as? NSArray ?? []
        foodItems = parseFoods(detailFoodsSource)
        reloadFoods()
        
        let notesText = dict.stringValueForKey(key: "notes")
        notesLabel.attributedText = makeNotesAttributedText(notesText)
        stepsTitleLabel.isHidden = notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        notesLabel.isHidden = stepsTitleLabel.isHidden
        view.layoutIfNeeded()
        hideLoadingSkeletonIfNeeded()
    }

    func setupLoadingUI() {
        let loadingImageSkeletonView = makeLoadingBlock(config: imageSkeletonConfig)
        let loadingCardView = UIView()
        loadingCardView.backgroundColor = .white
        loadingCardView.layer.cornerRadius = kFitWidth(24)
        loadingCardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        loadingCardView.clipsToBounds = true

        let loadingTitleSkeletonView = makeLoadingBlock(cornerRadius: kFitWidth(10))
        let loadingIngredientsTitleSkeletonView = makeLoadingBlock()
        let loadingFoodsContainerView = UIView()
        let loadingFoodRowHeight = kFitWidth(37)
        let loadingTitleHeight = singleLineSkeletonHeight(for: titleLabel)
        let loadingSectionTitleHeight = singleLineSkeletonHeight(for: ingredientsTitleLabel)
        let loadingFoodTextHeight = singleLineHeight(for: .systemFont(ofSize: 13, weight: .regular))
        (0..<4).forEach { index in
            let rowView = makeLoadingFoodRow(showSeparator: index < 3,
                                             textHeight: loadingFoodTextHeight)
            loadingFoodsContainerView.addSubview(rowView)
            rowView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(CGFloat(index) * loadingFoodRowHeight)
                make.height.equalTo(loadingFoodRowHeight)
            }
        }

        let loadingStepsTitleSkeletonView = makeLoadingBlock()
        let loadingStepsSkeletonView = makeLoadingBlock(cornerRadius: kFitWidth(12))

        loadingContainerView.addSubview(loadingImageSkeletonView)
        loadingContainerView.addSubview(loadingCardView)

        [loadingTitleSkeletonView,
         loadingIngredientsTitleSkeletonView,
         loadingFoodsContainerView,
         loadingStepsTitleSkeletonView,
         loadingStepsSkeletonView].forEach {
            loadingCardView.addSubview($0)
        }

        loadingImageSkeletonView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(imageHeight)
        }

        loadingCardView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(loadingImageSkeletonView.snp.bottom).offset(-kFitWidth(24))
        }

        loadingTitleSkeletonView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(24))
            make.width.equalTo(kFitWidth(180))
            make.height.equalTo(loadingTitleHeight)
        }

        loadingIngredientsTitleSkeletonView.snp.makeConstraints { make in
            make.left.equalTo(loadingTitleSkeletonView)
            make.top.equalTo(loadingTitleSkeletonView.snp.bottom).offset(kFitWidth(20))
            make.width.equalTo(kFitWidth(40))
            make.height.equalTo(loadingSectionTitleHeight)
        }

        loadingFoodsContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.top.equalTo(loadingIngredientsTitleSkeletonView.snp.bottom).offset(kFitWidth(14))
            make.height.equalTo(loadingFoodRowHeight * 4)
        }

        loadingStepsTitleSkeletonView.snp.makeConstraints { make in
            make.left.equalTo(loadingTitleSkeletonView)
            make.top.equalTo(loadingFoodsContainerView.snp.bottom).offset(kFitWidth(22))
            make.width.equalTo(kFitWidth(40))
            make.height.equalTo(loadingSectionTitleHeight)
        }

        loadingStepsSkeletonView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.top.equalTo(loadingStepsTitleSkeletonView.snp.bottom).offset(kFitWidth(14))
            make.bottom.equalTo(kFitWidth(-24))
            make.height.greaterThanOrEqualTo(kFitWidth(220))
        }
    }

    func showLoadingSkeletonIfNeeded() {
        loadingContainerView.alpha = 1
        chooseButtonSkeletonView.alpha = 1
        scrollView.alpha = 0.02
        chooseButton.alpha = 0.02
        scrollView.isScrollEnabled = false
        chooseButton.isUserInteractionEnabled = false
        chooseButtonSkeletonView.showSkeleton(buttonSkeletonConfig)
    }

    func hideLoadingSkeletonIfNeeded() {
        chooseButton.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        guard loadingContainerView.superview != nil || chooseButtonSkeletonView.superview != nil else {
            scrollView.alpha = 1
            chooseButton.alpha = 1
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.loadingContainerView.alpha = 0
            self.chooseButtonSkeletonView.alpha = 0
            self.scrollView.alpha = 1
            self.chooseButton.alpha = 1
        }, completion: { _ in
            self.loadingContainerView.removeFromSuperview()
            self.chooseButtonSkeletonView.removeFromSuperview()
        })
    }
    
    func parseFoods(_ foodsArray: NSArray?) -> [DietPlanFoodsDetailFoodItem] {
        let source = foodsArray ?? []
        return source.compactMap { item in
            let dict = item as? NSDictionary ?? [:]
            let originFoods = dict["foods"] as? NSDictionary ?? [:]
            let name = dict.stringValueForKey(key: "fname").isEmpty ? originFoods.stringValueForKey(key: "fname") : dict.stringValueForKey(key: "fname")
            guard !name.isEmpty else { return nil }
            return DietPlanFoodsDetailFoodItem(name: name,
                                               quantityText: quantityText(from: dict),
                                               unitText: specText(from: dict, fallback: originFoods))
        }
    }
    
    func quantityText(from dict: NSDictionary) -> String {
        if let stringValue = dict["qty"] as? String, !stringValue.isEmpty {
            return WHUtils.convertStringToStringNoDigit(stringValue) ?? stringValue
        }
        if let numberValue = dict["qty"] as? NSNumber {
            let rawText = numberValue.stringValue
            return WHUtils.convertStringToStringNoDigit(rawText) ?? rawText
        }
        let rawText = "\(dict.doubleValueForKey(key: "qty"))"
        return WHUtils.convertStringToStringNoDigit(rawText) ?? rawText
    }
    
    func specText(from dict: NSDictionary, fallback: NSDictionary) -> String {
        let currentSpec = dict.stringValueForKey(key: "spec")
        if !currentSpec.isEmpty {
            return currentSpec
        }
        return fallback.stringValueForKey(key: "specName")
    }
    
    func displayNumberText(from value: Any?) -> String {
        if let stringValue = value as? String, !stringValue.isEmpty {
            return WHUtils.convertStringToStringNoDigit(stringValue) ?? stringValue
        }
        if let numberValue = value as? NSNumber {
            let rawText = numberValue.stringValue
            return WHUtils.convertStringToStringNoDigit(rawText) ?? rawText
        }
        if let doubleValue = value as? Double {
            let rawText = "\(doubleValue)"
            return WHUtils.convertStringToStringNoDigit(rawText) ?? rawText
        }
        if let floatValue = value as? Float {
            let rawText = "\(floatValue)"
            return WHUtils.convertStringToStringNoDigit(rawText) ?? rawText
        }
        if let intValue = value as? Int {
            return "\(intValue)"
        }
        return "0"
    }
    
    func reloadFoods() {
        foodsStackView.arrangedSubviews.forEach { view in
            foodsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        ingredientsTitleLabel.isHidden = foodItems.isEmpty
        foodsStackView.isHidden = foodItems.isEmpty
        
        for (index, item) in foodItems.enumerated() {
            foodsStackView.addArrangedSubview(makeFoodRow(item: item, showSeparator: index < foodItems.count - 1))
        }
    }
    
    func makeFoodRow(item: DietPlanFoodsDetailFoodItem, showSeparator: Bool) -> UIView {
        let rowView = UIView()
        rowView.snp.makeConstraints { make in
            make.height.equalTo(kFitWidth(37))
        }
//        
        let nameLabel = UILabel()
        nameLabel.text = item.name
        nameLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        nameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        nameLabel.numberOfLines = 0
//        nameLabel.adjustsFontSizeToFitWidth = true
//        nameLabel.minimumScaleFactor = 0.6
        
        let amountLabel = UILabel()
        amountLabel.text = item.displayAmount
        amountLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        amountLabel.font = .systemFont(ofSize: 13, weight: .regular)
        amountLabel.textAlignment = .right
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        rowView.addSubview(nameLabel)
        rowView.addSubview(amountLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.lessThanOrEqualTo(amountLabel.snp.left).offset(kFitWidth(-12))
            make.centerY.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        if showSeparator {
            let separator = DietPlanDashedSeparatorView()
            rowView.addSubview(separator)
            separator.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        
        return rowView
    }

    func makeLoadingBlock(config: SkeletonConfig? = nil,
                          size: CGSize? = nil,
                          cornerRadius: CGFloat? = nil,
                          in containerView: UIView? = nil) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false

        if let containerView = containerView {
            containerView.addSubview(view)
        }

        var skeletonConfig = config ?? blockSkeletonConfig
        if let cornerRadius = cornerRadius {
            skeletonConfig.cornerRadius = cornerRadius
        }
        if let size = size {
            view.snp.makeConstraints { make in
                make.size.equalTo(size)
            }
        }
        view.showSkeleton(skeletonConfig)
        return view
    }

    func makeLoadingFoodRow(showSeparator: Bool, textHeight: CGFloat) -> UIView {
        let rowView = UIView()

        let nameSkeletonView = makeLoadingBlock()
        let amountSkeletonView = makeLoadingBlock()
        rowView.addSubview(nameSkeletonView)
        rowView.addSubview(amountSkeletonView)

        nameSkeletonView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(110))
            make.height.equalTo(textHeight)
        }

        amountSkeletonView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(58))
            make.height.equalTo(textHeight)
        }

        if showSeparator {
            let separator = DietPlanDashedSeparatorView()
            rowView.addSubview(separator)
            separator.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
        }

        return rowView
    }
    
    func makeSectionTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }

    func singleLineSkeletonHeight(for label: UILabel) -> CGFloat {
        singleLineHeight(for: label.font)
    }

    func singleLineHeight(for font: UIFont) -> CGFloat {
        ceil(font.lineHeight)
    }
    
    func makeNotesAttributedText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = kFitWidth(6)
        
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
            .paragraphStyle: paragraphStyle
        ])
    }
    
    func updateMacroItem(_ itemView: DietPlanMacroItemView, value: String) {
        itemView.updateValue(value)
    }
    
    func preloadFoodsAddAlertSelectionIfNeeded() {
        guard replacePlanItemId.isEmpty, sdate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return
        }
        
        foodsAddAlertVm.preloadDefaultSelection(sdate: sdate)
    }
    
    func showFoodsAddAlert() {
        if foodsAddAlertVm.superview == nil,
           let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.getKeyWindow().addSubview(foodsAddAlertVm)
        }
        
        foodsAddAlertVm.prepare(sdate: sdate, foodsArray: detailFoodsSource)
        foodsAddAlertVm.showSelf()
    }
    
    func popBackToDietPlanPage() {
        guard let navigationController = navigationController else {
            backTapAction()
            return
        }
        
        if let targetVC = navigationController.viewControllers.reversed().first(where: { $0 is DietPlanVC }) {
            navigationController.popToViewController(targetVC, animated: true)
            return
        }
        
        navigationController.popViewController(animated: true)
    }
}
