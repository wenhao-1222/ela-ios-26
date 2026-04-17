//
//  AICoachPreDayStatusPopupView.swift
//  lns
//
//  Created by LNS2 on 2026/4/17.
//

class AICoachPreDayStatusPopupView: UIView {

    private let statusTitles = ["已记录饮食+体重", "已记录饮食"]
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        bubbleBackgroundView.refreshColors()
    }

    private lazy var bubbleBackgroundView: AICoachPreDayStatusBubbleView = {
        let view = AICoachPreDayStatusBubbleView()
        return view
    }()

    lazy var topStatusView = AICoachPreDayStatusRowView(
        title: "已记录饮食+体重",
        selectedColor: .THEME
    )

    lazy var bottomStatusView = AICoachPreDayStatusRowView(
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
