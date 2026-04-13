//
//  GuidanceNutritionGoalVM.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit
import SnapKit
import MCToast

class GuidanceNutritionGoalVM: UIView {
    
    var saveBlock: (() -> ())?
    var tipsTapBlock:(()->())?
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    
    //    private var titleTopConstraint: Constraint?
    //    private var cardViewTopConstraint: Constraint?
    //    private let titleDefaultTopOffset = WHUtils().getNavigationBarHeight() + kFitWidth(88)
    //    private let titleMinimumTopOffset = WHUtils().getNavigationBarHeight() + kFitWidth(12)
    //    private let cardViewDefaultTopOffset = kFitWidth(56)
    //    private let cardViewKeyboardSpacing = kFitWidth(16)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
                initUI()
        //        registerKeyboardNotifications()
        //        refreshContentFromModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "你的卡路里和营养素目标"
        lab.text = "你的每日营养目标"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 22, weight: .medium)
        return lab
    }()
    lazy var tipsButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("别指望算法能 100%懂你", for: .normal)
//        btn.setTitle("如何使用这些目标？", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: (SCREEN_WIDHT-kFitWidth(320))*0.5, y: kFitWidth(192)+statusBarHeight, width: kFitWidth(320), height: kFitWidth(414)))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var labelOne : UILabel = {
        let lab = UILabel()
        lab.text = "-"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_25//WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = UIFont().DDInFontMedium(fontSize: 28)
        
        return lab
    }()
    lazy var labelTwo : UILabel = {
        let lab = UILabel()
        lab.text = "卡路里 (千卡)"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var goalImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_goal_selected")
        
        return img
    }()
    lazy var carVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(114), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "碳水化合物"
        vm.textField.textContentType = nil
        
        vm.numberChangeBlock = {(number)in
            self.carNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(182), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.textField.textContentType = nil
        
        vm.numberChangeBlock = {(number)in
            self.proteinNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(250), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "脂肪"
        vm.textField.textContentType = nil
        
        vm.numberChangeBlock = {(number)in
            self.fatNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(20), y: kFitWidth(346), width: kFitWidth(281), height: kFitWidth(44))
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
}

extension GuidanceNutritionGoalVM{
    private func resolvedGoalText(primary: String, fallback: String) -> String {
        let primaryText = primary.trimmingCharacters(in: .whitespacesAndNewlines)
        if !primaryText.isEmpty && primaryText != "-" {
            return primaryText
        }

        let fallbackText = fallback.trimmingCharacters(in: .whitespacesAndNewlines)
        if !fallbackText.isEmpty && fallbackText != "-" {
            return fallbackText
        }

        return ""
    }

    @objc func tipsTapAction(){
        self.carVm.textField.resignFirstResponder()
        self.proteinVm.textField.resignFirstResponder()
        self.fatVm.textField.resignFirstResponder()
//        alertVm.showView()
        self.tipsTapBlock?()
    }
    @objc func nextAction(){
        self.checkValue()
    }
    func checkValue() {
        if carVm.textField.text?.count == 0 {
            MCToast.mc_text("请输入碳水化合物数值",respond: .allow)
            return
        }
        
        if Int(carVm.textField.text ?? "0") ?? 0 >= 0 && Int(carVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("碳水化合物目标数值范围 0 ~ 4999 g",respond: .allow)
            return
        }
        if Int(proteinVm.textField.text ?? "0") ?? 0 >= 1 && Int(proteinVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("蛋白质目标数值范围 1 ~ 4999 g",respond: .allow)
            return
        }
        if Int(fatVm.textField.text ?? "0") ?? 0 >= 1 && Int(fatVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("脂肪目标数值范围 1 ~ 4999 g",respond: .allow)
            return
        }
        QuestinonaireMsgModel.shared.carbohydrates = carVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.protein = proteinVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.fats = fatVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.calories = labelOne.text ?? "0"
        
        QuestinonaireMsgModel.shared.carbohydratesNumber = carVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.proteinNumber = proteinVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.fatsNumber = fatVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.caloriesNumber = labelOne.text ?? "0"
        
//        WHBaseViewVC().changeRootVcToLogin()
        
        self.saveBlock?()
    }
    func calculateNumber() {
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            labelOne.text = "-"
            labelOne.textColor = .COLOR_TEXT_TITLE_0f1214_25//WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
            return
        }
        //((protein + carbohydrate) * 4) + (fat * 9);
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        labelOne.text = "\(number)"
        labelOne.textColor = .COLOR_TEXT_TITLE_0f1214
    }
    func refreshContentFromModel() {
//        self.carNumber = QuestinonaireMsgModel.shared.carbohydratesNumber.intValue
//        self.proteinNumber = QuestinonaireMsgModel.shared.proteinNumber.intValue
//        self.fatNumber = QuestinonaireMsgModel.shared.fatsNumber.intValue
//
//        carVm.textField.text = QuestinonaireMsgModel.shared.carbohydratesNumber
//        proteinVm.textField.text = QuestinonaireMsgModel.shared.proteinNumber
//        fatVm.textField.text = QuestinonaireMsgModel.shared.fatsNumber
//        labelOne.text = QuestinonaireMsgModel.shared.caloriesNumber
        let carbohydrateText = resolvedGoalText(primary: QuestinonaireMsgModel.shared.carbohydratesNumber,
                                                fallback: QuestinonaireMsgModel.shared.carbohydratesNumberFromServer)
        let proteinText = resolvedGoalText(primary: QuestinonaireMsgModel.shared.proteinNumber,
                                           fallback: QuestinonaireMsgModel.shared.proteinNumberFromServer)
        let fatText = resolvedGoalText(primary: QuestinonaireMsgModel.shared.fatsNumber,
                                       fallback: QuestinonaireMsgModel.shared.fatsNumberFromServer)
        let caloriesText = resolvedGoalText(primary: QuestinonaireMsgModel.shared.caloriesNumber,
                                            fallback: QuestinonaireMsgModel.shared.caloriesNumberFromServer)

        // 请求成功后，如果本地展示字段被提前清空，优先回填服务端缓存值，避免页面出现空白。
        if QuestinonaireMsgModel.shared.carbohydratesNumber.isEmpty {
            QuestinonaireMsgModel.shared.carbohydratesNumber = carbohydrateText
        }
        if QuestinonaireMsgModel.shared.proteinNumber.isEmpty {
            QuestinonaireMsgModel.shared.proteinNumber = proteinText
        }
        if QuestinonaireMsgModel.shared.fatsNumber.isEmpty {
            QuestinonaireMsgModel.shared.fatsNumber = fatText
        }
        if QuestinonaireMsgModel.shared.caloriesNumber.isEmpty {
            QuestinonaireMsgModel.shared.caloriesNumber = caloriesText
        }

        self.carNumber = carbohydrateText.intValue
        self.proteinNumber = proteinText.intValue
        self.fatNumber = fatText.intValue
        
        carVm.textField.text = carbohydrateText.isEmpty ? nil : carbohydrateText
        proteinVm.textField.text = proteinText.isEmpty ? nil : proteinText
        fatVm.textField.text = fatText.isEmpty ? nil : fatText
        labelOne.text = caloriesText.isEmpty ? "-" : caloriesText
        self.calculateNumber()
    }
}

extension GuidanceNutritionGoalVM{
    func initUI() {
        backgroundColor = .COLOR_BG_WHITE//WHColor_16(colorStr: "FAFAFA")
        addSubview(titleLabel)
        addSubview(tipsButton)
        addSubview(whiteView)
        whiteView.addSubview(labelOne)
        whiteView.addSubview(labelTwo)
        whiteView.addSubview(goalImgView)
        whiteView.addSubview(carVm)
        whiteView.addSubview(proteinVm)
        whiteView.addSubview(fatVm)
        
        whiteView.addSubview(nextBtn)
        
        whiteView.addShadow()
        
        setConstrait()
    }
    func setConstrait(){
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(90)+statusBarHeight)
        }
        tipsButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
        }
        labelOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(24))
        }
        labelTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(62))
        }
        goalImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(24))
            make.width.height.equalTo(kFitWidth(48))
        }
    }
}

//    lazy var cardView: UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .COLOR_BG_WHITE
//        vi.layer.cornerRadius = kFitWidth(16)
//        vi.clipsToBounds = true
//        return vi
//    }()
//
//    lazy var caloriesLabel: UILabel = {
//        let lab = UILabel()
//        lab.textColor = .COLOR_TEXT_TITLE_0f1214
//        lab.font = .systemFont(ofSize: 28, weight: .regular)
//        lab.text = "-"
//        return lab
//    }()
//
//    lazy var caloriesTitleLabel: UILabel = {
//        let lab = UILabel()
//        lab.text = "卡路里 (千卡)"
//        lab.textColor = .COLOR_TEXT_TITLE_0f1214
//        lab.font = .systemFont(ofSize: 14, weight: .regular)
//        return lab
//    }()
//
//    lazy var goalIconView: UIImageView = {
//        let img = UIImageView()
////        if #available(iOS 13.0, *) {
////            img.image = UIImage(systemName: "target")
////        }
//        img.image = UIImage(named: "question_goal_selected")
////        img.tintColor = .THEME
////        img.contentMode = .scaleAspectFit
//        return img
//    }()
//
//    lazy var carbRow = GuidanceNutritionGoalRowView(title: "碳水化合物")
//    lazy var proteinRow = GuidanceNutritionGoalRowView(title: "蛋白质")
//    lazy var fatRow = GuidanceNutritionGoalRowView(title: "脂肪")
//
//    lazy var saveButton: UIButton = {
//        let btn = UIButton(type: .custom)
//        btn.setTitle("保存目标", for: .normal)
//        btn.setTitleColor(.white, for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
//        btn.backgroundColor = .THEME
//        btn.layer.cornerRadius = kFitWidth(24)
//        btn.clipsToBounds = true
//        btn.enablePressEffect()
//        btn.addTarget(self, action: #selector(saveTapAction), for: .touchUpInside)
//        return btn
//    }()
//}
//
//extension GuidanceNutritionGoalVM {
//    @objc func saveTapAction() {
//        saveBlock?()
//    }
//    
//    func registerKeyboardNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    @objc func keyboardWillChangeFrame(_ notification: Notification) {
//        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//        let keyboardFrameInView = convert(keyboardFrame, from: nil)
//        let keyboardMinY = keyboardFrameInView.minY
//        layoutIfNeeded()
//        guard let anchorView = currentKeyboardAnchorView() else {
//            updateLayoutOffsets(headerShift: 0, cardOffset: cardViewDefaultTopOffset, notification: notification)
//            return
//        }
//        let anchorFrame = convert(anchorView.bounds, from: anchorView)
//        let targetBottom = keyboardMinY - cardViewKeyboardSpacing
//        let overlap = max(0, anchorFrame.maxY - targetBottom)
//        let maxHeaderShift = max(0, titleLabel.frame.minY - titleMinimumTopOffset)
//        let headerShift = min(overlap, maxHeaderShift)
//        updateLayoutOffsets(headerShift: headerShift,
//                            cardOffset: cardViewDefaultTopOffset - overlap + headerShift,
//                            notification: notification)
//    }
//
//    @objc func keyboardWillHide(_ notification: Notification) {
//        updateLayoutOffsets(headerShift: 0, cardOffset: cardViewDefaultTopOffset, notification: notification)
//    }
//
//    func updateLayoutOffsets(headerShift: CGFloat, cardOffset: CGFloat, notification: Notification?) {
//        titleTopConstraint?.update(offset: titleDefaultTopOffset - headerShift)
//        cardViewTopConstraint?.update(offset: cardOffset)
//
//        let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
//        let curveRaw = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
//        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
//        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) {
//            self.layoutIfNeeded()
//        }
//    }
//
//    func currentKeyboardAnchorView() -> UIView? {
//        cardView.findFirstResponderView()
//    }
//
//    func refreshContentFromModel() {
//        caloriesLabel.text = QuestinonaireMsgModel.shared.caloriesNumber.isEmpty ? "0" : QuestinonaireMsgModel.shared.caloriesNumber
//        carbRow.updateValue(QuestinonaireMsgModel.shared.carbohydratesNumber)
//        proteinRow.updateValue(QuestinonaireMsgModel.shared.proteinNumber)
//        fatRow.updateValue(QuestinonaireMsgModel.shared.fatsNumber)
//    }
//
//    func initUI() {
//        addSubview(titleLabel)
//        addSubview(cardView)
//
//        cardView.addSubview(caloriesLabel)
//        cardView.addSubview(caloriesTitleLabel)
//        cardView.addSubview(goalIconView)
//        cardView.addSubview(carbRow)
//        cardView.addSubview(proteinRow)
//        cardView.addSubview(fatRow)
//        cardView.addSubview(saveButton)
//
//        titleLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            titleTopConstraint = make.top.equalTo(titleDefaultTopOffset).constraint
//        }
//
//        cardView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(20))
//            make.right.equalTo(kFitWidth(-20))
//            cardViewTopConstraint = make.top.equalTo(titleLabel.snp.bottom).offset(cardViewDefaultTopOffset).constraint
//        }
//
//        caloriesLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(18))
//            make.top.equalTo(kFitWidth(26))
//        }
//
//        caloriesTitleLabel.snp.makeConstraints { make in
//            make.left.equalTo(caloriesLabel)
//            make.top.equalTo(caloriesLabel.snp.bottom).offset(kFitWidth(6))
//        }
//
//        goalIconView.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-26))
//            make.centerY.equalTo(caloriesLabel.snp.centerY).offset(kFitWidth(14))
//            make.width.height.equalTo(kFitWidth(44))
//        }
//
//        carbRow.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(14))
//            make.right.equalTo(kFitWidth(-14))
//            make.top.equalTo(caloriesTitleLabel.snp.bottom).offset(kFitWidth(42))
//            make.height.equalTo(kFitWidth(72))
//        }
//
//        proteinRow.snp.makeConstraints { make in
//            make.left.right.height.equalTo(carbRow)
//            make.top.equalTo(carbRow.snp.bottom)
//        }
//
//        fatRow.snp.makeConstraints { make in
//            make.left.right.height.equalTo(carbRow)
//            make.top.equalTo(proteinRow.snp.bottom)
//        }
//
//        saveButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(20))
//            make.right.equalTo(kFitWidth(-20))
//            make.height.equalTo(kFitWidth(48))
//            make.top.equalTo(fatRow.snp.bottom).offset(kFitWidth(40))
//            make.bottom.equalTo(kFitWidth(-24))
//        }
//    }
//}
//
//private extension UIView {
//    func findFirstResponderView() -> UIView? {
//        if isFirstResponder {
//            return self
//        }
//        for subview in subviews {
//            if let responder = subview.findFirstResponderView() {
//                return responder
//            }
//        }
//        return nil
//    }
//}
//
//class GuidanceNutritionGoalRowView: UIView {
//
//    init(title: String) {
//        self.titleText = title
//        super.init(frame: .zero)
//        initUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private let titleText: String
//
//    lazy var titleLabel: UILabel = {
//        let lab = UILabel()
//        lab.text = titleText
//        lab.textColor = .COLOR_TEXT_TITLE_0f1214
//        lab.font = .systemFont(ofSize: 15, weight: .medium)
//        return lab
//    }()
//
//    lazy var valueLabel: UILabel = {
//        let lab = UILabel()
//        lab.textColor = .COLOR_TEXT_TITLE_0f1214
//        lab.font = .systemFont(ofSize: 15, weight: .regular)
//        lab.textAlignment = .right
//        return lab
//    }()
//
//    lazy var separatorLine: UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
//        return vi
//    }()
//}
//
//extension GuidanceNutritionGoalRowView {
//    func updateValue(_ value: String) {
//        let display = value.isEmpty ? "输入数值" : value
//        valueLabel.text = "\(display) g"
//    }
//
//    func initUI() {
//        addSubview(titleLabel)
//        addSubview(valueLabel)
//        addSubview(separatorLine)
//
//        titleLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(12))
//            make.centerY.equalToSuperview()
//        }
//
//        valueLabel.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-12))
//            make.centerY.equalToSuperview()
//        }
//
//        separatorLine.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(8))
//            make.right.equalTo(kFitWidth(-8))
//            make.bottom.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
//    }
//}
