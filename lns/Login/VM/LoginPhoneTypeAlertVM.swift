//
//  LoginPhoneTypeAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/15.
//

import Foundation
import UIKit

class LoginPhoneTypeAlertVM: UIView {
    
    var choiceBlock:((NSDictionary)->())?
    var dataSourceArray = NSArray()
    var vmDataArray = [LoginPhoneTypeAlertItemVM]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
//        vi.clipsToBounds = true
        vi.backgroundColor = .white//WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
}

extension LoginPhoneTypeAlertVM{
    func showSelf(){
        UIApplication.shared.keyWindow?.addSubview(self)
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
    }
    @objc func hiddenSelf(){
        self.removeFromSuperview()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    func setSelectStatus(daysIndex:Int) {
        for vm in vmDataArray{
//            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        
        let vm = vmDataArray[daysIndex]
//        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
        
        if self.choiceBlock != nil{
            self.choiceBlock!(self.dataSourceArray[daysIndex]as? NSDictionary ?? [:])
        }
    }
}

extension LoginPhoneTypeAlertVM{
    func initUI()  {
        addSubview(whiteView)
        whiteView.addShadow()
    }
    func setDataArray(dataArray:NSArray,originY:CGFloat,selectedIndex:Int)  {
        self.dataSourceArray = dataArray
        for vi in whiteView.subviews{
            vi.removeFromSuperview()
        }
        vmDataArray.removeAll()
        
        whiteView.frame = CGRect.init(x: kFitWidth(32), y: originY, width: kFitWidth(200), height: kFitWidth(36)*CGFloat(dataArray.count))
        let scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(200), height: kFitWidth(36)*7.4))
        scrollView.bounces = false
        if dataArray.count > 7 {
            whiteView.frame = CGRect.init(x: kFitWidth(32), y: originY, width: kFitWidth(200), height: kFitWidth(36)*CGFloat(7.4))
            whiteView.addSubview(scrollView)
            scrollView.contentSize = CGSize.init(width: 0, height: kFitWidth(36)*CGFloat(dataArray.count))
        }
        
        for i in 0..<dataArray.count{
            let dict = dataArray[i]as? NSDictionary ?? [:]
            let vm = LoginPhoneTypeAlertItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(36)*CGFloat(i), width: 0, height: 0))
            vm.updateUI(dict: dict)
            
            if i == selectedIndex {
//                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
            }else{
//                vm.selectImgView.isHidden = true
                vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
            }
            
            if dataArray.count > 5 {
                scrollView.addSubview(vm)
            }else{
                whiteView.addSubview(vm)
            }
            
            vm.tag = 110 + i
            vmDataArray.append(vm)
            
            vm.tapBlock = {()in
                self.setSelectStatus(daysIndex: i)
                self.hiddenSelf()
            }
        }
    }
}

