//
//  PlanCreateDaysVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import UIKit

class PlanCreateDaysVM: UIView {
    
    let selfHeight = kFitWidth(79)
    let daysGap = (SCREEN_WIDHT-kFitWidth(32))/7
    let circelWidth = kFitWidth(8)
    
    var daysNumber = 1
    // 根据手势移动view的位置
    var touchWhiteViewCenterX = kFitWidth(0)
    
    var edgePanChangeX = kFitWidth(0)
    
    var daysChangeBlock:((Int)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        touchWhiteViewCenterX = daysGap*CGFloat(daysNumber)-circelWidth*0.5
        initUI()
        updateDayNumberLabel()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var iconImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "create_plan_weeks_icon")
        
        return img
    }()
    lazy var titleLabel : YYLabel = {
        let lab = YYLabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var progressBgView : UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(bgViewTapGesture(tapSender: )))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var progressView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(2), y: kFitWidth(2), width: touchWhiteViewCenterX+kFitWidth(8), height: kFitWidth(20)))
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(10)
        vi.clipsToBounds = true
        vi.backgroundColor = .THEME
        return vi
    }()
    lazy var touchWhiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: touchWhiteViewCenterX-circelWidth*0.5, y: kFitWidth(2), width: kFitWidth(20), height: kFitWidth(20)))
        vi.layer.cornerRadius = kFitWidth(10)
        vi.isUserInteractionEnabled = true
//        vi.clipsToBounds = true
        vi.backgroundColor = WHColor_16(colorStr: "F3F3F3")
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture: )))
        vi.addGestureRecognizer(panGesture)
        
        return vi
    }()
    lazy var touchHoleView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(1), y: kFitWidth(1), width: kFitWidth(18), height: kFitWidth(18)))
        vi.layer.cornerRadius = kFitWidth(9)
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        
        return vi
    }()
}

extension PlanCreateDaysVM{
    @objc private func bgViewTapGesture(tapSender:UITapGestureRecognizer){
        DLLog(message: "bgViewTapGesture:\(tapSender.location(in: self.progressBgView).x)")
        let tapPointX = tapSender.location(in: self.progressBgView).x
        if tapPointX < daysGap * 1.5{
            self.daysNumber = 1
        }else if tapPointX < daysGap * 2.5{
            self.daysNumber = 2
        }else if tapPointX < daysGap * 3.5{
            self.daysNumber = 3
        }else if tapPointX < daysGap * 4.5{
            self.daysNumber = 4
        }else if tapPointX < daysGap * 5.5{
            self.daysNumber = 5
        }else if tapPointX < daysGap * 6.5{
            self.daysNumber = 6
        }else{
            self.daysNumber = 7
        }
        
        updateDayNumberLabel()
        updateProgress()
    }
    func updateDaysNumber(daysNumber:Int) {
        self.daysNumber = daysNumber
        updateDayNumberLabel()
        updateProgress()
    }
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {

        // 获取当前手势所在的view
        if let view = gesture.view {
            
            switch gesture.state {
            case .began:
                self.edgePanChangeX = CGFloat(0)
//                touchWhiteViewCenterX = (daysGap+circelWidth*0.5)*CGFloat(3)
            case .changed:
                let translation = gesture.translation(in: view)
                DLLog(message: "translation.x:\(translation.x)-\(touchWhiteViewCenterX)")
                
                if touchWhiteViewCenterX+self.edgePanChangeX + translation.x < kFitWidth(10) + daysGap{
                    return
                }
                
                if touchWhiteViewCenterX+self.edgePanChangeX + translation.x > SCREEN_WIDHT-kFitWidth(32) - kFitWidth(12) {
                    return
                }
                self.edgePanChangeX = self.edgePanChangeX + translation.x
                DLLog(message: "touchWhiteViewCenterX:\(touchWhiteViewCenterX+self.edgePanChangeX)")
                
                
                self.touchWhiteView.center = CGPoint.init(x: touchWhiteViewCenterX+self.edgePanChangeX, y: kFitWidth(12))
                self.progressView.frame = CGRect.init(x: kFitWidth(2), y: kFitWidth(2), width: touchWhiteViewCenterX+self.edgePanChangeX+kFitWidth(7), height: kFitWidth(20))
                self.updateDaysMsg()
                gesture.setTranslation(.zero, in: view)
            case .ended:
                self.updateProgress()
                break
            default:
                break
            }
        }
    }
    func updateDaysMsg() {
        let whiteViewCenterX = self.touchWhiteView.center.x
        
        if whiteViewCenterX < daysGap * 1.5{
            self.daysNumber = 1
        }else if whiteViewCenterX < daysGap * 2.5{
            self.daysNumber = 2
        }else if whiteViewCenterX < daysGap * 3.5{
            self.daysNumber = 3
        }else if whiteViewCenterX < daysGap * 4.5{
            self.daysNumber = 4
        }else if whiteViewCenterX < daysGap * 5.5{
            self.daysNumber = 5
        }else if whiteViewCenterX < daysGap * 6.5{
            self.daysNumber = 6
        }else{
            self.daysNumber = 7
        }
        
        updateDayNumberLabel()
    }
    func updateProgress() {
        UIView.animate(withDuration: 0.2, delay: 0,options: .curveLinear) {
            if self.daysNumber < 7 {
                self.touchWhiteView.center = CGPoint.init(x: self.daysGap*CGFloat(self.daysNumber), y: kFitWidth(12))
                self.progressView.frame = CGRect.init(x: kFitWidth(2), y: kFitWidth(2), width: self.daysGap*CGFloat(self.daysNumber)+kFitWidth(7), height: kFitWidth(20))
                self.touchWhiteViewCenterX = self.daysGap*CGFloat(self.daysNumber)
            }else{
                self.touchWhiteView.center = CGPoint.init(x: SCREEN_WIDHT-kFitWidth(32)-kFitWidth(12), y: kFitWidth(12))
                self.progressView.frame = CGRect.init(x: kFitWidth(2), y: kFitWidth(2), width: SCREEN_WIDHT-kFitWidth(32)-kFitWidth(12)+kFitWidth(7), height: kFitWidth(20))
                self.touchWhiteViewCenterX = SCREEN_WIDHT-kFitWidth(32)-kFitWidth(12)
            }
        }
        
        if self.daysChangeBlock != nil{
            self.daysChangeBlock!(self.daysNumber)
        }
    }
    func updateDayNumberLabel() {
        var stringOne = NSMutableAttributedString.init(string: "计划周期 ")
        var stringTwo = NSMutableAttributedString.init(string: "\(daysNumber)")
        var stringThree = NSMutableAttributedString.init(string: " 天")
        
        stringTwo.yy_color = .THEME
        stringTwo.yy_font = .systemFont(ofSize: 14, weight: .regular)
        
        stringOne.yy_color = .COLOR_GRAY_BLACK_65
        stringOne.yy_font = .systemFont(ofSize: 14, weight: .regular)
        
        stringThree.yy_color = .COLOR_GRAY_BLACK_65
        stringThree.yy_font = .systemFont(ofSize: 14, weight: .regular)
        
        stringOne.append(stringTwo)
        stringOne.append(stringThree)
        
        titleLabel.attributedText = stringOne
    }
}

extension PlanCreateDaysVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(titleLabel)
        addSubview(progressBgView)
        
        for i in 0..<6{
            let vi = UIView.init(frame: CGRect.init(x: daysGap*CGFloat(i+1)-circelWidth*0.5, y: kFitWidth(8), width: circelWidth, height: circelWidth))
            vi.clipsToBounds = true
            vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.15)
            vi.layer.cornerRadius = kFitWidth(4)
            progressBgView.addSubview(vi)
        }
        
        progressBgView.addSubview(progressView)
        progressBgView.addSubview(touchWhiteView)
//        touchWhiteView.addSubview(touchHoleView)
        
        touchWhiteView.addShadow()
        
        setConstrait()
    }
    
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(24))
            make.width.height.equalTo(kFitWidth(16))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(iconImgView)
        }
        progressBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(24))
            make.bottom.equalToSuperview()
        }
    }
}
