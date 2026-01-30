//
//  ConfettiHaptics.swift
//  lns
//
//  Created by LNS2 on 2026/1/30.
//

import UIKit
import CoreHaptics

final class ConfettiHaptics {

    // MARK: - Public knobs (you can tune)
    /// 全局强度缩放, 不同机型手感差异大, 建议保留这个旋钮
    var intensityScale: Float = 1.0

    // MARK: - Private
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?

    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    // MARK: - Lifecycle
    func prepare() {
        guard supportsHaptics else { return }

        do {
            let engine = try CHHapticEngine()
            engine.playsHapticsOnly = true

            engine.resetHandler = { [weak self] in
                // 引擎被系统重置时, 自动重建
                self?.prepare()
            }

            try engine.start()
            self.engine = engine
        } catch {
            self.engine = nil
            self.player = nil
        }
    }

    func stop() {
        player = nil
        engine?.stop(completionHandler: nil)
        engine = nil
    }

    // MARK: - Main API
    /// 在礼花开始喷发的那一刻调用一次即可
    /// leadTime 用于更硬核的同步(可选), 一般 0.015 秒就很稳
    func playPerfectConfetti(leadTime: TimeInterval = 0.0) {
        guard supportsHaptics else {
            fallbackPerfectConfetti(leadTime: leadTime)
            return
        }
        guard let engine else {
            fallbackPerfectConfetti(leadTime: leadTime)
            return
        }

        do {
            // 确保引擎在跑
            try engine.start()

            let seed = UInt64(Date().timeIntervalSince1970 * 1000.0)
            let pattern = try buildPerfectPattern(seed: seed)

            let p = try engine.makeAdvancedPlayer(with: pattern)
            self.player = p

            // Core Haptics 的时间基准是 engine.currentTime
            let startAt = engine.currentTime + max(0.0, leadTime)
            try p.start(atTime: startAt)

            // 播放完别停引擎, 下次更稳更快
            engine.notifyWhenPlayersFinished { [weak self] _ in
                self?.player = nil
                return .leaveEngineRunning
            }

        } catch {
            fallbackPerfectConfetti(leadTime: leadTime)
        }
    }

    // MARK: - Pattern building

    private struct BurstSpec {
        let kickI: Float
        let kickS: Float

        let snapDelay: TimeInterval
        let snapI: Float
        let snapS: Float

        let crackleCount: Int
        let crackleWindow: TimeInterval
        let crackleStartI: Float
        let crackleEndI: Float
        let crackleSharpMin: Float
        let crackleSharpMax: Float

        let tailDelay: TimeInterval
        let tailDuration: TimeInterval
        let tailI: Float
        let tailS: Float
    }

    private func buildPerfectPattern(seed: UInt64) throws -> CHHapticPattern {
        var rng = SeededGenerator(seed: seed)

        // 你的录屏里五次爆破的相对时间(以第一次喷发为 0)
        let bursts: [TimeInterval] = [0.000, 0.433, 0.767, 0.967, 1.167]

        // 文案定格点(很加分的盖章 tick)
        let stampTickTime: TimeInterval = 0.267

        // 第五次爆破后, 彩纸最“满”的瞬间附近(终章闪光)
        let finalSparkleTime: TimeInterval = 1.300

        // 五次爆破的性格, 按你的动画节奏编排
        let specs: [BurstSpec] = [
            // 1: 深而干净, 体积感
            BurstSpec(
                kickI: 0.95, kickS: 0.18,
                snapDelay: 0.014, snapI: 0.72, snapS: 0.95,
                crackleCount: 12, crackleWindow: 0.18,
                crackleStartI: 0.55, crackleEndI: 0.18,
                crackleSharpMin: 0.65, crackleSharpMax: 0.90,
                tailDelay: 0.085, tailDuration: 0.12, tailI: 0.12, tailS: 0.14
            ),

            // 2: 更脆更亮, 更短
            BurstSpec(
                kickI: 0.80, kickS: 0.32,
                snapDelay: 0.012, snapI: 0.68, snapS: 1.00,
                crackleCount: 10, crackleWindow: 0.16,
                crackleStartI: 0.48, crackleEndI: 0.16,
                crackleSharpMin: 0.75, crackleSharpMax: 0.95,
                tailDelay: 0.0, tailDuration: 0.0, tailI: 0.0, tailS: 0.0
            ),

            // 3: 明显收一下, 防麻木
            BurstSpec(
                kickI: 0.62, kickS: 0.22,
                snapDelay: 0.016, snapI: 0.45, snapS: 0.85,
                crackleCount: 7, crackleWindow: 0.12,
                crackleStartI: 0.34, crackleEndI: 0.12,
                crackleSharpMin: 0.60, crackleSharpMax: 0.85,
                tailDelay: 0.0, tailDuration: 0.0, tailI: 0.0, tailS: 0.0
            ),

            // 4: 更厚一点, 更低频
            BurstSpec(
                kickI: 0.88, kickS: 0.14,
                snapDelay: 0.018, snapI: 0.58, snapS: 0.90,
                crackleCount: 8, crackleWindow: 0.12,
                crackleStartI: 0.46, crackleEndI: 0.15,
                crackleSharpMin: 0.60, crackleSharpMax: 0.88,
                tailDelay: 0.085, tailDuration: 0.08, tailI: 0.10, tailS: 0.12
            ),

            // 5: 终章, 强但不拖, 丰富 crackle + 余韵
            BurstSpec(
                kickI: 1.00, kickS: 0.20,
                snapDelay: 0.012, snapI: 0.82, snapS: 1.00,
                crackleCount: 12, crackleWindow: 0.12,
                crackleStartI: 0.58, crackleEndI: 0.14,
                crackleSharpMin: 0.70, crackleSharpMax: 0.96,
                tailDelay: 0.085, tailDuration: 0.16, tailI: 0.12, tailS: 0.14
            ),
        ]

        var events: [CHHapticEvent] = []

        func scaled(_ v: Float) -> Float {
            let x = v * intensityScale
            return clamp(x, 0.0, 1.0)
        }

        func addTransient(_ t: TimeInterval, _ intensity: Float, _ sharpness: Float) {
            events.append(
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: scaled(intensity)),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: clamp(sharpness, 0.0, 1.0))
                    ],
                    relativeTime: t
                )
            )
        }

        func addContinuous(_ t: TimeInterval, _ duration: TimeInterval, _ intensity: Float, _ sharpness: Float) {
            events.append(
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: scaled(intensity)),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: clamp(sharpness, 0.0, 1.0))
                    ],
                    relativeTime: t,
                    duration: duration
                )
            )
        }

        for i in 0..<bursts.count {
            let t0 = bursts[i]
            let s = specs[i]

            // Kick + Snap
            addTransient(t0, s.kickI, s.kickS)
            addTransient(t0 + s.snapDelay, s.snapI, s.snapS)

            // Crackle (颗粒噼啪), 递减且带微随机
            var t = t0 + 0.028
            let endTime = t0 + s.crackleWindow

            for j in 0..<s.crackleCount {
                // 10 到 22ms 的随机间隔
                t += rng.uniform(0.010, 0.022)
                if t > endTime { break }

                let p = Float(j) / Float(max(1, s.crackleCount - 1))
                let base = s.crackleStartI + (s.crackleEndI - s.crackleStartI) * p
                let intensity = clamp(base + rng.uniformF(-0.05, 0.05), 0.08, 0.65)
                let sharpness = rng.uniformF(s.crackleSharpMin, s.crackleSharpMax)

                addTransient(t, intensity, sharpness)
            }

            // Tail (极短余韵), 只在关键爆点上给一点点空间感
            if s.tailDuration > 0 {
                addContinuous(t0 + s.tailDelay, s.tailDuration, s.tailI, s.tailS)
            }

            // 在第 1 次爆破后加入盖章 tick, 对齐你的文案定格
            if i == 0 {
                addTransient(stampTickTime, 0.28, 0.90)
            }
        }

        // 终章闪光 tick, 对齐你画面最满的那一下
        addTransient(finalSparkleTime + rng.uniform(-0.010, 0.010), 0.32, 0.95)

        return try CHHapticPattern(events: events, parameters: [])
    }

    // MARK: - Fallback

    private func fallbackPerfectConfetti(leadTime: TimeInterval) {
        // 用 UIFeedbackGenerator 模拟五连爆, 质感不如 Core Haptics, 但也尽量做出层次
        let t: [TimeInterval] = [0.000, 0.433, 0.767, 0.967, 1.167]
        let stamp: TimeInterval = 0.267
        let sparkle: TimeInterval = 1.300

        func after(_ dt: TimeInterval, _ block: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + leadTime + dt, execute: block)
        }

        // 1
        after(t[0]) {
            let g = UIImpactFeedbackGenerator(style: .heavy)
            g.prepare()
            g.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                let g2 = UIImpactFeedbackGenerator(style: .rigid)
                g2.prepare()
                g2.impactOccurred(intensity: 0.8)
            }
        }

        // stamp tick
        after(stamp) {
            let g = UIImpactFeedbackGenerator(style: .light)
            g.prepare()
            g.impactOccurred(intensity: 0.7)
        }

        // 2
        after(t[1]) {
            let g = UIImpactFeedbackGenerator(style: .rigid)
            g.prepare()
            g.impactOccurred(intensity: 0.9)
        }

        // 3
        after(t[2]) {
            let g = UIImpactFeedbackGenerator(style: .light)
            g.prepare()
            g.impactOccurred(intensity: 0.75)
        }

        // 4
        after(t[3]) {
            let g = UIImpactFeedbackGenerator(style: .heavy)
            g.prepare()
            g.impactOccurred(intensity: 0.85)
        }

        // 5
        after(t[4]) {
            let g = UIImpactFeedbackGenerator(style: .heavy)
            g.prepare()
            g.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                let g2 = UIImpactFeedbackGenerator(style: .rigid)
                g2.prepare()
                g2.impactOccurred(intensity: 0.85)
            }
        }

        // sparkle
        after(sparkle) {
            let g = UIImpactFeedbackGenerator(style: .light)
            g.prepare()
            g.impactOccurred(intensity: 0.65)
        }
    }
}

// MARK: - Utils

@inline(__always)
private func clamp(_ x: Float, _ lo: Float, _ hi: Float) -> Float {
    return min(max(x, lo), hi)
}

/// 一个简单可靠的可复现随机数生成器, 用于让 crackle 每次略不同
private struct SeededGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed != 0 ? seed : 0x9E3779B97F4A7C15
    }

    mutating func nextUInt64() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func uniform(_ a: Double, _ b: Double) -> Double {
        // 取 53-bit 精度, 生成 0..1
        let r = Double(nextUInt64() >> 11) / Double(1 << 53)
        return a + (b - a) * r
    }

    mutating func uniformF(_ a: Float, _ b: Float) -> Float {
        return Float(uniform(Double(a), Double(b)))
    }
}
