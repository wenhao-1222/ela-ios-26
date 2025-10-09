//
//  NaturalDetailVC.swift
//  lns
//  营养详情
//  Created by LNS2 on 2024/4/25.
//

import Foundation


class NaturalDetailVC: WHBaseViewVC {
    
    var detailDict = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var caloriMealVm: NaturalCaloriMealsVM = {
        let vm = NaturalCaloriMealsVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.calculateBlock = {()in
            let frame = self.caloriSourceVm.frame
            self.caloriSourceVm.frame = CGRect.init(x: frame.origin.x, y: self.caloriMealVm.frame.maxY, width: frame.width, height: frame.height)
            self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.caloriSourceVm.frame.maxY + kFitWidth(12) + self.getBottomSafeAreaHeight())
        }
        return vm
    }()
    lazy var caloriSourceVm : NaturalCaloriSourceVM = {
        let vm = NaturalCaloriSourceVM.init(frame: CGRect.init(x: 0, y: self.caloriMealVm.frame.maxY, width: 0, height: 0))
        
        return vm
    }()
}

extension NaturalDetailVC{
    func initUI()  {
        initNavi(titleStr: "营养详情")
        self.navigationView.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        
        view.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight())
        scrollViewBase.addSubview(caloriMealVm)
        scrollViewBase.addSubview(caloriSourceVm)
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: caloriSourceVm.frame.maxY + kFitWidth(12) + getBottomSafeAreaHeight())
        
        caloriMealVm.setDataSource(dataDict: self.detailDict)
        
        let protein = detailDict.doubleValueForKey(key: "proteinDouble")
        let carbo = detailDict.doubleValueForKey(key: "carbohydrateDouble")
        let fat = detailDict.doubleValueForKey(key: "fatDouble")
        
        if protein > 0 || carbo > 0 || fat > 0{
            caloriSourceVm.setDataSource(array: [carbo,protein,fat])
        }else{
            caloriSourceVm.setDataSource(array: [detailDict.doubleValueForKey(key: "carbohydrate"),
                                                 detailDict.doubleValueForKey(key: "protein"),
                                                 detailDict.doubleValueForKey(key: "fat")])
        }
    }
}
