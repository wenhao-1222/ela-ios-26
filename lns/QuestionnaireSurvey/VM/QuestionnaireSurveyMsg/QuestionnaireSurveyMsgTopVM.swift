//
//  QuestionnaireSurveyMsgTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/25.
//

import Foundation
import UIKit

class QuestionnaireSurveyMsgTopVM: UIView {
    
    let selfHeight = kFitWidth(140)
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .black
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "欢迎来到LNS"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 36, weight: .medium)
        
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "通过填写由职业运动员和健身教练共同设计的调查问卷，我们将根据您的目标，生活及饮食习惯为您量身定制一个适合您的饮食计划"
//        lab.text = "通过填写由运动员和营养师联合设计的问卷，我们将根据您的目标和日常习惯为您量身定制一个营养参考值。"
        lab.text = "填写由运动员和营养师联合设计的问卷，我们将为您量身定制一个营养目标。"
//        lab.textColor = .COLOR_TEXT_BLACK999
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension QuestionnaireSurveyMsgTopVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsLabel)
        
        setConstrait()
    }
    
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(18))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(14))
        }
    }
}
