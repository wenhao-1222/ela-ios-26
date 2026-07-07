//
//  GuideTotalProCompleteVM.swift
//  lns
//
//  Created by Codex on 2026/7/7.
//

import UIKit
import SnapKit

class GuideTotalProCompleteVM: UIView {

    var nextBlock: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "设置完成!"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeSubtitleText()
        return label
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = kFitWidth(20)
        return stackView
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("开始记录饮食", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = kFitWidth(8)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return button
    }()
}

private extension GuideTotalProCompleteVM {
    func initUI() {

        addSubview(scrollView)
        addSubview(nextButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(makeTimelineItem(title: "第 1 到 3 周：建立基线",
                                                      detail: "收集饮食、体重和训练数据，了解你的身体习惯和真实反应。"))
        stackView.addArrangedSubview(makeTimelineItem(title: "第 4 到 7 周：关键校准",
                                                      detail: "根据进度从多个维度提前发现潜在卡点，在瓶颈出现前介入，并给出调整建议和可执行动作。"))
        stackView.addArrangedSubview(makeTimelineItem(title: "第 8 到 12 周：持续微调",
                                                      detail: "持续分析并区分体重波动，判断哪些是真正阻碍，哪些只是短期噪音，降低结果焦虑。"))

        setConstraints()
    }
    
    func setConstraints() {
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(kFitWidth(-18))
        }

        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(106))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.right.equalTo(kFitWidth(-25))
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(50))
            make.bottom.equalToSuperview().offset(kFitWidth(-24))
        }
    }

    func makeSubtitleText() -> NSAttributedString {
        let text = "在接下来 12 周，AI 教练会根据你的真实记录，逐步调整饮食策略"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = kFitWidth(8)

        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
            .paragraphStyle: paragraphStyle
        ])

        if let range = text.range(of: "12") {
            attr.addAttribute(.font,
                              value: UIFont().DDInFontBold(fontSize: 18),
                              range: NSRange(range, in: text))
        }

        return attr
    }

    func makeTimelineItem(title: String, detail: String) -> UIView {
        let container = UIView()

        let dotView = UIView()
        dotView.backgroundColor = .THEME
        dotView.layer.cornerRadius = kFitWidth(4)

        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.attributedText = makeTimelineTitleAttributedText(text: title, color: .COLOR_TEXT_TITLE_0f1214)

        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.attributedText = makeDetailText(detail)

        container.addSubview(dotView)
        container.addSubview(titleLabel)
        container.addSubview(detailLabel)

        dotView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(9))
//            make.top.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.width.height.equalTo(kFitWidth(8))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(dotView.snp.right).offset(kFitWidth(16))
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualTo(dotView)
        }

        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(4))
            make.bottom.equalToSuperview()
        }

        return container
    }

    func makeDetailText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
            .paragraphStyle: paragraphStyle
        ])
    }

    @objc func nextButtonAction() {
        nextBlock?()
    }
}

extension GuideTotalProCompleteVM {
    func prepareEntranceAnimation() {
        scrollView.setContentOffset(.zero, animated: false)
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        stackView.alpha = 0
        nextButton.alpha = 0
    }

    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.55, delay: 0, options: .curveLinear) {
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.55, delay: 0.1, options: .curveLinear) {
                self.stackView.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
    
}

extension GuideTotalProCompleteVM {
    func makeTimelineTitleAttributedText(text: String, color: UIColor) -> NSAttributedString {
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: color
            ]
        )

        guard let regex = try? NSRegularExpression(pattern: "\\d+", options: []) else {
            return attr
        }

        let nsText = text as NSString
        let numberFont = UIFont().DDInFontBold(fontSize: 18)
        regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length)).forEach {
            attr.addAttributes([
                .font: numberFont,
                .foregroundColor: color
            ], range: $0.range)
        }
        return attr
    }
}
