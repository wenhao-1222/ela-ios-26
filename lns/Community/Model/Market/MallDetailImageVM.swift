//
//  MallDetailImageVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/15.
//

import UIKit

final class MallDetailImageVM {

    let url: String

    /// 计算后的最终高度
    var height: CGFloat?

    /// Hero 预览模块（只创建一次）
    var heroModule: HeroBrowserViewModule?

    /// 是否正在加载（防止重复请求）
    var isLoading: Bool = false

    init(url: String) {
        self.url = url
    }
}
