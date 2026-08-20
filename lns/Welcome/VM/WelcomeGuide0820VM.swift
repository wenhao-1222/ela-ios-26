//
//  WelcomeGuide0820VM.swift
//  lns
//
//  Created by Codex on 2026/8/20.
//

import UIKit
import SnapKit

struct WelcomeGuide0820PageContent {
    let imageName: String
    let imageTop: CGFloat
    let title: String
    let details: [String]
}

private final class WelcomeGuide0820BulletRow: UIView {
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "create_plan_arrow_down")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .COLOR_TEXT_TITLE_0f1214
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        return imageView
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: kFitWidth(14), weight: .regular)
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.numberOfLines = 0
//        label.customLineHeight = 1
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    init(text: String) {
        super.init(frame: .zero)

        addSubview(arrowImageView)
        addSubview(detailLabel)
        detailLabel.text = text
//        detailLabel.setLineHeight(textString: text, lineHeight: kFitWidth(28))

        arrowImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(kFitWidth(8))
            make.width.height.equalTo(kFitWidth(11))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(arrowImageView.snp.right).offset(kFitWidth(15))
            make.top.right.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WelcomeGuide0820BasePageVM: UIView {
    private let content: WelcomeGuide0820PageContent
    private var delayedDetailViews: [UIView] = []

    private lazy var topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setImgLocal(imgName: content.imageName)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: kFitWidth(25), weight: .semibold)
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var detailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = kFitWidth(9)
        return stackView
    }()

    init(content: WelcomeGuide0820PageContent) {
        self.content = content
        super.init(frame: .zero)

        backgroundColor = WHColor_16(colorStr: "F5F5F5")
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDetailsVisible(_ isVisible: Bool) {
        delayedDetailViews.forEach {
            $0.layer.removeAllAnimations()
            $0.alpha = isVisible ? 1 : 0
        }
    }

    func revealDetails(delay: TimeInterval, duration: TimeInterval, completion: (() -> Void)? = nil) {
        delayedDetailViews.forEach {
            $0.layer.removeAllAnimations()
            $0.alpha = 0
        }
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut]) {
            self.delayedDetailViews.forEach {
                $0.alpha = 1
            }
        } completion: { _ in
            completion?()
        }
    }
}

private extension WelcomeGuide0820BasePageVM {
    func initUI() {
        addSubview(topImageView)
        addSubview(titleLabel)
        addSubview(detailStackView)
        titleLabel.text = content.title
//        titleLabel.setLineHeight(textString: content.title, lineHeight: kFitWidth(37))
        content.details.enumerated().forEach { index, text in
            let row = WelcomeGuide0820BulletRow(text: text)
            detailStackView.addArrangedSubview(row)
            if index > 0 {
                delayedDetailViews.append(row)
            }
        }

        topImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(content.imageTop)
            make.width.equalTo(kFitWidth(275))
            make.height.equalTo(kFitWidth(350))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(41))
            make.right.lessThanOrEqualTo(kFitWidth(-36))
            make.top.equalTo(viewTitleTop)
        }
        detailStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(47))
            make.right.equalTo(kFitWidth(-35))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }
    }

    var viewTitleTop: CGFloat {
        if SCREEN_HEIGHT <= 667 {
            return kFitWidth(482)
        }
        return kFitWidth(515)
    }
}

final class WelcomeGuide0820GoalUpdateVM: WelcomeGuide0820BasePageVM {
    init() {
        super.init(content: WelcomeGuide0820PageContent(
            imageName: "guide0820_goal_update",
            imageTop: kFitWidth(115),
            title: "你的目标\n不会一成不变",
            details: [
                "随着体重、代谢和实际执行发生变化 原本合适的摄入目标也可能需要调整",
                "ELA 会结合长期趋势，帮你判断现在应该 继续保持还是需要改变方向"
            ]
        ))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class WelcomeGuide0820DailyRecordVM: WelcomeGuide0820BasePageVM {
    init() {
        super.init(content: WelcomeGuide0820PageContent(
            imageName: "guide0820_daily_record",
            imageTop: kFitWidth(115),
            title: "每天几分钟\n让 ELA 真正了解你",
            details: [
                "记录饮食和体重，让 ELA 了解你的实际执行和身体变化",
                "记录越持续，ELA 越能看清什么对你真正有效，而不只是依赖最初的估算"
            ]
        ))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class WelcomeGuide0820NutritionStartVM: WelcomeGuide0820BasePageVM {
    var tapBlock: (() -> Void)?

    init() {
        super.init(content: WelcomeGuide0820PageContent(
            imageName: "guide0820_nutrition_start",
            imageTop: kFitWidth(115),
            title: "建立适合你的\n营养起点",
            details: [
                "ELA 会根据你的身体情况、生活习惯和目标，为你建立初始热量与营养目标",
                "无论你想减脂、增肌，还是改善整体健康，都可以从一个更适合当前状态的方向开始"
            ]
        ))

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func tapAction() {
        tapBlock?()
    }
}
