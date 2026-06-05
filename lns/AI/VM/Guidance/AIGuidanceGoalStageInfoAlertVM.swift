//
//  AIGuidanceGoalStageInfoAlertVM.swift
//  lns
//
//  Created by LNS2 on 2026/6/5.
//

import SnapKit

class AIGuidanceGoalStageInfoAlertVM: UIView {

    private var availableCardHeight: CGFloat {
        let topInset = WHUtils().getNavigationBarHeight() + kFitWidth(12)
        let bottomInset = max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(12))
        return SCREEN_HEIGHT - topInset - bottomInset
    }

    private var fixedLayoutHeight: CGFloat {
        kFitWidth(149)
    }

    private var bodyContentWidth: CGFloat {
        kFitWidth(313) - kFitWidth(52)
    }

    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        } else {
            return 0.15
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
           !isHidden {
            UIView.animate(withDuration: 0.2) {
                self.bgView.alpha = self.targetDimAlpha
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isHidden = true
        isUserInteractionEnabled = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var bgView: UIView = {
        let view = UIView(frame: bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .COLOR_ALERT_BG_BLACK
        view.alpha = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        view.addGestureRecognizer(tap)
        return view
    }()

    lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(8)
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        view.addGestureRecognizer(tap)
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = kFitWidth(18)
        return stackView
    }()

    private lazy var messageLabel = makeBodyLabel(fontSize: 14, lineHeightMultiple: 1.2)

    private lazy var referenceLabel = makeBodyLabel(fontSize: 12, lineHeightMultiple: 1.2)

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_LINE_F0
        return view
    }()

    lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("我知道了", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        return btn
    }()

    private var whiteViewHeightConstraint: Constraint?
}

extension AIGuidanceGoalStageInfoAlertVM {
    func show(content: AIGuidanceGoalStageVM.StageInfoContent) {
        titleLabel.text = content.title
        setBodyText(content.message, label: messageLabel, lineHeightMultiple: 1.33)
        setBodyText(content.reference, label: referenceLabel, lineHeightMultiple: 1.28)
        updateCardLayout()

        isHidden = false
        bgView.isUserInteractionEnabled = false
        whiteView.alpha = 0
        alpha = 0
        bgView.alpha = 0
        scrollView.setContentOffset(.zero, animated: false)

        UIView.animate(withDuration: 0.14, delay: 0, options: .curveEaseOut) {
            self.bgView.alpha = self.targetDimAlpha
        }

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
            self.whiteView.alpha = 1
        }
        UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveLinear) {
            self.alpha = 1
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
    }

    @objc func hiddenView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
            self.alpha = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear) {
            self.whiteView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
}

private extension AIGuidanceGoalStageInfoAlertVM {
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        whiteView.addSubview(lineView)
        whiteView.addSubview(confirmBtn)

        contentStackView.addArrangedSubview(messageLabel)
        contentStackView.addArrangedSubview(referenceLabel)

        whiteView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().priority(750)
            make.top.greaterThanOrEqualTo(WHUtils().getNavigationBarHeight() + kFitWidth(12))
            make.bottom.lessThanOrEqualTo(-max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(12)))
            make.width.equalTo(kFitWidth(313))
            whiteViewHeightConstraint = make.height.equalTo(availableCardHeight).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(kFitWidth(-20))
            make.top.equalToSuperview().offset(kFitWidth(20))
            make.height.greaterThanOrEqualTo(kFitWidth(27))
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(24))
            make.bottom.equalTo(lineView.snp.top).offset(kFitWidth(-18))
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top)
            make.height.equalTo(kFitWidth(1))
        }

        confirmBtn.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(48))
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: kFitWidth(26), bottom: 0, right: kFitWidth(26)))
        }

        updateCardLayout()
    }

    func updateCardLayout() {
        layoutIfNeeded()
        let contentHeight = measuredContentHeight()
        let maxScrollHeight = max(0, availableCardHeight - fixedLayoutHeight)
        let scrollContentFits = contentHeight <= maxScrollHeight
        let targetHeight = min(availableCardHeight, fixedLayoutHeight + contentHeight)

        scrollView.isScrollEnabled = !scrollContentFits
        scrollView.bounces = !scrollContentFits
        scrollView.alwaysBounceVertical = !scrollContentFits
        whiteViewHeightConstraint?.update(offset: targetHeight)
        layoutIfNeeded()
    }

    func measuredContentHeight() -> CGFloat {
        let targetSize = CGSize(width: bodyContentWidth, height: UIView.layoutFittingCompressedSize.height)
        let measuredSize = contentStackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return ceil(measuredSize.height) + kFitWidth(8)
    }

    func makeBodyLabel(fontSize: CGFloat, lineHeightMultiple: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: fontSize, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.preferredMaxLayoutWidth = bodyContentWidth
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func setBodyText(_ text: String, label: UILabel, lineHeightMultiple: CGFloat) {
        label.text = text
        label.setLineHeightMultiple(textString: text, lineHeightMultiple: lineHeightMultiple)
    }

    @objc func nothingToDo() {
    }
}
