//
//  RankCarouselView.swift
//  lns
//
//  Created by LNS2 on 2026/1/4.
//

import UIKit

public final class RankCarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    public enum TransitionKind { case normal, promote, demote }

    public var tiers: [RankTier] = [] {
        didSet { collectionView.reloadData(); layoutIfNeeded(); snap(to: currentIndex, animated: false) }
    }

    public var unlockedMaxIndex: Int = 0 {
        didSet {
            collectionView.visibleCells.forEach {
                ($0 as? RankBadgeCell)?.setLockedState(isLocked: isLocked(indexPath: collectionView.indexPath(for: $0)))
            }
        }
    }

    public private(set) var currentIndex: Int = 0
    public var onIndexChanged: ((Int) -> Void)?

    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    // ✅ 晋升 overlay：隐藏目标 cell，避免重影
    private var suppressIndex: Int? = nil
    private var promoteGhostView: UIImageView? = nil

    private var isTransitioning: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 26

        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RankBadgeCell.self, forCellWithReuseIdentifier: "RankBadgeCell")

        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let itemW = min(bounds.width * 0.42, 240)
        layout.itemSize = CGSize(width: itemW, height: itemW)

        let insetX = (bounds.width - itemW) / 2
        let insetY = max(0, (bounds.height - itemW) / 2)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)

        applyTransforms()
    }

    // MARK: - Public

    public func snap(to index: Int, animated: Bool) {
        guard !tiers.isEmpty else { return }
        let clamped = max(0, min(index, tiers.count - 1))
        currentIndex = clamped
        collectionView.setContentOffset(CGPoint(x: offsetX(for: clamped), y: 0), animated: animated)
        applyTransforms()
        onIndexChanged?(currentIndex)
    }

    public func playTransition(to index: Int, kind: TransitionKind) {
        guard !tiers.isEmpty else { return }
        if isTransitioning { return }
        isTransitioning = true
        collectionView.isUserInteractionEnabled = false

        let target = max(0, min(index, tiers.count - 1))

        func finish() {
            self.isTransitioning = false
            self.collectionView.isUserInteractionEnabled = true
        }

        func slide(to target: Int, completion: @escaping () -> Void) {
            UIView.animate(withDuration: 0.42,
                           delay: 0.02,
                           options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.collectionView.setContentOffset(CGPoint(x: self.offsetX(for: target), y: 0), animated: false)
                self.applyTransforms()
            } completion: { _ in
                completion()
            }
        }

        switch kind {
        case .promote:
            // ✅ 边入场边翻转：用 overlay 从右侧进来，同时翻转3次
            suppressIndex = target
            applyTransforms()

            let ghost = UIImageView()
            ghost.contentMode = .scaleAspectFit
            ghost.image = tiers[target].image ?? EffectsFactory.placeholderBadge(size: 260)
            ghost.bounds = CGRect(origin: .zero, size: layout.itemSize)

            let startX = bounds.maxX + layout.itemSize.width * 0.55
//            let centerY = bounds.midY
//            ghost.center = CGPoint(x: startX, y: centerY)
            // 保持入场高度与列表当前中心一致
            let targetCenter: CGPoint
            if let attrs = layout.layoutAttributesForItem(at: IndexPath(item: target, section: 0)) {
                targetCenter = collectionView.convert(attrs.center, to: self)
            } else {
                targetCenter = CGPoint(x: bounds.midX, y: bounds.midY)
            }

            ghost.center = CGPoint(x: startX, y: targetCenter.y)
            addSubview(ghost)
            promoteGhostView = ghost

            var t3d = CATransform3DIdentity
            t3d.m34 = -1.0 / 500.0
            ghost.layer.transform = t3d

            // 翻转 3 次（6π），从入场开始执行
            let flip = CABasicAnimation(keyPath: "transform.rotation.y")
            flip.fromValue = 0
            flip.toValue = Double.pi * 4.0//Double.pi * 6.0
            flip.duration = 0.92//0.62
            flip.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            ghost.layer.add(flip, forKey: "ghostFlip3")
            ghost.layer.add(flip, forKey: "ghostFlip2")

            // 同时滑动列表 + ghost 滑入中心
            UIView.animate(withDuration: 0.42,
                           delay: 0.02,
                           options: [.curveEaseInOut, .beginFromCurrentState]) {
//                ghost.center = CGPoint(x: self.bounds.midX, y: centerY)
                ghost.center = CGPoint(x: self.bounds.midX, y: targetCenter.y)
                self.collectionView.setContentOffset(CGPoint(x: self.offsetX(for: target), y: 0), animated: false)
                self.applyTransforms()
            } completion: { _ in
                self.currentIndex = target
                self.onIndexChanged?(target)

                ghost.removeFromSuperview()
                self.promoteGhostView = nil
                self.suppressIndex = nil
                self.applyTransforms()

                let targetCell = self.cell(at: target)
                targetCell?.playPromoteUnlockAfterEntrance()

                finish()
            }

        case .demote:
            // ✅ 先碎裂（碎一地固定）再滑动到上一段位
            if let currentCell = self.cell(at: currentIndex) {
                currentCell.playDemoteGemShatterToFloorThenMoveOut { [weak self] in
                    guard let self else { return }
                    slide(to: target) {
                        self.currentIndex = target
                        self.onIndexChanged?(target)

                        let targetCell = self.cell(at: target)
                        targetCell?.playDemoteArriveSad()
                        finish()
                    }
                }
            } else {
                slide(to: target) {
                    self.currentIndex = target
                    self.onIndexChanged?(target)
                    self.cell(at: target)?.playDemoteArriveSad()
                    finish()
                }
            }

        case .normal:
            slide(to: target) {
                self.currentIndex = target
                self.onIndexChanged?(target)
                finish()
            }
        }
    }

    func cell(at index: Int) -> RankBadgeCell? {
        let ip = IndexPath(item: index, section: 0)
        return collectionView.cellForItem(at: ip) as? RankBadgeCell
    }

    // MARK: - UICollectionView

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tiers.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankBadgeCell", for: indexPath) as! RankBadgeCell
        cell.configure(tier: tiers[indexPath.item])
        cell.setLockedState(isLocked: isLocked(indexPath: indexPath))
        return cell
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isTransitioning { applyTransforms() }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if isTransitioning { return }
        let targetX = targetContentOffset.pointee.x
        let idx = nearestIndex(forOffsetX: targetX)
        targetContentOffset.pointee.x = offsetX(for: idx)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isTransitioning { return }
        currentIndex = nearestIndex(forOffsetX: scrollView.contentOffset.x)
        onIndexChanged?(currentIndex)
    }

    // MARK: - Helpers

    private func isLocked(indexPath: IndexPath?) -> Bool {
        guard let ip = indexPath else { return false }
        return ip.item > unlockedMaxIndex
    }

    private func offsetX(for index: Int) -> CGFloat {
        let itemW = layout.itemSize.width
        let spacing = layout.minimumLineSpacing
        return CGFloat(index) * (itemW + spacing) - collectionView.contentInset.left
    }

    private func nearestIndex(forOffsetX x: CGFloat) -> Int {
        let itemW = layout.itemSize.width
        let spacing = layout.minimumLineSpacing
        let raw = (x + collectionView.contentInset.left) / (itemW + spacing)
        return max(0, min(Int(round(raw)), tiers.count - 1))
    }

    private func applyTransforms() {
        let focusedIndex = nearestIndex(forOffsetX: collectionView.contentOffset.x)
        for c in collectionView.visibleCells {
            guard let cell = c as? RankBadgeCell, let ip = collectionView.indexPath(for: cell) else { continue }
            let isCurrent = ip.item == focusedIndex
            let scale: CGFloat = isCurrent ? 1.0 : 0.5
            let alpha: CGFloat = isCurrent ? 1.0 : 0.7

            if ip.item == suppressIndex {
                cell.applySuppressedState()
            } else {
                cell.applyBadgeScale(scale, alpha: alpha)
            }
        }
    }
}
