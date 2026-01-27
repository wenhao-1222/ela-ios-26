//
//  DemoVC.swift
//  lns
//
//  Created by LNS2 on 2026/1/27.
//

final class DemoVC: UIViewController {

    private let confetti = RankUpConfetti3DView()

    private var rankUpAnimationPlayKey: Int = 0
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.triggerRankUp()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        confetti.frame = view.bounds
        confetti.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        confetti.layer.zPosition = 12345
        confetti.isUserInteractionEnabled = false

        // 建议加到最顶层 overlay
        view.addSubview(confetti)

        // 配置参数（对齐 Kotlin）
        var cfg = RankUpConfetti3DView.Config()
        cfg.enabledShapes = [.parallelogram]

        cfg.burstCount = 5
        cfg.burstIntervalMsList = [0, 500, 350, 200, 200]
        cfg.durationMs = 2500
        cfg.burstIntervalMs = 1000 // 兜底

        cfg.clearPreviousOnNewBurst = false

        cfg.particleCount = 70
        cfg.verticalRange = 0       // 0：不限制垂直范围（对齐 Kotlin 的 0f=>∞）
        cfg.horizontalRange = 2
        cfg.minParticleSize = 5
        cfg.maxParticleSize = 10

        cfg.originX = 0.5
        cfg.originY = 0.6
        cfg.spawnRadius = 50

        cfg.colors = [
            UIColor(red: 0x25/255, green: 0x63/255, blue: 0xEB/255, alpha: 1),
            UIColor(red: 0x43/255, green: 0x38/255, blue: 0xCA/255, alpha: 1),
            UIColor(red: 0x7C/255, green: 0x3A/255, blue: 0xED/255, alpha: 1),
            UIColor(red: 0x08/255, green: 0x91/255, blue: 0xB2/255, alpha: 1),
            UIColor(red: 0x0D/255, green: 0x94/255, blue: 0x88/255, alpha: 1),
            UIColor(red: 0xDB/255, green: 0x27/255, blue: 0x77/255, alpha: 1),
            UIColor(red: 0xEA/255, green: 0x58/255, blue: 0x0C/255, alpha: 1),
            UIColor(red: 0xD9/255, green: 0x77/255, blue: 0x06/255, alpha: 1),
            UIColor(red: 0x16/255, green: 0xA3/255, blue: 0x4A/255, alpha: 1),
            UIColor(red: 0x65/255, green: 0xA3/255, blue: 0x0D/255, alpha: 1),
        ]

        cfg.explodePower = 60
        cfg.explosionDirectionDeg = -90
        cfg.gravityPx = 1500
        cfg.windPx = 0
        cfg.randomSeed = 0 // 0:完全随机

        confetti.config = cfg
    }

    func triggerRankUp() {
        // playKey 变化触发（对齐 Compose 的 playKey）
        rankUpAnimationPlayKey += 1
        DLLog(message: "动画播放 开始  ---   \(rankUpAnimationPlayKey)")
        confetti.play(playKey: rankUpAnimationPlayKey) { [weak self] in
            // 对齐 Kotlin：onFinished -> onAnimationEvent(Finished)
            self?.handleFinished()
        }
    }

    private func handleFinished() {
        DLLog(message: "动画播放完毕")
        // ...
    }
}
