//
//  QuestionnairePlanNameAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/1.
//

import Foundation
import UIKit

class QuestionnairePlanNameAlertVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
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
        lab.text = "如何查看并使用计划？"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var contentLabelOne : UILabel = {
        let label = UILabel()
        label.text = "在完成注册后，您的定制营养目标和饮食计划将被保存在软件的“计划列表”中，如需："
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        return label
    }()
    lazy var contentLabelTwo : UILabel = {
        let label = UILabel()
//        label.text = "1. 查看您的计划：访问“计划列表”以浏览所有为您量身定制的饮食计划。"
//        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
//        label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        var tiAttr = NSMutableAttributedString(string: "1. 查看您的计划：")
        var contAttr = NSMutableAttributedString(string: "访问“我的计划”以浏览所有为您量身定制的饮食计划。")
        
        tiAttr.yy_color = .COLOR_GRAY_BLACK_85
        tiAttr.yy_font = .systemFont(ofSize: 14, weight: .medium)
        contAttr.yy_color = .COLOR_GRAY_BLACK_65
        contAttr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        
        tiAttr.append(contAttr)
        label.attributedText = tiAttr
        
        return label
    }()
    
    lazy var contentLabelThree : UILabel = {
        let label = UILabel()
//        label.text = "2. 执行计划：选中您想要开始的计划，并点击“执行计划”按钮，将该计划导入到您的饮食日志中，以便跟踪和管理您的饮食。"
//        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
//        label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        
        var tiAttr = NSMutableAttributedString(string: "2. 执行计划：")
        var contAttr = NSMutableAttributedString(string: "选中您想要开始的计划，并点击“激活计划”按钮，将该计划导入到您的饮食日志中，以便跟踪和管理您的饮食。")
        
        tiAttr.yy_color = .COLOR_GRAY_BLACK_85
        tiAttr.yy_font = .systemFont(ofSize: 14, weight: .medium)
        contAttr.yy_color = .COLOR_GRAY_BLACK_65
        contAttr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        
        tiAttr.append(contAttr)
        label.attributedText = tiAttr
        
        return label
    }()
    lazy var contentLabelFour : UILabel = {
        let label = UILabel()
//        label.text = "3. 获取更多计划：在“日志”页面，您可以点击“免费获取计划”以生成更多的饮食计划，以便探索和尝试新的饮食建议。"
//        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
//        label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        var tiAttr = NSMutableAttributedString(string: "3. 获取更多计划：")
        var contAttr = NSMutableAttributedString(string: "您可以在我的计划页面点击“获取计划”以生成更多的饮食计划，以便探索和尝试新的饮食建议。")
        
        tiAttr.yy_color = .COLOR_GRAY_BLACK_85
        tiAttr.yy_font = .systemFont(ofSize: 14, weight: .medium)
        contAttr.yy_color = .COLOR_GRAY_BLACK_65
        contAttr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        
        tiAttr.append(contAttr)
        label.attributedText = tiAttr
        return label
    }()
    lazy var contentLabelFive : UILabel = {
        let label = UILabel()
//        label.text = "4. 自定义计划：如果您希望创建一个完全符合个人口味和需求的计划，可以在“我的”下的“制作计划”选项中自定义并保存您的计划。"
//        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
//        label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        var tiAttr = NSMutableAttributedString(string: "4. 自定义计划：")
        var contAttr = NSMutableAttributedString(string: "如果您希望创建一个完全符合个人口味和需求的计划，可以在“我的计划”下的“制作计划”选项中自定义并保存您的计划。")
        
        tiAttr.yy_color = .COLOR_GRAY_BLACK_85
        tiAttr.yy_font = .systemFont(ofSize: 14, weight: .medium)
        contAttr.yy_color = .COLOR_GRAY_BLACK_65
        contAttr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        
        tiAttr.append(contAttr)
        label.attributedText = tiAttr
        return label
    }()
    lazy var contentLabelSix : UILabel = {
        let label = UILabel()
//        label.text = "5. 分享您的计划：您可以通过在“日志”或计划详情页内点击“分享”按钮，将您的饮食计划分享给其他用户。"
//        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
//        label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        var tiAttr = NSMutableAttributedString(string: "5. 分享您的计划：")
        var contAttr = NSMutableAttributedString(string: "您可以通过在“日志”或计划详情页内点击“分享”按钮，将您的饮食计划分享给其他用户。")
        
        tiAttr.yy_color = .COLOR_GRAY_BLACK_85
        tiAttr.yy_font = .systemFont(ofSize: 14, weight: .medium)
        contAttr.yy_color = .COLOR_GRAY_BLACK_65
        contAttr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        
        tiAttr.append(contAttr)
        label.attributedText = tiAttr
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

extension QuestionnairePlanNameAlertVM{
    func showView() {
        self.isHidden = false
        whiteView.alpha = 0
//        self.alpha = 0
        bgView.alpha = 0
        bgView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.45, delay: 0,options: .curveLinear) {
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
//            self.alpha = 0
//        }
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
            self.bgView.alpha = 0
        }completion: { c in
            self.isHidden = true
        }
    }
    @objc func nothingToDo() {
        
    }
}

extension QuestionnairePlanNameAlertVM{
    func initUI(){
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(contentLabelOne)
        whiteView.addSubview(contentLabelTwo)
        whiteView.addSubview(contentLabelThree)
        whiteView.addSubview(contentLabelFour)
        whiteView.addSubview(contentLabelFive)
        whiteView.addSubview(contentLabelSix)
        
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
            make.top.equalTo(contentLabelOne.snp.bottom).offset(kFitWidth(12))
        }
        contentLabelThree.snp.makeConstraints { make in
            make.left.right.equalTo(contentLabelOne)
            make.top.equalTo(contentLabelTwo.snp.bottom).offset(kFitWidth(12))
        }
        contentLabelFour.snp.makeConstraints { make in
            make.left.right.equalTo(contentLabelOne)
            make.top.equalTo(contentLabelThree.snp.bottom).offset(kFitWidth(12))
        }
        contentLabelFive.snp.makeConstraints { make in
            make.left.right.equalTo(contentLabelOne)
            make.top.equalTo(contentLabelFour.snp.bottom).offset(kFitWidth(12))
        }
        contentLabelSix.snp.makeConstraints { make in
            make.left.right.equalTo(contentLabelOne)
            make.top.equalTo(contentLabelFive.snp.bottom).offset(kFitWidth(12))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(contentLabelSix.snp.bottom).offset(kFitWidth(20))
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

