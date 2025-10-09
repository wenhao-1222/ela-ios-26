//
//  NaturalStatCalendarCollectionCellItemLeftVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/13.
//

import Foundation

class NaturalStatCalendarCollectionCellItemLeftVM: UIView {
    
    let selfWidth = kFitWidth(11)
    let selfHeight = kFitWidth(78)
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: selfWidth, height: selfHeight))
        
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var carloriesLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(30), width: selfWidth, height: kFitWidth(12)))
//        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 8, weight: .medium)
        lab.textColor = .THEME
        lab.text = "卡"
        lab.textAlignment = .right
        
        return lab
    }()
    lazy var carboLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(42), width: selfWidth, height: kFitWidth(12)))
//        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 8, weight: .medium)
        lab.textColor = .COLOR_CARBOHYDRATE
        lab.text = "碳"
        lab.textAlignment = .right
        
        return lab
    }()
    lazy var proteinLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(54), width: selfWidth, height: kFitWidth(12)))
//        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 8, weight: .medium)
        lab.textColor = .COLOR_PROTEIN
        lab.text = "蛋"
        lab.textAlignment = .right
        
        return lab
    }()
    lazy var fatLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(66), width: selfWidth, height: kFitWidth(12)))
//        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 8, weight: .medium)
        lab.textColor = .COLOR_FAT
        lab.text = "脂"
        lab.textAlignment = .right
        
        return lab
    }()
}

extension NaturalStatCalendarCollectionCellItemLeftVM{
    func initUI() {
        addSubview(carloriesLabel)
        addSubview(carboLabel)
        addSubview(proteinLabel)
        addSubview(fatLabel)
    }
}
