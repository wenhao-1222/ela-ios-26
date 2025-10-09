//
//  MealsCaloriesTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/7/24.
//

import Foundation

class MealsCaloriesTableViewCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(12), width: kFitWidth(343), height: kFitWidth(190)))
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        return vi
    }()
    lazy var caloriesNumLabel: UILabel = {
        let lab = UILabel()
        lab.text = "--"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .heavy)

        return lab
    }()
    lazy var caloriesUnitLabel: UILabel = {
        let lab = UILabel()
        lab.text = "卡路里（千卡）"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)

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

extension MealsCaloriesTableViewCell{
    func updateUI(dict:NSDictionary) {
        self.caloriDetailVm.updateMealsDetail(dict: dict)
        caloriesNumLabel.text = WHUtils.convertStringToStringNoDigit("\(dict.doubleValueForKey(key: "calories").rounded())")
    }
}
extension MealsCaloriesTableViewCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(caloriesNumLabel)
        bgView.addSubview(caloriesUnitLabel)
        bgView.addSubview(caloriDetailVm)
        
        contentView.addSubview(lineView)
        contentView.addSubview(foodsListLabel)
        
        caloriDetailVm.updateUIFormMeals()
//        let detailDict = ["carbohydrate":"0",
//                          "fat":"0",
//                          "protein":"0",
//                          "calories":"0"]
//        self.caloriDetailVm.updateMealsDetail(dict: detailDict as NSDictionary)
        
        let caloriDetailVmCenter = self.caloriDetailVm.center
        self.caloriDetailVm.center = CGPoint.init(x: kFitWidth(343)*0.5, y: caloriDetailVmCenter.y)
        
        setConstrait()
    }
    func setConstrait() {
        caloriesNumLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(20))
        }
        caloriesUnitLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesNumLabel.snp.right).offset(kFitWidth(2))
            make.centerY.lessThanOrEqualTo(caloriesNumLabel)
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
