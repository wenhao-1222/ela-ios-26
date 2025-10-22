//
//  CoursePayPopupView.swift
//  lns
//
//  Created by LNS2 on 2025/10/21.
//

// UIKit Popup built with UIView + SnapKit (no custom VC)
// 1) Add SnapKit to your project (SPM/CocoaPods)
// 2) Drop this file in, then call: `PopupView().present(in: view)`

import UIKit
import SnapKit

final class PopupView: UIView {
    // MARK: - Subviews
    private let blurView = UIVisualEffectView(effect: nil)
    private let dimView = UIView()
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    // Track original card center for pan interaction
    private var cardCenterY: CGFloat = 0

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Public API
    func present(in hostView: UIView) {
        // Attach to host
//        self.frame = hostView.bounds
        self.frame = CGRect.init(x: SCREEN_WIDHT*0.5 - kFitWidth(100), y: SCREEN_HEIGHT*0.5 - kFitWidth(140), width: kFitWidth(200), height: kFitWidth(280))
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostView.addSubview(self)
        layoutIfNeeded()

        // Initial states
        blurView.effect = nil
        dimView.alpha = 0
        blurView.alpha = 0.85
        cardView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92).concatenating(.init(translationX: 0, y: 30))
        cardView.alpha = 0

        // Animate in
        let blur = UIBlurEffect(style: .extraLight)
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0.8, options: [.allowUserInteraction, .curveEaseInOut]) {
            self.blurView.effect = blur
            self.dimView.alpha = 0.25
            self.cardView.transform = .identity
            self.cardView.alpha = 1
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.28, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
            self.cardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).concatenating(.init(translationX: 0, y: 20))
            self.cardView.alpha = 0
            self.blurView.effect = nil
            self.dimView.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - Setup & Layout
private extension PopupView {
    func setup() {
        backgroundColor = .clear

        // Blur (real-time frosted glass)
        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Dim overlay (above blur)
        dimView.backgroundColor = .black
        dimView.alpha = 0
        addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Card container
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 24
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowRadius = 20
        cardView.layer.shadowOffset = .init(width: 0, height: 10)
        addSubview(cardView)

        // Layout card
        cardView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().inset(24)
            make.width.lessThanOrEqualTo(568)
        }

        // Labels & button
        titleLabel.text = "100% 的课程收入将用于支持"
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)

        bodyLabel.text = "这里是示例文案，随意替换。重点是背景的毛玻璃与遮罩、卡片圆角和交互动效。"
        bodyLabel.numberOfLines = 0
        bodyLabel.font = .systemFont(ofSize: 16)

        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .tertiaryLabel
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)

        cardView.addSubview(titleLabel)
        cardView.addSubview(bodyLabel)
        cardView.addSubview(closeButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(28)
        }
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 32, height: 32))
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().inset(12)
        }

        // Gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTap(_:)))
        addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }
}

// MARK: - Actions
private extension PopupView {
    @objc func didTapClose() { dismiss() }

    @objc func backgroundTap(_ g: UITapGestureRecognizer) {
        let p = g.location(in: self)
        if !cardView.frame.contains(p) { dismiss() }
    }

    @objc func handlePan(_ g: UIPanGestureRecognizer) {
        switch g.state {
        case .began:
            cardCenterY = cardView.center.y
        case .changed:
            let t = g.translation(in: self)
            let y = max(0, t.y) // only drag down
            let progress = min(1, y / 240)
            cardView.transform = CGAffineTransform(translationX: 0, y: y)
                .scaledBy(x: 1 - 0.05 * progress, y: 1 - 0.05 * progress)
            updateBackground(for: progress)
        case .ended, .cancelled:
            let t = g.translation(in: self)
            if t.y > 120 {
                dismiss()
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut]) {
                    self.cardView.transform = .identity
                    self.updateBackground(for: 0)
                }
            }
        default: break
        }
    }

    func updateBackground(for progress: CGFloat) {
        let clamped = max(0, min(1, progress))
        dimView.alpha = 0.25 * (1 - clamped)
        // Lightweight blur intensity change by alpha (keeps effect smooth without private APIs)
        blurView.alpha = 1 - 0.6 * clamped
    }
}
