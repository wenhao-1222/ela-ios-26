//
//  UserConfigModel.swift
//  lns
//
//  Created by Elavatine on 2024/12/5.
//

import Photos

//相册里面选择的类型
enum SELECT_ALBUM_TYPE {
    case IMAGE  //图片
    case VIDEO  //视频
}
@objcMembers
class UserConfigModel {
    
    static let shared = UserConfigModel()
    
    private init(){
        
    }
    
    var forumPictureNumMax = 9
    
    var forumVideoNumMax = 1
    
    var selectType = SELECT_ALBUM_TYPE.IMAGE
    
    var canChoiceVideo = true//是否能够选择视频
    
    var photsSelectCount = 0
    
    //教程的列表数据
    var tutorialsListArray = NSArray()
    var tutorialsDataDict = NSMutableDictionary()
    var tutorialsTypeDict = NSMutableDictionary()
    var tutorialsDataParse = false
    
//    var photoAssets:[PHAsset] = [PHAsset]()
    
    var allowedOrientations : UIInterfaceOrientationMask = .portrait
    var userInterfaceOrientation : UIInterfaceOrientation = .portrait
    
    //是否支持深色模式  info.plist  User Interface Style
    var overrideUserInterfaceStyle = UIUserInterfaceStyle.light
    
    var isMuted = true
    
    var browerIndex = 0
    ///弱网情形下，加载详情页面较慢，会出现连续点击重复push帖子详情的问题，加个开关做控制
    ///2025年02月17日14:36:07
    var canPushForumDetail = true
    
    var splashId = ""
}


extension UserConfigModel{
    
}
