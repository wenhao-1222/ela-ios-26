//
//  ZFPlayerModel.swift
//  lns
//
//  Created by Elavatine on 2025/2/7.
//

class ZFPlayerModel {
    
    static let shared = ZFPlayerModel()
    
    private init(){
        self.player = ZFPlayerController()
        playerManager.scalingMode = .aspectFit
        self.player.replaceCurrentPlayerManager(playerManager)
    }
    
    var playerManager = ZFAVPlayerManager()
    var player = ZFPlayerController()
    
    func addToForumDetail(containerView:UIView) {
//        self.player = ZFPlayerController.player(withPlayerManager: playerManager, containerView: containerView)
        self.player.addPlayerView(toContainerView: containerView)
        self.player.stopWhileNotVisible = true
        self.player.customAudioSession = true
        self.player.allowOrentitaionRotation = false
        self.player.forceDeviceOrientation = true
    }
    func addToTableView(tableView:UITableView, tag:Int) {
        self.player = ZFPlayerController.player(with: tableView, playerManager: playerManager, containerViewTag: tag)
        self.player.playerDisapperaPercent = 0.1
        self.player.playerApperaPercent = 1.0
        self.player.stopWhileNotVisible = true
        self.player.customAudioSession = true
        self.player.resumePlayRecord = true
        
        self.player.isWWANAutoPlay = true
        playerManager.scalingMode = .aspectFill
        self.player.allowOrentitaionRotation = false
        if #available(iOS 16.0, *) {
            self.player.forceDeviceOrientation = false
        }
    }
}
