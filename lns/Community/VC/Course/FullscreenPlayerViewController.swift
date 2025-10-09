//
//  FullscreenPlayerViewController.swift
//  lns
//
//  Created by Elavatine on 2025/7/17.
//

import AVKit

class FullscreenPlayerViewController: AVPlayerViewController {
    private var isLandscape = false
    private let fullScreenButton: UIButton = {
        let btn = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        } else {
            btn.setTitle("全屏", for: .normal)
        }
        btn.tintColor = .white
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupButton()
//        addObserver(self, forKeyPath: #keyPath(showsPlaybackControls), options: [.initial, .new], context: nil)
    }

//    deinit {
//        removeObserver(self, forKeyPath: #keyPath(showsPlaybackControls))
//    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//       if keyPath == #keyPath(showsPlaybackControls) {
//           if let visible = change?[.newKey] as? Bool {
//               fullScreenButton.isHidden = !visible
//           }
//           return
//       }
//       super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//   }

    private func setupButton() {
        guard let overlay = contentOverlayView else { return }
        overlay.addSubview(fullScreenButton)
        fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            fullScreenButton.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -15),
//            fullScreenButton.bottomAnchor.constraint(equalTo: overlay.bottomAnchor, constant: -15),
//            fullScreenButton.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 15),
//                        fullScreenButton.bottomAnchor.constraint(equalTo: overlay.bottomAnchor, constant: -60),
            
            fullScreenButton.widthAnchor.constraint(equalToConstant: 30),
            fullScreenButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        fullScreenButton.addTarget(self, action: #selector(toggleFullScreen), for: .touchUpInside)
    }

    @objc private func toggleFullScreen() {
        isLandscape.toggle()
        if isLandscape {
            UserConfigModel.shared.allowedOrientations = .landscape
            UserConfigModel.shared.userInterfaceOrientation = .landscapeRight
        } else {
            UserConfigModel.shared.allowedOrientations = .portrait
            UserConfigModel.shared.userInterfaceOrientation = .portrait
        }
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserConfigModel.shared.allowedOrientations = .portrait
        UserConfigModel.shared.userInterfaceOrientation = .portrait
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UserConfigModel.shared.allowedOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UserConfigModel.shared.userInterfaceOrientation
    }
}
