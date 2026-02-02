//
//  LowBuzzHaptic.swift
//  lns
//
//  Created by LNS2 on 2026/2/2.
//

import CoreHaptics

final class LowBuzzHaptic {

    static let shared = LowBuzzHaptic()

    private var engine: CHHapticEngine?
    private var activePlayer: CHHapticPatternPlayer?

    private init() {
        prepare()
    }

    private func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.isAutoShutdownEnabled = false
            try engine?.start()
        } catch {
            print("Haptic engine error:", error)
        }
    }

    func playBuzz(duration: TimeInterval = 0.25) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            if engine == nil {
                engine = try CHHapticEngine()
                engine?.isAutoShutdownEnabled = false
            }
            try engine?.start()
        } catch {
            print("Haptic engine start error:", error)
            return
        }

        let prewarm = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 0.5),
                .init(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0
        )

        let buzz = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 0.5),
                .init(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0.02,
            duration: duration
        )

        do {
            let pattern = try CHHapticPattern(events: [prewarm, buzz], parameters: [])
            activePlayer = try engine!.makePlayer(with: pattern)
            try activePlayer?.start(atTime: 0)

            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
                self.activePlayer = nil
            }
        } catch {
            print("Haptic play error:", error)
        }
    }
    
}
