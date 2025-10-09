//
//  QuestionnairePlanWeeksVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/29.
//

import Foundation
import UIKit

class QuestionnairePlanWeeksVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var selectedIndex = -1
    
    var selectedBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "您的预期计划时长是？"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "根据用户所选目标显示时长建议"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var pickerView : CustomPickerView = {
        let vi = CustomPickerView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(278), width: SCREEN_WIDHT - kFitWidth(32), height: kFitWidth(80)))
        vi.delegate = self
//        vi.dataModel = ["1周",]
        return vi
    }()
}

extension QuestionnairePlanWeeksVM{
    func dealTipsString() {
        if QuestinonaireMsgModel.shared.goal == "1"{
            tipsLabel.text = "根据您选择的目标，推荐的计划周期为：不超过4周"
            pickerView.scrollToIndex = 3
            QuestinonaireMsgModel.shared.planWeeks = "4"
        }else if QuestinonaireMsgModel.shared.goal == "2"{
            tipsLabel.text = "根据您选择的目标，推荐的计划周期为：8-16周"
            pickerView.scrollToIndex = 11
            QuestinonaireMsgModel.shared.planWeeks = "12"
        }else if QuestinonaireMsgModel.shared.goal == "3"{
            tipsLabel.text = "根据您选择的目标，推荐的计划周期为：15-20周"
            pickerView.scrollToIndex = 17
            QuestinonaireMsgModel.shared.planWeeks = "18"
        }else if QuestinonaireMsgModel.shared.goal == "4"{
            tipsLabel.text = "根据您选择的目标，推荐的计划周期为：8-12周"
            pickerView.scrollToIndex = 9
            QuestinonaireMsgModel.shared.planWeeks = "10"
        }else if QuestinonaireMsgModel.shared.goal == "5"{
            tipsLabel.text = "根据您选择的目标，推荐的计划周期为：8-12周"
            pickerView.scrollToIndex = 9
            QuestinonaireMsgModel.shared.planWeeks = "10"
        }else if QuestinonaireMsgModel.shared.goal == "6"{
            tipsLabel.text = "根据您选择的目标，推荐的计划周期为：≥1周"
            pickerView.scrollToIndex = 3
            QuestinonaireMsgModel.shared.planWeeks = "4"
        }else if QuestinonaireMsgModel.shared.goal == "7"{
            tipsLabel.text = "根据您选择的目标，推荐的计划周期为：6-8周"
            pickerView.scrollToIndex = 6
            QuestinonaireMsgModel.shared.planWeeks = "7"
        }else if QuestinonaireMsgModel.shared.goal == "8"{
            tipsLabel.text = "根据您选择的目标，推荐的计划周期为：8-16周"
            pickerView.scrollToIndex = 11
            QuestinonaireMsgModel.shared.planWeeks = "12"
        }
    }
}
extension QuestionnairePlanWeeksVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsLabel)
        addSubview(pickerView)
        
        dealTipsString()
        
        setConstrait()
        
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(112))
        }
        
    }
}

extension QuestionnairePlanWeeksVM:MyPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView!, didSelectRow row: Int) {
        DLLog(message: "\(row)")
        QuestinonaireMsgModel.shared.planWeeks = "\(row + 1)"
        DLLog(message: "计划时长：\(QuestinonaireMsgModel.shared.planWeeks)  周")
    }
    func pickerViewBeginScroll() {
        
    }
}

