//
//  GuideAddFirstFoodsAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/12.
//


import Foundation
import UIKit

class GuideAddFirstFoodsAlertVM: UIView {
    
    let selfWidth = kFitWidth(152)
    let selfHeight = kFitWidth(60)
    
    var isShow = false
    var isAnimating = false
    
    var originFrame = CGRect()
    
    let linePathShow = UIBezierPath()
    let linePathHidden = UIBezierPath()
    var shapeLayer = CAShapeLayer()
    private var outsideTap: UITapGestureRecognizer?
    
    var currentIndex = 0
    var goalsDataArray = NSMutableArray()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT - kFitWidth(160), y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        originFrame = self.frame
        
        self.frame = CGRect.init(x: SCREEN_WIDHT*2-kFitWidth(160), y: frame.origin.y, width: selfWidth, height: selfHeight)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: selfWidth, height: kFitWidth(55)))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.8)
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var contentLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
//        lab.text = "点这里，记录今天吃的\n第一样食物"
        lab.setLineHeight(textString: "点这里，记录今天吃的第一样食物",lineHeight: kFitWidth(18))
        return lab
    }()
}

extension GuideAddFirstFoodsAlertVM{
    @objc func closeSelfAction() {
        if isAnimating || isShow == false{
            return
        }
        isAnimating = true
        isShow = false
        if let tap = outsideTap {
            tap.view?.removeGestureRecognizer(tap)
            outsideTap = nil
        }

        self.setNeedsDisplay()
        self.shapeLayer.isHidden = true
        self.shapeLayer.path = nil
        linePathShow.removeAllPoints()
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
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
        self.frame = self.originFrame
        isShow = true
        isAnimating = true
        self.isHidden = false
        self.setNeedsDisplay()
        if outsideTap == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(outsideTapAction))
            tap.delegate = self
            tap.cancelsTouchesInView = false
            (UIApplication.shared.delegate as? AppDelegate)?.getKeyWindow().addGestureRecognizer(tap)
            outsideTap = tap
        }
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.showView()
        } completion: { t in
            self.isAnimating = false
            self.initCgPath()
            self.setNeedsDisplay()
        }
    }
}

extension GuideAddFirstFoodsAlertVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(contentLabel)
        
        hiddenView()
        
        shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.8).cgColor
//        shapeLayer.fillColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.8).cgColor
        if let color = bgView.backgroundColor {
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.fillColor = color.cgColor
        }
        self.layer.addSublayer(shapeLayer)
        
//        initCgPath()
    }
    private func showView() {
        bgView.frame = CGRect.init(x: 0, y: kFitWidth(0), width: selfWidth, height: kFitWidth(55))
        contentLabel.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: kFitWidth(120), height: kFitWidth(55))
        
    }
    private func hiddenView() {
        bgView.frame = CGRect.init(x: kFitWidth(240), y: kFitWidth(0), width: kFitWidth(30), height: kFitWidth(18))
        contentLabel.frame = CGRect.init(x: kFitWidth(1), y: kFitWidth(1), width: kFitWidth(2), height: kFitWidth(2))
    }
}

extension GuideAddFirstFoodsAlertVM{
    override func draw(_ rect: CGRect) {
        shapeLayer.path = linePathShow.cgPath
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
        let offsetX = kFitWidth(5)
        linePathShow.move(to: CGPoint(x: kFitWidth(112) + offsetX, y: kFitWidth(55)))
        linePathShow.addLine(to: CGPoint(x: kFitWidth(120) + offsetX, y: kFitWidth(60)))
        linePathShow.addLine(to: CGPoint(x: kFitWidth(128) + offsetX, y: kFitWidth(55)))
//        linePathShow.addLine(to: CGPoint(x: kFitWidth(120), y: kFitWidth(60))
//         linePathShow.addLine(to: CGPoint(x: kFitWidth(126), y: kFitWidth(55))
//        linePathShow.addQuadCurve(to: CGPoint(x: kFitWidth(126), y: kFitWidth(55)),
//                                 controlPoint: CGPoint(x: kFitWidth(120), y: kFitWidth(68)))
        
        
//        linePathShow.move(to: CGPoint(x: kFitWidth(110), y: kFitWidth(55)))
//        linePathShow.addQuadCurve(to: CGPoint(x: kFitWidth(130), y: kFitWidth(55)),
//                                 controlPoint: CGPoint(x: kFitWidth(120), y: kFitWidth(67)))
    }
}

extension GuideAddFirstFoodsAlertVM:UIGestureRecognizerDelegate{
    @objc private func outsideTapAction() {
        closeSelfAction()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self)
        return !self.point(inside: point, with: nil)
    }
}
