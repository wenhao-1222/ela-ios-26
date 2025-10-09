//
//  FoodsDetailSpecAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/24.
//

import Foundation
import UIKit

class FoodsDetailSpecAlertVM: UIView {
    
    var selectBlock:((NSDictionary)->())?
    var specName = ""
    var vmDataArray = NSMutableArray()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.0)
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var specArray: NSArray = {
        return NSArray(object: [["specName":"克","specNum":"100"]])
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(200), height: kFitWidth(240)))
        vi.layer.cornerRadius = kFitWidth(8)
        vi.alpha = 0
        
        return vi
    }()
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.backgroundColor = .white
        
        return scro
    }()
}

extension FoodsDetailSpecAlertVM{
    @objc func showSelf() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
    }
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    func setDataArray(specArr:NSArray) {
        self.specArray = specArr
        if self.specArray.count == 0 {
            self.specArray = [["specName":"g","specNum":"100"]]
        }
        updateUI()
        
        if self.specName == "" || self.specName.count == 0 {
            selecteSpecAction(index: 0)
        }else{
            for i in 0..<self.specArray.count{
                let dict = self.specArray[i]as? NSDictionary ?? [:]
                if dict["specName"]as? String ?? "" == specName{
                    selecteSpecAction(index: i)
                    break
                }
            }
        }
    }
    @objc func selecteSpecAction(index:Int) {
        if self.selectBlock != nil{
            self.selectBlock!(self.specArray[index]as? NSDictionary ?? [:])
        }
        for i in 0..<vmDataArray.count{
            let vm = vmDataArray[i]as! QuestionnairePlanFoodsTypeItemVM
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
            if i == index{
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
            }
        }
        
        self.hiddenSelf()
    }
}

extension FoodsDetailSpecAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(scrollView)
//        whiteView.addShadow()
    }
    func updateUI() {
        if self.specArray.count <= 5{
            whiteView.frame = CGRect.init(x: kFitWidth(84), y: kFitWidth(180)+WHUtils().getNavigationBarHeight(), width: kFitWidth(200), height: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(self.specArray.count))
            scrollView.frame = CGRect.init(x: 0, y: 0, width: kFitWidth(200), height: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(self.specArray.count))
        }else{
            whiteView.frame = CGRect.init(x: kFitWidth(84), y: kFitWidth(180)+WHUtils().getNavigationBarHeight(), width: kFitWidth(200), height: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(5))
            scrollView.frame = CGRect.init(x: 0, y: 0, width: kFitWidth(200), height: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(5))
            scrollView.contentSize = CGSize.init(width: 0, height: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(self.specArray.count))
        }
        
        whiteView.addShadow()
        
        vmDataArray.removeAllObjects()
        for i in 0..<self.specArray.count{
            let dict = self.specArray[i]as? NSDictionary ?? [:]
            let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(i), width: 0, height: 0))
            scrollView.addSubview(vm)
            vm.titleLabel.text = "\(dict["specName"]as? String ?? "")"
            
            vm.tapBlock = {()in
                self.selecteSpecAction(index: i)
            }
            vmDataArray.add(vm)
        }
    }
}

