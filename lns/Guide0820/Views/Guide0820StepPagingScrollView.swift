//
//  Guide0820StepPagingScrollView.swift
//  lns
//
//  Created by Codex on 2026/9/1.
//

import UIKit

/// Guide0820 问卷流程使用的只读回退分页容器。
///
/// 用户只能向右拖动返回上一页；向前翻页仍由页面的“下一步”按钮驱动，
/// 避免绕过校验、数据提交和请求等业务逻辑。
final class Guide0820StepPagingScrollView: UIScrollView {
    /// 当前已经确认落页的下标。为 0 时不接管手势，让导航控制器处理返回。
    var settledPageIndex = 0

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panGestureRecognizer,
              settledPageIndex > 0,
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        let velocity = panGesture.velocity(in: self)
        guard velocity.x > 0, abs(velocity.x) > abs(velocity.y) else {
            return false
        }

        // 页面内部的横向刻度尺等组件优先响应，避免调整数值时误触发整页返回。
        let touchLocation = panGesture.location(in: self)
        if containsNestedHorizontalScrollView(at: touchLocation) {
            return false
        }

        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    /// 将系统预测的落点限制在手势开始页或它的上一页，确保一次只返回一步。
    func clampBackwardTargetContentOffset(_ targetContentOffset: UnsafeMutablePointer<CGPoint>,
                                          from pageIndex: Int) {
        let pageWidth = bounds.width
        guard pageWidth > 0 else { return }

        let currentOffsetX = pageWidth * CGFloat(pageIndex)
        let previousOffsetX = pageWidth * CGFloat(max(pageIndex - 1, 0))
        targetContentOffset.pointee.x = min(max(targetContentOffset.pointee.x, previousOffsetX), currentOffsetX)
        targetContentOffset.pointee.y = 0
    }

    /// 返回当前实际停靠的页码。
    func landedPageIndex(pageCount: Int) -> Int {
        guard pageCount > 0 else { return 0 }
        let pageWidth = max(bounds.width, 1)
        return min(max(Int(round(contentOffset.x / pageWidth)), 0), pageCount - 1)
    }

    private func containsNestedHorizontalScrollView(at location: CGPoint) -> Bool {
        var candidate = hitTest(location, with: nil)
        while let view = candidate, view !== self {
            if let nestedScrollView = view as? UIScrollView,
               nestedScrollView !== self,
               nestedScrollView.isScrollEnabled,
               nestedScrollView.contentSize.width > nestedScrollView.bounds.width + 1 {
                return true
            }
            candidate = view.superview
        }
        return false
    }
}
