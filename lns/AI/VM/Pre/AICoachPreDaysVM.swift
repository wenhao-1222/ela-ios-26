//
//  AICoachPreDaysVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/25.
//

import UIKit
import SnapKit

private enum AICoachPrePopupLayout {
    static let minWidth = kFitWidth(164)
    static let horizontalPadding = kFitWidth(14)
    static let topPadding = kFitWidth(15)
    static let bottomPadding = kFitWidth(15)
    static let rowSpacing = kFitWidth(10)
    static let rowIconSize = kFitWidth(18)
    static let rowLabelSpacing = kFitWidth(8)
    static let arrowWidth = kFitWidth(24)
    static let arrowHeight = kFitWidth(12)
    static let sideMargin = kFitWidth(12)
    static let minHeight = arrowHeight + topPadding + bottomPadding + kFitWidth(58)
}

private enum AICoachPreDaySweepAnimation {
    static let duration: CFTimeInterval = 2.82
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

    let selfHeight = kFitHeight(152)

    private var dayItems: [DayItem] = []
    private var reportAfterDays = 7
    private var itemViews: [AICoachPreDayItemView] = []
    private var selectedPopupIndex: Int?
    private var isFirstReport = true
    private var completeDays = 0

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

    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
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
//            make.top.equalTo(daysStackView.snp.bottom).offset(kFitWidth(-46))
            make.top.equalTo(kFitWidth(32))
            make.width.equalTo(AICoachPrePopupLayout.minWidth)
            make.height.equalTo(AICoachPrePopupLayout.minHeight)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapAction))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    /// reportAfterDays ：距离生成报告还有多少天，isFirstReport：是否为首报，has7CompleteDays：是否达成首报的条件
    func configure(items: [DayItem],
                   reportAfterDays: Int,
                   isFirstReport:Bool,
                   completeDays:Int) {
        self.dayItems = items
        self.reportAfterDays = reportAfterDays
        self.isFirstReport = isFirstReport
        self.completeDays = completeDays
        reloadDaysUI()
        updateMessage()
        hidePopup()
        updateSweepAnimationIfNeeded()
    }

    func dismissPopup() {
        hidePopup()
    }

    func isTouchInsideDayItem(_ touchedView: UIView?) -> Bool {
        guard let touchedView else { return false }
        for itemView in itemViews where touchedView.isDescendant(of: itemView) {
            return true
        }
        return false
    }
}

private extension AICoachPreDaysVM {
    func applyDefaultContent() {
        configure(items: [
            DayItem(title: "", state: .completed, completeStatus: 0),
            DayItem(title: "", state: .completed, completeStatus: 0),
            DayItem(title: "", state: .current, completeStatus: 0),
            DayItem(title: "", state: .pending, completeStatus: 0),
            DayItem(title: "", state: .pending, completeStatus: 0),
            DayItem(title: "", state: .pending, completeStatus: 0),
            DayItem(title: "", state: .pending, completeStatus: 0)
        ], reportAfterDays: 7, isFirstReport: isFirstReport, completeDays: completeDays)
    }

    func reloadDaysUI() {
        itemViews.removeAll()
        daysStackView.arrangedSubviews.forEach { subView in
            daysStackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        for (index, item) in dayItems.enumerated() {
            let itemView = AICoachPreDayItemView()
            itemView.update(item: item,isFirstReport:self.isFirstReport,completeDays:self.completeDays,index: index)
            itemView.tapBlock = { [weak self, weak itemView] in
                guard let self, let itemView else { return }
                self.dayItemTapAction(index: index, sourceView: itemView)
            }
            daysStackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
    }

    func updateSweepAnimationIfNeeded() {
        let shouldAnimate = reportAfterDays == 0
        layoutIfNeeded()

        for itemView in itemViews {
            if shouldAnimate {
                itemView.startIconSweepAnimation()
            } else {
                itemView.stopIconSweepAnimation()
            }
        }
    }

    func updateMessage() {
        //
        /*
         首报之前的文案：
         为了让反馈更精准，我还需要更多时间来了解你。请继续保持记录饮食和体重，我预计会在x 天后为你生成第一份反馈报告！
         
         首次出报告：你的首份教练报告已经准备好了，快去查看！

         后续出报告：你最新的教练报告已经准备好了，快去查看！
         */
        var fullText = "为了让反馈更精准，我还需要更多时间来了解你。请继续保持记录饮食和体重，我预计会在\(reportAfterDays) 天后为你生成第一份反馈报告！"
        
        if reportAfterDays == 0 {// 报告已能生成
            if isFirstReport{
                fullText = "你的首份教练报告已经准备好了，快去查看！"
            }else{
                fullText = "你最新的教练报告已经准备好了，快去查看！"
            }
        }
        
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
        let popupSize = popupView.preferredSize(maxWidth: bounds.width - AICoachPrePopupLayout.sideMargin * 2)
        let popupLeft = min(max(itemFrame.midX - popupSize.width * 0.5, AICoachPrePopupLayout.sideMargin),
                            bounds.width - popupSize.width - AICoachPrePopupLayout.sideMargin)

        popupView.snp.remakeConstraints { make in
            make.left.equalTo(popupLeft)
//            make.top.equalTo(itemFrame.maxY + kFitWidth(6))
            make.top.equalTo(kFitWidth(32))
            make.width.equalTo(popupSize.width)
            make.height.equalTo(popupSize.height)
        }

        popupView.updateArrowPosition(centerX: itemFrame.midX - popupLeft)
        bringSubviewToFront(popupView)
        popupView.isHidden = false
        popupView.alpha = 0
        UIView.animate(withDuration: 0.35) {
            self.popupView.alpha = 1
        }
    }

    @objc
    func backgroundTapAction() {
        hidePopup()
    }

    func hidePopup() {
        selectedPopupIndex = nil
        UIView.animate(withDuration: 0.35) {
            self.popupView.alpha = 0
        } completion: { _ in
            self.popupView.isHidden = true
        }

//        popupView.isHidden = true
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
    private let iconSweepLayer = CAGradientLayer()
    private var isIconSweepAnimating = false

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
        setupIconSweepLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(item: AICoachPreDaysVM.DayItem,isFirstReport:Bool=false,completeDays:Int,index:Int) {
        if isFirstReport{
            titleLabel.text = ""
            if completeDays >= 7{
                iconContainerView.backgroundColor = .THEME
                checkImageView.isHidden = false
            }else{
                checkImageView.isHidden = item.completeStatus == 0
                iconContainerView.backgroundColor = ((item.completeStatus > 0) ? UIColor.THEME : UIColor.COLOR_TEXT_TITLE_0f1214_05)
//                checkImageView.isHidden = completeDays < index
//                iconContainerView.backgroundColor = completeDays >= index ? .THEME : UIColor.COLOR_TEXT_TITLE_0f1214_05
            }
            return
        }
        titleLabel.text = item.title

        switch item.completeStatus {
        case 2:
            iconContainerView.backgroundColor = .THEME
            checkImageView.isHidden = false
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        case 1:
            iconContainerView.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_05
            checkImageView.isHidden = false
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        default:
            iconContainerView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
            checkImageView.isHidden = true
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_25
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateIconSweepLayerFrame()
    }

    func startIconSweepAnimation() {
        guard isIconSweepAnimating == false else { return }
        isIconSweepAnimating = true
        layoutIfNeeded()
        updateIconSweepLayerFrame()

        if iconSweepLayer.superlayer == nil {
            iconContainerView.layer.addSublayer(iconSweepLayer)
        }

        let translation = iconContainerView.bounds.width * 2.1
        iconSweepLayer.transform = CATransform3DMakeTranslation(-translation, 0, 0)

        let moveAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        moveAnimation.fromValue = -translation
        moveAnimation.toValue = translation
        moveAnimation.duration = AICoachPreDaySweepAnimation.duration
        moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        moveAnimation.repeatCount = .infinity
        moveAnimation.isRemovedOnCompletion = false
        iconSweepLayer.add(moveAnimation, forKey: "ai.pre.days.iconSweep")
    }

    func stopIconSweepAnimation() {
        isIconSweepAnimating = false
        iconSweepLayer.removeAnimation(forKey: "ai.pre.days.iconSweep")
        iconSweepLayer.transform = CATransform3DIdentity
        iconSweepLayer.removeFromSuperlayer()
    }
}

private extension AICoachPreDayItemView {
    func setupIconSweepLayer() {
        iconSweepLayer.startPoint = CGPoint(x: 0, y: 0.35)
        iconSweepLayer.endPoint = CGPoint(x: 1, y: 0.65)
        iconSweepLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.18).cgColor,
            UIColor.white.withAlphaComponent(0.52).cgColor,
            UIColor.white.withAlphaComponent(0.18).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        iconSweepLayer.locations = [0, 0.38, 0.5, 0.62, 1]
    }

    func updateIconSweepLayerFrame() {
        let bounds = iconContainerView.bounds
        guard bounds.isEmpty == false else { return }
        iconSweepLayer.frame = bounds.insetBy(dx: -bounds.width, dy: 0)
    }

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
            make.width.equalTo(kFitWidth(14))
            make.height.equalTo(kFitWidth(9))
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

    private let statusTitles = ["已记录饮食+体重", "已记录饮食"]
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        bubbleBackgroundView.refreshColors()
    }

    private lazy var bubbleBackgroundView: AICoachPreDayStatusBubbleView = {
        let view = AICoachPreDayStatusBubbleView()
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
        topStatusView.update(isSelected:true)
        bottomStatusView.update(isSelected: completeStatus == 1 || completeStatus == 2)
    }

    func updateArrowPosition(centerX: CGFloat) {
        bubbleBackgroundView.updateArrowPosition(centerX: centerX)
    }

    func preferredSize(maxWidth: CGFloat) -> CGSize {
        let safeMaxWidth = max(maxWidth, AICoachPrePopupLayout.minWidth)
        let textFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let requiredTextWidth = statusTitles.reduce(CGFloat.zero) { partialResult, text in
            let textWidth = ceil((text as NSString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: textFont],
                context: nil
            ).width)
            return max(partialResult, textWidth)
        }
        let preferredWidth = AICoachPrePopupLayout.horizontalPadding * 2 +
        AICoachPrePopupLayout.rowIconSize +
        AICoachPrePopupLayout.rowLabelSpacing +
        requiredTextWidth
        let finalWidth = min(max(AICoachPrePopupLayout.minWidth, preferredWidth), safeMaxWidth)
        let targetSize = CGSize(width: finalWidth, height: UIView.layoutFittingCompressedSize.height)
        let fittedHeight = systemLayoutSizeFitting(targetSize,
                                                   withHorizontalFittingPriority: .required,
                                                   verticalFittingPriority: .fittingSizeLevel).height
        return CGSize(width: finalWidth, height: max(AICoachPrePopupLayout.minHeight, ceil(fittedHeight)))
    }
}

private extension AICoachPreDayStatusPopupView {

    func setupUI() {
        backgroundColor = .clear

        addSubview(bubbleBackgroundView)
        bubbleBackgroundView.addSubview(topStatusView)
        bubbleBackgroundView.addSubview(bottomStatusView)

        bubbleBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        topStatusView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(14))
            make.top.equalToSuperview().offset(AICoachPrePopupLayout.arrowHeight + AICoachPrePopupLayout.topPadding)
        }

        bottomStatusView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(14))
            make.top.equalTo(topStatusView.snp.bottom).offset(AICoachPrePopupLayout.rowSpacing)
            make.bottom.equalToSuperview().offset(-AICoachPrePopupLayout.bottomPadding)
        }
    }
}

private final class AICoachPreDayStatusBubbleView: UIView {

    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let tintView = UIView()
    private let borderLayer = CAShapeLayer()
    private let cornerRadius = kFitWidth(14)
    private var arrowCenterX = AICoachPrePopupLayout.minWidth * 0.5
    private let blurMaskLayer = CAShapeLayer()
    private let tintMaskLayer = CAShapeLayer()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        refreshColors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(blurEffectView)
        addSubview(tintView)
        layer.addSublayer(borderLayer)
        blurEffectView.layer.mask = blurMaskLayer
        tintView.layer.mask = tintMaskLayer
        blurEffectView.isUserInteractionEnabled = false
        tintView.isUserInteractionEnabled = false
        refreshColors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateArrowPosition(centerX: CGFloat) {
        arrowCenterX = centerX
        setNeedsLayout()
    }

    func refreshColors() {
        tintView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.94)
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.98).cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineJoin = .round
        borderLayer.lineCap = .round
        borderLayer.zPosition = 10
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 16
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = bubblePath(in: bounds)
        blurEffectView.frame = bounds
        tintView.frame = bounds
        blurMaskLayer.frame = bounds
        blurMaskLayer.path = path.cgPath
        tintMaskLayer.frame = bounds
        tintMaskLayer.path = path.cgPath
        borderLayer.frame = bounds
        borderLayer.path = path.cgPath
        layer.shadowPath = path.cgPath
    }

    private func bubblePath(in rect: CGRect) -> UIBezierPath {
        let lineWidth = borderLayer.lineWidth
        let insetRect = rect.insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
        let topY = insetRect.minY + AICoachPrePopupLayout.arrowHeight
        let leftX = insetRect.minX
        let rightX = insetRect.maxX
        let bottomY = insetRect.maxY
        let radius = min(cornerRadius, (bottomY - topY) * 0.5)

        let arrowHalfWidth = AICoachPrePopupLayout.arrowWidth * 0.5
        let tipX = min(max(arrowCenterX, leftX + radius + arrowHalfWidth), rightX - radius - arrowHalfWidth)
        let leftShoulderX = tipX - arrowHalfWidth
        let rightShoulderX = tipX + arrowHalfWidth
        let tipY = insetRect.minY + 1

        let path = UIBezierPath()
        path.move(to: CGPoint(x: leftX + radius, y: topY))
        path.addLine(to: CGPoint(x: leftShoulderX, y: topY))
        path.addCurve(
            to: CGPoint(x: tipX, y: tipY),
            controlPoint1: CGPoint(x: tipX - arrowHalfWidth * 0.62, y: topY),
            controlPoint2: CGPoint(x: tipX - arrowHalfWidth * 0.28, y: tipY)
        )
        path.addCurve(
            to: CGPoint(x: rightShoulderX, y: topY),
            controlPoint1: CGPoint(x: tipX + arrowHalfWidth * 0.28, y: tipY),
            controlPoint2: CGPoint(x: tipX + arrowHalfWidth * 0.62, y: topY)
        )
        path.addLine(to: CGPoint(x: rightX - radius, y: topY))
        path.addArc(withCenter: CGPoint(x: rightX - radius, y: topY + radius), radius: radius, startAngle: -.pi * 0.5, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rightX, y: bottomY - radius))
        path.addArc(withCenter: CGPoint(x: rightX - radius, y: bottomY - radius), radius: radius, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
        path.addLine(to: CGPoint(x: leftX + radius, y: bottomY))
        path.addArc(withCenter: CGPoint(x: leftX + radius, y: bottomY - radius), radius: radius, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
        path.addLine(to: CGPoint(x: leftX, y: topY + radius))
        path.addArc(withCenter: CGPoint(x: leftX + radius, y: topY + radius), radius: radius, startAngle: .pi, endAngle: -.pi * 0.5, clockwise: true)
        path.close()
        return path
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
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
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
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(3))
            make.width.height.equalTo(AICoachPrePopupLayout.rowIconSize)
            make.bottom.lessThanOrEqualToSuperview().offset(-kFitWidth(3))
        }

        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(10))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconContainerView.snp.right).offset(AICoachPrePopupLayout.rowLabelSpacing)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }

        update(isSelected: false)
    }
}
