//
//  AITipsDonationCell.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITipsDonationCell: UITableViewCell {
    
    private let lineLayer = CAShapeLayer()
    private var linePath = UIBezierPath()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    
    override func draw(_ rect: CGRect) {
        lineLayer.strokeColor = WHColor_16(colorStr: "B2B2B2").cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = kFitWidth(1) // 线宽
        lineLayer.lineDashPattern = [4,4]
        
        linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: kFitWidth(16), y: rect.height-kFitWidth(1)))
        linePath.addLine(to: CGPoint(x: SCREEN_WIDHT-kFitWidth(16), y: rect.height-kFitWidth(1)))
        
        lineLayer.path = linePath.cgPath
    }
}

extension AITipsDonationCell{
    func initUI() {
        self.layer.addSublayer(lineLayer)
        contentView.addSubview(contentLab)
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-10))
        }
    }
}
