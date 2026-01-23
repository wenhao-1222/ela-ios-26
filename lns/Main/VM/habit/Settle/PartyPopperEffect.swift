//
//  PartyPopperEffect.swift
//  lns
//
//  Created by LNS2 on 2026/1/23.
//

import UIKit

/// 🎉 手捧礼花棒 / 礼花筒彩带特效（CAEmitterLayer）
/// 一行调用：PartyPopperEffect.burst(in: view, at: point)
final class PartyPopperEffect: UIView {

    private let emitter = CAEmitterLayer()

    // MARK: - One-liner API

    /// 在指定父视图、指定位置爆发礼花彩带（默认彩带更多）
    @discardableResult
    static func burst(
        in parent: UIView,
        at point: CGPoint,
        duration: TimeInterval = 1.2,
        intensity: CGFloat = 1.0,
        colors: [UIColor] = [
            .THEME, .THEME, .THEME, .THEME,
            WHColor_16(colorStr: "F5C54B"),
            WHColor_16(colorStr: "F7E7CE"),
            WHColor_16(colorStr: "F1E2D3"),
            WHColor_16(colorStr: "E6C78F"),
            WHColor_16(colorStr: "d6d9de"),
            WHColor_16(colorStr: "d6d9de"),
            WHColor_16(colorStr: "FFA500")
        ]
//        colors: [UIColor] = [
//            .systemRed, .systemBlue, .systemGreen, .systemYellow,
//            .systemPurple, .systemPink, .systemOrange, .systemTeal
//        ]
    ) -> PartyPopperEffect {
        let v = PartyPopperEffect(frame: parent.bounds)
        v.isUserInteractionEnabled = false
        v.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        parent.addSubview(v)
        
        v.play(at: point, duration: duration, intensity: intensity, colors: colors)
        return v
    }

    // MARK: - Life cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        emitter.frame = bounds
        emitter.masksToBounds = false
        // ✅ 彻底禁止 CAEmitterLayer 关键属性的隐式动画
        emitter.actions = [
            "emitterPosition": NSNull(),
            "emitterSize": NSNull(),
            "emitterCells": NSNull(),
            "birthRate": NSNull(),
            "lifetime": NSNull(),
            "beginTime": NSNull(),
            "timeOffset": NSNull(),
            "position": NSNull(),
            "bounds": NSNull()
        ]
        layer.addSublayer(emitter)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Core
//    private func play(at point: CGPoint,
//                      duration: TimeInterval,
//                      intensity: CGFloat,
//                      colors: [UIColor]) {
//
//        // “手捧礼花棒”感觉：从一个点向上喷射、带一定散射角
//        emitter.emitterPosition = point
//        emitter.emitterShape = .point
//        emitter.emitterMode = .points
//        emitter.renderMode = .additive
//
//        // 彩带（短/长）+ 少量纸屑点
//        let ribbonShort = makeRibbonCells(colors: colors, long: false, intensity: intensity)
//        let ribbonLong  = makeRibbonCells(colors: colors, long: true, intensity: intensity * 0.75)
////        let confettiDot = makeDotCells(colors: colors, intensity: intensity * 0.35)
//
//        emitter.emitterCells = ribbonShort + ribbonLong //+ confettiDot
//        emitter.birthRate = 1
//
//        // 先爆发一段，再停止发射，剩余粒子自然落下
//        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
//            guard let self else { return }
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//            self.emitter.birthRate = 0
//            self.emitter.emitterCells?.forEach { $0.birthRate = 0 }
//            CATransaction.commit()
//        }
//
//        // 根据粒子生命周期移除自身
//        let maxLife: TimeInterval = 2.6
//        DispatchQueue.main.asyncAfter(deadline: .now() + duration + maxLife) { [weak self] in
//            self?.removeFromSuperview()
//        }
//    }
    
    private func play(at point: CGPoint,
                      duration: TimeInterval,
                      intensity: CGFloat,
                      colors: [UIColor]) {

        // point 本来就是 parent(=superview) 坐标系里的点，这里转到自己坐标系
        let localPoint = point//convert(point, from: superview)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        emitter.frame = bounds
        emitter.masksToBounds = false

        emitter.emitterPosition = localPoint
        emitter.emitterSize = CGSize(width: 1, height: 1)   // ✅ 比 .zero 更稳
        emitter.emitterShape = .point
        emitter.emitterMode = .points
        emitter.renderMode = .additive

        let ribbonShort = makeRibbonCells(colors: colors, long: false, intensity: intensity)
        let ribbonLong  = makeRibbonCells(colors: colors, long: true, intensity: intensity * 0.75)

        emitter.emitterCells = ribbonShort + ribbonLong
        emitter.birthRate = 1

        CATransaction.commit()

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.emitter.birthRate = 0
            CATransaction.commit()
        }

        let maxLife: TimeInterval = 2.6
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + maxLife) { [weak self] in
            self?.removeFromSuperview()
        }
    }

    // MARK: - Particle builders
    private func makeRibbonCells(colors: [UIColor], long: Bool, intensity: CGFloat) -> [CAEmitterCell] {
        let size = long ? CGSize(width: 22, height: 8) : CGSize(width: 15, height: 5)
        let birth = (long ? 55.0 : 105.0) * Double(intensity) // 彩带更多

        return colors.map { color in
            let cell = CAEmitterCell()
            cell.contents = makeRectImage(color: color, size: size).cgImage

            cell.birthRate = Float(birth / Double(colors.count))

            // ✅ 寿命更长：保证“上升→下落”完整
            cell.lifetime = long ? 2.8 : 2.5
            cell.lifetimeRange = 0.7

            // ✅ 更像“礼花棒向上喷”：更集中向上
            cell.emissionLongitude = -.pi / 2
            cell.emissionRange = .pi / 5   // 原来更散，这里收窄

            // ✅ 初速度更大：喷得更高
            cell.velocity = long ? 620 : 500
            cell.velocityRange = 160

            // ✅ 重力稍微小一点：先飞高再落下更自然
            cell.yAcceleration = 620
            cell.xAcceleration = 0

            // 旋转/翻滚像彩带
            cell.spin = long ? 3.6 : 4.6
            cell.spinRange = 7.0

            // 缩放/消失
            cell.scale = long ? 0.95 : 0.9
            cell.scaleRange = 0.4
            cell.scaleSpeed = -0.10

//            cell.alphaRange = 0.15
//            cell.alphaSpeed = -0.38
            return cell
        }
    }

    private func makeDotCells(colors: [UIColor], intensity: CGFloat) -> [CAEmitterCell] {
        let birth = 32.0 * Double(intensity)

        return colors.map { color in
            let cell = CAEmitterCell()
            cell.contents = makeCircleImage(color: color, diameter: 6).cgImage

            cell.birthRate = Float(birth / Double(colors.count))

            // ✅ 点状纸屑也拉长寿命，保证抛物线完整
            cell.lifetime = 2.2
            cell.lifetimeRange = 0.6

            cell.emissionLongitude = -.pi / 2
            cell.emissionRange = .pi / 4.8 // 更集中向上

            // ✅ 更高
            cell.velocity = 440
            cell.velocityRange = 170
            cell.yAcceleration = 460

            cell.spin = 2.4
            cell.spinRange = 6.0

            cell.scale = 0.85
            cell.scaleRange = 0.55
//            cell.alphaSpeed = -0.45

            return cell
        }
    }

    // MARK: - Image generators (no assets needed)

    private func makeRectImage(color: UIColor, size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func makeCircleImage(color: UIColor, diameter: CGFloat) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            color.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
}
