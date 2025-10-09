//
//  MineFoodsTypeVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/29.
//

import Foundation
import UIKit

class MineFoodsTypeVM: UIView {
    
    let selfHeight = kFitWidth(47)
    var foodsType = "my"
    
    var allFoodsTapBlock:(()->())?
    var myFoodsTapBlock:(()->())?
    var myMealsTapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var myFoodsButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.frame = CGRect.init(x: kFitWidth(4), y: 0, width: kFitWidth(88), height: selfHeight)
        btn.setTitle("我的食物", for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(myFoodsTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var myMealsButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.frame = CGRect.init(x: kFitWidth(92), y: 0, width: kFitWidth(128), height: selfHeight)
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
        vi.center = CGPoint.init(x: myFoodsButton.center.x, y: selfHeight-kFitWidth(2))
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension MineFoodsTypeVM{
    @objc func myFoodsTapAction() {
        if foodsType == "my"{
            return
        }
        foodsType = "my"
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

extension MineFoodsTypeVM{
    func initUI(){
        addSubview(myFoodsButton)
        addSubview(myMealsButton)
        addSubview(lineView)
    }
}

