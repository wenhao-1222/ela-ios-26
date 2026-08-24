//
//  Guide0820RootView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820 引导流程根视图。
final class Guide0820RootView: UIView {
    /// 引导流程状态。
    private let flowState: Guide0820FlowState
    /// 打开协议页面回调。
    private let onOpenAgreement: (Guide0820AgreementType) -> Void
    /// 完成引导回调。
    private let onFinish: () -> Void
    /// 当前展示的页面视图。
    private var currentPageView: UIView?
    /// 手势开始时的页面下标。
    private var dragStartPageIndex = 0
    /// 页面是否正在切换动画中。
    private var isAnimatingPage = false

    /// 创建引导流程根视图。
    /// - Parameters:
    ///   - flowState: 引导流程状态。
    ///   - onOpenAgreement: 打开协议页面回调。
    ///   - onFinish: 完成引导回调。
    init(flowState: Guide0820FlowState,
         onOpenAgreement: @escaping (Guide0820AgreementType) -> Void,
         onFinish: @escaping () -> Void) {
        self.flowState = flowState
        self.onOpenAgreement = onOpenAgreement
        self.onFinish = onFinish
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 展示上一页。
    func showPreviousPage() {
        guard flowState.currentPageIndex > 0 else { return }
        flowState.showPrevious()
        showPage(at: flowState.currentPageIndex, direction: .backward, animated: true)
    }
}

private extension Guide0820RootView {
    /// 页面切换方向。
    enum PageDirection {
        /// 向前切换。
        case forward
        /// 向后切换。
        case backward

        /// 新页面进入时的水平偏移方向。
        var incomingOffsetSign: CGFloat {
            self == .forward ? 1 : -1
        }
    }

    /// 初始化视图结构。
    func initUI() {
        backgroundColor = .COLOR_BG_F2
        clipsToBounds = true

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)

        showPage(at: flowState.currentPageIndex, direction: .forward, animated: false)
    }

    /// 根据下标创建页面。
    /// - Parameter index: 页面下标。
    /// - Returns: 对应的页面视图。
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

    /// 展示下一页或完成引导。
    func showNextPage() {
        guard flowState.currentPageIndex < 2 else {
            onFinish()
            return
        }

        flowState.showNext()
        showPage(at: flowState.currentPageIndex, direction: .forward, animated: true)
    }

    /// 执行页面切换。
    /// - Parameters:
    ///   - index: 目标页面下标。
    ///   - direction: 切换方向。
    ///   - animated: 是否展示动画。
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

    /// 根据当前展示页同步子页面生命周期。
    /// - Parameter page: 当前展示页。
    func updatePageLifecycle(for page: UIView) {
        subviews.forEach { view in
            if let professionalView = view as? Guide0820ProfessionalBasisView {
                professionalView.setActive(view === page)
            }
        }
    }

    /// 处理右滑返回手势。
    /// - Parameter gesture: 当前滑动手势。
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
    /// 允许和页面内滚动手势同时识别。
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
