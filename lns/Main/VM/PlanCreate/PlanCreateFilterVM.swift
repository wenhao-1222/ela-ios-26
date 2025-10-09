//
//  PlanCreateFilterVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/15.
//

import Foundation
import UIKit

class PlanCreateFilterVM: UIView {
    
    let selfHeight = kFitWidth(48)
    var daysNumber = 1
    
    var tapBlock:(()->())?
    var synBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var timeButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("第\(daysNumber)天", for: .normal)
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.imagePosition(style: .right, spacing: kFitWidth(20))
        
        btn.addTarget(self, action: #selector(choiceDaystAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var synButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("同步用餐", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        btn.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.1)), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        btn.isHidden = true
        btn.addTarget(self, action: #selector(syntAction), for: .touchUpInside)
    
        return btn
    }()
}

extension PlanCreateFilterVM{
    @objc func choiceDaystAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    
    @objc func syntAction() {
        if self.synBlock != nil{
            self.synBlock!()
        }
    }
    func setDays(days:Int) {
        self.daysNumber = days + 1
        timeButton.setTitle("第\(daysNumber)天", for: .normal)
    }
    func refreshSynButton(daysNum:Int) {
        if daysNum == 1 {
            synButton.isHidden = true
        }else{
            synButton.isHidden = false
        }
    }
}
extension PlanCreateFilterVM{
    func initUI() {
        addSubview(timeButton)
        addSubview(synButton)
        
        timeButton.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
//            make.width.equalTo(kFitWidth(106))
            make.left.equalTo(kFitWidth(16))
        }
        synButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(timeButton)
            make.width.equalTo(kFitWidth(72))
            make.height.equalTo(kFitWidth(24))
        }
    }
}
