//
//  FriendRankingDailyNaturalVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/3.
//

class FriendRankingDailyNaturalVM: UIView {
    
    var selfHeight = kFitWidth(46)
    var selfWidth = ((SCREEN_WIDHT-kFitWidth(91)-kFitWidth(20))-kFitWidth(16))*0.5
    
    let lineWidth = kFitWidth(4)
    let bottomLayer = CAShapeLayer()//底部进度
    var bottomPath = UIBezierPath()
    let progressGrayLayer = CAShapeLayer()//进度
    var progressPath = UIBezierPath()
    let progressCoverLayer = CAShapeLayer()//超出部分
    var progressCoverPath = UIBezierPath()
    
    var bottomColor = UIColor.COLOR_TEXT_TITLE_0f1214_06
    var progressColor = UIColor.COLOR_CARBOHYDRATE
    
    var currentNum = 0
    var totalNum = 0
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        updateProgress()
    }
    
    lazy var titleLabel : LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var currentNumberLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var totalNumberLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    lazy var remainLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
}

extension FriendRankingDailyNaturalVM{
    func showCfg(_ config: SkeletonConfig = SkeletonConfig()) {
        titleLabel.text = nil
        currentNumberLabel.text = nil
        totalNumberLabel.text = nil
        remainLabel.text = nil
        
        titleLabel.showSkeleton(config)
//        currentNumberLabel.showSkeleton(config)
        totalNumberLabel.showSkeleton(config)
        remainLabel.showSkeleton(config)
    }
}

extension FriendRankingDailyNaturalVM{
    func updateUI(type:NATURAL_TYPE,currentNum:Double,totalNum:Double,sign:String) {
        updateContrait()
        var unitStr = "g"
        switch type {
        case .carbo:
//            bottomColor = .COLOR_CARBOHYDRATE_20
//            progressColor = .COLOR_CARBOHYDRATE
            titleLabel.text = "碳水"
        case .protein:
//            bottomColor = .COLOR_PROTEIN_20
//            progressColor = .COLOR_PROTEIN
            titleLabel.text = "蛋白质"
        case .fat:
//            bottomColor = .COLOR_FAT_20
//            progressColor = .COLOR_FAT
            titleLabel.text = "脂肪"
        case .calories:
//            bottomColor = .COLOR_FAT_20
//            progressColor = .COLOR_FAT
            titleLabel.text = "卡路里"
            unitStr = "kcal"
        }
        self.currentNum = Int(currentNum.rounded())
        self.totalNum = Int(totalNum.rounded())
//        if self.totalNum <= 0 {
//            self.totalNum = 1
//        }
        self.currentNumberLabel.text = "\(self.currentNum)"
        self.totalNumberLabel.text = "/\(self.totalNum)"
        
        let remainNum = abs(totalNum - currentNum)
//        self.remainLabel.text = "\(totalNum - currentNum)"
        
        if sign == "0" {
            self.remainLabel.text = "剩余\(WHUtils.convertStringToStringNoDigit("\(remainNum.rounded())") ?? "")\(unitStr)"
        }else if sign == "2"{
            self.remainLabel.textColor = WHColor_16(colorStr: "FD2C21")
            self.remainLabel.text = "超出\(WHUtils.convertStringToStringNoDigit("\(remainNum.rounded())") ?? "")\(unitStr)"
        }else{
            self.remainLabel.text = "已达成"
        }
        
        setNeedsDisplay()
        
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [titleLabel, currentNumberLabel, totalNumberLabel, remainLabel].forEach { $0.hideSkeletonWithCrossfade() }
    }
    func updateProgress() {
        bottomPath = UIBezierPath()
        progressPath = UIBezierPath()
        progressCoverPath = UIBezierPath()
        
        bottomLayer.strokeColor = bottomColor.cgColor // 弧线颜色
        progressGrayLayer.strokeColor = progressColor.cgColor // 弧线颜色
        
        let lineOriginY = kFitWidth(24.5)
        
        bottomPath.move(to: CGPoint.init(x: 0, y: lineOriginY))
        bottomPath.addLine(to: CGPoint.init(x: selfWidth, y: lineOriginY))
        bottomLayer.path = bottomPath.cgPath
        
        if self.currentNum == 0 {
            progressGrayLayer.strokeColor = UIColor.clear.cgColor
            progressCoverLayer.strokeColor = UIColor.clear.cgColor
            return
        }
        let percent = CGFloat(self.currentNum)/CGFloat(self.totalNum)
        progressPath.move(to: CGPoint.init(x: 0, y: lineOriginY))
        progressCoverPath.move(to: CGPoint.init(x: 0, y: lineOriginY))
        
        if percent >= 1{
            progressPath.addLine(to: CGPoint.init(x: selfWidth, y: lineOriginY))
            let coverPercent = (percent - 1) > 1 ? 1 : (percent - 1)
            let coverProgressWidth = selfWidth * coverPercent
            progressCoverPath.addLine(to: CGPoint.init(x: coverProgressWidth, y: lineOriginY))
        }else{
            let progressWidth = selfWidth * percent
            progressPath.addLine(to: CGPoint.init(x: progressWidth, y: lineOriginY))
        }
        progressGrayLayer.path = progressPath.cgPath
        progressCoverLayer.path = progressCoverPath.cgPath
    }
}

extension FriendRankingDailyNaturalVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(currentNumberLabel)
        addSubview(totalNumberLabel)
        addSubview(remainLabel)
        
        initLayer()
        setConstrait()
    }
    
    func initLayer() {
        self.layer.addSublayer(bottomLayer)
        self.layer.addSublayer(progressGrayLayer)
        self.layer.addSublayer(progressCoverLayer)
        
        bottomLayer.lineCap = .round
        bottomLayer.allowsEdgeAntialiasing = true
        bottomLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_06.cgColor // 弧线颜色
        bottomLayer.fillColor = nil // 无填充色
        bottomLayer.lineWidth = lineWidth // 线宽
        
        progressGrayLayer.lineCap = .round
        progressGrayLayer.allowsEdgeAntialiasing = true
        progressGrayLayer.fillColor = nil // 无填充色
        progressGrayLayer.lineWidth = lineWidth // 线宽
        
//        progressCoverLayer.lineCap = .round
        progressCoverLayer.lineWidth = lineWidth // 线宽
        progressCoverLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor // 弧线颜色
        progressCoverLayer.fillColor = nil // 无填充色
        progressCoverLayer.lineDashPhase = kFitWidth(0)
        progressCoverLayer.lineWidth = lineWidth // 线宽
        progressCoverLayer.lineDashPattern = [4,2]
    }
    
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(kFitWidth(58))
            make.height.equalTo(kFitWidth(16))
        }
        currentNumberLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalTo(totalNumberLabel.snp.left)//.offset(kFitWidth(14))
            make.width.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(16))
        }
        totalNumberLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.lessThanOrEqualTo(currentNumberLabel)
            make.width.equalTo(kFitWidth(54))
            make.height.equalTo(kFitWidth(16))
        }
        remainLabel.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(68))
            make.height.equalTo(kFitWidth(16))
        }
    }
    func updateContrait() {
        titleLabel.snp.remakeConstraints { make in
            make.left.top.equalToSuperview()
        }
        currentNumberLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalTo(totalNumberLabel.snp.left)
        }
        totalNumberLabel.snp.remakeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.lessThanOrEqualTo(currentNumberLabel)
        }
        remainLabel.snp.remakeConstraints { make in
            make.left.bottom.equalToSuperview()
        }
    }
}
