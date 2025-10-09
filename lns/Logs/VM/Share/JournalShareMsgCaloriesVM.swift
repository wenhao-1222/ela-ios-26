//
//  JournalShareMsgCaloriesVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/30.
//


class JournalShareMsgCaloriesVM: UIView {
    
    var selfHeight = kFitWidth(194)
    var selfWidth = kFitWidth(0)
    var msgDict = NSDictionary()
    
    let topGap = kFitWidth(25)//圆弧距离顶部距离
    let arcRadius = kFitWidth(120)//圆弧半径
    let lineWidth = kFitWidth(9)//圆弧宽度
    
    var circleCenter = CGPoint(x: 0, y: 0 )
    let startAngle = CGFloat(-Double.pi)
    
    //圆弧
    let bottomGrayLayer = CAShapeLayer()//底部圆弧
    var bottomGrayPath = UIBezierPath()
    let caloriesGrayLayer = CAShapeLayer()//卡路里
    var gradientLayer = CAGradientLayer()
    var caloriesGrayPath = UIBezierPath()
    let sportGrayLayer = CAShapeLayer()//运动
    var sportGrayPath = UIBezierPath()
    let caloriesCoverGrayLayer = CAShapeLayer()//超出摄入
    var caloriesCoverGrayPath = UIBezierPath()
    let caloriesCoverCircleLayer = CAShapeLayer()//超出摄入末端的圆弧
    var caloriesCoverCirclePath = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(84), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        selfWidth = SCREEN_WIDHT-kFitWidth(84)
        circleCenter = CGPoint.init(x: selfWidth*0.5, y: topGap + arcRadius)
        
        initLayer()
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        updateLayer()
    }
    lazy var caloriesIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "journal_share_calories_icon")
        
        return img
    }()
    lazy var currentCaloriesLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 11, weight: .medium)
        lab.text = "已摄入千卡"
        
        return lab
    }()
    lazy var currentCaloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = UIFont().DDInFontSemiBold(fontSize: 41)
        
        return lab
    }()
    lazy var caloriesBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F1F1F1")
        vi.layer.cornerRadius = kFitWidth(11)
        
        return vi
    }()
    lazy var caloriesLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "目标"
        
        return lab
    }()
    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = UIFont().DDInFontSemiBold(fontSize: 13)
        
        return lab
    }()
    lazy var sportCaloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_SPORT
        lab.font = UIFont().DDInFontMedium(fontSize: 9)
        
        return lab
    }()
    lazy var caloriesRemainBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F1F1F1")
        vi.layer.cornerRadius = kFitWidth(11)
        
        return vi
    }()
    lazy var caloriesRemainLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "剩余"
        
        return lab
    }()
    lazy var caloriesRemainLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = UIFont().DDInFontSemiBold(fontSize: 13)
        
        return lab
    }()
}

extension JournalShareMsgCaloriesVM{
    func updateUI(dict:NSDictionary) {
        self.msgDict = dict
        DLLog(message: "updateUI(dict:\(dict)")
        updateNumber()
        setNeedsDisplay()
    }
    func updateLayer() {
        let currentCalories = Int(msgDict.doubleValueForKey(key: "calories"))
        let targetCalories = Int(msgDict.doubleValueForKey(key: "caloriesden"))
        let sportCalories = Int(msgDict.stringValueForKey(key: "sportCalories").floatValue.rounded())
        let totalCalories = Float(targetCalories + sportCalories)
        
        let caloriesPercent = Float(currentCalories)/Float(totalCalories)
        let sportPercent = Float(sportCalories)/totalCalories
        
        var caloriesEndAngle = -(Double.pi)*Double(1-caloriesPercent)
        var coverEndAndle = -(Double.pi)
        
        if caloriesPercent >= 1{
            caloriesEndAngle = 0
            if caloriesPercent >= 2{
                coverEndAndle = 0
            }else{
                let coverPercent = caloriesPercent - 1
                coverEndAndle = -(Double.pi)*Double(1-coverPercent)
            }
        }
        
        let sportEndAngle = Double.pi*Double(sportPercent)
        
        bottomGrayPath = UIBezierPath()
        bottomGrayPath.addArc(withCenter: circleCenter, radius: arcRadius, startAngle: startAngle, endAngle: 0, clockwise: true)
        bottomGrayLayer.path = bottomGrayPath.cgPath
        
        caloriesGrayPath = UIBezierPath()
        caloriesGrayPath.addArc(withCenter: circleCenter, radius: arcRadius, startAngle: startAngle, endAngle: caloriesEndAngle, clockwise: true)
        caloriesGrayLayer.path = caloriesGrayPath.cgPath//CGRect.init(x: circleCenter.x-arcRadius-lineWidth, y: 0, width: arcRadius, height: arcRadius)
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: caloriesGrayPath.currentPoint.x+lineWidth, height: selfHeight)
        
        sportGrayPath = UIBezierPath()
        sportGrayPath.addArc(withCenter: circleCenter, radius: arcRadius, startAngle: 0, endAngle: -sportEndAngle, clockwise: false)
        sportGrayLayer.path = sportGrayPath.cgPath
        
        if caloriesPercent > 1{
            caloriesCoverGrayLayer.isHidden = false
            caloriesCoverCircleLayer.isHidden = false
        }else{
            caloriesCoverGrayLayer.isHidden = true
            caloriesCoverCircleLayer.isHidden = true
            return
        }
        caloriesCoverGrayPath = UIBezierPath()
        caloriesCoverGrayPath.addArc(withCenter: circleCenter, radius: arcRadius, startAngle: startAngle, endAngle: coverEndAndle, clockwise: true)
        caloriesCoverGrayLayer.path = caloriesCoverGrayPath.cgPath
        
        caloriesCoverCirclePath = UIBezierPath()
        caloriesCoverCirclePath.move(to: caloriesCoverGrayPath.currentPoint)
        caloriesCoverCirclePath.addArc(withCenter: caloriesCoverGrayPath.currentPoint, radius: lineWidth*0.5, startAngle: coverEndAndle, endAngle: coverEndAndle+Double.pi, clockwise: true)
        caloriesCoverCirclePath.addLine(to: caloriesCoverGrayPath.currentPoint)
        caloriesCoverCircleLayer.path = caloriesCoverCirclePath.cgPath
    }
    func updateNumber() {
        let currentCalories = Int(msgDict.doubleValueForKey(key: "calories"))
        let targetCalories = Int(msgDict.doubleValueForKey(key: "caloriesden"))
        let sportCalories = Int(msgDict.stringValueForKey(key: "sportCalories").floatValue.rounded())
        let totalCalories = targetCalories + sportCalories
        
        caloriesLabel.text = "\(targetCalories)"
        
        currentCaloriesLabel.text = "\(currentCalories)"
        
        if sportCalories > 0 {
            sportCaloriesLabel.text = "+\(sportCalories)"
        }else{
            sportCaloriesLabel.text = ""
        }
        
        if totalCalories >= currentCalories{
            caloriesRemainLabel.text = "\(totalCalories - currentCalories)"
        }else{
            caloriesRemainLab.text = "超出"
            caloriesRemainLab.textColor = WHColor_16(colorStr: "FF4000")
            caloriesRemainBgView.backgroundColor = WHColorWithAlpha(colorStr: "FF0000", alpha: 0.06)
            caloriesRemainLabel.text = "\(abs(totalCalories - currentCalories))"
            caloriesRemainLabel.textColor = WHColor_16(colorStr: "FF4000")
        }
    }
}

extension JournalShareMsgCaloriesVM{
    func initUI() {
        addSubview(caloriesIconImg)
        addSubview(currentCaloriesLab)
        addSubview(currentCaloriesLabel)
        addSubview(caloriesBgView)
        caloriesBgView.addSubview(caloriesLab)
        caloriesBgView.addSubview(caloriesLabel)
        caloriesBgView.addSubview(sportCaloriesLabel)
        addSubview(caloriesRemainBgView)
        caloriesRemainBgView.addSubview(caloriesRemainLab)
        caloriesRemainBgView.addSubview(caloriesRemainLabel)
        setConstrait()
    }
    func setConstrait() {
        currentCaloriesLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(7))
            make.top.equalTo(kFitWidth(66))
        }
        caloriesIconImg.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(currentCaloriesLab)
            make.right.equalTo(currentCaloriesLab.snp.left).offset(kFitWidth(-4))
            make.width.equalTo(kFitWidth(10))
            make.width.equalTo(kFitWidth(13))
        }
        currentCaloriesLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(currentCaloriesLab.snp.bottom).offset(kFitWidth(16))
        }
        if isIpad(){
            caloriesBgView.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(-50))
                make.bottom.equalTo(kFitWidth(-23))
                make.height.equalTo(kFitWidth(22))
            }
            caloriesRemainBgView.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(50))
                make.bottom.equalTo(kFitWidth(-23))
                make.height.equalTo(kFitWidth(22))
            }
        }else{
            caloriesBgView.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualTo(kFitWidth(57)+kFitWidth(38))
    //            make.right.equalTo(-selfWidth*0.5-kFitWidth(13))
                make.bottom.equalTo(kFitWidth(-23))
                make.height.equalTo(kFitWidth(22))
            }
            caloriesRemainBgView.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualTo(kFitWidth(159)+kFitWidth(38))
    //            make.left.equalTo(selfWidth*0.5+kFitWidth(13))
                make.bottom.equalTo(kFitWidth(-23))
                make.height.equalTo(kFitWidth(22))
            }
        }
        
        caloriesLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
        }
        caloriesLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(12))
            make.left.equalTo(caloriesLab.snp.right).offset(kFitWidth(3))
//            make.right.equalTo(kFitWidth(-12))
//            make.top.equalTo(kFitWidth(4))
            make.centerY.lessThanOrEqualToSuperview()
//            make.bottom.equalTo(kFitWidth(-4))
        }
        sportCaloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesLabel.snp.right)
            make.right.equalTo(kFitWidth(-12))
            make.centerY.lessThanOrEqualToSuperview()
        }
        caloriesRemainLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
        }
        caloriesRemainLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesRemainLab.snp.right).offset(kFitWidth(3))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(kFitWidth(4))
            make.bottom.equalTo(kFitWidth(-4))
        }
        
    }
    func initLayer() {
        self.layer.addSublayer(bottomGrayLayer)
        self.layer.addSublayer(sportGrayLayer)
//        self.layer.addSublayer(caloriesGrayLayer)
        self.layer.addSublayer(gradientLayer)
        self.layer.addSublayer(caloriesCoverGrayLayer)
        self.layer.addSublayer(caloriesCoverCircleLayer)
        
        bottomGrayLayer.lineCap = .round
        bottomGrayLayer.allowsEdgeAntialiasing = true
        bottomGrayLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_06.cgColor // 弧线颜色
        bottomGrayLayer.fillColor = nil // 无填充色
        bottomGrayLayer.lineWidth = lineWidth // 线宽
        
        sportGrayLayer.lineCap = .round
        sportGrayLayer.allowsEdgeAntialiasing = true
        sportGrayLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
        sportGrayLayer.fillColor = nil // 无填充色
        sportGrayLayer.lineWidth = lineWidth // 线宽
        
        caloriesGrayLayer.lineCap = .round
        caloriesGrayLayer.allowsEdgeAntialiasing = true
        caloriesGrayLayer.strokeColor = UIColor.COLOR_CALORI.cgColor // 弧线颜色
        caloriesGrayLayer.fillColor = nil // 无填充色
        caloriesGrayLayer.lineWidth = lineWidth // 线宽
        caloriesGrayLayer.frame = bounds//CGRect.init(x: circleCenter.x-arcRadius-lineWidth*0.5, y: topGap-lineWidth*0.5, width: arcRadius*2+lineWidth, height: arcRadius+lineWidth)
        
        gradientLayer.colors = [WHColor_16(colorStr: "00EEFF").cgColor,WHColor_16(colorStr: "007AFF").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.mask = caloriesGrayLayer
        
        caloriesCoverGrayLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.cgColor // 弧线颜色
        caloriesCoverGrayLayer.fillColor = nil // 无填充色
        caloriesCoverGrayLayer.lineDashPhase = kFitWidth(0)
        caloriesCoverGrayLayer.lineWidth = lineWidth // 线宽
        caloriesCoverGrayLayer.lineDashPattern = [4,4]
        
        caloriesCoverCircleLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.cgColor
        caloriesCoverCircleLayer.fillColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.cgColor
        caloriesCoverCircleLayer.lineWidth = kFitWidth(0.2) // 线宽
    }
}
