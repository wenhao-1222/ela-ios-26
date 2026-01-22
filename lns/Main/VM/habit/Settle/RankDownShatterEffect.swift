//
//  RankDownShatterEffect.swift
//  lns
//
//  Created by LNS2 on 2026/1/22.
//

import UIKit

/// 段位降低：碎裂 -> 上抛 -> 下落 -> 定格碎块
/// 一行调用：RankDownShatterEffect.play(on: badgeView)
final class RankDownShatterEffect: UIView {

    struct Config {
        /// 碎块网格（越大越细，建议 4x4 或 5x5）
        var grid: (cols: Int, rows: Int) = (4, 4)

        /// 碎块数量上限（会从网格里挑一部分做“碎裂块”）
        var maxPieceCount: Int = 12

        /// 动画时长（上抛+下落）
        var duration: TimeInterval = 0.75

        /// 上抛高度范围（值越大越“炸得高”）
        var burstUp: ClosedRange<CGFloat> = 80...130

        /// 水平散射范围（轨迹更可循就把范围变小）
        var burstX: ClosedRange<CGFloat> = -70...70

        /// 落点下沉范围（重力下落）
        var fallDown: ClosedRange<CGFloat> = 40...90

        /// 旋转强度（弧度）
        var rotate: ClosedRange<CGFloat> = (-1.2)...(1.2)

        /// 让碎片“更硬块”还是“更柔”
        var cornerRadius: CGFloat = 6

        /// 是否保留底座（底部几行不炸裂，留在中心像视频那样“底座还在”）
        var keepBaseRows: Int = 1

        /// 是否自动移除（视频里是定格不消失，默认 false）
        var autoRemoveAfter: TimeInterval? = nil

        /// 额外的小碎点数量（少量，增强碎裂感）
        var dustCount: Int = 10
    }

    // MARK: - API

    @discardableResult
    static func play(on targetView: UIView, config: Config = Config()) -> RankDownShatterEffect? {
        guard let superV = targetView.superview else { return nil }
        superV.layoutIfNeeded()

        let overlay = RankDownShatterEffect(frame: superV.bounds)
        overlay.isUserInteractionEnabled = false
        superV.addSubview(overlay)

        overlay.run(on: targetView, in: superV, config: config)
        return overlay
    }

    // MARK: - Internals

    private var pieceLayers: [CALayer] = []
    private var dustLayers: [CAShapeLayer] = []
    private var baseLayers: [CALayer] = []

    private func run(on target: UIView, in superV: UIView, config: Config) {
        let snap = snapshot(of: target)
        let targetFrame = superV.convert(target.bounds, from: target)

        // 先隐藏原图（你也可以改成 alpha=0.2 之类）
        let oldAlpha = target.alpha
        target.alpha = 0

        // 创建碎块（部分碎裂，底部保留）
        buildPieces(image: snap, targetFrame: targetFrame, config: config)

        // 少量小碎点（增强碎裂瞬间）
        buildDust(targetFrame: targetFrame, config: config)

        // 执行动画
        animatePieces(from: targetFrame, config: config) { [weak self] in
            // 定格后恢复/处理
            guard let self else { return }

            // 保持碎块定格：不恢复 target（因为这是“降级碎裂态”）
            // 如果你希望碎裂完显示“降级后的新段位图”，可以在这里把 target.image 换掉再 alpha=1

            if let t = config.autoRemoveAfter {
                DispatchQueue.main.asyncAfter(deadline: .now() + t) { [weak self] in
                    guard let self else { return }
                    UIView.animate(withDuration: 0.25) {
                        self.alpha = 0
                    } completion: { _ in
                        target.alpha = oldAlpha
                        self.removeFromSuperview()
                    }
                }
            }
        }
    }

    // MARK: - Build

    private func buildPieces(image: UIImage, targetFrame: CGRect, config: Config) {
        let cols = max(2, config.grid.cols)
        let rows = max(2, config.grid.rows)

        let pieceW = targetFrame.width / CGFloat(cols)
        let pieceH = targetFrame.height / CGFloat(rows)

        // 底部保留几行不炸裂（当“底座”）
        let keepBaseRows = max(0, min(rows, config.keepBaseRows))
        let baseRowStart = rows - keepBaseRows

        var candidates: [(c: Int, r: Int)] = []
        for r in 0..<rows {
            for c in 0..<cols {
                if r < baseRowStart { candidates.append((c, r)) }
            }
        }

        // 随机挑 maxPieceCount 个做“碎裂块”
        candidates.shuffle()
        let pieceCount = min(config.maxPieceCount, candidates.count)
        let shatterSet = Set(candidates.prefix(pieceCount).map { "\($0.c)-\($0.r)" })

        for r in 0..<rows {
            for c in 0..<cols {

                let rect = CGRect(
                    x: targetFrame.minX + CGFloat(c) * pieceW,
                    y: targetFrame.minY + CGFloat(r) * pieceH,
                    width: pieceW,
                    height: pieceH
                )

                let contentsRect = CGRect(
                    x: CGFloat(c) / CGFloat(cols),
                    y: CGFloat(r) / CGFloat(rows),
                    width: 1 / CGFloat(cols),
                    height: 1 / CGFloat(rows)
                )

                let layer = CALayer()
                layer.frame = rect
                layer.contents = image.cgImage
                layer.contentsGravity = .resizeAspectFill
                layer.contentsRect = contentsRect
                layer.masksToBounds = true
                layer.cornerRadius = config.cornerRadius
                layer.allowsEdgeAntialiasing = true

                // 轻微阴影，让“块状碎片”更立体
                layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
                layer.shadowOpacity = 1
                layer.shadowRadius = 6
                layer.shadowOffset = CGSize(width: 0, height: 2)

                self.layer.addSublayer(layer)

                let key = "\(c)-\(r)"
                if r >= baseRowStart {
                    // 底座：不炸裂，仅轻微抖动一下就定格
                    baseLayers.append(layer)
                } else if shatterSet.contains(key) {
                    pieceLayers.append(layer)
                } else {
                    // 非碎裂块：淡掉（让主体看起来“裂开”）
                    layer.opacity = 0.0
                }
            }
        }
    }

    private func buildDust(targetFrame: CGRect, config: Config) {
        guard config.dustCount > 0 else { return }
        let center = CGPoint(x: targetFrame.midX, y: targetFrame.midY)

        for _ in 0..<config.dustCount {
            let r = CGFloat.random(in: 1.5...3.5)
            let dot = CAShapeLayer()
            dot.path = UIBezierPath(ovalIn: CGRect(x: -r, y: -r, width: 2*r, height: 2*r)).cgPath
            dot.fillColor = UIColor.black.withAlphaComponent(0.12).cgColor
            dot.position = center
            dot.opacity = 0
            layer.addSublayer(dot)
            dustLayers.append(dot)
        }
    }

    // MARK: - Animate

    private func animatePieces(from targetFrame: CGRect,
                               config: Config,
                               completion: @escaping () -> Void) {

        let center = CGPoint(x: targetFrame.midX, y: targetFrame.midY)
        let duration = config.duration

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        // 1) 底座轻微“震一下”更像碎裂瞬间
        for b in baseLayers {
            let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shake.values = [0, -3, 2, -1, 0]
            shake.keyTimes = [0, 0.25, 0.5, 0.75, 1] as [NSNumber]
            shake.duration = 0.22
            shake.timingFunction = CAMediaTimingFunction(name: .easeOut)
            b.add(shake, forKey: "baseShake")
        }

        // 2) 碎块：同一点炸开 -> 上抛 -> 下落定格
        for p in pieceLayers {
            let start = CGPoint(x: p.frame.midX, y: p.frame.midY)

            let dx = CGFloat.random(in: config.burstX)
            let up = CGFloat.random(in: config.burstUp)
            let down = CGFloat.random(in: config.fallDown)

            // 终点：围绕中心稍微散开并下沉
            let end = CGPoint(
                x: start.x + dx,
                y: start.y - up * 0.15 + down
            )

            // 中间点：先明显上冲（轨迹可循）
            let mid = CGPoint(
                x: start.x + dx * 0.65,
                y: start.y - up
            )

            // 用二段贝塞尔（start->mid->end）实现“上抛再下落”
            let path = UIBezierPath()
            path.move(to: start)
            // 控制点：让轨迹弯起来更自然
            let c1 = CGPoint(x: start.x + dx * 0.20, y: start.y - up * 0.55)
            let c2 = CGPoint(x: start.x + dx * 0.55, y: start.y - up * 0.95)
            path.addCurve(to: mid, controlPoint1: c1, controlPoint2: c2)

            let c3 = CGPoint(x: mid.x + dx * 0.20, y: mid.y + up * 0.25)
            let c4 = CGPoint(x: end.x - dx * 0.10, y: end.y - down * 0.25)
            path.addCurve(to: end, controlPoint1: c3, controlPoint2: c4)

            // 让模型层先到终点，避免动画结束回跳
            p.position = end

            let move = CAKeyframeAnimation(keyPath: "position")
            move.path = path.cgPath
            move.duration = duration
            move.calculationMode = .cubic
            move.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            // 旋转 + 轻微缩放（碎裂更“脆”）
            let rotTo = CGFloat.random(in: config.rotate)
            let rot = CABasicAnimation(keyPath: "transform.rotation.z")
            rot.fromValue = 0
            rot.toValue = rotTo
            rot.duration = duration
            rot.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            // 轻微缩放：先略大（爆开）再回到 1
            let scale = CAKeyframeAnimation(keyPath: "transform.scale")
            scale.values = [1.0, 1.06, 1.0]
            scale.keyTimes = [0, 0.25, 1] as [NSNumber]
            scale.duration = duration
            scale.timingFunction = CAMediaTimingFunction(name: .easeOut)

            let group = CAAnimationGroup()
            group.animations = [move, rot, scale]
            group.duration = duration
            group.isRemovedOnCompletion = true

            p.add(group, forKey: "shatterMove")
        }

        // 3) 小碎点：瞬间出现 -> 上冲 -> 下落消失
        for d in dustLayers {
            let dx = CGFloat.random(in: -60...60)
            let up = CGFloat.random(in: 60...110)
            let down = CGFloat.random(in: 30...70)

            let start = center
            let mid = CGPoint(x: center.x + dx * 0.7, y: center.y - up)
            let end = CGPoint(x: center.x + dx, y: center.y + down)

            d.position = end

            let move = CAKeyframeAnimation(keyPath: "position")
            move.values = [start, mid, end]
            move.keyTimes = [0, 0.35, 1] as [NSNumber]
            move.duration = duration * 0.85
            move.timingFunctions = [
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .easeIn)
            ]

            let alpha = CAKeyframeAnimation(keyPath: "opacity")
            alpha.values = [0, 0.9, 0]
            alpha.keyTimes = [0, 0.15, 1] as [NSNumber]
            alpha.duration = duration * 0.85
            alpha.timingFunction = CAMediaTimingFunction(name: .easeOut)

            let g = CAAnimationGroup()
            g.animations = [move, alpha]
            g.duration = duration * 0.85
            g.isRemovedOnCompletion = true

            d.add(g, forKey: "dust")
        }

        CATransaction.commit()
    }

    // MARK: - Snapshot

    private func snapshot(of view: UIView) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: view.bounds.size, format: format)
        return renderer.image { ctx in
            // drawHierarchy 更接近真实渲染（含圆角/阴影等），比 layer.render 更像 UI
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
