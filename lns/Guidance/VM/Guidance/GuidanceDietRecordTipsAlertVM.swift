//
//  GuidanceDietRecordTipsAlertVM.swift
//  lns
//
//  Created by Codex on 2026/4/8.
//

import Foundation
import UIKit
import SnapKit

class GuidanceDietRecordTipsAlertVM: UIView {

    private var availableCardHeight: CGFloat {
        let topInset = WHUtils().getNavigationBarHeight() + kFitWidth(12)
        let bottomInset = max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(12))
        return SCREEN_HEIGHT - topInset - bottomInset
    }

    private var fixedLayoutHeight: CGFloat {
        kFitWidth(131)
    }

    private var bodyContentWidth: CGFloat {
        kFitWidth(320) - kFitWidth(40)
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
        isUserInteractionEnabled = true
        isHidden = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()

    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)

        return vi
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.text = "必须严苛记录才有效吗？"
        lab.textAlignment = .center
        lab.numberOfLines = 1
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.isDirectionalLockEnabled = true
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = kFitWidth(12)
        return stack
    }()

    private lazy var contentLabelOne: UILabel = {
        let label = makeBodyLabel("在体重管理研究里，饮食记录一直是最核心的行为之一。对需要减重或维持减重结果的人来说，记录食物摄入能改善结果。[1]")
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.2)
        return label
    }()

    private lazy var contentLabelTwo: UILabel = {
        let label = makeBodyLabel("但研究也发现，记录方式并不是越严苛越好，高强度和低强度的记录策略都可能有效，目前并没有一个适用于所有人的唯一最佳强度。[2]")
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.2)
        return label
    }()

    private lazy var referenceLabel: UILabel = {
        let label = makeBodyLabel("[1] USDA NESR, Diet Self-Monitoring\n[2] Raber et al., PHN 2021")
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.2)
        return label
    }()

    private lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()

    lazy var confirmBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("我知道了", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        return btn
    }()

    private var whiteViewHeightConstraint: Constraint?
}

extension GuidanceDietRecordTipsAlertVM {
    func showView() {
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

    @objc func nothingToDo() {
    }
}

extension GuidanceDietRecordTipsAlertVM {
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        whiteView.addSubview(lineView)
        whiteView.addSubview(confirmBtn)

        contentStackView.addArrangedSubview(contentLabelOne)
        contentStackView.addArrangedSubview(contentLabelTwo)
        contentStackView.addArrangedSubview(referenceLabel)

        contentStackView.setCustomSpacing(kFitWidth(16), after: contentLabelOne)
        contentStackView.setCustomSpacing(kFitWidth(20), after: contentLabelTwo)

        setConstrait()
        updateCardLayout()
    }

    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().priority(750)
            make.top.greaterThanOrEqualTo(WHUtils().getNavigationBarHeight() + kFitWidth(12))
            make.bottom.lessThanOrEqualTo(-max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(12)))
            make.width.equalTo(kFitWidth(320))
            whiteViewHeightConstraint = make.height.equalTo(availableCardHeight).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(27))
        }

        confirmBtn.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(48))
        }

        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top)
            make.height.equalTo(kFitWidth(1))
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(59))
            make.bottom.equalTo(lineView.snp.top).offset(kFitWidth(-20))
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: kFitWidth(20), bottom: 0, right: kFitWidth(20)))
        }
    }

    private func updateCardLayout() {
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

    private func measuredContentHeight() -> CGFloat {
        let targetSize = CGSize(width: bodyContentWidth, height: UIView.layoutFittingCompressedSize.height)
        let measuredSize = contentStackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return ceil(measuredSize.height) + kFitWidth(8)
    }

    private func makeBodyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.preferredMaxLayoutWidth = bodyContentWidth
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }
}
