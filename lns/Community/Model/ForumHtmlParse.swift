//
//  ForumHtmlParse.swift
//  lns
//
//  Created by Elavatine on 2024/11/6.
//

class ForumHtmlParse: NSObject {
    typealias Item = (text: String, html: String)
    
    // current document
    var document: Document = Document.init("")
    
    var itemsHead: [Item] = []
    var itemsStyle: [Item] = []
    var itemsCss: [Item] = []
    
    var style = ""
//    var contentHead = "<html lang=\"zh-CN\">\n <head>\n  <meta charset=\"UTF-8\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    var contentHead = ""
    
    //解析网页链接，返回元素数组
    func parseUrl(urlString:String) -> [ForumHtmlModel] {
        var divArray:[ForumHtmlModel] = [ForumHtmlModel]()
        
        self.downloadHTML(urlString: urlString)
        
        for item in itemsCss{
            let model = ForumHtmlModel()
            DLLog(message: "item.html:\(item.html)")
            if item.html.contains("<p>") && item.html.contains("</p>") && !item.html.contains("<p></p>") && !item.html.contains("<p> </p>"){
                model.type = .text
                model.htmlString = "<html lang=\"zh-CN\">" + contentHead + item.html + "</html>"
                divArray.append(model)
            }else if item.html.contains("<img"){
                model.type = .img
                model.imgUrl = self.dealHtmlForImage(htmlString: item.html)
                divArray.append(model)
            }else if item.html.contains("<video"){
                model.type = .video
                model.videoUrl = self.dealHtmlForVideo(htmlString: item.html)
                divArray.append(model)
            }
        }
        
        return divArray
    }
    
    //MARK: 解析获取图片地址
    func dealHtmlForImage(htmlString:String) -> String{
        var imgString = ""
        
        let htmlArr = htmlString.components(separatedBy: " ")
        for i in 0..<htmlArr.count{
            let str = htmlArr[i]
            if str.contains("src="){
                let str1 = str.replacingOccurrences(of: "src=\"", with: "")
                imgString = str1.replacingOccurrences(of: "\"", with: "")
                break
            }
        }
        
        return imgString
    }
    //MARK: 解析获取视频地址
    func dealHtmlForVideo(htmlString:String) -> String{
        var imgString = ""
        
        let htmlArr = htmlString.components(separatedBy: " ")
        for i in 0..<htmlArr.count{
            let str = htmlArr[i]
            if str.contains("src="){
                let str1 = str.replacingOccurrences(of: "src=\"", with: "")
                imgString = str1.replacingOccurrences(of: "\"", with: "")
                break
            }
        }
        
        return imgString
    }
    //MARK: 解析CSS
    //Parse CSS selector
    func parseCss() {
        do {
            //empty old items
            itemsCss = []
            // firn css selector
            let elements: Elements = try document.select("p,img,video")
            //transform it into a local object (Item)
            for element in elements {
                let text = try element.text()
                let html = try element.outerHtml()
                itemsCss.append(Item(text: text, html: html))
            }
        } catch let error {
            DLLog(message: "\(error)")
        }
    }
    //MARK: 解析style
    //Parse Style selector
    func parseStyle() {
        do {
            //empty old items
            itemsStyle = []
            // firn css selector
            let elements: Elements = try document.select("style")
            //transform it into a local object (Item)
            for element in elements {
                let text = try element.text()
                let html = try element.outerHtml()
                itemsStyle.append(Item(text: text, html: html))
            }
            if itemsStyle.count > 0 {
                style = itemsStyle[0].html
            }
        } catch let error {
            DLLog(message: "\(error)")
        }
    }
    //MARK: 解析head
    //Parse Head selector
    func parseHead() {
        do {
            //empty old items
            itemsHead = []
            // firn css selector
            let elements: Elements = try document.select("head")
            //transform it into a local object (Item)
            for element in elements {
                let text = try element.text()
                let html = try element.outerHtml()
                itemsHead.append(Item(text: text, html: html))
            }
            if itemsHead.count > 0 {
                contentHead = itemsHead[0].html
            }
        } catch let error {
            DLLog(message: "\(error)")
        }
    }
    //Download HTML
    func downloadHTML(urlString:String) {
        // url string to URL
        guard let url = URL(string: urlString) else {
            // an error occurred
            DLLog(message: "ForumHtmlParse Error: \(urlString) doesn't seem to be a valid URL")
            return
        }

        do {
            // content of url
            let html = try String.init(contentsOf: url)
            // parse it into a Document
            document = try SwiftSoup().parse(html)
            // parse css query
            parseHead()
//            parseStyle()
            parseCss()
        } catch let error {
            // an error occurred
            DLLog(message: "ForumHtmlParse Error: \(error)")
        }

    }
}
