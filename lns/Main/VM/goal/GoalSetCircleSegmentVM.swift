//
//  GoalSetCircleSegmentVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/7.
//

import Foundation
import UIKit


@objc public protocol GoalSetCircleSegmentVMDelegate: NSObjectProtocol {
    /// Called when clicked
    @objc optional func segment(didSelectItemAt index: Int)
}


class GoalSetCircleSegmentVM: UIView {
    
    var selfWidth = kFitWidth(58)*6
    let selfHeight = kFitWidth(50)
    let lineWidth = kFitWidth(1)//1.0 / UIScreen.main.scale
    
    var selectIndex = 0
    var btnArray:[UIButton] = [UIButton]()
    var selectBtn = UIButton()
    
    open weak var delegate: GoalSetCircleSegmentVMDelegate?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(13.5), y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(27), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.THEME.cgColor
        self.layer.borderWidth = lineWidth
        selfWidth = SCREEN_WIDHT-kFitWidth(27)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var weekDays: NSMutableArray = {
        return ["第1天","第2天","第3天","第4天","第5天","第6天"]
    }()
    
}

extension GoalSetCircleSegmentVM{
    @objc func buttonTapAction(sender:UIButton) {
        if selectIndex == sender.tag - 1070{
            return
        }
        selectIndex = sender.tag - 1070
        selectBtn.isSelected = false
        
        selectBtn = sender
        selectBtn.isSelected = true
        
        if let delegate = delegate , delegate.responds(to: #selector(GoalSetCircleSegmentVMDelegate.segment(didSelectItemAt:))){
            delegate.segment?(didSelectItemAt: selectIndex)
        }
    }
}

extension GoalSetCircleSegmentVM{
    func updateCircleDays(daysNumber:Int) {
        weekDays.removeAllObjects()
        btnArray.removeAll()
        for vi in self.subviews{
            vi.removeFromSuperview()
        }
        
        for i in 0..<daysNumber{
            weekDays.add("第\(i+1)天")
        }
        initUI()
        self.selectIndex = 0
    }
    func initUI() {
        let btnWidth = selfWidth/CGFloat(weekDays.count)//+kFitWidth(1)
        for i in 0..<weekDays.count{
            let button = FeedBackButton()
//            let originX = i == 0 ? (btnWidth*CGFloat(i)) : (btnWidth*CGFloat(i) - kFitWidth(0.5))
//            let btnW = i == 0 ? btnWidth : (btnWidth + kFitWidth(1))
//            button.frame = CGRect.init(x: originX, y: 0, width: btnW, height: kFitWidth(50))
            button.frame = CGRect.init(x: btnWidth*CGFloat(i), y: 0, width: btnWidth, height: kFitWidth(50))
            button.setTitle("\(weekDays[i]as? String ?? "")", for: .normal)
            button.setTitleColor(.THEME, for: .normal)
            button.setTitleColor(.white, for: .selected)
//            button.setTitleColor(.COLOR_BUTTON_DISABLE_BG_THEME, for: .highlighted)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            button.setBackgroundImage(createImageWithColor(color: .THEME), for: .selected)
            button.setBackgroundImage(createImageWithColor(color: .white), for: .normal)
            button.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .highlighted)
            button.clipsToBounds = true
            button.tag = 1070 + i
            button.addTarget(self, action: #selector(buttonTapAction(sender:)), for: .touchUpInside)
            
            if i == 0 {
                selectBtn = button
                button.isSelected = true
//                button.addClipCorner(corners: [.topLeft,.bottomLeft], radius: kFitWidth(8))
            }else if i == weekDays.count - 1{
//                button.addClipCorner(corners: [.topRight,.bottomRight], radius: kFitWidth(8))
            }
//            button.layer.borderColor = UIColor.THEME.cgColor
//            button.layer.borderWidth = kFitWidth(0.5)
            
            addSubview(button)
            btnArray.append(button)
            
            if i > 0 {
                let vi = UIView(frame: CGRect(x: kFitWidth(0), y: 0, width: lineWidth, height: kFitWidth(50)))
                vi.backgroundColor = .THEME
//                addSubview(vi)
                button.addSubview(vi)
            }
        }
//        
//        for i in 0..<weekDays.count{
//            if i > 0 {
//                let vi = UIView.init(frame: CGRect.init(x: btnWidth*CGFloat(i)-kFitWidth(0.4), y: 0, width: kFitWidth(0.8), height: kFitWidth(50)))
//                vi.backgroundColor = .THEME
//                addSubview(vi)
//            }
//        }
    }
}
