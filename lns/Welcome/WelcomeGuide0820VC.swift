//
//  WelcomeGuide0820VC.swift
//  lns
//
//  Created by Codex on 2026/8/20.
//

import UIKit
import SnapKit

final class WelcomeGuide0820VC: WHBaseViewVC {
    static let hasShownKey = "welcome_guide_0820_has_shown"

    var finishBlock: (() -> Void)?

    private var didFinish = false
    private var isCrossFadingPage = false
    private var isPageInteractionLocked = false
    private var currentPageIndex = 0
    private var detailRevealGeneration = 0
    private var didStartInitialPageReveal = false
    private var autoAdvanceWorkItem: DispatchWorkItem?
    private let detailRevealDelay: TimeInterval = 2.0
    private let detailFadeDuration: TimeInterval = 0.35
    private let interactionUnlockDelay: TimeInterval = 0.5
    private let autoAdvanceDelay: TimeInterval = 5.0

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.bounces = true
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()

    private lazy var contentView = UIView()

    private lazy var goalUpdateVM = WelcomeGuide0820GoalUpdateVM()
    private lazy var dailyRecordVM: WelcomeGuide0820DailyRecordVM = {
        let view = WelcomeGuide0820DailyRecordVM()
        let tap = UITapGestureRecognizer(target: self, action: #selector(pageTapAction))
        view.addGestureRecognizer(tap)
        return view
    }()
    private lazy var nutritionStartVM: WelcomeGuide0820NutritionStartVM = {
        let view = WelcomeGuide0820NutritionStartVM()
        view.tapBlock = { [weak self] in
            self?.handlePageTap()
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard didStartInitialPageReveal == false else { return }
        didStartInitialPageReveal = true
        handleVisiblePageChange(to: 0)
    }
}

private extension WelcomeGuide0820VC {
    func initUI() {
        view.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [nutritionStartVM, dailyRecordVM, goalUpdateVM].forEach {
            contentView.addSubview($0)
        }

        let goalTap = UITapGestureRecognizer(target: self, action: #selector(pageTapAction))
        goalUpdateVM.addGestureRecognizer(goalTap)
        nutritionStartVM.setDetailsVisible(false)
        dailyRecordVM.setDetailsVisible(false)
        goalUpdateVM.setDetailsVisible(false)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide).multipliedBy(3)
        }
        nutritionStartVM.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        dailyRecordVM.snp.makeConstraints { make in
            make.left.equalTo(nutritionStartVM.snp.right)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        goalUpdateVM.snp.makeConstraints { make in
            make.left.equalTo(dailyRecordVM.snp.right)
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }

    @objc func pageTapAction() {
        handlePageTap()
    }

    func handlePageTap() {
        guard isPageInteractionLocked == false else { return }
        cancelAutoAdvance()
        showNextPage()
    }

    func showNextPage() {
        guard scrollView.bounds.width > 0 else { return }
        guard isPageInteractionLocked == false else { return }
        guard isCrossFadingPage == false else { return }
        cancelAutoAdvance()
        let currentIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        let nextIndex = currentIndex + 1
        guard nextIndex < 3 else {
            finishGuide()
            return
        }

        if isStagedPage(index: nextIndex) {
            prepareStagedPage(index: nextIndex)
        }

        // showNextPageWithCrossFade()
        scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width * CGFloat(nextIndex), y: 0), animated: true)
    }

    func showNextPageWithCrossFade() {
        guard scrollView.bounds.width > 0 else { return }
        guard isPageInteractionLocked == false else { return }
        guard isCrossFadingPage == false else { return }
        let currentIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        let nextIndex = currentIndex + 1
        guard nextIndex < 3 else {
            finishGuide()
            return
        }

        let oldSnapshot = scrollView.snapshotView(afterScreenUpdates: false)
        oldSnapshot?.frame = view.bounds
        let nextPage = pageView(at: nextIndex)

        isCrossFadingPage = true
        scrollView.isScrollEnabled = false
        nextPage.alpha = 0
        scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width * CGFloat(nextIndex), y: 0), animated: false)
        view.layoutIfNeeded()

        if let oldSnapshot = oldSnapshot {
            view.addSubview(oldSnapshot)
        }

        UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseInOut]) {
            nextPage.alpha = 1
            oldSnapshot?.alpha = 0
        } completion: { _ in
            nextPage.alpha = 1
            oldSnapshot?.removeFromSuperview()
            self.scrollView.isScrollEnabled = true
            self.isCrossFadingPage = false
            self.handleVisiblePageChange(to: nextIndex)
        }
    }

    func pageView(at index: Int) -> UIView {
        switch index {
        case 0:
            return nutritionStartVM
        case 1:
            return dailyRecordVM
        default:
            return goalUpdateVM
        }
    }

    func finishGuide() {
        guard didFinish == false else { return }
        cancelAutoAdvance()
        detailRevealGeneration += 1
        didFinish = true
        UserDefaults.standard.set(true, forKey: Self.hasShownKey)
        finishBlock?()
    }

    func isStagedPage(index: Int) -> Bool {
        return index == 0 || index == 1 || index == 2
    }

    func shouldAutoAdvancePage(index: Int) -> Bool {
        return index == 0 || index == 1
    }

    func stagedPage(at index: Int) -> WelcomeGuide0820BasePageVM? {
        switch index {
        case 0:
            return nutritionStartVM
        case 1:
            return dailyRecordVM
        case 2:
            return goalUpdateVM
        default:
            return nil
        }
    }

    func prepareStagedPage(index: Int) {
        detailRevealGeneration += 1
        stagedPage(at: index)?.setDetailsVisible(false)
    }

    func handleVisiblePageChange(to index: Int, shouldRevealDetailsImmediately: Bool = false) {
        currentPageIndex = index
        cancelAutoAdvance()
        hideInactiveStagedPages(excluding: index)

        if isStagedPage(index: index) {
            if shouldRevealDetailsImmediately {
                showStagedPageImmediately(index: index)
            } else {
                startDetailReveal(for: index)
            }
        } else {
            detailRevealGeneration += 1
            isPageInteractionLocked = false
            scrollView.isScrollEnabled = true
        }
    }

    func hideInactiveStagedPages(excluding index: Int) {
        [0, 1, 2].forEach { stagedIndex in
            guard stagedIndex != index else { return }
            stagedPage(at: stagedIndex)?.setDetailsVisible(false)
        }
    }

    func startDetailReveal(for index: Int) {
        guard let page = stagedPage(at: index) else { return }

        detailRevealGeneration += 1
        let generation = detailRevealGeneration
        isPageInteractionLocked = true
        scrollView.isScrollEnabled = false

        page.revealDetails(delay: detailRevealDelay,
                           duration: detailFadeDuration) { [weak self] in
            guard let self = self,
                  self.detailRevealGeneration == generation,
                  self.currentPageIndex == index,
                  self.didFinish == false else { return }

            if self.shouldAutoAdvancePage(index: index) {
                self.scheduleAutoAdvance(generation: generation, pageIndex: index)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + self.interactionUnlockDelay) { [weak self] in
                guard let self = self,
                      self.detailRevealGeneration == generation,
                      self.currentPageIndex == index,
                      self.didFinish == false else { return }
                self.isPageInteractionLocked = false
                self.scrollView.isScrollEnabled = true
            }
        }
    }

    func showStagedPageImmediately(index: Int) {
        guard let page = stagedPage(at: index) else { return }

        detailRevealGeneration += 1
        let generation = detailRevealGeneration
        page.setDetailsVisible(true)
        isPageInteractionLocked = false
        scrollView.isScrollEnabled = true
        if shouldAutoAdvancePage(index: index) {
            scheduleAutoAdvance(generation: generation, pageIndex: index)
        }
    }

    func scheduleAutoAdvance(generation: Int, pageIndex: Int) {
        guard shouldAutoAdvancePage(index: pageIndex) else { return }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  self.detailRevealGeneration == generation,
                  self.currentPageIndex == pageIndex,
                  self.isPageInteractionLocked == false,
                  self.didFinish == false else { return }
            self.showNextPage()
        }
        autoAdvanceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + autoAdvanceDelay, execute: workItem)
    }

    func cancelAutoAdvance() {
        autoAdvanceWorkItem?.cancel()
        autoAdvanceWorkItem = nil
    }
}

extension WelcomeGuide0820VC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cancelAutoAdvance()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetIndex = pageIndex(for: targetContentOffset.pointee.x)
        guard targetIndex < currentPageIndex,
              isStagedPage(index: targetIndex) else { return }
        stagedPage(at: targetIndex)?.setDetailsVisible(true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = pageIndex(for: scrollView.contentOffset.x)
        handleVisiblePageChange(to: index, shouldRevealDetailsImmediately: index < currentPageIndex)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleVisiblePageChange(to: pageIndex(for: scrollView.contentOffset.x))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffsetX = scrollView.bounds.width * 2
        guard scrollView.contentOffset.x > maxOffsetX + kFitWidth(54) else { return }
        finishGuide()
    }

    private func pageIndex(for offsetX: CGFloat) -> Int {
        let index = Int(round(offsetX / max(scrollView.bounds.width, 1)))
        return min(max(index, 0), 2)
    }
}
