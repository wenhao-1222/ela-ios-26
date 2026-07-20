//
//  ElaProElementsIntroVM.swift
//  lns
//
//  Created by Codex on 2026/7/20.
//

import UIKit
import SnapKit

class ElaProElementsIntroVM: UIView {
    var continueTapBlock: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .clear
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInsetAdjustmentBehavior = .never
        return scroll
    }()
    
    lazy var contentView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        return vi
    }()
    
    lazy var heroImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "elements_pro_intro_header_img")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var titleImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "elements_pro_intro_title_img")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var subtitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "解锁更多数据维度"
        lab.textColor = UIColor.COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 17, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var featureCard: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.white.withAlphaComponent(0.32)
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderWidth = kFitWidth(1)
        vi.layer.borderColor = UIColor.white.withAlphaComponent(0.95).cgColor
        vi.clipsToBounds = true
        return vi
    }()
    
    lazy var performanceRow = makeFeatureRow(
        title: "量化运动表现",
        desc: "追踪咖啡因与肌酸，锁定神经募集与力量状态",
        dotImg: "guidance_pro_ai_icon"
    )
    
    lazy var recoveryRow = makeFeatureRow(
        title: "精准突破瓶颈",
        desc: "监控核心微量元素，优化内分泌与深度修复",
        dotImg: "elements_pro_icon_1"
    )
    
    lazy var riskRow = makeFeatureRow(
        title: "管理隐性风险",
        desc: "穿透宏量数据，精准把控心血管与代谢健康",
        dotImg: "elements_pro_icon_2"
    )
    
    lazy var firstDivider = makeDivider()
    lazy var secondDivider = makeDivider()
    
    lazy var continueButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .THEME
        btn.setTitle("继续", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(continueButtonTapAction), for: .touchUpInside)
        return btn
    }()
}

private extension ElaProElementsIntroVM {
    func initUI() {
        addSubview(scrollView)
        addSubview(continueButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(heroImageView)
        contentView.addSubview(titleImageView)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(featureCard)
        
        featureCard.addSubview(performanceRow)
        featureCard.addSubview(recoveryRow)
        featureCard.addSubview(riskRow)
        featureCard.addSubview(firstDivider)
        featureCard.addSubview(secondDivider)
        
        setConstraints()
    }
    
    func setConstraints() {
        continueButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(10)))
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).offset(kFitWidth(-14))
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        heroImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(7))
            make.width.equalTo(kFitWidth(303))
            make.height.equalTo(kFitWidth(244))
        }
        
        titleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(heroImageView.snp.bottom).offset(kFitWidth(33))
            make.width.equalTo(kFitWidth(170))
            make.height.equalTo(kFitWidth(39))
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleImageView.snp.bottom).offset(kFitWidth(7))
        }
        
        featureCard.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(58))
            make.bottom.equalToSuperview().offset(kFitWidth(-18))
        }
        
        performanceRow.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(72))
        }
        
        firstDivider.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(70))
            make.right.equalTo(kFitWidth(-2))
            make.top.equalTo(performanceRow.snp.bottom)
            make.height.equalTo(kFitWidth(1))
        }
        
        recoveryRow.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(firstDivider.snp.bottom)
            make.height.equalTo(performanceRow)
        }
        
        secondDivider.snp.makeConstraints { make in
            make.left.right.height.equalTo(firstDivider)
            make.top.equalTo(recoveryRow.snp.bottom)
        }
        
        riskRow.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(secondDivider.snp.bottom)
            make.height.equalTo(performanceRow)
            make.bottom.equalToSuperview()
        }
    }
    func makeFeatureRow(title: String, desc: String,dotImg:String) -> UIView {
        ElaProPriceVM.makeBenefitRow(title: title, desc: desc, dotImg: dotImg)
    }
    
    func makeDivider() -> UIView {
        let vi = UIView()
        vi.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_10
        return vi
    }
    
    @objc func continueButtonTapAction() {
        continueTapBlock?()
    }
}
