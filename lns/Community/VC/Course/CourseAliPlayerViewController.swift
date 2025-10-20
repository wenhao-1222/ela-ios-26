////
////  CourseAliPlayerViewController.swift
////  lns
////
////  Created by LNS2 on 2025/10/20.
////
//
//import UIKit
//import AliyunPlayer
//
//class CourseAliPlayerViewController: UIViewController {
//
//    var videoURL: URL?
//
//    private var aliPlayer: AliPlayer?
//    private let playerContainerView = UIView()
//    private var controlView: TutorialVideoSwiftControlView?
//    private lazy var dismissPanGesture: UIPanGestureRecognizer = {
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan(_:)))
//        pan.delegate = self
//        pan.cancelsTouchesInView = false
//        return pan
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//        setupUI()
//        setupPlayer()
//        prepareToPlay()
//        view.addGestureRecognizer(dismissPanGesture)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        controlView?.frame = playerContainerView.bounds
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        if isBeingDismissed || isMovingFromParent {
//            releasePlayer()
//        }
//    }
//
//    deinit {
//        releasePlayer()
//    }
//
//    private func setupUI() {
//        playerContainerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(playerContainerView)
//
//        NSLayoutConstraint.activate([
//            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            playerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
//            playerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    private func setupPlayer() {
//        let player = AliPlayer()
//        player.playerView = playerContainerView
//        player.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT
//        player.isAutoPlay = false
//        player.enableHardwareDecoder = true
//        aliPlayer = player
//
//        let control = TutorialVideoSwiftControlView(player: player, frame: playerContainerView.bounds)
//        control.backTapBlock = { [weak self] in
//            self?.dismiss(animated: true)
//        }
//        control.bottomToolVm.fullScreenButton.isHidden = true
//        control.bottomToolVm.nextButton.isHidden = true
//        control.topToolVm.shareButton.isHidden = true
//        playerContainerView.addSubview(control)
//        controlView = control
//    }
//
//    private func prepareToPlay() {
//        guard let url = videoURL, let player = aliPlayer else { return }
//        guard let urlSource = AVPUrlSource().url(with: url.absoluteString) else { return }
//        player.setUrlSource(urlSource)
//        player.prepare()
//        player.start()
//    }
//
//    private func releasePlayer() {
//        guard let player = aliPlayer else { return }
//        player.stop()
//        player.setPlayerView(nil)
//        player.destroy()
//        aliPlayer = nil
//    }
//
//    @objc private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: view)
//        switch gesture.state {
//        case .began:
//            break
//        case .changed:
//            if translation.y > 0 {
//                let progress = min(1, translation.y / view.bounds.height)
//                let scale = max(0.8, 1 - progress * 0.2)
//                view.transform = CGAffineTransform(translationX: 0, y: translation.y).scaledBy(x: scale, y: scale)
//                view.backgroundColor = UIColor.black.withAlphaComponent(max(0, 1 - progress))
//            }
//        case .ended, .cancelled:
//            let velocity = gesture.velocity(in: view)
//            if translation.y > 120 || velocity.y > 800 {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
//                    self.view.alpha = 0
//                    self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
//                }) { _ in
//                    self.dismiss(animated: false)
//                }
//            } else {
//                UIView.animate(withDuration: 0.25) {
//                    self.view.transform = .identity
//                    self.view.backgroundColor = .black
//                    self.view.alpha = 1
//                }
//            }
//        default:
//            break
//        }
//    }
//}
//
//extension CourseAliPlayerViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard gestureRecognizer === dismissPanGesture, let pan = gestureRecognizer as? UIPanGestureRecognizer else {
//            return true
//        }
//        let velocity = pan.velocity(in: view)
//        return abs(velocity.y) > abs(velocity.x)
//    }
//}
