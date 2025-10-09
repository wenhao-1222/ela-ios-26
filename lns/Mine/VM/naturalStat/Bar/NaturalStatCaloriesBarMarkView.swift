//
//  NaturalStatCaloriesBarMarkView.swift
//  lns
//
//  Created by LNS2 on 2024/9/11.
//

import Foundation

class NaturalStatCaloriesBarMarkView: UIView {
    
    
    var selfHeight = kFitWidth(0)
    var shapeLayer = CAShapeLayer()
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
//        super.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(80), height: kFitWidth(42)))
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: kFitWidth(80), height: frame.size.height))
        
        selfHeight = frame.size.height
        self.backgroundColor = .clear
//        self.isUserInteractionEnabled = true
        // Disable interaction so taps pass through to the chart view
        self.isUserInteractionEnabled = false
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(80), height: kFitWidth(42)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(4)
        return vi
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(8), width: kFitWidth(80), height: kFitWidth(12)))
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 10, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.adjustsFontSizeToFitWidth = true
//        lab.backgroundColor = WHColor_ARC()
        
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(20), width: kFitWidth(64), height: kFitWidth(14)))
        lab.font = .systemFont(ofSize: 12, weight: .bold)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.adjustsFontSizeToFitWidth = true
//        lab.backgroundColor = WHColor_ARC()
        
        return lab
    }()
}

extension NaturalStatCaloriesBarMarkView{
    func updateUI(dict:NSDictionary) {
        DLLog(message: "dict:\(dict)")
        let caloriesString = "\(dict.doubleValueForKey(key: "calories"))"
        numberLabel.text = "\(WHUtils.convertStringToStringNoDigit(caloriesString) ?? "0")千卡"
        if dict["sdate"] != nil{
            let sdateStr = dict.stringValueForKey(key: "sdate")
            timeLabel.text = sdateStr
        }else{
            timeLabel.text = "\(dict.stringValueForKey(key: "year"))年\(dict.stringValueForKey(key: "month"))月"
        }
    }
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: kFitWidth(40), y: kFitWidth(42)))
        path.addLine(to: CGPoint.init(x: kFitWidth(40), y: selfHeight-kFitWidth(22)))
        
        shapeLayer.path = path.cgPath
        shapeLayer.allowsEdgeAntialiasing = true
        shapeLayer.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.2).cgColor // 颜色
        shapeLayer.lineDashPhase = kFitWidth(1)
        shapeLayer.fillColor = nil // 无填充色
        shapeLayer.lineWidth = kFitWidth(1) // 线宽
        shapeLayer.lineDashPattern = [4,1]
    }
}

extension NaturalStatCaloriesBarMarkView{
    func initUI() {
        self.layer.addSublayer(shapeLayer)
        addSubview(bgView)
        bgView.addSubview(timeLabel)
        bgView.addSubview(numberLabel)
        
//        setConstrait()
        bgView.addShadow()
    }
    func setConstrait() {
        timeLabel.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(8))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-8))
            make.right.equalTo(kFitWidth(-8))
        }
    }
}
