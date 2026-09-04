import SwiftUI
import Foundation

struct ThinkingOrbsPill: View {
    /// 当前系统的深浅色模式；未显式传入 `scheme` 时用于自动选择配色。
    @Environment(\.colorScheme) var systemScheme
    /// 球体右侧显示的提示文案。
    var label: String = "Reasoning..."
    /// 是否显示球体外层的胶囊背景及对应内边距。
    var showsPill: Bool = true
    /// 是否在胶囊内显示右侧提示文案。
    var showsLabel: Bool = true
    /// 动画播放速度倍率；`1.0` 表示使用默认周期。
    var speed: Double = 1.0
    /// 是否反向播放球体动画。
    var reverse: Bool = false
    /// 动画起始相位，取值以一个完整周期为 `1.0`。
    var startAt: Double = 0.0
    /// 单个点尺寸的缩放倍率。
    var dotScale: Double = 1.0
    /// 点阵密度倍率，用于控制球体包含的点数量。
    var dots: Double = 1.0
    /// 点阵分布范围倍率，用于控制球体的疏密程度。
    var spread: Double = 1.0
    /// 透视强度倍率，用于控制前后景点阵的投影差异。
    var perspective: Double = 1.0
    /// 景深尺寸倍率，用于控制近处与远处点的大小差异。
    var depthSize: Double = 1.0
    /// 景深透明度倍率，用于控制远近点的明暗衰减。
    var depthFade: Double = 1.0
    /// 整体点阵透明度倍率。
    var dotOpacity: Double = 1.0
    /// 球体围绕自身轴线持续旋转的速度参数。
    var spin: Double = 0.0
    /// 球体水平方向的初始旋转角度，单位为度。
    var turn: Double = 0.0
    /// 球体垂直方向的初始倾斜角度，单位为度。
    var tilt: Double = 0.0
    /// 球体画布的边长，单位为 point。
    var ballSize: CGFloat = 46.0
    /// 指定使用的深浅色模式；为 `nil` 时跟随系统设置。
    var scheme: ColorScheme? = nil
    /// 深色模式下的普通点颜色。
    var dotColor: Color = Color(red: 0.824, green: 0.827, blue: 0.831, opacity: 0.8)
    /// 强调点颜色；当前球体样式支持用它区分特殊点。
    var accentColor: Color = Color(.sRGB, red: 0.9098, green: 0.5216, blue: 0.2353)
    /// 深色模式下的胶囊背景颜色。
    var pillColor: Color = Color(.sRGB, red: 0.1059, green: 0.1059, blue: 0.1137)
    /// 深色模式下的提示文案颜色。
    var labelColor: Color = Color(.sRGB, red: 0.9569, green: 0.9451, blue: 0.9176)
    /// 浅色模式下的普通点颜色。
    var dotColorLight: Color = Color(.sRGB, red: 0.1451, green: 0.1412, blue: 0.1647)
    /// 浅色模式下的胶囊背景颜色。
    var pillColorLight: Color = Color(.sRGB, red: 1.0, green: 1.0, blue: 1.0)
    /// 浅色模式下的提示文案颜色。
    var labelColorLight: Color = Color(.sRGB, red: 0.1451, green: 0.1412, blue: 0.1647)

    /// 当前最终生效的模式是否为深色模式。
    private var isDark: Bool { (scheme ?? systemScheme) == .dark }
    /// 根据当前模式选择最终使用的普通点颜色。
    private var dotInk: Color { isDark ? dotColor : dotColorLight }
    /// 根据当前模式选择最终使用的胶囊背景颜色。
    private var chipInk: Color { isDark ? pillColor : pillColorLight }
    /// 根据当前模式选择最终使用的提示文案颜色。
    private var labelInk: Color { isDark ? labelColor : labelColorLight }

    /// 组合点阵球、可选提示文案和可选胶囊背景，生成组件的最终界面。
    var body: some View {
        HStack(spacing: 9.0) {
            ThinkingOrbsBall(
                style: 6,
                period: 4.8,
                speed: speed,
                reverse: reverse,
                startAt: startAt,
                animated: true,
                dotScale: dotScale,
                dots: dots,
                spread: spread,
                perspective: perspective,
                depthSize: depthSize,
                depthFade: depthFade,
                dotOpacity: dotOpacity,
                spin: spin,
                turn: turn,
                tilt: tilt,
                dot: dotInk,
                accent: accentColor)
                .frame(width: ballSize, height: ballSize)
            if showsPill && showsLabel {
                Text(label)
                    .font(.system(size: 14.0, design: .monospaced))
                    .foregroundStyle(labelInk.opacity(0.74))
                    .fixedSize()
            }
        }
        .padding(showsPill ? (showsLabel ? EdgeInsets(top: 7.0, leading: 8.0, bottom: 7.0, trailing: 22.0) : EdgeInsets(top: 7.0, leading: 7.0, bottom: 7.0, trailing: 7.0)) : EdgeInsets())
        .background(Capsule().fill(showsPill ? chipInk : .clear))
    }
}

private struct ThinkingOrbsBall: View {
    /// 球体绘制样式编号；当前页面使用样式 `6`。
    let style: Int
    /// 完成一次动画循环所需的基础秒数。
    let period: Double
    /// 动画播放速度倍率。
    let speed: Double
    /// 是否反向推进动画相位。
    let reverse: Bool
    /// 动画初始相位偏移量。
    let startAt: Double
    /// 是否根据时间轴持续刷新画布。
    let animated: Bool
    /// 点半径的缩放倍率。
    let dotScale: Double
    /// 点阵数量的密度倍率。
    let dots: Double
    /// 点阵空间分布的缩放倍率。
    let spread: Double
    /// 三维投影的透视倍率。
    let perspective: Double
    /// 点半径随景深变化的倍率。
    let depthSize: Double
    /// 点透明度随景深变化的倍率。
    let depthFade: Double
    /// 点阵整体透明度倍率。
    let dotOpacity: Double
    /// 围绕球体轴线持续旋转的速度。
    let spin: Double
    /// 水平方向的初始旋转角度。
    let turn: Double
    /// 垂直方向的初始倾斜角度。
    let tilt: Double
    /// 普通点的绘制颜色。
    let dot: Color
    /// 强调点的绘制颜色。
    let accent: Color

    /// 根据 `animated` 决定使用动态时间轴还是固定首帧。
    var body: some View {
        if animated {
            TimelineView(.animation) { timeline in
                canvas(at: timeline.date.timeIntervalSinceReferenceDate)
            }
        } else {
            canvas(at: 0)
        }
    }

    /// 计算指定时间对应的点阵，并将所有点绘制到 SwiftUI 画布中。
    /// - Parameter seconds: 当前时间轴时间，单位为秒。
    private func canvas(at seconds: Double) -> some View {
        Canvas { context, size in
            let box = min(size.width, size.height)
            let ox = (size.width - box) / 2
            let oy = (size.height - box) / 2
            let phase = orbPhase(period: period, speed: speed, reverse: reverse, startAt: startAt, seconds: seconds)
            let dots = orbSheetDots(
                style: style,
                phase: phase,
                size: box,
                dotScale: orbSizeDotScale(box) * dotScale,
                knobs: OrbKnobs(n: dots, sp: spread, pv: perspective, dz: depthSize, df: depthFade, yw: turn * orbDegree, pc: tilt * orbDegree, sn: spin, op: dotOpacity))
            for d in dots {
                let rect = CGRect(
                    x: ox + d.x - d.r,
                    y: oy + d.y - d.r,
                    width: d.r * 2,
                    height: d.r * 2)
                context.fill(Path(ellipseIn: rect), with: .color((d.accent ? accent : dot).opacity(d.a)))
            }
        }
    }
}

/// 将角度转换为弧度时使用的单位系数。
private let orbDegree: Double = Double.pi / 180

/// 根据时间、周期和播放选项计算归一化动画相位。
private func orbPhase(period: Double, speed: Double, reverse: Bool, startAt: Double, seconds: Double) -> Double {
    let p = period / orbMax(0.0001, speed)
    var u = orbMod(seconds, p) / p
    if u < 0 { u += 1 }
    if reverse { u = 1 - u }
    u = orbMod(u + startAt, 1)
    return u < 0 ? u + 1 : u
}

#Preview {
    ThinkingOrbsPill()
}

private struct OrbVec {
    /// 向量中按约定顺序保存的数值。
    let a: [Double]
    /// 使用给定数值数组创建向量。
    init(_ a: [Double]) { self.a = a }
    /// 使用浮点索引读取向量元素，越界时返回 `NaN` 以兼容原始算法。
    subscript(_ i: Double) -> Double {
        guard i >= 0, i < Double(a.count) else { return Double.nan }
        return a[Int(i)]
    }
    /// 向量元素个数，使用 `Double` 表示以兼容 JavaScript 计算逻辑。
    var jsLength: Double { Double(a.count) }
    /// 将另一个向量的元素追加到当前向量并返回新值。
    func concat(_ other: OrbVec) -> OrbVec { OrbVec(a + other.a) }
}

extension Array where Element == OrbVec {
    /// 使用浮点索引读取向量数组，越界时返回空向量。
    fileprivate subscript(_ i: Double) -> OrbVec {
        guard i >= 0, i < Double(count) else { return OrbVec([]) }
        return self[Int(i)]
    }
    /// 数组元素个数的 `Double` 表示，用于兼容原始算法。
    fileprivate var jsLength: Double { Double(count) }
}

private struct OrbKnobs {
    /// 点阵数量倍率。
    var n: Double = 1
    /// 点阵空间分布倍率。
    var sp: Double = 1
    /// 透视强度倍率。
    var pv: Double = 1
    /// 点半径的景深倍率。
    var dz: Double = 1
    /// 点透明度的景深衰减倍率。
    var df: Double = 1
    /// 水平旋转角，单位为弧度。
    var yw: Double = 0
    /// 垂直倾斜角，单位为弧度。
    var pc: Double = 0
    /// 持续自转速度。
    var sn: Double = 0
    /// 点阵整体透明度倍率。
    var op: Double = 1
    /// 所有调节参数均采用默认值的配置。
    static let identity = OrbKnobs()
    /// 影响边界拟合结果的参数组合，用作拟合缓存键的一部分。
    var fitKey: String { "(n)/(sp)/(pv)/(dz)/(df)/(yw)/(pc)/(sn)" }
}

private final class OrbSink {
    /// 点半径基础缩放值。
    let ds: Double
    /// 普通点对应的颜色标识值。
    let dot: Double
    /// 强调点对应的颜色标识值。
    let acc: Double
    /// 点阵数量倍率。
    let n: Double
    /// 点阵空间分布倍率。
    let sp: Double
    /// 透视强度倍率。
    let pv: Double
    /// 点半径的景深倍率。
    let dz: Double
    /// 点透明度的景深衰减倍率。
    let df: Double
    /// 水平旋转角，单位为弧度。
    let yw: Double
    /// 垂直倾斜角，单位为弧度。
    let pc: Double
    /// 持续自转速度。
    let sn: Double
    /// 当前归一化动画相位。
    var t: Double
    /// 接收完成投影的点数据并交给上层收集或测量的回调。
    private let sink: (Double, Double, Double, Double, Double) -> Void
    /// 创建绘制数据接收器，并保存当前绘制参数和输出回调。
    init(ds: Double, dot: Double, acc: Double, knobs Q: OrbKnobs, t: Double, _ sink: @escaping (Double, Double, Double, Double, Double) -> Void) {
        self.ds = ds
        self.dot = dot
        self.acc = acc
        self.n = Q.n
        self.sp = Q.sp
        self.pv = Q.pv
        self.dz = Q.dz
        self.df = Q.df
        self.yw = Q.yw
        self.pc = Q.pc
        self.sn = Q.sn
        self.t = t
        self.sink = sink
    }
    /// 将一个点的位置、半径、透明度和颜色标识发送给输出回调。
    func d(_ c: Double, _ x: Double, _ y: Double, _ r: Double, _ a: Double, _ col: Double) {
        sink(x, y, r, a, col)
    }
}

/// 计算给定弧度的正弦值。
private func orbSin(_ x: Double) -> Double { sin(x) }
/// 计算给定弧度的余弦值。
private func orbCos(_ x: Double) -> Double { cos(x) }
/// 计算自然指数函数值。
private func orbExp(_ x: Double) -> Double { exp(x) }
/// 计算指定底数和指数的幂。
private func orbPow(_ x: Double, _ y: Double) -> Double { pow(x, y) }
/// 计算反余弦值。
private func orbAcos(_ x: Double) -> Double { acos(x) }
/// 根据二维坐标计算带象限信息的反正切值。
private func orbAtan2(_ y: Double, _ x: Double) -> Double { atan2(y, x) }
/// 计算平方根。
private func orbSqrt(_ x: Double) -> Double { x.squareRoot() }
/// 计算绝对值。
private func orbAbs(_ x: Double) -> Double { abs(x) }
/// 向下取整给定数值。
private func orbFloor(_ x: Double) -> Double { floor(x) }

/// 按照 JavaScript `Math.round` 的边界行为进行四舍五入。
private func orbRound(_ x: Double) -> Double {
    if x.isNaN || x.isInfinite || x == 0 { return x }
    if x > 0 && x < 0.5 { return 0 }
    if x < 0 && x >= -0.5 { return -0.0 }
    let f = floor(x)
    return x - f >= 0.5 ? f + 1 : f
}

/// 返回两个数值中的较大值，并传播 `NaN`。
private func orbMax(_ a: Double, _ b: Double) -> Double {
    if a.isNaN || b.isNaN { return .nan }
    return a > b ? a : b
}

/// 返回三个数值中的最大值，并传播 `NaN`。
private func orbMax(_ a: Double, _ b: Double, _ c: Double) -> Double { orbMax(orbMax(a, b), c) }

/// 返回两个数值中的较小值，并传播 `NaN`。
private func orbMin(_ a: Double, _ b: Double) -> Double {
    if a.isNaN || b.isNaN { return .nan }
    return a < b ? a : b
}

/// 计算浮点余数。
private func orbMod(_ a: Double, _ b: Double) -> Double { a.truncatingRemainder(dividingBy: b) }

/// 按照 JavaScript 数值规则判断值是否为真。
private func orbTruthy(_ x: Double) -> Bool { x != 0 && !x.isNaN }

/// 当前值为真时返回当前值，否则返回备用值。
private func orbOr(_ a: Double, _ b: Double) -> Double { orbTruthy(a) ? a : b }

/// 以防溢出并补偿浮点误差的方式计算三维向量长度。
private func orbHypot(_ x: Double, _ y: Double, _ z: Double) -> Double {
    let v = [x, y, z]
    var oneArgIsNaN = false
    var m: Double = 0
    for value in v {
        if value.isNaN { oneArgIsNaN = true; continue }
        let a = abs(value)
        if a > m { m = a }
    }
    if m == Double.infinity { return .infinity }
    if oneArgIsNaN { return .nan }
    if m == 0 { return 0 }
    var sum: Double = 0
    var compensation: Double = 0
    for value in v {
        let n = abs(value) / m
        let summand = n * n - compensation
        let preliminary = sum + summand
        compensation = (preliminary - sum) - summand
        sum = preliminary
    }
    return sum.squareRoot() * m
}

/// 根据向量中的指定元素进行稳定升序排序。
private func orbSortByIndex(_ arr: [OrbVec], _ key: Double) -> [OrbVec] {
    return arr.enumerated()
        .sorted { l, r in
            let a = l.element[key]
            let b = r.element[key]
            if a < b { return true }
            if b < a { return false }
            return l.offset < r.offset
        }
        .map { $0.element }
}

private enum OrbSpecs13 {
    /// 一个完整圆周的弧度值。
    static let TAU: Double = Double.pi * 2

    /// 四分之一圆周（90°）的弧度值。
    static let HP: Double = Double.pi / 2

    /// 将基础点数乘以密度倍率，并确保结果至少为一个点。
    static func NC(_ c: Double, _ n: Double) -> Double {
        let v: Double = orbRound(c * n)
        return v < 1 ? 1 : v
    }

    /// 对三维点应用自转、水平转向和垂直倾斜变换。
    static func VIEW(_ p: OrbVec, _ K: OrbSink) -> OrbVec {
        let ay: Double = K.yw + (((Double.pi * 2) * K.sn) * K.t)
        let ca: Double = orbCos(ay)
        let sa: Double = orbSin(ay)
        let X: Double = (p[0] * ca) - (p[2] * sa)
        var Z: Double = (p[0] * sa) + (p[2] * ca)
        let cb: Double = orbCos(K.pc)
        let sb: Double = orbSin(K.pc)
        let Y: Double = (p[1] * cb) - (Z * sb)
        Z = (p[1] * sb) + (Z * cb)
        return OrbVec([X, Y, Z, p[3], p[4], p[5]])
    }

    /// 将数值限制在 `0...1` 范围内。
    static func cl(_ u: Double) -> Double {
        return u < 0 ? 0 : (u > 1 ? 1 : u)
    }

    /// 生成首尾平滑衔接的余弦缓动值。
    static func bump(_ u: Double) -> Double {
        return 0.5 - (0.5 * orbCos(TAU * cl(u)))
    }

    /// 按给定水平角和垂直角旋转三维点。
    static func rot(_ p: OrbVec, _ ay: Double, _ ax: Double) -> OrbVec {
        let ca: Double = orbCos(ay)
        let sa: Double = orbSin(ay)
        let X: Double = (p[0] * ca) - (p[2] * sa)
        var Z: Double = (p[0] * sa) + (p[2] * ca)
        let cb: Double = orbCos(ax)
        let sb: Double = orbSin(ax)
        let Y: Double = (p[1] * cb) - (Z * sb)
        Z = (p[1] * sb) + (Z * cb)
        return OrbVec([X, Y, Z, p[3], p[4], p[5]])
    }

    /// 将三维点执行透视投影、景深缩放和透明度计算后输出。
    static func P3(_ pts: [OrbVec], _ c: Double, _ S2: Double, _ K: OrbSink, _ RF: Double) {
        let cx: Double = S2 / 2
        let cy: Double = S2 / 2
        let R: Double = (S2 * (orbOr(RF, 0.3))) * K.sp
        let f: Double = 3.5 * K.pv
        var out: [OrbVec] = []
        for p0 in pts {
            let p: OrbVec = VIEW(p0, K)
            let z: Double = p[2]
            let per: Double = f / (f - z)
            let d: Double = cl((z + 1.1) / 2.2)
            out.append(OrbVec([cx + ((p[0] * R) * per), cy + ((p[1] * R) * per), ((K.ds * (0.4 + ((1.6 * K.dz) * d))) * per) * (p[3].isNaN ? 1 : p[3]), (0.07 + (0.93 * orbPow(d, 1.55 * K.df))) * (p[4].isNaN ? 1 : p[4]), orbOr(p[5], K.dot), z]))
        }
        out = orbSortByIndex(out, 5)
        for o in out {
            K.d(c, o[0], o[1], o[2], o[3], o[4])
        }
    }

    /// 使用 Fibonacci 球面采样算法生成分布均匀的单位向量。
    static func fib(_ i: Double, _ N: Double) -> OrbVec {
        let y: Double = 1 - ((i / (N - 1)) * 2)
        let r: Double = orbSqrt(orbMax(0, 1 - (y * y)))
        let th: Double = i * 2.399963
        return OrbVec([orbCos(th) * r, y, orbSin(th) * r])
    }

    /// 将笛卡尔坐标转换为球面极角和方位角。
    static func sph(_ p: OrbVec) -> OrbVec {
        return OrbVec([orbAcos(orbMax(-1, orbMin(1, p[1]))), orbAtan2(p[2], p[0])])
    }

    /// 生成样式 6 的球面点阵，并在球体与扁平圆盘之间循环变形。
    static func draw6(_ c: Double, _ t: Double, _ S2: Double, _ K: OrbSink) {
        var pts: [OrbVec] = []
        let m: Double = bump(t)
        do {
            var i: Double = 0
            while i < NC(150, K.n) {
                defer { i += 1 }
                let p: OrbVec = fib(i, NC(150, K.n))
                let s: OrbVec = sph(p)
                let pp: Double = s[0] + ((HP - s[0]) * m)
                let r: Double = orbSin(pp)
                pts.append(rot(OrbVec([orbCos(s[1]) * r, orbCos(pp), orbSin(s[1]) * r, 0.8 + (0.5 * m), 0.9]), TAU * t, 0.4))
            }
        }
        P3(pts, c, S2, K, 0.3)
    }
}

/// 根据样式编号将绘制请求分派到对应的球体算法。
private func orbDraw(_ style: Int, _ c: Double, _ t: Double, _ S: Double, _ K: OrbSink) {
    switch style {
    case 6: OrbSpecs13.draw6(c, t, S, K)
    default: break
    }
}

private struct OrbDot {
    /// 点中心在画布中的横坐标。
    let x: Double
    /// 点中心在画布中的纵坐标。
    let y: Double
    /// 点的绘制半径。
    let r: Double
    /// 点的最终透明度。
    let a: Double
    /// 是否使用强调色绘制该点。
    let accent: Bool
}

/// 普通点在内部算法中使用的颜色标识值。
private let orbDotInk: Double = 1
/// 强调点在内部算法中使用的颜色标识值。
private let orbAccentInk: Double = 2
/// 测量球体边界时使用的颜色占位标识值。
private let orbProbeInk: Double = 3

private final class OrbFitCache: @unchecked Sendable {
    /// 全局共享的边界拟合缓存。
    static let shared = OrbFitCache()
    /// 按样式、尺寸和调节参数保存的拟合比例。
    private var map: [String: Double] = [:]
    /// 保护缓存读写的互斥锁。
    private let lock = NSLock()

    /// 返回指定配置的拟合比例；已有结果直接从线程安全缓存读取。
    func fit(_ style: Int, _ size: Double, _ Q: OrbKnobs) -> Double {
        let key = "\(style)@\(size)@\(Q.fitKey)"
        lock.lock()
        if let hit = map[key] {
            lock.unlock()
            return hit
        }
        lock.unlock()
        let f = orbFit(style, size, Q)
        lock.lock()
        map[key] = f
        lock.unlock()
        return f
    }
}

/// 采样一个完整动画周期，计算使点阵保持在画布安全区域内的缩放比例。
private func orbFit(_ style: Int, _ S: Double, _ Q: OrbKnobs) -> Double {
    let h = S / 2
    var ext: Double = 0
    let probe = OrbSink(ds: 1, dot: orbProbeInk, acc: orbProbeInk, knobs: Q, t: 0) { x, y, r, a, _ in
        if a <= 0.05 || r <= 0.15 { return }
        ext = orbMax(ext, orbAbs(x - h) + r * 0.5, orbAbs(y - h) + r * 0.5)
    }
    for k in 0 ..< 20 {
        probe.t = Double(k) / 20
        orbDraw(style, 0, Double(k) / 20, S, probe)
    }
    return ext > 1 ? orbMax(0.55, orbMin(1.7, (S * 0.415) / ext)) : 1
}

/// 根据画布边长返回适合当前尺寸的基础点半径倍率。
private func orbSizeDotScale(_ S: Double) -> Double {
    if S <= 46 { return 0.4 }
    if S <= 190 { return 0.4 + ((S - 46) / 144) * 0.6 }
    if S <= 340 { return 1 + ((S - 190) / 150) * 0.55 }
    return 1.55
}

/// 生成指定样式和相位下可直接绘制的二维点阵数据。
private func orbSheetDots(style: Int, phase: Double, size S: Double, dotScale: Double, knobs Q: OrbKnobs = .identity) -> [OrbDot] {
    var out: [OrbDot] = []
    let f = OrbFitCache.shared.fit(style, S, Q)
    let h = S / 2
    let K = OrbSink(ds: dotScale, dot: orbDotInk, acc: orbAccentInk, knobs: Q, t: phase) { x, y, r, a, col in
        let fx = h + (x - h) * f
        let fy = h + (y - h) * f
        let fr = r * (0.55 + 0.45 * f)
        let fa = a * Q.op
        if fr <= 0.05 || fa <= 0.004 { return }
        out.append(OrbDot(x: fx, y: fy, r: fr, a: orbMin(1, fa), accent: col == orbAccentInk))
    }
    orbDraw(style, 0, phase, S, K)
    return out
}
