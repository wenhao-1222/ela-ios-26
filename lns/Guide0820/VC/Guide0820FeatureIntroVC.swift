import UIKit
import SnapKit

/// 功能介绍页 VM 的最小展示契约。每个 MasterGo 图层对应一个独立 VM。
protocol Guide0820FeaturePageViewModel {
    var title: String { get }
    var message: String { get }
    var detail: String { get }
    var imageName: String { get }
}

/// 承载五个功能介绍 VM 的横向分页控制器。
final class Guide0820FeatureIntroVC: WHBaseViewVC, UIScrollViewDelegate {
    private let pageViewModels: [Guide0820FeaturePageViewModel] = [
        Guide0820FeatureNutritionRecommendationVM(),
        Guide0820FeatureDynamicGoalsVM(),
        Guide0820FeatureAIActionVM(),
        Guide0820FeatureWeightTrendVM(),
        Guide0820FeatureNutritionAnalysisVM()
    ]
    private let onFinished: (() -> Void)?
    private let scrollView = UIScrollView()
    private let pagesContentView = UIView()
    private let pageIndicatorStack = UIStackView()
    private let previousButton = ElaLiquidGlassCloseButton(image: UIImage(systemName: "chevron.left"))
    private let nextButton = ElaLiquidGlassCloseButton(image: UIImage(systemName: "chevron.right"))
    private let continueButton = UIButton(type: .system)
    private var currentPage = 0

    init(onFinished: (() -> Void)? = nil) {
        self.onFinished = onFinished
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        onFinished = nil
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        addELAFlowingBackground()
        buildInterface()
        updateNavigationState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enforceInteractivePopGestureDisabled()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enforceInteractivePopGestureDisabled()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }

    deinit { restoreFullscreenInteractivePopGesture() }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageFromScrollPosition()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updatePageFromScrollPosition()
    }
}

private extension Guide0820FeatureIntroVC {
    func buildInterface() {
        view.backgroundColor = .COLOR_BG_F2

        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        scrollView.addSubview(pagesContentView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        pagesContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalTo(view.snp.width).multipliedBy(pageViewModels.count)
        }

        var previousPage: UIView?
        for vm in pageViewModels {
            let page = makePageView(vm)
            pagesContentView.addSubview(page)
            page.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(view.snp.width)
                if let previousPage { $0.left.equalTo(previousPage.snp.right) }
                else { $0.left.equalToSuperview() }
            }
            previousPage = page
        }
        if let previousPage { previousPage.snp.makeConstraints { $0.right.equalToSuperview() } }

        pageIndicatorStack.axis = .horizontal
        pageIndicatorStack.spacing = kFitWidth(6)
        pageIndicatorStack.alignment = .center
        view.addSubview(pageIndicatorStack)
        for _ in pageViewModels {
            let indicator = UIView()
            indicator.layer.cornerRadius = kFitWidth(2)
            indicator.snp.makeConstraints { $0.width.equalTo(kFitWidth(19)); $0.height.equalTo(kFitWidth(4)) }
            pageIndicatorStack.addArrangedSubview(indicator)
        }
        pageIndicatorStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kFitWidth(480))
            $0.height.equalTo(kFitWidth(4))
        }

        configureArrow(previousButton, action: #selector(previousPageAction))
        configureArrow(nextButton, action: #selector(nextPageAction))
        view.addSubview(previousButton); view.addSubview(nextButton)
        previousButton.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(20)); $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kFitWidth(268)); $0.width.height.equalTo(kFitWidth(44))
        }
        nextButton.snp.makeConstraints {
            $0.right.equalTo(kFitWidth(-20)); $0.centerY.equalTo(previousButton); $0.width.height.equalTo(kFitWidth(44))
        }

        continueButton.setTitle("继续", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: kFitWidth(17), weight: .medium)
        continueButton.backgroundColor = .THEME
        continueButton.layer.cornerRadius = kFitWidth(12)
        continueButton.enablePressEffect()
        continueButton.addTarget(self, action: #selector(continueAction), for: .touchUpInside)
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(16)); $0.right.equalTo(kFitWidth(-16))
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(kFitWidth(-8))
            $0.height.equalTo(kFitWidth(52))
        }
    }

    func makePageView(_ vm: Guide0820FeaturePageViewModel) -> UIView {
        let page = UIView()

        let title = UILabel()
        title.text = vm.title
        title.textColor = .COLOR_TEXT_TITLE_0f1214
        title.font = .systemFont(ofSize: kFitWidth(17), weight: .semibold)
        title.textAlignment = .center
        page.addSubview(title)
        title.snp.makeConstraints {
            $0.top.equalTo(page.safeAreaLayoutGuide.snp.top).offset(kFitWidth(38))
            $0.centerX.equalToSuperview(); $0.height.equalTo(kFitWidth(25))
        }

        let imageView = UIImageView(image: UIImage(named: vm.imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        page.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalTo(page.safeAreaLayoutGuide.snp.top).offset(kFitWidth(85))
            $0.centerX.equalToSuperview(); $0.width.equalTo(kFitWidth(225)); $0.height.equalTo(kFitWidth(376))
        }

        let message = UILabel()
        message.text = vm.message
        message.textColor = .COLOR_TEXT_TITLE_0f1214
        message.font = .systemFont(ofSize: kFitWidth(21), weight: .medium)
        message.numberOfLines = 0
        message.lineBreakMode = .byWordWrapping
        page.addSubview(message)
        message.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(32)); $0.right.equalTo(kFitWidth(-28))
            $0.top.equalTo(page.safeAreaLayoutGuide.snp.top).offset(kFitWidth(522))
        }

        let detail = UILabel()
        detail.text = vm.detail
        detail.textColor = .COLOR_TEXT_TITLE_0f1214_50
        detail.font = .systemFont(ofSize: kFitWidth(14), weight: .regular)
        detail.numberOfLines = 0
        detail.lineBreakMode = .byWordWrapping
        // MasterGo 标注行高为 47.6px（2x 导出，对应 23.8pt）。
        detail.guide0820SetLineHeight(kFitWidth(23.8))
        page.addSubview(detail)
        detail.snp.makeConstraints {
            $0.left.equalTo(message); $0.right.equalTo(page).offset(kFitWidth(-28))
            $0.top.equalTo(message.snp.bottom).offset(kFitWidth(8))
        }
        return page
    }

    func configureArrow(_ button: ElaLiquidGlassCloseButton, action: Selector) {
        button.iconColor = .COLOR_TEXT_TITLE_0f1214
        button.iconSize = kFitWidth(17)
        button.showsOuterStroke = true
        button.accessibilityLabel = action == #selector(previousPageAction) ? "上一页" : "下一页"
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    func enforceInteractivePopGestureDisabled() {
        updateInteractivePopGestureBlocked(true)
        // iOS 26 exposes the full-screen recognizer separately; keep both
        // recognizers disabled while this onboarding page is visible.
        if #available(iOS 26.0, *) {
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }
        DispatchQueue.main.async { [weak self] in
            guard let self, self.navigationController?.topViewController === self else { return }
            self.updateInteractivePopGestureBlocked(true)
            if #available(iOS 26.0, *) {
                self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            }
        }
    }

    func updatePageFromScrollPosition() {
        let width = max(scrollView.bounds.width, 1)
        let index = min(max(Int(round(scrollView.contentOffset.x / width)), 0), pageViewModels.count - 1)
        currentPage = index
        updateNavigationState()
    }

    func updateNavigationState() {
        previousButton.isHidden = currentPage == 0
        nextButton.isHidden = currentPage == pageViewModels.count - 1
        for (index, view) in pageIndicatorStack.arrangedSubviews.enumerated() {
            view.backgroundColor = index == currentPage ? .THEME : UIColor.COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.12)
        }
    }

    func showPage(_ index: Int) {
        let target = min(max(index, 0), pageViewModels.count - 1)
        scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width * CGFloat(target), y: 0), animated: true)
        currentPage = target
        updateNavigationState()
    }

    @objc func previousPageAction() { showPage(currentPage - 1) }
    @objc func nextPageAction() { showPage(currentPage + 1) }

    @objc func continueAction() {
        if currentPage < pageViewModels.count - 1 {
            showPage(currentPage + 1)
        } else {
            onFinished?()
        }
    }
}
