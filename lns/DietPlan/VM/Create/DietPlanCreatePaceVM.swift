//
//  DietPlanCreatePaceVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

extension Notification.Name {
    static let dietPlanPaceInputDidChange = Notification.Name("dietPlanPaceInputDidChange")
}

class DietPlanCreatePaceVM: UIView {

    enum Level: Int, CaseIterable {
        case slight = 0
        case steady = 1
        case major = 2

        var title: String {
            switch self {
            case .slight:
                return "循序渐进"
            case .steady:
                return "稳步推进"
            case .major:
                return "快速达成"
            }
        }

        var detail: String {
            switch self {
            case .slight:
                return "我希望尽量少改饮食习惯，也能慢慢看到进展"
            case .steady:
                return "我愿意在合理范围内做出改变，并长期稳定坚持"
            case .major:
                return "我愿意做出更明显的调整，希望更快看到进展"
            }
        }

        var rateAbs: Double {
            switch self {
            case .slight:
                return 0.25
            case .steady:
                return 0.50
            case .major:
                return 0.70
            }
        }

        var lineColor: UIColor {
            switch self {
            case .slight:
                return .THEME
            case .steady:
                return WHColor_16(colorStr: "2C845C")
            case .major:
                return WHColor_16(colorStr: "FF8725")
            }
        }

        var modelValue: String {
            switch self {
            case .slight:
                return "1"
            case .steady:
                return "2"
            case .major:
                return "3"
            }
        }
    }

    struct ChartPoint {
        let t: Double
        let value: Double
    }
    
    private let pointCount: Int = 61
    private let minHorizonWeeks: Double = 4.0
    private let maxHorizonWeeks: Double = 20.0
    private let minRateKgPerWeek: Double = 0.25
    private let maxRateKgPerWeek: Double = 0.70
    private let defaultCurrentWeight: Double = 70.0
    private let defaultTargetWeight: Double = 65.0
    private let edgeTickInset: CGFloat = kFitWidth(35)

    private var currentLevel: Level = .steady
    private var sliderRawValue: Double = 1.0
    private var currentRateKgPerWeek: Double = 0.50
    private var currentEndWeight: Double = 0
    private var targetWeight: Double = 0
    private var chartPoints: [ChartPoint] = []
    private var startWeight: Double = 0
    private var displayWeeks: Double = 20
    private var yMinValue: Double = 0
    private var yMaxValue: Double = 1

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
        observePaceInputs()
        applyLevel(level: .steady, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        chartLineLayer.frame = chartPlotView.bounds
        redrawChartPath(animated: false)
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你想以什么节奏推进目标？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var levelLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textAlignment = .center
        return lab
    }()

    lazy var sliderView: UISlider = {
        let vi = UISlider()
        vi.minimumValue = 0
        vi.maximumValue = 2
        vi.value = 1
        vi.minimumTrackTintColor = .THEME
        vi.maximumTrackTintColor = WHColor_16(colorStr: "D9D9D9")
        vi.setThumbImage(makeThumbImage(), for: .normal)
        vi.setThumbImage(makeThumbImage(), for: .highlighted)
        vi.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        vi.addTarget(self, action: #selector(sliderTouchEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return vi
    }()

    lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white.withAlphaComponent(0.55)
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var descLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
//        lab.numberOfLines = 0
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()

    lazy var chartWrapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        return vi
    }()

    lazy var chartPlotView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        return vi
    }()

    lazy var startWeightLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()

    lazy var endWeightLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .right
        return lab
    }()

    lazy var xAxisLine: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        return vi
    }()

    lazy var tickLeftLabel: UILabel = makeTickLabel()
    lazy var tickMidLabel: UILabel = makeTickLabel()
    lazy var tickRightLabel: UILabel = makeTickLabel()
    lazy var tickLeftMark: UIView = makeTickMarkView()
    lazy var tickMidMark: UIView = makeTickMarkView()
    lazy var tickRightMark: UIView = makeTickMarkView()
    private var startWeightTopOffset: CGFloat = 0
    private var endWeightTopOffset: CGFloat = 0

    lazy var chartLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = kFitWidth(2.5)
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }()
}

extension DietPlanCreatePaceVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(levelLabel)
        addSubview(sliderView)
        addSubview(cardView)

        cardView.addSubview(descLabel)
        cardView.addSubview(chartWrapView)
        chartWrapView.addSubview(chartPlotView)
        chartWrapView.addSubview(startWeightLabel)
        chartWrapView.addSubview(endWeightLabel)
        chartWrapView.addSubview(xAxisLine)
        chartWrapView.addSubview(tickLeftMark)
        chartWrapView.addSubview(tickMidMark)
        chartWrapView.addSubview(tickRightMark)
        chartWrapView.addSubview(tickLeftLabel)
        chartWrapView.addSubview(tickMidLabel)
        chartWrapView.addSubview(tickRightLabel)
        chartPlotView.layer.addSublayer(chartLineLayer)

        setConstraint()
    }

    func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(55))
        }

        levelLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(86))
        }

        sliderView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(levelLabel.snp.bottom).offset(kFitWidth(28))
            make.height.equalTo(kFitWidth(40))
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(sliderView.snp.bottom).offset(kFitWidth(20))
            make.bottom.lessThanOrEqualToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(72)))
        }

        descLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(24))
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
        }

        chartWrapView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(kFitWidth(16))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(kFitWidth(-14))
            make.height.equalTo(kFitWidth(220))
        }

        chartPlotView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(22))
            make.right.equalTo(kFitWidth(-22))
            make.top.equalTo(kFitWidth(18))
            make.height.equalTo(kFitWidth(125))
        }

        startWeightLabel.snp.makeConstraints { make in
            make.left.equalTo(chartPlotView)
            make.top.equalTo(chartWrapView.snp.top).offset(kFitWidth(140))
        }

        endWeightLabel.snp.makeConstraints { make in
            make.right.equalTo(chartPlotView)
            make.top.equalTo(chartWrapView.snp.top).offset(kFitWidth(24))
        }

        xAxisLine.snp.makeConstraints { make in
            make.left.right.equalTo(chartPlotView)
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalToSuperview().offset(kFitWidth(-36))
        }

        tickLeftMark.snp.makeConstraints { make in
            make.centerX.equalTo(tickLeftLabel)
            make.top.equalTo(xAxisLine.snp.bottom)
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(5))
        }

        tickMidMark.snp.makeConstraints { make in
            make.centerX.equalTo(tickMidLabel)
            make.top.equalTo(xAxisLine.snp.bottom)
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(5))
        }

        tickRightMark.snp.makeConstraints { make in
            make.centerX.equalTo(tickRightLabel)
            make.top.equalTo(xAxisLine.snp.bottom)
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(5))
        }

        tickLeftLabel.snp.makeConstraints { make in
            make.left.equalTo(chartPlotView).offset(kFitWidth(edgeTickInset))
            make.top.equalTo(xAxisLine.snp.bottom).offset(kFitWidth(9))
        }

        tickMidLabel.snp.makeConstraints { make in
            make.centerX.equalTo(chartPlotView)
            make.top.equalTo(tickLeftLabel)
        }

        tickRightLabel.snp.makeConstraints { make in
            make.right.equalTo(chartPlotView).offset(kFitWidth(-edgeTickInset))
            make.top.equalTo(tickLeftLabel)
        }
    }
}

private extension DietPlanCreatePaceVM {
    func observePaceInputs() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePaceInputChanged),
            name: .dietPlanPaceInputDidChange,
            object: nil
        )
    }

    @objc func handlePaceInputChanged() {
        render(level: currentLevel, rateKgPerWeek: currentRateKgPerWeek, animated: false, persistLevel: false)
    }

    @objc func sliderValueChanged() {
        sliderRawValue = min(max(Double(sliderView.value), 0), 2)
        currentRateKgPerWeek = mapRawValueToRate(sliderRawValue)
        let previewLevelValue = max(0, min(2, Int(round(sliderRawValue))))
        guard let previewLevel = Level(rawValue: previewLevelValue) else {
            return
        }
        render(level: previewLevel, rateKgPerWeek: currentRateKgPerWeek, animated: false, persistLevel: false)
    }

    @objc func sliderTouchEnd() {
        let snapRaw = min(max(round(sliderRawValue), 0), 2)
        sliderRawValue = snapRaw
        currentRateKgPerWeek = mapRawValueToRate(snapRaw)
        sliderView.setValue(Float(snapRaw), animated: true)
        guard let level = Level(rawValue: Int(snapRaw)) else {
            return
        }
        applyLevel(level: level, animated: true)
    }

    func applyLevel(level: Level, animated: Bool) {
        currentLevel = level
        sliderRawValue = Double(level.rawValue)
        sliderView.setValue(Float(sliderRawValue), animated: false)
        currentRateKgPerWeek = mapRawValueToRate(sliderRawValue)
        render(level: level, rateKgPerWeek: currentRateKgPerWeek, animated: animated, persistLevel: true)
    }

    func render(level: Level, rateKgPerWeek: Double, animated: Bool, persistLevel: Bool) {
        if persistLevel {
            QuestinonaireMsgModel.shared.paceLevel = level.modelValue
        }
        levelLabel.text = level.title
        descLabel.text = level.detail
        chartLineLayer.strokeColor = level.lineColor.cgColor

        recomputeSpec(rateKgPerWeek: rateKgPerWeek)

        startWeightLabel.text = "\(formatWeight(startWeight)) 公斤"
        endWeightLabel.text = "\(formatWeight(endLabelDisplayWeight())) 公斤"
        updateTickLabels()
        redrawChartPath(animated: animated)
    }

    func recomputeSpec(rateKgPerWeek: Double) {
        let w0 = resolveCurrentWeight()
        let wt = resolveTargetWeight()
        startWeight = w0
        targetWeight = wt
        let horizonWeeks = resolveHorizonWeeks(currentWeight: w0, targetWeight: wt)
        displayWeeks = horizonWeeks

        let allEndDisplays = Level.allCases.map { level in
            resolveEndDisplayWeight(
                currentWeight: w0,
                targetWeight: wt,
                horizonWeeks: horizonWeeks,
                rateKgPerWeek: level.rateAbs
            )
        }

        let baseMin = min(w0, allEndDisplays.min() ?? w0)
        let baseMax = max(w0, allEndDisplays.max() ?? w0)
        let pad = max(1.0, (baseMax - baseMin) * 0.15)
        yMinValue = baseMin - pad
        yMaxValue = baseMax + pad
        chartPoints = buildPoints(
            currentWeight: w0,
            targetWeight: wt,
            horizonWeeks: horizonWeeks,
            rateKgPerWeek: rateKgPerWeek
        )
        currentEndWeight = chartPoints.last?.value ?? w0
    }
    
    func buildPoints(currentWeight: Double,
                     targetWeight: Double,
                     horizonWeeks: Double,
                     rateKgPerWeek: Double) -> [ChartPoint] {
        let delta = targetWeight - currentWeight
        let absDelta = abs(delta)
        var points: [ChartPoint] = []
        points.reserveCapacity(pointCount)

        if absDelta < 0.001 {
            for i in 0..<pointCount {
                let t = Double(i) * horizonWeeks / Double(max(pointCount - 1, 1))
                points.append(ChartPoint(t: t, value: currentWeight))
            }
            return points
        }

        let direction = delta >= 0 ? 1.0 : -1.0
        let tGoal = absDelta / max(rateKgPerWeek, 0.0001)

        for i in 0..<pointCount {
            let t = Double(i) * horizonWeeks / Double(max(pointCount - 1, 1))
            let value: Double
            if tGoal <= horizonWeeks, t >= tGoal {
                value = targetWeight
            } else {
                let segmentEnd = tGoal <= horizonWeeks ? tGoal : horizonWeeks
                let u = segmentEnd <= 0.0001 ? 1.0 : min(max(t / segmentEnd, 0), 1)
                let eased = smoothstep(u)
                let segmentTarget: Double = tGoal <= horizonWeeks
                    ? targetWeight
                    : currentWeight + direction * rateKgPerWeek * horizonWeeks
                value = currentWeight + (segmentTarget - currentWeight) * eased
            }
            points.append(ChartPoint(t: t, value: value))
        }

        return points
    }

    func redrawChartPath(animated: Bool) {
        guard chartPlotView.bounds.width > 0,
              chartPlotView.bounds.height > 0,
              !chartPoints.isEmpty else {
            return
        }

        let yRange = max(yMaxValue - yMinValue, 0.001)

        let width = chartPlotView.bounds.width
        let height = chartPlotView.bounds.height

        let path = UIBezierPath()
        for (idx, point) in chartPoints.enumerated() {
            let x = CGFloat(point.t / max(displayWeeks, 0.001)) * width
            let yRatio = (point.value - yMinValue) / yRange
            let y = height - CGFloat(yRatio) * height
            let cgPoint = CGPoint(x: x, y: y)
            if idx == 0 {
                path.move(to: cgPoint)
            } else {
                path.addLine(to: cgPoint)
            }
        }

        chartLineLayer.path = path.cgPath
        updateWeightLabelPositions(yRange: yRange, plotHeight: height)

        guard animated else {
            return
        }

        chartLineLayer.removeAllAnimations()
        let ani = CABasicAnimation(keyPath: "strokeEnd")
        ani.duration = 0.22
        ani.fromValue = 0
        ani.toValue = 1
        ani.timingFunction = CAMediaTimingFunction(name: .easeOut)
        chartLineLayer.add(ani, forKey: "pace_path")
    }

    func updateWeightLabelPositions(yRange: Double, plotHeight: CGFloat) {
        guard let startPoint = chartPoints.first, let endPoint = chartPoints.last else {
            return
        }
        let startRatio = (startPoint.value - yMinValue) / yRange
        let endRatio = (endPoint.value - yMinValue) / yRange
        let startLineYInPlot = plotHeight - CGFloat(startRatio) * plotHeight
        let endLineYInPlot = plotHeight - CGFloat(endRatio) * plotHeight
        let startLineY = chartPlotView.frame.minY + startLineYInPlot
        let endLineY = chartPlotView.frame.minY + endLineYInPlot

        let labelGap = kFitWidth(4)
        let startHeight = startWeightLabel.intrinsicContentSize.height
        let endHeight = endWeightLabel.intrinsicContentSize.height
        let maxLabelHeight = max(startHeight, endHeight)
        let isAscending = currentEndWeight >= startWeight

        // 上升时左下右上，下降时左上右下，避免文本压住折线。
        let startTop = isAscending
            ? (startLineY + labelGap)
            : (startLineY - startHeight - labelGap)
        let endTop = isAscending
            ? (endLineY - endHeight - labelGap)
            : (endLineY + labelGap)

        let minTop = chartPlotView.frame.minY - maxLabelHeight * 0.2
        let maxTop = chartWrapView.bounds.height - maxLabelHeight - kFitWidth(2)
        let clampedStartTop = min(max(startTop, minTop), maxTop)
        let clampedEndTop = min(max(endTop, minTop), maxTop)

        startWeightTopOffset = clampedStartTop
        endWeightTopOffset = clampedEndTop
        startWeightLabel.snp.updateConstraints { make in
            make.top.equalTo(chartWrapView.snp.top).offset(startWeightTopOffset)
        }
        endWeightLabel.snp.updateConstraints { make in
            make.top.equalTo(chartWrapView.snp.top).offset(endWeightTopOffset)
        }
        chartWrapView.layoutIfNeeded()
    }

    func updateTickLabels() {
        let (startDate, endDate) = chartDateRange()
        let midDate = Date(timeIntervalSince1970: (startDate.timeIntervalSince1970 + endDate.timeIntervalSince1970) * 0.5)
        let windowWeeks = max(displayWeeks, 0)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")

        if windowWeeks <= 8 {
            formatter.dateFormat = "M月d日"
        } else {
            formatter.dateFormat = "M月"
        }

        tickLeftLabel.text = formatter.string(from: startDate)
        tickMidLabel.text = formatter.string(from: midDate)
        tickRightLabel.text = formatter.string(from: endDate)
    }

    func chartDateRange() -> (Date, Date) {
        let start = Calendar.current.startOfDay(for: Date())
        let days = Int(round(displayWeeks * 7))
        let end = Calendar.current.date(byAdding: .day, value: days, to: start) ?? start
        QuestinonaireMsgModel.shared.chartStartDate = start
        QuestinonaireMsgModel.shared.chartEndDate = end
        return (start, end)
    }

    func resolveCurrentWeight() -> Double {
        let parsed = parseWeight(QuestinonaireMsgModel.shared.weight)
        return max(parsed ?? defaultCurrentWeight, 30.0)
    }

    func resolveTargetWeight() -> Double {
        let parsed = parseWeight(QuestinonaireMsgModel.shared.targetWeight)
        return max(parsed ?? defaultTargetWeight, 30.0)
    }

    func resolveHorizonWeeks(currentWeight: Double, targetWeight: Double) -> Double {
        let absDelta = abs(targetWeight - currentWeight)
        if absDelta < 0.001 {
            return minHorizonWeeks
        }
        let weeks = absDelta / minRateKgPerWeek
        return min(max(weeks, minHorizonWeeks), maxHorizonWeeks)
    }

    func resolveEndDisplayWeight(currentWeight: Double,
                                 targetWeight: Double,
                                 horizonWeeks: Double,
                                 rateKgPerWeek: Double) -> Double {
        let delta = targetWeight - currentWeight
        let absDelta = abs(delta)
        if absDelta < 0.001 {
            return currentWeight
        }

        let direction = delta >= 0 ? 1.0 : -1.0
        let tGoal = absDelta / max(rateKgPerWeek, 0.0001)
        if tGoal <= horizonWeeks {
            return targetWeight
        }
        return currentWeight + direction * rateKgPerWeek * horizonWeeks
    }

    func mapRawValueToRate(_ rawValue: Double) -> Double {
        let t = min(max(rawValue / 2.0, 0), 1)
        return minRateKgPerWeek + (maxRateKgPerWeek - minRateKgPerWeek) * t
    }

    func endLabelDisplayWeight() -> Double {
        if abs(currentEndWeight - targetWeight) < 0.001 {
            return targetWeight
        }
        return currentEndWeight.rounded()
    }

    func parseWeight(_ text: String) -> Double? {
        let clean = text.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return nil }
        return Double(clean)
    }

    func smoothstep(_ u: Double) -> Double {
        return u * u * (3 - 2 * u)
    }

    func formatWeight(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }

    func makeTickLabel() -> UILabel {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "8C8D94")
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }

    func makeTickMarkView() -> UIView {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        return vi
    }

    func makeThumbImage() -> UIImage? {
        let size = CGSize(width: kFitWidth(28), height: kFitWidth(28))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let rect = CGRect(origin: .zero, size: size)
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: rect)
        context.setStrokeColor(WHColor_16(colorStr: "E8E8E8").cgColor)
        context.setLineWidth(1)
        context.strokeEllipse(in: rect.insetBy(dx: 0.5, dy: 0.5))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
