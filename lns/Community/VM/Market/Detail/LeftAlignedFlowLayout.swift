//
//  LeftAlignedFlowLayout.swift
//  lns
//
//  Created by Elavatine on 2025/9/9.
//

import UIKit

/// 固定 interItemSpacing/lineSpacing 的左对齐流式布局
final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    private let fixedInterItem: CGFloat
    private let fixedLine: CGFloat
    private let fixedInsets: UIEdgeInsets

    init(interItemSpacing: CGFloat, lineSpacing: CGFloat, sectionInsets: UIEdgeInsets) {
        self.fixedInterItem = interItemSpacing
        self.fixedLine = lineSpacing
        self.fixedInsets = sectionInsets
        super.init()
        minimumInteritemSpacing = interItemSpacing
        minimumLineSpacing = lineSpacing
        sectionInset = sectionInsets
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attrs = super.layoutAttributesForElements(in: rect)?
                .map({ $0.copy() as! UICollectionViewLayoutAttributes }),
              let _ = collectionView else { return super.layoutAttributesForElements(in: rect) }

        // 仅调整 cell，保持补充视图位置
        var currentRowY: CGFloat = -CGFloat.greatestFiniteMagnitude
        var left: CGFloat = fixedInsets.left

        for a in attrs where a.representedElementCategory == .cell {
            // 新起一行（y 改变）
            if abs(a.frame.origin.y - currentRowY) > 1 {
                currentRowY = a.frame.origin.y
                left = fixedInsets.left
            }
            a.frame.origin.x = left
            left = a.frame.maxX + fixedInterItem
        }
        return attrs
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
}
