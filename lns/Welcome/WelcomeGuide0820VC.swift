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
            self?.showNextPage()
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
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
        showNextPage()
    }

    func showNextPage() {
        guard scrollView.bounds.width > 0 else { return }
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
        didFinish = true
        UserDefaults.standard.set(true, forKey: Self.hasShownKey)
        finishBlock?()
    }
}

extension WelcomeGuide0820VC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffsetX = scrollView.bounds.width * 2
        guard scrollView.contentOffset.x > maxOffsetX + kFitWidth(54) else { return }
        finishGuide()
    }
}
