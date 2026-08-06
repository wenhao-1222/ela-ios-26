//
//  MealAdviceFoodsVM.swift
//  lns
//
//  Created by LNS2 on 2026/8/5.
//

import Foundation
import UIKit

class MealAdviceFoodsVM: UIView {
    
    var selfHeight = kFitWidth(0)
    private var selectedCount = 0
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_BG_F2
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "这餐计划吃什么？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textAlignment = .center
        
        return lab
    }()
    
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "选择食物后，我们会根据今天的剩余营养目标\n推荐这一餐中每种食物的摄入克重"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    
    lazy var searchBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        
        return vi
    }()
    
    lazy var searchIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_search_icon")
        
        return img
    }()
    
    lazy var searchTextField: ChineseTextField = {
        let text = ChineseTextField()
        text.placeholder = "请输入想要搜索的食物"
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.clearButtonMode = .whileEditing
        text.returnKeyType = .search
        text.textNumber = 50
        
        return text
    }()
    
    lazy var selectedTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    
    lazy var sectionTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "最近添加"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    
    lazy var allFoodsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("全部食物", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        
        return btn
    }()
    
    lazy var myFoodsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("我的食物", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        
        return btn
    }()
    
    lazy var noDataLabel: UILabel = {
        let lab = UILabel()
        lab.text = "-暂无数据-"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        
        return lab
    }()
    
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("规划本餐摄入量", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.enablePressEffect()
        
        return btn
    }()
}

extension MealAdviceFoodsVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsLabel)
        addSubview(searchBgView)
        searchBgView.addSubview(searchIconImg)
        searchBgView.addSubview(searchTextField)
        addSubview(selectedTitleLabel)
        addSubview(sectionTitleLabel)
        addSubview(allFoodsButton)
        addSubview(myFoodsButton)
        addSubview(noDataLabel)
        addSubview(confirmButton)
        
        refreshSelectedState()
        setConstrait()
    }
    
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(16)+WHUtils().getNavigationBarHeight())
        }
        tipsLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(55))
//            make.right.equalTo(kFitWidth(-55))
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
//            make.height.equalTo(kFitWidth(48))
        }
        searchBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(44))
            make.height.equalTo(kFitWidth(36))
        }
        searchIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(22))
        }
        searchTextField.snp.makeConstraints { make in
            make.left.equalTo(searchIconImg.snp.right).offset(kFitWidth(12))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }
        selectedTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(21))
            make.top.equalTo(searchBgView.snp.bottom).offset(kFitWidth(25))
//            make.height.equalTo(kFitWidth(22))
        }
        sectionTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(21))
            make.top.equalTo(selectedTitleLabel.snp.bottom).offset(kFitWidth(74))
        }
        myFoodsButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-21))
            make.centerY.lessThanOrEqualTo(sectionTitleLabel)
            make.height.equalTo(kFitWidth(30))
        }
        allFoodsButton.snp.makeConstraints { make in
            make.right.equalTo(myFoodsButton.snp.left).offset(kFitWidth(-12))
            make.centerY.lessThanOrEqualTo(sectionTitleLabel)
            make.height.equalTo(kFitWidth(30))
        }
        noDataLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(626))
            make.height.equalTo(kFitWidth(20))
        }
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(35))
            make.height.equalTo(kFitWidth(48))
        }
    }
    
    func refreshSelectedState() {
        let attr = NSMutableAttributedString(
            string: "已添加",
            attributes: [
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        attr.append(NSAttributedString(
            string: "·\(selectedCount)",
            attributes: [
                .foregroundColor: UIColor.THEME,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        ))
        selectedTitleLabel.attributedText = attr
        confirmButton.isEnabled = selectedCount > 0
    }
}
