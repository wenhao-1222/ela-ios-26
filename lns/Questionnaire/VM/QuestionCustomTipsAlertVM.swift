//
//  QuestionCustomTipsAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/2.
//

import Foundation
import UIKit

class QuestionCustomTipsAlertVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
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
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "如何使用这些目标？"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var contentLabelOne : UILabel = {
        let label = UILabel()
        label.text = "· 完成注册后，您的营养目标会自动显示在软件的概览页及饮食日志顶部。\n\n·记录日常饮食时，您可以轻松核对目标，确保饮食选择有助于达成营养摄入目标。"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        return label
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
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

extension QuestionCustomTipsAlertVM{
    func showView() {
        self.isHidden = false
        whiteView.alpha = 0
        self.alpha = 0
        
        bgView.isUserInteractionEnabled = false
        bgView.alpha = 0
        // 1) 蒙层先快后慢，140ms 淡到 0.45（与内容节奏不同步，减少“停顿感”）
        UIView.animate(withDuration: 0.14, delay: 0, options: .curveEaseOut) {
            self.bgView.alpha = 0.15
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
    @objc func nothingToDo(){
        
    }
}

extension QuestionCustomTipsAlertVM{
    func initUI(){
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(contentLabelOne)
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
            make.top.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(18))
        }
        contentLabelOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(62))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(contentLabelOne.snp.bottom).offset(kFitWidth(20))
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

