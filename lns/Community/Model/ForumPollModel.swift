//
//  ForumPollModel.swift
//  lns
//
//  Created by Elavatine on 2024/12/12.
//
import Photos

class ForumPollModel: NSObject {
    
    var title = ""
    var imageUrl = ""
    var photoAsset:PHAsset = PHAsset()
    var image = UIImage()
    var hasPhoto = false
    var sn = ""
    var isSelect = false
}
