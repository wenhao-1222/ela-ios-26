//
//  GuidanceNutritionGoalTipsAlertVM.swift
//  lns
//
//  Created by LNS2 on 2026/4/8.
//


import Foundation
import UIKit

class GuidanceNutritionGoalTipsAlertVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    var nextBlock:(()->())?
    
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        } else {
            // iOS 13 以下没有深色模式，按浅色处理
            return 0.15
        }
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
   override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       super.traitCollectionDidChange(previousTraitCollection)
       if #available(iOS 13.0, *),
          previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
          !isHidden {
           UIView.animate(withDuration: 0.2) {
               self.bgView.alpha = self.targetDimAlpha
           }
       }
   }
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
//        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK//WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "别指望算法能 100%懂你"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var contentLabelOne : UILabel = {
        let label = UILabel()
        label.text = "Elavatine 的营养目标计算公式，是根据大量科学研究及运动员长期实践经验得出的。"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.18)
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        return label
    }()
    lazy var contentLabelTwo : UILabel = {
        let label = UILabel()
        label.text = "但即便如此，我们也必须诚实地告诉你，任何初始目标都很难一次就 100% 贴合你的真实身体需求。你的训练风格、站立、坐立习惯，以及代谢适应能力等，都有可能会在未来影响你所需的摄入量。"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.18)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        return label
    }()
    
    lazy var contentLabelThree : UILabel = {
        let label = UILabel()
        label.text = "但请不必担心，你完全可以通过观察体重增减与体型变化，自己逐渐调整摄入量或营养比例。"
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.18)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        return label
    }()
    
    lazy var contentLabelFour : UILabel = {
        let label = UILabel()
        label.text = "如果你需要更专业的支持，ELA AI 教练也可以帮助你更快地找到最适合你的摄入目标并持续调整。"
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.18)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        return label
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        return vi
    }()
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("我知道了", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
}

extension GuidanceNutritionGoalTipsAlertVM{
    func showView() {
        self.isHidden = false
        bgView.isUserInteractionEnabled = false
        whiteView.alpha = 0
        self.alpha = 0
        bgView.alpha = 0

        // 1) 蒙层先快后慢，140ms 淡到 0.45（与内容节奏不同步，减少“停顿感”）
        UIView.animate(withDuration: 0.14, delay: 0, options: .curveEaseOut) {
            self.bgView.alpha = self.targetDimAlpha//0.85
        }
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
        UIView.animate(withDuration: 0.4, delay: 0.1,options: .curveLinear) {
            self.alpha = 1
        }completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
    }
    
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.alpha = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0.2,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { c in
            self.isHidden = true
        }
    }
    
    @objc func nothingToDo() {
        
    }
}

extension GuidanceNutritionGoalTipsAlertVM{
    func initUI(){
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(contentLabelOne)
        whiteView.addSubview(contentLabelTwo)
        whiteView.addSubview(contentLabelThree)
        whiteView.addSubview(contentLabelFour)
        whiteView.addSubview(lineView)
        whiteView.addSubview(confirmBtn)
    
        setConstrait()
    }
    
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(320))
//            make.height.equalTo(kFitWidth(454))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(27))
        }
        contentLabelOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(67))
        }
        contentLabelTwo.snp.makeConstraints { make in
            make.left.right.equalTo(contentLabelOne)
            make.top.equalTo(contentLabelOne.snp.bottom).offset(kFitWidth(20))
        }
        contentLabelThree.snp.makeConstraints { make in
            make.left.right.equalTo(contentLabelOne)
            make.top.equalTo(contentLabelTwo.snp.bottom).offset(kFitWidth(20))
        }
        contentLabelFour.snp.makeConstraints { make in
            make.left.right.equalTo(contentLabelOne)
            make.top.equalTo(contentLabelThree.snp.bottom).offset(kFitWidth(20))
        }
        
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(contentLabelFour.snp.bottom).offset(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(-48))
            make.height.equalTo(kFitWidth(1))
        }
        confirmBtn.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(lineView.snp.bottom)
        }
    }
}
