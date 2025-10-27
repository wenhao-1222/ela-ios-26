//
//  BottomCardPresentationController.swift
//  lns
//
//  Created by LNS2 on 2025/10/27.
//

final class BottomCardPresentationController: UIPresentationController {
    private let dimmingView = UIView()
    private let cardHeight: CGFloat

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         cardHeight: CGFloat) {
        self.cardHeight = cardHeight
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0
        dimmingView.isUserInteractionEnabled = true
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @objc private func handleTap() {
        presentedViewController.dismiss(animated: true)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        let h = cardHeight
        return CGRect(x: 0,
                      y: container.bounds.height - h,
                      width: container.bounds.width,
                      height: h)
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView else { return }
        // 背景遮罩
        dimmingView.frame = container.bounds
        container.addSubview(dimmingView)

        // 缩放底下的 presenting VC
        let scale: CGFloat = 0.94
        let corner: CGFloat = 12

        presentingViewController.view.layer.masksToBounds = true
        let animations = {
            self.dimmingView.alpha = 1
            self.presentingViewController.view.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.presentingViewController.view.layer.cornerRadius = corner
        }
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in animations() })
        } else {
            animations()
        }
    }

    override func dismissalTransitionWillBegin() {
        let animations = {
            self.dimmingView.alpha = 0
            self.presentingViewController.view.transform = .identity
            self.presentingViewController.view.layer.cornerRadius = 0
        }
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in animations() })
        } else {
            animations()
        }
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
