//
//  CoursePlayerViewController.swift
//  lns
//
//  Created by Elavatine on 2025/7/17.
//

import UIKit

class CoursePlayerViewController: UIViewController {
    var player = ZFPlayerController()
    var playerManager = ZFAVPlayerManager()
//    let controlView = CourseCoverControlView()
    var videoURL: URL?
    private var panStart: CGPoint = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPlayer()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                view.addGestureRecognizer(pan)
        NotificationCenter.default.addObserver(self, selector: #selector(endFullAction), name: NSNotification.Name(rawValue: "tutorialEnterFullScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitFullAction), name: NSNotification.Name(rawValue: "tutorialExitFullScreen"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    lazy var controlView: CourseCoverControlView = {
        let vi = CourseCoverControlView()
        vi.portraitControlView.isCalSafeArea = true
        vi.prepareShowControlView = true
//        vi.autoFadeTimeInterval = 0.2
        vi.portraitControlView.shareVideoBtn.isHidden = true
//        vi.portraitControlView.backBtn.isHidden = true
//        vi.landScapeControlView.backBtn.isHidden = true
        vi.fastViewAnimated = true
        vi.prepareShowLoading = true
        vi.portraitControlView.nextBtn.isHidden = true
        vi.landScapeControlView.nextBtn.isHidden = true
        vi.customDisablePanMovingDirection = true
//        vi.portraitControlView.updateUIForCourseCover()
        vi.portraitControlView.pauseManualTapBlock = {(isPlay)in
//            if isPlay == false{
//                self.isManualPause = false
//            }else{
//                self.isManualPause = true
//            }
        }
        vi.bottomPgrogress.isHidden = true
        vi.backBtnClickCallback = { [weak self] in
            self?.dismiss(animated: true)
        }
        return vi
    }()

    private func setupPlayer() {
        playerManager.scalingMode = .aspectFit
        player = ZFPlayerController.player(withPlayerManager: playerManager, containerView: view)
        player.controlView = controlView
        player.customAudioSession = true
        player.shouldAutoPlay = false
        player.forceDeviceOrientation = true
        player.disablePanMovingDirection = .vertical
        player.allowOrentitaionRotation = false
        if let url = videoURL {
            player.assetURL = url
            player.currentPlayerManager.play?()
        }
        player.orientationWillChange = { [weak self] _, _ in
            self?.setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 16.0, *) {
            } else {
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }

    @objc private func endFullAction() {
        UserConfigModel.shared.userInterfaceOrientation = .landscapeRight
        UserConfigModel.shared.allowedOrientations = .landscape
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
        }
    }

    @objc private func exitFullAction() {
        UserConfigModel.shared.userInterfaceOrientation = .portrait
        UserConfigModel.shared.allowedOrientations = .portrait
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UserConfigModel.shared.allowedOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UserConfigModel.shared.userInterfaceOrientation
    }
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view)
        switch pan.state {
        case .began:
            panStart = view.center
        case .changed:
            if translation.y > 0 {
                let percent = translation.y / view.bounds.height
                let scale = max(0.8, 1 - percent)
                view.transform = CGAffineTransform(translationX: 0, y: translation.y).scaledBy(x: scale, y: scale)
                view.backgroundColor = UIColor.black.withAlphaComponent(max(0, 1 - percent))
            }
        case .ended, .cancelled:
            let velocity = pan.velocity(in: view)
            if translation.y > 100 || velocity.y > 500 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                    self.view.alpha = 0
                    self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
                }) { _ in
                    self.dismiss(animated: false)
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.view.transform = .identity
                    self.view.backgroundColor = .black
                }
            }
        default:
            break
        }
    }
}
