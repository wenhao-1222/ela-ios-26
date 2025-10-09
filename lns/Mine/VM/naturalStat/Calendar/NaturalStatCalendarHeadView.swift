//
//  NaturalStatCalendarHeadView.swift
//  lns
//
//  Created by LNS2 on 2024/9/13.
//

import Foundation

class NaturalStatCalendarHeadView: UIView {
    
    let itemWidth = (SCREEN_WIDHT-kFitWidth(11))/7
    
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

extension NaturalStatCalendarHeadView{
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
            let label = UILabel.init(frame: CGRect.init(x: kFitWidth(11)+itemWidth*CGFloat(i), y: 0, width: itemWidth, height: kFitWidth(48)))
            label.text = weekDaysArray[i]as? String ?? ""
            label.textColor = .COLOR_GRAY_BLACK_65
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14, weight: .medium)
            addSubview(label)
        }
    }
    func resetSubViewForGoalHead() {
        for vi in self.subviews{
            vi.removeFromSuperview()
        }
        addSubview(lineView)
        
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        
        let arr = ["一","二","三","四","五","六","日"]
        for i in 0..<arr.count{
            let label = UILabel.init(frame: CGRect.init(x: kFitWidth(11)+itemWidth*CGFloat(i), y: 0, width: itemWidth, height: kFitWidth(48)))
            label.text = arr[i]
            label.textColor = .COLOR_GRAY_BLACK_65
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14, weight: .medium)
            addSubview(label)
        }
    }
}
