//
//  WXUtil.swift
//  lns
//
//  Created by LNS2 on 2024/3/21.
//

import Foundation

enum ShareType {
    case session
    case timeline
    case favorite
}

class WXUtil {
    func wxLogin() {
        if WXApi.isWXAppInstalled() {
            let rep = SendAuthReq()
            //这两个参数 可以照抄 第一个是固定的，第二个随意写
            rep.scope = "snsapi_userinfo"
            rep.state = "wx_oauth_authorization_state"
            WXApi.send(rep, completion: nil)
          }
         else {
             DLLog(message: "未安装微信应用或版本过低")
         }
    }
    /*
     分享文本
     */
    func shareText(text:String, to scene:ShareType) {
        let req = SendMessageToWXReq()
        req.text = text
        req.bText = true
        
        switch scene {
        case .session:
            req.scene = Int32(WXSceneSession.rawValue)
            
        case .timeline:
            req.scene = Int32(WXSceneTimeline.rawValue)
            
        case .favorite:
            req.scene = Int32(WXSceneFavorite.rawValue)
            
        }
        WXApi.send(req)
    }
    
    /*
     分享图片
     */
    func shareImage(image:UIImage,thumbImage:UIImage,title:String,description:String,to scene: ShareType) {
        let message = WXMediaMessage()
        message.setThumbImage(thumbImage)
        message.title = title
        message.description = description
        
        let obj = WXImageObject()
        
        // 将UIImage转换为PNG格式的Data
        if let pngData = image.pngData() {
            // 使用pngData
            print("转换成PNG格式的数据成功，数据长度：\(pngData.count)")
            obj.imageData = pngData
            message.mediaObject = obj
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            
            switch scene {
            case .session:
                req.scene = Int32(WXSceneSession.rawValue)
                
            case .timeline:
                req.scene = Int32(WXSceneTimeline.rawValue)
                
            case .favorite:
                req.scene = Int32(WXSceneFavorite.rawValue)
                
            }
            WXApi.send(req)
        } else {
            print("转换成PNG格式的数据失败")
        }
    }
    /*
     分享音乐
     */
    func shareMusic(to scene: ShareType) {
          let message = WXMediaMessage()
          message.title = "音乐标题"
          message.description = "音乐描述"
          message.setThumbImage(UIImage())
 
          let obj = WXMusicObject()
          obj.musicUrl = "音乐链接"
          obj.musicLowBandUrl = obj.musicUrl

         obj.musicDataUrl = "音乐数据链接地址"
         obj.musicLowBandDataUrl = obj.musicDataUrl
         message.mediaObject = obj

         let req = SendMessageToWXReq()
         req.bText = false
         req.message = message
         switch scene {
         case .session:
             req.scene = Int32(WXSceneSession.rawValue)
         case .timeline:
             req.scene = Int32(WXSceneTimeline.rawValue)
         case .favorite:
             req.scene = Int32(WXSceneFavorite.rawValue)
         }

         WXApi.send(req)
     }
    /*
     分享视频
     */
     func shareVideo(to scene: ShareType) {
          let message = WXMediaMessage()
          message.title = "视频标题"
          message.description = "视频描述"
          message.setThumbImage(UIImage())
 
          let obj = WXVideoObject()
          obj.videoUrl = "视频链接地址"
         obj.videoLowBandUrl = "低分辨率视频地址"

         let req = SendMessageToWXReq()
         req.bText = false
         req.message = message

         switch scene {
         case .session:
             req.scene = Int32(WXSceneSession.rawValue)
         case .timeline:
             req.scene = Int32(WXSceneTimeline.rawValue)
         case .favorite:
             req.scene = Int32(WXSceneFavorite.rawValue)
         }

         WXApi.send(req)
     }
    /*
     分享URL
     */
     func shareURL(to scene: ShareType) {
     
          let message = WXMediaMessage()
          message.title = "title"
          message.description = "description"
          message.setThumbImage(UIImage())
 
          let obj = WXWebpageObject()
          obj.webpageUrl = "http://www.baidu.com"
         message.mediaObject = obj

         let req = SendMessageToWXReq()
         req.bText = false
         req.message = message

         switch scene {
         case .session:
             req.scene = Int32(WXSceneSession.rawValue)
         case .timeline:
             req.scene = Int32(WXSceneTimeline.rawValue)
         case .favorite:
             req.scene = Int32(WXSceneFavorite.rawValue)
         }

         WXApi.send(req)
     }
}
