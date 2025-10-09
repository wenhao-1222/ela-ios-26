//
//  QuestionnaireSurveyVC.swift
//  lns
//
//  Created by LNS2 on 2024/3/25.
//

import Foundation


class QuestionnaireSurveyVC : WHBaseViewVC {
    
    var step = 0
    var contentHeight = kFitWidth(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentHeight = SCREEN_HEIGHT-QuestionnaireSurveyBottomVM().selfHeight-getNavigationBarHeight()
        
        initUI()
    }
    lazy var scrollView : UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: contentHeight))
        scro.backgroundColor = .clear
        return scro
    }()
    lazy var msgVm: QuestionnaireSurveyMsgVM = {
        let vm = QuestionnaireSurveyMsgVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: contentHeight))
        vm.birthdayVm.tapBlock = {()in
            self.datePickerVm.isHidden = false
        }
        return vm
    }()
    lazy var loseFatVm : QuestionnaireSurveyLoseFatVM = {
        let vm = QuestionnaireSurveyLoseFatVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: contentHeight))
        
        return vm
    }()
    lazy var eventsVm : QuestionnaireSurveyEventVM = {
        let vm = QuestionnaireSurveyEventVM.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: 0, height: contentHeight))
        
        return vm
    }()
    lazy var bodyFatVm : QuestionnaireSurveyBodyFatVM = {
        let vm = QuestionnaireSurveyBodyFatVM.init(frame: CGRect.init(x: SCREEN_WIDHT*3, y: 0, width: 0, height: contentHeight))
        
        return vm
    }()
    lazy var mealsDayVm : QuestionnaireSurveyMealsVM = {
        let vm = QuestionnaireSurveyMealsVM.init(frame: CGRect.init(x: SCREEN_WIDHT*4, y: 0, width: 0, height: contentHeight))
        return vm
    }()
    lazy var planDayVm : QuestionnaireSurveyPlanDaysVM = {
        let vm = QuestionnaireSurveyPlanDaysVM.init(frame: CGRect.init(x: SCREEN_WIDHT*5, y: 0, width: 0, height: contentHeight))
        
        return vm
    }()
    lazy var foodsVm : QuestionnaireSurveyFoodsVM = {
        let vm = QuestionnaireSurveyFoodsVM.init(frame: CGRect.init(x: SCREEN_WIDHT*6, y: 0, width: 0, height: contentHeight))
        vm.controller = self
        return vm
    }()
    lazy var bottomVm: QuestionnaireSurveyBottomVM = {
        let vm = QuestionnaireSurveyBottomVM.init(frame: .zero)
        
        vm.nextBlock = {()in
            self.step = self.step + 1
            self.bottomVm.showPreBtn(step: self.step)
            
            if self.step < 4{
                self.msgVm.setMsgPage(pageIndex: self.step)
            }else{
                let offsetX = SCREEN_WIDHT*CGFloat(self.step-3)
                self.scrollView.setContentOffset(CGPoint.init(x: offsetX, y: 0), animated: true)
            }
        }
        vm.preBlock = {()in
            self.step = self.step - 1
            self.bottomVm.showPreBtn(step: self.step)
            
            if self.step < 4{
                self.scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
                self.msgVm.setMsgPage(pageIndex: self.step)
            }else{
                let offsetX = SCREEN_WIDHT*CGFloat(self.step-3)
                self.scrollView.setContentOffset(CGPoint.init(x: offsetX, y: 0), animated: true)
            }
        }
        
        return vm
    }()
    lazy var datePickerVm : DatePickerVM = {
        let vm = DatePickerVM.init(frame: .zero)
        vm.isHidden = true
        vm.titleLabel.text = "请选择出生年月"
        vm.timeConfirmBlock = {(timeStr)in
            self.msgVm.birthdayVm.timeLabel.text = timeStr
        }
        return vm
    }()
    
}

extension QuestionnaireSurveyVC{
    func initUI(){
        initNavi(titleStr: "问卷调查")
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(msgVm)
        scrollView.addSubview(loseFatVm)
        scrollView.addSubview(eventsVm)
        scrollView.addSubview(bodyFatVm)
        scrollView.addSubview(mealsDayVm)
        scrollView.addSubview(planDayVm)
        scrollView.addSubview(foodsVm)
        
        view.addSubview(bottomVm)
        view.addSubview(datePickerVm)
    }
}
