//
//  GoalCircleTagsVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/18.
//


import Foundation
import UIKit

class GoalCircleTagsVM: UIView {
    
    let selfHeight = kFitWidth(73)
    let gap = kFitWidth(10)
    let btnWidth = (SCREEN_WIDHT-kFitWidth(34) - kFitWidth(10) * CGFloat(4))*0.2
    var buttonArray:[GoalCircleTagsItemVM] = [GoalCircleTagsItemVM]()
    
    var selectTag = ""
    
    var tagChangeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        scro.showsHorizontalScrollIndicator = false
        scro.backgroundColor = .white
        return scro
    }()
}

extension GoalCircleTagsVM{
    func btnTapAction(index:Int) {
        if buttonArray.count > index{
            let selectVm = buttonArray[index]
            if selectVm.isSelect{
                selectTag = ConstantModel.shared.cc_label_array[index]as? String ?? ""
                self.tagChangeBlock?(ConstantModel.shared.cc_label_array[index]as? String ?? "")
                for vm in buttonArray{
                    vm.setSelect(select: false)
                }
                selectVm.setSelect(select: true)
            }else{
                selectVm.setSelect(select: false)
                selectTag = ""
                self.tagChangeBlock?("")
            }
        }
    }
    func refreshSelectTag(index:Int) {
        for vm in buttonArray{
            vm.setSelect(select: false)
        }
        if index >= 0 {
            let selectVm = buttonArray[index]
            selectVm.setSelect(select: true)
        }
    }
}

extension GoalCircleTagsVM{
    func initUI()  {
        addSubview(scrollView)
        updateDataSource()
    }
    func updateDataSource() {
        var maxX = kFitWidth(0)
        for i in 0..<ConstantModel.shared.cc_label_array.count{
            let vm = GoalCircleTagsItemVM.init(frame: CGRect.init(x: kFitWidth(17)+(btnWidth+gap)*CGFloat(i), y: kFitWidth(0), width: btnWidth, height: kFitWidth(28)))
            vm.contentLabel.text = "#\(ConstantModel.shared.cc_label_array[i]as? String ?? "")"
            scrollView.addSubview(vm)
            
            vm.tapBlock = {()in
                self.btnTapAction(index: i)
            }
            
            buttonArray.append(vm)
            
            maxX = vm.frame.maxX
        }
        scrollView.contentSize = CGSize.init(width: maxX, height: 0)
    }
}


