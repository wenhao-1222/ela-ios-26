//
//  NaturalStatDateCustomHeadView.swift
//  lns
//
//  Created by LNS2 on 2024/9/10.
//

import Foundation

class NaturalStatDateCustomHeadView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(48)))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        
        return vi
    }()
    lazy var weekDaysArray: NSArray = {
        return ["日","一","二","三","四","五","六"]
    }()
}

extension NaturalStatDateCustomHeadView{
    func initUI() {
        initWeekDays()
        addSubview(lineView)
        
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
    func initWeekDays() {
        for i in 0..<weekDaysArray.count{
            let label = UILabel.init(frame: CGRect.init(x: kFitWidth(19.5)+kFitWidth(48)*CGFloat(i), y: 0, width: kFitWidth(48), height: kFitWidth(48)))
            label.text = weekDaysArray[i]as? String ?? ""
            label.textColor = .COLOR_GRAY_BLACK_65
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14, weight: .medium)
            addSubview(label)
        }
    }
}
