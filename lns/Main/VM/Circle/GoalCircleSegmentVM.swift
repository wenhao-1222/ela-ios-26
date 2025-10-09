//
//  GoalCircleSegmentVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/18.
//


import Foundation
import UIKit


@objc public protocol GoalCircleSegmentVMDelegate: NSObjectProtocol {
    /// Called when clicked
    @objc optional func segment(didSelectItemAt index: Int)
}


class GoalCircleSegmentVM: UIView {
    
    var selfWidth = kFitWidth(58)*6
    let selfHeight = kFitWidth(50)
    let lineWidth = kFitWidth(1)//1.0 / UIScreen.main.scale
    
    var selectIndex = 0
    var btnArray:[UIButton] = [UIButton]()
    var selectBtn = UIButton()
    
    open weak var delegate: GoalCircleSegmentVMDelegate?
    
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
//        addSubview(todayLabel)
//        todayLabel.addClipCorner(corners: [.topLeft,.topRight,.bottomRight], radius: kFitWidth(8))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var weekDays: NSMutableArray = {
        return ["一","二","三","四","五","六","七"]
    }()
    private let defaultWeekDays = ["一","二","三","四","五","六","七"]
}

extension GoalCircleSegmentVM{
    @objc func buttonTapAction(sender:UIButton) {
        if selectIndex == sender.tag - 1070{
            return
        }
        selectIndex = sender.tag - 1070
        selectBtn.isSelected = false
        
        selectBtn = sender
        selectBtn.isSelected = true
        
        if let delegate = delegate , delegate.responds(to: #selector(GoalCircleSegmentVMDelegate.segment(didSelectItemAt:))){
            delegate.segment?(didSelectItemAt: selectIndex)
        }
    }
    func updateButton(tag:String) {
        if weekDays.count > selectIndex {
            if tag.count > 0 {
                weekDays[selectIndex] = tag
            } else {
                let defaultTitle = selectIndex < defaultWeekDays.count ? defaultWeekDays[selectIndex] : ""
                weekDays[selectIndex] = defaultTitle
            }
        }
        if tag.count > 0 {
            selectBtn.setTitle(tag, for: .normal)
        }else{
//            selectBtn.setTitle(weekDays[selectIndex]as? String ?? "", for: .normal)
            let defaultTitle = selectIndex < defaultWeekDays.count ? defaultWeekDays[selectIndex] : ""
            selectBtn.setTitle(defaultTitle, for: .normal)
        }
    }
}

extension GoalCircleSegmentVM{
    func updateCircleDays(daysNumber:Int, selectedIndex:Int? = nil,tags:[String]? = nil) {
        weekDays.removeAllObjects()
        btnArray.removeAll()
        for vi in self.subviews{
            vi.removeFromSuperview()
        }
        for i in 0..<daysNumber{
            if let tagArr = tags, i < tagArr.count, tagArr[i].count > 0 {
                weekDays.add(tagArr[i])
            } else {
                switch i {
                case 0:
                    weekDays.add("一")
                case 1:
                    weekDays.add("二")
                case 2:
                    weekDays.add("三")
                case 3:
                    weekDays.add("四")
                case 4:
                    weekDays.add("五")
                case 5:
                    weekDays.add("六")
                default:
                    weekDays.add("七")
                    
                }
            }
        }
        initUI()
       
        let index = selectedIndex ?? 0
        setSelectIndex(index: index)
    }
    func setSelectIndex(index:Int){
        guard index >= 0 && index < btnArray.count else { return }
        selectBtn.isSelected = false
        selectBtn = btnArray[index]
        selectBtn.isSelected = true
        selectIndex = index
    }
    func initUI() {
        let btnWidth = selfWidth/CGFloat(weekDays.count)
        for i in 0..<weekDays.count{
            let button = FeedBackButton()
            button.frame = CGRect.init(x: btnWidth*CGFloat(i), y: 0, width: btnWidth, height: kFitWidth(50))
            button.setTitle("\(weekDays[i]as? String ?? "")", for: .normal)
            button.setTitleColor(.THEME, for: .normal)
            button.setTitleColor(.white, for: .selected)
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
            }
            addSubview(button)
            btnArray.append(button)
            
            if i > 0 {
                let vi = UIView(frame: CGRect(x: kFitWidth(0), y: 0, width: lineWidth, height: kFitWidth(50)))
                vi.backgroundColor = .THEME
                button.addSubview(vi)
            }
        }
    }
}
