//
//  PlanCreateFoodsDaysAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/15.
//

import Foundation
import UIKit

class PlanCreateFoodsDaysAlertVM: UIView {
    
    var choiceBlock:((Int)->())?
    var vmDataArray = [QuestionnairePlanFoodsTypeItemVM]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
}

extension PlanCreateFoodsDaysAlertVM{
    @objc func hiddenSelf(){
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    func setSelectStatus(daysIndex:Int) {
        for vm in vmDataArray{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        
        let vm = vmDataArray[daysIndex]
        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
        
        if self.choiceBlock != nil{
            self.choiceBlock!(daysIndex)
        }
    }
    
}

extension PlanCreateFoodsDaysAlertVM{
    func initUI()  {
        addSubview(whiteView)
        whiteView.addShadow()
    }
    func showDaysAlertView(daysNumber:Int,originY:CGFloat,selectedDaysIndex:Int)  {
        for vi in whiteView.subviews{
            vi.removeFromSuperview()
        }
        vmDataArray.removeAll()
        
//        whiteView.frame = CGRect.init(x: kFitWidth(159), y: originY, width: kFitWidth(200), height: kFitWidth(48)*CGFloat(daysNumber))
        whiteView.frame = CGRect.init(x: kFitWidth(16), y: originY, width: kFitWidth(200), height: kFitWidth(48)*CGFloat(daysNumber))
        let scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(200), height: kFitWidth(48)*3.4))
        
        if daysNumber > 3 {
//            whiteView.frame = CGRect.init(x: kFitWidth(159), y: originY, width: kFitWidth(200), height: kFitWidth(48)*CGFloat(3))
            whiteView.frame = CGRect.init(x: kFitWidth(16), y: originY, width: kFitWidth(200), height: kFitWidth(48)*CGFloat(3.4))
            whiteView.addSubview(scrollView)
            scrollView.contentSize = CGSize.init(width: 0, height: kFitWidth(48)*CGFloat(daysNumber))
        }
        
        for i in 0..<daysNumber{
            let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(i), width: 0, height: 0))
            vm.titleLabel.text = "第 \(i+1) 天"
            
            if i == selectedDaysIndex {
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
            }else{
                vm.selectImgView.isHidden = true
                vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
            }
            
            if daysNumber > 3 {
                scrollView.addSubview(vm)
            }else{
                whiteView.addSubview(vm)
            }
            
            vm.tag = 1040 + i
            vmDataArray.append(vm)
            
            vm.tapBlock = {()in
                self.setSelectStatus(daysIndex: i)
                self.hiddenSelf()
            }
        }
        
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
    }
}
