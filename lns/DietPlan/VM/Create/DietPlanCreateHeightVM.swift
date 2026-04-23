//
//  DietPlanCreateHeightVM.swift
//  lns
//
//  Created by Codex on 2026/2/25.
//


class DietPlanCreateHeightVM: UIView {

    var valueChangeBlock: ((Int) -> ())?
    var currentValue: Int = 170
    private var hasAppliedInitialValue = false
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let rulerStepHeight = kFitWidth(7)
    private var linkedRulerScrollView: UIScrollView?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你的身高是?"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)

        return lab
    }()

    lazy var numberLabel: YYLabel = {
        let lab = YYLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .right
        lab.font = .systemFont(ofSize: 12, weight: .regular)

        return lab
    }()

    lazy var rulerView: TTScrollRulerView = {
        let vmOriginY = WHUtils().getNavigationBarHeight() + kFitWidth(60) + kFitWidth(90)//kFitWidth(170)
        let vi = TTScrollRulerView(frame: CGRect(x: kFitWidth(183), y: vmOriginY, width: kFitWidth(200), height: kFitWidth(420)))
        vi.backgroundColor = .clear
        vi.rulerBackgroundColor = .clear
        return vi
    }()

    lazy var rulerPanProxyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleProxyPan(_:)))
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        return view
    }()

    lazy var topMaskView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    lazy var topMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        return layer
    }()

    lazy var bottomMaskView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    lazy var bottomMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        return layer
    }()
}

extension DietPlanCreateHeightVM {
    func applyDefaultHeight(_ value: Int) {
        currentValue = value
        QuestinonaireMsgModel.shared.height = "\(value)"
        updateHeightText(value: value)
        if hasAppliedInitialValue {
            rulerView.scroll(toValue: value, animation: false)
        }
    }
    
    func initUI() {
        addSubview(titleLabel)
        addSubview(numberLabel)
        addSubview(rulerPanProxyView)
        addSubview(rulerView)
        addSubview(topMaskView)
        addSubview(bottomMaskView)
        topMaskView.layer.addSublayer(topMaskLayer)
        bottomMaskView.layer.addSublayer(bottomMaskLayer)
        feedbackGenerator.prepare()

        rulerView.rulerDelegate = self
        rulerView.rulerDirection = .vertical
        rulerView.rulerFace = .down_right
        rulerView.lockMax = 240
        rulerView.lockMin = 110
        rulerView.lockDefault = rulerView.lockMax + rulerView.lockMin - currentValue
        rulerView.pointerBackgroundColor = .THEME
        rulerView.h_height = Float(kFitWidth(36))
        rulerView.m_height = Float(kFitWidth(24))
        rulerView.customRuler(with: customColorMake(217.0 / 255.0, 217.0 / 255.0, 217.0 / 255.0),
                              numColor: .COLOR_TEXT_TITLE_0f1214_20,
                              scrollEnable: true)
//        rulerView.customRuler(with: customColorMake(217.0 / 255.0, 217.0 / 255.0, 217.0 / 255.0),
//                              numColor: WHColorWithAlpha(colorStr: "000000", alpha: 0.15),
//                              scrollEnable: true)
        rulerView.unitValue = 1
        rulerView.classicRuler()
        rulerView.scroll(toValue: currentValue, animation: false)

        setConstrait()
        updateHeightText(value: currentValue)
        QuestinonaireMsgModel.shared.height = "\(currentValue)"
    }

    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(60))
        }

        numberLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(59))
            make.centerY.equalTo(rulerView)
            make.right.lessThanOrEqualTo(rulerView.snp.left).offset(kFitWidth(-30))
        }

        rulerPanProxyView.snp.makeConstraints { make in
            make.top.bottom.equalTo(rulerView)
            make.left.equalToSuperview()
            make.right.equalTo(rulerView.snp.left)
        }

        rulerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(90))
//            make.centerX.equalToSuperview().offset(kFitWidth(56))
//            make.bottom.equalTo(kFitWidth(-159)-WHUtils().getBottomSafeAreaHeight())
            make.left.equalTo(SCREEN_WIDHT*0.5)
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(420))
        }

        topMaskView.snp.makeConstraints { make in
            make.top.equalTo(rulerView.snp.top)
            make.left.equalTo(rulerView.snp.left)
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(128))
        }

        bottomMaskView.snp.makeConstraints { make in
            make.bottom.equalTo(rulerView.snp.bottom)
            make.left.equalTo(rulerView.snp.left)
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(128))
        }
    }

    func updateHeightText(value: Int) {
        let text = NSMutableAttributedString(string: "\(value)")
        let unit = NSMutableAttributedString(string: " 厘米")
        text.yy_font = UIFont().DDInFontMedium(fontSize: 44)//.systemFont(ofSize: 40, weight: .medium)
        text.yy_color = .THEME
        unit.yy_font = .systemFont(ofSize: 12, weight: .regular)
        unit.yy_color = .COLOR_TEXT_TITLE_0f1214
        text.append(unit)
        numberLabel.attributedText = text
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topMaskLayer.frame = topMaskView.bounds
        bottomMaskLayer.frame = bottomMaskView.bounds
        linkedRulerScrollView = resolveRulerScrollView()
        if !hasAppliedInitialValue {
            hasAppliedInitialValue = true
            DispatchQueue.main.async {
                self.rulerView.scroll(toValue: self.currentValue, animation: false)
                QuestinonaireMsgModel.shared.height = "\(self.currentValue)"
                self.updateHeightText(value: self.currentValue)
            }
        }
    }

    private func resolveRulerScrollView() -> UIScrollView? {
        if let linkedRulerScrollView {
            return linkedRulerScrollView
        }
        return rulerView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }

    private func clampRulerOffset(_ offsetY: CGFloat, scrollView: UIScrollView) -> CGFloat {
        let minOffset = CGFloat(rulerView.lockMin / max(rulerView.unitValue, 1)) * rulerStepHeight
        let maxOffset = CGFloat(rulerView.lockMax / max(rulerView.unitValue, 1)) * rulerStepHeight
        return min(max(offsetY, minOffset), maxOffset)
    }

    @objc
    private func handleProxyPan(_ gesture: UIPanGestureRecognizer) {
        guard let scrollView = resolveRulerScrollView() else { return }

        switch gesture.state {
        case .began, .changed:
            let translation = gesture.translation(in: rulerPanProxyView)
            let targetOffsetY = clampRulerOffset(scrollView.contentOffset.y - translation.y, scrollView: scrollView)
            scrollView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: false)
            gesture.setTranslation(.zero, in: rulerPanProxyView)
        case .ended, .cancelled, .failed:
            let snappedIndex = round(scrollView.contentOffset.y / rulerStepHeight)
            let snappedOffsetY = clampRulerOffset(snappedIndex * rulerStepHeight, scrollView: scrollView)
            scrollView.setContentOffset(CGPoint(x: 0, y: snappedOffsetY), animated: true)
        default:
            break
        }
    }
}

extension DietPlanCreateHeightVM: rulerDelegate {
    func ruler(with value: Int) {
        if value != currentValue {
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
        }
        currentValue = value
        QuestinonaireMsgModel.shared.height = "\(value)"
        updateHeightText(value: value)
        valueChangeBlock?(value)
    }
}
