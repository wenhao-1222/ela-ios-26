//
//  GuidanceSexTipsAlertVM.swift
//  lns
//
//  Created by Codex on 2026/4/8.
//

import Foundation
import UIKit
import SnapKit

class GuidanceSexTipsAlertVM: UIView {

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
        lab.text = "荷尔蒙：无法被忽略的变量"
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

    private lazy var introLabel: UILabel = {
        let label = makeBodyLabel("在营养与运动生理学中，生理性别并非形式项，而是初始估算的重要变量。")
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.2)
        return label
    }()

    private lazy var maleTitleLabel: UILabel = {
        makeSectionLabel("· 男性的代谢模型相对线性")
    }()

    private lazy var maleContentLabel: UILabel = {
        let label = makeBodyLabel("更高的骨骼肌比例和雄性激素水平，赋予了男性更高的基础代谢率，这也决定了其在增肌或减脂期，对碳水化合物与蛋白质具备更大的消耗与利用空间。[1]")
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.2)
        return label
    }()

    private lazy var femaleTitleLabel: UILabel = {
        makeSectionLabel("· 女性绝不仅仅是“缩小版的男性”")
    }()

    private lazy var femaleContentLabel: UILabel = {
        let label = makeBodyLabel("在整个生理周期中，雌激素与孕激素的交替波动，会直接影响身体的储水状态与食欲倾向。研究显示，在中等强度有氧运动中，女性平均比男性更依赖脂肪氧化；而黄体期也常伴随短期的代谢与体重波动，平均约0.5kg的体重起伏主要与细胞外液滞留有关。[2][3][4]")
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.2)
        return label
    }()

    private lazy var endingLabel: UILabel = {
        let label = makeBodyLabel("了解你的生理性别，是为了帮助 Elavatine 摒弃粗暴的“一刀切”公式，为你构建真正符合你生理规律的初始基准线。")
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.2)
        return label
    }()

    private lazy var referenceLabel: UILabel = {
        let label = makeBodyLabel("[1] Hunter et al. (2023), Med Sci Sports Exer\n[2] Cano et al. (2022), Eur J Appl Physiol\n[3] Kanellakis et al. (2023), Am J Hum Biol\n[4] Benton et al. (2020), PLOS On")
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

extension GuidanceSexTipsAlertVM {
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

extension GuidanceSexTipsAlertVM {
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        whiteView.addSubview(lineView)
        whiteView.addSubview(confirmBtn)

        contentStackView.addArrangedSubview(introLabel)
        contentStackView.addArrangedSubview(maleTitleLabel)
        contentStackView.addArrangedSubview(maleContentLabel)
        contentStackView.addArrangedSubview(femaleTitleLabel)
        contentStackView.addArrangedSubview(femaleContentLabel)
        contentStackView.addArrangedSubview(endingLabel)
        contentStackView.addArrangedSubview(referenceLabel)

        contentStackView.setCustomSpacing(kFitWidth(20), after: introLabel)
        contentStackView.setCustomSpacing(kFitWidth(8), after: maleTitleLabel)
        contentStackView.setCustomSpacing(kFitWidth(20), after: maleContentLabel)
        contentStackView.setCustomSpacing(kFitWidth(8), after: femaleTitleLabel)
        contentStackView.setCustomSpacing(kFitWidth(20), after: femaleContentLabel)
        contentStackView.setCustomSpacing(kFitWidth(20), after: endingLabel)

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
            make.top.equalTo(kFitWidth(67))
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

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.preferredMaxLayoutWidth = bodyContentWidth
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
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
