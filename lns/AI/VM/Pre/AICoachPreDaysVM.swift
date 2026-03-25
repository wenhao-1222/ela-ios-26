//
//  AICoachPreDaysVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/25.
//

import UIKit
import SnapKit

private enum AICoachPrePopupLayout {
    static let width = kFitWidth(164)
    static let bodyHeight = kFitWidth(94)
    static let arrowWidth = kFitWidth(24)
    static let arrowHeight = kFitWidth(12)
    static let totalHeight = bodyHeight + arrowHeight
}

class AICoachPreDaysVM: UIView, UIGestureRecognizerDelegate {

    enum DayState {
        case completed
        case current
        case pending
    }

    struct DayItem {
        let title: String
        let state: DayState
        let completeStatus: Int
    }

    let selfHeight = kFitHeight(135)

    private var dayItems: [DayItem] = []
    private var reportAfterDays = 4
    private var itemViews: [AICoachPreDayItemView] = []
    private var selectedPopupIndex: Int?

    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true

        initUI()
        applyDefaultContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = kFitWidth(13)
        return stackView
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return label
    }()

    private lazy var popupView: AICoachPreDayStatusPopupView = {
        let view = AICoachPreDayStatusPopupView()
        view.isHidden = true
        return view
    }()
}

extension AICoachPreDaysVM{
    func initUI() {
        addSubview(daysStackView)
        addSubview(messageLabel)
        addSubview(popupView)

        daysStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(44))
            make.right.equalTo(kFitWidth(-44))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }

        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(daysStackView.snp.bottom).offset(kFitWidth(18))
            make.bottom.equalToSuperview()
        }

        popupView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(daysStackView.snp.bottom).offset(kFitWidth(6))
            make.width.equalTo(AICoachPrePopupLayout.width)
            make.height.equalTo(AICoachPrePopupLayout.totalHeight)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapAction))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    func configure(items: [DayItem], reportAfterDays: Int) {
        self.dayItems = items
        self.reportAfterDays = reportAfterDays
        reloadDaysUI()
        updateMessage()
        hidePopup()
    }
}

private extension AICoachPreDaysVM {
    func applyDefaultContent() {
        configure(items: [
            DayItem(title: "一", state: .completed, completeStatus: 1),
            DayItem(title: "二", state: .completed, completeStatus: 1),
            DayItem(title: "三", state: .current, completeStatus: 2),
            DayItem(title: "四", state: .pending, completeStatus: 0),
            DayItem(title: "五", state: .pending, completeStatus: 0),
            DayItem(title: "六", state: .pending, completeStatus: 0),
            DayItem(title: "日", state: .pending, completeStatus: 0)
        ], reportAfterDays: 4)
    }

    func reloadDaysUI() {
        itemViews.removeAll()
        daysStackView.arrangedSubviews.forEach { subView in
            daysStackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }

        for (index, item) in dayItems.enumerated() {
            let itemView = AICoachPreDayItemView()
            itemView.update(item: item)
            itemView.tapBlock = { [weak self, weak itemView] in
                guard let self, let itemView else { return }
                self.dayItemTapAction(index: index, sourceView: itemView)
            }
            daysStackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
    }

    func updateMessage() {
        let fullText = "请完整记录饮食和力量训练，教练将会在 \(reportAfterDays) 天后\n给你发送第一份反馈报告"
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50
            ]
        )

        let highlightText = "\(reportAfterDays)"
        let highlightRange = (fullText as NSString).range(of: highlightText)
        if highlightRange.location != NSNotFound {
            attributedText.addAttributes([
                .foregroundColor: UIColor.THEME,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ], range: highlightRange)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = kFitWidth(4)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))

        messageLabel.attributedText = attributedText
    }

    func dayItemTapAction(index: Int, sourceView: UIView) {
        if selectedPopupIndex == index, popupView.isHidden == false {
            hidePopup()
            return
        }

        selectedPopupIndex = index
        popupView.update(completeStatus: dayItems[index].completeStatus)

        let itemFrame = sourceView.convert(sourceView.bounds, to: self)
        let popupWidth = AICoachPrePopupLayout.width
        let popupLeft = min(max(itemFrame.midX - popupWidth * 0.5, kFitWidth(12)), bounds.width - popupWidth - kFitWidth(12))

        popupView.snp.remakeConstraints { make in
            make.left.equalTo(popupLeft)
            make.top.equalTo(itemFrame.maxY + kFitWidth(6))
            make.width.equalTo(AICoachPrePopupLayout.width)
            make.height.equalTo(AICoachPrePopupLayout.totalHeight)
        }

        popupView.updateArrowPosition(centerX: itemFrame.midX - popupLeft)
        bringSubviewToFront(popupView)
        popupView.isHidden = false
    }

    @objc
    func backgroundTapAction() {
        hidePopup()
    }

    func hidePopup() {
        selectedPopupIndex = nil
        popupView.isHidden = true
    }
}

extension AICoachPreDaysVM {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if popupView.isHidden == false, let touchedView = touch.view, touchedView.isDescendant(of: popupView) {
            return false
        }

        if let touchedView = touch.view {
            for itemView in itemViews where touchedView.isDescendant(of: itemView) {
                return false
            }
        }

        return true
    }
}

private final class AICoachPreDayItemView: UIView {

    var tapBlock: (() -> Void)?

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = kFitWidth(5)
        view.clipsToBounds = true
        return view
    }()

    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ai_progress_complete_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(item: AICoachPreDaysVM.DayItem) {
        titleLabel.text = item.title

        switch item.completeStatus {
        case 2:
            iconContainerView.backgroundColor = .THEME
            checkImageView.isHidden = false
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        case 1:
            iconContainerView.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
            checkImageView.isHidden = false
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        default:
            iconContainerView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_50
            checkImageView.isHidden = true
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_25
        }
    }
}

private extension AICoachPreDayItemView {
    func setupUI() {
        addSubview(iconContainerView)
        addSubview(titleLabel)
        iconContainerView.addSubview(checkImageView)

        iconContainerView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(kFitWidth(30))
        }

        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(15))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(iconContainerView.snp.bottom).offset(kFitWidth(6))
            make.bottom.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapAction))
        addGestureRecognizer(tapGesture)
    }

    @objc
    func itemTapAction() {
        tapBlock?()
    }
}

private final class AICoachPreDayStatusPopupView: UIView {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bodyView.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.95).cgColor
    }

    private let bodyCornerRadius = kFitWidth(14)
    private var arrowCenterXConstraint: Constraint?

    private lazy var bodyView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_WHITE_65
        view.layer.cornerRadius = bodyCornerRadius
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.95).cgColor
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 16
        return view
    }()

    private lazy var arrowView: AICoachPreDayStatusArrowView = {
        let view = AICoachPreDayStatusArrowView()
        return view
    }()

    private lazy var topStatusView = AICoachPreDayStatusRowView(
        title: "已记录饮食+体重",
        selectedColor: .THEME
    )

    private lazy var bottomStatusView = AICoachPreDayStatusRowView(
        title: "已记录饮食",
        selectedColor: .COLOR_TEXT_TITLE_0f1214_50
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(completeStatus: Int) {
        topStatusView.update(isSelected: true)
        bottomStatusView.update(isSelected: false)
//        topStatusView.update(isSelected: completeStatus == 2)
//        bottomStatusView.update(isSelected: completeStatus == 1 || completeStatus == 2)
    }

    func updateArrowPosition(centerX: CGFloat) {
        let minX = AICoachPrePopupLayout.arrowWidth * 0.5 + kFitWidth(18)
        let maxX = AICoachPrePopupLayout.width - AICoachPrePopupLayout.arrowWidth * 0.5 - kFitWidth(18)
        let targetX = min(max(centerX, minX), maxX)
        arrowCenterXConstraint?.update(offset: targetX - AICoachPrePopupLayout.width * 0.5)
        layoutIfNeeded()
    }
}

private extension AICoachPreDayStatusPopupView {

    func setupUI() {
        backgroundColor = .clear

        addSubview(arrowView)
        addSubview(bodyView)
        bodyView.addSubview(topStatusView)
        bodyView.addSubview(bottomStatusView)

        arrowView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(AICoachPrePopupLayout.arrowWidth)
            make.height.equalTo(AICoachPrePopupLayout.arrowHeight)
            arrowCenterXConstraint = make.centerX.equalToSuperview().constraint
        }

        bodyView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(AICoachPrePopupLayout.arrowHeight - 1)
        }

        topStatusView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(14))
            make.top.equalToSuperview().offset(kFitWidth(16))
            make.height.equalTo(kFitWidth(24))
        }

        bottomStatusView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(14))
            make.top.equalTo(topStatusView.snp.bottom).offset(kFitWidth(10))
            make.height.equalTo(kFitWidth(24))
        }
    }
}

private final class AICoachPreDayStatusArrowView: UIView {

    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let shapeLayer = layer as? CAShapeLayer else { return }
        shapeLayer.fillColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.95).cgColor
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let shapeLayer = layer as? CAShapeLayer else { return }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.5, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.width * 0.5, y: 0.5))
        path.addLine(to: CGPoint(x: bounds.width - 0.5, y: bounds.height))
        path.close()

        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
        shapeLayer.strokeColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.95).cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        shapeLayer.shadowOpacity = 1
        shapeLayer.shadowOffset = CGSize(width: 0, height: 2)
        shapeLayer.shadowRadius = 6
    }
}

private final class AICoachPreDayStatusRowView: UIView {

    private let title: String
    private let selectedColor: UIColor

    init(title: String, selectedColor: UIColor) {
        self.title = title
        self.selectedColor = selectedColor
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = kFitWidth(4)
        view.clipsToBounds = true
        return view
    }()

    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ai_progress_complete_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    func update(isSelected: Bool) {
        iconContainerView.backgroundColor = isSelected ? selectedColor : .COLOR_TEXT_TITLE_0f1214_50
//        checkImageView.isHidden = isSelected == false
//        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
    }
}

private extension AICoachPreDayStatusRowView {
    func setupUI() {
        addSubview(iconContainerView)
        addSubview(titleLabel)
        iconContainerView.addSubview(checkImageView)

        iconContainerView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(18))
        }

        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(10))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconContainerView.snp.right).offset(kFitWidth(8))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }

        update(isSelected: false)
    }
}
