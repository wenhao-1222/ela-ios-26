//
//  FoodsAddIconVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/5.
//

import Foundation
import UIKit

enum addicon_status {
    case normal
    case short_add
    case long_right
    case right_normal
    case short_right
}

class FoodsAddIconVM: UIView {
    
    var selfHeight = kFitWidth(50)
    var bottomViewWidth = kFitWidth(30)
    let addIconRectGap = kFitWidth(16)//➕ 四周的间隙
    let iconWidth = kFitWidth(3)
    
    var tapBlock:(()->())?
    
    var status = addicon_status.normal
    
    private var shapeLayerVerLeft = CAShapeLayer()
    private var shapeLayerVerRight = CAShapeLayer()
    private var shapeLayerHorTop = CAShapeLayer()
    private var shapeLayerHorBottom = CAShapeLayer()
    private var shapeLayerRight = CAShapeLayer()
    
    private var arcPathVerLeft = UIBezierPath()
    private var arcPathVerRight = UIBezierPath()
    private var arcPathHorTop = UIBezierPath()
    private var arcPathHorBottom = UIBezierPath()
    private var arcPathHorRight = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfHeight, height: selfHeight))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
//        self.layer.cornerRadius = selfHeight*0.5
//        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        
        initUI()
        
        let tap = FeedBackTapGestureRecognizerHeavy.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: addIconRectGap-kFitWidth(6), y: addIconRectGap-kFitWidth(6), width: bottomViewWidth, height: bottomViewWidth))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        vi.layer.cornerRadius = bottomViewWidth*0.5
        
        return vi
    }()
}

extension FoodsAddIconVM{
    override func draw(_ rect: CGRect) {
        switch status {
        case .normal:
            drawAddIconView()
        case .short_add:
            shortenAddIcon()
        case .long_right:
            longRight()
        case .right_normal:
            break
        case .short_right:
            shortRight()
            break
        }
    }
    func drawAddIconView() {
        self.layer.addSublayer(shapeLayerVerLeft)
        self.layer.addSublayer(shapeLayerVerRight)
        self.layer.addSublayer(shapeLayerHorTop)
        self.layer.addSublayer(shapeLayerHorBottom)
        
        arcPathVerLeft = UIBezierPath()
        arcPathVerLeft.move(to: CGPoint.init(x: selfHeight*0.5, y: selfHeight*0.5))
        arcPathVerLeft.addLine(to: CGPoint.init(x: addIconRectGap, y: selfHeight*0.5))
        
        arcPathVerRight = UIBezierPath()
        arcPathVerRight.move(to: CGPoint.init(x: selfHeight*0.5, y: selfHeight*0.5))
        arcPathVerRight.addLine(to: CGPoint.init(x: selfHeight-addIconRectGap, y: selfHeight*0.5))
        
        arcPathHorTop = UIBezierPath()
        arcPathHorTop.move(to: CGPoint.init(x: selfHeight*0.5, y: selfHeight*0.5))
        arcPathHorTop.addLine(to: CGPoint.init(x: selfHeight*0.5, y: addIconRectGap))
        
        arcPathHorBottom = UIBezierPath()
        arcPathHorBottom.move(to: CGPoint.init(x: selfHeight*0.5, y: selfHeight*0.5))
        arcPathHorBottom.addLine(to: CGPoint.init(x: selfHeight*0.5 , y: selfHeight-addIconRectGap))
        
        shapeLayerVerLeft.path = arcPathVerLeft.cgPath
        shapeLayerVerRight.path = arcPathVerRight.cgPath
        shapeLayerHorTop.path = arcPathHorTop.cgPath
        shapeLayerHorBottom.path = arcPathHorBottom.cgPath
    }
    // 创建动画   显示➕
    func showAddIcon(){
        let shortenAnimation = CABasicAnimation(keyPath: "strokeEnd")
        shortenAnimation.fromValue = 0.0
        shortenAnimation.toValue = 1.0
        shortenAnimation.duration = 0.3
        shortenAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 添加动画到线段layer
        shapeLayerVerLeft.add(shortenAnimation, forKey: "animationKey")
        shapeLayerVerRight.add(shortenAnimation, forKey: "animationKey")
        shapeLayerHorTop.add(shortenAnimation, forKey: "animationKey")
        shapeLayerHorBottom.add(shortenAnimation, forKey: "animationKey")
        
        self.status = .normal
        self.bgView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        self.isUserInteractionEnabled = true
    }
    // 创建缩短动画   缩短➕
    func shortenAddIcon(){
        self.isUserInteractionEnabled = false
        let shortenAnimation = CABasicAnimation(keyPath: "strokeEnd")
        shortenAnimation.fromValue = 1.0
        shortenAnimation.toValue = 0.0
        shortenAnimation.duration = 0.4
        shortenAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 添加动画到线段layer
        shapeLayerVerLeft.add(shortenAnimation, forKey: "shorten")
        shapeLayerVerRight.add(shortenAnimation, forKey: "shorten")
        shapeLayerHorTop.add(shortenAnimation, forKey: "shorten")
        shapeLayerHorBottom.add(shortenAnimation, forKey: "shorten")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.status = .long_right
            self.setNeedsDisplay()
        })
    }
    func longRight() {
        shapeLayerVerLeft.removeFromSuperlayer()
        shapeLayerVerRight.removeFromSuperlayer()
        shapeLayerHorTop.removeFromSuperlayer()
        shapeLayerHorBottom.removeFromSuperlayer()
        self.layer.addSublayer(shapeLayerRight)
        
        arcPathHorRight = UIBezierPath()
        arcPathHorRight.move(to: CGPoint.init(x: addIconRectGap, y: selfHeight*0.5))
        arcPathHorRight.addLine(to: CGPoint.init(x: selfHeight*0.5-kFitWidth(2), y: selfHeight-addIconRectGap))
        arcPathHorRight.addLine(to: CGPoint.init(x: selfHeight-addIconRectGap*1.2, y: addIconRectGap*1.1))
        shapeLayerRight.path = arcPathHorRight.cgPath
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 添加动画到线段layer
        shapeLayerRight.add(animation, forKey: "animationKey")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            TouchGenerator.shared.touchGenerator()
            self.status = .right_normal
            self.bgView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.4)
            UIView.animate(withDuration: 0.14) {
                self.bgView.frame = CGRect.init(x: self.addIconRectGap-kFitWidth(9), y: self.addIconRectGap-kFitWidth(9), width: self.bottomViewWidth+kFitWidth(6), height: self.bottomViewWidth+kFitWidth(6))
            }completion: { t in
                UIView.animate(withDuration: 0.2) {
                    self.bgView.frame = CGRect.init(x: self.addIconRectGap-kFitWidth(6), y: self.addIconRectGap-kFitWidth(6), width: self.bottomViewWidth, height: self.bottomViewWidth)
                }
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            self.status = .short_right
            self.setNeedsDisplay()
        })
    }
    func shortRight() {
        shapeLayerRight.removeFromSuperlayer()
        drawAddIconView()
        showAddIcon()
    }
}

extension FoodsAddIconVM{
    func initUI() {
        addSubview(bgView)
        self.layer.addSublayer(shapeLayerVerLeft)
        self.layer.addSublayer(shapeLayerVerRight)
        self.layer.addSublayer(shapeLayerHorTop)
        self.layer.addSublayer(shapeLayerHorBottom)
//        self.layer.addSublayer(shapeLayerRight)
        
        shapeLayerVerLeft.allowsEdgeAntialiasing = true
        shapeLayerVerLeft.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        shapeLayerVerLeft.lineWidth = iconWidth // 线宽
        shapeLayerVerLeft.lineCap = .round
        
        shapeLayerVerRight.allowsEdgeAntialiasing = true
        shapeLayerVerRight.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        shapeLayerVerRight.lineWidth = iconWidth // 线宽
        shapeLayerVerRight.lineCap = .round
        
        shapeLayerHorTop.allowsEdgeAntialiasing = true
        shapeLayerHorTop.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        shapeLayerHorTop.lineWidth = iconWidth // 线宽
        shapeLayerHorTop.lineCap = .round
        
        shapeLayerHorBottom.allowsEdgeAntialiasing = true
        shapeLayerHorBottom.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        shapeLayerHorBottom.lineWidth = iconWidth // 线宽
        shapeLayerHorBottom.lineCap = .round
        
        shapeLayerRight.allowsEdgeAntialiasing = true
        shapeLayerRight.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        shapeLayerRight.fillColor = nil
        shapeLayerRight.lineWidth = iconWidth // 线宽
        shapeLayerRight.lineCap = .round
        shapeLayerRight.lineJoin = .round
    }
}

extension FoodsAddIconVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.bgView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.4)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.bgView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.bgView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
    }
    
    @objc func tapAction() {
        self.bgView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        self.status = .short_add
        self.setNeedsDisplay()
        
        if self.tapBlock != nil{
            self.tapBlock!()
        }
     }
}
