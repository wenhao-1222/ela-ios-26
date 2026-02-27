//
//  DietPlanCreatePaceVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

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
                return 0.45
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
                return "slight"
            case .steady:
                return "steady"
            case .major:
                return "major"
            }
        }
    }

    struct ChartPoint {
        let t: Double
        let value: Double
    }
    
    struct LevelRenderData {
        let endDisplay: Double
        let points: [ChartPoint]
    }

    private let pointCount: Int = 60
    private let defaultChartDurationDays: Int = 14

    private var currentLevel: Level = .steady
    private var levelDataMap: [Level: LevelRenderData] = [:]
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
        applyLevel(level: .steady, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        lab.font = .systemFont(ofSize: 20, weight: .regular)
        return lab
    }()

    lazy var endWeightLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .regular)
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
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
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
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(18))
            make.height.equalTo(kFitWidth(125))
        }

        startWeightLabel.snp.makeConstraints { make in
            make.left.equalTo(chartPlotView)
            make.bottom.equalTo(chartPlotView.snp.bottom).offset(kFitWidth(6))
        }

        endWeightLabel.snp.makeConstraints { make in
            make.right.equalTo(chartPlotView)
            make.bottom.equalTo(chartPlotView.snp.top).offset(kFitWidth(3))
        }

        xAxisLine.snp.makeConstraints { make in
            make.left.right.equalTo(chartPlotView)
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalToSuperview().offset(kFitWidth(-36))
        }

        tickLeftLabel.snp.makeConstraints { make in
            make.left.equalTo(chartPlotView)
            make.top.equalTo(xAxisLine.snp.bottom).offset(kFitWidth(9))
        }

        tickMidLabel.snp.makeConstraints { make in
            make.centerX.equalTo(chartPlotView)
            make.top.equalTo(tickLeftLabel)
        }

        tickRightLabel.snp.makeConstraints { make in
            make.right.equalTo(chartPlotView)
            make.top.equalTo(tickLeftLabel)
        }
    }
}

private extension DietPlanCreatePaceVM {
    @objc func sliderValueChanged() {
        let snapped = Int(round(sliderView.value))
        guard let newLevel = Level(rawValue: max(0, min(2, snapped))) else {
            return
        }
        sliderView.setValue(Float(newLevel.rawValue), animated: false)
        if newLevel != currentLevel {
            applyLevel(level: newLevel, animated: true)
        }
    }

    @objc func sliderTouchEnd() {
        sliderView.setValue(Float(currentLevel.rawValue), animated: true)
    }

    func applyLevel(level: Level, animated: Bool) {
        currentLevel = level
        QuestinonaireMsgModel.shared.paceLevel = level.modelValue

        levelLabel.text = level.title
        descLabel.text = level.detail
        chartLineLayer.strokeColor = level.lineColor.cgColor

        recomputeAllLevelData()
        chartPoints = levelDataMap[level]?.points ?? []
        let endDisplay = levelDataMap[level]?.endDisplay ?? startWeight

        startWeightLabel.text = "\(formatWeight(startWeight)) 公斤"
        endWeightLabel.text = "\(formatWeight(endDisplay)) 公斤"
        updateTickLabels()
        redrawChartPath(animated: animated)
    }

    func recomputeAllLevelData() {
        let w0 = resolveCurrentWeight()
        startWeight = w0
        let goalDirection = resolveGoalDirection(currentWeight: w0)
        let weeks = resolveChartWindowWeeks()
        displayWeeks = weeks

        var tmpMap: [Level: LevelRenderData] = [:]
        var endDisplays: [Double] = [w0]

        for level in Level.allCases {
            let endDisplay = resolveTargetWeight(startWeight: w0, level: level, direction: goalDirection, weeks: displayWeeks)
            let points = buildPoints(startWeight: w0, endWeight: endDisplay, weeks: displayWeeks)

            tmpMap[level] = LevelRenderData(
                endDisplay: endDisplay,
                points: points
            )
            endDisplays.append(endDisplay)
        }

        let baseMin = endDisplays.min() ?? w0
        let baseMax = endDisplays.max() ?? w0
        let pad = max(0.5, (baseMax - baseMin) * 0.15)
        yMinValue = baseMin - pad
        yMaxValue = baseMax + pad
        levelDataMap = tmpMap
    }
    
    func buildPoints(startWeight: Double,
                     endWeight: Double,
                     weeks: Double) -> [ChartPoint] {
        var points: [ChartPoint] = []
        points.reserveCapacity(pointCount)
        
        for i in 0..<pointCount {
            let t = Double(i) * weeks / Double(max(pointCount - 1, 1))
            let u = max(0, min(1, t / max(weeks, 0.0001)))
            let e = smoothstep(u)
            let value = startWeight + (endWeight - startWeight) * e
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

    func updateTickLabels() {
        let (startDate, endDate) = normalizedChartDateRange()
        let midDate = Date(timeIntervalSince1970: (startDate.timeIntervalSince1970 + endDate.timeIntervalSince1970) * 0.5)
        let windowWeeks = max(endDate.timeIntervalSince(startDate) / (7 * 24 * 3600), 0.0001)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")

        if windowWeeks <= 6 {
            formatter.dateFormat = "M月d日"
        } else {
            formatter.dateFormat = "M月"
        }

        tickLeftLabel.text = formatter.string(from: startDate)
        tickMidLabel.text = formatter.string(from: midDate)
        tickRightLabel.text = formatter.string(from: endDate)
    }
    
    func resolveChartWindowWeeks() -> Double {
        return Double(resolveChartDurationDays()) / 7.0
    }
    
    func normalizedChartDateRange() -> (Date, Date) {
        let start = QuestinonaireMsgModel.shared.chartStartDate
        let days = resolveChartDurationDays()
        let end = Calendar.current.date(byAdding: .day, value: days, to: start) ?? start.addingTimeInterval(Double(days) * 24 * 3600)
        QuestinonaireMsgModel.shared.chartStartDate = start
        QuestinonaireMsgModel.shared.chartEndDate = end
        return (start, end)
    }

    func resolveCurrentWeight() -> Double {
        let weightString = QuestinonaireMsgModel.shared.weight//.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsed = Double(weightString.replacingOccurrences(of: ",", with: "."))
        return max(parsed ?? 85.0, 30.0)
    }

    func resolveTargetWeight(startWeight: Double, level: Level, direction: Double, weeks: Double) -> Double {
        return max(startWeight + direction * level.rateAbs * weeks, 30.0)
    }

    func resolveGoalDirection(currentWeight: Double) -> Double {
        let goalString = QuestinonaireMsgModel.shared.goal
        if goalString.contains("减脂") {
            return -1.0
        }
        if goalString.contains("增肌") {
            return 1.0
        }
        if goalString.contains("保持") {
            return 0.0
        }
        return currentWeight >= 80 ? -1.0 : 1.0
    }

    func resolveChartDurationDays() -> Int {
        // 预留自定义时长扩展，当前固定 14 天
        return defaultChartDurationDays
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
