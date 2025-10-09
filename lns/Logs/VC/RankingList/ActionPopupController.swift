//
//  ActionPopupController.swift
//  lns
//
//  Created by Elavatine on 2025/7/3.
//

import UIKit

class ActionPopupController: UIViewController {

    private let popupView = ActionPopupView()
    private let backgroundView = ActionPopupBackgroundView()
    private var popupSize = CGSize(width: 150, height: 44 * 3 + 10)
    /// vertical offset between popup and anchor
    private let arrowSpacing: CGFloat = 4
    private var dismissHandler: (() -> Void)?

    init(anchor: CGPoint, in container: UIView, actions: [(String, () -> Void)]) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        self.view.isUserInteractionEnabled = true
        popupSize = CGSize(width: kFitWidth(66), height: kFitWidth(44)*CGFloat(actions.count)+kFitWidth(10))
        setupBackgroundTap(in: container)
        setupPopup(anchor: anchor, in: container, actions: actions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBackgroundTap(in container: UIView) {
        container.isUserInteractionEnabled = true
        backgroundView.frame = container.bounds
        backgroundView.backgroundColor = .clear
        backgroundView.isUserInteractionEnabled = true
        backgroundView.outsideTapHandler = { [weak self] in
            self?.dismissPopup()
        }

        container.addSubview(backgroundView)

//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
//        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
//        tap.cancelsTouchesInView = false
//        backgroundView.addGestureRecognizer(tap)
    }

    private func setupPopup(anchor: CGPoint, in container: UIView, actions: [(String, () -> Void)]) {
        let screenBounds = UIScreen.main.bounds
        let spaceAbove = anchor.y
        let spaceBelow = screenBounds.height - anchor.y

        let showAbove = spaceBelow < popupSize.height && spaceAbove >= popupSize.height
        let arrowDirection: ArrowDirection = showAbove ? .down : .up

        popupView.removeFromSuperview()
        popupView.frame = CGRect(origin: .zero, size: popupSize)
        popupView.configureButtons(actions)
        popupView.arrowDirection = arrowDirection

        // 定位popupView
        var originX = anchor.x - popupSize.width / 2
        originX = max(10, min(originX, screenBounds.width - popupSize.width - kFitWidth(10)))

        let arrowCenterX = anchor.x - originX
        var originY: CGFloat
        if showAbove {
//            originY = anchor.y - popupSize.height - kFitWidth(8)
            originY = anchor.y - popupSize.height - arrowSpacing - kFitWidth(30)
        } else {
//            originY = anchor.y + kFitWidth(8)
            originY = anchor.y //+ arrowSpacing
        }

        popupView.frame.origin = CGPoint(x: originX, y: originY)
        popupView.arrowCenterX = arrowCenterX
        popupView.alpha = 0
        popupView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        backgroundView.addSubview(popupView)
        backgroundView.popupView = popupView

        // 动画呈现
        UIView.animate(withDuration: 0.25) {
            self.popupView.alpha = 1
            self.popupView.transform = .identity
        }
    }

    @objc func dismissPopup() {
        UIView.animate(withDuration: 0.2, animations: {
            self.popupView.alpha = 0
            self.popupView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.backgroundView.removeFromSuperview()
            self.dismissHandler?()
        }
    }

    func onDismiss(_ handler: @escaping () -> Void) {
        self.dismissHandler = handler
    }
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: backgroundView)
        if !popupView.frame.contains(location) {
            dismissPopup()
        }
    }
}
