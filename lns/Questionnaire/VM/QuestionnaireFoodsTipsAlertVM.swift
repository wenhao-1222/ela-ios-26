//
//  QuestionnaireFoodsTipsAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/6/12.
//

import Foundation
import UIKit

class QuestionnaireFoodsTipsAlertVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//.COLOR_GRAY_BLACK_85
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
        lab.text = "为什么找不到我想要的食物？"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var contentLabelOne : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        let attr = NSMutableAttributedString(string: "为了确保准确性，我们筛选掉了不符合计划的食物。")
        
        attr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        attr.yy_color = .COLOR_GRAY_BLACK_65
        label.attributedText = attr
        
        return label
    }()
    lazy var contentLabelTwo : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        let attr = NSMutableAttributedString(string: "如需添加更多食物，请在")
        let att = NSMutableAttributedString(string: "激活计划后前往日志添加。")
        
        attr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        attr.yy_color = .COLOR_GRAY_BLACK_65
        att.yy_font = .systemFont(ofSize: 14, weight: .medium)
        att.yy_color = .COLOR_GRAY_BLACK_85
        
        attr.append(att)
        label.attributedText = attr
        
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

extension QuestionnaireFoodsTipsAlertVM{
    func showView() {
        self.isHidden = false
        whiteView.alpha = 0
//        self.alpha = 0
        bgView.alpha = 0
        bgView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut) {
            self.whiteView.alpha = 1
            self.bgView.alpha = 0.25
        }completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
//        UIView.animate(withDuration: 0.4, delay: 0.1,options: .curveLinear) {
//            self.alpha = 1
//        }
    }
    
    @objc func hiddenView() {
//        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
////            self.alpha = 0
//            self.bgView.alpha = 0
//        }
        UIView.animate(withDuration: 0.3, delay: 0.2,options: .curveLinear) {
            self.whiteView.alpha = 0
            self.bgView.alpha = 0
        }completion: { c in
            self.isHidden = true
        }
    }
    
    @objc func nothingToDo() {
        
    }
}

extension QuestionnaireFoodsTipsAlertVM{
    func initUI(){
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(contentLabelOne)
        whiteView.addSubview(contentLabelTwo)
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
        contentLabelTwo.snp.makeConstraints { make in
            make.left.right.equalTo(contentLabelOne)
            make.top.equalTo(contentLabelOne.snp.bottom).offset(kFitWidth(8))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(contentLabelTwo.snp.bottom).offset(kFitWidth(20))
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

