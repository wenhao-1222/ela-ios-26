//
//  LogsMealsMsgVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation
import UIKit

class LogsMealsMsgVM: UIView {
    
    var selfHeight = kFitWidth(70)
    var dataSourceArray = NSMutableArray()
    
    var calculatBlock:((NSDictionary)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.size.height
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(0), width: kFitWidth(359), height: selfHeight))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(8)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.text = "第 1 餐"
        return lab
    }()
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "logs_add_icon_theme"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        
        return btn
    }()
    lazy var noFoodsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "请添加食物"
        return lab
    }()
    lazy var naturalVm : LogsMealsNaturalMsgVM = {
        let vm = LogsMealsNaturalMsgVM.init(frame: CGRect.init(x: 0, y: kFitWidth(59), width: 0, height: 0))
        vm.isHidden = true
        return vm
    }()
}

extension LogsMealsMsgVM{
    func updateUI(array:NSArray) {
        dataSourceArray = NSMutableArray(array: array)
        
        if dataSourceArray.count > 0 {
            noFoodsLabel.isHidden = true
            naturalVm.isHidden = false
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var caloriTotal = Int(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            var originY = kFitWidth(147)
            for i in 0..<self.dataSourceArray.count{
                let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
                
                let calori = dict["calories"]as? Int ?? 0
                
//                let carbohydrate = dict.doubleValueForKey(key: "carbohydrate")
//                let protein = dict.doubleValueForKey(key: "protein")
//                let fat = dict.doubleValueForKey(key: "fat")
                
                let carbohydrate = dict["carbohydrate"]as? Double ?? 0
                let protein = dict["protein"]as? Double ?? 0
                let fat = dict["fat"]as? Double ?? 0
                
                caloriTotal = caloriTotal + calori
                carboTotal = carboTotal + carbohydrate
                proteinTotal = proteinTotal + protein
                fatTotal = fatTotal + fat
                
                DispatchQueue.main.sync {
                    let vm = LogsMealsFoodsMsgVM.init(frame: CGRect.init(x: 0, y: originY, width: 0, height: 0))
                    self.whiteView.addSubview(vm)
                    vm.updateUI(dict: dict)
                    originY = originY + kFitWidth(40)
                }
            }
            
            DispatchQueue.main.async {
                self.naturalVm.caloriLabel.count(from: 0, to: CGFloat(caloriTotal), withDuration: 0.7)
                self.naturalVm.carboLabel.count(from: 0, to: CGFloat(carboTotal), withDuration: 0.7)
                self.naturalVm.proteinLabel.count(from: 0, to: CGFloat(proteinTotal), withDuration: 0.7)
                self.naturalVm.fatLabel.count(from: 0, to: CGFloat(fatTotal), withDuration: 0.7)
                
            }
        }
    }
}
extension LogsMealsMsgVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(addButton)
        whiteView.addSubview(noFoodsLabel)
        
        whiteView.addSubview(naturalVm)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        addButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(kFitWidth(52))
            make.height.equalTo(kFitWidth(50))
        }
        noFoodsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(42))
        }
    }
}
