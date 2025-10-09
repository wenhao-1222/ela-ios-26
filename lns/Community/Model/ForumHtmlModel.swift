//
//  ForumHtmlModel.swift
//  lns
//
//  Created by Elavatine on 2024/11/6.
//

//富文本元素的类型
enum FORUM_HTML_TYPE {
    case text
    case img
    case video
}

class ForumHtmlModel: NSObject {
    
    var type = FORUM_HTML_TYPE.text
    
    var htmlString = ""
    
    var imgUrl = ""
    
    var videoUrl = ""
    
    func printMsg() {
        DLLog(message: "\(self.type) -------------")
        if self.type == .text{
            DLLog(message: "\(self.htmlString)")
        }else if self.type == .img{
            DLLog(message: "\(self.imgUrl)")
        }else {
            DLLog(message: "\(self.videoUrl)")
        }
    }
}
