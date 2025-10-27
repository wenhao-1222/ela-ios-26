//
//  BottomCardTransitioningDelegate.swift
//  lns
//
//  Created by LNS2 on 2025/10/27.
//

final class BottomCardTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var cardHeight: CGFloat = 420  // 你可以外部设置

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        BottomCardPresentationController(presentedViewController: presented,
                                         presenting: presenting,
                                         cardHeight: cardHeight)
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        BottomCardAnimator(style: .present)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        BottomCardAnimator(style: .dismiss)
    }
}
