import SwiftUI

/// AI 能量球档位。
///
/// 设计意图：
/// - 业务侧只需要传入 1 到 7 档，不需要理解内部绘制参数。
/// - 每个档位通过 `profile` 映射到一组视觉强度参数。
/// - 当前页面使用 `.level7`，视觉上按参考视频主效果做峰值档。
public enum AICoachLoopLevel: Int, CaseIterable, Identifiable, Sendable {
    /// 1 档：最低活跃度。外圈、核心、闪点都最弱。
    case level1 = 1
    /// 2 档：轻微激活。比 1 档多一点外圈亮度和节点。
    case level2 = 2
    /// 3 档：浅层分析。开始出现更明显的内部线条和外层能量。
    case level3 = 3
    /// 4 档：稳定思考。外圈和核心亮度进入中等强度。
    case level4 = 4
    /// 5 档：参考视频基准档。当前产品页默认展示这一档。
    case level5 = 5
    /// 6 档：深度推理。比 5 档更亮、更密、更快。
    case level6 = 6
    /// 7 档：峰值状态。所有强度参数最高。
    case level7 = 7

    /// SwiftUI `ForEach` 使用的稳定 id。
    public var id: Int { rawValue }

    /// 档位名称。只在 `showsLevelLabel == true` 时作为底部文字展示。
    public var title: String {
        switch self {
        case .level1: return "休眠种子"
        case .level2: return "轻度苏醒"
        case .level3: return "浅层分析"
        case .level4: return "稳定思考"
        case .level5: return "高活跃推理"
        case .level6: return "深度推理"
        case .level7: return "峰值智能核心"
        }
    }
}

/// 单个档位对应的动画调参集合。
///
/// 这里就是 1 到 7 档的主要调参面板。
/// 当前“电浆球”版本会读取这些参数来控制尺寸、密度、亮度、形变、光晕和速度。
private struct AICoachLoopProfile: Sendable {
    /// 单次循环时长，单位秒。数值越小动画越快；Level 5 设为 1.80，对齐参考视频 1.8 秒循环。
    let loopDuration: CGFloat
    /// 中心能量强度。调大后核心雾光、旋涡线和闪电更亮。
    let brainStrength: CGFloat
    /// 外壳强度。调大后外圈膜、碎弧和边缘光更亮。
    let outerRingStrength: CGFloat
    /// 外壳高亮细线透明度。设为 0 可隐藏外圈最亮的清晰细线，不影响底部蓝色雾光。
    let outerShellHighlightOpacity: CGFloat
    /// 外侧游丝白色高光透明度。设为 0 可隐藏靠近外圈的白色刮痕感细线。
    let outerFilamentHighlightOpacity: CGFloat
    /// 内部能量膜层数基准。调大后内部淡环和外壳膜层更多。
    let brainLayers: Int
    /// 中心旋涡线密度。调大后核心内部弧线更多。
    let neuralLineCount: Int
    /// 中心白色高光数量。调大后核心亮斑/细高光更多。
    let neuralNodeCount: Int
    /// 外圈碎弧数量。调大后外壳裂纹、电浆碎片更多。
    let outerArcCount: Int
    /// 闪电连接线数量。调大后中心到外层的白蓝电弧更多。
    let sparkCount: Int
    /// 外壳半径比例。调大后球体更大、更贴近画布边缘。
    let outerRadius: CGFloat
    /// 核心半径比例。调大后中心旋涡更大。
    let brainRadius: CGFloat
    /// 环形扰动幅度。调大后外壳和旋涡更不规则、更像液态。
    let ringAmplitude: CGFloat
    /// 发光模糊强度。调大后光晕更大更柔，过大会糊。
    let bloom: CGFloat
    /// 线条锐度。调大后细线更亮更硬，调小更柔。
    let sharpness: CGFloat
    /// 背景蓝色能量场透明度。仅在 `includesBackground == true` 时生效。
    let backgroundOpacity: CGFloat
    /// 内部淡环透明度。调大后中心和外圈之间的能量膜更明显。
    let membraneOpacity: CGFloat
    /// 核心透明度。调大后中心蓝色云团和旋涡更明显。
    let coreOpacity: CGFloat
}

private extension AICoachLoopLevel {
    /// 档位到视觉参数的映射表。
    ///
    /// 调参入口：
    /// - 想改整体速度：改对应档位的 `loopDuration`。
    /// - 想改整体亮度和光晕：改 `brainStrength`、`outerRingStrength`、`coreOpacity`、`bloom`。
    /// - 想改复杂度：改 `brainLayers`、`neuralLineCount`、`neuralNodeCount`、`outerArcCount`、`sparkCount`。
    /// - 想改形状大小：改 `outerRadius`、`brainRadius`、`ringAmplitude`。
    var profile: AICoachLoopProfile {
        switch self {
        case .level1:
            return AICoachLoopProfile(
                loopDuration: 6.40,
                brainStrength: 0.01,
                outerRingStrength: 0.12,
                outerShellHighlightOpacity: 1.00,
                outerFilamentHighlightOpacity: 1.00,
                brainLayers: 0,
                neuralLineCount: 7,
                neuralNodeCount: 2,
                outerArcCount: 8,
                sparkCount: 1,
                outerRadius: 0.315,
                brainRadius: 0.125,
                ringAmplitude: 0.54,
                bloom: 0.32,
                sharpness: 0.22,
                backgroundOpacity: 0.38,
                membraneOpacity: 0.05,
                coreOpacity: 0.18
            )
        case .level2:
            return AICoachLoopProfile(
                loopDuration: 3.60,
                brainStrength: 0.30,
                outerRingStrength: 0.18,
                outerShellHighlightOpacity: 1.00,
                outerFilamentHighlightOpacity: 1.00,
                brainLayers: 1,
                neuralLineCount: 12,
                neuralNodeCount: 4,
                outerArcCount: 5,
                sparkCount: 1,
                outerRadius: 0.335,
                brainRadius: 0.140,
                ringAmplitude: 0.36,
                bloom: 0.42,
                sharpness: 0.52,
                backgroundOpacity: 0.48,
                membraneOpacity: 0.12,
                coreOpacity: 0.25
            )
        case .level3:
            return AICoachLoopProfile(
                loopDuration: 2.85,
                brainStrength: 0.48,
                outerRingStrength: 0.34,
                outerShellHighlightOpacity: 1.00,
                outerFilamentHighlightOpacity: 1.00,
                brainLayers: 2,
                neuralLineCount: 20,
                neuralNodeCount: 7,
                outerArcCount: 8,
                sparkCount: 3,
                outerRadius: 0.360,
                brainRadius: 0.158,
                ringAmplitude: 0.52,
                bloom: 0.58,
                sharpness: 0.68,
                backgroundOpacity: 0.62,
                membraneOpacity: 0.24,
                coreOpacity: 0.38
            )
        case .level4:
            return AICoachLoopProfile(
                loopDuration: 2.25,
                brainStrength: 0.70,
                outerRingStrength: 0.52,
                outerShellHighlightOpacity: 1.00,
                outerFilamentHighlightOpacity: 1.00,
                brainLayers: 2,
                neuralLineCount: 31,
                neuralNodeCount: 11,
                outerArcCount: 12,
                sparkCount: 6,
                outerRadius: 0.382,
                brainRadius: 0.178,
                ringAmplitude: 0.72,
                bloom: 0.78,
                sharpness: 0.84,
                backgroundOpacity: 0.74,
                membraneOpacity: 0.40,
                coreOpacity: 0.55
            )
        case .level5:
            // Calibrated against the supplied 1.8s reference recording.
            return AICoachLoopProfile(
                loopDuration: 1.80,
                brainStrength: 1.12,
                outerRingStrength: 0.98,
                outerShellHighlightOpacity: 1.00,
                outerFilamentHighlightOpacity: 1.00,
                brainLayers: 4,
                neuralLineCount: 66,
                neuralNodeCount: 22,
                outerArcCount: 28,
                sparkCount: 12,
                outerRadius: 0.392,
                brainRadius: 0.212,
                ringAmplitude: 0.96,
                bloom: 1.06,
                sharpness: 1.12,
                backgroundOpacity: 0.92,
                membraneOpacity: 0.70,
                coreOpacity: 0.90
            )
        case .level6:
            return AICoachLoopProfile(
                loopDuration: 1.80,
                brainStrength: 1.30,
                outerRingStrength: 1.12,
                outerShellHighlightOpacity: 1.00,
                outerFilamentHighlightOpacity: 1.00,
                brainLayers: 5,
                neuralLineCount: 78,
                neuralNodeCount: 28,
                outerArcCount: 34,
                sparkCount: 16,
                outerRadius: 0.394,
                brainRadius: 0.220,
                ringAmplitude: 1.06,
                bloom: 1.14,
                sharpness: 1.18,
                backgroundOpacity: 0.98,
                membraneOpacity: 0.80,
                coreOpacity: 0.96
            )
        case .level7:
            return AICoachLoopProfile(
                loopDuration: 62.40,
                brainStrength: 1.62,
                outerRingStrength: 0.96,
                outerShellHighlightOpacity: 0.00,
                outerFilamentHighlightOpacity: 0.00,
                brainLayers: 9,
                neuralLineCount: 92,
                neuralNodeCount: 0,
                outerArcCount: 12,
                sparkCount: 0,
                outerRadius: 0.355,
                brainRadius: 0.135,
                ringAmplitude: 2.82,
                bloom: 1.26,
                sharpness: 0.92,
                backgroundOpacity: 1.00,
                membraneOpacity: 2.00,
                coreOpacity: 1.96
            )
        }
    }
}

/// SwiftUI 可复用 AI 能量球组件。
///
/// 当前页面的使用方式在 `AIEnergyOrbVC` 中：
/// `AICoachLoopOrb(level: .level7, size: side, includesBackground: false)`。
/// 如果其他页面要复用，只需要控制 `level` 和 `size`。
public struct AICoachLoopOrb: View {
    /// 当前展示档位。影响循环速度和档位参数；当前参考视频版本默认使用 Level 5。
    public var level: AICoachLoopLevel
    /// 组件宽高。数值越大球体显示越大；UIKit 容器会传入当前可用正方形边长。
    public var size: CGFloat
    /// 是否显示底部档位标签。产品页设为 false，调试预览可设为 true。
    public var showsLevelLabel: Bool
    /// 是否绘制深蓝背景场。设为 true 更接近参考视频；设为 false 可叠在已有深色背景上。
    public var includesBackground: Bool
    /// 动画时间锚点。固定锚点可保证同一时刻多处组件动画相位一致。
    public var anchorDate: Date

    /// 用户打开“减少动态效果”时，会固定在 `anchorDate` 对应的第一帧，避免持续动画。
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// 创建一个 AI 能量球。
    ///
    /// 参数调节效果：
    /// - `level`：控制档位参数和循环速度。
    /// - `size`：控制画布尺寸，不改变内部比例。
    /// - `showsLevelLabel`：只影响调试标签，不影响动画。
    /// - `includesBackground`：控制是否绘制参考视频那种深蓝底光。
    /// - `anchorDate`：控制循环相位起点。
    public init(
        level: AICoachLoopLevel,
        size: CGFloat = 300,
        showsLevelLabel: Bool = false,
        includesBackground: Bool = true,
        anchorDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    ) {
        self.level = level
        self.size = size
        self.showsLevelLabel = showsLevelLabel
        self.includesBackground = includesBackground
        self.anchorDate = anchorDate
    }

    /// SwiftUI 主体。
    ///
    /// `TimelineView` 每帧更新时间，`Canvas` 每帧重画矢量图形。
    /// 当前动画没有图片和视频资源，所有视觉都由路径、渐变、模糊和混合模式实时生成。
    public var body: some View {
        let profile = level.profile

        // 60fps 驱动动画；实际帧率由系统根据性能调度。
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
            // phase 范围固定在 [0, 1)，所有 sin/cos 都从这个相位派生，保证循环首尾衔接。
            let phase = Self.loopPhase(
                now: reduceMotion ? anchorDate : timeline.date,
                anchor: anchorDate,
                duration: profile.loopDuration
            )

            ZStack(alignment: .bottom) {
                // Canvas 是核心绘制层。extendedLinear 让高亮和 plusLighter 混合更接近发光效果。
                Canvas(opaque: false, colorMode: .extendedLinear) { context, canvasSize in
                    var ctx = context
                    let renderer = AICoachOrbCanvasRenderer(
                        level: level,
                        includesBackground: includesBackground
                    )
                    renderer.render(context: &ctx, size: canvasSize, phase: phase)
                }
                // 离屏合成，提升 blur / plusLighter 叠加质量。
                .drawingGroup(opaque: false, colorMode: .extendedLinear)

                if showsLevelLabel {
                    Text("L\(level.rawValue)  \(level.title)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.36), in: Capsule())
                        .padding(.bottom, 8)
                }
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .accessibilityLabel("AI教练进度动画第\(level.rawValue)档")
    }

    /// 把真实时间转换成 0 到 1 的循环相位。
    ///
    /// 调节效果：
    /// - `duration` 越小，动画越快。
    /// - 返回值只保留小数部分，所以每个循环结束会自然回到开头。
    private static func loopPhase(now: Date, anchor: Date, duration: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        let elapsed = CGFloat(now.timeIntervalSince(anchor))
        let turns = elapsed / duration
        return turns - floor(turns)
    }
}

/// Canvas 渲染器。
///
/// 这个结构只负责“怎么画”，不持有 SwiftUI 状态。
/// 当前主渲染已经改成参考视频风格：
/// 背景深蓝场 -> 内部雾化电浆 -> 破碎外壳 -> 中心旋涡 -> 白蓝电弧。
private struct AICoachOrbCanvasRenderer {
    /// 当前档位，用来读取 `profile`。
    let level: AICoachLoopLevel
    /// 是否绘制背景蓝雾。如果外部页面已有背景，可设为 false。
    let includesBackground: Bool

    /// 当前档位参数快捷入口。
    private var p: AICoachLoopProfile { level.profile }
    /// 2π，所有圆形路径、旋转、相位动画都使用这个常量。
    private let tau: CGFloat = .pi * 2.0

    /// 主渲染入口。
    ///
    /// 参数说明：
    /// - `context`：Canvas 绘图上下文，所有图形都画到这里。
    /// - `size`：当前画布尺寸。
    /// - `phase`：0 到 1 的循环进度。
    ///
    /// 当前可调重点在 `AICoachLoopLevel.profile`。
    /// - `outerRadius`：调大外壳更贴近画布边缘。
    /// - `brainRadius`：调大中心旋涡更大。
    /// - 绘制顺序会影响叠加观感，越后画越容易盖在上面。
    func render(context: inout GraphicsContext, size: CGSize, phase: CGFloat) {
        let theta = phase * tau
        let minSide = min(size.width, size.height)
        let center = CGPoint(x: size.width * 0.50, y: size.height * 0.50)
        let outerRadius = minSide * p.outerRadius
        let brainRadius = minSide * p.brainRadius

        if includesBackground {
            drawBackground(context: &context, size: size, center: center, radius: outerRadius, theta: theta)
        }

        // plusLighter 是加亮混合，适合蓝色电浆、闪电、Bloom 感的叠加。
        context.blendMode = .plusLighter
        if level == .level7 {
            drawContainedBrainBurst(context: &context, center: center, outerRadius: outerRadius, coreRadius: brainRadius, theta: theta)
            return
        }

        // 1. 大范围蓝色雾场和内部弱环。
        drawPlasmaField(context: &context, center: center, outerRadius: outerRadius, coreRadius: brainRadius, theta: theta)
        // 2. 参考视频里中心和外壳之间密集游走的短弧纹理。
        drawReferenceInteriorFilaments(context: &context, center: center, outerRadius: outerRadius, coreRadius: brainRadius, theta: theta)
        // 3. 参考视频最明显的破碎外球壳。
        drawReferenceOuterShell(context: &context, center: center, radius: outerRadius, theta: theta)
        // 4. 中心蓝色旋涡核心。
        drawReferenceCore(context: &context, center: center, radius: brainRadius, theta: theta)
        // 5. 局部白蓝电弧高光。
        drawReferenceLightning(context: &context, center: center, outerRadius: outerRadius, coreRadius: brainRadius, theta: theta)
    }

    /// 绘制深蓝背景场。
    ///
    /// 对应参考图效果：
    /// - 图一不是纯黑底，而是中心附近有深蓝径向雾光。
    /// - 这个函数负责铺底色、中心大光晕、边缘暗角。
    ///
    /// 常用调参：
    /// - `fieldOpacity` 越大，背景越蓝。
    /// - `radius * 2.30` 越大，背景渐变扩散范围越大。
    /// - 最后一层黑色径向渐变控制暗角，透明度越高边缘越黑。
    private func drawBackground(context: inout GraphicsContext, size: CGSize, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let rect = CGRect(origin: .zero, size: size)
        // 背景轻微呼吸，避免静态死板。振幅很低，只影响底光强弱。
        let pulse = 0.78 + 0.22 * sin(theta)
        let fieldOpacity = p.backgroundOpacity

        // 第一层：全画布深蓝到黑色径向渐变。
        context.fill(
            Path(rect),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: Color(red: 0.00, green: 0.070, blue: 0.170).alpha(0.82 * fieldOpacity), location: 0.00),
                    .init(color: Color(red: 0.00, green: 0.022, blue: 0.075).alpha(0.96), location: 0.58),
                    .init(color: .black.alpha(1.00), location: 1.00)
                ]),
                center: center,
                startRadius: 0,
                endRadius: radius * 2.30
            )
        )

        // 第二层：柔和中心蓝色光场。blur 越大，光越雾化。
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: radius * (0.20 + 0.040 * pulse) * p.bloom))
            layer.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - radius * 1.58,
                    y: center.y - radius * 1.26,
                    width: radius * 3.16,
                    height: radius * 2.52
                )),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: Color(red: 0.00, green: 0.42, blue: 1.00).alpha(0.13 * fieldOpacity * pulse), location: 0.00),
                        .init(color: Color(red: 0.00, green: 0.14, blue: 0.55).alpha(0.07 * fieldOpacity), location: 0.48),
                        .init(color: .clear, location: 1.00)
                    ]),
                    center: center,
                    startRadius: 0,
                    endRadius: radius * 1.62
                )
            )
        }

        // 第三层：边缘暗角，让球体视觉集中在中心。
        context.fill(
            Path(rect),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: .clear, location: 0.40),
                    .init(color: Color.black.alpha(0.36), location: 0.72),
                    .init(color: Color.black.alpha(0.96), location: 1.00)
                ]),
                center: center,
                startRadius: radius * 0.50,
                endRadius: max(size.width, size.height) * 0.72
            )
        )
    }

    /// Level 7 专用：被外壳包住的蓝色内爆脑核。
    ///
    /// 视觉目标：
    /// - 外轮廓是一圈厚的蓝色电弧壳，不出现零散白色刮痕。
    /// - 内部像高速运转的大脑/能量核心，中心亮光向外投射。
    /// - 整体保持“即将爆炸但仍被球壳束缚”的张力。
    private func drawContainedBrainBurst(context: inout GraphicsContext, center: CGPoint, outerRadius: CGFloat, coreRadius: CGFloat, theta: CGFloat) {
        let cyan = Color(red: 0.02, green: 0.82, blue: 1.00)
        let electric = Color(red: 0.13, green: 0.94, blue: 1.00)
        let blue = Color(red: 0.00, green: 0.28, blue: 1.00)
        let deepBlue = Color(red: 0.00, green: 0.06, blue: 0.26)
        let whiteBlue = Color(red: 0.78, green: 0.98, blue: 1.00)
        let pulse = 0.82 + 0.18 * sin(theta * 2.0)
        let hotPulse = 0.62 + 0.38 * flashPulse(theta: theta, cycles: 2, seed: 4.0, power: 1.9)

        // 深蓝球体体积，先把能量限制在外壳内部。
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: outerRadius * 0.10 * p.bloom))
            layer.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - outerRadius * 1.02,
                    y: center.y - outerRadius * 0.98,
                    width: outerRadius * 2.04,
                    height: outerRadius * 1.96
                )),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: electric.alpha(0.32 * hotPulse), location: 0.00),
                        .init(color: blue.alpha(0.18 * p.membraneOpacity), location: 0.36),
                        .init(color: deepBlue.alpha(0.42), location: 0.72),
                        .init(color: .clear, location: 1.00)
                    ]),
                    center: CGPoint(x: center.x - outerRadius * 0.08, y: center.y - outerRadius * 0.08),
                    startRadius: 0,
                    endRadius: outerRadius * 1.10
                )
            )
        }

        // 中心爆亮脑核，类似内部爆炸光被蓝色壳体包住。
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: coreRadius * 0.42 * p.bloom))
            layer.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - coreRadius * 1.72,
                    y: center.y - coreRadius * 1.56,
                    width: coreRadius * 3.44,
                    height: coreRadius * 3.12
                )),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: whiteBlue.alpha(0.56 * p.coreOpacity * hotPulse), location: 0.00),
                        .init(color: electric.alpha(0.52 * p.coreOpacity), location: 0.28),
                        .init(color: blue.alpha(0.28 * p.coreOpacity), location: 0.62),
                        .init(color: .clear, location: 1.00)
                    ]),
                    center: CGPoint(x: center.x - coreRadius * 0.12, y: center.y - coreRadius * 0.08),
                    startRadius: 0,
                    endRadius: coreRadius * 1.92
                )
            )
        }

        // 内部脑状高速流线：更像一团发光脑核，而不是规则线圈。
        for i in 0..<max(22, p.neuralLineCount / 3) {
            let seed = CGFloat(i) * 41.27 + 8.0
            let orbit = CGFloat([2, -2, 3, -3, 4, -4][i % 6])
            let radius = coreRadius * (0.24 + hashed(seed) * 0.94)
            let arc = liquidArcPath(
                center: center,
                radius: radius,
                startAngle: hashed(seed + 1.0) * tau + theta * orbit,
                length: 0.08 + hashed(seed + 2.0) * 0.20,
                amplitude: coreRadius * (0.15 + hashed(seed + 3.0) * 0.10) * p.ringAmplitude,
                samples: 18,
                theta: theta * CGFloat(i % 2 == 0 ? 2 : -2),
                seed: seed
            )
            let gate = 0.45 + 0.55 * flashPulse(theta: theta, cycles: 1 + i % 4, seed: seed, power: 2.0)

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: coreRadius * 0.060 * p.bloom))
                layer.stroke(
                    arc,
                    with: .color(blue.alpha(0.28 * gate * p.brainStrength)),
                    style: StrokeStyle(lineWidth: coreRadius * 0.092 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }
            context.stroke(
                arc,
                with: .color(electric.alpha(0.34 * gate * p.brainStrength)),
                style: StrokeStyle(lineWidth: coreRadius * 0.020 * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }

        // 内爆投射光：从核心往外壳顶出去的短束光。
        for i in 0..<18 {
            let seed = CGFloat(i) * 63.11 + 12.0
            let angle = hashed(seed) * tau + theta * CGFloat(i % 2 == 0 ? 1 : -1)
            let startRadius = coreRadius * (0.38 + hashed(seed + 1.0) * 0.50)
            let endRadius = outerRadius * (0.56 + hashed(seed + 2.0) * 0.26)
            let start = CGPoint(x: center.x + cos(angle) * startRadius, y: center.y + sin(angle) * startRadius)
            let endAngle = angle + (hashed(seed + 3.0) - 0.5) * 0.55
            let end = CGPoint(x: center.x + cos(endAngle) * endRadius, y: center.y + sin(endAngle) * endRadius)
            let control = CGPoint(
                x: center.x + cos((angle + endAngle) * 0.5 + sin(theta + seed) * 0.22) * outerRadius * 0.32,
                y: center.y + sin((angle + endAngle) * 0.5 + cos(theta + seed) * 0.22) * outerRadius * 0.32
            )
            let gate = 0.32 + 0.68 * flashPulse(theta: theta, cycles: 1 + i % 3, seed: seed, power: 2.8)
            var beam = Path()
            beam.move(to: start)
            beam.addQuadCurve(to: end, control: control)

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: outerRadius * 0.028 * p.bloom))
                layer.stroke(
                    beam,
                    with: .color(cyan.alpha(0.16 * gate * p.brainStrength)),
                    style: StrokeStyle(lineWidth: outerRadius * 0.032 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }
            context.stroke(
                beam,
                with: .color(electric.alpha(0.18 * gate * p.coreOpacity)),
                style: StrokeStyle(lineWidth: outerRadius * 0.0065 * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }

        // 厚电弧外壳：完整圆形边界 + 不规则高能边缘。
        for layerIndex in 0..<6 {
            let f = CGFloat(layerIndex)
            let shell = wavyRingPath(
                center: center,
                radius: outerRadius * (0.91 + f * 0.014),
                amplitude: outerRadius * (0.030 + f * 0.004) * p.ringAmplitude,
                samples: 220,
                theta: theta * CGFloat(layerIndex % 2 == 0 ? 1 : -1),
                seed: 811.0 + f * 37.0,
                phaseShift: f * 0.51
            )

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: outerRadius * (0.034 + f * 0.006) * p.bloom))
                layer.stroke(
                    shell,
                    with: .color(blue.alpha((0.16 - f * 0.010) * p.outerRingStrength * pulse)),
                    style: StrokeStyle(lineWidth: outerRadius * (0.075 - f * 0.006), lineCap: .round, lineJoin: .round)
                )
            }
            context.stroke(
                shell,
                with: .color(cyan.alpha((0.20 - f * 0.018) * p.outerRingStrength)),
                style: StrokeStyle(lineWidth: outerRadius * (0.016 - f * 0.0014) * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }

        // 边界上的局部爆亮碎弧，颜色偏蓝，不使用白色刮痕。
        for i in 0..<max(12, p.outerArcCount) {
            let seed = CGFloat(i) * 77.17 + 29.0
            let start = hashed(seed) * tau + theta * CGFloat([1, -1, 2, -2][i % 4])
            let arc = liquidArcPath(
                center: center,
                radius: outerRadius * (0.90 + hashed(seed + 1.0) * 0.09),
                startAngle: start,
                length: 0.035 + hashed(seed + 2.0) * 0.085,
                amplitude: outerRadius * 0.030 * p.ringAmplitude,
                samples: 14,
                theta: theta,
                seed: seed
            )
            let gate = 0.42 + 0.58 * flashPulse(theta: theta, cycles: 1 + i % 4, seed: seed, power: 2.2)
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: outerRadius * 0.020 * p.bloom))
                layer.stroke(
                    arc,
                    with: .color(electric.alpha(0.26 * gate * p.outerRingStrength)),
                    style: StrokeStyle(lineWidth: outerRadius * 0.026 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }
            context.stroke(
                arc,
                with: .color(cyan.alpha(0.28 * gate * p.outerRingStrength)),
                style: StrokeStyle(lineWidth: outerRadius * 0.008 * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }
    }

    /// 绘制球体内部的大范围电浆雾场。
    ///
    /// 对应参考图效果：
    /// - 图一外壳内部不是空的，有多圈很淡的蓝色能量膜。
    /// - 这个函数先画一层大模糊蓝雾，再按 `brainLayers` 画多条很淡的波纹环。
    ///
    /// 常用调参：
    /// - `outerRadius * 0.24`：雾场模糊半径，越大越柔。
    /// - `brainLayers`：内部淡环数量基准，增加会让球体内部更复杂。
    /// - `radius: outerRadius * (0.56 + f * 0.065)`：每层淡环的位置。
    /// - `amplitude`：淡环边缘不规则程度。
    private func drawPlasmaField(context: inout GraphicsContext, center: CGPoint, outerRadius: CGFloat, coreRadius: CGFloat, theta: CGFloat) {
        let pulse = 0.72 + 0.28 * sin(theta * CGFloat(max(1, p.brainLayers)) + 0.4)

        // 模糊的蓝色体积光，负责整体“能量球内部有雾”的观感。
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: outerRadius * 0.30 * p.bloom))
            layer.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - outerRadius * 1.22,
                    y: center.y - outerRadius * 1.18,
                    width: outerRadius * 2.44,
                    height: outerRadius * 2.36
                )),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: Color(red: 0.08, green: 0.74, blue: 1.00).alpha(0.18 * pulse * p.membraneOpacity), location: 0.00),
                        .init(color: Color(red: 0.00, green: 0.30, blue: 0.86).alpha(0.09 * p.membraneOpacity), location: 0.44),
                        .init(color: Color(red: 0.00, green: 0.05, blue: 0.20).alpha(0.04 * p.membraneOpacity), location: 0.80),
                        .init(color: .clear, location: 1.00)
                    ]),
                    center: center,
                    startRadius: coreRadius * 0.20,
                    endRadius: outerRadius * 1.25
                )
            )
        }

        // 多层低透明度波纹环，模拟电浆膜在球体内部流动。
        let membraneCount = max(0, p.brainLayers + 1)
        for i in 0..<membraneCount {
            let f = CGFloat(i)
            let path = wavyRingPath(
                center: center,
                radius: outerRadius * (0.50 + f * 0.064),
                amplitude: outerRadius * (0.045 + f * 0.011),
                samples: 180,
                theta: theta * CGFloat(i % 2 == 0 ? 1 : -1),
                seed: 300.0 + f * 41.0,
                phaseShift: f * 0.53
            )

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: outerRadius * (0.030 + f * 0.006) * p.bloom))
                layer.stroke(
                    path,
                    with: .color(Color(red: 0.00, green: 0.48, blue: 1.00).alpha((0.025 + 0.013 * f) * p.outerRingStrength * p.membraneOpacity)),
                    style: StrokeStyle(lineWidth: outerRadius * (0.058 - f * 0.004) * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }

    /// 绘制参考视频中最容易被忽略的中层电浆纹理。
    ///
    /// 参考视频的中心和外壳之间不是空的，而是有一圈不断滚动的蓝白短弧。
    /// 这一层把球体从“外圈 + 核心”补成更接近视频里的三层结构。
    private func drawReferenceInteriorFilaments(context: inout GraphicsContext, center: CGPoint, outerRadius: CGFloat, coreRadius: CGFloat, theta: CGFloat) {
        let cyan = Color(red: 0.03, green: 0.78, blue: 1.00)
        let blue = Color(red: 0.00, green: 0.30, blue: 1.00)
        let white = Color(red: 0.86, green: 1.00, blue: 1.00)
        let filamentCount = max(12, p.neuralLineCount / 2)

        for i in 0..<filamentCount {
            let seed = CGFloat(i) * 58.31 + 14.0
            let band = hashed(seed + 0.7)
            let spin = CGFloat([1, -1, 2, -2, 3, -3][i % 6])
            let start = hashed(seed) * tau + theta * spin
            let length = 0.018 + hashed(seed + 2.0) * 0.082
            let bandRadius = coreRadius * 1.06 + (outerRadius - coreRadius) * (0.18 + band * 0.64)
            let gate = 0.24 + 0.76 * flashPulse(theta: theta, cycles: 1 + i % 4, seed: seed, power: 2.8)
            let arc = liquidArcPath(
                center: center,
                radius: bandRadius,
                startAngle: start,
                length: length,
                amplitude: outerRadius * 0.050 * p.ringAmplitude,
                samples: 16,
                theta: theta * CGFloat(i % 2 == 0 ? 1 : -1),
                seed: seed
            )

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: outerRadius * 0.013 * p.bloom))
                layer.stroke(
                    arc,
                    with: .color(blue.alpha(0.10 * gate * p.brainStrength * p.membraneOpacity)),
                    style: StrokeStyle(lineWidth: outerRadius * 0.019 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }

            let hot = gate > 0.82 || i % 11 == 0
            context.stroke(
                arc,
                with: .color((hot ? white : cyan).alpha((hot ? 0.34 * p.outerFilamentHighlightOpacity : 0.18) * gate * p.brainStrength * p.membraneOpacity)),
                style: StrokeStyle(lineWidth: outerRadius * (hot ? 0.0065 : 0.0045) * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }

        for i in 0..<max(4, p.brainLayers * 2) {
            let seed = CGFloat(i) * 74.6 + 37.0
            let angle = hashed(seed) * tau + theta * CGFloat(i % 2 == 0 ? 1 : -1)
            let inner = coreRadius * (0.86 + hashed(seed + 1.0) * 0.32)
            let outer = outerRadius * (0.46 + hashed(seed + 2.0) * 0.22)
            let start = CGPoint(x: center.x + cos(angle) * inner, y: center.y + sin(angle) * inner)
            let endAngle = angle + (hashed(seed + 3.0) - 0.5) * 0.90
            let end = CGPoint(x: center.x + cos(endAngle) * outer, y: center.y + sin(endAngle) * outer)
            let control = CGPoint(
                x: center.x + cos((angle + endAngle) * 0.5 + sin(theta + seed) * 0.35) * outerRadius * 0.26,
                y: center.y + sin((angle + endAngle) * 0.5 + cos(theta + seed) * 0.35) * outerRadius * 0.26
            )
            let gate = flashPulse(theta: theta, cycles: 1 + i % 3, seed: seed, power: 3.2)

            var path = Path()
            path.move(to: start)
            path.addQuadCurve(to: end, control: control)

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: outerRadius * 0.011 * p.bloom))
                layer.stroke(
                    path,
                    with: .color(cyan.alpha(0.11 * gate * p.brainStrength)),
                    style: StrokeStyle(lineWidth: outerRadius * 0.014 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }
            context.stroke(
                path,
                with: .color(white.alpha(0.16 * gate * p.coreOpacity * p.outerFilamentHighlightOpacity)),
                style: StrokeStyle(lineWidth: outerRadius * 0.0038 * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }
    }

    /// 绘制参考视频风格的破碎外球壳。
    ///
    /// 对应参考图效果：
    /// - 这是最重要的外观层，决定“像不像图一”。
    /// - 图二之前过于规整，是因为只有干净圆环；这里改为多层 wavy ring + 短碎亮弧。
    ///
    /// 常用调参：
    /// - 第一段 `0..<7`：外壳连续能量膜层数，增加会更厚。
    /// - `localRadius`：每层外壳半径，整体调大可以让球更满。
    /// - `amplitude`：外壳破碎/抖动程度，越大越不规则。
    /// - 第二段 `0..<34`：短碎亮弧数量，越多越像电浆裂纹。
    /// - `length`：短弧长度，越大碎片越长。
    /// - `gate`：每条亮弧随时间闪烁的强度。
    private func drawReferenceOuterShell(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let cyan = Color(red: 0.02, green: 0.74, blue: 1.00)
        let blue = Color(red: 0.00, green: 0.28, blue: 1.00)
        let white = Color(red: 0.82, green: 1.00, blue: 1.00)

        // 连续外壳膜：多层不规则闭合环，负责球体边界。
        for layerIndex in 0..<max(1, p.brainLayers * 2 + 3) {
            let f = CGFloat(layerIndex)
            let localRadius = radius * (0.78 + f * 0.018 * max(0.8, p.outerRingStrength))
            let amplitude = radius * (0.052 + f * 0.0045) * p.ringAmplitude
            let path = wavyRingPath(
                center: center,
                radius: localRadius,
                amplitude: amplitude,
                samples: 220,
                theta: theta * (layerIndex % 2 == 0 ? 1.0 : -1.0),
                seed: 71.0 + f * 29.0,
                phaseShift: f * 0.62
            )

            // 模糊粗线先画在底部，形成 Bloom 光晕。
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: radius * (0.024 + f * 0.003)))
                layer.stroke(
                    path,
                    with: .color(blue.alpha((0.048 + f * 0.010) * p.outerRingStrength)),
                    style: StrokeStyle(lineWidth: radius * max(0.004, (0.032 - f * 0.0018)) * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }

            // 细线画在上方，提供清晰的电浆边缘。
            context.stroke(
                path,
                with: .color(cyan.alpha((0.032 + f * 0.010) * p.outerRingStrength * p.outerShellHighlightOpacity)),
                style: StrokeStyle(lineWidth: radius * (0.0060 + f * 0.0006) * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }

        // 短碎电弧：所有旋转速度必须是整数圈，确保 phase 回 0 时路径完全闭合。
        for i in 0..<max(0, p.outerArcCount * 3) {
            let seed = CGFloat(i) * 77.17 + 9.0
            let spin = CGFloat([1, -1, 2, -2, 3, -3][i % 6])
            let start = hashed(seed) * tau + theta * spin
            let length = 0.012 + hashed(seed + 1.0) * 0.058
            let gate = 0.24 + 0.76 * flashPulse(theta: theta, cycles: 1 + (i % 5), seed: seed, power: 2.35) * p.outerRingStrength
            let arc = liquidArcPath(
                center: center,
                radius: radius * (0.73 + hashed(seed + 4.0) * 0.30),
                startAngle: start + sin(theta * CGFloat(1 + i % 3) + seed) * 0.08,
                length: length,
                amplitude: radius * 0.082 * p.ringAmplitude,
                samples: 12,
                theta: theta,
                seed: seed
            )

            // 外层模糊辉光。
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: radius * 0.016 * p.bloom))
                layer.stroke(
                    arc,
                    with: .color(cyan.alpha(0.20 * gate * p.outerRingStrength)),
                    style: StrokeStyle(lineWidth: radius * 0.021 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }

            // 内层清晰高亮；部分片段变白，模拟局部电弧爆亮。
            let isHot = gate > 0.78 || i % 9 == 0
            context.stroke(
                arc,
                with: .color((isHot ? white : cyan).alpha((isHot ? 0.52 : 0.24) * gate * p.outerRingStrength)),
                style: StrokeStyle(lineWidth: radius * (isHot ? 0.0078 : 0.0048) * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }
    }

    /// 绘制中心蓝色旋涡核心。
    ///
    /// 对应参考图效果：
    /// - 图一中心是一团较大的旋涡云，不是图二那种小线团。
    /// - 这个函数负责中心体积光、多圈旋涡弧、局部白色高亮。
    ///
    /// 常用调参：
    /// - 第一层 ellipse 尺寸：控制中心蓝色云团大小。
    /// - `0..<8`：主要旋涡弧数量，越多中心越复杂。
    /// - `radius * 0.090`：旋涡弧底光粗细，越大越糊更有能量感。
    /// - 第二个 `0..<7`：白色细高光数量，越多越闪。
    private func drawReferenceCore(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let cyan = Color(red: 0.02, green: 0.82, blue: 1.00)
        let blue = Color(red: 0.00, green: 0.28, blue: 1.00)
        let white = Color(red: 0.88, green: 1.00, blue: 1.00)

        // 中心模糊体积光，奠定蓝色大脑/能量云的基础亮度。
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: radius * 0.30 * p.bloom))
            layer.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - radius * 1.36,
                    y: center.y - radius * 1.28,
                    width: radius * 2.72,
                    height: radius * 2.56
                )),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: white.alpha(0.08 * p.coreOpacity * p.brainStrength), location: 0.00),
                        .init(color: cyan.alpha(0.42 * p.coreOpacity * p.brainStrength), location: 0.30),
                        .init(color: blue.alpha(0.28 * p.coreOpacity * p.brainStrength), location: 0.62),
                        .init(color: .clear, location: 1.00)
                    ]),
                    center: CGPoint(x: center.x - radius * 0.08, y: center.y - radius * 0.08),
                    startRadius: 0,
                    endRadius: radius * 1.45
                )
            )
        }

        drawReferenceCoreTangle(context: &context, center: center, radius: radius, theta: theta)

        // 大旋涡弧：模拟中心能量绕行和翻涌。
        let swirlCount = max(1, p.neuralLineCount / 5)
        for i in 0..<swirlCount {
            let f = CGFloat(i)
            let orbitCycles = CGFloat([1, 2, -1, -2, 3, -3][i % 6])
            let distortionCycles = CGFloat([1, -1, 2, -2, 3, -3][(i + 2) % 6])
            let path = liquidArcPath(
                center: center,
                radius: radius * (0.20 + f * 0.045 + p.brainRadius * 0.10),
                startAngle: hashed(f * 21.0 + 6.0) * tau + theta * orbitCycles,
                length: 0.10 + hashed(f * 13.0) * 0.20,
                amplitude: radius * (0.070 + f * 0.005) * p.ringAmplitude,
                samples: 22,
                theta: theta * distortionCycles,
                seed: f * 53.0 + 18.0
            )

            // 粗模糊底光。
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: radius * 0.052 * p.bloom))
                layer.stroke(
                    path,
                    with: .color(blue.alpha(0.20 * p.brainStrength)),
                    style: StrokeStyle(lineWidth: radius * 0.070 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }
            // 清晰青色弧线。
            context.stroke(
                path,
                with: .color(cyan.alpha((0.26 + f * 0.006) * p.brainStrength)),
                style: StrokeStyle(lineWidth: radius * 0.013 * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }

        // 白色细高光：模拟核心局部闪电和亮斑。
        for i in 0..<max(0, p.neuralNodeCount) {
            let seed = CGFloat(i) * 46.0 + 2.0
            let spin = CGFloat([-1, 1, -2, 2][i % 4])
            let path = liquidArcPath(
                center: center,
                radius: radius * (0.22 + hashed(seed) * 0.58 + p.brainRadius * 0.14),
                startAngle: hashed(seed + 2.0) * tau + theta * spin,
                length: 0.07 + hashed(seed + 6.0) * 0.18,
                amplitude: radius * 0.070 * p.ringAmplitude,
                samples: 14,
                theta: theta,
                seed: seed
            )
            context.stroke(
                path,
                with: .color(white.alpha((0.12 + 0.36 * flashPulse(theta: theta, cycles: 1 + i % 3, seed: seed, power: 2.7)) * p.coreOpacity)),
                style: StrokeStyle(lineWidth: radius * 0.010 * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }
    }

    /// 绘制核心里的短折线电浆团。
    ///
    /// 参考视频中心不是规则旋涡，而是很多短促、折返、互相叠加的亮线。
    /// 这里用确定性折线生成一个会循环流动的核心团块。
    private func drawReferenceCoreTangle(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let cyan = Color(red: 0.04, green: 0.86, blue: 1.00)
        let blue = Color(red: 0.00, green: 0.34, blue: 1.00)
        let white = Color(red: 0.88, green: 1.00, blue: 1.00)
        let count = max(10, p.neuralLineCount / 3)

        for i in 0..<count {
            let seed = CGFloat(i) * 39.71 + 5.0
            let path = coreTanglePath(center: center, radius: radius, theta: theta, seed: seed, index: i)
            let gate = 0.36 + 0.64 * flashPulse(theta: theta, cycles: 1 + i % 4, seed: seed, power: 2.6)
            let hot = gate > 0.86 || i % 13 == 0

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: radius * 0.034 * p.bloom))
                layer.stroke(
                    path,
                    with: .color(blue.alpha(0.16 * gate * p.brainStrength)),
                    style: StrokeStyle(lineWidth: radius * 0.030 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }

            context.stroke(
                path,
                with: .color((hot ? white : cyan).alpha((hot ? 0.42 : 0.24) * gate * p.coreOpacity)),
                style: StrokeStyle(lineWidth: radius * (hot ? 0.012 : 0.008) * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }
    }

    /// 绘制从中心向外延伸的白蓝电弧。
    ///
    /// 对应参考图效果：
    /// - 图一有局部很亮的白蓝连接光，不是均匀发亮。
    /// - 这些电弧用二次贝塞尔曲线从核心拉到外层，带有闪烁门控。
    ///
    /// 常用调参：
    /// - `0..<10`：电弧数量。
    /// - `gate > 0.035`：显示阈值，调高会减少电弧出现时间。
    /// - `power: 4.2`：闪烁尖锐度，越大越像瞬间闪电。
    /// - `outerRadius * 0.030`：电弧辉光粗细。
    private func drawReferenceLightning(context: inout GraphicsContext, center: CGPoint, outerRadius: CGFloat, coreRadius: CGFloat, theta: CGFloat) {
        let white = Color(red: 0.92, green: 1.00, blue: 1.00)
        let cyan = Color(red: 0.05, green: 0.82, blue: 1.00)

        for i in 0..<max(0, p.sparkCount) {
            let seed = CGFloat(i) * 31.8 + 4.0
            let gate = flashPulse(theta: theta, cycles: 1 + i % 4, seed: seed, power: 5.0)
            guard gate > 0.055 else { continue }

            let startAngle = hashed(seed) * tau + theta * CGFloat(i % 2 == 0 ? 1 : -1)
            let endAngle = startAngle + (hashed(seed + 1.0) - 0.5) * 1.20
            let startRadius = coreRadius * (0.34 + hashed(seed + 2.0) * 0.58)
            let endRadius = outerRadius * (0.35 + hashed(seed + 3.0) * 0.42)
            let start = CGPoint(x: center.x + cos(startAngle) * startRadius, y: center.y + sin(startAngle) * startRadius)
            let end = CGPoint(x: center.x + cos(endAngle) * endRadius, y: center.y + sin(endAngle) * endRadius)
            let control = CGPoint(
                x: center.x + cos((startAngle + endAngle) * 0.5 + sin(theta + seed) * 0.4) * outerRadius * 0.25,
                y: center.y + sin((startAngle + endAngle) * 0.5 + cos(theta + seed) * 0.4) * outerRadius * 0.25
            )

            var path = Path()
            path.move(to: start)
            path.addQuadCurve(to: end, control: control)

            // 模糊蓝色外光。
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: outerRadius * 0.018 * p.bloom))
                layer.stroke(
                    path,
                    with: .color(cyan.alpha(0.22 * gate * p.brainStrength)),
                    style: StrokeStyle(lineWidth: outerRadius * 0.024 * p.sharpness, lineCap: .round, lineJoin: .round)
                )
            }
            // 白色细线高光。
            context.stroke(
                path,
                with: .color(white.alpha(0.38 * gate * p.coreOpacity)),
                style: StrokeStyle(lineWidth: outerRadius * 0.007 * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }
    }

    /// 旧版外圈整体光晕。
    ///
    /// 当前主渲染没有调用，保留给旧版“科技脑圆环”效果。
    /// 如果恢复调用：
    /// - 调大 `p.outerRingStrength` 会让外侧蓝色光晕更强。
    /// - 调大 `p.bloom` 会让光晕扩散更远。
    private func drawOuterAura(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let pulse = 0.82 + 0.18 * sin(theta * 2.0 + 0.30)
        let opacity = 0.17 * p.outerRingStrength * p.bloom * pulse

        context.drawLayer { layer in
            layer.addFilter(.blur(radius: max(8, radius * 0.20 * p.bloom)))
            layer.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - radius * 1.38,
                    y: center.y - radius * 1.30,
                    width: radius * 2.76,
                    height: radius * 2.60
                )),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: Color(red: 0.00, green: 0.88, blue: 1.00).alpha(opacity), location: 0.00),
                        .init(color: Color(red: 0.00, green: 0.36, blue: 1.00).alpha(opacity * 0.50), location: 0.43),
                        .init(color: Color(red: 0.00, green: 0.05, blue: 0.30).alpha(opacity * 0.25), location: 0.70),
                        .init(color: .clear, location: 1.00)
                    ]),
                    center: center,
                    startRadius: 0,
                    endRadius: radius * 1.52
                )
            )
        }
    }

    /// 旧版规则液态外环。
    ///
    /// 当前主渲染没有调用，因为它会产生图二那种过于规整的圆环。
    /// 如果恢复调用：
    /// - `0..<5` 控制连续圆环层数。
    /// - `p.outerArcCount` 控制外环短弧数量。
    /// - `p.ringAmplitude` 控制圆环波动幅度。
    /// - `p.sharpness` 控制线条锐度。
    private func drawOuterLiquidRing(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let cyan = Color(red: 0.02, green: 0.74, blue: 1.00)
        let blue = Color(red: 0.00, green: 0.26, blue: 1.00)
        let white = Color(red: 0.76, green: 0.98, blue: 1.00)

        for layerIndex in 0..<5 {
            let f = CGFloat(layerIndex)
            let localRadius = radius * (0.955 + f * 0.014)
            let amplitude = radius * (0.018 + f * 0.006) * p.ringAmplitude
            let path = wavyRingPath(
                center: center,
                radius: localRadius,
                amplitude: amplitude,
                samples: 240,
                theta: theta,
                seed: 17.0 + f * 41.0,
                phaseShift: f * 0.47
            )

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: radius * (0.030 + f * 0.006) * p.bloom))
                layer.stroke(
                    path,
                    with: .color(blue.alpha(0.17 * p.outerRingStrength)),
                    style: StrokeStyle(lineWidth: radius * (0.070 - f * 0.006), lineCap: .round, lineJoin: .round)
                )
            }

            context.stroke(
                path,
                with: .color(cyan.alpha((0.15 + 0.050 * f) * p.outerRingStrength)),
                style: StrokeStyle(lineWidth: radius * (0.027 - f * 0.0028) * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }

        for i in 0..<p.outerArcCount {
            let seed = CGFloat(i) * 91.7 + 12.3
            let rotation = CGFloat([1, -1, 2, -2, 3, -3][i % 6])
            let start = hashed(seed) * tau + theta * rotation
            let length = 0.10 + hashed(seed + 3.0) * 0.24
            let gate = flashPulse(theta: theta, cycles: 1 + (i % 4), seed: seed, power: 2.7)
            let arcOpacity = (0.15 + 0.85 * gate) * p.outerRingStrength
            let arc = liquidArcPath(
                center: center,
                radius: radius * (0.965 + hashed(seed + 7.0) * 0.070),
                startAngle: start,
                length: length,
                amplitude: radius * 0.022 * p.ringAmplitude,
                samples: 24,
                theta: theta,
                seed: seed
            )

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: radius * 0.030 * p.bloom))
                layer.stroke(
                    arc,
                    with: .color(cyan.alpha(0.30 * arcOpacity)),
                    style: StrokeStyle(lineWidth: radius * 0.040, lineCap: .round, lineJoin: .round)
                )
            }

            context.stroke(
                arc,
                with: .color((gate > 0.75 ? white : cyan).alpha(0.52 * arcOpacity)),
                style: StrokeStyle(lineWidth: radius * 0.014 * p.sharpness, lineCap: .round, lineJoin: .round)
            )
        }

        drawReferenceLikeBottomTail(context: &context, center: center, radius: radius, theta: theta)
    }

    /// 旧版底部拖尾。
    ///
    /// 当前主渲染没有调用。
    /// 用途是给圆环底部加一条向下的能量尾巴；参考图一并不明显，所以当前关闭。
    /// 调大线宽或 alpha 会让底部拖尾更亮更长。
    private func drawReferenceLikeBottomTail(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        guard p.outerRingStrength > 0.42 else { return }
        let pulse = flashPulse(theta: theta, cycles: 2, seed: 44.0, power: 4.0)
        let baseX = center.x + sin(theta * 2.0 + 0.9) * radius * 0.10
        let y0 = center.y + radius * 0.90
        var path = Path()
        path.move(to: CGPoint(x: baseX, y: y0))
        path.addCurve(
            to: CGPoint(x: baseX + sin(theta) * radius * 0.03, y: y0 + radius * 0.34),
            control1: CGPoint(x: baseX - radius * 0.05, y: y0 + radius * 0.10),
            control2: CGPoint(x: baseX + radius * 0.04, y: y0 + radius * 0.22)
        )
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: radius * 0.032 * p.bloom))
            layer.stroke(
                path,
                with: .color(Color(red: 0.04, green: 0.70, blue: 1.00).alpha(0.16 * pulse * p.outerRingStrength)),
                style: StrokeStyle(lineWidth: radius * 0.026, lineCap: .round)
            )
        }
    }

    /// 旧版内层膜。
    ///
    /// 当前主渲染没有调用。
    /// 用途是在外圈和中心之间画一层半透明环形膜。
    /// - `membraneRadius` 控制膜的位置。
    /// - `p.membraneOpacity` 控制膜的显眼程度。
    /// - `p.ringAmplitude` 控制膜边缘波动。
    private func drawInnerMembrane(context: inout GraphicsContext, center: CGPoint, outerRadius: CGFloat, brainRadius: CGFloat, theta: CGFloat) {
        let membraneRadius = (outerRadius + brainRadius) * 0.53
        let pulse = 0.80 + 0.20 * sin(theta * 2.0 + 1.3)
        let path = wavyRingPath(
            center: center,
            radius: membraneRadius,
            amplitude: outerRadius * 0.020 * p.ringAmplitude,
            samples: 180,
            theta: theta,
            seed: 502.0,
            phaseShift: 1.0
        )

        context.drawLayer { layer in
            layer.addFilter(.blur(radius: outerRadius * 0.050 * p.bloom))
            layer.stroke(
                path,
                with: .color(Color(red: 0.00, green: 0.56, blue: 1.00).alpha(0.10 * p.brainStrength * p.membraneOpacity * pulse)),
                style: StrokeStyle(lineWidth: outerRadius * 0.17, lineCap: .round, lineJoin: .round)
            )
        }

        context.stroke(
            path,
            with: .color(Color(red: 0.03, green: 0.76, blue: 1.00).alpha(0.16 * p.brainStrength * p.membraneOpacity * pulse)),
            style: StrokeStyle(lineWidth: outerRadius * 0.018 * p.sharpness, lineCap: .round, lineJoin: .round)
        )
    }

    /// 旧版中心脑核心填充。
    ///
    /// 当前主渲染没有调用。
    /// 用途是填充一个脑形轮廓，形成图二中的“蓝色小脑团”。
    /// 如果恢复调用，调大 `radius` 或 `p.coreOpacity` 会让中心脑团更大更亮。
    private func drawBrainCore(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let pulse = 0.82 + 0.18 * sin(theta * 2.0 + 0.2)
        let clip = brainSilhouette(center: center, radius: radius, theta: theta)
        let coreOpacity = min(1.0, 0.48 * p.coreOpacity * p.brainStrength * pulse)

        context.drawLayer { layer in
            layer.addFilter(.blur(radius: max(4, radius * 0.25 * p.bloom)))
            layer.fill(
                clip,
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: Color(red: 0.18, green: 0.96, blue: 1.00).alpha(coreOpacity), location: 0.00),
                        .init(color: Color(red: 0.00, green: 0.43, blue: 1.00).alpha(coreOpacity * 0.60), location: 0.46),
                        .init(color: .clear, location: 1.00)
                    ]),
                    center: CGPoint(x: center.x - radius * 0.10, y: center.y - radius * 0.10),
                    startRadius: 0,
                    endRadius: radius * 1.55
                )
            )
        }

        context.fill(
            clip,
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: Color(red: 0.07, green: 0.80, blue: 1.00).alpha(0.22 * p.coreOpacity * p.brainStrength), location: 0.0),
                    .init(color: Color(red: 0.00, green: 0.18, blue: 0.66).alpha(0.16 * p.coreOpacity * p.brainStrength), location: 0.58),
                    .init(color: .clear, location: 1.0)
                ]),
                center: CGPoint(x: center.x - radius * 0.10, y: center.y - radius * 0.08),
                startRadius: 0,
                endRadius: radius * 1.18
            )
        )

        let highlight = Path(ellipseIn: CGRect(
            x: center.x - radius * 0.72,
            y: center.y - radius * 0.68,
            width: radius * 1.05,
            height: radius * 0.90
        ))
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: radius * 0.16))
            layer.fill(highlight, with: .color(Color.white.alpha(0.10 * p.coreOpacity * p.brainStrength * pulse)))
        }
    }

    /// 旧版脑沟回线条。
    ///
    /// 当前主渲染没有调用。
    /// 用途是给 `drawBrainCore` 生成脑纹理曲线。
    /// - `p.brainLayers` 越大，线条数量越多。
    /// - `p.brainStrength` 越大，线条越亮。
    /// - `p.sharpness` 越大，线条越细锐。
    private func drawBrainFolds(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        guard p.brainStrength > 0.12 else { return }
        let clip = brainSilhouette(center: center, radius: radius * 1.02, theta: theta)
        let cyan = Color(red: 0.02, green: 0.78, blue: 1.00)
        let blue = Color(red: 0.00, green: 0.30, blue: 0.92)

        context.drawLayer { layer in
            layer.clip(to: clip)

            let count = 5 + p.brainLayers * 3
            for i in 0..<count {
                let seed = CGFloat(i) * 37.7 + 6.0
                let path = brainFoldPath(center: center, radius: radius, index: i, theta: theta, seed: seed)
                let gate = 0.58 + 0.42 * sin(theta * CGFloat(1 + i % 3) + seed)
                let alpha = (0.055 + 0.15 * gate) * p.brainStrength
                let width = radius * (0.020 + hashed(seed + 2.0) * 0.014) * p.sharpness

                layer.drawLayer { glow in
                    glow.addFilter(.blur(radius: radius * 0.050 * p.bloom))
                    glow.stroke(
                        path,
                        with: .color(blue.alpha(alpha * 0.65)),
                        style: StrokeStyle(lineWidth: width * 3.0, lineCap: .round, lineJoin: .round)
                    )
                }

                layer.stroke(
                    path,
                    with: .color(cyan.alpha(alpha)),
                    style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }

    /// 旧版中心神经网络线条。
    ///
    /// 当前主渲染没有调用。
    /// 用途是生成图二那种中心缠绕的细线网络。
    /// 如果你想回到“AI 大脑”感觉，可恢复调用这个函数；
    /// 如果想像参考图一，应继续关闭，因为它会让中心太像线团。
    /// - `p.neuralLineCount` 控制线条密度。
    /// - `p.brainLayers` 控制分层数量。
    /// - `gate > 0.82` 控制白色瞬时高光出现条件。
    private func drawNeuralNetwork(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let clip = brainSilhouette(center: center, radius: radius * 1.05, theta: theta)
        let cyan = Color(red: 0.00, green: 0.84, blue: 1.00)
        let deepBlue = Color(red: 0.00, green: 0.30, blue: 1.00)
        let white = Color(red: 0.86, green: 1.00, blue: 1.00)

        context.drawLayer { layer in
            layer.clip(to: clip)

            for layerIndex in 0..<p.brainLayers {
                let layerPhase = theta + CGFloat(layerIndex) * 0.37
                let count = max(4, p.neuralLineCount / max(1, p.brainLayers))

                for i in 0..<count {
                    let globalIndex = i + layerIndex * 101
                    let seed = CGFloat(globalIndex) * 43.21 + 9.7
                    let path = neuralPath(
                        center: center,
                        radius: radius * (0.78 + CGFloat(layerIndex) * 0.065),
                        index: globalIndex,
                        theta: layerPhase,
                        seed: seed
                    )

                    let gate = 0.52 + 0.48 * sin(theta * CGFloat(1 + globalIndex % 4) + seed)
                    let alpha = (0.10 + 0.28 * max(0, gate)) * p.brainStrength
                    let lineWidth = radius * (0.016 + hashed(seed + 5.0) * 0.015) * p.sharpness

                    layer.drawLayer { glow in
                        glow.addFilter(.blur(radius: radius * (0.035 + CGFloat(layerIndex) * 0.008) * p.bloom))
                        glow.stroke(
                            path,
                            with: .color(deepBlue.alpha(alpha * 0.70)),
                            style: StrokeStyle(lineWidth: lineWidth * 3.5, lineCap: .round, lineJoin: .round)
                        )
                    }

                    layer.stroke(
                        path,
                        with: .color(cyan.alpha(alpha)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                    )

                    if gate > 0.82 {
                        layer.stroke(
                            path,
                            with: .color(white.alpha((gate - 0.82) * 2.5 * p.brainStrength)),
                            style: StrokeStyle(lineWidth: lineWidth * 0.55, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
            }
        }
    }

    /// 旧版中心节点闪点。
    ///
    /// 当前主渲染没有调用。
    /// 用途是给中心神经网络加白色小光点。
    /// - `p.neuralNodeCount` 控制节点数量。
    /// - `power: 5.0` 控制闪烁尖锐度。
    /// - `nodeRadius` 控制光点大小。
    private func drawCoreSparks(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        let color = Color(red: 0.82, green: 1.00, blue: 1.00)
        let count = p.neuralNodeCount
        guard count > 0 else { return }

        for i in 0..<count {
            let seed = CGFloat(i) * 69.31 + 33.0
            let point = brainPoint(center: center, radius: radius * 0.88, seed: seed, theta: theta)
            let pulse = flashPulse(theta: theta, cycles: 1 + (i % 5), seed: seed, power: 5.0)
            let nodeRadius = radius * (0.018 + hashed(seed + 2.0) * 0.026) * (0.70 + p.brainStrength * 0.42)
            let opacity = (0.07 + 0.70 * pulse) * min(1.0, p.brainStrength)
            let rect = CGRect(x: point.x - nodeRadius, y: point.y - nodeRadius, width: nodeRadius * 2, height: nodeRadius * 2)

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: nodeRadius * 2.25 * p.bloom))
                layer.fill(
                    Path(ellipseIn: rect.insetBy(dx: -nodeRadius * 2.8, dy: -nodeRadius * 2.8)),
                    with: .color(color.alpha(opacity * 0.30))
                )
            }
            context.fill(Path(ellipseIn: rect), with: .color(color.alpha(opacity)))
        }
    }

    /// 旧版外圈粒子闪点。
    ///
    /// 当前主渲染没有调用。
    /// 用途是在外圈附近添加漂浮粒子。
    /// - `p.sparkCount` 控制粒子数量。
    /// - `rotation` 控制粒子绕行方向。
    /// - `guard pulse > 0.045` 控制粒子是否在当前帧出现。
    private func drawOuterSparks(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, theta: CGFloat) {
        guard p.sparkCount > 0 else { return }
        let color = Color(red: 0.72, green: 0.98, blue: 1.00)

        for i in 0..<p.sparkCount {
            let seed = CGFloat(i) * 103.3 + 7.0
            let rotation = CGFloat([1, -1, 2, -2][i % 4])
            let angle = hashed(seed) * tau + theta * rotation
            let pulse = flashPulse(theta: theta, cycles: 1 + (i % 4), seed: seed + 3.0, power: 7.0)
            guard pulse > 0.045 else { continue }

            let r = radius * (0.86 + hashed(seed + 4.0) * 0.22)
            let point = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            let dot = radius * (0.006 + hashed(seed + 2.0) * 0.011) * p.sharpness
            let rect = CGRect(x: point.x - dot, y: point.y - dot, width: dot * 2, height: dot * 2)

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: dot * 4.5 * p.bloom))
                layer.fill(Path(ellipseIn: rect.insetBy(dx: -dot * 3, dy: -dot * 3)), with: .color(color.alpha(0.25 * pulse * p.outerRingStrength)))
            }
            context.fill(Path(ellipseIn: rect), with: .color(color.alpha(0.85 * pulse * p.outerRingStrength)))
        }
    }

    /// 生成旧版脑形轮廓路径。
    ///
    /// 当前主渲染没有调用。
    /// 用途是给旧版中心脑核心、脑沟回、神经网络提供裁剪形状。
    /// 调参效果：
    /// - `samples` 越大轮廓越平滑，但绘制成本更高。
    /// - `lobeNoise` 里的 sin 项决定脑轮廓起伏。
    /// - `centerIndent` / `lowerIndent` 控制上、下凹陷。
    private func brainSilhouette(center: CGPoint, radius: CGFloat, theta: CGFloat) -> Path {
        var path = Path()
        let samples = 128
        for i in 0...samples {
            let u = CGFloat(i) / CGFloat(samples)
            let angle = u * tau
            let topLift = 1.0 + 0.04 * max(0, -sin(angle))
            let lobeNoise = 1.0
                + 0.055 * sin(angle * 2.0 + theta)
                + 0.040 * sin(angle * 5.0 - theta * 2.0 + 0.7)
                + 0.025 * sin(angle * 9.0 + theta * 3.0 + 1.9)
            let centerIndent = 1.0 - 0.10 * exp(-pow(abs(angle - .pi * 0.5) / 0.23, 2.0))
            let lowerIndent = 1.0 - 0.08 * exp(-pow(abs(angle - .pi * 1.5) / 0.25, 2.0))
            let localRadius = radius * lobeNoise * topLift * centerIndent * lowerIndent
            let point = CGPoint(
                x: center.x + cos(angle) * localRadius * 1.06,
                y: center.y + sin(angle) * localRadius * 0.92
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }

    /// 生成一条闭合的不规则圆环路径。
    ///
    /// 当前主渲染大量使用它绘制电浆外壳和内部淡环。
    /// 参数调节效果：
    /// - `radius`：圆环基础半径。
    /// - `amplitude`：圆环边缘破碎/起伏幅度，越大越像电浆乱流。
    /// - `samples`：采样点数量，越大越平滑；太低会显得多边形。
    /// - `theta`：动画相位，改变它会让波纹流动。
    /// - `seed`：固定随机种子，不同 seed 生成不同形状。
    /// - `phaseShift`：额外相位偏移，用于错开多层圆环。
    private func wavyRingPath(center: CGPoint, radius: CGFloat, amplitude: CGFloat, samples: Int, theta: CGFloat, seed: CGFloat, phaseShift: CGFloat) -> Path {
        var path = Path()
        for sample in 0...samples {
            let u = CGFloat(sample) / CGFloat(samples)
            let angle = u * tau
            let noise = ringNoise(angle: angle, theta: theta, seed: seed, phaseShift: phaseShift)
            let localRadius = radius + amplitude * noise
            let point = CGPoint(x: center.x + cos(angle) * localRadius, y: center.y + sin(angle) * localRadius)
            if sample == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }

    /// 生成一段不规则短弧路径。
    ///
    /// 当前主渲染用它绘制外壳碎片、中心旋涡和白色高光。
    /// 参数调节效果：
    /// - `startAngle`：短弧从哪个角度开始。
    /// - `length`：短弧占整圈的比例，0.10 约等于 36 度。
    /// - `amplitude`：短弧自身抖动幅度。
    /// - `samples`：短弧分段数量。
    /// - `taper = sin(u * .pi)`：让短弧两端自然收尖，中间最强。
    private func liquidArcPath(center: CGPoint, radius: CGFloat, startAngle: CGFloat, length: CGFloat, amplitude: CGFloat, samples: Int, theta: CGFloat, seed: CGFloat) -> Path {
        var path = Path()
        for sample in 0...samples {
            let u = CGFloat(sample) / CGFloat(samples)
            let angle = startAngle + u * length * tau
            let taper = sin(u * .pi)
            let localRadius = radius + amplitude * taper * ringNoise(angle: angle, theta: theta, seed: seed, phaseShift: 0.7)
            let point = CGPoint(x: center.x + cos(angle) * localRadius, y: center.y + sin(angle) * localRadius)
            if sample == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        return path
    }

    /// 生成核心短折线路径。
    ///
    /// 点位始终限制在核心附近，避免形成明显的大圆轨道。
    private func coreTanglePath(center: CGPoint, radius: CGFloat, theta: CGFloat, seed: CGFloat, index: Int) -> Path {
        let pointCount = 4 + Int(hashed(seed + 2.0) * 4.0)
        let baseAngle = hashed(seed) * tau + theta * CGFloat([1, -1, 2, -2][index % 4])
        let baseR = radius * (0.10 + hashed(seed + 1.0) * 0.46)
        var points: [CGPoint] = []

        for step in 0..<pointCount {
            let u = CGFloat(step) / CGFloat(max(1, pointCount - 1))
            let angle = baseAngle + (u - 0.5) * (0.85 + hashed(seed + 3.0) * 1.30)
                + sin(theta * CGFloat(1 + (index + step) % 3) + seed + u * tau) * 0.22
            let zigzag = sin(u * CGFloat(pointCount - 1) * .pi + seed) * radius * 0.16
            let localR = clamp(baseR + zigzag + radius * (hashed(seed + CGFloat(step) * 7.0) - 0.5) * 0.20, min: radius * 0.06, max: radius * 0.78)
            points.append(CGPoint(
                x: center.x + cos(angle) * localR * 1.04,
                y: center.y + sin(angle) * localR * 0.96
            ))
        }

        guard let first = points.first else { return Path() }
        var path = Path()
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }

    /// 生成旧版神经网络曲线路径。
    ///
    /// 当前主渲染没有调用。
    /// 用途是生成图二中心那类缠绕线团。
    /// 调参效果：
    /// - `pointCount` 决定曲线复杂度。
    /// - `turn` 决定曲线弯折范围。
    /// - `pulse` 让线条随时间轻微摆动。
    private func neuralPath(center: CGPoint, radius: CGFloat, index: Int, theta: CGFloat, seed: CGFloat) -> Path {
        var points: [CGPoint] = []
        let pointCount = 6 + Int(hashed(seed + 4.0) * 6.0)
        let baseAngle = hashed(seed) * tau
        let turnDirection: CGFloat = hashed(seed + 1.0) > 0.5 ? 1.0 : -1.0
        let turn = turnDirection * (0.70 + hashed(seed + 2.0) * 2.20)
        let baseR = 0.16 + hashed(seed + 3.0) * 0.50

        for step in 0..<pointCount {
            let u = CGFloat(step) / CGFloat(pointCount - 1)
            let waveCycles = CGFloat(1 + (index + step) % 4)
            let pulse = sin(u * tau + theta * waveCycles + seed)
            let angle = baseAngle + (u - 0.5) * turn + pulse * 0.24
            let fold = sin(u * .pi + seed * 0.03)
            let radial = radius * clamp(baseR + fold * 0.34 + pulse * 0.055, min: 0.08, max: 0.98)
            let hemisphereBias = sin(baseAngle * 2.0) * radius * 0.06
            points.append(CGPoint(
                x: center.x + cos(angle) * radial * 1.05 + hemisphereBias,
                y: center.y + sin(angle) * radial * 0.90
            ))
        }

        guard let first = points.first else { return Path() }
        var path = Path()
        path.move(to: first)
        if points.count == 1 { return path }

        for i in 1..<points.count {
            let previous = points[i - 1]
            let current = points[i]
            let mid = CGPoint(x: (previous.x + current.x) * 0.5, y: (previous.y + current.y) * 0.5)
            path.addQuadCurve(to: mid, control: previous)
            if i == points.count - 1 {
                path.addQuadCurve(to: current, control: mid)
            }
        }
        return path
    }

    /// 生成旧版脑沟回路径。
    ///
    /// 当前主渲染没有调用。
    /// 用途是画中心脑形轮廓内部的短曲线。
    /// 调参效果：
    /// - `side` 决定线条在左半脑还是右半脑。
    /// - `vertical` 决定线条垂直位置。
    /// - control 点决定曲线弯曲程度。
    private func brainFoldPath(center: CGPoint, radius: CGFloat, index: Int, theta: CGFloat, seed: CGFloat) -> Path {
        let side: CGFloat = index % 2 == 0 ? -1.0 : 1.0
        let vertical = -0.62 + CGFloat(index % 7) * 0.19
        let start = CGPoint(
            x: center.x + side * radius * (0.08 + hashed(seed) * 0.38),
            y: center.y + vertical * radius + sin(theta + seed) * radius * 0.035
        )
        let end = CGPoint(
            x: center.x + side * radius * (0.36 + hashed(seed + 1.0) * 0.42),
            y: center.y + (vertical + 0.06 + hashed(seed + 2.0) * 0.22) * radius
        )
        let control1 = CGPoint(
            x: center.x + side * radius * (0.18 + hashed(seed + 3.0) * 0.38),
            y: center.y + (vertical - 0.20 + sin(theta * 2.0 + seed) * 0.05) * radius
        )
        let control2 = CGPoint(
            x: center.x + side * radius * (0.44 + hashed(seed + 4.0) * 0.30),
            y: center.y + (vertical + 0.24 + cos(theta * 3.0 + seed) * 0.05) * radius
        )
        var path = Path()
        path.move(to: start)
        path.addCurve(to: end, control1: control1, control2: control2)
        return path
    }

    /// 生成旧版中心节点位置。
    ///
    /// 当前主渲染没有调用。
    /// 用途是把闪点分布在脑形核心内部。
    /// 调参效果：
    /// - `sqrt(...)` 让点更均匀地分布在圆内，而不是挤在中心。
    /// - `theta` 让点位轻微运动。
    private func brainPoint(center: CGPoint, radius: CGFloat, seed: CGFloat, theta: CGFloat) -> CGPoint {
        let angle = hashed(seed) * tau + sin(theta * CGFloat(1 + Int(seed) % 4) + seed) * 0.22
        let r = radius * sqrt(0.08 + hashed(seed + 1.0) * 0.92)
        return CGPoint(x: center.x + cos(angle) * r * 1.02, y: center.y + sin(angle) * r * 0.88)
    }

    /// 环形噪声函数。
    ///
    /// 当前主渲染的电浆壳破碎感主要来自这里。
    /// 它把多个不同频率的 sin 波叠加，得到可循环、可控、无随机跳变的噪声。
    /// 调参效果：
    /// - `n1` 低频控制大形变。
    /// - `n2/n3` 中频控制破碎纹理。
    /// - `n4/n5` 高频控制细碎抖动。
    /// - 每项后面的系数越大，该频率影响越强。
    private func ringNoise(angle: CGFloat, theta: CGFloat, seed: CGFloat, phaseShift: CGFloat) -> CGFloat {
        let a = angle + phaseShift
        let n1 = sin(a * 3.0 + theta * 1.0 + seed * 0.11) * 0.46
        let n2 = sin(a * 7.0 - theta * 2.0 + seed * 0.07) * 0.26
        let n3 = sin(a * 13.0 + theta * 3.0 + seed * 0.13) * 0.15
        let n4 = sin(a * 23.0 - theta * 4.0 + seed * 0.17) * 0.08
        let n5 = sin(a * 41.0 + theta * 5.0 + seed * 0.19) * 0.04
        return n1 + n2 + n3 + n4 + n5
    }

    /// 生成一个周期性闪烁脉冲。
    ///
    /// 当前主渲染用它控制短弧、电弧、白色高光的忽明忽暗。
    /// 参数调节效果：
    /// - `cycles`：一个循环内闪几次。
    /// - `seed`：错开不同元素的闪烁时间。
    /// - `power`：越大峰值越尖，越像瞬时闪电；越小越柔和。
    private func flashPulse(theta: CGFloat, cycles: Int, seed: CGFloat, power: CGFloat) -> CGFloat {
        let value = 0.5 + 0.5 * sin(theta * CGFloat(cycles) + seed)
        return pow(max(0, value), power)
    }

    /// 伪随机哈希函数。
    ///
    /// 输入一个固定数字，输出 0 到 1 的稳定随机值。
    /// 当前用于：
    /// - 错开短弧位置。
    /// - 错开粒子/闪电的角度。
    /// - 让每条路径有不同长度和半径。
    ///
    /// 注意：这是确定性的，不会每帧乱跳，所以动画能稳定循环。
    private func hashed(_ value: CGFloat) -> CGFloat {
        let raw = sin(value * 12.9898 + 78.233) * 43758.5453123
        return raw - floor(raw)
    }

    /// 限制数值范围。
    ///
    /// 用途是避免半径、透明度、随机结果超出合理范围。
    /// 调参时如果看到元素跑出球体范围，可以检查调用处的 clamp 上下限。
    private func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
        Swift.max(lower, Swift.min(upper, value))
    }
}

private extension Color {
    /// 用 CGFloat 设置 SwiftUI Color 透明度的小工具。
    ///
    /// 会自动把输入夹到 0...1，避免透明度小于 0 或大于 1。
    func alpha(_ value: CGFloat) -> Color {
        opacity(Double(Swift.max(0.0, Swift.min(1.0, value))))
    }
}
