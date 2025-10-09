//
//  FoodsListAddVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

enum FOODS_TYPE {
    case all //全部食物
    case my //我的食物
    case meal //我的餐食
}

class FoodsListAddVM: UIView {
    
    let selfHeight = kFitWidth(119)
    var foodsType = "all"
    var isFromMerge = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
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
    lazy var createFoodsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
//        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.setTitle("创建食物", for: .normal)
        btn.backgroundColor = .white
        btn.setImage(UIImage(named: "foods_create_icon_normal"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        
        return btn
    }()
    lazy var createFoodsSoonButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(133), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
//        btn.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.setTitle("快速添加", for: .normal)
        btn.backgroundColor = .white
        btn.setImage(UIImage(named: "foods_create_icon_soon"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        
        return btn
    }()
    lazy var aiFoodsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(250), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
//        btn.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.setTitle("AI识别", for: .normal)
        btn.backgroundColor = .white
        btn.setImage(UIImage(named: "foods_ai_icon"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor
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
        btn.backgroundColor = .white
        btn.isHidden = true
        btn.enablePressEffect()
        btn.setImage(UIImage(named: "foods_merge_icon"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        
        return btn
    }()
    
    lazy var mergeFoodsNewVm: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_new_func_icon")
        
        return img
    }()
//    lazy var mergeFoodsNewVm: FoodsNewFuncVM = {
//        let vm = FoodsNewFuncVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//        
//        return vm
//    }()
    lazy var createMealsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
//        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(86))
        btn.setTitle("创建食谱", for: .normal)
        btn.backgroundColor = .white
        btn.enablePressEffect()
        btn.setImage(UIImage(named: "meals_create_icon"), for: .normal)
        btn.setTitleColor(WHColor_16(colorStr: "2BA471"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        btn.isHidden = true
        
        return btn
    }()
}

extension FoodsListAddVM{
    func initUI() {
        addSubview(bgView)
        addSubview(createFoodsButton)
        addSubview(createFoodsSoonButton)
        addSubview(aiFoodsButton)
        addSubview(mergeFoodsButton)
        addSubview(createMealsButton)
        
        aiFoodsButton.addSubview(aiFoodsNewVm)
        mergeFoodsButton.addSubview(mergeFoodsNewVm)
        
        aiFoodsNewVm.snp.makeConstraints { make in
//            make.top.right.equalToSuperview()
            make.top.equalTo(kFitWidth(5))
            make.right.equalTo(kFitWidth(-5))
            make.width.height.equalTo(kFitWidth(12))
//            make.height.equalTo(kFitWidth(15))
        }
        mergeFoodsNewVm.snp.makeConstraints { make in
//            make.top.right.equalToSuperview()
//            make.width.equalTo(kFitWidth(40))
//            make.height.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(5))
            make.right.equalTo(kFitWidth(-5))
            make.width.height.equalTo(kFitWidth(12))
        }
    }
    func refreshButtonFrame() {
        createFoodsSoonButton.isHidden = true
//        createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(343), height: kFitWidth(86))
        createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        aiFoodsButton.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
//        mergeFoodsButton.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
    }
    
    func refreshButtonFrameForAll(hasCreatSoon:Bool)  {
        if hasCreatSoon{
            createFoodsSoonButton.isHidden = false
            createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
            createFoodsSoonButton.frame = CGRect.init(x: kFitWidth(133), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
            aiFoodsButton.frame = CGRect.init(x: kFitWidth(250), y: kFitWidth(17), width: kFitWidth(109), height: kFitWidth(86))
        }else{
            createFoodsSoonButton.isHidden = true
            createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
            aiFoodsButton.frame = CGRect.init(x: kFitWidth(191), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        }
    }
    
    func refreshButtonStatus(isMeals:Bool,isMyFoods:Bool=false){
        if isMeals == true{
            bgView.backgroundColor = WHColor_16(colorStr: "E3F9E9")
            self.backgroundColor = WHColor_16(colorStr: "E3F9E9")
            self.createMealsButton.isHidden = false
            self.createFoodsButton.isHidden = true
            self.createFoodsSoonButton.isHidden = true
        }else{
            bgView.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
            self.createMealsButton.isHidden = true
            self.createFoodsButton.isHidden = false
            self.createFoodsSoonButton.isHidden = false
        }
    }
    
    func refreshButton(type:FOODS_TYPE,isFromMain:Bool) {
        createFoodsButton.isHidden = true
        aiFoodsButton.isHidden = true
        createFoodsSoonButton.isHidden = true
        mergeFoodsButton.isHidden = true
        createMealsButton.isHidden = true
        
        if isFromMain{//首页进来的
            var btnWidth = (SCREEN_WIDHT-kFitWidth(40))/2
            switch type{
            case .all: //创建食物 、 AI识别
                createFoodsButton.isHidden = false
                aiFoodsButton.isHidden = false
                createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                aiFoodsButton.frame = CGRect.init(x: createFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
            case .my://创建食物 、 食物融合
                createFoodsButton.isHidden = false
                mergeFoodsButton.isHidden = false
                createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
                mergeFoodsButton.frame = CGRect.init(x: createFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
            case .meal:
                createMealsButton.isHidden = false
            }
        }else{
            switch type{
            case .all: //创建食物 、快速添加、 AI识别
                if self.isFromMerge {
                    let btnWidth = (SCREEN_WIDHT-kFitWidth(40))/2
                    createFoodsButton.isHidden = false
                    createFoodsSoonButton.isHidden = false
                    createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                    createFoodsSoonButton.frame = CGRect.init(x: createFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                }else{
                    let btnWidth = (SCREEN_WIDHT-kFitWidth(48))/3
                    createFoodsButton.isHidden = false
                    createFoodsSoonButton.isHidden = false
                    aiFoodsButton.isHidden = false
                    createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                    createFoodsSoonButton.frame = CGRect.init(x: createFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                    aiFoodsButton.frame = CGRect.init(x: createFoodsSoonButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                }
            case .my://创建食物 、 食物融合
                createFoodsButton.isHidden = false
                mergeFoodsButton.isHidden = false
                let btnWidth = (SCREEN_WIDHT-kFitWidth(40))/2
                createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
                mergeFoodsButton.frame = CGRect.init(x: createFoodsButton.frame.maxX+kFitWidth(8), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
            case .meal:
                createMealsButton.isHidden = false
            }
        }
    }
    func refreshButtonFrameForMerge() {
        createFoodsButton.isHidden = false
        aiFoodsButton.isHidden = true
        createFoodsSoonButton.isHidden = true
        mergeFoodsButton.isHidden = true
        createMealsButton.isHidden = true
        createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(86))
    }
}
