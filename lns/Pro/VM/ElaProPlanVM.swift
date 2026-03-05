//
//  ElaProPlanVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//

import UIKit
import SnapKit

class ElaProPlanVM: UIView {
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "Image 5")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView()
        vi.showsVerticalScrollIndicator = false
        return vi
    }()
    
    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        let text = "把专业健身饮食\n变成你每天能执行的菜谱"
        let font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        lab.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
        lab.textColor = .white
        lab.font = font
        return lab
    }()
    
    lazy var tagLeftLabel: UILabel = makeTagLabel("运动员共创")
    lazy var tagRightLabel: UILabel = makeTagLabel("营养师校准")
    lazy var tagLeftLeftIcon: UIImageView = makeTagIcon(named: "ela_tag_label_left_icon")
    lazy var tagLeftRightIcon: UIImageView = makeTagIcon(named: "ela_tag_label_right_icon")
    lazy var tagRightLeftIcon: UIImageView = makeTagIcon(named: "ela_tag_label_left_icon")
    lazy var tagRightRightIcon: UIImageView = makeTagIcon(named: "ela_tag_label_right_icon")
    
    lazy var planOneCard: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE//UIColor.white.withAlphaComponent(0.96)
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        return vi
    }()
    
    lazy var planOneTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "饮食计划 1.0"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        return lab
    }()
    
    lazy var planOneDescLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        let text = "旧版本已帮助和你情况相似的用户，在尽量减少避免脂肪堆积情况下 3 个月内完成 增肌 5.4 公斤。"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        let attr = NSMutableAttributedString(string: text)
        attr.addAttributes([
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: text.count))
        
        let highlights = ["3", "增肌 5.4 公斤"]
        for key in highlights {
            if let range = text.range(of: key) {
                let nsRange = NSRange(range, in: text)
                attr.addAttributes([
                    .foregroundColor: UIColor.THEME,
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .paragraphStyle: paragraphStyle
                ], range: nsRange)
            }
        }
        lab.attributedText = attr
        return lab
    }()
    
    lazy var planTwoCard: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        return vi
    }()
    
    lazy var planTwoTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "全新饮食计划 2.0"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        return lab
    }()
    
    lazy var rowOne = makeRow(icon: "ela_pro_icon_2_1", title: "从食材清单升级为可执行的简易菜谱")
    lazy var rowTwo = makeRow(icon: "ela_pro_icon_2_2", title: "贴近日常口味，更容易坚持")
    lazy var rowThree = makeRow(icon: "ela_pro_icon_2_3", title: "智能推荐搭配，减少每餐决策成本")
    lazy var rowFour = makeRow(icon: "ela_pro_icon_2_4", title: "每周购物清单")
    
    lazy var dividerOne = makeDivider()
    lazy var dividerTwo = makeDivider()
    lazy var dividerThree = makeDivider()
    
    private func makeTagLabel(_ text: String) -> UILabel {
        let lab = UILabel()
        lab.text = text
        lab.textColor = WHColor_16(colorStr: "EAD6AE")
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        return lab
    }
    
    private func makeTagIcon(named: String) -> UIImageView {
        let img = UIImageView()
        img.setImgLocal(imgName: named)
        img.contentMode = .scaleAspectFit
        return img
    }
    
    private func makeRow(icon: String, title: String) -> UIView {
        let row = UIView()
        
        let iconView = UIImageView()
        iconView.setImgLocal(imgName: icon)
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        titleLabel.numberOfLines = 1
        
        row.addSubview(iconView)
        row.addSubview(titleLabel)
        
        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(1))
//            make.left.equalTo(kFitWidth(12))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(25))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(14))
            make.right.equalTo(kFitWidth(-12))
            make.centerY.equalToSuperview()
        }
        
        return row
    }
    
    private func makeDivider() -> UIView {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10//WHColor_16(colorStr: "ECEDEE")
        return vi
    }
}

extension ElaProPlanVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(tagLeftLabel)
        contentView.addSubview(tagRightLabel)
        contentView.addSubview(tagLeftLeftIcon)
        contentView.addSubview(tagLeftRightIcon)
        contentView.addSubview(tagRightLeftIcon)
        contentView.addSubview(tagRightRightIcon)
        contentView.addSubview(planOneCard)
        contentView.addSubview(planTwoCard)
        
        planOneCard.addSubview(planOneTitleLabel)
        planOneCard.addSubview(planOneDescLabel)
        
        planTwoCard.addSubview(planTwoTitleLabel)
        planTwoCard.addSubview(rowOne)
        planTwoCard.addSubview(rowTwo)
        planTwoCard.addSubview(rowThree)
        planTwoCard.addSubview(rowFour)
        planTwoCard.addSubview(dividerOne)
        planTwoCard.addSubview(dividerTwo)
        planTwoCard.addSubview(dividerThree)
        
        setConstrait()
    }
    
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(86)))
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(statusBarHeight + kFitWidth(65))
        }
        
        tagLeftLabel.snp.makeConstraints { make in
            make.left.equalTo(tagLeftLeftIcon.snp.right).offset(kFitWidth(6))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(22))
        }
        tagLeftLeftIcon.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.centerY.equalTo(tagLeftLabel)
            make.width.equalTo(kFitWidth(11))
            make.height.equalTo(kFitWidth(21))
        }
        tagLeftRightIcon.snp.makeConstraints { make in
            make.left.equalTo(tagLeftLabel.snp.right).offset(kFitWidth(6))
            make.centerY.equalTo(tagLeftLabel)
            make.width.equalTo(kFitWidth(11))
            make.height.equalTo(kFitWidth(21))
        }
        
        tagRightLabel.snp.makeConstraints { make in
            make.left.equalTo(tagRightLeftIcon.snp.right).offset(kFitWidth(6))
            make.centerY.equalTo(tagLeftLabel)
        }
        tagRightLeftIcon.snp.makeConstraints { make in
            make.left.equalTo(tagLeftRightIcon.snp.right).offset(kFitWidth(21))
            make.centerY.equalTo(tagLeftLabel)
            make.width.equalTo(kFitWidth(11))
            make.height.equalTo(kFitWidth(21))
        }
        tagRightRightIcon.snp.makeConstraints { make in
            make.left.equalTo(tagRightLabel.snp.right).offset(kFitWidth(6))
            make.centerY.equalTo(tagLeftLabel)
            make.width.equalTo(kFitWidth(11))
            make.height.equalTo(kFitWidth(21))
        }
        
        planOneCard.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(tagLeftLabel.snp.bottom).offset(kFitWidth(34))
        }
        
        planOneTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
        }
        
        planOneDescLabel.snp.makeConstraints { make in
            make.left.equalTo(planOneTitleLabel)
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(planOneTitleLabel.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-16))
        }
        
        planTwoCard.snp.makeConstraints { make in
            make.left.right.equalTo(planOneCard)
            make.top.equalTo(planOneCard.snp.bottom).offset(kFitWidth(14))
            make.bottom.equalToSuperview().offset(kFitWidth(-18))
        }
        
        planTwoTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(kFitWidth(18))
            make.height.equalTo(kFitWidth(24))
        }
        
        rowOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.right.equalTo(kFitWidth(-18))
            make.top.equalTo(planTwoTitleLabel.snp.bottom).offset(kFitWidth(7))
            make.height.equalTo(kFitWidth(52))
        }
        
        dividerOne.snp.makeConstraints { make in
            make.right.equalTo(rowOne)
            make.left.equalTo(rowOne).offset(kFitWidth(37))
            make.top.equalTo(rowOne.snp.bottom)
            make.height.equalTo(kFitWidth(1))
        }
        
        rowTwo.snp.makeConstraints { make in
            make.left.right.height.equalTo(rowOne)
            make.top.equalTo(dividerOne.snp.bottom)
        }
        
        dividerTwo.snp.makeConstraints { make in
            make.left.right.height.equalTo(dividerOne)
            make.top.equalTo(rowTwo.snp.bottom)
        }
        
        rowThree.snp.makeConstraints { make in
            make.left.right.height.equalTo(rowOne)
            make.top.equalTo(dividerTwo.snp.bottom)
        }
        
        dividerThree.snp.makeConstraints { make in
            make.left.right.height.equalTo(dividerOne)
            make.top.equalTo(rowThree.snp.bottom)
        }
        
        rowFour.snp.makeConstraints { make in
            make.left.right.height.equalTo(rowOne)
            make.top.equalTo(dividerThree.snp.bottom)
            make.bottom.equalTo(kFitWidth(-16))
        }
    }
}
