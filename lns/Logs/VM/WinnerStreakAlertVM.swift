//
//  WinnerStreakAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/2.
//

import Foundation
import UIKit

class WinnerStreakAlertVM: UIView {
    
    let selfHeight = kFitWidth(80)
    
    var isShow = false
    var isAnimating = false
    
    let linePathShow = UIBezierPath()
    let linePathHidden = UIBezierPath()
    var shapeLayer = CAShapeLayer()
    
    var currentIndex = 0
    var goalsDataArray = NSMutableArray()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT - kFitWidth(290), y: frame.origin.y, width: kFitWidth(274), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(12), width: kFitWidth(264), height: kFitWidth(72)))
        vi.backgroundColor = WHColor_16(colorStr: "1E5BB8")
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    lazy var topLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var maxStreakDaysLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var closeIcon : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "streak_close_icon")
        img.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(closeSelfAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
}

extension WinnerStreakAlertVM{
    func updateUI(dict:NSDictionary) {
//        DLLog(message: "WinnerStreakAlertVM  updateUI:\(dict)")
        
        if dict.doubleValueForKey(key: "level") < 7{
            iconImgView.setImgLocal(imgName: "streak_icon_\(Int(dict.doubleValueForKey(key: "level")))")
        }else{
            iconImgView.setImgLocal(imgName: "streak_icon_6")
        }
        
        maxStreakDaysLabel.text = "您记录饮食的最高连续记录为 \(dict.stringValueForKey(key: "max_streak")) 天"
        topLabel.text = "距离下个里程碑还差 \(dict.stringValueForKey(key: "gap")) 天"
    }
    @objc func closeSelfAction() {
        if isAnimating || isShow == false{
            return
        }
        isAnimating = true
        isShow = false
        self.setNeedsDisplay()
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
//            self.bgView.frame = CGRect.init(x: kFitWidth(240), y: kFitWidth(12), width: kFitWidth(12), height: kFitWidth(5))
            self.hiddenView()
        } completion: { t in
            self.isHidden = true
            self.isAnimating = false
        }
    }
    func showSelf(){
        if isAnimating {
            return
        }
        if isShow {
            closeSelfAction()
            return
        }
        isShow = true
        isAnimating = true
        self.isHidden = false
        self.setNeedsDisplay()
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.showView()
        } completion: { t in
            self.isAnimating = false
        }
    }
}

extension WinnerStreakAlertVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(iconImgView)
        bgView.addSubview(topLabel)
        bgView.addSubview(maxStreakDaysLabel)
        bgView.addSubview(closeIcon)
        
//        setConstrait()
        hiddenView()
        
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = WHColor_16(colorStr: "1E5BB8").cgColor
        shapeLayer.fillColor = WHColor_16(colorStr: "1E5BB8").cgColor
        self.layer.addSublayer(shapeLayer)
        
        initCgPath()
    }
    private func showView() {
        bgView.frame = CGRect.init(x: 0, y: kFitWidth(12), width: kFitWidth(274), height: kFitWidth(72))
        iconImgView.frame = CGRect.init(x: kFitWidth(12), y: kFitWidth(18), width: kFitWidth(36), height: kFitWidth(36))
        topLabel.frame = CGRect.init(x: kFitWidth(56), y: kFitWidth(20), width: kFitWidth(188), height: kFitWidth(15))
        maxStreakDaysLabel.frame = CGRect.init(x: kFitWidth(56), y: kFitWidth(42), width: kFitWidth(188), height: kFitWidth(14))
        closeIcon.frame = CGRect.init(x: kFitWidth(246), y: kFitWidth(28), width: kFitWidth(16), height: kFitWidth(16))
        
        
    }
    private func hiddenView() {
        bgView.frame = CGRect.init(x: kFitWidth(240), y: kFitWidth(0), width: kFitWidth(30), height: kFitWidth(18))
        iconImgView.frame = CGRect.init(x: kFitWidth(1), y: kFitWidth(1), width: kFitWidth(2), height: kFitWidth(2))
        topLabel.frame = CGRect.init(x: kFitWidth(3), y: kFitWidth(2), width: kFitWidth(6), height: kFitWidth(4))
        maxStreakDaysLabel.frame = CGRect.init(x: kFitWidth(3), y: kFitWidth(7), width: kFitWidth(6), height: kFitWidth(2))
        closeIcon.frame = CGRect.init(x: kFitWidth(10), y: kFitWidth(6), width: kFitWidth(2), height: kFitWidth(2))
    }
    
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(36))
        }
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(56))
            make.top.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-30))
        }
        maxStreakDaysLabel.snp.makeConstraints { make in
            make.left.equalTo(topLabel)
            make.top.equalTo(topLabel.snp.bottom).offset(kFitWidth(6))
            make.right.equalTo(topLabel)
        }
        closeIcon.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.width.height.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}

extension WinnerStreakAlertVM{
    override func draw(_ rect: CGRect) {
        
//        shapeLayer.path = isShow ? linePathShow.cgPath : linePathHidden.cgPath
        shapeLayer.path = linePathShow.cgPath
//        shapeLayer.fillColor = isShow ? WHColor_16(colorStr: "1E5BB8").cgColor : nil
        //设置animation
        let strokeAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        strokeAnimation.fromValue = isShow ? 0 : 1;
        strokeAnimation.toValue = isShow ? 1 : 0;
        strokeAnimation.duration = 0.3;
        DispatchQueue.main.asyncAfter(deadline:.now(), execute: {
            self.shapeLayer.add(strokeAnimation, forKey: "strokeEnd")
        })
    }
    
    func initCgPath()  {
        linePathShow.move(to: CGPoint.init(x: kFitWidth(245), y: kFitWidth(12)))
        linePathShow.addLine(to: CGPoint.init(x: kFitWidth(251), y: 0))
        linePathShow.addLine(to: CGPoint.init(x: kFitWidth(257), y: kFitWidth(12)))
        
//        linePathShow.move(to: CGPoint.init(x: kFitWidth(240), y: kFitWidth(12)))
//        linePathShow.addLine(to: CGPoint.init(x: kFitWidth(246), y: 0))
//        linePathShow.addLine(to: CGPoint.init(x: kFitWidth(252), y: kFitWidth(12)))
    }
}

