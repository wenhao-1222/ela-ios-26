//
//  GuideTotalFirstVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/4.
//


class GuideTotalFirstVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    
    /// Called when user taps to proceed to the next page
    var nextBlock:(() -> Void)?
    
    /// Lines used for tips label printing effect
    private let tipsLines = [
        "*2 分钟为 Elavatine 用户每日记录平均用时",
        "† Kaiser Permanente Center for Health Research，Am J Prev ",
        "Med 2008；200 % 表示效果约为对照组的两倍"
    ]
    /// Timer used for typewriter animation
    private var typingTimer: Timer?
    /// Current line index for typewriter animation
    private var typingLineIndex: Int = 0
    /// Current character index within the line for typewriter animation
    private var typingCharIndex: Int = 0
    
    /// The time when the page became visible
    private var pageDisplayDate = Date()
    /// Ensures navigation only happens once
    private var hasScheduledNext = false
    
    let chart = ProgressChartView()
//    let chart = WeightChangeChartView()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        
        initUI()
//        startEntranceAnimation()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: statusBarHeight+kFitWidth(20), width: SCREEN_WIDHT, height: kFitHeight(37)))
        lab.text = "欢迎来到Elavatine"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var downImgIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_first_page_down_icon")
        return img
    }()
    lazy var downLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .medium)
        
        var attr = NSMutableAttributedString(string: "通过记录饮食，每天\n")
        var timeAttr = NSMutableAttributedString(string: "仅需2分钟")
        var tailAttr = NSMutableAttributedString(string: "*")
        
        timeAttr.yy_color = .THEME
        
        attr.append(timeAttr)
        attr.append(tailAttr)
        
        let range = NSMakeRange(0, attr.length)
        attr.yy_setLineHeightMultiple(1.2, range: range)
        lab.attributedText = attr
        
        return lab
    }()
    lazy var upImgIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_first_page_up_icon")
        return img
    }()
    lazy var upLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .medium)
        
        var attr = NSMutableAttributedString(string: "可将体重管理成效提\n高到原本的")
        var timeAttr = NSMutableAttributedString(string: "200%")
        var tailAttr = NSMutableAttributedString(string: "†")
        
        timeAttr.yy_color = WHColor_16(colorStr: "FF8C3B")
//        tailAttr.yy_font = .systemFont(ofSize: 16, weight: .medium)
        attr.append(timeAttr)
        attr.append(tailAttr)
        
        let range = NSMakeRange(0, attr.length)
        attr.yy_setLineHeightMultiple(1.2, range: range)
        lab.attributedText = attr
        
        return lab
    }()
    lazy var logoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_first_page_logo_icon")
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    private func createTipsLabel() -> UILabel {
        let lab = UILabel()
        lab.textAlignment = .left
        lab.numberOfLines = 1
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return lab
    }
    lazy var tipsLabel1: UILabel = {
        return createTipsLabel()
    }()
    lazy var tipsLabel2: UILabel = {
        return createTipsLabel()
    }()
    lazy var tipsLabel3: UILabel = {
        return createTipsLabel()
    }()
    
    /// Transparent view capturing taps to trigger nextBlock
    lazy var nextTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextTapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()

    private lazy var tipLabels: [UILabel] = [tipsLabel1, tipsLabel2, tipsLabel3]
}

extension GuideTotalFirstVM{
    @objc private func nextTapAction() {
//        nextBlock?()
        guard !hasScheduledNext else { return }
        hasScheduledNext = true
        let elapsed = Date().timeIntervalSince(pageDisplayDate)
        let delay = max(0, 2.5 - elapsed)
        if delay <= 0 {
            nextBlock?()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.nextBlock?()
            }
        }
    }
}

extension GuideTotalFirstVM{
    func initUI() {
        addSubview(titleLab)
        addSubview(downImgIcon)
        addSubview(downLabel)
        addSubview(upImgIcon)
        addSubview(upLabel)
        
        chart.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chart)
        chart.backgroundColor = .COLOR_BG_F5
        
        addSubview(logoImgView)
        addSubview(tipsLabel1)
        addSubview(tipsLabel2)
        addSubview(tipsLabel3)
        addSubview(nextTapView)
        
        tipsLabel1.text = tipsLines[0]
        tipsLabel2.text = tipsLines[1]
        tipsLabel3.text = tipsLines[2]
        
        NSLayoutConstraint.activate([
           chart.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: kFitWidth(15)),
           chart.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: kFitWidth(-15)),
           chart.topAnchor.constraint(equalTo: titleLab.bottomAnchor, constant: kFitWidth(147)),
//           chart.centerYAnchor.constraint(equalTo: self.centerYAnchor),
           chart.heightAnchor.constraint(equalTo: chart.widthAnchor, multiplier: 1/1.36)
       ])
//        NSLayoutConstraint.activate([
//                chart.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//                chart.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//                chart.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
//                chart.heightAnchor.constraint(equalToConstant: 240)
//            ])
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.chart.startGradientAnimation()
        })
        
        setConstrait()
        
        pageDisplayDate = Date()
        hasScheduledNext = false
    }
    func setConstrait(){
        downImgIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(30))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(63))
            make.width.equalTo(kFitWidth(14))
            make.height.equalTo(kFitWidth(20))
        }
        downLabel.snp.makeConstraints { make in
            make.left.equalTo(downImgIcon.snp.right).offset(kFitWidth(10))
            make.centerY.lessThanOrEqualTo(downImgIcon)
        }
        upLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-30))
            make.centerY.lessThanOrEqualTo(downImgIcon)
        }
        upImgIcon.snp.makeConstraints { make in
            make.right.equalTo(upLabel.snp.left).offset(kFitWidth(-10))
            make.centerY.lessThanOrEqualTo(downImgIcon)
            make.width.height.equalTo(downImgIcon)
        }
        
        // calculate final widths so text does not shift while typing
        let font = UIFont.systemFont(ofSize: 11, weight: .regular)
        let widths = tipsLines.map { line -> CGFloat in
            return (line as NSString).size(withAttributes: [.font: font]).width
        }
        tipsLabel1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImgView.snp.bottom).offset(kFitWidth(50))
//            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(30))
            make.width.equalTo(widths[0])
        }
        tipsLabel2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipsLabel1.snp.bottom).offset(kFitWidth(3))
            make.width.equalTo(widths[1])
        }
        tipsLabel3.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipsLabel2.snp.bottom).offset(kFitWidth(3))
            make.width.equalTo(widths[2])
        }
        logoImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(chart.snp.bottom).offset(kFitWidth(50))
            make.width.equalTo(kFitWidth(111))
//            make.bottom.equalTo(tipsLabel.snp.top).offset(kFitWidth(-50))
        }
        
        nextTapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 动画依次将元素从右侧拖入并淡入图表
   func startEntranceAnimation() {
       layoutIfNeeded()
       let offset = SCREEN_WIDHT
       let views = [downImgIcon, downLabel, upImgIcon, upLabel]
       for v in views {
           v.transform = CGAffineTransform(translationX: offset, y: 0)
           v.alpha = 0
       }
//       chartImgView.alpha = 0
       logoImgView.alpha = 0
       let relativeDuration = 0.45

       UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: .calculationModeLinear) {
           UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: relativeDuration) {
               self.downImgIcon.transform = .identity
               self.downImgIcon.alpha = 1
           }
           UIView.addKeyframe(withRelativeStartTime: 0.18, relativeDuration: relativeDuration) {
               self.downLabel.transform = .identity
               self.downLabel.alpha = 1
           }
           UIView.addKeyframe(withRelativeStartTime: 0.45, relativeDuration: relativeDuration) {
               self.upImgIcon.transform = .identity
               self.upImgIcon.alpha = 1
           }
           UIView.addKeyframe(withRelativeStartTime: 0.68, relativeDuration: relativeDuration) {
               self.upLabel.transform = .identity
               self.upLabel.alpha = 1
           }
           UIView.addKeyframe(withRelativeStartTime: 1, relativeDuration: relativeDuration) {
               self.logoImgView.alpha = 1
           }
       }completion: { _ in
//           self.chartImgView.startAnimation()
           
           self.startTipsTypingAnimation()
//           self.startTypingAnimation()
       }
   }
    
    /// Starts the typewriter animation for the tips label
    func startTipsTypingAnimation() {
        typingTimer?.invalidate()
        typingLineIndex = 0
        typingCharIndex = 0
        tipLabels.forEach { $0.text = "" }
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.typingLineIndex >= self.tipsLines.count {
                timer.invalidate()
//                self.tipsLabel.textAlignment = .center
                return
            }
            
            let line = self.tipsLines[self.typingLineIndex]
            if self.typingCharIndex >= line.count {
                self.typingLineIndex += 1
                self.typingCharIndex = 0
                if self.typingLineIndex >= self.tipsLines.count {
                    timer.invalidate()
                }
                return
            }

            self.typingCharIndex += 1
            let endIndex = line.index(line.startIndex, offsetBy: self.typingCharIndex)
            self.tipLabels[self.typingLineIndex].text = String(line[..<endIndex])
        }
    }

    /// Stops the typewriter animation if running
    func stopTipsTypingAnimation() {
        typingTimer?.invalidate()
        typingTimer = nil
    }
    
    /// 显示折线图动画
    func startChartAnimation() {
        // Ensure the chart has correct bounds before starting animations
        layoutIfNeeded()
        chart.layoutIfNeeded()
        chart.startGradientAnimation()
        chart.startProgressAnimation()
    }
}
