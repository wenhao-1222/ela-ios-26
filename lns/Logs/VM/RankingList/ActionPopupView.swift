//
//  ActionPopupView.swift
//  lns
//
//  Created by Elavatine on 2025/7/3.
//

import UIKit

enum ArrowDirection {
    case up
    case down
}

class ActionPopupView: UIView {

    private let stackView = UIStackView()
    private let arrowView = TriangleView()
    private let backgroundView = UIView()
    public var arrowDirection: ArrowDirection = .up
    public var arrowCenterX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    private var buttonActions: [(title: String, handler: () -> Void)] = []

    init(arrowDirection: ArrowDirection = .up) {
        super.init(frame: .zero)
        self.arrowDirection = arrowDirection
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear
        self.isUserInteractionEnabled = true

        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = kFitWidth(8)
//        backgroundView.clipsToBounds = true
//        backgroundView.addShadow(radius: kFitWidth(8))
        arrowView.backgroundColor = .clear
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 1

        backgroundView.addSubview(stackView)
        addSubview(backgroundView)
        addSubview(arrowView)
        // Apply shadow to the whole popup including the arrow
//        addShadow(opacity: 0.2,radius: kFitWidth(8))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let arrowHeight: CGFloat = kFitWidth(4)
        let arrowWidth: CGFloat = kFitWidth(12)

        if arrowDirection == .up {
//            arrowView.frame = CGRect(x: (bounds.width - arrowWidth) / 2, y: 0, width: arrowWidth, height: arrowHeight)
            let x = max(arrowWidth / 2, min(arrowCenterX, bounds.width - arrowWidth / 2))
            arrowView.frame = CGRect(x: x - arrowWidth / 2 - kFitWidth(5), y: 0, width: arrowWidth, height: arrowHeight)
            backgroundView.frame = CGRect(x: 0, y: arrowHeight, width: bounds.width, height: bounds.height - arrowHeight)
            arrowView.direction = .up
        } else {
            backgroundView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - arrowHeight)
//            arrowView.frame = CGRect(x: (bounds.width - arrowWidth) / 2, y: bounds.height - arrowHeight, width: arrowWidth, height: arrowHeight)
            let x = max(arrowWidth / 2, min(arrowCenterX, bounds.width - arrowWidth / 2))
            arrowView.frame = CGRect(x: x - arrowWidth / 2 - kFitWidth(5), y: bounds.height - arrowHeight, width: arrowWidth, height: arrowHeight)
            arrowView.direction = .down
        }

        stackView.frame = backgroundView.bounds
        stackView.layer.cornerRadius = kFitWidth(8)
        stackView.clipsToBounds = true
        
        backgroundView.addShadow(radius: kFitWidth(8))
//        updateShadowPath()
    }

    /// Combine arrow and background into one shadow path
    private func updateShadowPath() {
        let roundedPath = UIBezierPath(roundedRect: backgroundView.frame,
                                       cornerRadius: backgroundView.layer.cornerRadius)
        let arrowPath = UIBezierPath()
        if arrowDirection == .up {
            arrowPath.move(to: CGPoint(x: arrowView.frame.midX, y: arrowView.frame.minY))
            arrowPath.addLine(to: CGPoint(x: arrowView.frame.maxX, y: arrowView.frame.maxY))
            arrowPath.addLine(to: CGPoint(x: arrowView.frame.minX, y: arrowView.frame.maxY))
        } else {
            arrowPath.move(to: CGPoint(x: arrowView.frame.midX, y: arrowView.frame.maxY))
            arrowPath.addLine(to: CGPoint(x: arrowView.frame.maxX, y: arrowView.frame.minY))
            arrowPath.addLine(to: CGPoint(x: arrowView.frame.minX, y: arrowView.frame.minY))
        }
        arrowPath.close()
        roundedPath.append(arrowPath)
        layer.shadowPath = roundedPath.cgPath
        layer.masksToBounds = false
    }

    func configureButtons(_ items: [(String, () -> Void)]) {
        buttonActions = items
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (title, action) in items {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
            button.backgroundColor = .white
            button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.tag = stackView.arrangedSubviews.count
            stackView.addArrangedSubview(button)
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < buttonActions.count else { return }
        buttonActions[index].handler()
    }
}
