//
//  FoodsListAddVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

private final class FoodsListAddActionScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}

enum FOODS_TYPE {
    case all //全部食物
    case my //我的食物
    case meal //我的餐食
}

class FoodsListAddVM: UIView {
    
    let selfHeight = kFitWidth(119)
    var foodsType = "all"
    var isFromMerge = false
    var shouldShowMealAdviceEntry = false
    weak var controller: WHBaseViewVC?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_BLACK_04//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(2), width: SCREEN_WIDHT, height: selfHeight-kFitWidth(2)))
        vi.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        return vi
    }()
    lazy var scrollView: UIScrollView = {
        let vi = FoodsListAddActionScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        vi.backgroundColor = .clear
        vi.showsHorizontalScrollIndicator = false
        vi.alwaysBounceHorizontal = false
        vi.canCancelContentTouches = true
        vi.contentInsetAdjustmentBehavior = .never
        return vi
    }()
    lazy var createFoodsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
//        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.setTitle("创建食物", for: .normal)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.setImage(UIImage(named: "foods_create_icon_normal")?.withTintColor(.THEME), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layer.borderColor = UIColor.COLOR_BG_BLACK_06.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        
        return btn
    }()
    lazy var adviceFoodsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(367), y: kFitWidth(17), width: kFitWidth(99), height: kFitWidth(86))
        btn.setTitle("下餐规划", for: .normal)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.setImage(UIImage(named: "foods_advice_icon")?.withTintColor(.THEME), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layer.borderColor = UIColor.COLOR_BG_BLACK_06.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        
        return btn
    }()
    lazy var createFoodsSoonButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(133), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
//        btn.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.setTitle("快速添加", for: .normal)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.setImage(UIImage(named: "foods_create_icon_soon")?.withTintColor(.THEME), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layer.borderColor = UIColor.COLOR_BG_BLACK_06.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        
        return btn
    }()
    lazy var aiFoodsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(250), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
//        btn.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.setTitle("AI识别", for: .normal)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.setImage(UIImage(named: "foods_ai_icon")?.withTintColor(.THEME), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layer.borderColor = UIColor.COLOR_BG_BLACK_06.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        
        return btn
    }()
    lazy var aiFoodsNewVm: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_new_func_icon")
        
        return img
    }()
//    lazy var aiFoodsNewVm: FoodsNewFuncVM = {
//        let vm = FoodsNewFuncVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//        
//        return vm
//    }()
    lazy var mergeFoodsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(250), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
//        btn.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.setTitle("融合食物", for: .normal)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.isHidden = true
        btn.enablePressEffect()
        btn.setImage(UIImage(named: "foods_merge_icon")?.withTintColor(.THEME), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.layer.borderColor = UIColor.COLOR_BG_BLACK_06.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        
        return btn
    }()
    
    lazy var mergeFoodsNewVm: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_new_func_icon")
        
        return img
    }()
    lazy var createMealsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
//        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(86))
        btn.setTitle("创建餐食", for: .normal)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.enablePressEffect()
        btn.setImage(UIImage(named: "meals_create_icon")?.withTintColor(WHColor_16(colorStr: "2BA471")), for: .normal)
//        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(WHColor_16(colorStr: "2BA471"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.layer.borderColor = UIColor.COLOR_BG_BLACK_06.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        btn.isHidden = true
        
        return btn
    }()
}

extension FoodsListAddVM{
    func initUI() {
        addSubview(bgView)
        addSubview(scrollView)
        scrollView.addSubview(createFoodsButton)
        scrollView.addSubview(createFoodsSoonButton)
        scrollView.addSubview(aiFoodsButton)
        scrollView.addSubview(adviceFoodsButton)
        scrollView.addSubview(mergeFoodsButton)
        scrollView.addSubview(createMealsButton)
        
//        aiFoodsButton.addSubview(aiFoodsNewVm)
        mergeFoodsButton.addSubview(mergeFoodsNewVm)
        
//        aiFoodsNewVm.snp.makeConstraints { make in
////            make.top.right.equalToSuperview()
//            make.top.equalTo(kFitWidth(5))
//            make.right.equalTo(kFitWidth(-5))
//            make.width.height.equalTo(kFitWidth(12))
////            make.height.equalTo(kFitWidth(15))
//        }
        mergeFoodsNewVm.snp.makeConstraints { make in
//            make.top.right.equalToSuperview()
//            make.width.equalTo(kFitWidth(40))
//            make.height.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(5))
            make.right.equalTo(kFitWidth(-5))
            make.width.height.equalTo(kFitWidth(12))
        }
        refreshButton(type: .all, isFromMain: false)
        adviceFoodsButton.addTarget(self, action: #selector(adviceFoodsAction), for: .touchUpInside)
    }
    
    @objc func adviceFoodsAction() {
        window?.endEditing(true)
        let mealAdviceContext = currentMealAdviceContext()
        ElaMealAdviceProVC.pushMealAdviceFlow(
            from: controller,
            sDate: mealAdviceContext.sDate,
            mealIndex: mealAdviceContext.mealIndex
        )
    }

    private func currentMealAdviceContext() -> (sDate: String, mealIndex: Int) {
        if let foodsVC = controller as? FoodsListNewVC {
            return (foodsVC.mealAdviceSDate, foodsVC.mealAdviceMealIndex)
        } else if let foodsVC = controller as? FoodsListVC {
            return (foodsVC.mealAdviceSDate, foodsVC.mealAdviceMealIndex)
        }
        return (Date().todayDate, 0)
    }
    
    func refreshButtonFrame() {
        createFoodsSoonButton.isHidden = true
        adviceFoodsButton.isHidden = true
//        createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(343), height: kFitWidth(86))
        createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        aiFoodsButton.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
//        mergeFoodsButton.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
    }
    
    func refreshButtonFrameForAll(hasCreatSoon:Bool)  {
        if hasCreatSoon{
            createFoodsSoonButton.isHidden = false
            adviceFoodsButton.isHidden = true
            createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
            createFoodsSoonButton.frame = CGRect.init(x: kFitWidth(133), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
            aiFoodsButton.frame = CGRect.init(x: kFitWidth(250), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
            scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
        }else{
            createFoodsSoonButton.isHidden = true
            adviceFoodsButton.isHidden = true
            createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
            aiFoodsButton.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
            scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
        }
    }
    
    func refreshButtonStatus(isMeals:Bool,isMyFoods:Bool=false){
        if isMeals == true{
            bgView.backgroundColor = WHColor_16(colorStr: "E3F9E9")
            self.backgroundColor = WHColor_16(colorStr: "E3F9E9")
            self.createMealsButton.isHidden = false
            self.createFoodsButton.isHidden = true
            self.createFoodsSoonButton.isHidden = true
            self.adviceFoodsButton.isHidden = true
        }else{
            bgView.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
            self.createMealsButton.isHidden = true
            self.createFoodsButton.isHidden = false
            self.createFoodsSoonButton.isHidden = false
            self.adviceFoodsButton.isHidden = true
        }
    }
    
    func refreshButton(type:FOODS_TYPE,isFromMain:Bool) {
        createFoodsButton.isHidden = true
        aiFoodsButton.isHidden = true
        createFoodsSoonButton.isHidden = true
        adviceFoodsButton.isHidden = true
        mergeFoodsButton.isHidden = true
        createMealsButton.isHidden = true
        scrollView.contentOffset = .zero
        scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
        
        if isFromMain{//首页进来的
            let btnWidth = kFitWidth(99)//(SCREEN_WIDHT-kFitWidth(48))/3
            switch type{
            case .all: //快速添加、 AI识别 、下餐规划、 创建食物
                let actionBtnWidth = shouldShowMealAdviceEntry ? kFitWidth(99) : kFitWidth(109)
                createFoodsButton.isHidden = false
                createFoodsSoonButton.isHidden = false
                aiFoodsButton.isHidden = false
                adviceFoodsButton.isHidden = !shouldShowMealAdviceEntry
                createFoodsSoonButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: actionBtnWidth, height: kFitWidth(86))
                aiFoodsButton.frame = CGRect.init(x: createFoodsSoonButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: actionBtnWidth, height: kFitWidth(86))
                adviceFoodsButton.frame = CGRect.init(x: aiFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: actionBtnWidth, height: kFitWidth(86))
                let createFoodsX = shouldShowMealAdviceEntry ? adviceFoodsButton.frame.maxX+kFitWidth(8) : aiFoodsButton.frame.maxX+kFitWidth(8)
                createFoodsButton.frame = CGRect.init(x: createFoodsX, y: kFitWidth(17), width: actionBtnWidth, height: kFitWidth(86))
                scrollView.contentSize = CGSize(width: createFoodsButton.frame.maxX+kFitWidth(16), height: scrollView.frame.height)
            case .my://创建食物 、 食物融合
                createFoodsButton.isHidden = false
                mergeFoodsButton.isHidden = false
                createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
                mergeFoodsButton.frame = CGRect.init(x: createFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
                scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
            case .meal:
                createMealsButton.isHidden = false
                scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
            }
        }else{
            switch type{
            case .all: //快速添加、 AI识别 、下餐规划、 创建食物
                if self.isFromMerge {
                    let btnWidth = (SCREEN_WIDHT-kFitWidth(40))/2
                    createFoodsButton.isHidden = false
                    createFoodsSoonButton.isHidden = false
                    createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                    createFoodsSoonButton.frame = CGRect.init(x: createFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                    scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
                }else{
                    let actionBtnWidth = shouldShowMealAdviceEntry ? kFitWidth(99) : kFitWidth(109)//(SCREEN_WIDHT-kFitWidth(48))/3
                    createFoodsButton.isHidden = false
                    createFoodsSoonButton.isHidden = false
                    aiFoodsButton.isHidden = false
                    adviceFoodsButton.isHidden = !shouldShowMealAdviceEntry
                    createFoodsSoonButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: actionBtnWidth, height: kFitWidth(86))
                    aiFoodsButton.frame = CGRect.init(x: createFoodsSoonButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: actionBtnWidth, height: kFitWidth(86))
                    adviceFoodsButton.frame = CGRect.init(x: aiFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: actionBtnWidth, height: kFitWidth(86))
                    let createFoodsX = shouldShowMealAdviceEntry ? adviceFoodsButton.frame.maxX+kFitWidth(8) : aiFoodsButton.frame.maxX+kFitWidth(8)
                    createFoodsButton.frame = CGRect.init(x: createFoodsX, y: kFitWidth(17), width: actionBtnWidth, height: kFitWidth(86))
                    scrollView.contentSize = CGSize(width: createFoodsButton.frame.maxX+kFitWidth(16), height: scrollView.frame.height)
                }
            case .my://创建食物 、 食物融合
                createFoodsButton.isHidden = false
                mergeFoodsButton.isHidden = false
                let btnWidth = (SCREEN_WIDHT-kFitWidth(40))/2
                createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                mergeFoodsButton.frame = CGRect.init(x: createFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
            case .meal:
                createMealsButton.isHidden = false
                scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
            }
        }
    }
    func refreshButtonFrameForMerge() {
        createFoodsButton.isHidden = false
        aiFoodsButton.isHidden = true
        createFoodsSoonButton.isHidden = true
        adviceFoodsButton.isHidden = true
        mergeFoodsButton.isHidden = true
        createMealsButton.isHidden = true
        createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(86))
        scrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: scrollView.frame.height)
    }
    
    func showCreateFoodsButtonWithRightInset() {
        layoutIfNeeded()
        scrollView.layoutIfNeeded()
        
        let maxOffsetX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
        let targetOffsetX = max(0, createFoodsButton.frame.maxX + kFitWidth(16) - scrollView.bounds.width)
        let offsetX = min(targetOffsetX, maxOffsetX)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
    
    func createFoodsButtonFrame(in view: UIView) -> CGRect {
        layoutIfNeeded()
        scrollView.layoutIfNeeded()
        return createFoodsButton.convert(createFoodsButton.bounds, to: view)
    }
}
