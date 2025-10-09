//
//  PlayerContainerView.swift
//  lns
//
//  Created by Elavatine on 2025/4/10.
//

/// 视图容器, 类似 ZFPlayerPresentView
class PlayerContainerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    private var avLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    func setPlayer(player: AVPlayer) {
        avLayer.player = player
        avLayer.videoGravity = .resizeAspect
    }
}
