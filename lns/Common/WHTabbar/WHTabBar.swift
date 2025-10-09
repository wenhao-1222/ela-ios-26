//
//  WHTabBar.swift
//  lns
//
//  Created by LNS2 on 2024/5/6.
//

import Foundation

class WHTabBar : UITabBar{
    
    var tabbar = LLMyTabbar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func enumSubView(vi:UIView) {
        for subView in vi.subviews{
            if subView.isEqual(UIVisualEffectView.classForCoder()){
                subView.backgroundColor = .white
                for vi in subView.subviews{
                    vi.backgroundColor = .white
                }
            }else{
                enumSubView(vi: subView)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension WHTabBar{
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        var view = super.hitTest(point, with: event)
//        if self.isHidden == false{
//            if view == nil{
//                for vi in self.subviews{
//                    let tp = vi.convert(point, from: self)
//                    let centerImgFrame = CGRect.init(x: tabbar.centerButton.frame.minX+(tabbar.centerButton.bounds.width-kFitWidth(58))*0.5, y: tabbar.centerButton.frame.minY, width: kFitWidth(58), height: tabbar.centerButton.frame.height)
//                    if CGRectContainsPoint(centerImgFrame, tp){
//                        view = tabbar.centerButton
//                    }
//                }
//            }
//        }
//        
//        return view
//    }
}
