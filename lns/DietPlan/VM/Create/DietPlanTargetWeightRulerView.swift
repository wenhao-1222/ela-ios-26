//
//  DietPlanTargetWeightRulerView.swift
//  lns
//
//  Created by LNS2 on 2026/2/26.
//

final class DietPlanTargetWeightRulerView: UIView, UIScrollViewDelegate {

    var minValue: Double = 30.0 {
        didSet { rebuildRuler() }
    }
    var maxValue: Double = 200.0 {
        didSet { rebuildRuler() }
    }
    var stepValue: Double = 0.1 {
        didSet { rebuildRuler() }
    }
    var onValueChanged: ((Double) -> ())?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let centerLine = UIView()
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let spacing = kFitWidth(7)
    private var centerInset: CGFloat = 0
    private var lastSize: CGSize = .zero
    private var currentIndex: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        centerLine.backgroundColor = .THEME
        centerLine.layer.cornerRadius = kFitWidth(1.5)
        centerLine.clipsToBounds = true
        addSubview(centerLine)
        feedbackGenerator.prepare()
        
        
        addSubview(leftGradientView)
        addSubview(rightGradientView)
        leftGradientView.layer.addSublayer(leftGradientLayer)
        rightGradientView.layer.addSublayer(rightGradientLayer)
        
        leftGradientView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(128))
        }

        rightGradientView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(128))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        leftGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        rightGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
    }
    
    lazy var leftGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()

    lazy var rightGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var leftGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    lazy var rightGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        leftGradientLayer.frame = leftGradientView.bounds
        rightGradientLayer.frame = rightGradientView.bounds
        centerLine.frame = CGRect(x: (bounds.width - kFitWidth(3)) * 0.5,
                                  y: kFitWidth(12),
                                  width: kFitWidth(4),
                                  height: kFitWidth(56))
        guard bounds.size != lastSize else { return }
        lastSize = bounds.size
        rebuildRuler()
        updateOffset(index: currentIndex, animated: false)
    }

    private var valueCount: Int {
        guard stepValue > 0, maxValue >= minValue else { return 0 }
        return Int(round((maxValue - minValue) / stepValue)) + 1
    }

    private var majorInterval: Int {
        guard stepValue > 0 else { return 1 }
        return max(1, Int(round(1.0 / stepValue)))
    }

    func rebuildRuler() {
        guard bounds.width > 0, valueCount > 0 else { return }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        centerInset = bounds.width * 0.5

        let totalWidth = centerInset * 2 + CGFloat(max(valueCount - 1, 0)) * spacing
        contentView.frame = CGRect(x: 0, y: 0, width: totalWidth, height: bounds.height)
        scrollView.contentSize = contentView.bounds.size

        let majorY = kFitWidth(34)
        let majorH = kFitWidth(34)
        let minorY = kFitWidth(46)
        let minorH = kFitWidth(22)

        for i in 0..<valueCount {
            let x = centerInset + CGFloat(i) * spacing
            let isMajor = i % majorInterval == 0
            let tickView = UIView()
            tickView.backgroundColor = WHColor_16(colorStr: "D8D8D8")
            let viewWidth = isMajor ? kFitWidth(2) : kFitWidth(1)
//            tickView.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214.withAlphaComponent(isMajor ? 0.15 : 0.08)
            tickView.frame = CGRect(x: x - viewWidth * 0.5,
                                    y: isMajor ? majorY : minorY,
                                    width: viewWidth,
                                    height: isMajor ? majorH : minorH)
            contentView.addSubview(tickView)

            if isMajor {
                let label = UILabel(frame: CGRect(x: x - kFitWidth(18), y: tickView.frame.maxY+kFitWidth(8), width: kFitWidth(36), height: kFitWidth(24)))
                label.textAlignment = .center
                label.font = UIFont().DDInFontMedium(fontSize: 15)//.systemFont(ofSize: 14, weight: .medium)
                label.textColor = .COLOR_TEXT_TITLE_0f1214_50
                let value = minValue + Double(i) * stepValue
                label.text = "\(Int(round(value)))"
                contentView.addSubview(label)
            }
        }
    }

    func setValue(_ value: Double, animated: Bool) {
        guard valueCount > 0 else { return }
        let clamped = min(max(value, minValue), maxValue)
        let index = Int(round((clamped - minValue) / stepValue))
        currentIndex = min(max(index, 0), valueCount - 1)
        updateOffset(index: currentIndex, animated: animated)
        emitValue()
    }

    private func updateOffset(index: Int, animated: Bool) {
        let targetCenterX = centerInset + CGFloat(index) * spacing
        let targetOffsetX = targetCenterX - scrollView.bounds.width * 0.5
        let maxOffsetX = max(scrollView.contentSize.width - scrollView.bounds.width, 0)
        let finalOffsetX = min(max(targetOffsetX, 0), maxOffsetX)
        scrollView.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: animated)
        if !animated {
            updateIndexByContentOffset()
        }
    }

    private func updateIndexByContentOffset() {
        guard valueCount > 0 else { return }
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width * 0.5
        let raw = (centerX - centerInset) / spacing
        let index = min(max(Int(round(raw)), 0), valueCount - 1)
        guard index != currentIndex else { return }
        currentIndex = index
        feedbackGenerator.selectionChanged()
        feedbackGenerator.prepare()
        emitValue()
    }

    private func emitValue() {
        let value = minValue + Double(currentIndex) * stepValue
        onValueChanged?(value)
    }

    private func snapToCurrentIndex() {
        updateOffset(index: currentIndex, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateIndexByContentOffset()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToCurrentIndex()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToCurrentIndex()
    }
}
