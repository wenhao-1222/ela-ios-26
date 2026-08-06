//
//  GuidanceProPurchasedConfirmAlertVM.swift
//  lns
//
//  Created by Codex on 2026/8/6.
//

import UIKit
import SnapKit

final class GuidanceProPurchasedCheckButton: ElaExpandedTapButton {
    private let checkImageView = UIImageView()
    private var isApplyingState = false

    override var isSelected: Bool {
        didSet {
            guard !isApplyingState else { return }
            applyCheckState(animated: true)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        applyCheckState(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChecked(_ checked: Bool, animated: Bool) {
        isApplyingState = true
        super.isSelected = checked
        applyCheckState(animated: animated)
        isApplyingState = false
    }

    private func initUI() {
        addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(30))
        }
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.isUserInteractionEnabled = false
    }

    private func applyCheckState(animated: Bool) {
        checkImageView.setCheckState(isSelected,
                                     checkedImageName: "circle_today_select_icon",
                                     uncheckedImageName: "circle_today_normal_icon",
                                     animated: animated)
    }
}

final class GuidanceProPurchasedConfirmAlertVM: UIView {

    enum LinkType {
        case membershipAgreement
    }

    var confirmBlock: (() -> Void)?
    var linkTapBlock: ((LinkType) -> Void)?

    private static let linkAttribute = NSAttributedString.Key("GuidanceProPurchasedConfirmAlertLinkType")
    private let blueColor = UIColor.THEME//WHColor_16(colorStr: "1677F2")
    private var isDismissing = false

    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAction))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(34)
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
        }
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.16).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = kFitWidth(18)
        view.layer.shadowOffset = CGSize(width: 0, height: kFitWidth(8))

        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "购买前请确认"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "为确保你的权益，请在确认需要 ELA PRO 后，\n再勾选并支付"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.25)
        return label
    }()

    private lazy var agreementCheckButton: GuidanceProPurchasedCheckButton = {
        makeCheckButton(action: #selector(toggleAgreementAction))
    }()

    private lazy var coachCheckButton: GuidanceProPurchasedCheckButton = {
        makeCheckButton(action: #selector(toggleCoachAction))
    }()

    private lazy var refundCheckButton: GuidanceProPurchasedCheckButton = {
        makeCheckButton(action: #selector(toggleRefundAction))
    }()

    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.isUserInteractionEnabled = true
        label.attributedText = makeAgreementText()
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(agreementTapAction(_:))))
        return label
    }()

    private lazy var coachLabel: UILabel = {
        makeBodyLabel("我明白教练调整建议和分析，需要基于我的主动记录，才能提供帮助。")
    }()

    private lazy var refundLabel: UILabel = {
        makeBodyLabel("我理解数据计算会消耗成本，虚拟产品购买后不退款。")
    }()

    private lazy var agreementRow: UIStackView = {
        makeRow(checkButton: agreementCheckButton, label: agreementLabel)
    }()

    private lazy var coachRow: UIStackView = {
        makeRow(checkButton: coachCheckButton, label: coachLabel)
    }()

    private lazy var refundRow: UIStackView = {
        makeRow(checkButton: refundCheckButton, label: refundLabel)
    }()

    private lazy var itemStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [agreementRow, coachRow, refundRow])
        stack.axis = .vertical
        stack.spacing = kFitWidth(15)
        stack.alignment = .fill
        return stack
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        button.layer.cornerRadius = kFitWidth(22)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确认付款", for: .normal)
        button.setTitleColor(.THEME, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        button.layer.cornerRadius = kFitWidth(22)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isHidden = true
        isUserInteractionEnabled = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showSelf() {
        guard isHidden else { return }

        isDismissing = false
        resetConfirmationState()
        isHidden = false
        dimView.alpha = 0
        whiteView.alpha = 0
        whiteView.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
        layoutIfNeeded()

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.dimView.alpha = 1
            self.whiteView.alpha = 1
            self.whiteView.transform = .identity
        }
    }

    func hiddenSelf(completion: (() -> Void)? = nil) {
        guard !isDismissing else { return }
        isDismissing = true

        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn, .allowUserInteraction]) {
            self.dimView.alpha = 0
            self.whiteView.alpha = 0
            self.whiteView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        } completion: { _ in
            self.isHidden = true
            self.isDismissing = false
            completion?()
        }
    }
}

private extension GuidanceProPurchasedConfirmAlertVM {
    func initUI() {
        addSubview(dimView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(subtitleLabel)
        whiteView.addSubview(itemStackView)
        whiteView.addSubview(cancelButton)
        whiteView.addSubview(confirmButton)

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        whiteView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualTo(kFitWidth(27))
            make.right.lessThanOrEqualTo(kFitWidth(-27))
            make.width.equalTo(SCREEN_WIDHT - kFitWidth(40))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(20))
            make.left.right.equalToSuperview().inset(kFitWidth(20))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(7))
            make.left.right.equalToSuperview().inset(kFitWidth(20))
        }

        itemStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(22))
            make.left.right.equalToSuperview().inset(kFitWidth(24))
        }

        cancelButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(33))
            make.top.equalTo(itemStackView.snp.bottom).offset(kFitWidth(35))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-20))
        }

        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(cancelButton.snp.right).offset(kFitWidth(14))
            make.right.equalTo(kFitWidth(-20))
            make.centerY.equalTo(cancelButton)
            make.width.equalTo(cancelButton)
            make.height.equalTo(cancelButton)
        }
    }

    func makeRow(checkButton: UIButton, label: UILabel) -> UIStackView {
        checkButton.setContentHuggingPriority(.required, for: .horizontal)
        checkButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            checkButton.widthAnchor.constraint(equalToConstant: kFitWidth(30)),
            checkButton.heightAnchor.constraint(equalToConstant: kFitWidth(30))
        ])

        let stack = UIStackView(arrangedSubviews: [checkButton, label])
        stack.axis = .horizontal
        stack.spacing = kFitWidth(2)
        stack.alignment = .center
        return stack
    }

    func makeCheckButton(action: Selector) -> GuidanceProPurchasedCheckButton {
        let button = GuidanceProPurchasedCheckButton(type: .custom)
        button.hitTestEdgeInsets = .init(top: -8, left: -8, bottom: -8, right: -8)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func makeBodyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: label.font as Any,
                .foregroundColor: label.textColor as Any,
                .paragraphStyle: bodyParagraphStyle()
            ]
        )
        return label
    }

    func makeAgreementText() -> NSAttributedString {
        let normalText = "我已阅读并同意 "
        let membershipAgreement = "《会员服务协议》"
        let text = normalText + membershipAgreement
        let result = NSMutableAttributedString(string: text)
        result.addAttributes([
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214
        ], range: NSRange(location: 0, length: (text as NSString).length))

        addLinkAttributes(to: result, text: membershipAgreement, type: .membershipAgreement)
        return result
    }

    func addLinkAttributes(to text: NSMutableAttributedString,
                           text linkText: String,
                           type: LinkType) {
        let range = (text.string as NSString).range(of: linkText)
        guard range.location != NSNotFound else { return }
        text.addAttributes([
            .foregroundColor: blueColor,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
            Self.linkAttribute: linkAttributeValue(for: type)
        ], range: range)
    }

    func linkAttributeValue(for type: LinkType) -> String {
        switch type {
        case .membershipAgreement:
            return "membershipAgreement"
        }
    }

    func linkType(for value: String) -> LinkType? {
        switch value {
        case "membershipAgreement":
            return .membershipAgreement
        default:
            return nil
        }
    }

    func bodyParagraphStyle() -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.25
        style.alignment = .left
        return style
    }

    @objc func confirmAction() {
        let uncheckedRows = [
            (agreementCheckButton.isSelected == false, agreementRow),
            (coachCheckButton.isSelected == false, coachRow),
            (refundCheckButton.isSelected == false, refundRow)
        ]
        let hasUncheckedRow = uncheckedRows.contains { $0.0 }

        guard !hasUncheckedRow else {
            uncheckedRows
                .filter { $0.0 }
                .forEach { shake($0.1) }
            return
        }

        hiddenSelf { [weak self] in
            self?.confirmBlock?()
        }
    }

    @objc func dismissAction() {
        hiddenSelf()
    }

    @objc func toggleAgreementAction() {
        agreementCheckButton.isSelected.toggle()
        updateConfirmButtonAppearance()
    }

    @objc func toggleCoachAction() {
        coachCheckButton.isSelected.toggle()
        updateConfirmButtonAppearance()
    }

    @objc func toggleRefundAction() {
        refundCheckButton.isSelected.toggle()
        updateConfirmButtonAppearance()
    }

    @objc func nothingToDo() {
    }

    @objc func agreementTapAction(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let type = linkType(at: gesture.location(in: label), in: label) else {
            return
        }

        linkTapBlock?(type)
    }

    func linkType(at point: CGPoint, in label: UILabel) -> LinkType? {
        guard let attributedText = label.attributedText, !attributedText.string.isEmpty else {
            return nil
        }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        let textRect = label.textRect(forBounds: label.bounds,
                                      limitedToNumberOfLines: label.numberOfLines)
        guard textRect.contains(point) else { return nil }

        let location = CGPoint(x: point.x - textRect.origin.x,
                               y: point.y - textRect.origin.y)
        let glyphIndex = layoutManager.glyphIndex(for: location, in: textContainer)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1),
                                                   in: textContainer)
        guard glyphRect.contains(location) else { return nil }

        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        guard characterIndex < attributedText.length,
              let value = attributedText.attribute(Self.linkAttribute,
                                                   at: characterIndex,
                                                   effectiveRange: nil) as? String else {
            return nil
        }
        return linkType(for: value)
    }

    func resetConfirmationState() {
        [agreementCheckButton, coachCheckButton, refundCheckButton].forEach {
            $0.setChecked(false, animated: false)
            updateCheckButtonColor($0)
        }
        updateConfirmButtonAppearance()
    }

    func updateCheckButtonColor(_ button: UIButton) {
        button.tintColor = .clear
    }

    func updateConfirmButtonAppearance() {
        let isAllChecked = agreementCheckButton.isSelected
            && coachCheckButton.isSelected
            && refundCheckButton.isSelected
//        confirmButton.backgroundColor = isAllChecked ? blueColor : WHColor_16(colorStr: "E4E5E7")
        
        confirmButton.setTitleColor(isAllChecked ? UIColor.THEME : UIColor.COLOR_TEXT_TITLE_0f1214_30, for: .normal)
    }

    func shake(_ row: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.3
        animation.values = [-5, 5, -5, 5, 0]
        row.layer.add(animation, forKey: "shake")
    }
}
