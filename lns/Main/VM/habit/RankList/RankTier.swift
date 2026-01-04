//
//  RankTier.swift
//  lns
//
//  Created by LNS2 on 2026/1/4.
//

import UIKit

public struct RankTier {
    public let id: Int           // 1...9
    public let name: String
    public let imageName: String // rank_1 ... rank_9
    public let accent: UIColor   // 发光/纸屑主色

    public init(id: Int, name: String, imageName: String, accent: UIColor) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.accent = accent
    }

    public var image: UIImage? { UIImage(named: imageName) }

    /// 示例 9 段位（你可以按实际段位名称/颜色改）
    public static func defaultNine() -> [RankTier] {
        let accents: [UIColor] = [
            UIColor(red: 0.78, green: 0.55, blue: 0.37, alpha: 1.0), // bronze
            UIColor(red: 0.55, green: 0.72, blue: 0.92, alpha: 1.0), // sapphire
            UIColor(red: 0.98, green: 0.74, blue: 0.20, alpha: 1.0), // gold
            UIColor(red: 0.67, green: 0.88, blue: 0.50, alpha: 1.0),
            UIColor(red: 0.86, green: 0.55, blue: 0.92, alpha: 1.0),
            UIColor(red: 0.30, green: 0.83, blue: 0.86, alpha: 1.0),
            UIColor(red: 0.95, green: 0.40, blue: 0.33, alpha: 1.0),
            UIColor(red: 0.35, green: 0.45, blue: 0.98, alpha: 1.0),
            UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0),
        ]
        return (1...9).map { i in
            RankTier(id: i, name: "段位\(i)", imageName: "rank_\(i)", accent: accents[(i-1) % accents.count])
        }
    }
}
