//
//  GuidanceExerciseCaloriesRecordTipsAlertVM.swift
//  lns
//
//  Created by LNS2 on 2026/4/8.
//


import Foundation
import UIKit

class GuidanceExerciseCaloriesRecordTipsAlertVM: UIView {
    
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
        lab.text = "运动消耗的陷阱"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var contentLabelOne : UILabel = {
        let label = UILabel()
        label.text = "研究显示，不论是借助手表等设备还是手动记录，运动消耗的热量都很容易出现明显误差。部分腕戴设备研究的中位误差约为 27% 至 93%，各品牌平均绝对误差普遍超过 30%。手动记录同样不稳定，且整体更倾向于高估。现实中，几乎只有实验室间接测热能（运动）和双标水（日常）才能相对的测出热量消耗。[1] [2]"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.18)
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        return label
    }()
    lazy var contentLabelTwo : UILabel = {
        let label = UILabel()
        label.text = "因此，我们更建议大多数人优先记录饮食、体重趋势，以及力量训练频率而不是运动消耗。[3]"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.18)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        return label
    }()
    
    lazy var contentLabelThree : UILabel = {
        let label = UILabel()
        label.text = "[1] Germini et al. (2022), JMIR  \n[2] Shcherbina et al. (2017), JPM\n[3] Dowd et al. (2018), IJBNPA"
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.18)
        label.font = .systemFont(ofSize: 12, weight: .regular)
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

extension GuidanceExerciseCaloriesRecordTipsAlertVM{
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

extension GuidanceExerciseCaloriesRecordTipsAlertVM{
    func initUI(){
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(contentLabelOne)
        whiteView.addSubview(contentLabelTwo)
        whiteView.addSubview(contentLabelThree)
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
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(contentLabelThree.snp.bottom).offset(kFitWidth(20))
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
