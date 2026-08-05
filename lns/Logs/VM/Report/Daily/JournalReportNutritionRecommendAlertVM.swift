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
    private let closeButtonSize = kFitWidth(28)
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
//        button.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.9)
        button.layer.cornerRadius = closeButtonSize/2
        button.clipsToBounds = true
        button.tintColor = .COLOR_TEXT_TITLE_0f1214_35
//        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.setImage(UIImage(named: "alert_close_icon"), for: .normal)
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
            "但 Elavatine 目前按照营养成分标示的通用口径统计“总糖”，其中包括水果、牛奶等食物中的天然糖，也可能包括添加糖，因此不能直接等同于游离糖。中国居民膳食指南建议每天吃 200 到 350 g 新鲜水果，并摄入相当于 300 g 液态奶的奶制品。",
            "所以 Elavatine 内的总糖参考上限 = 游离糖理想上限 + 天然糖缓冲量"
        ])

        addSection(title: "饱和脂肪：", paragraphs: [
            "WHO 和美国膳食指南的公共卫生底线是 <10% 总热量，也就是 2000 kcal 时 <22 g/天；但这是最低合规线，并不是“最大化心血管健康”的最优目标。",
            "AHA（美国心脏协会）给出的心血管友好目标是：饱和脂肪低于总热量 6%。他们举例，2000 kcal 饮食中，饱和脂肪不超过 120 kcal，相当约 13 g/天。AHA 同时明确，饱和脂肪会提高 LDL，替换成不饱和脂肪可降低心血管风险。"
        ])
        addSection(title: "反式脂肪：", paragraphs: [
            "反式脂肪没有“有益摄入量”。WHO 的硬上限是反式脂肪 ≤1% 总能量，并建议进一步低于 1%；AHA 建议避免反式脂肪，反式脂肪会提高 LDL、降低 HDL，并与更高心血管风险相关。"
        ])
        addSection(title: "胆固醇：", paragraphs: [
            "现在没有一个适用于所有人的、能被高质量证据支持的每日胆固醇 mg 上限。",
            "300 mg/天为过去科学营养指南的核心阈值，但这一标准在近年被 AHA & NICE（英国国家卫生与临床优化研究所）推翻，并表明现有研究总体没有稳定支持“膳食胆固醇本身”和 CVD 风险之间存在简单线性关系；问题在于高胆固醇食物经常同时高饱和脂肪，比如肥肉、黄油、全脂奶、加工肉。鸡蛋和贝类是例外，因为胆固醇高但饱和脂肪不一定高。反式脂肪和膳食胆固醇应“尽可能低，同时不影响营养充足性”。"
        ])
        addSection(title: "钠：", paragraphs: [
            "AHA 建议大多数成年人理想钠摄入不超过 1500 mg/天，WHO 则建议成年人钠摄入低于 2000 mg/天。以上数据更接近日常基础目标上限，尚未计算运动时的汗液流失。对于健身群体来说，钠是维持神经传导、肌肉收缩和体液平衡的重要电解质。同时德国运动营养工作组综述给出的平均汗钠约 900 mg/L，一次普通健身出汗约 0.55 L，就相当于额外流失约 500 mg 钠。因此 Elavatine 会将健身人群的钠建议目标相对提高到 2000 mg/天，作为更适合日常训练场景的固定目标。大量出汗、高温或长时间训练时，仍可能需要根据实际情况额外补充电解质。"
        ])
        addSection(title: "钾：", paragraphs: [
            "WHO 从降低血压、心血管疾病、卒中和冠心病风险角度，建议成年人从食物中摄入至少 90 mmol/day 的钾，也就是 3510 mg/天，但它是条件性推荐，并说明精确最大获益水平证据有限。同时这个钾摄入目标结合 Elavatine 的钠摄入目标，可以形成更合理的钠钾比例，帮助维持更好的钠钾平衡。"
        ])
        addSection(title: "钙：", paragraphs: [
            "根据 NIH ODS（美国国立卫生研究院膳食补充剂办公室），成年人钙摄入的基础建议量为 1000 mg/day，这个数值更适合作为普通健身人群的日常钙目标。但运动员的骨健康特殊情况需要单独处理。IOC（国际奥委会）高水平运动员补剂共识中提到，对于存在低能量可用性或月经功能异常的运动员，为了优化骨健康，钙摄入也可提高到 1500 mg/天。"
        ])
        addSection(title: "铁：", paragraphs: [
            "根据 NIH ODS，成人铁 RDA 可以按人群区分：19 至 50 岁男性为 8 mg/天，19 至 50 岁女性为 18 mg/天，51 岁以上男女均为 8 mg/天，孕期为 27 mg/天，哺乳期为 9 mg/天。如果是素食者，铁摄入目标通常需要按普通 RDA 的 1.8 倍计算，因为植物性食物中的非血红素铁生物利用度更低。同时，NIH 也明确成人铁 UL 为 45 mg/天，长期高剂量补铁可能造成胃肠道副作用，极高剂量甚至可能带来严重毒性。",
            "对于运动员和健身人群，铁摄入需要更加谨慎。铁参与血红蛋白、肌红蛋白、肌肉代谢和结缔组织健康，直接关系到氧气运输、能量代谢和运动表现。运动人群更容易受到出汗、运动性溶血、胃肠道出血、低能量摄入、限制性饮食、月经失血，以及运动后铁调素（hepcidin）升高导致铁吸收下降等因素影响。"
        ])
        addSection(title: "维生素 A：", paragraphs: [
            "维生素 A 对免疫功能、细胞分化、生殖功能、甲状腺和其他内分泌组织都非常重要。但维 A 属于脂溶性维生素，尤其是动物性食物和补剂中的预成型维生素 A，长期过量有明确毒性风险。",
            "美国 National Academies 给出的成人维生素 A RDA 为：男性 900 μg RAE/day，女性 700 μg RAE/day；NIH ODS 也采用同一套标准。RAE 是视黄醇活性当量，用来统一不同来源维生素 A 的实际活性。"
        ])
        addSection(title: "维生素 C：", paragraphs: [
            "National Academies 的 DRI 说明，男性 90 mg/天、女性 75 mg/天可维持接近最大化的中性粒细胞维生素 C 浓度，同时尿排泄较少。NIH ODS 也给出同样的成人 RDA，并说明吸烟者每日需要额外 35 mg。",
            "而针对以最大化免疫系统健康为目标的健身运动群体，NIH ODS 说明，人体维 C 浓度受到严格控制，每日摄入达到 100 mg 或以上时，细胞内维生素 C 浓度已接近饱和；达到至少 200 mg 时，血浆浓度只会出现边际增加。运动营养文献中也提到，针对运动员基础营养的实用建议，可以把约 200 mg/天作为运动人群的指导值，用来达到较理想的血浆维 C 状态和骨骼肌维 C 状态，同时避免高剂量抗氧化补剂的问题。在马拉松跑者、滑雪者、士兵等“极端体力运动或寒冷暴露”人群中，250 mg 到 1 g/天的维 C 研究剂量让感冒发生率下降约 50%。"
        ])
        addSection(title: "咖啡因：", paragraphs: [
            "NIH ODS 总结，训练前摄入约 2 到 6 mg/kg 咖啡因可改善耐力、力量、爆发或高强度团队运动表现，更高剂量通常不会继续提高表现，反而会增加副作用；ISSN 2021 也指出 3 到 6 mg/kg 是一致有效区间，9 mg/kg 副作用更多且通常不必要。",
            "EFSA（欧洲食品安全局）认为健康成人单次 200 mg 左右通常不构成安全担忧，每日总量 400 mg 通常不构成安全担忧；FDA（美国食品药品监督管理局）也把 400 mg/day 视为多数成人通常不会产生危险负面影响的摄入量。"
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
            "[9] World Health Organization. Sodium reduction. World Health Organization. Published May 11, 2026. Accessed May 27, 2026.",
            "[10] Mosler S, Braun H, Carlsohn A, et al. Position of the Working Group Sports Nutrition of the German Nutrition Society (DGE): fluid replacement in sports. Dtsch Z Sportmed. 2020;71:178-184. doi:10.5960/dzsm.2020.453.",
            "[11] World Health Organization. Guideline: Potassium Intake for Adults and Children. World Health Organization; 2012. Accessed May 27, 2026.",
            "[12] National Institutes of Health Office of Dietary Supplements. Calcium: fact sheet for health professionals. Updated July 11, 2025. Accessed May 27, 2026.",
            "[13] Maughan RJ, Burke LM, Dvorak J, et al. IOC consensus statement: dietary supplements and the high-performance athlete. Int J Sport Nutr Exerc Metab. 2018;28(2):104-125. doi:10.1123/ijsnem.2018-0020.",
            "[14] National Institutes of Health Office of Dietary Supplements. Iron: fact sheet for health professionals. Updated September 4, 2025. Accessed May 27, 2026.",
            "[15] Nolte S, Krüger K, Hollander K, Carlsohn A. Approaches to prevent iron deficiency in athletes. Dtsch Z Sportmed. 2024;75:195-202. doi:10.5960/dzsm.2024.607.",
            "[16] National Institutes of Health Office of Dietary Supplements. Vitamin A and carotenoids: fact sheet for health professionals. Updated March 10, 2025. Accessed May 27, 2026.",
            "[17] Institute of Medicine (US) Panel on Micronutrients. Vitamin A. In: Dietary Reference Intakes for Vitamin A, Vitamin K, Arsenic, Boron, Chromium, Copper, Iodine, Iron, Manganese, Molybdenum, Nickel, Silicon, Vanadium, and Zinc. National Academies Press; 2001. Accessed May 27, 2026.",
            "[18] Institute of Medicine (US) Panel on Dietary Antioxidants and Related Compounds. Vitamin C. In: Dietary Reference Intakes for Vitamin C, Vitamin E, Selenium, and Carotenoids. National Academies Press; 2000. Accessed May 27, 2026. https://www.ncbi.nlm.nih.gov/books/NBK225480/",
            "[19] National Institutes of Health Office of Dietary Supplements. Vitamin C: fact sheet for health professionals. Updated July 31, 2025. Accessed May 27, 2026. https://ods.od.nih.gov/factsheets/VitaminC-HealthProfessional/",
            "[20] Neubauer O, Yfanti C. Antioxidants in athlete’s basic nutrition: considerations towards a guideline for the intake of vitamin C and vitamin E. In: Lamprecht M, ed. Antioxidants in Sport Nutrition. CRC Press/Taylor & Francis; 2015:chap 3. Accessed May 27, 2026. https://www.ncbi.nlm.nih.gov/books/NBK299049/",
            "[21] National Institutes of Health Office of Dietary Supplements. Dietary supplements for exercise and athletic performance: fact sheet for health professionals. Updated April 1, 2024. Accessed May 27, 2026. https://ods.od.nih.gov/factsheets/ExerciseAndAthleticPerformance-HealthProfessional/",
            "[22] Guest NS, VanDusseldorp TA, Nelson MT, et al. International Society of Sports Nutrition position stand: caffeine and exercise performance. J Int Soc Sports Nutr. 2021;18(1):1. doi:10.1186/s12970-020-00383-4.",
            "[23] EFSA Panel on Dietetic Products, Nutrition and Allergies (NDA). Scientific opinion on the safety of caffeine. EFSA Journal. 2015;13(5):4102. doi:10.2903/j.efsa.2015.4102.",
            "[24] U.S. Food and Drug Administration. Spilling the beans: how much caffeine is too much? FDA. Updated August 28, 2024. Accessed May 27, 2026. https://www.fda.gov/consumers/consumer-updates/spilling-beans-how-much-caffeine-too-much",
            "[25] Kreider RB, Kalman DS, Antonio J, et al. International Society of Sports Nutrition position stand: safety and efficacy of creatine supplementation in exercise, sport, and medicine. J Int Soc Sports Nutr. 2017;14:18. doi:10.1186/s12970-017-0173-z."
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
