//
//  RankUpConfetti3DView.swift
//  lns
//
//  Created by LNS2 on 2026/1/27.
//


import UIKit

// MARK: - Public API

public final class RankUpConfetti3DView: UIView {

    public enum ParticleShape: CaseIterable, Hashable {
        case square
        case circle
        case star5
        case triangle
        case parallelogram
    }
    
    private var impactGen: UIImpactFeedbackGenerator?
    private var impactMedium: UIImpactFeedbackGenerator?
    private let haptics = ConfettiHaptics()

    private var hapticEndMs: Int = 0
    private var lastHapticMs: Int = 0
    private var lastLandingHapticMs: Int = 0
    
    // ✅ 新增：记录当前 burst 的开始时间，用于计算烟花强弱包络
    private var currentBurstStartMs: Int = 0
    private let landingHapticDelayMs: Int = 600
    private let landingHapticCooldownMs: Int = 800

    public struct Config {
        // 图案开关
        public var enabledShapes: Set<ParticleShape> = Set(ParticleShape.allCases)

        // 每轮粒子数量
        public var particleCount: Int = 80

        // 整体总时长（所有喷射加起来）
        public var durationMs: Int = 1400

        // 喷射次数
        public var burstCount: Int = 1

        // 固定间隔兜底：0 / interval / 2interval ...
        public var burstIntervalMs: Int = 400

        // 相对间隔列表：前缀和触发
        public var burstIntervalMsList: [Int] = []

        // 是否每次喷之前清除之前粒子
        public var clearPreviousOnNewBurst: Bool = true

        // 颜色池：非空则只从这里取色；为空则 HSV 随机
        public var colors: [UIColor] = []

        // 物理参数
        public var gravityPx: CGFloat = 2200
        public var windPx: CGFloat = 100

        /// 0~100
        public var explodePower: CGFloat = 1

        /// nil = 360°;  -90 上; 90 下; 0 右; 180 左
        public var explosionDirectionDeg: CGFloat? = nil

        /// 3D 翻转速度倍率
        public var sheetSpinMultiplier: CGFloat = 0.5

        /// 初始散落半径
        public var spawnRadius: CGFloat = 40

        /// 发射中心点（归一化 0~1）
        public var originX: CGFloat = 0.5
        public var originY: CGFloat = 0.5

        /// 可见范围控制（相对 baseRadius=min(w,h)/2）；0 表示不限制
        public var horizontalRange: CGFloat = 2
        public var verticalRange: CGFloat = 2

        public var minParticleSize: CGFloat = 2
        public var maxParticleSize: CGFloat = 6

        /// 0=完全随机；非0=可复现
        public var randomSeed: UInt64 = 0

        /// 3D 透视强度（与 Kotlin 的 900f 对齐）
        public var perspective: CGFloat = 900
        
        /// 触感反馈
        public var hapticsEnabled: Bool = true
        public var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
        public var hapticContinuous: Bool = true
        public var hapticDurationMs: Int = 250        // 每次喷射持续震多久
        public var hapticIntervalMs: Int = 50         // 多久震一次（越小越密）
        public var hapticIntensity: CGFloat = 0.75     // iOS13+

        public init() {}
    }

    public var config: Config = .init()

    /// playKey：传入变化值即可触发播放；=0 则不播（对齐 Compose）
    public func play(playKey: Int, onFinished: (() -> Void)? = nil) {
        self.onFinished = onFinished
        guard playKey != 0 else { return }
        guard playKey != lastPlayKey else { return }
        lastPlayKey = playKey
        startAnimation()
    }

    // MARK: - Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        // 保持透明叠加
        backgroundColor = .clear
        isOpaque = false
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // 不强制裁剪（你原需求是能落到屏幕底部）
        clipsToBounds = false
        contentScaleFactor = UIScreen.main.scale
    }

    deinit {
        stopDisplayLink()
    }

    // MARK: - Internal

    private struct Vec3 { var x: CGFloat; var y: CGFloat; var z: CGFloat }

    private final class SeededRNG {
        private var state: UInt64
        init(seed: UInt64) { self.state = seed == 0 ? UInt64.random(in: 1...UInt64.max) : seed }
        func nextUInt() -> UInt64 {
            // LCG
            state = 6364136223846793005 &* state &+ 1442695040888963407
            return state
        }
        func nextFloat() -> CGFloat {
            // [0,1)
            let u = nextUInt() >> 11
            let denom = CGFloat(1 << 53)
            return CGFloat(u) / denom
        }
        func nextInt(_ upper: Int) -> Int {
            guard upper > 0 else { return 0 }
            return Int(nextUInt() % UInt64(upper))
        }
    }

    private struct Particle {
        // 位置：相对 center 的偏移（对齐 Kotlin：x/y 以中心为基准）
        var x: CGFloat
        var y: CGFloat

        // 速度 px/s
        var vx: CGFloat
        var vy: CGFloat

        // Z 轴旋转
        var rotation: CGFloat     // deg
        var omega: CGFloat        // deg/s

        // 外部 size（Kotlin 用于 rotate pivot & 一些随机）
        let size: CGFloat

        let color: UIColor
        let shape: ParticleShape

        let bornMs: Int
        let lifeMs: Int

        // 预建 path（star/triangle）
        let path: UIBezierPath?

        // 3D
        var rotX: CGFloat
        var rotY: CGFloat
        var omegaX: CGFloat
        var omegaY: CGFloat

        // 真实几何尺寸
        let w: CGFloat
        let h: CGFloat
        let skew: CGFloat
    }

    private var particles: [Particle] = []
    private var displayLink: CADisplayLink?
    private var lastFrameTimestamp: CFTimeInterval = 0

    private var animationStartMs: Int = 0
    private var launchedBursts: Int = 0
    private var triggerTimes: [Int] = []

    private var lastPlayKey: Int = 0
    private var onFinished: (() -> Void)?

    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        clipsToBounds = false
    }

    private func startAnimation() {
        stopDisplayLink()
        particles.removeAll(keepingCapacity: true)
        launchedBursts = 0
        lastFrameTimestamp = 0

        animationStartMs = nowMs()
        // ✅ 这里创建触感生成器（关键）
        if config.hapticsEnabled {
            haptics.prepare()
            let g = UIImpactFeedbackGenerator(style: config.hapticStyle)
            g.prepare()
            impactGen = g
            impactMedium = UIImpactFeedbackGenerator(style: .heavy)
            impactMedium?.prepare()
            lastHapticMs = 0
            hapticEndMs = 0
            currentBurstStartMs = 0   // ✅ 新增：初始化
            lastLandingHapticMs = 0
        } else {
            impactGen = nil
            impactMedium = nil
        }
        let safeBurstCount = max(1, config.burstCount)
        let safeInterval = max(1, config.burstIntervalMs)

        // triggerTimes：对齐 Kotlin
        if !config.burstIntervalMsList.isEmpty {
            let cleaned = config.burstIntervalMsList.map { max(0, $0) }
            let count = min(safeBurstCount, cleaned.count)
            var acc = 0
            triggerTimes = []
            triggerTimes.reserveCapacity(count)
            for i in 0..<count {
                acc += cleaned[i]
                triggerTimes.append(acc)
            }
        } else {
            triggerTimes = (0..<safeBurstCount).map { $0 * safeInterval }
        }

        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func finishAnimation() {
        stopDisplayLink()
        particles.removeAll()
        impactGen = nil
        impactMedium = nil
        setNeedsDisplay()
        onFinished?()
    }

    @objc private func tick(_ link: CADisplayLink) {
        let ts = link.timestamp
        if lastFrameTimestamp == 0 { lastFrameTimestamp = ts }

        var dt = CGFloat(ts - lastFrameTimestamp)
        lastFrameTimestamp = ts
        dt = min(dt, 0.033)

        let now = nowMs()
        let elapsed = now - animationStartMs

        // 1) 发射（durationMs 只控制“喷射期”）
        let totalBursts = triggerTimes.count
        while launchedBursts < totalBursts,
              elapsed >= triggerTimes[launchedBursts],
              elapsed < config.durationMs
        {
            spawnBurst(nowMs: now)
            
            // ✅ 新增：记录本次 burst 的起点（用于后续连续震动强弱变化）
            currentBurstStartMs = now

            if config.hapticsEnabled {
//                haptics.playPerfectConfetti(leadTime: 0)
                if config.hapticContinuous {
                    hapticEndMs = now + config.hapticDurationMs
                    lastHapticMs = 0

                    // ✅ 保留：先立刻震一下（但用“爆点强度”）
//                    let firstIntensity = clamp(1.0 * config.hapticIntensity, 0.05, 1.0)
//                    impactGen?.impactOccurred(intensity: firstIntensity)
                    impactMedium?.impactOccurred(intensity: 0.95)
                    impactMedium?.prepare()
                    impactGen?.prepare()
                    lastHapticMs = now
                } else {
                    // 单次震动：也给“爆点强度”
//                    let oneShotIntensity = clamp(1.0 * config.hapticIntensity, 0.05, 1.0)
                    //                        impactGen?.impactOccurred(intensity: oneShotIntensity)
                                            impactMedium?.impactOccurred(intensity: 0.95)
                    impactMedium?.prepare()
                    impactGen?.prepare()
                }
            }

            launchedBursts += 1
            
            // ✅ 烟花即将落地时的“低频余震”
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(landingHapticDelayMs) + 0.3) { [weak self] in
                            guard let self else { return }
                            let nowMs = self.nowMs()
                            guard nowMs - self.lastLandingHapticMs >= self.landingHapticCooldownMs else { return }
                            self.lastLandingHapticMs = nowMs
//                LowBuzzHaptic.shared.playBuzz(duration: 0.25)
                BuzzFallbackHaptic.playBuzz()
            }
        }

        // 2) 更新
        for i in particles.indices {
            let age = now - particles[i].bornMs
            if age < 0 { continue }

            let mulVX = clamp(1 - 0.06 * dt, 0.85, 1)
            let mulVY = clamp(1 - 0.02 * dt, 0.92, 1)
            particles[i].vx *= mulVX
            particles[i].vy *= mulVY

            particles[i].vx += config.windPx * dt * 0.2
            particles[i].vy += config.gravityPx * dt

            particles[i].x += particles[i].vx * dt
            particles[i].y += particles[i].vy * dt
            particles[i].rotation += particles[i].omega * dt

            particles[i].x += sin(CGFloat(age) / 180.0 + particles[i].size) * 0.35

            particles[i].rotX += particles[i].omegaX * dt
            particles[i].rotY += particles[i].omegaY * dt
        }

        // 3) 出屏删除（只在底部出屏才消失）
        let ox = clamp(config.originX, 0, 1)
        let oy = clamp(config.originY, 0, 1)
        let center = CGPoint(x: bounds.width * ox, y: bounds.height * oy)
        let margin: CGFloat = max(config.maxParticleSize, 10) * 4
        
        // ✅ 连续震动：改为“烟花包络强弱变化”，其他逻辑不动
        if config.hapticsEnabled, config.hapticContinuous, now < hapticEndMs {
            if lastHapticMs == 0 || (now - lastHapticMs) >= config.hapticIntervalMs {
                // 0~1：当前 burst 内的进度
                let denom = max(1, config.hapticDurationMs)
                let t = clamp(CGFloat(now - currentBurstStartMs) / CGFloat(denom), 0, 1)
                
                // 烟花包络：弱->强->爆点->衰减余震
                let env = fireworkEnvelope(t)
                
                // 最终强度：env * 用户配置强度
                let intensity = clamp(env * config.hapticIntensity, 0.05, 1.0)
                
                impactGen?.impactOccurred(intensity: intensity)
                impactGen?.prepare()
                lastHapticMs = now
            }
        }
        
        particles.removeAll { p in
            let absY = center.y + p.y
            return absY > bounds.height + margin
        }

        // 4) 结束：喷射结束 + 没粒子了
        let spawningEnded = elapsed >= config.durationMs
        if spawningEnded && particles.isEmpty {
            finishAnimation()
            return
        }

        setNeedsDisplay()
    }

    private func spawnBurst(nowMs: Int) {
        if config.clearPreviousOnNewBurst && launchedBursts > 0 {
            particles.removeAll(keepingCapacity: true)
        }

        let rnd = SeededRNG(seed: config.randomSeed == 0 ? UInt64.random(in: 1...UInt64.max) : config.randomSeed)

        let safeMin = max(1, config.minParticleSize)
        let safeMax = max(config.maxParticleSize, safeMin)
        let sizeRange = max(0, safeMax - safeMin)

        // remainingMs：duration - (born - start)
        let remaining = max(0, config.durationMs - (nowMs - animationStartMs))
        if remaining <= 0 { return }

        // explodePower -> baseSpeed（对齐 Kotlin）
        let powerNorm = clamp(config.explodePower, 0, 100) / 100.0
        let baseSpeedMin: CGFloat = 150
        let baseSpeedMax: CGFloat = 1500
        let baseSpeed = baseSpeedMin + (baseSpeedMax - baseSpeedMin) * powerNorm

        let spreadDegWhenDirected: CGFloat = 35//60    彩带的散开程度，数字越大越散
        let deg2rad = CGFloat.pi / 180.0

        func randColor() -> UIColor {
            if !config.colors.isEmpty {
                return config.colors[rnd.nextInt(config.colors.count)]
            }
            // HSV：h=0..360, s=0.65..1, v=0.75..1, alpha=1
            let h = rnd.nextFloat() * 360
            let s = 0.65 + rnd.nextFloat() * 0.35
            let v = 0.75 + rnd.nextFloat() * 0.25
            return UIColor(hue: h / 360.0, saturation: s, brightness: v, alpha: 1)
        }

        let allowed = config.enabledShapes.isEmpty ? Set(ParticleShape.allCases) : config.enabledShapes
        let allowedList = Array(allowed)

        for _ in 0..<max(0, config.particleCount) {
            let shape = allowedList[rnd.nextInt(allowedList.count)]
            let size = safeMin + rnd.nextFloat() * sizeRange

            // Parallelogram 更像彩纸：细长 + 倾斜（对齐 Kotlin）
            let w: CGFloat
            let h: CGFloat
            if shape == .parallelogram {
                h = size
                w = size * (1.6 + rnd.nextFloat() * 1.6) // 1.6~3.2
            } else {
                w = size
                h = size
            }

            let skew: CGFloat
            if shape == .parallelogram {
                skew = h * (0.08 + rnd.nextFloat() * 0.12) // 0.08~0.20
            } else {
                skew = 0
            }

            let is3DSheet = (shape == .parallelogram)

            let rotX0: CGFloat = is3DSheet ? (rnd.nextFloat() * 180 - 90) : 0
            let rotY0: CGFloat = is3DSheet ? (rnd.nextFloat() * 180 - 90) : 0

            let omegaX: CGFloat = is3DSheet ? ((rnd.nextFloat() * 720 - 360) * config.sheetSpinMultiplier) : 0
            let omegaY: CGFloat = is3DSheet ? ((rnd.nextFloat() * 720 - 360) * config.sheetSpinMultiplier) : 0
            let omegaZ: CGFloat
            if is3DSheet {
                omegaZ = ((rnd.nextFloat() - 0.5) * 220) * config.sheetSpinMultiplier
            } else {
                omegaZ = (rnd.nextFloat() - 0.5) * 420
            }

            // 初始散落：angleForPos + r^0.6（对齐 Kotlin）
            let angleForPos = rnd.nextFloat() * (2 * CGFloat.pi)
            let r = pow(rnd.nextFloat(), 0.6) * config.spawnRadius

            // 方向：explosionDirectionDeg + spread 或 360（对齐 Kotlin）
            let angleForVelDeg: CGFloat
            if let dir = config.explosionDirectionDeg {
                let offset = (rnd.nextFloat() - 0.5) * spreadDegWhenDirected
                angleForVelDeg = dir + offset
            } else {
                angleForVelDeg = rnd.nextFloat() * 360
            }
            let angleForVelRad = angleForVelDeg * deg2rad

            // speed：baseSpeed*(0.6..1.4)
            let speed = baseSpeed * (0.6 + rnd.nextFloat() * 0.8)

            var vx = cos(angleForVelRad) * speed
            var vy = sin(angleForVelRad) * speed

            // 噪声：±0.5*speed*0.15
            vx += (rnd.nextFloat() - 0.5) * (speed * 0.15)
            vy += (rnd.nextFloat() - 0.5) * (speed * 0.15)

            // life：remaining*(0.7..1.0)，clamp 16..remaining
            let rawLife = Int(CGFloat(remaining) * (0.7 + rnd.nextFloat() * 0.3))
            let lifeMs = clampInt(rawLife, 16, remaining)

            let path: UIBezierPath?
            switch shape {
            case .star5:
                path = buildStarPath(outerR: size / 2, innerR: size / 4, points: 5)
            case .triangle:
                path = buildTrianglePath(size: size)
            default:
                path = nil
            }

            let p = Particle(
                x: cos(angleForPos) * r,
                y: sin(angleForPos) * r,
                vx: vx,
                vy: vy,
                rotation: rnd.nextFloat() * 360,
                omega: omegaZ,
                size: size,
                color: randColor(),
                shape: shape,
                bornMs: nowMs,
                lifeMs: lifeMs,
                path: path,
                rotX: rotX0,
                rotY: rotY0,
                omegaX: omegaX,
                omegaY: omegaY,
                w: w,
                h: h,
                skew: skew
            )

            particles.append(p)
        }
    }

    // MARK: - Rendering

    public override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let ox = clamp(config.originX, 0, 1)
        let oy = clamp(config.originY, 0, 1)
        let center = CGPoint(x: bounds.width * ox, y: bounds.height * oy)

        let baseRadius = min(bounds.width, bounds.height) / 2

        let maxDx: CGFloat = config.horizontalRange > 0 ? baseRadius * config.horizontalRange : .greatestFiniteMagnitude
        let maxDy: CGFloat = config.verticalRange > 0 ? baseRadius * config.verticalRange : .greatestFiniteMagnitude

        let now = nowMs()

        for p in particles {
            let age = now - p.bornMs
            if age < 0 { continue }
//            if age < 0 || age > p.lifeMs { continue }

            // Kotlin 固定 alpha=0.9
            let alpha: CGFloat = 0.9

            let pos = CGPoint(x: center.x + p.x, y: center.y + p.y)
            let dx = pos.x - center.x
            let dy = pos.y - center.y

            if abs(dx) > maxDx || abs(dy) > maxDy { continue }

            ctx.saveGState()
            // 对齐 Kotlin：translate(pos) + rotate(p.rotation, pivot=size/2)
            ctx.translateBy(x: pos.x, y: pos.y)

            // pivot = (size/2, size/2)
            let pivotX = p.size / 2
            let pivotY = p.size / 2
            ctx.translateBy(x: pivotX, y: pivotY)
            ctx.rotate(by: (p.rotation * CGFloat.pi / 180))
            ctx.translateBy(x: -pivotX, y: -pivotY)

            switch p.shape {
            case .square:
                ctx.setFillColor(p.color.withAlphaComponent(alpha).cgColor)
                ctx.fill(CGRect(x: 0, y: 0, width: p.size, height: p.size))

            case .circle:
                ctx.setFillColor(p.color.withAlphaComponent(alpha).cgColor)
                let r = p.size / 2
                ctx.fillEllipse(in: CGRect(x: r - r, y: r - r, width: 2 * r, height: 2 * r).offsetBy(dx: r, dy: r))

            case .star5, .triangle:
                guard let path = p.path else { break }
                ctx.setFillColor(p.color.withAlphaComponent(alpha).cgColor)
                ctx.addPath(path.cgPath)
                ctx.fillPath()

            case .parallelogram:
                let (path3d, facing) = build3DSheetPath(
                    w: p.w,
                    h: p.h,
                    skew: p.skew,
                    rotXDeg: p.rotX,
                    rotYDeg: p.rotY,
                    perspective: config.perspective
                )
                // extraAlpha：0.35 + abs(facing)*0.65
                let face = abs(facing)
                let extraAlpha = clamp(0.35 + face * 0.65, 0, 1)

                ctx.setFillColor(p.color.withAlphaComponent(alpha * extraAlpha).cgColor)
                ctx.addPath(path3d.cgPath)
                ctx.fillPath()
            }

            ctx.restoreGState()
        }
    }

    // MARK: - Geometry / Paths (match Kotlin)

    private func buildTrianglePath(size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size / 2, y: 0))
        path.addLine(to: CGPoint(x: size, y: size))
        path.addLine(to: CGPoint(x: 0, y: size))
        path.close()
        return path
    }

    private func buildStarPath(outerR: CGFloat, innerR: CGFloat, points: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let step = CGFloat.pi / CGFloat(points)
        let start = -CGFloat.pi / 2

        for i in 0..<(points * 2) {
            let r = (i % 2 == 0) ? outerR : innerR
            let a = start + CGFloat(i) * step
            let x = outerR + cos(a) * r
            let y = outerR + sin(a) * r
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.close()
        return path
    }

    private func rotateX(_ v: Vec3, rad: CGFloat) -> Vec3 {
        let c = cos(rad), s = sin(rad)
        return Vec3(x: v.x, y: v.y * c - v.z * s, z: v.y * s + v.z * c)
    }

    private func rotateY(_ v: Vec3, rad: CGFloat) -> Vec3 {
        let c = cos(rad), s = sin(rad)
        return Vec3(x: v.x * c + v.z * s, y: v.y, z: -v.x * s + v.z * c)
    }

    /// 对齐 Kotlin build3DSheetPath：返回 (path, facing)
    private func build3DSheetPath(
        w: CGFloat,
        h: CGFloat,
        skew: CGFloat,
        rotXDeg: CGFloat,
        rotYDeg: CGFloat,
        perspective: CGFloat
    ) -> (UIBezierPath, CGFloat) {

        let halfW = w / 2
        let halfH = h / 2

        // 左上、右上、右下、左下（上边整体往右 skew）
        let p0 = Vec3(x: -halfW + skew / 2, y: -halfH, z: 0)
        let p1 = Vec3(x: +halfW + skew / 2, y: -halfH, z: 0)
        let p2 = Vec3(x: +halfW - skew / 2, y: +halfH, z: 0)
        let p3 = Vec3(x: -halfW - skew / 2, y: +halfH, z: 0)

        let rx = rotXDeg * CGFloat.pi / 180
        let ry = rotYDeg * CGFloat.pi / 180

        func transform(_ v: Vec3) -> Vec3 {
            // 先绕 X 再绕 Y
            return rotateY(rotateX(v, rad: rx), rad: ry)
        }

        let t0 = transform(p0)
        let t1 = transform(p1)
        let t2 = transform(p2)
        let t3 = transform(p3)

        // facing：transform((0,0,1)).z
        let n = transform(Vec3(x: 0, y: 0, z: 1))
        let facing = clamp(n.z, -1, 1)

        func project(_ v: Vec3) -> CGPoint {
            let s = perspective / (perspective + v.z)
            return CGPoint(x: v.x * s, y: v.y * s)
        }

        let o0 = project(t0)
        let o1 = project(t1)
        let o2 = project(t2)
        let o3 = project(t3)

        let path = UIBezierPath()
        path.move(to: o0)
        path.addLine(to: o1)
        path.addLine(to: o2)
        path.addLine(to: o3)
        path.close()

        return (path, facing)
    }

    // MARK: - Utils

    private func nowMs() -> Int {
        Int(CACurrentMediaTime() * 1000.0)
    }

    private func clamp(_ x: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat {
        min(max(x, a), b)
    }

    private func clampInt(_ x: Int, _ a: Int, _ b: Int) -> Int {
        min(max(x, a), b)
    }

    // ✅ 新增：烟花强弱包络（0~1 -> 0~1）
    // 弱 -> 快速上升 -> 爆点持平 -> 指数衰减余震
    private func fireworkEnvelope(_ t: CGFloat) -> CGFloat {
        if t < 0.15 {
            return t / 0.15
        } else if t < 0.4 {
            return 1.0
        } else {
            let decay = (t - 0.4) / 0.6
            return CGFloat(exp(-3.0 * Double(decay)))
        }
    }
}

// Swift 的 sin/cos 用 Double，做个 CGFloat 版
@inline(__always) private func sin(_ x: CGFloat) -> CGFloat { CGFloat(Darwin.sin(Double(x))) }
@inline(__always) private func cos(_ x: CGFloat) -> CGFloat { CGFloat(Darwin.cos(Double(x))) }
@inline(__always) private func pow(_ x: CGFloat, _ y: CGFloat) -> CGFloat { CGFloat(Darwin.pow(Double(x), Double(y))) }

final class BuzzFallbackHaptic {
    static func playBuzz() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()

        generator.impactOccurred(intensity: 0.9)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            generator.impactOccurred(intensity: 0.8)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            generator.impactOccurred(intensity: 0.75)
        }
//        var iden = 0.68
        for i in 0..<18{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14 + 0.06*Double(i)) {
                let iden = 0.68-Double(i)*0.01
                generator.impactOccurred(intensity: iden)
            }
        }
    }
}
