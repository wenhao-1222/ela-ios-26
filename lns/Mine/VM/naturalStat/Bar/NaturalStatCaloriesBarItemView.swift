//
//  NaturalStatCaloriesBarItemView.swift
//  lns
//
//  Created by LNS2 on 2024/9/9.
//

import Foundation

class NaturalStatCaloriesBarItemView: UIView {
    
    let selfHeight = kFitWidth(160)
    var selfWidth = kFitWidth(30)
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: kFitWidth(40), width: frame.size.width, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        selfWidth = frame.size.width
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: selfHeight, width: selfWidth, height: 0))
        vi.backgroundColor = .THEME
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 10, weight: .medium)
        lab.textAlignment = .center
        lab.isHidden = true
        
        return lab
    }()
}

extension NaturalStatCaloriesBarItemView{
    func updateUI(dict:NSDictionary,maxValue:Double) {
        let caloriesNum = dict.doubleValueForKey(key: "calories")
        let percent = caloriesNum/maxValue
        let bgViewHeight = percent * selfHeight
        
//        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear, animations: {
            self.bgView.frame = CGRect.init(x: 0, y: self.selfHeight-bgViewHeight, width: self.selfWidth, height: bgViewHeight)
//        })
    }
}

extension NaturalStatCaloriesBarItemView{
    func initUI(){
        addSubview(bgView)
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(bgView)
            make.bottom.equalTo(bgView.snp.top).offset(kFitWidth(-4))
        }
    }
}
