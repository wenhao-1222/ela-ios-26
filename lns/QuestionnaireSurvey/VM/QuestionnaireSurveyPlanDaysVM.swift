//
//  QuestionnaireSurveyPlanDaysVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation
import UIKit

class QuestionnaireSurveyPlanDaysVM: UIView {
    
    var selfHeight = kFitWidth(48)
    var selectedIndex = -1
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = WHColor_RGB(r: 38.0, g: 40.0, b: 49.0)
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.size.height
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleVm : QuestionnaireSurveyTopVM = {
        let vm = QuestionnaireSurveyTopVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "您的预计时长是"
        
        return vm
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "所选计划建议不超过4周"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var textField : UITextField = {
        let text = UITextField()
        text.placeholder = "周数"
        text.font = .systemFont(ofSize: 16, weight: .medium)
//        text.backgroundColor = .COLOR_LINE_GREY
        text.layer.cornerRadius = kFitWidth(8)
        text.clipsToBounds = true
        text.textAlignment = .center
//        text.textContentType = .username
        
        return text
    }()
    lazy var unitLab : UILabel = {
        let lab = UILabel()
        lab.text = "周 计划时长"
        lab.textColor = .white
        
        return lab
    }()
}

extension QuestionnaireSurveyPlanDaysVM{
    func initUI() {
        addSubview(titleVm)
        addSubview(tipsLabel)
        addSubview(textField)
        addSubview(unitLab)
        
        setConstrait()
    }
    func setConstrait(){
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(12)+QuestionnaireSurveyTopVM().selfHeight)
        }
        textField.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(40))
            make.width.equalTo(kFitWidth(80))
            make.height.equalTo(kFitWidth(26))
        }
        unitLab.snp.makeConstraints { make in
            make.left.equalTo(textField.snp.right).offset(kFitWidth(5))
            make.centerY.lessThanOrEqualTo(textField)
        }
    }
}
