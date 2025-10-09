//
//  PlanDetailDaysVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import UIKit

class PlanDetailDaysVM: UIView {
    
    let selfHeight = kFitWidth(60)
    
    var lastBlock:(()->())?
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var lastButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "back_arrow"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.isHidden = true
        
        btn.addTarget(self, action: #selector(lastAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var dayLabel : YYLabel = {
        let lab = YYLabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var nextButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "plan_detail_arrow_blace_icon"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
}

extension PlanDetailDaysVM{
    @objc func lastAction() {
        if self.lastBlock != nil{
            self.lastBlock!()
        }
        lastButton.isEnabled = false
        nextButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.lastButton.isEnabled = true
            self.nextButton.isEnabled = true
        })
    }
    @objc func nextAction() {
        nextButton.isEnabled = false
        lastButton.isEnabled = false
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//            self.nextButton.isEnabled = true
//            self.lastButton.isEnabled = true
//        })
        if self.nextBlock != nil{
            self.nextBlock!()
        }
    }
    func changeStatus(isUpdate:Bool) {
        nextButton.isHidden = isUpdate
        lastButton.isHidden = isUpdate
    }
}

extension PlanDetailDaysVM{
    func updateUI(currentIndex:Int,totalDay:Int) {
        let currentDay = NSMutableAttributedString.init(string: "\(currentIndex+1)")
        let totalDayString = NSMutableAttributedString.init(string: "/\(totalDay)天")
        
        currentDay.yy_font = .systemFont(ofSize: 24, weight: .medium)
        currentDay.yy_color = .COLOR_GRAY_BLACK_85
        
        totalDayString.yy_font = .systemFont(ofSize: 14, weight: .medium)
        totalDayString.yy_color = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        
        currentDay.append(totalDayString)
        dayLabel.attributedText = currentDay
        
        self.lastButton.isHidden = currentIndex == 0 ? true : false
        self.nextButton.isHidden = (currentIndex == totalDay - 1) ? true : false
    }
}
extension PlanDetailDaysVM{
    func initUI() {
        addSubview(dayLabel)
        addSubview(lastButton)
        addSubview(nextButton)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        dayLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            
        }
        lastButton.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(92))
        }
        nextButton.snp.makeConstraints { make in
            make.right.top.height.equalToSuperview()
            make.width.equalTo(lastButton)
        }
        lineView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(1))
        }
    }
}
