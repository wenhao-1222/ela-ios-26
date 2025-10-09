//
//  NaturalStatDateCustomTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/9/10.
//

import Foundation

class NaturalStatDateCustomTableViewCell: UITableViewCell {
    
    let buttonWidth = kFitWidth(48)
    var buttonArray:[NaturalStatDateCustomDateButton] = [NaturalStatDateCustomDateButton]()
    
    var yearInt = 0
    var monthInt = 0

    var btnTapBlock:((DateChoiceModel)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    lazy var bottomView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        return vi
    }()
}

extension NaturalStatDateCustomTableViewCell{
    @objc func buttonTapAction(btnSender:UIButton) {
        let dayIndex = btnSender.tag - yearInt * monthInt
        if self.btnTapBlock != nil{
            let model = DateChoiceModel()
            model.yearInt = yearInt
            model.monthInt = monthInt
            model.dayInt = dayIndex
            self.btnTapBlock!(model)
        }
    }
}
extension NaturalStatDateCustomTableViewCell{
    func updateUI(dict:NSDictionary) {
        for vi in bottomView.subviews{
            vi.removeFromSuperview()
        }
        buttonArray.removeAll()
        let days = dict["days"]as? NSArray ?? []
        yearInt = Int(dict.doubleValueForKey(key: "yearIndex"))
        monthInt = Int(dict.doubleValueForKey(key: "monthIndex"))
        
//        year = dict.stringValueForKey(key: "yearIndex")
//        month = dict.stringValueForKey(key: "monthIndex").count > 1 ? dict.stringValueForKey(key: "monthIndex") : "0\(dict.stringValueForKey(key: "monthIndex"))"
//         
        for i in 0..<days.count{
            let dayDict = days[i]as? NSDictionary ?? [:]
            
            let weekDay = Int(dayDict.doubleValueForKey(key: "weekDay"))
            let weekIndex = Int(dayDict.doubleValueForKey(key: "weekIndex"))
            
            let btn = NaturalStatDateCustomDateButton.init(frame: CGRect.init(x: getButtonOriginX(weekDay: weekDay), y: (buttonWidth+kFitWidth(8))*CGFloat(weekIndex-1), width: buttonWidth, height: buttonWidth))
            
//            btn.backgroundColor = .clear
            btn.setTitle("\(dayDict.stringValueForKey(key: "day"))", for: .normal)
            btn.setWeekDay(weekDay: weekDay)
//            btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
//            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
//            btn.clipsToBounds = true
            
            bottomView.addSubview(btn)
            
            btn.setDate(yearInt: yearInt, monthInt: monthInt, dayInt: Int(dayDict.doubleValueForKey(key: "day")))
            btn.tag = yearInt * monthInt + i + 1
            btn.addTarget(self, action: #selector(buttonTapAction(btnSender: )), for: .touchUpInside)
            
            buttonArray.append(btn)
        }
    }
    func udpateChoiceStatus(startTime:String,endTime:String){
        for btn in buttonArray{
            btn.setSelect(isSelct: false)
            
            if startTime.count > 0 {
                if btn.dateString == startTime{
                    btn.setSelect(isSelct: true,isStartTime: true)
                }else if btn.dateString == endTime{
                    btn.setSelect(isSelct: true,isStartTime: false)
                }else if endTime.count > 0 && Date().judgeMin(firstTime: startTime, secondTime: btn.dateString,formatter: "yyyy-MM-dd") && Date().judgeMin(firstTime: btn.dateString, secondTime: endTime,formatter: "yyyy-MM-dd"){
                    btn.setBetweenStatus()
                }
            }
        }
        
    }
    func udpateChoiceStatus(startModel:DateChoiceModel,endModel:DateChoiceModel) {
        for btn in buttonArray{
//            setButtonSelectStatus(button: btn, isSelect: false)
            btn.setSelect(isSelct: false)
        }
        if startModel.yearInt == 0 && endModel.yearInt == 0{
            return
        }
        
        if startModel.yearInt > 0 && endModel.yearInt == 0{
            //选择了开始日期，但是没有结束日期
            if yearInt == startModel.yearInt && monthInt == startModel.monthInt{
                let btn = buttonArray[startModel.dayInt-1]
//                setButtonSelectStatus(button: btn, isSelect: true)
                btn.setSelect(isSelct: true)
            }
        }
    }
    
    func getButtonOriginX(weekDay:Int) -> CGFloat{
        if weekDay == 7 {
            return kFitWidth(0)
        }else{
            return buttonWidth*CGFloat(weekDay)
        }
    }
//    func setButtonSelectStatus(button:UIButton,isSelect:Bool) {
//        
//        if isSelect{
//            
//            button.backgroundColor = .THEME
//            button.setTitleColor(.white, for: .normal)
//            button.layer.cornerRadius = kFitWidth(8)
//        }else{
//            button.backgroundColor = .clear
//            button.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
//            button.layer.cornerRadius = kFitWidth(0)
//        }
//    }
    
}
extension NaturalStatDateCustomTableViewCell{
    func initUI() {
        contentView.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(19.5))
            make.right.equalTo(kFitWidth(-19.5))
            make.top.equalTo(kFitWidth(0))
            make.bottom.equalTo(kFitWidth(0))
        }
    }
}
