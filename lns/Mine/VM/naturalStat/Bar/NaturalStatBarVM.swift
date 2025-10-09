//
//  NaturalStatBarVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/12.
//

import Foundation

class NaturalStatBarVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var controller = WHBaseViewVC()
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: controller.getNavigationBarHeight() + kFitWidth(28), width: SCREEN_WIDHT, height: SCREEN_HEIGHT - controller.getNavigationBarHeight() - kFitWidth(28)))
        selfHeight = SCREEN_HEIGHT - controller.getNavigationBarHeight() - kFitWidth(28)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    lazy var scrollViewBase : UIScrollView = {
        let vi = UIScrollView()
        vi.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-controller.getNavigationBarHeight())
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        
        return vi
    }()
    lazy var naviTimeVm: NaturalStatNaviTimeVM = {
        let vm = NaturalStatNaviTimeVM.init(frame: .zero)
        return vm
    }()
    lazy var perDataVm: NaturalPerVM = {
        let vm = NaturalPerVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        
        return vm
    }()
    lazy var caloriesBarChartView: NaturalStatCaloriesBarChartView = {
        let vm = NaturalStatCaloriesBarChartView.init(frame: CGRect.init(x: 0, y: self.perDataVm.frame.maxY, width: 0, height: 0))
        
        return vm
    }()
    lazy var dgBarChartView: NaturalStatCaloriesDGBarChart = {
        let vm = NaturalStatCaloriesDGBarChart.init(frame: CGRect.init(x: 0, y: self.perDataVm.frame.maxY, width: 0, height: 0))
        
        return vm
    }()
    lazy var naturalBarChartView: NaturalStatCPFDGBarChart = {
        let vm = NaturalStatCPFDGBarChart.init(frame: CGRect.init(x: 0, y: self.dgBarChartView.frame.maxY+kFitWidth(8), width: 0, height: 0))
        return vm
    }()
    lazy var fitnessStatVm: FitnessStatVM = {
        let vm = FitnessStatVM.init(frame: CGRect.init(x: 0, y: self.naturalBarChartView.frame.maxY, width: 0, height: 0))
        vm.heightChangeBlock = {(heigth)in
            self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.fitnessStatVm.frame.minY+heigth+kFitWidth(20)+WHUtils().getBottomSafeAreaHeight())
        }
        vm.tipTapBlock = {()in
//            self.controller.definesPresentationContext = true
            let vc = FitnessTipsVC()
//            vc.modalPresentationStyle = .pageSheet
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.controller.navigationController?.pushViewController(vc, animated: true)
            }else{
                vc.modalPresentationStyle = .pageSheet
                vc.modalTransitionStyle = .crossDissolve
                self.controller.present(vc, animated: true)
            }
        }
        return vm
    }()
}

extension NaturalStatBarVM{
    func initUI() {
        addSubview(naviTimeVm)
        addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight)
        scrollViewBase.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        
        scrollViewBase.addSubview(perDataVm)
        scrollViewBase.addSubview(dgBarChartView)
        scrollViewBase.addSubview(naturalBarChartView)
        scrollViewBase.addSubview(fitnessStatVm)
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: self.fitnessStatVm.frame.maxY+kFitWidth(20)+WHUtils().getBottomSafeAreaHeight())
    }
}
