//
//  AICoachPreReadyMessageVM.swift
//  lns
//
//  Created by Codex on 2026/5/25.
//

import UIKit
import SnapKit

final class AICoachPreReadyMessageVM: UIView {

    let selfHeight = kFitWidth(34)

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        backgroundColor = .clear
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "你的首期教练反馈已经准备好了，快去查看！"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        return label
    }()
}

extension AICoachPreReadyMessageVM {
    func prepareEntranceAnimation() {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -kFitWidth(12))
    }

    func applyFinalPresentationState() {
        alpha = 1
        transform = .identity
    }

    func playEntranceAnimation(duration: TimeInterval,
                               completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveLinear) {
            self.applyFinalPresentationState()
        } completion: { _ in
            completion?()
        }
    }
}

private extension AICoachPreReadyMessageVM {
    func initUI() {
        addSubview(messageLabel)

        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.bottom.equalToSuperview()
        }
    }
}
