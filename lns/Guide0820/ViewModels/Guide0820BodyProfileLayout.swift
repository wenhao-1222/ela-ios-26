//
//  Guide0820BodyProfileLayout.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

/// 将 MasterGo 750px 设计稿尺寸换算成项目当前的 375pt 基准适配尺寸。
func guide0820Design(_ px: CGFloat) -> CGFloat {
    kFitWidth(px / 2.0)
}
