//
//  ElaLiquidGlassCloseButton.swift
//  lns
//
//  Created by Codex on 2026/8/17.
//

import UIKit

/// App-wide close button that uses native Liquid Glass on iOS 26 and keeps the
/// existing plain icon behavior on earlier systems.
final class ElaLiquidGlassCloseButton: UIButton {

    var iconImage: UIImage? {
        didSet {
            applyAppearance()
        }
    }

    var iconColor: UIColor = .COLOR_TEXT_TITLE_0f1214 {
        didSet {
            applyAppearance()
        }
    }

    var iconSize: CGFloat = kFitWidth(17) {
        didSet {
            applyAppearance()
        }
    }

    var showsOuterStroke: Bool = true {
        didSet {
            updateStrokeVisibility()
        }
    }

    private let glassBackgroundView = UIVisualEffectView(effect: nil)
    private let tintView = UIView()
    private let iconImageView = UIImageView()
    private let strokeLayer = CAShapeLayer()
    private let borderHighlightLayer = CAShapeLayer()

    init(image: UIImage? = UIImage(systemName: "xmark")) {
        self.iconImage = image
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        iconImage = image(for: .normal) ?? UIImage(systemName: "xmark")
        setupUI()
    }

    override var isHighlighted: Bool {
        didSet {
            updateStateAppearance()
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateStateAppearance()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        applyAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let radius = bounds.height * 0.5
        glassBackgroundView.frame = bounds
        tintView.frame = glassBackgroundView.bounds
        iconImageView.bounds = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
        iconImageView.center = CGPoint(x: bounds.midX, y: bounds.midY)

        glassBackgroundView.layer.cornerRadius = radius
        glassBackgroundView.layer.cornerCurve = .continuous

        strokeLayer.frame = bounds
        strokeLayer.path = UIBezierPath(
            ovalIn: bounds.insetBy(dx: 0.5, dy: 0.5)
        ).cgPath

        borderHighlightLayer.frame = bounds
        borderHighlightLayer.path = UIBezierPath(
            ovalIn: bounds.insetBy(dx: 1, dy: 1)
        ).cgPath
        bringBorderLayersToFront()
    }
}

private extension ElaLiquidGlassCloseButton {

    var isNativeGlassAvailable: Bool {
        if #available(iOS 26.0, *) {
            return true
        } else {
            return false
        }
    }

    func setupUI() {
        accessibilityLabel = "关闭"
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = false
        layer.masksToBounds = false

        glassBackgroundView.isUserInteractionEnabled = false
        glassBackgroundView.backgroundColor = .clear
        glassBackgroundView.isOpaque = false
        glassBackgroundView.clipsToBounds = true

        tintView.isUserInteractionEnabled = false
        iconImageView.isUserInteractionEnabled = false
        iconImageView.contentMode = .scaleAspectFit

        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.lineWidth = 1
        borderHighlightLayer.fillColor = UIColor.clear.cgColor
        borderHighlightLayer.lineWidth = 1.5
        borderHighlightLayer.opacity = 0

        insertSubview(glassBackgroundView, at: 0)
        glassBackgroundView.contentView.addSubview(tintView)
        layer.addSublayer(strokeLayer)
        layer.addSublayer(borderHighlightLayer)
        addSubview(iconImageView)

        applyAppearance()
        updateStateAppearance()
    }

    func applyAppearance() {
        if isNativeGlassAvailable {
            applyNativeGlassAppearance()
        } else {
            applyFallbackAppearance()
        }
    }

    func applyNativeGlassAppearance() {
        guard #available(iOS 26.0, *) else {
            return
        }

        glassBackgroundView.isHidden = true
        iconImageView.isHidden = true
        updateNativeStrokeVisibility()

        var config = UIButton.Configuration.clearGlass()
        config.image = iconImage?.withRenderingMode(.alwaysTemplate)
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: iconSize,
                                                                                  weight: .regular,
                                                                                  scale: .medium)
        config.baseForegroundColor = iconColor
        config.cornerStyle = .capsule
        config.contentInsets = .zero
        configuration = config
        tintColor = iconColor
        bringBorderLayersToFront()
    }

    func applyFallbackAppearance() {
        configuration = nil
        glassBackgroundView.isHidden = false
        iconImageView.isHidden = false
        updateStrokeVisibility()

        let isDark = traitCollection.userInterfaceStyle == .dark
        glassBackgroundView.effect = UIBlurEffect(style: isDark ? .systemThinMaterialDark : .systemThinMaterialLight)
        applySharedBackgroundColors()
        updateIcon()
    }

    func applySharedBackgroundColors() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        tintView.backgroundColor = isDark
            ? UIColor.white.withAlphaComponent(0.10)
            : UIColor.white.withAlphaComponent(0.24)
        strokeLayer.strokeColor = UIColor.white
            .withAlphaComponent(isDark ? 0.26 : 0.72)
            .cgColor
        borderHighlightLayer.strokeColor = UIColor.white
            .withAlphaComponent(isDark ? 0.52 : 0.92)
            .cgColor
    }

    func updateIcon() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize,
                                                       weight: .regular,
                                                       scale: .medium)
        let image = iconImage?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
        iconImageView.image = image
        iconImageView.tintColor = iconColor
    }

    func bringBorderLayersToFront() {
        strokeLayer.removeFromSuperlayer()
        borderHighlightLayer.removeFromSuperlayer()
        layer.addSublayer(strokeLayer)
        layer.addSublayer(borderHighlightLayer)
    }

    func updateStrokeVisibility() {
        guard !isNativeGlassAvailable else {
            updateNativeStrokeVisibility()
            return
        }

        strokeLayer.isHidden = !showsOuterStroke
        borderHighlightLayer.isHidden = !showsOuterStroke
    }

    func updateNativeStrokeVisibility() {
        strokeLayer.isHidden = true
        borderHighlightLayer.isHidden = true
        borderHighlightLayer.opacity = 0
    }

    func updateStateAppearance() {
        alpha = isEnabled ? 1 : 0.45

        guard !isNativeGlassAvailable else {
            transform = .identity
            iconImageView.alpha = 1
            tintView.alpha = 1
            updateNativeStrokeVisibility()
            return
        }

        let changes = {
            self.transform = self.isHighlighted && self.isEnabled
                ? CGAffineTransform(scaleX: 0.96, y: 0.96)
                : .identity
            self.iconImageView.alpha = self.isHighlighted && self.isEnabled ? 0.72 : 1
            self.tintView.alpha = self.isHighlighted && self.isEnabled ? 0.78 : 1
            self.borderHighlightLayer.opacity = self.isHighlighted && self.isEnabled ? 1 : 0
        }

        UIView.animate(withDuration: 0.12,
                       delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction],
                       animations: changes)
    }
}
