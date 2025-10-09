//
//  QuestionnaireSurveyMsgItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/25.
//

import Foundation
import UIKit

class QuestionnaireSurveyMsgItemVM: UIView {

    let selfHeight = kFitWidth(48)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: kFitWidth(343), height: selfHeight))
        self.backgroundColor = WHColor_RGB(r: 38.0, g: 40.0, b: 49.0)
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
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
//        vi.backgroundColor = .COLOR_LINE_GREY
        vi.backgroundColor = .clear
        
        return vi
    }()
}

extension QuestionnaireSurveyMsgItemVM{
    func initUI(){
        addSubview(titleLabel)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait(){
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalToSuperview()
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(0.5))
        }
    }
}
