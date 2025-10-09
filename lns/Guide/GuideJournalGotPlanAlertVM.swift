//
//  GuideJournalGotPlanAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/1.
//

import Foundation
import UIKit

class GuideJournalGotPlanAlertVM: UIView {
    
    let originY = kFitWidth(182) + statusBarHeight + 44
    let addBtnOriginY = statusBarHeight + 44 + LogsNaturalGoalVM().selfHeight + kFitWidth(12)
    
    var showNum = 1
    
    private let lineLayer = CAShapeLayer()
    private var linePath = UIBezierPath()
    private let lineLayerTrangle = CAShapeLayer()
    private var linePathTrangle = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        let is_guide = UserDefaults.standard.value(forKey: guide_logs_plan) as? String ?? ""
        
        if is_guide.count > 0 || Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2025-02-01",formatter: "yyyy-MM-dd"){
            self.isHidden = true
        }
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var createPlanButton: GJVerButton = {
        let btn = GJVerButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: originY, width: kFitWidth(343), height: kFitWidth(40))
        btn.setTitle("免费获取计划", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setImage(UIImage(named: "logs_create_plan_icon"), for: .normal)
        btn.imagePosition(style: .left, spacing: kFitWidth(6))
        btn.backgroundColor = .THEME
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
//        btn.isHidden = true
        
        return btn
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        
        var titleAttr = NSMutableAttributedString(string: "如需要获取新的营养目标/详细饮食计划点击这里")
        titleAttr.yy_font = .systemFont(ofSize: 14)
        titleAttr.yy_color = .white
        
        lab.attributedText = titleAttr
//
//        var titleAttr = NSMutableAttributedString(string: "")
//        let step1 = NSMutableAttributedString(string: "，添加用餐食物")
//        
//        titleAttr = WHUtils().createAttributedStringWithImage(image: UIImage(named: "tutorials_add_icon")!, text: "点击")
////        titleAttr = WHUtils().createAttributedStringWithImage(image: UIImage(named: "main_edit_icon")!, text: "设定营养目标：点击")
//        
//        titleAttr.yy_font = .systemFont(ofSize: 14)
//        step1.yy_font = .systemFont(ofSize: 14)
//        
//        titleAttr.yy_color = .white
//        step1.yy_color = .white
//        
//        titleAttr.append(step1)
//        lab.attributedText = titleAttr
        
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.isUserInteractionEnabled = true
        
        
        return lab
    }()
    lazy var borderView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_25//WHColor_ARC()
//        vi.layer.cornerRadius = kFitWidth(8)
//        vi.clipsToBounds = true
        return vi
    }()
    lazy var addBottomView: UIView = {
        let vi = UIView()
        vi.layer.borderColor = UIColor.THEME.cgColor
        vi.layer.borderWidth = kFitWidth(1)
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        vi.isHidden = true
        return vi
    }()
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "logs_add_icon_theme"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.isEnabled = false
        btn.isHidden = true
        
        return btn
    }()
    lazy var bottomeTipsLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(120), y: SCREEN_HEIGHT-WHUtils().getTabbarHeight()-kFitWidth(40), width: SCREEN_WIDHT - kFitWidth(240), height: kFitWidth(36)))
//        lab.text = "点击任意位置可关闭"
        lab.text = "我知道啦"
        lab.textColor = .white//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        lab.layer.borderWidth = kFitWidth(0.5)
        lab.layer.borderColor = UIColor.white.cgColor
        lab.layer.cornerRadius = kFitWidth(8)
        lab.clipsToBounds = true
        lab.backgroundColor = .COLOR_GRAY_BLACK_25
        
        lab.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(doneClick))
        lab.addGestureRecognizer(tap)
        
        
//        lab.isHidden = true
        return lab
    }()
    lazy var blurEffect: UIBlurEffect = {
        let vi = UIBlurEffect(style:.extraLight)
        return vi
    }()
    lazy var blurEffectView: UIVisualEffectView = {
        let vi = UIVisualEffectView(effect: blurEffect)
        vi.alpha = 0.6//0.73
        return vi
    }()
}

extension GuideJournalGotPlanAlertVM{
    @objc func doneClick() {
        self.isHidden = true
//        if self.showNum == 1{
//            addButton.isHidden = false
//            addBottomView.isHidden = false
//            createPlanButton.isHidden = true
////            bottomeTipsLabel.isHidden = true
//           
//            var titleAttr = NSMutableAttributedString(string: "")
//            let step1 = NSMutableAttributedString(string: "，记录用餐食物")
//            
//            titleAttr = WHUtils().createAttributedStringWithImage(image: UIImage(named: "tutorials_add_icon")!, text: "点击")
//    //        titleAttr = WHUtils().createAttributedStringWithImage(image: UIImage(named: "main_edit_icon")!, text: "设定营养目标：点击")
//            
//            titleAttr.yy_font = .systemFont(ofSize: 14)
//            step1.yy_font = .systemFont(ofSize: 14)
//            
//            titleAttr.yy_color = .white
//            step1.yy_color = .white
//            
//            titleAttr.append(step1)
//            tipsLabel.attributedText = titleAttr
//            tipsLabel.snp.remakeConstraints { make in
//                make.right.equalTo(addBottomView.snp.left).offset(kFitWidth(-5))
//                make.centerY.lessThanOrEqualTo(addBottomView)
//            }
//            
//            showNum = 2
//        }else{
//            self.isHidden = true
//        }
        UserDefaults.standard.setValue("1", forKey: guide_logs_plan)
    }
}
extension GuideJournalGotPlanAlertVM{
    func initUI() {
        addSubview(blurEffectView)
        addSubview(borderView)
        addSubview(createPlanButton)
        addSubview(tipsLabel)
        
        addSubview(addBottomView)
        addSubview(addButton)
        addSubview(bottomeTipsLabel)
        
        setConstrait()
        initLayer()
        borderView.addDashedBorder(borderColor: .white, dashPattern: [5,5])
    }
    
    func setConstrait()  {
//        tipsLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(createPlanButton.snp.bottom).offset(kFitWidth(5))
//        }
        blurEffectView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
//            make.bottom.equalTo(self.createPlanButton.snp.top)
        }
        borderView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(tipsLabel)
            make.left.top.equalTo(tipsLabel).offset(kFitWidth(-8))
            make.right.bottom.equalTo(tipsLabel).offset(kFitWidth(8))
        }
        tipsLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(createPlanButton.snp.bottom).offset(kFitWidth(105))
        }
        addButton.snp.makeConstraints { make in
            make.top.equalTo(addBtnOriginY)
            make.right.equalTo(kFitWidth(-8))
            make.width.equalTo(kFitWidth(52))
            make.height.equalTo(kFitWidth(50))
        }
        addBottomView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(addButton)
            make.width.height.equalTo(kFitWidth(36))
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawArrowDash()
    }
    func initLayer() {
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(lineLayerTrangle)
        
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = kFitWidth(1) // 线宽
        lineLayer.lineDashPattern = [5,2]
        
        lineLayerTrangle.strokeColor = UIColor.white.cgColor
        lineLayerTrangle.fillColor = UIColor.white.cgColor
        lineLayerTrangle.lineWidth = kFitWidth(0.2) // 线宽
    }
    func drawArrowDash() {
        let firstPoint = CGPoint.init(x: borderView.frame.midX - borderView.frame.width*0.25, y: borderView.frame.minY)
        let endPoint = CGPoint.init(x: createPlanButton.frame.midX + kFitWidth(40), y: createPlanButton.frame.maxY+kFitWidth(5))
        let controlPoint1 = CGPoint.init(x: firstPoint.x + (endPoint.x - firstPoint.x)*0.8,
                                         y: firstPoint.y - (firstPoint.y - endPoint.y)*0.1)
        linePath = UIBezierPath()
        linePathTrangle = UIBezierPath()
        
        linePath.move(to: firstPoint)
        linePath.addQuadCurve(to: endPoint, controlPoint: controlPoint1)
        lineLayer.path = linePath.cgPath
        
        let arcPoints = WHUtils().getArrowPoint(fPoint: CGPoint.init(x: endPoint.x-2, y: endPoint.y+15),
                                      tPoint: CGPoint.init(x: endPoint.x, y: endPoint.y+4))
        
        linePathTrangle.move(to: arcPoints.0)
        linePathTrangle.addLine(to: arcPoints.2)
        linePathTrangle.addLine(to: arcPoints.1)
        linePathTrangle.addLine(to: CGPoint.init(x: arcPoints.2.x, y: arcPoints.2.y-2))
        linePathTrangle.addLine(to: arcPoints.0)
        
        let shortenAnimation = CABasicAnimation(keyPath: "strokeEnd")
        shortenAnimation.fromValue = 0.0
        shortenAnimation.toValue = 1.0
        shortenAnimation.duration = 0.7
        shortenAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 添加动画到线段layer
        lineLayer.add(shortenAnimation, forKey: "animationKey")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.lineLayerTrangle.path = self.linePathTrangle.cgPath
            shortenAnimation.duration = 0.3
            self.lineLayerTrangle.add(shortenAnimation, forKey: "animationKey")
        })
    }
}
