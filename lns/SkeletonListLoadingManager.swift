//
//  SkeletonListLoadingManager.swift
//  lns
//
//  Created by LNS2 on 2025/11/25.
//

import UIKit

/// 主要功能：
/// 1. 初始骨架 → 数据加载完成 → 去骨架
/// 2. “无数据”情况下：骨架淡出 → NoDataView 淡入（无闪烁）
///
/// 用于任何 UITableView 页面
class SkeletonListLoadingManager {

    /// 公用入口（给 TableView 扩展调用）
    static func finishLoading<T: UITableViewCell>(
        tableView: UITableView,
        list: NSArray,
        noDataView: UIView,
        animationCellType: T.Type,
        skeletonFadeDuration: TimeInterval = 0.25
    ) {

        // 1. 有数据：正常 reload，不显示 NoDataView
        if list.count > 0 {
            noDataView.isHidden = true
            tableView.reloadData()
            return
        }

        // 2. 无数据：让当前 skeleton cell 优雅淡出
        fadeOutSkeleton(in: tableView, cellType: animationCellType, duration: skeletonFadeDuration)

        // 3. 等骨架淡出完成后 → 淡入 noDataView
        DispatchQueue.main.asyncAfter(deadline: .now() + skeletonFadeDuration) {

            fadeIn(view: noDataView, duration: 0.25)

            // 最后清空 tableView 数据（避免空 rows 可选）
            tableView.reloadData()
        }
    }

    /// 渐隐 Skeleton
    private static func fadeOutSkeleton<T: UITableViewCell>(
        in tableView: UITableView,
        cellType: T.Type,
        duration: TimeInterval
    ) {
        for cell in tableView.visibleCells {
            guard let cell = cell as? PlanListTableViewCell else { continue }

            // 你项目中定义的 skeletonViews
            [cell.nameLabel, cell.timeLabel, cell.planDaysLabel].forEach { lbl in
                lbl?.hideSkeletonWithCrossfade()
            }
        }
    }

    /// 泛用 fadeIn
    private static func fadeIn(view: UIView, duration: TimeInterval) {
        view.alpha = 0
        view.isHidden = false
        UIView.animate(withDuration: duration) {
            view.alpha = 1
        }
    }

}
