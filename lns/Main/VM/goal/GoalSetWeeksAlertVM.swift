//
//  GoalSetWeeksAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/5.
//

import Foundation
import UIKit

class GoalSetWeeksAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    var whiteViewHeight = kFitWidth(478)+WHUtils().getBottomSafeAreaHeight()
    var whiteViewOriginY = kFitWidth(0)
    
    var msgDict = NSDictionary()
    
    var hiddenBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        initUI()
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(12))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var topVm: GoalSetWeeksAlertTopVM = {
        let vm = GoalSetWeeksAlertTopVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vm.cancelBlock = {()in
            self.hiddenView()
        }
//        vm.confirmBlock = {()in
//            self.submitAction()
//        }
        vm.typeVm.typeChangeBlock = {(type)in
            self.caloriesVm.changeType(type: type)
            self.showSelf()
            if type == "g"{
                self.specGVm.isHidden = false
                self.specPercentVm.isHidden = true
                self.specPercentVm.caloriesNumber = Int(self.caloriesVm.numberLabel.text ?? "0") ?? 0
                self.caloriesVm.numberLabel.text = "\(self.specGVm.caloriesNumber)"
            }else{
                self.specGVm.isHidden = true
                self.specPercentVm.isHidden = false
                self.specGVm.resignTextField()
                self.caloriesVm.numberLabel.text = "\(self.specPercentVm.caloriesNumber)"
            }
        }
        return vm
    }()
    lazy var caloriesVm: GoalSetCaloriesVM = {
        let vm = GoalSetCaloriesVM.init(frame: CGRect.init(x: 0, y: kFitWidth(60), width: 0, height: 0))
        vm.frame = CGRect.init(x: 0, y: self.topVm.frame.maxY, width: SCREEN_WIDHT, height: kFitWidth(64))
        vm.numberChangeBlock = {(calories)in
            self.specPercentVm.updateNumberWithCalories(calories: Int(calories) ?? 0)
        }
        vm.updateConstraitForAlert()
        return vm
    }()
    lazy var specGVm: GoalSetSpecGVM = {
        let vm = GoalSetSpecGVM.init(frame: CGRect.init(x: 0, y: self.caloriesVm.frame.maxY, width: 0, height: 0))
        vm.frame = CGRect.init(x: 0, y: self.caloriesVm.frame.maxY, width: SCREEN_WIDHT, height: kFitWidth(214))
        vm.caloriChangeBlock = {(calori)in
            self.caloriesVm.numberLabel.text = calori
        }
        vm.caloriInitBlock = {(calori)in
            self.caloriesVm.numberLabel.text = calori
            self.specPercentVm.caloriesNumber = Int(calori) ?? 0
            self.specPercentVm.updateNum(specGVm: self.specGVm)
        }
        vm.updateConstraitForAlert()
        return vm
    }()
    lazy var specPercentVm: GoalSetSpecPercentVM = {
        let vm = GoalSetSpecPercentVM.init(frame: CGRect.init(x: 0, y: self.caloriesVm.frame.maxY, width: 0, height: 0))
        vm.isHidden = true
        vm.numberChangeBlock = {()in
//            self.specGVm.updateNum(perVm: self.specPercentVm)
        }
        
        return vm
    }()
}

extension GoalSetWeeksAlertVM{
    @objc func showSelf() {
        self.isHidden = false
        
        if self.topVm.typeVm.type == "g"{
            whiteViewHeight = kFitWidth(288)+WHUtils().getBottomSafeAreaHeight()
        }else{
            whiteViewHeight = kFitWidth(478)+WHUtils().getBottomSafeAreaHeight()
        }
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }completion: { t in
//             self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }
    }
    @objc func hiddenView() {
        specGVm.carVm.textField.resignFirstResponder()
        specGVm.proteinVm.textField.resignFirstResponder()
        specGVm.fatVm.textField.resignFirstResponder()
        caloriesVm.numberLabel.resignFirstResponder()
        
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        }completion: { t in
            self.isHidden = true
        }
        specGVm.initData(dict: msgDict)
   }
    func updateData(dict:NSDictionary) {
        msgDict = dict
        specGVm.initData(dict: dict)
    }
    @objc func nothingAction() {
        specGVm.carVm.textField.resignFirstResponder()
        specGVm.proteinVm.textField.resignFirstResponder()
        specGVm.fatVm.textField.resignFirstResponder()
        caloriesVm.numberLabel.resignFirstResponder()
    }
}

extension GoalSetWeeksAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(topVm)
        whiteView.addSubview(caloriesVm)
        whiteView.addSubview(specGVm)
        whiteView.addSubview(specPercentVm)
        specPercentVm.updateConstraitForAlert()
    }
}

extension GoalSetWeeksAlertVM{
    @objc func keyboardWillShow(notification: NSNotification) {
//        if self.topVm.typeVm.type == "g" {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                    self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-self.whiteViewHeight*0.5+kFitWidth(40))
                }
            }
//        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.topVm.typeVm.type == "g" {
            UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-self.whiteViewHeight*0.5)
            }completion: { t in
    //            self.hiddenView()
            }
//        }
    }
}
