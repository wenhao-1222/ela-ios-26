//
//  FoodsListTypeVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

class FoodsListTypeVM: UIView {
    
    let selfHeight = kFitWidth(47)
    var foodsType = "all"
    
    var allFoodsTapBlock:(()->())?
    var myFoodsTapBlock:(()->())?
    var myMealsTapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var allFoodsButton: GJVerButton = {
        let btn = GJVerButton()
        btn.frame = CGRect.init(x: kFitWidth(4), y: 0, width: kFitWidth(88), height: selfHeight)
        btn.setTitle("全部食物", for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.isSelected = true
        btn.addTarget(self, action: #selector(allFoodsTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var myFoodsButton: GJVerButton = {
        let btn = GJVerButton()
        btn.frame = CGRect.init(x: kFitWidth(92), y: 0, width: kFitWidth(88), height: selfHeight)
        btn.setTitle("我的食物", for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(myFoodsTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var myMealsButton: GJVerButton = {
        let btn = GJVerButton()
        btn.frame = CGRect.init(x: kFitWidth(180), y: 0, width: kFitWidth(128), height: selfHeight)
        btn.setTitle("我的食谱/餐食", for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(myMealsTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(24), height: kFitWidth(4)))
        vi.center = CGPoint.init(x: allFoodsButton.center.x, y: selfHeight-kFitWidth(2))
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension FoodsListTypeVM{
    @objc func allFoodsTapAction() {
        if foodsType == "all"{
            return
        }
        foodsType = "all"
        myFoodsButton.isSelected = false
        myMealsButton.isSelected = false
        allFoodsButton.isSelected = true
        if self.allFoodsTapBlock != nil{
            self.allFoodsTapBlock!()
        }
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.lineView.center = CGPoint.init(x: self.allFoodsButton.center.x, y: self.selfHeight-kFitWidth(2))
        }
        
    }
    @objc func myFoodsTapAction() {
        if foodsType == "my"{
            return
        }
        foodsType = "my"
        allFoodsButton.isSelected = false
        myMealsButton.isSelected = false
        myFoodsButton.isSelected = true
        if self.myFoodsTapBlock != nil{
            self.myFoodsTapBlock!()
        }
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.lineView.center = CGPoint.init(x: self.myFoodsButton.center.x, y: self.selfHeight-kFitWidth(2))
        }
        
    }
    @objc func myMealsTapAction() {
        if foodsType == "meals"{
            return
        }
        foodsType = "meals"
        allFoodsButton.isSelected = false
        myFoodsButton.isSelected = false
        myMealsButton.isSelected = true
        if self.myMealsTapBlock != nil{
            self.myMealsTapBlock!()
        }
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.lineView.center = CGPoint.init(x: self.myMealsButton.center.x, y: self.selfHeight-kFitWidth(2))
        }
        
    }
}

extension FoodsListTypeVM{
    func initUI(){
        addSubview(allFoodsButton)
        addSubview(myFoodsButton)
        addSubview(myMealsButton)
        addSubview(lineView)
    }
}
