//
//  RankDownShatterView.swift
//  lns
//
//  Created by LNS2 on 2026/1/22.
//

import UIKit

/// 段位降低碎裂（可整体移动）
/// ✅ 优化：碎裂不向上，上来就“原地崩裂”+ 重力向下随机掉落（无上抛）
/// 一行调用：RankDownShatterView.play(on: target, in: parent)
final class RankDownShatterView: UIView {

    struct Config {
        var grid: (cols: Int, rows: Int) = (4, 4)
        var maxPieceCount: Int = 10
        var duration: TimeInterval = 0.55

        /// 原地崩裂的水平散射（小一点更“原地”）
        var burstX: ClosedRange<CGFloat> = -22...22

        /// 下落距离（重力掉落的随机范围）
        var fallDown: ClosedRange<CGFloat> = 70...120

        /// 旋转强度（弧度）
        var rotate: ClosedRange<CGFloat> = (-0.9)...(0.9)

        /// 底部保留几行不碎裂（更像“底座”）
        var keepBaseRows: Int = 1

        var cornerRadius: CGFloat = 6
        var fadeNonShatterPieces: Bool = true

        /// 原地崩裂“抖一下”的强度
        var popJitter: CGFloat = 6.0

        /// 下落的缓动曲线（重力感：先慢后快）
        var fallTiming: CAMediaTimingFunctionName = .easeIn
        /// 3D 翻转范围（弧度）——越大越“翻”
        var rotateX: ClosedRange<CGFloat> = (-0.55)...(0.55)
        var rotateY: ClosedRange<CGFloat> = (-0.55)...(0.55)

    }

    // MARK: - API

    /// ✅ 一行创建并在原位播放碎裂
    /// - 返回：碎裂容器 view（后续可整体移动）
    @discardableResult
    static func play(on targetView: UIView,
                     in superview: UIView,
                     config: Config = Config(),
                     completion: (() -> Void)? = nil) -> RankDownShatterView {

        superview.layoutIfNeeded()

        let targetFrame = superview.convert(targetView.bounds, from: targetView)
        let snap = snapshot(of: targetView)

        let v = RankDownShatterView(frame: targetFrame)
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        superview.addSubview(v)

        // 目标先隐藏（碎裂替代显示）
        targetView.alpha = 0

        v.buildPieces(image: snap, config: config)
        v.animateShatter(config: config) {
            completion?()
        }

        return v
    }

    /// ✅ 碎裂完成后整体移动（含缩放）
    func moveWhole(toCenterX: CGFloat,
                   scale: CGFloat,
                   duration: TimeInterval,
                   completion: (() -> Void)? = nil) {

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.center.x = toCenterX
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            completion?()
        }
    }

    // MARK: - Internals

    private var pieceLayers: [CALayer] = []
    private var baseLayers: [CALayer] = []

    private func buildPieces(image: UIImage, config: Config) {
        let cols = max(2, config.grid.cols)
        let rows = max(2, config.grid.rows)

        let pieceW = bounds.width / CGFloat(cols)
        let pieceH = bounds.height / CGFloat(rows)

        let keepBaseRows = max(0, min(rows, config.keepBaseRows))
        let baseRowStart = rows - keepBaseRows

        var candidates: [(c: Int, r: Int)] = []
        for r in 0..<rows {
            for c in 0..<cols {
                if r < baseRowStart { candidates.append((c, r)) }
            }
        }

        candidates.shuffle()
        let pieceCount = min(config.maxPieceCount, candidates.count)
        let shatterSet = Set(candidates.prefix(pieceCount).map { "\($0.c)-\($0.r)" })

        for r in 0..<rows {
            for c in 0..<cols {

                let rect = CGRect(x: CGFloat(c) * pieceW,
                                  y: CGFloat(r) * pieceH,
                                  width: pieceW,
                                  height: pieceH)

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

                layer.shadowColor = UIColor.black.withAlphaComponent(0.22).cgColor
                layer.shadowOpacity = 1
                layer.shadowRadius = 5
                layer.shadowOffset = CGSize(width: 0, height: 2)

                self.layer.addSublayer(layer)

                let key = "\(c)-\(r)"
                if r >= baseRowStart {
                    baseLayers.append(layer)
                } else if shatterSet.contains(key) {
                    pieceLayers.append(layer)
                } else if config.fadeNonShatterPieces {
                    layer.opacity = 0
                }
            }
        }
    }
    /// ✅ 核心：不向上，仅原地崩裂 + 下落
    /// ✅ 最终不回正：把最终 position / transform 写进 model layer
    /// ✅ 立体：m34 透视 + 3D 翻转（X/Y/Z）
    private func animateShatter(config: Config, completion: @escaping () -> Void) {

        // ✅ 透视：让 3D 翻转有深度感（600~900 更自然）
        var t = CATransform3DIdentity
        t.m34 = -1.0 / 600.0
        layer.sublayerTransform = t

        let duration = config.duration

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        // 1) 底座轻微抖一下
        for b in baseLayers {
            let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shake.values = [0, -2.5, 1.8, -1.0, 0]
            shake.keyTimes = [0, 0.25, 0.5, 0.75, 1] as [NSNumber]
            shake.duration = 0.22
            shake.timingFunction = CAMediaTimingFunction(name: .easeOut)
            b.add(shake, forKey: "baseShake")
        }

        // 2) 碎片：原地崩裂 -> 只向下掉落（无上抛）-> 最终保持姿态
        for p in pieceLayers {

            let startPos = CGPoint(x: p.frame.midX, y: p.frame.midY)

            let dx = CGFloat.random(in: config.burstX)
            let dy = CGFloat.random(in: config.fallDown)

            // ✅ 立体旋转：Z + X/Y 翻转
            let rz = CGFloat.random(in: config.rotate)
            let rx = CGFloat.random(in: config.rotateX)
            let ry = CGFloat.random(in: config.rotateY)

            let endPos = CGPoint(x: startPos.x + dx, y: startPos.y + dy)

            // ✅ 把最终状态写进 model layer：结束不会回跳/回正
            p.position = endPos

            var finalT = CATransform3DIdentity
            finalT = CATransform3DRotate(finalT, rx, 1, 0, 0)
            finalT = CATransform3DRotate(finalT, ry, 0, 1, 0)
            finalT = CATransform3DRotate(finalT, rz, 0, 0, 1)
            p.transform = finalT

            // (A) 原地崩裂 pop：只在原地附近抖动/微散开（不向上）
            let j = config.popJitter * CGFloat.random(in: 0.7...1.25)

            let popEnd = CGPoint(
                x: startPos.x + dx * 0.45,
                y: startPos.y + CGFloat.random(in: -2...6)
            )

            let pop = CAKeyframeAnimation(keyPath: "position")
            pop.values = [
                startPos,
                CGPoint(
                    x: startPos.x + dx * 0.25 + CGFloat.random(in: -j...j),
                    y: startPos.y + CGFloat.random(in: -j...j)
                ),
                popEnd
            ]
            pop.keyTimes = [0, 0.6, 1] as [NSNumber]
            pop.duration = duration * 0.22
            pop.timingFunction = CAMediaTimingFunction(name: .easeOut)

            // (B) fall：从 popEnd 开始直接向下掉到 endPos（重力：先慢后快）
            let fall = CABasicAnimation(keyPath: "position")
            fall.fromValue = popEnd
            fall.toValue = endPos
            fall.beginTime = pop.duration
            fall.duration = max(0.01, duration - pop.duration)
            fall.timingFunction = CAMediaTimingFunction(name: config.fallTiming)

            // (C) 3D 旋转：从 identity -> finalT（结束不回正，因为 model 已经 finalT）
            let rot3D = CABasicAnimation(keyPath: "transform")
            rot3D.fromValue = CATransform3DIdentity
            rot3D.toValue = finalT
            rot3D.duration = duration
            rot3D.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            // (D) 轻微缩放：崩裂瞬间撑开一点，再回到 1（不影响最终旋转）
            let scale = CAKeyframeAnimation(keyPath: "transform.scale")
            scale.values = [1.0, 1.06, 1.0]
            scale.keyTimes = [0, 0.18, 1] as [NSNumber]
            scale.duration = duration
            scale.timingFunction = CAMediaTimingFunction(name: .easeOut)

            // (E) 组合
            let group = CAAnimationGroup()
            group.animations = [pop, fall, rot3D, scale]
            group.duration = duration
            group.isRemovedOnCompletion = true

            p.add(group, forKey: "shatterFallOnly_3D")
        }

        CATransaction.commit()
    }


    private static func snapshot(of view: UIView) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size, format: format)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
