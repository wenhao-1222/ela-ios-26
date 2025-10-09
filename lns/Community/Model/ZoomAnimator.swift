//
//  ZoomAnimator.swift
//  lns
//
//  Created by Elavatine on 2024/12/31.
//  ForumListTableViewCell
//ForumOfficialDetailVC

class ZoomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let toVc = transitionContext.viewController(forKey: .to) as! ForumOfficialDetailVC
//        let fromVc = transitionContext.viewController(forKey: .from) as? ForumVC
        
        guard let toVc = transitionContext.viewController(forKey: .to) as? ForumOfficialDetailVC,
              let fromVc = transitionContext.viewController(forKey: .from) as? ForumVC else {
            transitionContext.completeTransition(true)
            return
        }

        let containerView = transitionContext.containerView
//        let cell = fromVc?.forumListVm.tapTableViewCell
//        let snapShotView = cell?.imageView?.snapshotView(afterScreenUpdates: false)
//        
//        snapShotView?.frame = containerView.convert(cell!.imgView.frame, from: cell!.imgView.superview)
//        cell?.imgView.isHidden = true
        
        let cell = fromVc.forumListVm.tapTableViewCell
        guard let snapShotView = cell.imgView.snapshotView(afterScreenUpdates: false) else {
            transitionContext.completeTransition(true)
            return
        }

        snapShotView.frame = containerView.convert(cell.imgView.frame, from: cell.imgView.superview)
        cell.imgView.isHidden = true

        toVc.view.frame = transitionContext.finalFrame(for: toVc)
        toVc.view.alpha = 0
//        toVc.videoVm.isHidden = true
        
        let targetView: UIView
        if toVc.model.contentType == .VIDEO {
            targetView = toVc.videoVm
            toVc.videoVm.isHidden = true
        } else {
            targetView = toVc.bannerImgVm
            toVc.bannerImgVm.isHidden = true
        }
        
        containerView.addSubview(toVc.view)
//        containerView.addSubview(snapShotView!)
//        
//        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0,options: .curveLinear) {
//            snapShotView?.frame = containerView.convert(toVc.videoVm.frame, from: toVc.view)
//
//        } completion: { t in
//            cell?.imgView.isHidden = false
//            toVc.videoVm.isHidden = false
//            snapShotView?.removeFromSuperview()
//            
//            
//            transitionContext.completeTransition(transitionContext.transitionWasCancelled)
//        }
        containerView.addSubview(snapShotView)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveLinear) {
                snapShotView.frame = containerView.convert(targetView.frame, from: toVc.view)
            toVc.view.alpha = 1
        } completion: { _ in
            cell.imgView.isHidden = false
            if toVc.model.contentType == .VIDEO {
                toVc.videoVm.isHidden = false
            } else {
                toVc.bannerImgVm.isHidden = false
            }
            snapShotView.removeFromSuperview()

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }
}
