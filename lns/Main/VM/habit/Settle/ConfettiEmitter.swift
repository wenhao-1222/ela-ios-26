//
//  ConfettiEmitter.swift
//  lns
//
//  Created by LNS2 on 2026/1/23.
//

import UIKit

final class ConfettiEmitter {

    // MARK: - Public Config

    /// 彩带颜色
    var colors: [UIColor] = [
        .systemRed,
        .systemBlue,
        .systemGreen,
        .systemYellow,
        .systemPink
    ]

    /// 每秒产生的彩带数量
    var confettiPerSecond: Float = 60

    /// 彩带生命周期（必须足够长，保证出屏幕后消失）
    var lifetime: Float = 5.0

    /// 重力加速度（越大下落越快）
    var gravity: CGFloat = 560

    /// 喷射角度范围
    var emissionRange: CGFloat = .pi / 10

    // MARK: - Private

    private let emitterLayer = CAEmitterLayer()
    private weak var containerView: UIView?
    private var hasStarted = false   // ⭐️ 关键状态

    // MARK: - Init

    init(in view: UIView, emitPoint: CGPoint) {
        self.containerView = view
        setupEmitter(at: emitPoint)
    }

    // MARK: - Setup

    private func setupEmitter(at point: CGPoint) {
        emitterLayer.emitterPosition = point
        emitterLayer.emitterShape = .point
        emitterLayer.emitterSize = .zero
        emitterLayer.emitterMode = .outline
        // ⛔️ 初始暂停，防止“偷跑”
        emitterLayer.birthRate = 0
        emitterLayer.speed = 1   // ✅ 明确确保没被 pause

        containerView?.layer.addSublayer(emitterLayer)
    }
    func startEmission(at point: CGPoint) {
        // ⭐️ 关键：强制同步 emitterPosition
        CATransaction.begin()
        CATransaction.setDisableActions(true) // ⛔️ 禁止隐式动画
        emitterLayer.emitterPosition = point
        CATransaction.commit()

        if !hasStarted {
            emitterLayer.emitterCells = makeCells()

            let now = emitterLayer.convertTime(CACurrentMediaTime(), from: nil)
            emitterLayer.beginTime = now
            emitterLayer.timeOffset = 0

            hasStarted = true
        }

        emitterLayer.birthRate = 1
    }
    /// 停止喷射（不再产生新彩带，但已有的继续运动）
    func stopEmission() {
        emitterLayer.birthRate = 0
    }

    /// 完整结束并移除（等彩带自然出屏幕后调用）
    func finishAndRemove() {
        let delay = TimeInterval(lifetime + 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.emitterLayer.removeFromSuperlayer()
        }
    }

    // MARK: - Cell Factory

    private func makeCells() -> [CAEmitterCell] {
        let perColorRate = confettiPerSecond / Float(colors.count)

        return colors.map { color in
            let cell = CAEmitterCell()

            // 产生速率
            cell.birthRate = perColorRate

            // 生命周期（关键）
            cell.lifetime = lifetime
            cell.lifetimeRange = 1

            // 初始速度（向上抛）
            cell.velocity = 700
            cell.velocityRange = 100

            // 重力（物理核心）
            cell.yAcceleration = gravity
            cell.xAcceleration = CGFloat.random(in: -50...50)

            // 发射方向（向上）
            cell.emissionLongitude = -.pi / 2
            cell.emissionRange = emissionRange

            // 旋转（更自然）
            cell.spin = 4
            cell.spinRange = 6

            // 尺寸
            cell.scale = 0.6
            cell.scaleRange = 0.3

            // 颜色 & 内容
            cell.color = color.cgColor
            cell.contents = ConfettiEmitter.makeConfettiImage(color: color).cgImage

            // ⚠️ 不设置 alphaSpeed / scaleSpeed → 不会空中消失

            return cell
        }
    }

    // MARK: - Confetti Image

    private static func makeConfettiImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 6, height: 18)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 2)
        color.setFill()
        path.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
