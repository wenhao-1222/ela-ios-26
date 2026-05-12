//
//  AICoachPreDaysVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/25.
//

import UIKit
import SnapKit

enum AICoachPrePopupLayout {
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

enum AICoachPreDaySweepAnimation {
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
    private var shouldAnimateMessageLabel = false
    private var shouldAnimateSweep = true
    private var temporaryMessage: String?

    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true

        initUI()
//        applyDefaultContent()
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
        label.alpha = 0
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
                   completeDays:Int,
                   shouldAnimateSweep: Bool = true,
                   temporaryMessage: String? = nil,
                   animateMessageChange: Bool = false) {
        self.dayItems = items
        self.reportAfterDays = reportAfterDays
        self.isFirstReport = isFirstReport
        self.completeDays = completeDays
        self.shouldAnimateSweep = shouldAnimateSweep
        self.temporaryMessage = temporaryMessage
        reloadDaysUI()
        updateMessage(animated: animateMessageChange)
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

    func prepareEntranceAnimation() {
        let initialTransform = CGAffineTransform(translationX: 0, y: -kFitWidth(12))
        alpha = 1
        transform = initialTransform
        daysStackView.alpha = 0
        daysStackView.transform = initialTransform
        messageLabel.alpha = 0
        messageLabel.transform = initialTransform
        shouldAnimateMessageLabel = false
    }

    func playEntranceAnimation(alongsideDaysAnimation: (() -> Void)? = nil,
                               completion: (() -> Void)? = nil) {
        shouldAnimateMessageLabel = true

        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.daysStackView.transform = .identity
            self.daysStackView.alpha = 1
            alongsideDaysAnimation?()
        } completion: { _ in
            UIView.animate(withDuration: 0.35,
                           delay: 0.18,
                           options: .curveLinear) {
                self.messageLabel.transform = .identity
                self.messageLabel.alpha = self.messageLabel.isHidden ? 0 : 1
            } completion: { _ in
                completion?()
            }
        }
    }

    func applyFinalPresentationState() {
        alpha = 1
        transform = .identity
        daysStackView.alpha = 1
        daysStackView.transform = .identity
        messageLabel.alpha = messageLabel.isHidden ? 0 : 1
        messageLabel.transform = .identity
    }

    func setShouldAnimateSweep(_ shouldAnimateSweep: Bool) {
        self.shouldAnimateSweep = shouldAnimateSweep
        updateSweepAnimationIfNeeded()
    }

    func showTemporaryMessage(_ text: String, animated: Bool) {
        temporaryMessage = text
        messageLabel.isHidden = false
        updateMessage(animated: animated)
        showMessageLabelIfNeeded(animated: animated)
    }

    func showConfiguredMessage(animated: Bool) {
        temporaryMessage = nil
        messageLabel.isHidden = false
        updateMessage(animated: animated)
        showMessageLabelIfNeeded(animated: animated)
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
        let shouldAnimate = shouldAnimateSweep && (reportAfterDays == 0 || temporaryMessage != nil)
        layoutIfNeeded()

        for itemView in itemViews {
            if shouldAnimate {
                itemView.startIconSweepAnimation()
            } else {
                itemView.stopIconSweepAnimation()
            }
        }
    }

    func updateMessage(animated: Bool = false) {
        //
        /*
         首报之前的文案：
         为了让反馈更精准，我还需要更多时间来了解你。请继续保持记录饮食和体重，我预计会在x 天后为你生成第一份反馈报告！
         
         首次出报告：你的首份教练报告已经准备好了，快去查看！

         首报之后的文案：
         请继续保持记录饮食和体重，我预计会在x天后给你发送下一份反馈报告。
         
         后续出报告：你最新的教练报告已经准备好了，快去查看！
         */
        if let temporaryMessage {
            applyMessageText(temporaryMessage, highlightText: nil, animated: animated)
            return
        }

        var fullText = "为了让反馈更精准，我还需要更多时间来了解你。请继续保持记录饮食和体重，我预计会在\(reportAfterDays) 天后为你生成第一份反馈报告！"
        
        if !isFirstReport{
            fullText = "请继续保持记录饮食和体重，我预计会在\(reportAfterDays)天后给你发送下一份反馈报告。"
        }
        
        if reportAfterDays == 0 {// 报告已能生成
            if isFirstReport{
                fullText = "你的首份教练报告已经准备好了，快去查看！"
            }else{
                fullText = "你最新的教练报告已经准备好了，快去查看！"
            }
        }
        
        applyMessageText(fullText, highlightText: "\(reportAfterDays)", animated: animated)
    }

    func makeMessageAttributedText(_ fullText: String, highlightText: String?) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50
            ]
        )

        if let highlightText, highlightText.isEmpty == false {
            let highlightRange = (fullText as NSString).range(of: highlightText)
            if highlightRange.location != NSNotFound {
                attributedText.addAttributes([
                    .foregroundColor: UIColor.THEME,
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium)
                ], range: highlightRange)
            }
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = kFitWidth(4)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))

        return attributedText
    }

    func applyMessageText(_ fullText: String, highlightText: String?, animated: Bool) {
        let attributedText = makeMessageAttributedText(fullText, highlightText: highlightText)

        guard animated, messageLabel.alpha > 0, messageLabel.isHidden == false else {
            messageLabel.attributedText = attributedText
            return
        }

        UIView.transition(with: messageLabel,
                          duration: 0.35,
                          options: [.transitionCrossDissolve, .allowUserInteraction]) {
            self.messageLabel.attributedText = attributedText
        }
    }

    func showMessageLabelIfNeeded(animated: Bool) {
        guard messageLabel.alpha < 1 else { return }
        messageLabel.transform = .identity
        guard animated else {
            messageLabel.alpha = 1
            return
        }
        UIView.animate(withDuration: 0.35) {
            self.messageLabel.alpha = 1
        }
    }

    func dayItemTapAction(index: Int, sourceView: UIView) {
        if selectedPopupIndex == index, popupView.isHidden == false {
            hidePopup()
            return
        }
        if isFirstReport && dayItems[index].completeStatus < 1{
            return
        }

        selectedPopupIndex = index
        popupView.update(completeStatus: dayItems[index].completeStatus)

        let itemFrame = sourceView.convert(sourceView.bounds, to: self)
        let popupSize = popupView.preferredSize(maxWidth: bounds.width - AICoachPrePopupLayout.sideMargin * 2)
        let popupLeft = min(max(itemFrame.midX - popupSize.width * 0.5, AICoachPrePopupLayout.sideMargin),
                            bounds.width - popupSize.width - AICoachPrePopupLayout.sideMargin)

        if self.isFirstReport{
            popupView.bottomStatusView.isHidden = true
            popupView.snp.remakeConstraints { make in
                make.left.equalTo(popupLeft)
    //            make.top.equalTo(itemFrame.maxY + kFitWidth(6))
                make.top.equalTo(kFitWidth(32))
                make.width.equalTo(popupSize.width)
                make.height.equalTo(popupSize.height*0.6)
            }
            popupView.topStatusView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(kFitWidth(14))
                make.top.equalToSuperview().offset(AICoachPrePopupLayout.arrowHeight + AICoachPrePopupLayout.topPadding)
                make.bottom.equalToSuperview().offset(kFitWidth(-10))
            }
        }else{
            popupView.snp.remakeConstraints { make in
                make.left.equalTo(popupLeft)
    //            make.top.equalTo(itemFrame.maxY + kFitWidth(6))
                make.top.equalTo(kFitWidth(32))
                make.width.equalTo(popupSize.width)
                make.height.equalTo(popupSize.height)
            }
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
