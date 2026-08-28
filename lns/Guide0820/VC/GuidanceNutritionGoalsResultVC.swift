//
//  GuidanceNutritionGoalsResultVC.swift
//  lns
//
//  Initial nutrition goals result page shown after the v3 goals request.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift

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
    private let tipsStack = UIStackView()
    private lazy var bottomSheetView = Guide0820BottomSheetView()

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
        // The selected nutrition values are the edit affordances in the
        // MasterGo card. Tapping one of them opens the dedicated edit state.
        saveGoals()
        completion?()
    }

}

private extension GuidanceNutritionGoalsResultVC {
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
        view.addSubview(primaryButton)
        view.addSubview(closeButton)
        view.addSubview(bottomSheetView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.bottom.equalTo(primaryButton.snp.top).offset(kFitWidth(-16))
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
        editCard.backgroundColor = .white
        editCard.layer.cornerRadius = kFitWidth(12)
        editCard.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(16)); $0.right.equalTo(kFitWidth(-16)); $0.top.equalTo(titleStack.snp.bottom).offset(kFitWidth(22.5)); $0.height.equalTo(kFitWidth(149))
        }
        makeNutritionCard()

        let coachTitle = makeLabel("教练对你现阶段的判断", size: 16, weight: .semibold, color: .COLOR_TEXT_TITLE_0f1214)
        let coachCard = roundedCard()
        let coachParagraphs = UIStackView(arrangedSubviews: [
            coachParagraphLabel("对你来说，现阶段更重要的是尽快为肌肉增长提供充足能量，而不是把体重增长控制得过于保守。你的初始目标会设置更明显的热量盈余，同时让碳水和脂肪保持相对均衡。"),
            coachParagraphLabel("从你目前的训练目标来看，力量训练需要充足的碳水支持训练表现、肌糖原补充和恢复，同时也需要保证必要的脂肪摄入，有助于维持正常激素水平。让碳水和脂肪保持相对均衡，可以为力量提升和肌肉增长提供稳定的营养基础。")
        ])
        coachParagraphs.axis = .vertical
        coachParagraphs.alignment = .fill
        coachParagraphs.distribution = .fill
        coachParagraphs.spacing = kFitWidth(16)
        coachCard.addSubview(coachParagraphs)
        coachParagraphs.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(21.25))
            $0.right.equalTo(kFitWidth(-21.75))
            $0.top.equalTo(kFitWidth(14.5))
            $0.bottom.equalTo(kFitWidth(-14.5))
        }
        contentView.addSubview(coachTitle); contentView.addSubview(coachCard)
        coachTitle.snp.makeConstraints { $0.left.equalTo(kFitWidth(16)); $0.top.equalTo(editCard.snp.bottom).offset(kFitWidth(25)) }
        coachCard.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(16))
            $0.right.equalTo(kFitWidth(-16))
            $0.top.equalTo(coachTitle.snp.bottom).offset(kFitWidth(12))
        }

        let tipsTitle = makeLabel("接下来，先做好这些", size: 16, weight: .semibold, color: .COLOR_TEXT_TITLE_0f1214)
        tipsStack.axis = .vertical
        tipsStack.alignment = .fill
        tipsStack.distribution = .fill
        tipsStack.spacing = kFitWidth(16)
        [("1、看清每日空间", "记录每天真实摄入，清楚热量预算和蛋白质目标的完成情况。"), ("2、控制碳水占比", "按照当前相对较低的碳水比例执行，让热量缺口更贴近你更容易控制的饮食结构。"), ("3、建立减脂基线", "持续记录饮食和体重，让 ELA 逐步掌握实际摄入与体重变化之间的关系。")].forEach { title, body in
            let titleLabel = tipsTitleLabel(title)
            titleLabel.widthAnchor.constraint(equalToConstant: kFitWidth(206)).isActive = true
            let detailLabel = tipsDetailLabel(body)
            let row = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
            row.axis = .vertical
            row.alignment = .fill
            row.spacing = kFitWidth(4)
            tipsStack.addArrangedSubview(row)
        }
        let tipsCard = roundedCard(); tipsCard.addSubview(tipsStack)
        tipsStack.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(20))
            $0.right.equalTo(kFitWidth(-20))
            $0.top.equalTo(kFitWidth(15))
            $0.bottom.equalTo(kFitWidth(-15))
        }
        contentView.addSubview(tipsTitle); contentView.addSubview(tipsCard)
        tipsTitle.snp.makeConstraints { $0.left.equalTo(kFitWidth(16)); $0.top.equalTo(coachCard.snp.bottom).offset(kFitWidth(23.5)) }
        tipsCard.snp.makeConstraints { $0.left.equalTo(kFitWidth(16)); $0.right.equalTo(kFitWidth(-16)); $0.top.equalTo(tipsTitle.snp.bottom).offset(kFitWidth(12)); $0.height.equalTo(kFitWidth(240.5)) }

        let noteTitle = makeLabel("这是结合你目前情况，为现阶段制定的营养目标。", size: 14, weight: .medium, color: .COLOR_TEXT_TITLE_0f1214)
        let noteBody = tipsDetailLabel("随着饮食和体重数据逐渐积累，ELA 会进一步识别你的实际变化规律，让后续调整更贴近你的身体反应和进度。")
        let noteStack = UIStackView(arrangedSubviews: [noteTitle, noteBody])
        noteStack.axis = .vertical; noteStack.spacing = kFitWidth(6)
        contentView.addSubview(noteStack)
        noteStack.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(21)); $0.right.equalTo(kFitWidth(-21)); $0.top.equalTo(tipsCard.snp.bottom).offset(kFitWidth(25.5))
            $0.bottom.equalToSuperview().offset(kFitWidth(-16))
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
        label.numberOfLines = 1
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

    func roundedCard() -> UIView { let view = UIView(); view.backgroundColor = .white; view.layer.cornerRadius = kFitWidth(12); return view }
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
                                        fat: fat))
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

    func validValue(for field: UITextField, allowingZero: Bool) -> Double? {
        guard let text = field.text, let value = Double(text), value >= 0, allowingZero || value > 0 else { return nil }
        return value
    }

    func saveGoals() {
        NutritionDefaultModel.shared.saveGoals(dict: ["calories": numberText(goals.calories), "carbohydrates": numberText(goals.carbohydrate), "proteins": numberText(goals.protein), "fats": numberText(goals.fat)] as NSDictionary)
    }

    func showValidationAlert() {
        let alert = UIAlertController(title: "请输入有效目标", message: "碳水可以为 0，蛋白质和脂肪必须大于 0。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }

    /// 切换当前页面对应的三方输入法开关。
    private func setKeyboardExtensionAllowed(_ allowed: Bool) {
        (UIApplication.shared.delegate as? AppDelegate)?.setKeyboardExtensionAllowed(allowed)
    }
}

extension GuidanceNutritionGoalsResultVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowed = CharacterSet.decimalDigits
        return string.rangeOfCharacter(from: allowed.inverted) == nil && (textField.text?.count ?? 0) + string.count - range.length <= 5
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Keep the focus indicator on the currently active field only.
        [carbohydrateField, proteinField, fatField].forEach {
            $0.layer.borderWidth = 0
            $0.layer.borderColor = nil
        }
        textField.layer.borderWidth = kFitWidth(1)
        textField.layer.borderColor = UIColor.THEME.cgColor
        if !isEditingGoals {
            setEditingState(true, animated: true)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.layer.borderColor = nil
    }
}
