//
//  NaturalStatCPFDGBarLegendView.swift
//  lns
//
//  Created by LNS2 on 2024/9/12.
//

import Foundation

class NaturalStatCPFDGBarLegendView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(46), width: kFitWidth(200), height: kFitWidth(15)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        initUI()
    }
    lazy var carboView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARBOHYDRATE
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var carboLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "碳水"
        return lab
    }()
    lazy var proteinView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_PROTEIN
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var proteinLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "蛋白质"
        return lab
    }()
    lazy var fatView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_FAT
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var fatLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "脂肪"
        return lab
    }()
}

extension NaturalStatCPFDGBarLegendView{
    func initUI() {
        addSubview(carboView)
        addSubview(carboLabel)
        addSubview(proteinView)
        addSubview(proteinLabel)
        addSubview(fatView)
        addSubview(fatLabel)
        
        setConstrait()
    }
    func setConstrait() {
        carboView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(8))
        }
        carboLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.height.equalToSuperview()
        }
        proteinView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(56))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(carboView)
        }
        proteinLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(68))
            make.top.height.equalToSuperview()
        }
        fatView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(124))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(carboView)
        }
        fatLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(136))
            make.top.height.equalToSuperview()
        }
    }
}
