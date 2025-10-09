//
//  LLMyTabbar.swift
//  swiftStudy01
//
//  Created by 刘恋 on 2019/6/6.
//  Copyright © 2019 刘恋. All rights reserved.
//

import UIKit


//声明代理方法
protocol LLMyTabbarDelegate: NSObjectProtocol {
     func tabbarDidSelectedButtomFromto(tabbar:LLMyTabbar,from:Int,to:Int)
}

class LLMyTabbar: UIView {

    //delegate  要写在class里面，否则无效
    var delegate:LLMyTabbarDelegate?
    var nomarlButton = LLButton()
    var seletedButton = LLButton()
    
    var btnArr:[LLButton] = NSMutableArray() as! [LLButton]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(gotoMainNotification), name: NSNotification.Name(rawValue: "gotoMain"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "activePlan"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(mineServiceMsgNotification), name: NSNotification.Name(rawValue: "serviceMsgUnRead"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mineServiceMsgReadNotification), name: NSNotification.Name(rawValue: "serviceMsgRead"), object: nil)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func gotoMainNotification(){
        DLLog(message: "跳转到首页")
//        if ( delegate?.responds(to: Selector(("tabbarDidSelectedButtomFromto"))) != nil )  {
//            delegate?.tabbarDidSelectedButtomFromto(tabbar: self, from: seletedButton.tag, to: 0)
//        }
        seletedButton.isSelected = false
        seletedButton.conentLab.textColor = .COLOR_TEXT_TITLE_0f1214
//        sender.isSelected = true
        seletedButton = btnArr[0]
        seletedButton.isSelected = true
        seletedButton.conentLab.textColor = .THEME
    }
    
    @objc func gotoLogsNotification(){
        DLLog(message: "跳转到日志")
//        if ( delegate?.responds(to: Selector(("tabbarDidSelectedButtomFromto"))) != nil )  {
//            delegate?.tabbarDidSelectedButtomFromto(tabbar: self, from: seletedButton.tag, to: 1)
//        }
        
        seletedButton.isSelected = false
        seletedButton.conentLab.textColor = .COLOR_TEXT_TITLE_0f1214
//        sender.isSelected = true
        seletedButton = btnArr[1]
        seletedButton.isSelected = true
        seletedButton.conentLab.textColor = .THEME
    }
    @objc func mineServiceMsgNotification(){
        let btn = btnArr.last
        btn?.redView.isHidden = false
    }
    @objc func mineServiceMsgReadNotification(){
        let btn = btnArr.last
        //UserInfoModel.shared.widgetNewFuncRead 使用教程--小组件  红点去除   2025年04月08日11:27:30
        if UserInfoModel.shared.settingNewFuncRead && UserInfoModel.shared.newsListHasUnRead == false{//&& UserInfoModel.shared.statNewFuncRead
            btn?.redView.isHidden = true
        }else{
            btn?.redView.isHidden = false
        }
    }
    func addTabBarButtonWithItem(item:UITabBarItem)-> Void{
        let button:LLButton = LLButton(type: .custom)
        self.addSubview(button)
        
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        button.setTitleColor(.THEME, for: UIControl.State.selected)
        
//            button.setTitleColor(.COLOR_TEXT_TITLE_0f1214_30, for: .normal)
//            button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
//        button.setTitle(item.title, for: .normal)
        button.conentLab.text = item.title
        button.conentLab.textColor = .COLOR_TEXT_TITLE_0f1214
        button.setImage(item.image, for: .normal)
        button.setImage(item.selectedImage, for: .selected)
        
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action:#selector(buttonClick(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(handlePressDragEnter), for: .touchDown)
  
//        if self.subviews.count == 1 {
//            self.buttonClick(button)
//        }
        
        btnArr.append(button)
    }
    
    @objc func handlePressDragEnter(_ sender: LLButton) {
        if seletedButton != sender{
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
        }
    }

    //button 调用方法传参使用  需注意
   @objc func buttonClick(_ sender: LLButton) {
        //调用代理
        if ( delegate?.responds(to: Selector(("tabbarDidSelectedButtomFromto"))) != nil )  {
            delegate?.tabbarDidSelectedButtomFromto(tabbar: self, from: seletedButton.tag, to: sender.tag)
        }
       
        seletedButton.isSelected = false
       seletedButton.conentLab.textColor = .COLOR_TEXT_TITLE_0f1214
        sender.isSelected = true
        seletedButton = sender
       seletedButton.conentLab.textColor = .THEME
    }
    
    func centerClick() {
        //调用代理
        if ( delegate?.responds(to: Selector(("tabbarDidSelectedButtomFromto"))) != nil )  {
            delegate?.tabbarDidSelectedButtomFromto(tabbar: self, from: seletedButton.tag, to: 1)
        }

//        seletedButton.isSelected = false
        seletedButton = btnArr[1]
        seletedButton.isSelected = true
        seletedButton.conentLab.textColor = .THEME
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for var index in 0...(self.subviews.count-1) {
            let button:LLButton = self.subviews[index] as! LLButton
            let number:Int = Int(CGFloat(kScreenWidth))/Int(self.subviews.count)
            let width:CGFloat = CGFloat(self.frame.size.width)/CGFloat(Int(self.subviews.count))
            let X:CGFloat = CGFloat(index * number)
            
//            if index == 1 {
//                button.frame = CGRect(x: X,y: 0,width: width,height: kFitWidth(70))
//                button.imageView?.frame = CGRect.init(x: 0, y: 0, width: kFitWidth(58), height: kFitWidth(58))
//                button.imageView?.contentMode = .top
//                button.imageView?.clipsToBounds = false
//                centerButton = button
//            }else{
                button.frame = CGRect(x: X,y: kFitWidth(0),width: width,height: kFitWidth(48))
                button.imageView?.frame = CGRect.init(x: 0, y: kFitWidth(4), width: kFitWidth(24), height: kFitWidth(24))
                button.imageView?.contentMode = .top
                button.imageView?.clipsToBounds = false
            
                button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
                button.setTitleColor(.THEME, for: .selected)
//            }
            
            button.tag = index
            index = index + 1
            
            if index == 0 {
                seletedButton = button
                seletedButton.isSelected = true
                seletedButton.conentLab.textColor = .THEME
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        DLLog(message: "point(inside:\(point.x),\(point.y)")
        for vi in self.subviews{
            let tp = vi.convert(point, from: self)
            if CGRectContainsPoint(vi.bounds, tp){
                return true
            }
        }
        return false
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        var view = super.hitTest(point, with: event)
//        if view == nil{
//            for vi in self.subviews{
//                let tp = vi.convert(point, from: self)
//                if CGRectContainsPoint(centerButton.bounds, tp){
//                    view = centerButton
//                }
//            }
//        }
//        return view
//    }

    
//    func getCurrentController() -> UIViewController? {
//           guard let window = UIApplication.shared.windows.first else {
//               return nil
//           }
//           var tempView: UIView?
//           for subview in window.subviews.reversed() {
//               if subview.classForCoder.description() == "UILayoutContainerView" {
//                   tempView = subview
//                   break
//               }
//           }
//           
//           if tempView == nil {
//               tempView = window.subviews.last
//           }
//           
//           var nextResponder = tempView?.next
//           var next: Bool {
//               return !(nextResponder is UIViewController) || nextResponder is UINavigationController || nextResponder is UITabBarController
//           }
//
//           while next{
//               tempView = tempView?.subviews.first
//               if tempView == nil {
//                   return nil
//               }
//               nextResponder = tempView!.next
//           }
//           return nextResponder as? UIViewController
//       }
    
}
