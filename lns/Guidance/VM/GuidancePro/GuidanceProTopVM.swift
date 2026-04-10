//
//  GuidanceProTopVM.swift
//  lns
//
//  Created by Codex on 2026/3/20.
//

import UIKit
import SnapKit

class GuidanceProTopVM: UIView {

    private enum BubbleAnimationKey {
        static let sway = "guidance.pro.bubble.sway"
        static let drift = "guidance.pro.bubble.drift"
    }

    private lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_guidance_1_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var elaproImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_expired_alert_icon")
        return img
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "将给你更完整的支持"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "帮助你更精确地执行"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GuidanceProTopVM {
    func startBubbleFloatingAnimationIfNeeded() {
        guard bubbleImageView.layer.animation(forKey: BubbleAnimationKey.sway) == nil else { return }

        let swayAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        swayAnimation.values = [-0.05, 0.028, -0.02, 0.05, -0.05]
        swayAnimation.keyTimes = [0.0, 0.26, 0.52, 0.78, 1.0]
        swayAnimation.duration = 4.8
        swayAnimation.repeatCount = .infinity
        swayAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        swayAnimation.isAdditive = true

        let driftAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        driftAnimation.values = [
            NSValue(cgSize: CGSize(width: -4, height: 0)),
            NSValue(cgSize: CGSize(width: 2, height: -3)),
            NSValue(cgSize: CGSize(width: 4, height: -1)),
            NSValue(cgSize: CGSize(width: -2, height: 2)),
            NSValue(cgSize: CGSize(width: -4, height: 0))
        ]
        driftAnimation.keyTimes = [0.0, 0.26, 0.52, 0.78, 1.0]
        driftAnimation.duration = 5.6
        driftAnimation.repeatCount = .infinity
        driftAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        driftAnimation.isAdditive = true

        bubbleImageView.layer.add(swayAnimation, forKey: BubbleAnimationKey.sway)
        bubbleImageView.layer.add(driftAnimation, forKey: BubbleAnimationKey.drift)
    }

    func stopBubbleFloatingAnimation() {
        bubbleImageView.layer.removeAnimation(forKey: BubbleAnimationKey.sway)
        bubbleImageView.layer.removeAnimation(forKey: BubbleAnimationKey.drift)
    }
}

private extension GuidanceProTopVM {
    func initUI() {
        addSubview(bubbleImageView)
        addSubview(elaproImg)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        bubbleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(kFitWidth(300))
            make.height.equalTo(kFitWidth(415))
        }
        elaproImg.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(108))
            make.height.equalTo(kFitWidth(19))
            make.top.equalTo(bubbleImageView.snp.bottom).offset(kFitWidth(50))
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bubbleImageView.snp.bottom).offset(kFitWidth(80))
            make.left.greaterThanOrEqualTo(kFitWidth(24))
            make.right.lessThanOrEqualTo(kFitWidth(-24))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.left.greaterThanOrEqualTo(kFitWidth(24))
            make.right.lessThanOrEqualTo(kFitWidth(-24))
            make.bottom.equalToSuperview()
        }
    }
}
