//
//  MealsCaloriesDetailVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/25.
//

import Foundation
import UIKit

class MealsCaloriesDetailVM: UIView {
    
    var selfHeight = kFitWidth(234)
    var controller = WHBaseViewVC()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(12), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(190)))
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        return vi
    }()
    lazy var caloriesNumLabel: UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "-"
        lab.format = "%d"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
//        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.font = UIFont().DDInFontMedium(fontSize: 16)

        return lab
    }()
    lazy var caloriesUnitLabel: UILabel = {
        let lab = UILabel()
        lab.text = "千卡"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .bold)

        return lab
    }()
    lazy var caloriDetailVm: FoodsDetailCaloriVM = {
        let vm = FoodsDetailCaloriVM.init(frame: CGRect.init(x: 0, y: kFitWidth(56), width: 0, height: 0))
        return vm
    }()
    lazy var foodsListLabel: UILabel = {
        let lab = UILabel()
        lab.text = "食物列表"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.15)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.backgroundColor = .white
        
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
}

extension MealsCaloriesDetailVM{
    func updateUI(dict:NSDictionary) {
        self.caloriDetailVm.updateMealsDetail(dict: dict)
        caloriesNumLabel.text = WHUtils.convertStringToStringNoDigit("\(dict.doubleValueForKey(key: "calories").rounded())")
        
        caloriesNumLabel.count(from: 0, to: CGFloat(Int(dict.doubleValueForKey(key: "calories").rounded())), withDuration: 0.5)
    }
}
extension MealsCaloriesDetailVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(caloriesNumLabel)
        bgView.addSubview(caloriesUnitLabel)
        bgView.addSubview(caloriDetailVm)
        
        addSubview(lineView)
        addSubview(foodsListLabel)
        
        caloriDetailVm.updateUIFormMeals()
        let caloriDetailVmCenter = self.caloriDetailVm.center
        self.caloriDetailVm.center = CGPoint.init(x: (SCREEN_WIDHT-kFitWidth(32))*0.5, y: caloriDetailVmCenter.y)
        
        setConstrait()
    }
    func setConstrait() {
        caloriesNumLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
//            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(-5))
            make.top.equalTo(kFitWidth(20))
        }
        caloriesUnitLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesNumLabel.snp.right).offset(kFitWidth(2))
//            make.centerY.lessThanOrEqualTo(caloriesNumLabel)
            make.bottom.equalTo(caloriesNumLabel)//.offset(kFitWidth(-2))
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(bgView)
            make.top.equalTo(bgView.snp.bottom).offset(kFitWidth(26))
            make.height.equalTo(kFitWidth(1))
        }
        foodsListLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(lineView)
            make.width.equalTo(kFitWidth(64))
            make.height.equalTo(kFitWidth(12))
        }
    }
}
