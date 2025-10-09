//
//  QuestionnaireBodyFatItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation
import UIKit

class QuestionnaireBodyFatItemVM: UIView {
    
    var selfHeight = kFitWidth(179)
    var isRight = false
    var isSelect = false
    
    var numberLabelWidth = kFitWidth(20)
    var numberLabelWidthSelect = kFitWidth(20)
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let feedbackWeight: CGFloat = 0.9
    private var lastFeedbackTime: TimeInterval = 0
    private let minimumFeedbackInterval: TimeInterval = 0.1

    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT*0.5, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
//        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        
        return img
    }()
    
    //body_fat_img_cover
    
    lazy var coverViewForLabel : UIImageView = {
        let layerView = UIImageView()
        layerView.setImgLocal(imgName: "body_fat_img_cover")
        layerView.frame = CGRect(x: 0, y: kFitWidth(104), width: kFitWidth(164), height: kFitWidth(60))
        return layerView
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "体脂肪"
        
        return lab
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 20, weight: .medium)
//        lab.text = "体脂肪"
        lab.textAlignment = .left
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var coverView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()
    lazy var selectImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "body_fat_select_icon")
        
        return img
    }()
    lazy var rectView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderColor = UIColor.THEME.cgColor
        vi.layer.borderWidth = kFitWidth(1)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension QuestionnaireBodyFatItemVM{
    @objc func tapAction() {
        if self.isSelect{
            return
        }
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension QuestionnaireBodyFatItemVM{
    func refreshForRight() {
        imgView.frame = CGRect.init(x: SCREEN_WIDHT*0.5-kFitWidth(16)-kFitWidth(164), y: kFitWidth(0), width: kFitWidth(164), height: kFitWidth(164))
        rectView.frame =  imgView.frame
    }
    func updateUI(dict:NSDictionary,isRight:Bool) {
        imgView.setImgLocal(imgName: "\(dict["imgUrl"]as? String ?? "")")
        numberLabel.text = "\(dict["data"]as? String ?? "")"
        self.isRight = isRight
        
        numberLabelWidth = WHUtils().getWidthOfString(string: "\(dict["data"]as? String ?? "")", font: UIFont().DDInFontMedium(fontSize: 20), height: kFitWidth(28))
        numberLabelWidthSelect = WHUtils().getWidthOfString(string: "\(dict["data"]as? String ?? "")", font: UIFont().DDInFontMedium(fontSize: 28), height: kFitWidth(28))
        
        if isRight{
            refreshForRight()
        }
    }
    func updateUIIsSelected(isSelect: Bool) {
        if isSelect {
            // ===== 更自然的“按压→回弹”参数（只改时间与系数） =====
            // 整体时长控制
            let mainDuration: TimeInterval   = 0.78   // 主体弹性总时长
            let checkDuration: TimeInterval  = 0.54   // 勾选小圆弹出时长

            // 回弹系数（按压→峰→谷→峰→谷→微峰→落定），幅度逐次衰减
            let valley0: CGFloat = 0.965  // 先“按压”一下（<1）
            let peak1:  CGFloat = 1.070  // 第一次回弹峰
            let valley1: CGFloat = 0.985  // 第一次回弹谷
            let peak2:  CGFloat = 1.028  // 第二次回弹峰
            let valley2: CGFloat = 0.996  // 第二次回弹谷
            let peak3:  CGFloat = 1.008  // 微小回弹峰
            let settle: CGFloat = 1.000  // 落定

            // 勾选抖动幅度（更克制）
            let checkPeak:   CGFloat = 1.08
            let checkValley: CGFloat = 0.96

            // —— 目标几何（保持你现有逻辑）—— //
            let leftGap = isRight ? (SCREEN_WIDHT*0.5 - kFitWidth(24) - kFitWidth(148)) : kFitWidth(24)
            let finalFrame = CGRect(x: leftGap, y: kFitWidth(8), width: kFitWidth(148), height: kFitWidth(148))

            [imgView, coverView, coverViewForLabel, titleLab, numberLabel, selectImgView].forEach {
                $0.layer.removeAllAnimations()
                $0.transform = .identity
            }

            titleLab.text = "已选择体脂肪"
            imgView.layer.cornerCurve = .continuous
            imgView.layer.cornerRadius = kFitWidth(8)

            coverView.isHidden = false
            coverViewForLabel.isHidden = false
            let firstGap = kFitWidth(4)
            UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseInOut, animations: {
//                self.imgView.frame = CGRect(x: leftGap+firstGap, y: kFitWidth(8)+firstGap, width: kFitWidth(148)-firstGap*2, height: kFitWidth(148)-firstGap*2)
                self.coverViewForLabel.alpha = 1
                self.coverView.alpha = 0
            })

            // 选中态文案/数值目标
            let targetTitleFrame = CGRect(x: kFitWidth(48), y: kFitWidth(52), width: kFitWidth(200), height: kFitWidth(12))
            let targetNumberFrame = CGRect(
                x: (kFitWidth(148) - self.numberLabelWidthSelect) * 0.5,
                y: kFitWidth(70),
                width: self.numberLabelWidthSelect,
                height: kFitWidth(28)
            )

            // 勾选初始
            selectImgView.alpha = 0
            selectImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            numberLabel.font = .systemFont(ofSize: 28, weight: .medium)

            // ===== 主体：先“按压”再回弹多次（duang duang duang）=====
            UIView.animateKeyframes(withDuration: mainDuration,
                                    delay: 0,
                                    options: [.calculationModeCubic, .beginFromCurrentState, .allowUserInteraction]) {

                // 0%~16%：按压 (0.965)
                UIView.addKeyframe(withRelativeStartTime: 0.00, relativeDuration: 0.04) {
                    self.imgView.transform = CGAffineTransform(scaleX: valley0, y: valley0)
                    self.coverView.alpha = 0
                    self.coverViewForLabel.alpha = 1
                    self.titleLab.frame = targetTitleFrame
                    self.numberLabel.frame = targetNumberFrame
                }
                // 16%~38%：回弹到峰1 (1.070) + 同步文案布局变更
                UIView.addKeyframe(withRelativeStartTime: 0.04, relativeDuration: 0.18) {
                    self.imgView.transform = CGAffineTransform(scaleX: peak1, y: peak1)
                    self.coverView.alpha = 1
                    self.coverViewForLabel.alpha = 0
                    self.titleLab.frame = targetTitleFrame
                    self.numberLabel.frame = targetNumberFrame
                }
                // 38%~58%：落到谷1 (0.985)
                UIView.addKeyframe(withRelativeStartTime: 0.22, relativeDuration: 0.16) {
                    self.imgView.transform = CGAffineTransform(scaleX: valley1, y: valley1)
                }
                // 58%~76%：峰2 (1.028)
                UIView.addKeyframe(withRelativeStartTime: 0.38, relativeDuration: 0.14) {
                    self.imgView.transform = CGAffineTransform(scaleX: peak2, y: peak2)
                }
                // 76%~90%：谷2 (0.996)
                UIView.addKeyframe(withRelativeStartTime: 0.52, relativeDuration: 0.1) {
                    self.imgView.transform = CGAffineTransform(scaleX: valley2, y: valley2)
                }
                // 90%~96%：微峰 (1.008)
                UIView.addKeyframe(withRelativeStartTime: 0.62, relativeDuration: 0.06) {
                    self.imgView.transform = CGAffineTransform(scaleX: peak3, y: peak3)
                }
                // 96%~100%：落定 (1.000)
                UIView.addKeyframe(withRelativeStartTime: 0.68, relativeDuration: 0.1) {
                    self.imgView.transform = CGAffineTransform(scaleX: settle, y: settle)
                }
            } completion: { _ in
                self.coverViewForLabel.isHidden = true
            }

            // ===== 勾选“圆圈”：更克制的弹入（先轻压再回弹）=====
            UIView.animateKeyframes(withDuration: checkDuration,
                                    delay: 0.06,
                                    options: [.calculationModeCubic, .beginFromCurrentState, .allowUserInteraction]) {
                // 0%~35%：到峰
                UIView.addKeyframe(withRelativeStartTime: 0.00, relativeDuration: 0.35) {
                    self.selectImgView.alpha = 1
                    self.selectImgView.transform = CGAffineTransform(scaleX: checkPeak, y: checkPeak)
                }
                // 35%~70%：回到谷
                UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.35) {
                    self.selectImgView.transform = CGAffineTransform(scaleX: checkValley, y: checkValley)
                }
                // 70%~100%：落定
                UIView.addKeyframe(withRelativeStartTime: 0.70, relativeDuration: 0.30) {
                    self.selectImgView.transform = .identity
                }
            }

            // 最终几何（保持你的 finalFrame）
            UIView.animate(withDuration: 0.10, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.imgView.frame = finalFrame
            }

        }else {
            // 还原未选中（保持干净）
            [imgView, coverView, coverViewForLabel, titleLab, numberLabel, selectImgView].forEach {
                $0.layer.removeAllAnimations()
                $0.transform = .identity
            }

            imgView.layer.cornerCurve = .continuous
            imgView.layer.cornerRadius = kFitWidth(12)
            numberLabel.font = .systemFont(ofSize: 20, weight: .medium)

            if isRight {
                self.refreshForRight()
            } else {
                imgView.frame = CGRect(x: kFitWidth(16), y: 0, width: kFitWidth(164), height: kFitWidth(164))
            }

            coverViewForLabel.isHidden = false
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
                self.coverView.alpha = 0
                self.coverViewForLabel.alpha = 1
                self.titleLab.frame = CGRect(x: kFitWidth(16), y: kFitWidth(120), width: kFitWidth(200), height: kFitWidth(12))
                self.numberLabel.frame = CGRect(x: kFitWidth(16), y: kFitWidth(135), width: self.numberLabelWidth, height: kFitWidth(20))
                self.selectImgView.alpha = 0
            } completion: { _ in
                self.titleLab.text = "体脂肪"
                self.coverView.isHidden = true
                self.selectImgView.alpha = 1
            }
        }
    }
}

extension QuestionnaireBodyFatItemVM{
    func initUI() {
        addSubview(rectView)
        addSubview(imgView)
        imgView.addSubview(coverViewForLabel)
        imgView.addSubview(coverView)
        imgView.addSubview(titleLab)
        imgView.addSubview(numberLabel)
        coverView.addSubview(selectImgView)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.frame = CGRect.init(x: kFitWidth(16), y: 0, width: kFitWidth(164), height: kFitWidth(164))
        titleLab.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(120), width: kFitWidth(200), height: kFitWidth(12))
        numberLabel.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(135), width: kFitWidth(200), height: kFitWidth(20))
        rectView.frame =  CGRect.init(x: kFitWidth(16), y: 0, width: kFitWidth(164), height: kFitWidth(164))
        
        selectImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
            make.top.equalTo(kFitWidth(49))
            make.width.height.equalTo(kFitWidth(16))
        }
        coverView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
    }
}

extension QuestionnaireBodyFatItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
//        let scale: CGFloat = 0.99
//        UIView.animate(withDuration: 0.1) {
//            self.transform = CGAffineTransform(scaleX: scale, y: scale)
//        }
        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
//        UIView.animate(withDuration: 0.1) {
//            self.transform = .identity
//        }
        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
            triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
            tapAction()
        }
    }
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//        UIView.animate(withDuration: 0.1) {
//            self.transform = .identity
//        }
//    }
    private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
        let now = Date().timeIntervalSince1970
        guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
        generator.impactOccurred(intensity: intensity)
        lastFeedbackTime = now
    }
}
