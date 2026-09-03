//
//  GuidanceNutritionGoalsResultVC.swift
//  lns
//
//  Initial nutrition goals result page shown after the v3 goals request.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift
import MCToast

/// Presents the initial nutrition targets and allows editing carbohydrate,
/// protein and fat values before the Guide0820 flow is completed.
final class GuidanceNutritionGoalsResultVC: WHBaseViewVC {
    typealias Goals = GuidanceNutritionGoalsProgressVC.NutritionGoalsResult

    var completion: (() -> Void)?

    private var goals: Goals
    private var isEditingGoals = false

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let editCard = UIView()
    private lazy var bottomSheetView = Guide0820BottomSheetView()

    // `bottomGradientView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var bottomGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.addSublayer(bottomGradientLayer)
        return view
    }()

    // `bottomGradientLayer` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        return layer
    }()

    private let caloriesLabel = UILabel()
    private let carbohydrateField = UITextField()
    private let proteinField = UITextField()
    private let fatField = UITextField()

    private lazy var closeButton: Guide0820MoreButton = {
        let button = Guide0820MoreButton()
        button.addTarget(self, action: #selector(operationButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始第一阶段", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .THEME
        button.layer.cornerRadius = kFitWidth(12)
        button.enablePressEffect()
        button.addTarget(self, action: #selector(primaryAction), for: .touchUpInside)
        return button
    }()

    init(goals: Goals?) {
        self.goals = goals ?? Goals(protein: 1, carbohydrate: 0, fat: 1, calories: 0)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildInterface()
        updateBottomGradientColors()
        updateValues()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInteractivePopGestureBlocked(true)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInteractivePopGestureBlocked(true)
        setKeyboardExtensionAllowed(false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection == nil ||
                traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        updateBottomGradientColors()
        [carbohydrateField, proteinField, fatField]
            .filter(\.isFirstResponder)
            .forEach {
                $0.layer.borderColor = UIColor.THEME.resolvedColor(with: traitCollection).cgColor
            }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreFullscreenInteractivePopGesture()
        setKeyboardExtensionAllowed(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    deinit {
        restoreFullscreenInteractivePopGesture()
        setKeyboardExtensionAllowed(true)
    }

    @objc private func operationButtonAction() {
        showOperationSheet()
    }

    @objc private func primaryAction() {
        view.endEditing(true)
        guard let validatedGoals = validatedGoalsFromFields() else {
            return
        }
        goals = validatedGoals
        saveGoals()
        let featureVC = Guide0820FeatureIntroVC(onFinished: completion)
        if let navigationController,
           let index = navigationController.viewControllers.firstIndex(where: { $0 === self }) {
            // Replace this result page in-place so it can never be revealed by
            // a back gesture or a later pop operation.
            var stack = navigationController.viewControllers
            stack[index] = featureVC
            navigationController.setViewControllers(stack, animated: true)
        } else if let navigationController {
            navigationController.pushViewController(featureVC, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: featureVC)
            navigationController.setNavigationBarHidden(true, animated: false)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }

}

private extension GuidanceNutritionGoalsResultVC {
    /// 将动态页面背景色重新解析为当前外观下的渐变 CGColor。
    func updateBottomGradientColors() {
        let color = UIColor.COLOR_BG_F2.resolvedColor(with: traitCollection)
        bottomGradientLayer.colors = [
            color.withAlphaComponent(0).cgColor,
            color.cgColor
        ]
    }

    func showOperationSheet() {
        let operationView = Guide0820OperationSheetView(
            vm: Guide0820OperationSheetVM(),
            onClose: { [weak self] in
                self?.bottomSheetView.dismiss()
            },
            onSelectItem: { [weak self] item in
                self?.handleOperationItem(item)
            }
        )
        let sheetViewHeight = kFitWidth(239) + getBottomSafeAreaHeight() - kFitWidth(65)
        bottomSheetView.present(contentView: operationView,
                                contentHeight: sheetViewHeight,
                                keyboardAvoidanceEnabled: false)
    }

    func handleOperationItem(_ item: Guide0820OperationItem) {
        switch item.identifier {
        case .sourceInput:
            showInviteSourceSheet()
        case .clearData:
            showDeleteConfirmationSheet()
        }
    }

    func showInviteSourceSheet() {
        let sourceView = Guide0820InviteSourceSheetView(
            vm: Guide0820InviteSourceInputVM(),
            onClose: { [weak self] in
                self?.bottomSheetView.dismiss()
            }
        )
        bottomSheetView.present(contentView: sourceView,
                                contentHeight: kFitWidth(272.5),
                                keyboardAvoidanceEnabled: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            sourceView.focusInput()
        }
    }

    func showDeleteConfirmationSheet() {
        let deleteView = Guide0820DeleteConfirmationSheetView(
            vm: Guide0820DeleteConfirmationVM(),
            onClose: { [weak self] in
                self?.bottomSheetView.dismiss()
            },
            onConfirm: { [weak self] in
                self?.clearGuideSourceDataAndReturn()
            }
        )
        bottomSheetView.present(contentView: deleteView,
                                contentHeight: kFitWidth(272.5),
                                keyboardAvoidanceEnabled: false)
    }

    func clearGuideSourceDataAndReturn() {
        Guide0820ProgressStorage.clearAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.returnToFirstLaunchPage()
        }
    }

    func returnToFirstLaunchPage() {
        let firstLaunchVC = FirstLaunchVC(skipAnimation: true,
                                          forceNeedBuildPlanOnConfirm: true)
        if let navigationController {
            navigationController.setViewControllers([firstLaunchVC], animated: true)
            return
        }
        let navigationController = UINavigationController(rootViewController: firstLaunchVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    func buildInterface() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(bottomGradientView)
        view.addSubview(primaryButton)
        view.addSubview(closeButton)
        view.addSubview(bottomSheetView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.bottom.equalTo(primaryButton.snp.top).offset(kFitWidth(-16))
        }
        bottomGradientView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(scrollView)
            $0.height.equalTo(kFitWidth(20))
//            $0.height.equalTo(kFitWidth(72))
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(view.snp.height)
        }
        closeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(kFitWidth(-16))
            // The design places the ellipsis above the title row rather than
            // on the title's baseline. Keep the button's hit area generous,
            // while moving its center up to the intended visual position.
            $0.top.equalToSuperview().offset(kFitWidth(43.5))
            $0.width.height.equalTo(kFitWidth(44))
        }
        bottomSheetView.snp.makeConstraints { $0.edges.equalToSuperview() }

        let title = makeLabel("你的初始营养目标是", size: 19, weight: .medium, color: .COLOR_TEXT_TITLE_0f1214)
        let subtitle = makeLabel("你可以手动编辑这个目标", size: 12, weight: .regular, color: .COLOR_TEXT_TITLE_0f1214_50)
        title.snp.makeConstraints { $0.height.equalTo(kFitWidth(28.5)) }
        subtitle.snp.makeConstraints { $0.height.equalTo(kFitWidth(18)) }
        let titleStack = UIStackView(arrangedSubviews: [title, subtitle])
        titleStack.axis = .vertical
        titleStack.spacing = kFitWidth(6)
        contentView.addSubview(titleStack)
        titleStack.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(21)); $0.right.equalTo(kFitWidth(-21)); $0.top.equalTo(kFitWidth(78))
        }

        contentView.addSubview(editCard)
        editCard.backgroundColor = .COLOR_CARD_BG_WHITE
        editCard.layer.cornerRadius = kFitWidth(12)
        editCard.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(16)); $0.right.equalTo(kFitWidth(-16)); $0.top.equalTo(titleStack.snp.bottom).offset(kFitWidth(22.5)); $0.height.equalTo(kFitWidth(149))
        }
        makeNutritionCard()

        let reportStack = makeReportStack(for: goals.coachSuggestion)
        contentView.addSubview(reportStack)
        reportStack.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(16))
            $0.right.equalTo(kFitWidth(-16))
            $0.top.equalTo(editCard.snp.bottom).offset(kFitWidth(25))
            $0.bottom.equalToSuperview().offset(kFitWidth(-30))
        }

        primaryButton.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(16)); $0.right.equalTo(kFitWidth(-16))
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(kFitWidth(-8))
            $0.height.equalTo(kFitWidth(52))
        }
    }

    func makeNutritionCard() {
        // MasterGo: 630 × 238.2px content frame, positioned 28.5px/23px
        // from the card's leading/top edges (the design is exported at 2x).
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = kFitWidth(15.49)

        editCard.addSubview(stack)
        stack.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(14.25))
            $0.top.equalTo(kFitWidth(11.5))
            $0.width.equalTo(kFitWidth(315))
            $0.height.equalTo(kFitWidth(119.1))
        }

        
        let calorieRow = UIStackView()
        calorieRow.axis = .vertical
        calorieRow.alignment = .center
        calorieRow.spacing = kFitWidth(2.58)
        calorieRow.addArrangedSubview(metricLabel(title: "热量(千卡)", color: .COLOR_CALORI))
        stack.addArrangedSubview(calorieRow)
        caloriesLabel.font = UIFont().DDInFontSemiBold(fontSize: kFitWidth(20.655))
        caloriesLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        caloriesLabel.textAlignment = .center
        caloriesLabel.snp.makeConstraints {
            $0.width.equalTo(kFitWidth(72.295))
            $0.height.equalTo(kFitWidth(30.985))
        }
        calorieRow.addArrangedSubview(caloriesLabel)

        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = kFitWidth(22.145)
        row.distribution = .fill
        [("碳水(g)", carbohydrateField, UIColor.COLOR_CARBOHYDRATE), ("蛋白质(g)", proteinField, UIColor.COLOR_PROTEIN), ("脂肪(g)", fatField, UIColor.COLOR_FAT)].forEach { title, field, color in
            let column = UIStackView()
            column.axis = .vertical
            column.alignment = .center
            column.spacing = kFitWidth(2.58)
            column.widthAnchor.constraint(equalToConstant: kFitWidth(88)).isActive = true
            column.addArrangedSubview(metricLabel(title: title, color: color))
            let fieldFont = pingFangFont(size: kFitWidth(13), weight: .medium)
            field.font = fieldFont
            field.textColor = .COLOR_TEXT_TITLE_0f1214
            field.contentVerticalAlignment = .center
            var textAttributes = field.defaultTextAttributes
            textAttributes[.font] = fieldFont
            textAttributes[.foregroundColor] = UIColor.COLOR_TEXT_TITLE_0f1214
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = kFitWidth(18.59)
            paragraphStyle.maximumLineHeight = kFitWidth(18.59)
            paragraphStyle.alignment = .center
            textAttributes[.paragraphStyle] = paragraphStyle
            field.defaultTextAttributes = textAttributes
            field.textAlignment = .center
            field.keyboardType = .numberPad
            field.layer.cornerRadius = kFitWidth(13.285)
            
            field.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_05
            field.isUserInteractionEnabled = true
            field.delegate = self
            field.widthAnchor.constraint(equalToConstant: kFitWidth(87.785)).isActive = true
            field.heightAnchor.constraint(equalToConstant: kFitWidth(33.12)).isActive = true
            field.addTarget(self,
                            action: #selector(nutritionFieldEditingChanged(_:)),
                            for: .editingChanged)
            field.setMealAdviceDoneAccessory { [weak field] in
                field?.resignFirstResponder()
            }
            column.addArrangedSubview(field); row.addArrangedSubview(column)
        }
        stack.addArrangedSubview(row)
    }

    func makeReportStack(for suggestion: Goals.CoachSuggestion?) -> UIStackView {
        let reportStack = UIStackView()
        reportStack.axis = .vertical
        reportStack.alignment = .fill
        reportStack.distribution = .fill

        if let judgment = suggestion?.judgment {
            let section = makeJudgmentSection(judgment)
            reportStack.addArrangedSubview(section)
            reportStack.setCustomSpacing(kFitWidth(23.5), after: section)
        }

        if let actionPlan = suggestion?.actionPlan {
            let section = makeActionPlanSection(actionPlan)
            reportStack.addArrangedSubview(section)
            reportStack.setCustomSpacing(kFitWidth(25.5), after: section)
        }

        if let conclusion = suggestion?.conclusion {
            reportStack.addArrangedSubview(makeConclusionSection(conclusion))
        }

        return reportStack
    }

    func makeJudgmentSection(_ section: Goals.TextSection) -> UIStackView {
        let title = makeLabel(section.title,
                              size: 16,
                              weight: .semibold,
                              color: .COLOR_TEXT_TITLE_0f1214)
        let paragraphs = section.content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let paragraphStack = UIStackView(arrangedSubviews: paragraphs.map(coachParagraphLabel))
        paragraphStack.axis = .vertical
        paragraphStack.alignment = .fill
        paragraphStack.distribution = .fill
        paragraphStack.spacing = kFitWidth(16)

        let card = roundedCard()
        card.addSubview(paragraphStack)
        paragraphStack.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(21.25))
            $0.right.equalTo(kFitWidth(-21.75))
            $0.top.equalTo(kFitWidth(14.5))
            $0.bottom.equalTo(kFitWidth(-14.5))
        }

        let stack = UIStackView(arrangedSubviews: [title, card])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = kFitWidth(12)
        return stack
    }

    func makeActionPlanSection(_ section: Goals.ActionSection) -> UIStackView {
        let title = makeLabel(section.title,
                              size: 16,
                              weight: .semibold,
                              color: .COLOR_TEXT_TITLE_0f1214)
        let itemsStack = UIStackView()
        itemsStack.axis = .vertical
        itemsStack.alignment = .fill
        itemsStack.distribution = .fill
        itemsStack.spacing = kFitWidth(16)

        section.items.forEach { item in
            let row = UIStackView(arrangedSubviews: [
                tipsTitleLabel(item.title),
                tipsDetailLabel(item.content)
            ])
            row.axis = .vertical
            row.alignment = .fill
            row.spacing = kFitWidth(4)
            itemsStack.addArrangedSubview(row)
        }

        let card = roundedCard()
        card.addSubview(itemsStack)
        itemsStack.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(20))
            $0.right.equalTo(kFitWidth(-20))
            $0.top.equalTo(kFitWidth(15))
            $0.bottom.equalTo(kFitWidth(-15))
        }

        let stack = UIStackView(arrangedSubviews: [title, card])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = kFitWidth(12)
        return stack
    }

    func makeConclusionSection(_ section: Goals.TextSection) -> UIStackView {
        let title = makeLabel(section.title,
                              size: 14,
                              weight: .medium,
                              color: .COLOR_TEXT_TITLE_0f1214)
        let body = tipsDetailLabel(section.content)
        let stack = UIStackView(arrangedSubviews: [title, body])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = kFitWidth(6)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0,
                                           left: kFitWidth(5),
                                           bottom: 0,
                                           right: kFitWidth(5))
        return stack
    }

    func metricLabel(title: String, color: UIColor) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = kFitWidth(3.1)
        row.snp.makeConstraints { $0.height.equalTo(kFitWidth(17.04)) }

        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = kFitWidth(4.13)
        dot.snp.makeConstraints { $0.width.height.equalTo(kFitWidth(4.13)) }

        let label = makeLabel(title, size: 11.36, weight: .regular, color: .COLOR_TEXT_TITLE_0f1214_50)
        let labelFont = pingFangFont(size: kFitWidth(11.36), weight: .regular)
        label.font = labelFont
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = kFitWidth(17.04)
        paragraphStyle.maximumLineHeight = kFitWidth(17.04)
        label.attributedText = NSAttributedString(string: title,
                                                   attributes: [.font: labelFont,
                                                                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
                                                                .paragraphStyle: paragraphStyle])
        row.addArrangedSubview(dot)
        row.addArrangedSubview(label)
        return row
    }

    func pingFangFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let name = weight == .medium ? "PingFangSC-Medium" : "PingFangSC-Regular"
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }

    func coachParagraphLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        let font = pingFangFont(size: kFitWidth(12), weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = kFitWidth(20.4)
        paragraphStyle.maximumLineHeight = kFitWidth(20.4)
        label.attributedText = NSAttributedString(string: text,
                                                   attributes: [.font: font,
                                                                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_80,
                                                                .paragraphStyle: paragraphStyle])
        return label
    }

    func tipsTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        let font = pingFangFont(size: kFitWidth(13), weight: .medium)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = kFitWidth(19.5)
        paragraphStyle.maximumLineHeight = kFitWidth(19.5)
        label.attributedText = NSAttributedString(string: text,
                                                   attributes: [.font: font,
                                                                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                                                                .paragraphStyle: paragraphStyle])
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func tipsDetailLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        let font = pingFangFont(size: kFitWidth(12), weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = kFitWidth(18)
        paragraphStyle.maximumLineHeight = kFitWidth(18)
        label.attributedText = NSAttributedString(string: text,
                                                   attributes: [.font: font,
                                                                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_80,
                                                                .paragraphStyle: paragraphStyle])
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func roundedCard() -> UIView { let view = UIView(); view.backgroundColor = .COLOR_CARD_BG_WHITE; view.layer.cornerRadius = kFitWidth(12); return view }
    func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel { let label = UILabel(); label.text = text; label.textColor = color; label.font = .systemFont(ofSize: size, weight: weight); label.numberOfLines = 0; return label }

    func updateValues() {
        updateCaloriesLabel()
        carbohydrateField.text = numberText(goals.carbohydrate)
        proteinField.text = numberText(goals.protein)
        fatField.text = numberText(goals.fat)
    }

    @objc func nutritionFieldEditingChanged(_ textField: UITextField) {
        let carbohydrate = Double(carbohydrateField.text ?? "") ?? 0
        let protein = Double(proteinField.text ?? "") ?? 0
        let fat = Double(fatField.text ?? "") ?? 0
        goals = Goals(protein: protein,
                      carbohydrate: carbohydrate,
                      fat: fat,
                      calories: calories(for: carbohydrate,
                                        protein: protein,
                                        fat: fat),
                      coachSuggestion: goals.coachSuggestion)
        updateCaloriesLabel()
    }

    func calories(for carbohydrate: Double, protein: Double, fat: Double) -> Double {
        (carbohydrate + protein) * 4 + fat * 9
    }

    func updateCaloriesLabel() {
        let calorieFont = UIFont().DDInFontSemiBold(fontSize: kFitWidth(20.655))
        let calorieParagraphStyle = NSMutableParagraphStyle()
        calorieParagraphStyle.minimumLineHeight = kFitWidth(30.985)
        calorieParagraphStyle.maximumLineHeight = kFitWidth(30.985)
        calorieParagraphStyle.alignment = .center
        caloriesLabel.attributedText = NSAttributedString(string: numberText(goals.calories),
                                                           attributes: [.font: calorieFont,
                                                                        .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                                                                        .paragraphStyle: calorieParagraphStyle])
    }

    func numberText(_ value: Double) -> String { value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value) }

    func setEditingState(_ editing: Bool, animated: Bool) {
        isEditingGoals = editing
        carbohydrateField.isUserInteractionEnabled = editing
        proteinField.isUserInteractionEnabled = editing
        fatField.isUserInteractionEnabled = editing
        if animated { UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() } }
    }

    func validatedGoalsFromFields() -> Goals? {
        if carbohydrateField.text?.count == 0 {
            MCToast.mc_text("请输入碳水化合物数值", respond: .allow)
            return nil
        }

        let carbohydrate = Int(carbohydrateField.text ?? "0") ?? 0
        guard carbohydrate >= 0, carbohydrate <= 4999 else {
            MCToast.mc_text("碳水化合物目标数值范围 0 ~ 4999 g", respond: .allow)
            return nil
        }

        let protein = Int(proteinField.text ?? "0") ?? 0
        guard protein >= 1, protein <= 4999 else {
            MCToast.mc_text("蛋白质目标数值范围 1 ~ 4999 g", respond: .allow)
            return nil
        }

        let fat = Int(fatField.text ?? "0") ?? 0
        guard fat >= 1, fat <= 4999 else {
            MCToast.mc_text("脂肪目标数值范围 1 ~ 4999 g", respond: .allow)
            return nil
        }

        let carbohydrateValue = Double(carbohydrate)
        let proteinValue = Double(protein)
        let fatValue = Double(fat)
        return Goals(protein: proteinValue,
                     carbohydrate: carbohydrateValue,
                     fat: fatValue,
                     calories: calories(for: carbohydrateValue,
                                        protein: proteinValue,
                                        fat: fatValue),
                     coachSuggestion: goals.coachSuggestion)
    }

    func saveGoals() {
        // 登录前只保存到 Guide0820 的待绑定模型；正式用户目标由登录后的 custom_save 设置。
        // 接口 calories 为整数，按项目读取默认目标时既有的 rounded 规则统一一次取整。
        Guide0820ProgressStorage.saveFinalNutritionGoals(
            carbohydrate: goals.carbohydrate,
            protein: goals.protein,
            fat: goals.fat,
            calories: Int(goals.calories.rounded())
        )
    }

    /// 切换当前页面对应的三方输入法开关。
    private func setKeyboardExtensionAllowed(_ allowed: Bool) {
        (UIApplication.shared.delegate as? AppDelegate)?.setKeyboardExtensionAllowed(allowed)
    }
}

extension GuidanceNutritionGoalsResultVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowed = CharacterSet.decimalDigits
        guard string.rangeOfCharacter(from: allowed.inverted) == nil,
              let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return false
        }

        // When a field currently contains only zero, typing a non-zero value
        // replaces that zero instead of producing a leading-zero number.
        if currentText == "0",
           range.location == (currentText as NSString).length,
           range.length == 0,
           let firstCharacter = string.first,
           firstCharacter != "0" {
            guard string.count <= 5 else { return false }
            textField.text = string
            textField.sendActions(for: .editingChanged)
            return false
        }

        let nextText = currentText.replacingCharacters(in: textRange, with: string)
        guard nextText.count <= 5 else { return false }

        // Empty and a single zero are valid editing states. Any multi-digit
        // integer with a leading zero (00, 01, 010, etc.) is not.
        let isIntegerText = nextText.unicodeScalars.allSatisfy { allowed.contains($0) }
        if nextText.count > 1, nextText.hasPrefix("0"), isIntegerText {
            return false
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Keep the focus indicator on the currently active field only.
        [carbohydrateField, proteinField, fatField].forEach {
            $0.layer.borderWidth = 0
            $0.layer.borderColor = nil
        }
        textField.layer.borderWidth = kFitWidth(1)
        textField.layer.borderColor = UIColor.THEME.resolvedColor(with: traitCollection).cgColor
        if !isEditingGoals {
            setEditingState(true, animated: true)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.layer.borderColor = nil
    }
}
