//
//  VdoTestVC.swift
//  lns
//
//  Created by Elavatine on 2025/3/25.
//
//
//import VdoFramework
//import AVKit
//
//class VdoTestVC: ViewController {
//    
//    private var asset: VdoAsset?
//    private let playerViewController = AVPlayerViewController()
//
//    private var otp = "20160313versUSE323HaZx3xzS1dLOHaU6VmiuXpViFxXsyAiSR7FhreZ07I206I"
//    private var playbackInfo = "eyJ2aWRlb0lkIjoiY2E3ZWI1MWUxMjIxNGU3NWJiNWQwZjNmMzI1OTNiMDAifQ=="
//    private var videoId = "ca7eb51e12214e75bb5d0f3f32593b00"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        initUI()
//        
//        // Setting the AVPlayer controller in a subview
//        self.playerViewController.view.frame = self.videoView.bounds
//        self.playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.addChild(self.playerViewController)
//        self.videoView.addSubview(self.playerViewController.view)
//        self.playerViewController.didMove(toParent: self)
//        // create a delegate for tracking player state
//            VdoCipher.setPlaybackDelegate(delegate: self)
//        
//        VdoAsset.createAsset(videoId: videoId) { asset, error in
//            if let error = error {
//                // Remove buffering icon (if present) and show error
//                print(error)
//            } else {
//                self.asset = asset // keep this asset reference for your use
//                print("asset created")
//                DispatchQueue.main.async {
//                    // enable the UI for playing. remove buffering icon if showing
//                    self.playOnlineButton.isEnabled = true
//                }
//            }
//        }
//    }
//    
//    lazy var videoView: UIView = {
//        let vi = UIView()
//        
//        return vi
//    }()
//    lazy var playOnlineButton: UIButton = {
//        let btn = UIButton()
//        btn.addTarget(self, action: #selector(playVideoTapped), for: .touchUpInside)
//        btn.isEnabled = false
//        btn.setTitle("播放", for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .disabled)
//        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.layer.cornerRadius = kFitWidth(24)
//        
//        return btn
//    }()
//}
//
//extension VdoTestVC{
//    @objc func playVideoTapped(_ sender: UIButton) {
//        let controller = VdoCipher.getVdoPlayerViewController()
//        // create a delegate for tracking player UI state (Optional can be skipped)
//        VdoCipher.setUIPlayerDelegate(self)
//        self.asset?.playOnline(otp: self.otp, playbackInfo: self.playbackInfo)
//        
//        // to show full screen Video UI Player
//        presentFullScreen(uiPlayer: controller)
//    }
//   
//    // Full screen player
//    private func presentFullScreen(uiPlayer controller: UIViewController) {
//         self.present(controller, animated: true, completion: nil)
//    }
//}
//
//extension VdoTestVC:VdoPlayerViewControllerDelegate{
//    @objc func playOnline(_ sender: Any) {
//        guard let asset = asset else {
//            return print("not ready for playback")
//        }
//        asset.playOnline(otp: otp, playbackInfo: playbackInfo)
//    }
//    
//    func initUI() {
//        view.addSubview(playOnlineButton)
//        view.addSubview(videoView)
//        
//        
//        videoView.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.width.height.equalTo(kFitWidth(300))
//            make.top.equalTo(kFitWidth(100))
//        }
//        
//        playOnlineButton.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(videoView.snp.bottom).offset(kFitWidth(50))
//            make.width.equalTo(kFitWidth(343))
//            make.height.equalTo(kFitWidth(48))
//        }
//    }
//}
//
//extension VdoTestVC: AssetPlaybackDelegate {
//    
//    func streamPlaybackManager(playerReadyToPlay player: AVPlayer) {
//        player.play()
//    }
//    
//    func streamPlaybackManager(playerCurrentItemDidChange player: AVPlayer) {
//        
//    }
//    
//    func streamLoadError(error: VdoFramework.VdoError) {
//        DLLog(message: "streamLoadError:\(error)")
//    }
//}
