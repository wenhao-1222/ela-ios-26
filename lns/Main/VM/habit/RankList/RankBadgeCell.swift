//
//  RankBadgeCell.swift
//  lns
//
//  Created by LNS2 on 2026/1/4.
//

import UIKit
import QuartzCore

final class RankBadgeCell: UICollectionViewCell {

    private let badgeImageView = UIImageView()
    private let lockOverlay = UIImageView()

    private var tier: RankTier?
    private var isLockedNow: Bool = false

    private var confettiEmitter: CAEmitterLayer?
    private var sparkleLayers: [CAShapeLayer] = []
    private var glowLayer: CALayer?
    private var warningMarks: CAShapeLayer?

    private var hapticLink: CADisplayLink?
    private var pendingHapticTimes: [CFTimeInterval] = []

    private var countNum = 5
    // ✅ 宝石碎片 layers（固定在地上直到 cell 移出/复用）
    private var shardLayers: [CALayer] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.backgroundColor = .clear

        badgeImageView.contentMode = .scaleAspectFit
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(badgeImageView)

        NSLayoutConstraint.activate([
            badgeImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            badgeImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            badgeImageView.heightAnchor.constraint(equalTo: badgeImageView.widthAnchor)
        ])

        badgeImageView.layer.shadowOpacity = 0.28
        badgeImageView.layer.shadowRadius = 14
        badgeImageView.layer.shadowOffset = .zero

        lockOverlay.translatesAutoresizingMaskIntoConstraints = false
        lockOverlay.contentMode = .scaleAspectFit
        lockOverlay.image = EffectsFactory.lockIcon(size: 44)
        lockOverlay.alpha = 0.0
        contentView.addSubview(lockOverlay)

        NSLayoutConstraint.activate([
            lockOverlay.centerXAnchor.constraint(equalTo: badgeImageView.centerXAnchor),
            lockOverlay.centerYAnchor.constraint(equalTo: badgeImageView.centerYAnchor),
            lockOverlay.widthAnchor.constraint(equalToConstant: 44),
            lockOverlay.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cleanupEffects()
        badgeImageView.alpha = 1
        badgeImageView.transform = .identity
        badgeImageView.layer.transform = CATransform3DIdentity
        lockOverlay.transform = .identity
        lockOverlay.alpha = 0
        badgeImageView.isHidden = false
        lockOverlay.isHidden = false
    }

    func configure(tier: RankTier) {
        self.tier = tier
        badgeImageView.image = tier.image ?? EffectsFactory.placeholderBadge(size: 260)
        badgeImageView.layer.shadowColor = tier.accent.cgColor
    }

    func setLockedState(isLocked: Bool) {
        guard let tier else { return }
        isLockedNow = isLocked
        if isLocked {
            badgeImageView.image = EffectsFactory.grayLockedImage(from: tier.image ?? EffectsFactory.placeholderBadge(size: 260))
            lockOverlay.alpha = 1.0
        } else {
            badgeImageView.image = tier.image ?? EffectsFactory.placeholderBadge(size: 260)
            lockOverlay.alpha = 0.0
        }
        if shardLayers.isEmpty {
            badgeImageView.isHidden = false
            lockOverlay.isHidden = false
        }

//        badgeImageView.isHidden = false
//        lockOverlay.isHidden = false
    }
    // MARK: - Presentation

    func applyBadgeScale(_ scale: CGFloat, alpha: CGFloat) {
        contentView.alpha = 1.0
        let t = CGAffineTransform(scaleX: scale, y: scale)
        badgeImageView.transform = t
        badgeImageView.alpha = alpha
        lockOverlay.transform = t
    }

    func applySuppressedState() {
        contentView.alpha = 0.0
    }

    // MARK: - ✅ 晋升：落位后做“解锁+庆祝”（翻转在 carousel overlay 里做）
    func playPromoteUnlockAfterEntrance() {
        guard let tier else { return }

        // 蓝色轮廓 + 星星
        playGlowOutline(color: UIColor(red: 0.58, green: 0.90, blue: 0.96, alpha: 1.0))
//        playSparkles(color: UIColor(red: 0.58, green: 0.90, blue: 0.96, alpha: 1.0))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            self.lockOverlay.alpha = 0.0
            self.badgeImageView.image = tier.image ?? EffectsFactory.placeholderBadge(size: 260)

            self.badgeImageView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            UIView.animate(withDuration: 0.62,
                           delay: 0,
                           usingSpringWithDamping: 0.46,
                           initialSpringVelocity: 0.9,
                           options: [.curveEaseOut]) {
                self.badgeImageView.transform = .identity
            }

            self.playConfetti(accent: tier.accent)

            let h = UIImpactFeedbackGenerator(style: .heavy)
            h.prepare()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { h.impactOccurred() }
        }
    }

    // MARK: - ✅ 降级：沮丧（紧张符号+抖动）→ 宝石崩裂碎一地并固定 → completion 让外部开始滑动移出

    func playDemoteGemShatterToFloorThenMoveOut(completion: @escaping () -> Void) {
        cleanupEffects()

        playWarningMarks()
        playSadWobble()
        // 崩碎后只保留碎片
//        badgeImageView.isHidden = true
//        lockOverlay.isHidden = true

        // 先短暂停一下再碎（更像视频节奏）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            let dur: TimeInterval = 0.78
            self.shatterBadgeImageToFloor(duration: dur)
            let maxStagger = Double(max(self.shardLayers.count - 1, 0)) * 0.002
            DispatchQueue.main.asyncAfter(deadline: .now() + dur + maxStagger - 0.06) {
                completion()
            }
        }

        let h = UINotificationFeedbackGenerator()
        h.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { h.notificationOccurred(.error) }
    }

    func playDemoteArriveSad() {
        cleanupEffects()
        badgeImageView.isHidden = false
        lockOverlay.isHidden = false
        badgeImageView.alpha = 0
        badgeImageView.transform = CGAffineTransform(translationX: 0, y: 10).scaledBy(x: 0.98, y: 0.98)
        UIView.animate(withDuration: 0.30, delay: 0.02, options: [.curveEaseOut]) {
            self.badgeImageView.alpha = 1
            self.badgeImageView.transform = .identity
        }
    }

    // MARK: - 宝石崩裂核心

    private func shatterBadgeImageToFloor(duration: TimeInterval) {
        guard let image = badgeImageView.image else { return }

        // 崩碎后碎片变灰
        let grayImage = EffectsFactory.grayLockedImage(from: image)

//        badgeImageView.alpha = 0.0
//        lockOverlay.alpha = 0.0
        badgeImageView.alpha = 1.0
        lockOverlay.alpha = 1.0


        contentView.layoutIfNeeded()
        let badgeRect = badgeImageView.convert(badgeImageView.bounds, to: contentView)

        // ✅ grid 越大碎片越细：10 很接近“碎一地”
        let shards = EffectsFactory.makeGemImageShards(
            image: grayImage,
            in: badgeRect,
            grid: 6,
            contentScale: UIScreen.main.scale
        )
        shardLayers = shards
        shards.forEach { contentView.layer.addSublayer($0) }
        // 起始保持完整徽章视觉，碎片在“碎裂”瞬间才出现
        shards.forEach { $0.opacity = 0.0 }
        UIView.animate(withDuration: 0.12) {
            self.badgeImageView.alpha = 0.0
            self.lockOverlay.alpha = 0.0
            shards.forEach { $0.opacity = 1.0 }
        }
        // 地面基准（不要同一水平线：做随机堆叠）
//        let floorBaseY = contentView.bounds.maxY - (contentView.bounds.height * 0.12)
        let maxSpreadX = contentView.bounds.width * 0.95
        let maxDrop = max(contentView.bounds.height * 0.75, 140)
        let totalShatterDuration = duration + Double(max(shards.count - 1, 0)) * 0.002

        for (i, shard) in shards.enumerated() {
            let start = shard.position

//            // 横向散开
//            let dx = CGFloat.random(in: -92...92)
//            // 纵向下坠距离
//            let dy = CGFloat.random(in: 120...240)
            let dx = CGFloat.random(in: -maxSpreadX...maxSpreadX) * 0.35
            let dy = CGFloat.random(in: 120...maxDrop)

            // 每片落地高度不一致，形成“堆”
//            let floorJitter = CGFloat.random(in: -12...22)
//            let rollDown = min(16, abs(dx) * 0.06)
//            let targetFloorY = floorBaseY + floorJitter + rollDown
            // 不同碎片停在不同高度，形成“散落”效果
            let extraDepth = CGFloat.random(in: -66...100)

            let finalX = start.x + dx
//            let rawFinalY = min(targetFloorY, start.y + dy)
//            let clampedFinalY = min(rawFinalY, contentView.bounds.maxY - 6)
            let rawFinalY = start.y + dy + extraDepth
            let clampedFinalY = min(max(rawFinalY, contentView.bounds.minY + 40), contentView.bounds.maxY - 8)

            // 轻微反弹
            let bounce = CGFloat.random(in: 10...24)

            // 旋转
            let rot = CGFloat.random(in: -2.0...2.0)
            let rot2 = rot * 0.35

            // 阴影更像落地
            shard.shadowOpacity = 0.18
            shard.shadowRadius = 6
            shard.shadowOffset = CGSize(width: 0, height: 4)
            shard.zPosition = CGFloat(200 + i)

            let p1 = CGPoint(x: start.x + dx * 0.75, y: start.y + dy * 0.75)
            let p2 = CGPoint(x: finalX, y: max(0, clampedFinalY - bounce))
            let p3 = CGPoint(x: finalX, y: clampedFinalY)

            let positionAnim = CAKeyframeAnimation(keyPath: "position")
            positionAnim.values = [start, p1, p2, p3].map { NSValue(cgPoint: $0) }
            positionAnim.keyTimes = [0.0, 0.62, 0.86, 1.0] as [NSNumber]
            positionAnim.timingFunctions = [
                CAMediaTimingFunction(name: .easeIn),
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .easeInEaseOut)
            ]
            positionAnim.duration = duration

            let rotateAnim = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            rotateAnim.values = [0, rot, rot2]
            rotateAnim.keyTimes = [0.0, 0.72, 1.0] as [NSNumber]
            rotateAnim.timingFunctions = [
                CAMediaTimingFunction(name: .easeInEaseOut),
                CAMediaTimingFunction(name: .easeInEaseOut)
            ]
            rotateAnim.duration = duration

            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = 1.0
            scaleAnim.toValue = 0.98
            scaleAnim.duration = duration
            scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            let group = CAAnimationGroup()
            group.animations = [positionAnim, rotateAnim, scaleAnim]
            group.duration = duration
            group.beginTime = CACurrentMediaTime() + Double(i) * 0.002
            group.fillMode = .forwards
            group.isRemovedOnCompletion = false

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                // 动画结束瞬间：把 model layer 固定到终点，并且不允许隐式动画
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                shard.position = p3
                shard.setAffineTransform(CGAffineTransform(rotationAngle: rot2).scaledBy(x: 0.98, y: 0.98))
                CATransaction.commit()

                shard.removeAnimation(forKey: "gemShatterToFloor")
            }
            shard.add(group, forKey: "gemShatterToFloor")
            CATransaction.commit()

//            group.isRemovedOnCompletion = true
//            shard.add(group, forKey: "gemShatterToFloor")
//
//            // ✅ 关键：动画完把 model layer 固定在最终位置（碎一地停住）
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.002 + duration) {
//                shard.position = p3
//                shard.setAffineTransform(CGAffineTransform(rotationAngle: rot2).scaledBy(x: 0.98, y: 0.98))
//                shard.removeAllAnimations()
//            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + totalShatterDuration) { [weak self] in
            self?.badgeImageView.isHidden = true
            self?.lockOverlay.isHidden = true
        }
    }

    // MARK: - Effects helpers

    private func playGlowOutline(color: UIColor) {
        guard let img = badgeImageView.image else { return }
        let g = CALayer()
        g.frame = badgeImageView.bounds
        g.contents = img.cgImage
        g.contentsGravity = .resizeAspect
        g.contentsScale = UIScreen.main.scale
        g.opacity = 0.0
        g.shadowColor = color.cgColor
        g.shadowRadius = 22
        g.shadowOpacity = 1.0
        g.shadowOffset = .zero
        badgeImageView.layer.addSublayer(g)
        glowLayer = g

        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = 0.14
        fadeIn.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.0
        scale.toValue = 1.06
        scale.duration = 0.28
        scale.autoreverses = true
        scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1.0
        fadeOut.toValue = 0.0
        fadeOut.beginTime = 0.24
        fadeOut.duration = 0.16
        fadeOut.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let group = CAAnimationGroup()
        group.animations = [fadeIn, scale, fadeOut]
        group.duration = 0.40
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        g.add(group, forKey: "glow")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) { g.removeFromSuperlayer() }
    }

    private func playSparkles(color: UIColor) {
        let points: [CGPoint] = [
            CGPoint(x: 0.18, y: 0.20),
            CGPoint(x: 0.82, y: 0.22),
            CGPoint(x: 0.86, y: 0.56),
            CGPoint(x: 0.22, y: 0.64),
        ]
        sparkleLayers.removeAll()

        for (i, p) in points.enumerated() {
            let s = CAShapeLayer()
            s.frame = badgeImageView.bounds
            s.strokeColor = color.cgColor
            s.lineWidth = 3.0
            s.lineCap = .round
            s.opacity = 0.0

            let cx = badgeImageView.bounds.width * p.x
            let cy = badgeImageView.bounds.height * p.y
            let len: CGFloat = 14

            let path = UIBezierPath()
            path.move(to: CGPoint(x: cx - len, y: cy))
            path.addLine(to: CGPoint(x: cx + len, y: cy))
            path.move(to: CGPoint(x: cx, y: cy - len))
            path.addLine(to: CGPoint(x: cx, y: cy + len))
            s.path = path.cgPath

            badgeImageView.layer.addSublayer(s)
            sparkleLayers.append(s)

            let delay = Double(i) * 0.04
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0.0
            fade.toValue = 1.0
            fade.duration = 0.10
            fade.beginTime = delay
            fade.autoreverses = true
            fade.timingFunction = CAMediaTimingFunction(name: .easeOut)
            fade.repeatCount = 2
            fade.isRemovedOnCompletion = true
            s.add(fade, forKey: "spark")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.sparkleLayers.forEach { $0.removeFromSuperlayer() }
            self?.sparkleLayers.removeAll()
        }
    }
//    private func playConfetti(accent: UIColor) {
//
//        confettiEmitter?.removeFromSuperlayer()
//        confettiEmitter = nil
//
//        // ====== 参数：连炸 ======
//        let booms = 5
//
//        /// “快结束”的提前量：越小=越贴近结束才喷；越大=更早喷
//        /// 建议 0.20~0.35 之间微调
//        let lead: CFTimeInterval = 0.25
//
//
//        let onTime: CFTimeInterval = 0.05
//        let particleLife: CFTimeInterval = 1.35
//        
//        /// 每次（除了第一次）都在上次快结束时喷：step = particleLife - lead
//        let step: CFTimeInterval = max(0.05, particleLife - lead)
//        /// 5 次井喷的起始时间点
//        let boomStarts: [CFTimeInterval] = (0..<booms).map { CFTimeInterval($0) * step }
//
//        // ====== 爆点：徽章正中偏下（固定同一点）======
//        contentView.layoutIfNeeded()
//        let badgeFrame = badgeImageView.frame
//        let origin = CGPoint(
//            x: badgeFrame.midX,
//            y: badgeFrame.midY + badgeFrame.height * 0.18
//        )
//
//        let emitter = CAEmitterLayer()
//        emitter.emitterPosition = origin
//        emitter.emitterShape = .point
//        emitter.emitterMode = .outline
//        emitter.renderMode = .additive
//        emitter.beginTime = CACurrentMediaTime()
//        emitter.birthRate = 0
//
//        let dotCG = makeFireworkDotImage(size: 18).cgImage
//        let streakCG = makeFireworkStreakImage(size: CGSize(width: 18, height: 6)).cgImage
//
//        let colors: [UIColor] = [
//            UIColor(red: 0.15, green: 0.75, blue: 1.0, alpha: 1),
//            UIColor(red: 0.98, green: 0.78, blue: 0.22, alpha: 1),
//            UIColor(red: 0.98, green: 0.38, blue: 0.63, alpha: 1),
//            UIColor(red: 0.70, green: 0.42, blue: 0.98, alpha: 1),
//            UIColor(red: 0.35, green: 0.95, blue: 0.62, alpha: 1),
//            accent
//        ]
//
//        // ✅ 向上喷更集中：扇形越小越“柱状向上”
//        let upwardCone: CGFloat = .pi / 1.8   // 更集中一些；想更集中改 .pi/6.8
//
//        // ✅ 为了“随机左右扰动”，我们做三种 xAcceleration：左/中/右
//        let xAccels: [(x: CGFloat, weight: Float)] = [
//            (x: -120, weight: 0.28),
//            (x:    0, weight: 0.44),
//            (x:  120, weight: 0.28),
//        ]
//        
//
//        // MARK: - 火花点（主）
//        func dotCell(color: UIColor, xAccel: CGFloat, weight: Float) -> CAEmitterCell {
//            let c = CAEmitterCell()
//            c.contents = dotCG
//            c.color = color.cgColor
//
//            c.birthRate = 80//620 * weight
//            c.lifetime = Float(particleLife)
//            c.lifetimeRange = 0.25
//
//            c.emissionLongitude = -.pi / 2
//            c.emissionRange = upwardCone
//
//            // ✅ 喷更高
//            c.velocity = 620
//            c.velocityRange = 240
//            c.yAcceleration = 1050
//
//            // ✅ 轻微左右漂移（用多 cell 混合实现“随机”）
//            c.xAcceleration = xAccel
//
//            c.spin = 2.6
//            c.spinRange = 6.0
//
//            c.scale = 0.24//0.16
//            c.scaleRange = 0.10
//            c.alphaSpeed = -1.10
//            return c
//        }
//
//        // MARK: - 短光条（辅助：更像“炸开的火花束”）
//        func streakCell(color: UIColor, xAccel: CGFloat, weight: Float) -> CAEmitterCell {
//            let c = CAEmitterCell()
//            c.contents = streakCG
//            c.color = color.withAlphaComponent(0.95).cgColor
//
//            c.birthRate = 80//320 * weight
//            c.lifetime = Float(particleLife * 0.95)
//            c.lifetimeRange = 0.18
//
//            c.emissionLongitude = -.pi / 2
//            c.emissionRange = upwardCone
//
//            c.velocity = 720
//            c.velocityRange = 260
//            c.yAcceleration = 1120
//
//            c.xAcceleration = xAccel
//
//            c.spin = 6.0
//            c.spinRange = 10.0
//
//            c.scale = 0.22
//            c.scaleRange = 0.14
//            c.alphaSpeed = -1.25
//            return c
//        }
//
//        var cells: [CAEmitterCell] = []
//        for col in colors {
//            for xa in xAccels {
//                cells.append(dotCell(color: col, xAccel: xa.x, weight: xa.weight))
//                cells.append(streakCell(color: col, xAccel: xa.x, weight: xa.weight))
//            }
//        }
//        emitter.emitterCells = cells
//
//        contentView.layer.addSublayer(emitter)
//        confettiEmitter = emitter
//
//        // ====== 4~5 次 boom 脉冲（birthRate 开关）======
//        let total: CFTimeInterval = (boomStarts.last ?? 0) + onTime + 0.06
//
//        var times: [NSNumber] = [0.0]
//        var values: [NSNumber] = [0.0]
//
//        for tOn in boomStarts {
//            let tOff = tOn + onTime
//
//            times.append(NSNumber(value: tOn / total))
//            values.append(1.0)
//
//            times.append(NSNumber(value: tOff / total))
//            values.append(0.0)
//        }
//
//        let pulse = CAKeyframeAnimation(keyPath: "birthRate")
//        pulse.values = values
//        pulse.keyTimes = times
//        pulse.duration = total
//        pulse.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .linear),
//                                      count: max(values.count - 1, 1))
//        pulse.isRemovedOnCompletion = true
//        emitter.add(pulse, forKey: "fireworkBoomPulse")
//
//        // ====== 触感：每一次 boom 都震一下 ======
////        let h = UIImpactFeedbackGenerator(style: .rigid)
////        h.prepare()
////        for tOn in boomStarts {
////            DispatchQueue.main.asyncAfter(deadline: .now() + tOn) {
////                h.impactOccurred(intensity: 1.0)
////                h.prepare()
////            }
////        }
//        scheduleBoomHaptics(boomStarts: boomStarts)
//
//
//        // 收尾移除
//        DispatchQueue.main.asyncAfter(deadline: .now() + total + particleLife + 0.2) { [weak self] in
//            self?.confettiEmitter?.removeFromSuperlayer()
//            self?.confettiEmitter = nil
//        }
//    }
//
//    // MARK: - 烟花素材（亮点 & 光条）
//    private func makeFireworkDotImage(size: CGFloat) -> UIImage {
//        let r = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
//        return r.image { ctx in
//            let rect = CGRect(x: 0, y: 0, width: size, height: size)
//            ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.12).cgColor)
//            ctx.cgContext.fillEllipse(in: rect)
//
//            let inner = rect.insetBy(dx: size * 0.30, dy: size * 0.30)
//            ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.98).cgColor)
//            ctx.cgContext.fillEllipse(in: inner)
//        }
//    }
//
//    private func makeFireworkStreakImage(size: CGSize) -> UIImage {
//        let r = UIGraphicsImageRenderer(size: size)
//        return r.image { ctx in
//            let rect = CGRect(origin: .zero, size: size)
//            let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.5)
//            ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.95).cgColor)
//            ctx.cgContext.addPath(path.cgPath)
//            ctx.cgContext.fillPath()
//
//            ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.25).cgColor)
//            ctx.cgContext.fill(CGRect(x: rect.minX + rect.width * 0.15,
//                                      y: rect.minY,
//                                      width: rect.width * 0.12,
//                                      height: rect.height))
//        }
//    }
//    private func scheduleBoomHaptics(boomStarts: [CFTimeInterval]) {
//        // 清理旧的
//        hapticLink?.invalidate()
//        hapticLink = nil
//        pendingHapticTimes.removeAll()
//
//        // ✅ 用 CoreAnimation 时间基准对齐
//        let start = CACurrentMediaTime()
//
//        // ✅ 触感提前一点点（抵消系统触感延迟）
//        let early: CFTimeInterval = 0.05
//
//        // 目标触发时刻（绝对时间）
//        pendingHapticTimes = boomStarts
//            .map { start + $0 - early }
//            .sorted()
//
//        let generator = UIImpactFeedbackGenerator(style: .rigid)
//        generator.prepare()
//
//        let link = CADisplayLink(target: BlockTarget { [weak self] in
//            guard let self else { return }
//            let now = CACurrentMediaTime()
//
//            // 可能一帧跨过多个点：用 while 连续触发
//            while let t = self.pendingHapticTimes.first, now >= t {
//                self.pendingHapticTimes.removeFirst()
//                generator.impactOccurred(intensity: 1.0)
//                generator.prepare()
//            }
//
//            if self.pendingHapticTimes.isEmpty {
//                self.hapticLink?.invalidate()
//                self.hapticLink = nil
//            }
//        }, selector: #selector(BlockTarget.tick))
//
//        link.add(to: .main, forMode: .common)
//        hapticLink = link
//    }
//
//    /// 小工具：用 block 驱动 CADisplayLink
//    private final class BlockTarget: NSObject {
//        private let block: () -> Void
//        init(_ block: @escaping () -> Void) { self.block = block }
//        @objc func tick() { block() }
//    }

//MARK: 之前的烟花动画
    private func playConfetti(accent: UIColor) {
        let emitter = CAEmitterLayer()
        //顶部喷射
//        emitter.emitterPosition = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.minY + 10)
        //改成底部喷射
        let badgeFrame = badgeImageView.frame
        emitter.emitterPosition = CGPoint(x: badgeFrame.midX, y: badgeFrame.midY + badgeFrame.height*0.25)
        //e.emissionRange 控制扇形范围（角度越大越散）
        emitter.emitterShape = .cuboid
        //emitter.emitterSize 控制发射宽度（越大越“横向铺开”）。
        emitter.emitterSize = CGSize(width: contentView.bounds.width * 0.9, height: 1)
        emitter.renderMode = .additive

        let colors: [UIColor] = [
            UIColor(red: 0.15, green: 0.75, blue: 1.0, alpha: 1),
            UIColor(red: 0.98, green: 0.78, blue: 0.22, alpha: 1),
            UIColor(red: 0.98, green: 0.38, blue: 0.63, alpha: 1),
            UIColor(red: 0.70, green: 0.42, blue: 0.98, alpha: 1),
            accent
        ]

        func cell(_ c: UIColor) -> CAEmitterCell {
            let e = CAEmitterCell()
            let tilt = CGFloat.random(in: -0.55...0.55)
            let spinBase = CGFloat.random(in: -8.0...8.0)
            e.birthRate = 4//粒子数量   数值越大，粒子越多
            e.lifetime = 1.05
            e.lifetimeRange = 0.22
            e.velocity = 420//基础速度
            e.velocityRange = 120//速度随机范围
            e.yAcceleration = 500//向下的重力，越大下落越快
            //向下喷射
//            e.emissionLongitude = .pi
            //改成向上喷射
            e.emissionLongitude = -.pi/2
            e.emissionRange = .pi / 4
//            e.spin = 5
//            e.spinRange = 6
//            e.emissionLatitude = tilt
            e.spin = spinBase
            e.spinRange = abs(spinBase) * 0.8//spinBase * 1.4
            e.alphaSpeed = -0.9
            //----------   以下三个参数  修改粒子大小
            e.scale = 0.24//0.055
            e.scaleRange = 0.03//0.03
            e.contents = EffectsFactory.confettiSquare(size: 28).cgImage//EffectsFactory.confettiSquare(size: 22).cgImage
            //----------
            e.color = c.cgColor
            return e
        }

        emitter.emitterCells = colors.map(cell)
        contentView.layer.addSublayer(emitter)
        confettiEmitter = emitter

        //0.18秒后，烟花粒子消失
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.88) {
            emitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            emitter.removeFromSuperlayer()
            self.countNum -= 1
            if self.countNum > 0 {
                self.playConfetti(accent: accent)
            }else{
                self.countNum = 5
            }
        }
    }

    private func playWarningMarks() {
        let s = CAShapeLayer()
        s.frame = badgeImageView.bounds
        s.strokeColor = UIColor.black.withAlphaComponent(0.35).cgColor
        s.lineWidth = 3
        s.lineCap = .round
        s.fillColor = UIColor.clear.cgColor

        let w = badgeImageView.bounds.width
        let h = badgeImageView.bounds.height
        let p = UIBezierPath()
        p.move(to: CGPoint(x: w*0.78, y: h*0.22))
        p.addLine(to: CGPoint(x: w*0.83, y: h*0.18))
        p.move(to: CGPoint(x: w*0.83, y: h*0.26))
        p.addLine(to: CGPoint(x: w*0.87, y: h*0.23))
        s.path = p.cgPath
        s.opacity = 0.0
        badgeImageView.layer.addSublayer(s)
        warningMarks = s

        let a = CABasicAnimation(keyPath: "opacity")
        a.fromValue = 0
        a.toValue = 1
        a.duration = 0.08
        a.autoreverses = true
        a.repeatCount = 2
        a.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        s.add(a, forKey: "warn")
    }

    private func playSadWobble() {
        let anim = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        anim.values = [0, -0.06, 0.05, -0.03, 0]
        anim.keyTimes = [0, 0.25, 0.55, 0.78, 1]
        anim.duration = 0.20
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        badgeImageView.layer.add(anim, forKey: "wobble")
    }

    private func cleanupEffects() {
        confettiEmitter?.removeFromSuperlayer()
        confettiEmitter = nil

        sparkleLayers.forEach { $0.removeFromSuperlayer() }
        sparkleLayers.removeAll()

        glowLayer?.removeFromSuperlayer()
        glowLayer = nil

        warningMarks?.removeFromSuperlayer()
        warningMarks = nil

        shardLayers.forEach { $0.removeFromSuperlayer() }
        shardLayers.removeAll()
        hapticLink?.invalidate()
        hapticLink = nil
        pendingHapticTimes.removeAll()

    }
}
