//
//  NaturalStatCPFBarMarkView.swift
//  lns
//
//  Created by LNS2 on 2024/9/12.
//

import Foundation

class NaturalStatCPFBarMarkView: UIView {
    
    var selfHeight = kFitWidth(0)
    var shapeLayer = CAShapeLayer()
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: kFitWidth(86), height: frame.size.height))
        
        selfHeight = frame.size.height
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(86), height: kFitWidth(86)))
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
    lazy var carboView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(28), width: kFitWidth(4), height: kFitWidth(8)))
        vi.backgroundColor = .COLOR_CARBOHYDRATE
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var carboNumberLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(26), width: kFitWidth(60), height: kFitWidth(12)))
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var proteinView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(48), width: kFitWidth(4), height: kFitWidth(8)))
        vi.backgroundColor = .COLOR_PROTEIN
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var proteinNumberLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(46), width: kFitWidth(60), height: kFitWidth(12)))
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var fatView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(68), width: kFitWidth(4), height: kFitWidth(8)))
        vi.backgroundColor = .COLOR_FAT
        vi.layer.cornerRadius = kFitWidth(1)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var fatNumberLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(66), width: kFitWidth(60), height: kFitWidth(12)))
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension NaturalStatCPFBarMarkView{
    func updateUI(dict:NSDictionary) {
        DLLog(message: "dict:\(dict)")
        let carbohydrateString = "\(dict.doubleValueForKey(key: "carbohydrate"))"
        carboNumberLabel.text = "碳水 \(WHUtils.convertStringToStringNoDigit(carbohydrateString) ?? "0")g"
        
        let proteinString = "\(dict.doubleValueForKey(key: "protein"))"
        proteinNumberLabel.text = "蛋白质 \(WHUtils.convertStringToStringNoDigit(proteinString) ?? "0")g"
        
        let fatString = "\(dict.doubleValueForKey(key: "fat"))"
        fatNumberLabel.text = "脂肪 \(WHUtils.convertStringToStringNoDigit(fatString) ?? "0")g"
        
        if dict["sdate"] != nil{
            let sdateStr = dict.stringValueForKey(key: "sdate")
            timeLabel.text = sdateStr
        }else{
            timeLabel.text = "\(dict.stringValueForKey(key: "year"))年\(dict.stringValueForKey(key: "month"))月"
        }
        self.setNeedsDisplay()
    }
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: kFitWidth(43), y: kFitWidth(86)))
        path.addLine(to: CGPoint.init(x: kFitWidth(43), y: selfHeight-kFitWidth(22)))
        
        shapeLayer.path = path.cgPath
        shapeLayer.allowsEdgeAntialiasing = true
        shapeLayer.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.2).cgColor // 颜色
        shapeLayer.lineDashPhase = kFitWidth(1)
        shapeLayer.fillColor = nil // 无填充色
        shapeLayer.lineWidth = kFitWidth(1) // 线宽
        shapeLayer.lineDashPattern = [4,1]
    }
}

extension NaturalStatCPFBarMarkView{
    func initUI() {
        self.layer.addSublayer(shapeLayer)
        addSubview(bgView)
        bgView.addSubview(timeLabel)
        bgView.addSubview(carboView)
        bgView.addSubview(carboNumberLabel)
        bgView.addSubview(proteinView)
        bgView.addSubview(proteinNumberLabel)
        bgView.addSubview(fatView)
        bgView.addSubview(fatNumberLabel)
        
//        setConstrait()
        bgView.addShadow()
    }
    func setConstrait() {
        timeLabel.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(8))
        }
        carboNumberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-8))
            make.right.equalTo(kFitWidth(-8))
        }
    }
}

