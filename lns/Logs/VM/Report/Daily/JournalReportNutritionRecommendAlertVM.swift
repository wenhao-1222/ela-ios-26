//
//  JournalReportNutritionRecommendAlertVM.swift
//  lns
//
//  Created by Codex on 2026/7/21.
//

import UIKit
import SnapKit

/// 日报营养详情中“推荐摄入量如何计算”的说明弹窗。
final class JournalReportNutritionRecommendAlertVM: AlertVMCommon {

    private let contentHorizontalInset = kFitWidth(28)
    private let titleTop = kFitWidth(25)
    private let closeButtonSize = kFitWidth(25)
    private let closeTapSize = kFitWidth(70)
    private let scrollBottomInset = kFitWidth(12)
    weak var hostView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        whiteViewHeight = SCREEN_HEIGHT - WHUtils().getNavigationBarHeight() - kFitWidth(60)
        updateWhiteViewLayout()
        configureBaseStyle()
        initContentUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.9)
        button.layer.cornerRadius = closeButtonSize/2
        button.clipsToBounds = true
        button.tintColor = .COLOR_TEXT_TITLE_0f1214_35
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Elavatine是如何计算\n推荐摄入量的?"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.setLineHeightMultiple(textString: label.text, lineHeightMultiple: 1.1)
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .clear
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = kFitWidth(16)
        return stack
    }()
}

private extension JournalReportNutritionRecommendAlertVM {
    func configureBaseStyle() {
        whiteView.backgroundColor = .COLOR_BG_F2//.COLOR_CARD_BG_WHITE_ALERT
        whiteBlurView.contentView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.08)
        confirmButton.isHidden = true
    }

    func initContentUI() {
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(titleTop)
            make.centerX.lessThanOrEqualToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(titleTop)
            make.right.equalToSuperview().offset(-kFitWidth(25))
            make.width.height.equalTo(closeButtonSize)
        }

        let closeTapView = UIView()
        closeTapView.backgroundColor = .clear
        closeTapView.isUserInteractionEnabled = true
        closeTapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hiddenSelf)))
        whiteView.addSubview(closeTapView)
        closeTapView.snp.makeConstraints { make in
            make.center.equalTo(closeButton)
            make.width.height.equalTo(closeTapSize)
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(40))
            make.bottom.equalToSuperview().offset(-scrollBottomInset)
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
                .inset(UIEdgeInsets(top: 0,
                                    left: contentHorizontalInset,
                                    bottom: kFitWidth(16),
                                    right: contentHorizontalInset))
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-contentHorizontalInset * 2)
        }

        addContent()
    }

    func addContent() {
        addSection(title: "纤维：", paragraphs: [
            "美国膳食参考摄入量和 ADA（美国糖尿病协会）推荐的常用下限是 14 g/1000 kcal，而糖尿病营养建议里，EASD 的目标更高，约 16.7 g/1000 kcal。",
            "如果只追求普通健康，ADA 推荐的 14 g/1000 kcal 已经能覆盖明确有益区间。但从血糖稳定性的角度，目标可以适当高于普通健康下限。Lancet 2019 的系统综述和荟萃分析纳入 185 项前瞻研究和 58 项临床试验，发现高纤维摄入与全因死亡、心血管病、2 型糖尿病、结直肠癌等风险降低相关，风险降低在 25 到 29 g/天最明确，且剂量反应曲线提示更高摄入可能继续带来额外收益。因此，Elavatine 将膳食纤维默认目标设在普通健康底线之上，采用更适合代谢健康和血糖稳定性的保守优化目标。"
        ])

        addSection(title: "糖：", paragraphs: [
            "WHO 建议成年人和儿童将游离糖控制在总热量 10% 以下，进一步降到 5% 以下会带来额外健康收益。对 2000 kcal 饮食来说，5% 热量约等于 25 g 游离糖。",
            "但 Elavatine 目前按照营养成分标示的通用口径统计“总糖”，其中包括水果、牛奶等食物中的天然糖，也可能包括添加糖，因此不能直接等同于游离糖。中国居民膳食指南建议每天吃 200 到 350 g 新鲜水果，并摄入相当于 300 g 液态奶的奶制品。"
        ])

        addSection(title: "肌酸：", paragraphs: [
            "服用肌酸的核心是把肌肉内肌酸/磷酸肌酸储量长期拉高。NIH ODS 总结，肌酸主要提高短时间、高强度、重复爆发型活动，比如举重和冲刺；可以通过短期负荷期来让肌酸快速产生作用，无负荷期方案也可以用约 3 到 6 g/天，或 0.03 到 0.1 g/kg/天，连续 3 到 4 周产生增效作用。"
        ])

        contentStackView.addArrangedSubview(makeDivider())
        addReferences()
    }

    func addSection(title: String, paragraphs: [String]) {
        let titleLabel = makeBodyLabel(text: title,
                                       font: .systemFont(ofSize: 14, weight: .medium),
                                       color: .COLOR_TEXT_TITLE_0f1214)
        contentStackView.addArrangedSubview(titleLabel)

        for paragraph in paragraphs {
            let label = makeBodyLabel(text: paragraph,
                                      font: .systemFont(ofSize: 13, weight: .regular),
                                      color: .COLOR_TEXT_TITLE_0f1214_50)
            contentStackView.addArrangedSubview(label)
        }
    }

    func addReferences() {
        let titleLabel = makeBodyLabel(text: "文献来源：",
                                       font: .systemFont(ofSize: 12, weight: .medium),
                                       color: .COLOR_TEXT_TITLE_0f1214)
        contentStackView.addArrangedSubview(titleLabel)

        let refs = [
            "[1] Institute of Medicine. Dietary Reference Intakes for Energy, Carbohydrate, Fiber, Fat, Fatty Acids, Cholesterol, Protein, and Amino Acids. Washington, DC: The National Academies Press; 2005. doi:10.17226/10490.",
            "[2] Evert AB, Dennison M, Gardner CD, Garvey WT, Lau KHK, MacLeod J, et al. Nutrition therapy for adults with diabetes or prediabetes: a consensus report. Diabetes Care. 2019;42(5):731-754. doi:10.2337/dci19-0014.",
            "[3] The Diabetes and Nutrition Study Group (DNSG) of the European Association for the Study of Diabetes (EASD). Evidence-based European recommendations for the dietary management of diabetes. Diabetologia. 2023;66(6):965-985. doi:10.1007/s00125-023-05894-8.",
            "[4] Reynolds A, Mann J, Cummings J, Winter N, Mete E, Te Morenga L. Carbohydrate quality and human health: a series of systematic reviews and meta-analyses. The Lancet. 2019;393(10170):434-445. doi:10.1016/S0140-6736(18)31809-9.",
            "[5] World Health Organization. Guideline: Sugars Intake for Adults and Children. World Health Organization; 2015. Accessed May 27, 2026.",
            "[6] U.S. Food and Drug Administration. Added sugars on the Nutrition Facts label. Updated March 4, 2026. Accessed May 27, 2026.",
            "[7] Chinese Nutrition Society. 中国居民膳食指南（2022）平衡膳食八准则. Published April 26, 2022. Accessed May 27, 2026.",
            "[8] American Heart Association. How much sodium should I eat per day? American Heart Association. Last reviewed July 15, 2025. Accessed May 27, 2026.",
            "[9] World Health Organization. Sodium reduction. World Health Organization. Published May 11, 2026. Accessed May 27, 2026."
        ]

        for ref in refs {
            let label = makeBodyLabel(text: ref,
                                      font: .systemFont(ofSize: 12, weight: .regular),
                                      color: .COLOR_TEXT_TITLE_0f1214_50)
            contentStackView.addArrangedSubview(label)
        }
    }

    func makeBodyLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = font
        label.numberOfLines = 0
        label.setLineHeightMultiple(textString: text, lineHeightMultiple: 1.42)
        return label
    }

    func makeDivider() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.height.equalTo(kFitWidth(1))
        }

        let divider = DottedLineView()
        container.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        return container
    }
}

extension JournalReportNutritionRecommendAlertVM {
    func showSelf(in hostView: UIView? = nil) {
        if let hostView = hostView {
            self.hostView = hostView
        }
        guard let hostView = self.hostView else { return }
        if superview !== hostView {
            removeFromSuperview()
            hostView.addSubview(self)
        }
        super.showSelf()
    }
}
