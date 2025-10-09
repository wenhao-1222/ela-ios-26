//
//  JournalReportWeekCalendarDayVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/16.
//

class JournalReportWeekCalendarDayVM: UIView {
    
    let selfHeight = kFitWidth(178)
    let selfWidth = kFitWidth(230)
    
    let labelWidth = kFitWidth(25)
    let dayArray = ["日","一","二","三","四","五","六"]
    let originX = [kFitWidth(9),kFitWidth(39),kFitWidth(69),kFitWidth(99),kFitWidth(129),kFitWidth(159),kFitWidth(189)]
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isSkeletonable = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension JournalReportWeekCalendarDayVM{
    func updateUI(dataArray:[String],startDate:String,endDate:String,perfectDate:String,logsDates:NSArray) {
        for vi in self.subviews{
            vi.removeFromSuperview()
        }
        initTopTitleLabel()
        let currentMonth = Date().currenYearMonthM.lastObject
        
        for i in 0..<dataArray.count{
            let index = i % 7
            let originY = CGFloat(i / 7) * (labelWidth + kFitWidth(5)) + kFitWidth(33)
            let lab = UILabel.init(frame: CGRect.init(x: originX[index], y: originY, width: labelWidth, height: labelWidth))
            lab.layer.cornerRadius = kFitWidth(4)
            lab.clipsToBounds = true
            lab.textAlignment = .center
            lab.font = .systemFont(ofSize: 11, weight: .regular)
            
            addSubview(lab)
            
//            lab.text = dataArray
            let dateString = dataArray[i]
            let dateStrArr = dateString.components(separatedBy: "-")
            
            var day = dateStrArr.last
            if day?.intValue ?? 10 < 10 {
                day = day?.mc_cutToSuffix(from: (day?.count ?? 1)-1)
            }
            lab.text = day
            
            let month = dateStrArr[1]
            if month.intValue == (currentMonth as? String ?? "0").intValue{
                lab.textColor = .COLOR_TEXT_TITLE_0f1214
            }else{
                lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
            }
            
            if i >= 13 && i <= 19{
                lab.backgroundColor = .COLOR_TEXT_TITLE_0f1214_06//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
                if perfectDate == dateString{
                    lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 1.0)
                    lab.textColor = .white
                }else{
                    for d in 0..<logsDates.count{
                        let dict = logsDates[d]as? NSDictionary ?? [:]
                        if dict.stringValueForKey(key: "sdate") == dateString{
                            lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
                            break
                        }
                    }
                }
            }
        }
    }
}

extension JournalReportWeekCalendarDayVM{
    func initUI() {
//        initTopTitleLabel()
    }
    func initTopTitleLabel() {
        for i in 0..<originX.count{
            let lab = UILabel.init(frame: CGRect.init(x: originX[i], y: 0, width: labelWidth, height: labelWidth))
            lab.text = dayArray[i]
            lab.textAlignment = .center
            lab.font = .systemFont(ofSize: 11, weight: .regular)
            if i == 0 || i == originX.count - 1{
                lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
            }else{
                lab.textColor = .COLOR_TEXT_TITLE_0f1214
            }
            addSubview(lab)
        }
    }
}
