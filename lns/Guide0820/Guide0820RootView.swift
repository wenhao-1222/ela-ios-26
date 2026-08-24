//
//  Guide0820RootView.swift
//  lns
//
//  Created by Codex on 2026/8/21.
//

import UIKit
import SnapKit

enum Guide0820AgreementType {
    case userAgreement
    case privacyPolicy
}

final class Guide0820FlowState {
    private(set) var currentPageIndex = 0

    let privacyVM = Guide0820PrivacyVM()
    let professionalBasisVM = Guide0820ProfessionalBasisVM()
    let sourceVM = Guide0820SourceVM()

    func showNext() {
        currentPageIndex = min(currentPageIndex + 1, 2)
    }

    func showPrevious() {
        currentPageIndex = max(currentPageIndex - 1, 0)
    }
}

final class Guide0820PrivacyVM {
    struct AgreementItem {
        let id: Guide0820AgreementType
        let title: String
        let iconName: String
    }

    let title = "保护你的隐私"
    let subtitle = "我们永远不会出售你的健康数据，也绝不会在未经你同意\n的情况下与第三方共享。"
    let buttonTitle = "同意并继续"
    let agreements = [
        AgreementItem(id: .userAgreement, title: "用户协议", iconName: "guide0820_user_agreement_icon"),
        AgreementItem(id: .privacyPolicy, title: "隐私政策", iconName: "guide0820_privacy_policy_icon")
    ]
}

final class Guide0820ProfessionalBasisVM {
    let buttonTitle = "下一步"
}

final class Guide0820SourceVM {
    struct SourceItem: Equatable {
        let id: String
        let title: String
        let iconName: String
    }

    private(set) var selectedItemID: String?

    let title = "你是怎么知道我们的？"
    let items = [
        SourceItem(id: "friend", title: "朋友", iconName: "guide0820_source_friend_icon"),
        SourceItem(id: "coach", title: "教练", iconName: "guide0820_source_coach_icon"),
        SourceItem(id: "douyin", title: "抖音", iconName: "guide0820_source_douyin_icon"),
        SourceItem(id: "xiaohongshu", title: "小红书", iconName: "guide0820_source_xiaohongshu_icon"),
        SourceItem(id: "app_market", title: "应用市场", iconName: "guide0820_source_app_market_icon"),
        SourceItem(id: "other", title: "其他", iconName: "guide0820_source_other_icon")
    ]

    var buttonTitle: String {
        selectedItemID == nil ? "跳过" : "继续"
    }

    func select(_ item: SourceItem) {
        selectedItemID = selectedItemID == item.id ? nil : item.id
    }
}

final class Guide0820RootView: UIView {
    private let flowState: Guide0820FlowState
    private let onOpenAgreement: (Guide0820AgreementType) -> Void
    private let onFinish: () -> Void

    private var currentPageView: UIView?
    private var dragStartPageIndex = 0
    private var isAnimatingPage = false

    init(flowState: Guide0820FlowState,
         onOpenAgreement: @escaping (Guide0820AgreementType) -> Void,
         onFinish: @escaping () -> Void) {
        self.flowState = flowState
        self.onOpenAgreement = onOpenAgreement
        self.onFinish = onFinish
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showPreviousPage() {
        guard flowState.currentPageIndex > 0 else { return }
        flowState.showPrevious()
        showPage(at: flowState.currentPageIndex, direction: .backward, animated: true)
    }
}

private extension Guide0820RootView {
    enum PageDirection {
        case forward
        case backward

        var incomingOffsetSign: CGFloat {
            self == .forward ? 1 : -1
        }
    }

    func initUI() {
        backgroundColor = .COLOR_BG_F2
        clipsToBounds = true

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)

        showPage(at: flowState.currentPageIndex, direction: .forward, animated: false)
    }

    func makePage(at index: Int) -> UIView {
        switch index {
        case 0:
            return Guide0820PrivacyView(
                vm: flowState.privacyVM,
                onOpenAgreement: onOpenAgreement,
                onNext: { [weak self] in
                    self?.showNextPage()
                }
            )
        case 1:
            return Guide0820ProfessionalBasisView(
                vm: flowState.professionalBasisVM,
                onNext: { [weak self] in
                    self?.showNextPage()
                }
            )
        default:
            return Guide0820SourceView(
                vm: flowState.sourceVM,
                onFinish: onFinish
            )
        }
    }

    func showNextPage() {
        guard flowState.currentPageIndex < 2 else {
            onFinish()
            return
        }

        flowState.showNext()
        showPage(at: flowState.currentPageIndex, direction: .forward, animated: true)
    }

    func showPage(at index: Int, direction: PageDirection, animated: Bool) {
        guard isAnimatingPage == false else { return }

        let oldPage = currentPageView
        let newPage = makePage(at: index)
        currentPageView = newPage

        addSubview(newPage)
        newPage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        layoutIfNeeded()

        guard animated, let oldPage = oldPage else {
            oldPage?.removeFromSuperview()
            updatePageLifecycle(for: newPage)
            return
        }

        isAnimatingPage = true
        let offsetX = max(bounds.width, SCREEN_WIDHT) * direction.incomingOffsetSign
        newPage.transform = CGAffineTransform(translationX: offsetX, y: 0)
        newPage.alpha = 0

        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseInOut]) {
            oldPage.transform = CGAffineTransform(translationX: -offsetX * 0.35, y: 0)
            oldPage.alpha = 0
            newPage.transform = .identity
            newPage.alpha = 1
        } completion: { [weak self] _ in
            oldPage.removeFromSuperview()
            oldPage.transform = .identity
            oldPage.alpha = 1
            self?.isAnimatingPage = false
            self?.updatePageLifecycle(for: newPage)
        }
    }

    func updatePageLifecycle(for page: UIView) {
        subviews.forEach { view in
            if let professionalView = view as? Guide0820ProfessionalBasisView {
                professionalView.setActive(view === page)
            }
        }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            dragStartPageIndex = flowState.currentPageIndex
        case .ended, .cancelled:
            let translation = gesture.translation(in: self)
            guard dragStartPageIndex == flowState.currentPageIndex else { return }
            guard translation.x > kFitWidth(70),
                  abs(translation.y) < kFitWidth(70),
                  flowState.currentPageIndex > 0 else { return }
            showPreviousPage()
        default:
            break
        }
    }
}

extension Guide0820RootView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

private final class Guide0820PrivacyView: UIView {
    private let vm: Guide0820PrivacyVM
    private let onOpenAgreement: (Guide0820AgreementType) -> Void
    private let onNext: () -> Void

    private lazy var titleGroupView = makeTitleGroupView()
    private lazy var agreementCardView = makeAgreementCardView()
    private lazy var legalTextView = Guide0820AgreementLegalTextView(onOpenAgreement: onOpenAgreement)
    private lazy var primaryButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: onNext)

    init(vm: Guide0820PrivacyVM,
         onOpenAgreement: @escaping (Guide0820AgreementType) -> Void,
         onNext: @escaping () -> Void) {
        self.vm = vm
        self.onOpenAgreement = onOpenAgreement
        self.onNext = onNext
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820PrivacyView {
    func initUI() {
        backgroundColor = .COLOR_BG_F2

        addSubview(titleGroupView)
        addSubview(agreementCardView)
        addSubview(legalTextView)
        addSubview(primaryButton)

        titleGroupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(kFitWidth(143.75) - SCREEN_HEIGHT / 2)
            make.width.equalTo(kFitWidth(333))
        }

        agreementCardView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(kFitWidth(284) - SCREEN_HEIGHT / 2)
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(120))
        }

        primaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        legalTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(primaryButton.snp.centerY).offset(-kFitWidth(31.75))
            make.width.equalTo(kFitWidth(291))
            make.height.equalTo(kFitWidth(18))
        }
    }

    func makeTitleGroupView() -> UIView {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = vm.title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(24), weight: .medium)

        let subtitleLabel = UILabel()
        subtitleLabel.text = vm.subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        subtitleLabel.font = .systemFont(ofSize: kFitWidth(13), weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.setLineSpacing(kFitWidth(4.1))

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(36))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(7))
            make.height.equalTo(kFitWidth(44.2))
            make.bottom.equalToSuperview()
        }

        return container
    }

    func makeAgreementCardView() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .COLOR_BG_WHITE
        cardView.layer.cornerRadius = kFitWidth(12)
        cardView.clipsToBounds = true

        var previousRow: UIView?
        for (index, item) in vm.agreements.enumerated() {
            let row = Guide0820AgreementRow(item: item) { [weak self] in
                self?.onOpenAgreement(item.id)
            }
            cardView.addSubview(row)
            row.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(kFitWidth(60))
                if let previousRow = previousRow {
                    make.top.equalTo(previousRow.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                if index == vm.agreements.count - 1 {
                    make.bottom.equalToSuperview()
                }
            }

            if index != vm.agreements.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
                cardView.addSubview(separator)
                separator.snp.makeConstraints { make in
                    make.left.equalTo(kFitWidth(42.5))
                    make.right.equalTo(kFitWidth(-16))
                    make.top.equalTo(row.snp.bottom)
                    make.height.equalTo(0.5)
                }
            }

            previousRow = row
        }

        return cardView
    }
}

private final class Guide0820AgreementRow: UIControl {
    private let action: () -> Void

    init(item: Guide0820PrivacyVM.AgreementItem, action: @escaping () -> Void) {
        self.action = action
        super.init(frame: .zero)
        initUI(item: item)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820AgreementRow {
    func initUI(item: Guide0820PrivacyVM.AgreementItem) {
        backgroundColor = .clear
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)

        let iconView = UIImageView()
        iconView.setImgLocal(imgName: item.iconName)
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: .regular)

        let arrowView = UIImageView()
        arrowView.setImgLocal(imgName: "plan_arrow_gray")
        arrowView.contentMode = .scaleAspectFit

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(arrowView)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12.5))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(16))
            make.centerY.equalToSuperview()
        }

        arrowView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }

    @objc func tapAction() {
        action()
    }
}

private final class Guide0820AgreementLegalTextView: UIView {
    private let onOpenAgreement: (Guide0820AgreementType) -> Void

    init(onOpenAgreement: @escaping (Guide0820AgreementType) -> Void) {
        self.onOpenAgreement = onOpenAgreement
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820AgreementLegalTextView {
    func initUI() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.distribution = .fill

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }

        stackView.addArrangedSubview(makeLabel("继续即表示你同意我们的《", color: .COLOR_TEXT_TITLE_0f1214_50))
        stackView.addArrangedSubview(makeButton("服务条款", action: #selector(userAgreementAction)))
        stackView.addArrangedSubview(makeLabel("》和《", color: .COLOR_TEXT_TITLE_0f1214_50))
        stackView.addArrangedSubview(makeButton("隐私政策", action: #selector(privacyPolicyAction)))
        stackView.addArrangedSubview(makeLabel("》。", color: .COLOR_TEXT_TITLE_0f1214_50))
    }

    func makeLabel(_ text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = .systemFont(ofSize: kFitWidth(11), weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        return label
    }

    func makeButton(_ title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.THEME, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: kFitWidth(11), weight: .regular)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.82
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc func userAgreementAction() {
        onOpenAgreement(.userAgreement)
    }

    @objc func privacyPolicyAction() {
        onOpenAgreement(.privacyPolicy)
    }
}

private final class Guide0820ProfessionalBasisView: UIView {
    private let vm: Guide0820ProfessionalBasisVM
    private let onNext: () -> Void

    private lazy var contentView = Guide0820ProfessionalBasisUIKitVM(frame: .zero)
    private lazy var primaryButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: onNext)

    init(vm: Guide0820ProfessionalBasisVM,
         onNext: @escaping () -> Void) {
        self.vm = vm
        self.onNext = onNext
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        contentView.stopScrollers()
    }

    func setActive(_ isActive: Bool) {
        if isActive {
            contentView.startScrollersIfNeeded()
        } else {
            contentView.stopScrollers()
        }
    }
}

private extension Guide0820ProfessionalBasisView {
    func initUI() {
        backgroundColor = .COLOR_BG_WHITE

        addSubview(contentView)
        addSubview(primaryButton)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        primaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(32))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview().offset(-max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(26)))
        }
    }
}

private final class Guide0820SourceView: UIView {
    private let vm: Guide0820SourceVM
    private let onFinish: () -> Void

    private var rows: [Guide0820SourceRow] = []

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = vm.title
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: kFitWidth(24), weight: .medium)
        return label
    }()
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = kFitWidth(12)
        return stackView
    }()
    private lazy var bottomGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var topGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    private lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    private lazy var bottomFadeView = Guide0820SourceBottomFadeView()
    private lazy var primaryButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: onFinish)

    init(vm: Guide0820SourceVM,
         onFinish: @escaping () -> Void) {
        self.vm = vm
        self.onFinish = onFinish
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
}

private extension Guide0820SourceView {
    func initUI() {
        backgroundColor = .COLOR_BG_F2

        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(bottomFadeView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        addSubview(primaryButton)
        scrollView.addSubview(stackView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        vm.items.forEach { item in
            let row = Guide0820SourceRow(item: item, isSelected: vm.selectedItemID == item.id) { [weak self] selectedItem in
                self?.selectItem(selectedItem)
            }
            rows.append(row)
            stackView.addArrangedSubview(row)
            row.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(80))
            }
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(21))
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(kFitWidth(87))
        }

        bottomFadeView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(158))
        }

        primaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview().offset(-max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(26)))
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalTo(primaryButton.snp.top)
        }

        topGradientView.snp.makeConstraints { make in
            make.left.right.top.equalTo(scrollView)
            make.height.equalTo(kFitWidth(36))
        }

        bottomGradientView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(scrollView)
            make.height.equalTo(kFitWidth(56))
        }

        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(scrollView.frameLayoutGuide).inset(kFitWidth(21))
            make.top.equalTo(scrollView.contentLayoutGuide).offset(kFitWidth(36))
            make.bottom.equalTo(scrollView.contentLayoutGuide)
        }
    }

    func selectItem(_ item: Guide0820SourceVM.SourceItem) {
        vm.select(item)
        primaryButton.setTitle(vm.buttonTitle, for: .normal)

        rows.forEach { row in
            row.setSelected(row.item.id == vm.selectedItemID, animated: true)
        }
    }
}

private final class Guide0820SourceRow: UIControl {
    let item: Guide0820SourceVM.SourceItem

    private let action: (Guide0820SourceVM.SourceItem) -> Void
    private let checkImageView = UIImageView()

    init(item: Guide0820SourceVM.SourceItem,
         isSelected: Bool,
         action: @escaping (Guide0820SourceVM.SourceItem) -> Void) {
        self.item = item
        self.action = action
        super.init(frame: .zero)
        initUI(isSelected: isSelected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ isSelected: Bool, animated: Bool) {
        checkImageView.setCheckState(isSelected,
                                     checkedImageName: "select_icon_selected_circle",
                                     uncheckedImageName: "select_icon_normal_circle",
                                     animated: animated)
    }
}

private extension Guide0820SourceRow {
    func initUI(isSelected: Bool) {
        backgroundColor = .COLOR_BG_WHITE
        layer.cornerRadius = kFitWidth(12)
        clipsToBounds = true
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)

        let iconView = UIImageView()
        iconView.setImgLocal(imgName: item.iconName)
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
//        titleLabel.textColor = item.id == "other" ? .COLOR_TEXT_TITLE_0f1214_50 : .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(16), weight: .medium)

        checkImageView.contentMode = .scaleAspectFit
        setSelected(isSelected, animated: false)

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(checkImageView)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(25))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(17))
            make.centerY.equalToSuperview()
        }

        checkImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
    }

    @objc func tapAction() {
        action(item)
    }
}

private final class Guide0820SourceBottomFadeView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(gradientLayer)
        gradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

private final class Guide0820PrimaryButton: UIButton {
    private let tapActionBlock: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.tapActionBlock = action
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820PrimaryButton {
    func initUI() {
        backgroundColor = .THEME
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: kFitWidth(17), weight: .medium)
        layer.cornerRadius = kFitWidth(12)
        clipsToBounds = true
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }

    @objc func tapAction() {
        tapActionBlock()
    }
}

private final class Guide0820BadgeVM: UIView {
    private let title: String

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textAlignment = .center
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: kFitWidth(17), weight: .semibold)
        return label
    }()

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setStrokeColor(UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor)
        context.setLineWidth(kFitWidth(2))
        context.setLineCap(.round)

        let midY = rect.midY
        let leftCenter = CGPoint(x: rect.midX - kFitWidth(42), y: midY)
        let rightCenter = CGPoint(x: rect.midX + kFitWidth(42), y: midY)
        context.addArc(center: leftCenter,
                       radius: kFitWidth(28),
                       startAngle: -.pi * 0.72,
                       endAngle: .pi * 0.72,
                       clockwise: true)
        context.addArc(center: rightCenter,
                       radius: kFitWidth(28),
                       startAngle: .pi * 1.72,
                       endAngle: .pi * 0.28,
                       clockwise: false)
        context.strokePath()
    }
}

private final class Guide0820ProfessionalBasisUIKitVM: GuidanceRemoveBarrierVM {
    private lazy var professionalBadge = Guide0820BadgeVM(title: "专业")
    private lazy var authorityBadge = Guide0820BadgeVM(title: "权威")

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820ProfessionalBasisUIKitVM {
    func configureContent() {
        titleLabel.text = "建立在专业依据之上"
        zhunayeLabel.text = "与传奇运动员和营养师合作\n将专业经验融入 ELA"
        jijianLabel.text = "结合美国农业部 USDA 等权威\n数据库 让记录与分析更有依据"

        zhuanyeImg.isHidden = true
        jijianImg.isHidden = true

        addSubview(professionalBadge)
        addSubview(authorityBadge)

        professionalBadge.snp.makeConstraints { make in
            make.center.equalTo(zhuanyeImg)
            make.width.equalTo(kFitWidth(157))
            make.height.equalTo(kFitWidth(45))
        }

        authorityBadge.snp.makeConstraints { make in
            make.center.equalTo(jijianImg)
            make.width.equalTo(kFitWidth(157))
            make.height.equalTo(kFitWidth(45))
        }
    }
}

private extension UILabel {
    func setLineSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = spacing
        attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font as Any,
                .foregroundColor: textColor as Any,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}
