//
//  NaturalStatCaloriesBarChartXAxisView.swift
//  lns
//
//  Created by LNS2 on 2024/9/10.
//

import Foundation

class NaturalStatCaloriesBarChartXAxisView: UIView {
    
    let selfHeight = kFitWidth(32)
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var xAxisLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
}

extension NaturalStatCaloriesBarChartXAxisView{
    func updateUI(textStr:String) {
        xAxisLabel.text = textStr
    }
    func updateUI(dict:NSDictionary) {
//        let sdate = dict.stringValueForKey(key: "sdate")
        if let sdate = dict["sdate"]{
            let sdateStr = dict.stringValueForKey(key: "sdate")
            xAxisLabel.text = "\(sdateStr.mc_cutToSuffix(from: sdateStr.count-2))日"
        }else{
            let monthStr = dict.stringValueForKey(key: "month")
            xAxisLabel.text = "\(monthStr)月"
        }
    }
}

extension NaturalStatCaloriesBarChartXAxisView{
    func initUI() {
        addSubview(xAxisLabel)
        xAxisLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(2))
            make.width.lessThanOrEqualToSuperview()
        }
    }
}
