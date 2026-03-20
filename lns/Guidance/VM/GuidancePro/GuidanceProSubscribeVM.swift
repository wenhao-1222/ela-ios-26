//
//  GuidanceProSubscribeVM.swift
//  lns
//
//  Created by Codex on 2026/3/20.
//

import UIKit
import SnapKit
class GuidanceProSubscribeVM: UIView {

    var startTrialTapBlock: (() -> Void)?

    private lazy var loadingOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        view.isHidden = true
        return view
    }()

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .THEME
        view.hidesWhenStopped = false
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    private lazy var contentView = UIView()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "guidance_pro_intro_img"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var starsLeftImgView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "guidance_pro_promise_img")
        return img
    }()
    private lazy var starsLabel: UILabel = {
        let label = UILabel()
        label.text = "★★★★★"
        label.textColor = UIColor(hex: 0xFFC928)
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "超过1万+评价"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 8, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    lazy var starsRightImgView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "guidance_pro_subscribe_img")
        return img
    }()
    private lazy var faqStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = kFitWidth(18)
        return stack
    }()

    private lazy var reminderCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_WHITE_65//UIColor.white.withAlphaComponent(0.84)
        view.layer.cornerRadius = kFitWidth(12)
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
        return view
    }()

    private lazy var reminderLabel: UILabel = {
        let label = UILabel()
        label.text = "在试用期结束前提醒我"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private lazy var reminderSwitch: UISwitch = {
        let view = UISwitch()
        view.onTintColor = .THEME
        view.isOn = true
        return view
    }()

    private lazy var trialDescLabel: UILabel = {
        let label = UILabel()
        label.text = "免费试用3天，随后以186/年价格续费，仅0.51元/天。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var renewalDescLabel: UILabel = {
        let label = UILabel()
        label.text = "订阅计划会自动续订。请通过 App Store 取消订阅。\n除非你取消，否则免费试用结束后将开始收费。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var startTrialButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("0元 开启体验", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.layer.cornerRadius = kFitWidth(22)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(startTrialTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var noteIconLabel: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.text = "现在无需付费，你可以随时取消。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private lazy var proTitleLabel = makeSectionTitle("ELA PRO 将帮助你：")
    private lazy var freeTitleLabel = makeSectionTitle("以及现有的免费功能：")
    private lazy var proFeatureContainer = makeFeatureContainer()
    private lazy var freeFeatureContainer = makeFeatureContainer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GuidanceProSubscribeVM {
    func setLoading(_ isLoading: Bool) {
        loadingOverlayView.isHidden = !isLoading
        isUserInteractionEnabled = !isLoading

        if isLoading {
            bringSubviewToFront(loadingOverlayView)
            loadingIndicatorView.startAnimating()
        } else {
            loadingIndicatorView.stopAnimating()
        }

        startTrialButton.isEnabled = !isLoading
        startTrialButton.setTitle(isLoading ? "处理中..." : "0元 开启体验", for: .normal)
    }
}

private extension GuidanceProSubscribeVM {
    func initUI() {
        addSubview(scrollView)
        addSubview(loadingOverlayView)
        scrollView.addSubview(contentView)
        loadingOverlayView.addSubview(loadingIndicatorView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        contentView.addSubview(logoImageView)
        contentView.addSubview(starsLeftImgView)
        contentView.addSubview(starsLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(starsRightImgView)
        contentView.addSubview(faqStackView)
        contentView.addSubview(reminderCardView)
        contentView.addSubview(trialDescLabel)
        contentView.addSubview(renewalDescLabel)
        contentView.addSubview(startTrialButton)
        contentView.addSubview(noteIconLabel)
        contentView.addSubview(noteLabel)
        contentView.addSubview(proTitleLabel)
        contentView.addSubview(proFeatureContainer)
        contentView.addSubview(freeTitleLabel)
        contentView.addSubview(freeFeatureContainer)

        reminderCardView.addSubview(reminderLabel)
        reminderCardView.addSubview(reminderSwitch)

        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
//            make.top.equalToSuperview().offset(kFitWidth(18))
            make.top.equalTo(statusBarHeight+kFitWidth(110))
            make.width.equalTo(kFitWidth(165))
            make.height.equalTo(kFitWidth(29))
        }
        starsRightImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-29))
            make.centerY.lessThanOrEqualTo(logoImageView)
            make.width.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(38))
        }
        starsLabel.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-24))
            make.right.equalTo(starsRightImgView.snp.left).offset(kFitWidth(-3))
//            make.centerY.lessThanOrEqualTo(starsRightImgView)
            make.top.equalTo(starsRightImgView).offset(kFitWidth(5))
        }

        ratingLabel.snp.makeConstraints { make in
            make.centerX.equalTo(starsLabel)
            make.bottom.equalTo(starsRightImgView).offset(kFitWidth(-5))
//            make.top.equalTo(starsLabel.snp.bottom).offset(kFitWidth(8))
        }
        starsLeftImgView.snp.makeConstraints { make in
            make.right.equalTo(starsLabel.snp.left).offset(kFitWidth(-3))
            make.width.height.equalTo(starsRightImgView)
            make.centerY.lessThanOrEqualTo(starsRightImgView)
        }

        faqStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(34))
        }

        reminderCardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(faqStackView.snp.bottom).offset(kFitWidth(30))
            make.height.equalTo(kFitWidth(60))
        }

        reminderLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.centerY.equalToSuperview()
        }

        reminderSwitch.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-18))
            make.centerY.equalToSuperview()
        }

        trialDescLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(reminderCardView.snp.bottom).offset(kFitWidth(18))
        }

        renewalDescLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(34))
            make.right.equalTo(kFitWidth(-34))
            make.top.equalTo(trialDescLabel.snp.bottom).offset(kFitWidth(14))
        }

        startTrialButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(renewalDescLabel.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(kFitWidth(52))
        }

        noteIconLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-kFitWidth(78))
            make.top.equalTo(startTrialButton.snp.bottom).offset(kFitWidth(16))
        }

        noteLabel.snp.makeConstraints { make in
            make.left.equalTo(noteIconLabel.snp.right).offset(kFitWidth(8))
            make.centerY.equalTo(noteIconLabel)
        }

        proTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(noteLabel.snp.bottom).offset(kFitWidth(30))
        }

        proFeatureContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(proTitleLabel.snp.bottom).offset(kFitWidth(14))
        }

        freeTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(proFeatureContainer.snp.bottom).offset(kFitWidth(26))
        }

        freeFeatureContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(freeTitleLabel.snp.bottom).offset(kFitWidth(14))
            make.bottom.equalToSuperview().offset(-kFitWidth(24))
        }

        buildFAQs()
        buildFeatureRows()
    }

    func buildFAQs() {
        let faqItems = [
            ("Q：试用期间会扣费吗？", "A：不会扣费。"),
            ("Q：开始体验后可以取消吗？", "A：当然可以。在试用期结束前随时可取消，不会扣除任何费用。"),
            ("Q：如何取消试用？", "A：非常简单！进入手机设置，随后点击你的头像，点击订阅后选择elavatine，再次点击“取消订阅”即可。")
        ]

        faqItems.forEach { title, answer in
            faqStackView.addArrangedSubview(makeFAQView(question: title, answer: answer))
        }
    }

    func buildFeatureRows() {
        let proItems = [
            ("定制饮食计划", "按你的目标与饮食模式定制，直接照着执行"),
            ("整理购物清单", "为你食谱提前列好未来一周所需食材"),
            ("去除广告", "专心记录饮食，不被干扰"),
            ("解锁AI识别上限", "放开使用AI食物与营养成分表识别"),
            ("优先体验新功能", "新功能上线的第一时间体验")
        ]

        let freeItems: [(String, String?)] = [
            ("日常饮食记录", nil),
            ("身体数据记录", nil),
            ("有氧训练记录", nil)
        ]

        addFeatureRows(proItems, to: proFeatureContainer, accentColor: UIColor(hex: 0xEAF3FF))
        addFeatureRows(freeItems, to: freeFeatureContainer, accentColor: UIColor(hex: 0xF2F4F7))
    }

    func makeFAQView(question: String, answer: String) -> UIView {
        let view = UIView()

        let questionLabel = UILabel()
        questionLabel.text = question
        questionLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        questionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        questionLabel.numberOfLines = 0

        let answerLabel = UILabel()
        answerLabel.text = answer
        answerLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        answerLabel.font = .systemFont(ofSize: 16, weight: .medium)
        answerLabel.numberOfLines = 0

        view.addSubview(questionLabel)
        view.addSubview(answerLabel)

        questionLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }

        answerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(questionLabel.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalToSuperview()
        }

        return view
    }

    func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }

    func makeFeatureContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        view.layer.cornerRadius = kFitWidth(16)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.78).cgColor
        view.clipsToBounds = true
        return view
    }

    func addFeatureRows(_ items: [(String, String?)], to container: UIView, accentColor: UIColor) {
        var previousRow: UIView?

        for (index, item) in items.enumerated() {
            let row = makeFeatureRow(title: item.0, desc: item.1, accentColor: accentColor)
            container.addSubview(row)

            row.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                if let previousRow {
                    make.top.equalTo(previousRow.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                if index == items.count - 1 {
                    make.bottom.equalToSuperview()
                }
            }

            previousRow = row
        }
    }

    func makeFeatureRow(title: String, desc: String?, accentColor: UIColor) -> UIView {
        let view = UIView()

        let iconView = UIView()
        iconView.backgroundColor = accentColor
        iconView.layer.cornerRadius = kFitWidth(14)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 0

        let descLabel = UILabel()
        descLabel.text = desc
        descLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        descLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descLabel.numberOfLines = 0
        descLabel.isHidden = desc == nil

        let divider = UIView()
        divider.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.15)

        view.addSubview(iconView)
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(divider)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.top.equalTo(kFitWidth(18))
            make.width.height.equalTo(kFitWidth(28))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(12))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(14))
        }

        if desc == nil {
            divider.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.right.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(14))
                make.height.equalTo(1)
                make.bottom.equalToSuperview()
            }
        } else {
            descLabel.snp.makeConstraints { make in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            }

            divider.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.right.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(kFitWidth(14))
                make.height.equalTo(1)
                make.bottom.equalToSuperview()
            }
        }

        return view
    }

    @objc func startTrialTapAction() {
        startTrialTapBlock?()
    }
}

private extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
