//
//  PlanShareMealsMsgVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit

class PlanShareMealsMsgVM: UIView {
    
    let selfHeight = kFitWidth(160)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: kFitWidth(320), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var scrollView : UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(320), height: selfHeight))
        
        
        return scro
    }()
    
}

extension PlanShareMealsMsgVM{
    func initUI() {
        addSubview(scrollView)
    }
    
    func updateUI(dataArray:NSArray,isLogs:Bool? = true)  {
        var originY = kFitWidth(0)
        for i in 0..<dataArray.count{
            let arr = dataArray[i]as? NSArray ?? []
            if arr.count > 0 {
                let titleVm = PlanShareMealsTitleVM.init(frame: CGRect.init(x: 0, y: originY, width: kFitWidth(320), height: 0))
                titleVm.titleLabel.text = "第 \(i+1) 餐"
                
                var hasFoods = false
                
                for j in 0..<arr.count{
                    let dict = arr[j]as? NSDictionary ?? [:]
                    
                    if isLogs == true{
                        if dict.stringValueForKey(key: "state") == "1"{
                            if hasFoods == false{
                                hasFoods = true
                                scrollView.addSubview(titleVm)
                                originY = originY + titleVm.selfHeight + kFitWidth(8)
                            }
                            
                            let foodsVm = PlanShareMealsFoodsVM.init(frame: CGRect.init(x: 0, y: originY, width: kFitWidth(320), height: 0))
                            scrollView.addSubview(foodsVm)
                            foodsVm.updateUI(dict: dict)
                            originY = originY + foodsVm.selfHeight
                        }
                    }else{
                        if hasFoods == false{
                            hasFoods = true
                            scrollView.addSubview(titleVm)
                            originY = originY + titleVm.selfHeight + kFitWidth(8)
                        }
                        
                        let foodsVm = PlanShareMealsFoodsVM.init(frame: CGRect.init(x: 0, y: originY, width: kFitWidth(320), height: 0))
                        scrollView.addSubview(foodsVm)
                        foodsVm.updateUI(dict: dict)
                        originY = originY + foodsVm.selfHeight
                    }
                }
            }
        }
        
        scrollView.contentSize = CGSize.init(width: 0, height: originY)
    }
}
