//
//  JournalShareMsgNaturalItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/6.
//

enum NATURAL_TYPE {
    case carbo
    case protein
    case fat
    case calories
}


class JournalShareMsgNaturalItemVM: UIView {
    
    var selfHeight = kFitWidth(61)
    var selfWidth = ((SCREEN_WIDHT-kFitWidth(32)-kFitWidth(84))-kFitWidth(16*2)-kFitWidth(23)*2)/3
    
    let lineWidth = kFitWidth(4)
    let bottomLayer = CAShapeLayer()//底部进度
    var bottomPath = UIBezierPath()
    let progressGrayLayer = CAShapeLayer()//进度
    var progressPath = UIBezierPath()
    let progressCoverLayer = CAShapeLayer()//超出部分
    var progressCoverPath = UIBezierPath()
    
    var bottomColor = UIColor.COLOR_CARBOHYDRATE
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
    
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    lazy var currentNumberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    lazy var totalNumberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
}

extension JournalShareMsgNaturalItemVM{
    func updateUI(type:NATURAL_TYPE,currentNum:Double,totalNum:Double) {
        switch type {
        case .carbo:
            bottomColor = .COLOR_CARBOHYDRATE_20
            progressColor = .COLOR_CARBOHYDRATE
            titleLabel.text = "碳水"
        case .protein:
            bottomColor = .COLOR_PROTEIN_20
            progressColor = .COLOR_PROTEIN
            titleLabel.text = "蛋白质"
        case .fat:
            bottomColor = .COLOR_FAT_20
            progressColor = .COLOR_FAT
            titleLabel.text = "脂肪"
        case .calories:
            break
        }
        self.currentNum = Int(currentNum.rounded())
        self.totalNum = Int(totalNum.rounded())
        if self.totalNum <= 0 {
            self.totalNum = 1
        }
        self.currentNumberLabel.text = "\(self.currentNum)"
        self.totalNumberLabel.text = "/\(self.totalNum)g"
        if self.currentNum > self.totalNum{
            self.currentNumberLabel.textColor = WHColor_16(colorStr: "FF4000")
        }
        
        setNeedsDisplay()
    }
    func updateProgress() {
        bottomPath = UIBezierPath()
        progressPath = UIBezierPath()
        progressCoverPath = UIBezierPath()
        
        bottomLayer.strokeColor = bottomColor.cgColor // 弧线颜色
        progressGrayLayer.strokeColor = progressColor.cgColor // 弧线颜色
        
        let lineOriginY = kFitWidth(31)
        
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

extension JournalShareMsgNaturalItemVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(currentNumberLabel)
        addSubview(totalNumberLabel)
        
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
            make.left.equalToSuperview()
            make.top.equalTo(kFitWidth(12))
        }
        currentNumberLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(kFitWidth(38))
        }
        totalNumberLabel.snp.makeConstraints { make in
            make.left.equalTo(currentNumberLabel.snp.right)
            make.centerY.lessThanOrEqualTo(currentNumberLabel)
        }
    }
}
