//
//  GoalSetWeeksSegmentVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/1.
//

import Foundation
import UIKit


@objc public protocol GoalSetWeeksSegmentVMDelegate: NSObjectProtocol {
    /// Called when clicked
    @objc optional func segment(didSelectItemAt index: Int)
}


class GoalSetWeeksSegmentVM: UIView {
    
    let selfWidth = SCREEN_WIDHT-kFitWidth(25)
    let selfHeight = kFitWidth(50)
    let lineWidth = kFitWidth(1)//1.0 / UIScreen.main.scale
    var selectIndex = 0
    var btnArray:[UIButton] = [UIButton]()
    var selectBtn = UIButton()
    
    open weak var delegate: GoalSetWeeksSegmentVMDelegate?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(12.5), y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.THEME.cgColor
        self.layer.borderWidth = lineWidth//kFitWidth(1)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var weekDays: NSArray = {
        return ["一","二","三","四","五","六","日"]
    }()
    
}

extension GoalSetWeeksSegmentVM{
    @objc func buttonTapAction(sender:UIButton) {
        if selectIndex == sender.tag - 1070{
            return
        }
        selectIndex = sender.tag - 1070
        selectBtn.isSelected = false
        
        selectBtn = sender
        selectBtn.isSelected = true
        
        if let delegate = delegate , delegate.responds(to: #selector(GoalSetWeeksSegmentVMDelegate.segment(didSelectItemAt:))){
            delegate.segment?(didSelectItemAt: selectIndex)
        }
    }
}

extension GoalSetWeeksSegmentVM{
    func initUI() {
        let btnWidth = selfWidth/CGFloat(weekDays.count)
        
        for i in 0..<weekDays.count{
            let button = FeedBackButton()
//            button.frame = CGRect.init(x: btnWidth*CGFloat(i), y: 0, width: btnWidth, height: kFitWidth(50))
            button.frame = CGRect(x: btnWidth*CGFloat(i), y: 0, width: btnWidth, height: kFitWidth(50))
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
            
//            addSubview(button)
            insertSubview(button, at: i + 10)
            btnArray.append(button)
            
            if i > 0 {
                let vi = UIView(frame: CGRect(x: kFitWidth(0), y: 0, width: lineWidth, height: kFitWidth(50)))
                vi.backgroundColor = .THEME
//                addSubview(vi)
                button.addSubview(vi)
            }
        }
//        for i in 0..<weekDays.count{
//            if i > 0 {
//                let vi = UIView.init(frame: CGRect.init(x: btnWidth*CGFloat(i)-kFitWidth(0.5), y: 0, width: kFitWidth(1.0), height: kFitWidth(50)))
//                vi.backgroundColor = .THEME
//                addSubview(vi)
//            }
//        }
    }
}
