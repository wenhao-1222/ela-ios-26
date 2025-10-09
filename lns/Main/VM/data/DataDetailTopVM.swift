//
//  DataDetailTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/18.
//

import Foundation
import UIKit

class DataDetailTopVM: UIView {
    
    let selfHeight = kFitWidth(136)
    let btnWidth = (SCREEN_WIDHT-kFitWidth(16)*4)/3
    
    var typeBlock:(()->())?
    var timeBlock:(()->())?
    var addBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
    lazy var bodyTypeButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(16), width: btnWidth, height: kFitWidth(40)))
        btn.setTitle("体重", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.imagePosition(style: .right, spacing: kFitWidth(4))
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(typeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var timeButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: self.bodyTypeButton.frame.maxX+kFitWidth(16), y: kFitWidth(16), width: btnWidth, height: kFitWidth(40)))
        btn.setTitle("3个月", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.imagePosition(style: .right, spacing: kFitWidth(4))
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(timeAction), for: .touchUpInside)
        return btn
    }()
    lazy var addButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: self.timeButton.frame.maxX+kFitWidth(16), y: kFitWidth(16), width: btnWidth, height: kFitWidth(40)))
        btn.setTitle("添加数据", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "data_add_icon_black"), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        return btn
    }()
    lazy var startNumberLabel : UILabel = {
        let lab = UILabel()
        lab.text = "0kg"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var startNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "开始"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var endNumberLabel : UILabel = {
        let lab = UILabel()
        lab.text = "0kg"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var endNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "当前"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    
    lazy var changeNumberButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("0kg", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setImage(UIImage(named: "data_desc_icon"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.imagePosition(style: .left, spacing: kFitWidth(4))
        
        return btn
    }()
    lazy var changeNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "变动"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    
    lazy var bottomGapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        
        return vi
    }()
}

extension DataDetailTopVM{
    @objc func typeAction() {
        if self.typeBlock != nil{
            self.typeBlock!()
        }
    }
    @objc func timeAction() {
        if self.timeBlock != nil{
            self.timeBlock!()
        }
    }
    @objc func addAction() {
        if self.addBlock != nil{
            self.addBlock!()
        }
    }
    func updateUI(startNumber:CGFloat,currentNumber:CGFloat,unit:String) {
        startNumberLabel.text = "\(WHUtils.convertStringToString("\(startNumber)") ?? "")\(unit)"
        endNumberLabel.text = "\(WHUtils.convertStringToString("\(currentNumber)") ?? "")\(unit)"
        
        let change = currentNumber - startNumber
//        changeNumberButton.setTitle("\(abs(change))\(unit)", for: .normal)
        changeNumberButton.setTitle("\(WHUtils.convertStringToString("\(abs(change))") ?? "0")\(unit)", for: .normal)
        let percent = Double(change)/Double(startNumber)*100
        
        if change > 0 {
            changeNumberButton.setImage(UIImage(named: "data_asc_icon"), for: .normal)
            changeNumberLab.text = "变动（+\(WHUtils.convertStringToString(String(format: "%.2f", abs(percent))) ?? "0")%）"
        }else if change < 0 {
            changeNumberButton.setImage(UIImage(named: "data_desc_icon"), for: .normal)
            changeNumberLab.text = "变动（-\(WHUtils.convertStringToString(String(format: "%.2f", abs(percent))) ?? "0")%）"
        }else{
            changeNumberButton.setImage(UIImage(named: "data_ping_icon"), for: .normal)
            changeNumberLab.text = "变动（0%）"
        }
        
    }
    
    func updateTypeButton(type:String) {
        bodyTypeButton.setTitle("\(type)", for: .normal)
        bodyTypeButton.imagePosition(style: .right, spacing: kFitWidth(4))
    }
}

extension DataDetailTopVM{
    func initUI() {
        addSubview(lineView)
        addSubview(bodyTypeButton)
        addSubview(timeButton)
        addSubview(addButton)
        
        addSubview(startNumberLab)
        addSubview(startNumberLabel)
        addSubview(endNumberLab)
        addSubview(endNumberLabel)
        addSubview(changeNumberLab)
        addSubview(changeNumberButton)
        
        addSubview(bottomGapView)
        
        setConstrait()
    }
    
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        startNumberLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(bodyTypeButton)
            make.top.equalTo(kFitWidth(99))
        }
        startNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(bodyTypeButton)
            make.bottom.equalTo(startNumberLab.snp.top).offset(kFitWidth(-8))
        }
        endNumberLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(timeButton)
            make.centerY.lessThanOrEqualTo(startNumberLab)
        }
        endNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(timeButton)
            make.centerY.lessThanOrEqualTo(startNumberLabel)
        }
        changeNumberLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(addButton)
            make.centerY.lessThanOrEqualTo(startNumberLab)
        }
        changeNumberButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(addButton)
            make.centerY.lessThanOrEqualTo(startNumberLabel)
            make.width.equalTo(btnWidth)
        }
        bottomGapView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(8))
        }
    }
}
