//
//  BottomCardAnimator.swift
//  lns
//
//  Created by LNS2 on 2025/10/27.
//

final class BottomCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum Style { case present, dismiss }
    let style: Style
    let duration: TimeInterval = 0.35

    init(style: Style) { self.style = style }

    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval { duration }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let container = ctx.containerView

        switch style {
        case .present:
            guard let toVC = ctx.viewController(forKey: .to),
                  let toView = toVC.view else { return }
            container.addSubview(toView)

            let finalFrame = ctx.finalFrame(for: toVC)
            toView.frame = finalFrame.offsetBy(dx: 0, dy: container.bounds.height - finalFrame.minY)
            toView.layer.masksToBounds = true
            toView.layer.cornerRadius = 16

            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0.2,
                           options: [.curveEaseInOut]) {
                toView.frame = finalFrame
            } completion: { finished in
                ctx.completeTransition(finished)
            }

        case .dismiss:
            guard let fromVC = ctx.viewController(forKey: .from),
                  let fromView = fromVC.view else { return }
            let startFrame = fromView.frame
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                fromView.frame = startFrame.offsetBy(dx: 0, dy: container.bounds.height - startFrame.minY)
            } completion: { finished in
                ctx.completeTransition(finished)
            }
        }
    }
}
