//
//  QuestionnaireSurveyMsgVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation
import UIKit

class QuestionnaireSurveyMsgVM: UIView {
    
    var selfHeight = kFitWidth(48)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = WHColor_RGB(r: 38.0, g: 40.0, b: 49.0)
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.size.height
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var topVm : QuestionnaireSurveyMsgTopVM = {
        let vm = QuestionnaireSurveyMsgTopVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        
        return vm
    }()
    lazy var scrollView : UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY, width: SCREEN_WIDHT, height: self.selfHeight-QuestionnaireSurveyMsgTopVM().selfHeight))
        scro.backgroundColor = .clear
        return scro
    }()
    lazy var sexVm : QuestionnaireSurveyMsgSexVM = {
        let vm = QuestionnaireSurveyMsgSexVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: self.scrollView.frame.size.height))
        
        return vm
    }()
    lazy var birthdayVm : QuestionnaireSurveyMsgBirthdayVM = {
        let vm = QuestionnaireSurveyMsgBirthdayVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: self.scrollView.frame.size.height))
        
        return vm
    }()
    lazy var heightVm : QuestionnaireSurveyMsgHeightVM = {
        let vm = QuestionnaireSurveyMsgHeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: 0, height: self.scrollView.frame.size.height))
        return vm
    }()
    lazy var weightVm : QuestionnaireSurveyMsgWeightVM = {
        let vm = QuestionnaireSurveyMsgWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT*3, y: 0, width: 0, height: self.scrollView.frame.size.height))
        
        return vm
    }()
}

extension QuestionnaireSurveyMsgVM{
    func setMsgPage(pageIndex:Int) {
        let offsetX = SCREEN_WIDHT*CGFloat(pageIndex)
        scrollView.setContentOffset(CGPoint.init(x: offsetX, y: 0), animated: true)
    }
}

extension QuestionnaireSurveyMsgVM{
    func initUI(){
        addSubview(topVm)
        
        addSubview(scrollView)
        scrollView.addSubview(sexVm)
        scrollView.addSubview(birthdayVm)
        scrollView.addSubview(heightVm)
        scrollView.addSubview(weightVm)
        
    }
}
