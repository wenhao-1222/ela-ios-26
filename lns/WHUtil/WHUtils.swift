//
//  WHUtils.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation
//import mat

class WHUtils: NSObject {
    //字符串转双精度后去除小数点00
    static func convertStringToString(_ str: String) -> String? {
        if let doubleValue = Double(str) {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = doubleValue.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
            return numberFormatter.string(from: NSNumber(value: doubleValue))
        }
        return str
    }
    
    static func convertStringToStringOneDigitForce(_ str: String) -> String? {
        if let doubleValue = Double(str) {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 1
            numberFormatter.maximumFractionDigits = 1
            return numberFormatter.string(from: NSNumber(value: doubleValue))
        }
        return str
    }
    
    static func convertStringToStringOneDigit(_ str: String) -> String? {
        if let doubleValue = Double(str) {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 1
            return numberFormatter.string(from: NSNumber(value: doubleValue))
        }
        return str
    }
    
    static func convertStringToStringThreeDigit(_ str: String) -> String? {
        if let doubleValue = Double(str) {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 3
            return numberFormatter.string(from: NSNumber(value: doubleValue))
        }
        return str
    }
    static func convertStringToStringNoDigit(_ str: String) -> String? {
        if let doubleValue = Double(str) {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 0
            return numberFormatter.string(from: NSNumber(value: doubleValue))
        }
        return str
    }
    static func converObjToDouble(dict:NSDictionary,key:String) -> Double{
        return dict["\(key)"]as? Double ?? Double(dict["\(key)"]as? String ?? "0")!
    }
    static func getSpecArrayFromFoods(foodsDict:NSDictionary) -> NSArray{
        let specString = foodsDict["spec"]as? String ?? ""
        let spec = WHUtils.getArrayFromJSONString(jsonString: specString)
        return spec
    }
    static func getSpecDefaultFromFoods(foodsDict:NSDictionary) -> NSDictionary{
        let specString = foodsDict["spec"]as? String ?? ""
        let spec = WHUtils.getArrayFromJSONString(jsonString: specString)
        if spec.count > 0 {
            return spec[0]as? NSDictionary ?? [:]
        }
        return [:]
    }
    //JSONString转换为数组
    static func getArrayFromJSONString(jsonString:String) ->NSArray{
        if jsonString == "" || jsonString.isBlank || !jsonString.contains("["){
            return []
        }
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return array as! NSArray
        }
        return array as! NSArray
    }
    //JSONString转换为字典
    static func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    //    字典转换为JSONString
    static func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    //    数组转换为JSONString
    static func getJSONStringFromArray(array:NSArray) ->String{
        if !JSONSerialization.isValidJSONObject(array) {
            print("无法解析出JSONString")
            return""
        }
        let data :NSData! = try!JSONSerialization.data(withJSONObject: array, options: [])as  NSData?
        let JSONString = NSString(data: data as Data, encoding:String.Encoding.utf8.rawValue)
        return JSONString!as String
    }
    func getWidthOfString(string:String,font:UIFont,height:CGFloat) -> CGFloat {
        let dict = NSDictionary.init(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        
        let rect = (string as NSString).boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: height), options: [.truncatesLastVisibleLine,.usesLineFragmentOrigin,.usesFontLeading], attributes: dict as! [NSAttributedString.Key : Any], context: nil) as CGRect
        
        
        return rect.size.width
    }
    func getHeightOfString(string:String,font:UIFont,width:CGFloat) -> CGFloat {
        let dict = NSDictionary.init(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        
        let rect = (string as NSString).boundingRect(with: CGSize.init(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine,.usesLineFragmentOrigin,.usesFontLeading], attributes: dict as! [NSAttributedString.Key : Any], context: nil) as CGRect
        
        
        return rect.size.height
    }
    func getTextViewHeight(textView: UITextView, width: CGFloat) -> CGFloat {
        let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }
    /*
     // 使用示例
     let originalText = "这是一段包含中英文的示例文本，用于测试文本截断功能。"
     let width: CGFloat = 100.0
     let font = UIFont.systemFont(ofSize: 16)
     let truncatedResult = truncatedText(originalText, toWidth: width, font: font)
     */
    func truncatedText(_ inputText: String, toWidth width: CGFloat, font: UIFont) -> String {
        if inputText.count < 2 {
            return inputText
        }
        let labelAttributes: [NSAttributedString.Key: Any] = [.font: font]
        var truncatedText = inputText
        let nsString = NSString(string: truncatedText)
        var size = nsString.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: labelAttributes, context: nil).size
        
        while (size.width > width || size.height > kFitWidth(22)) && nsString.length > 0 {
            truncatedText.removeLast()
            let nsStringT = NSString(string: truncatedText)
            size = nsStringT.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: labelAttributes, context: nil).size
        }
        
        return truncatedText
    }
    ///手机号脱敏，考虑国际各个位数的手机号
    func maskPhoneNumber(_ phone: String) -> String {
        // 提取所有数字字符
        let digits = phone.filter { $0.isWholeNumber }
        let totalLength = digits.count

        // 定义保留位数规则
        let prefixCount: Int
        let suffixCount: Int

        if totalLength >= 8 {
            prefixCount = 3
            suffixCount = 4
        } else if totalLength >= 4 {
            prefixCount = 2
            suffixCount = 2
        } else {
            // 太短则不处理
            return phone
        }

        // 构建脱敏数字字符串
        let start = digits.prefix(prefixCount)
        let end = digits.suffix(suffixCount)
        let masked = String(repeating: "*", count: totalLength - prefixCount - suffixCount)
        let maskedDigits = String(start) + masked + String(end)

        // 将原始 phone 字符串中的数字替换为 maskedDigits
        var result = ""
        var digitIndex = maskedDigits.startIndex

        for char in phone {
            if char.isWholeNumber {
                result.append(maskedDigits[digitIndex])
                digitIndex = maskedDigits.index(after: digitIndex)
            } else {
                result.append(char) // 保留非数字字符如 +, -, 空格
            }
        }

        return result
    }
    func getImageSize(_ url: String?,imgWidthTar:CGFloat) -> CGSize {
        guard let urlStr = url else {
            return CGSize.zero
        }

        let tempUrl = URL(string: urlStr)
        let imageSourceRef = CGImageSourceCreateWithURL(tempUrl! as CFURL, nil)
        var imgWidth: CGFloat = imgWidthTar//kFitWidth(343)
        var imgHeight: CGFloat = 0

        if let imageSRef = imageSourceRef {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSRef, 0, nil)
            if let imageP = imageProperties {
                let imageDict = imageP as Dictionary
                let width = imageDict[kCGImagePropertyPixelWidth] as! CGFloat
                let height = imageDict[kCGImagePropertyPixelHeight] as! CGFloat
                
                imgHeight = imgWidth*height/width
                if imgHeight > imgWidth{
                    imgHeight = imgWidth
                    imgWidth = width/height*imgHeight
                }
            }
        }
        return CGSize(width: imgWidth, height: imgHeight)
    }
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
//    func getCurrentController() -> UIViewController? {
//        guard let window = UIApplication.shared.windows.first else {
//            return nil
//        }
//        var tempView: UIView?
//        for subview in window.subviews.reversed() {
//            if subview.classForCoder.description() == "UILayoutContainerView" {
//                tempView = subview
//                break
//            }
//        }
//        
//        if tempView == nil {
//            tempView = window.subviews.last
//        }
//        
//        var nextResponder = tempView?.next
//        var next: Bool {
//            return !(nextResponder is UIViewController) || nextResponder is UINavigationController || nextResponder is UITabBarController
//        }
//        
//        while next{
//            tempView = tempView?.subviews.first
//            if tempView == nil {
//                return nil
//            }
//            nextResponder = tempView!.next
//        }
//        return nextResponder as? UIViewController
//    }
    func createAttributedStringWithImage(image: UIImage, text: String) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 11, weight: .regular).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        
        let string = NSMutableAttributedString(string: text)
        string.append(attachmentString)
        
        return string
    }
    //底部的安全距离
    func getBottomSafeAreaHeight() -> CGFloat {
        var bottomPadding = CGFloat(0)
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            bottomPadding = window.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            bottomPadding = window.safeAreaInsets.bottom
        }
        return bottomPadding
    }
    //tabbar高度
    func getTabbarHeight() -> CGFloat {
        return getBottomSafeAreaHeight() + 49
        //        return (statusBarHeight==44 ? 83 : 49)
    }
    //导航栏高度
    func getNavigationBarHeight() -> CGFloat {
//        return getTopSafeAreaHeight()+64
        if isIpad(){
            return statusBarHeight + 56
        }
        return statusBarHeight + 44
    }
    //顶部的安全距离   不包括状态栏
    func getTopSafeAreaHeight() -> CGFloat {
        var topPadding = CGFloat(0)
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        topPadding = window.safeAreaInsets.top
        return topPadding - 20
    }
    
    /// 获取箭头的点位置
    func getArrowPoint(fPoint:CGPoint,tPoint:CGPoint) -> (CGPoint,CGPoint,CGPoint) {
        var p1 = CGPoint.zero           //箭头点1
        var p2 = CGPoint.zero           //箭头点2
        var p3 = CGPoint.zero           //箭头最前面点
        //假设箭头边长20,箭头是一个等腰三角形
        let line = sqrt(pow(abs(tPoint.x-fPoint.x), 2)+pow(abs(tPoint.y-fPoint.y), 2))
        let arrowH:CGFloat = 10//line>30 ? 5 : line/3
        //线与水平方向的夹角
        let angle = getAnglesWithThreePoints(p1: fPoint, p2: tPoint, p3: CGPoint(x: fPoint.x, y: tPoint.y))
        let _x = CGFloat(fabs(sin(angle)))*arrowH/2
        let _y = CGFloat(fabs(cos(angle)))*arrowH/2
        //向右上角、水平向右
        if tPoint.x >= fPoint.x && tPoint.y <= fPoint.y{
            p1.x = tPoint.x-_x
            p1.y = tPoint.y-_y
            
            p2.x = tPoint.x+_x
            p2.y = tPoint.y+_y
            
            p3.x = tPoint.x+_y*2
            p3.y = tPoint.y-_x*2
            
        }else if tPoint.x > fPoint.x && tPoint.y > fPoint.y{
            //向右下角
            p1.x = tPoint.x+_x
            p1.y = tPoint.y-_y
            
            p2.x = tPoint.x-_x
            p2.y = tPoint.y+_y
            
            p3.x = tPoint.x+_y*2
            p3.y = tPoint.y+_x*2
        }else if tPoint.x < fPoint.x && tPoint.y < fPoint.y{
            //向左上角
            p1.x = tPoint.x-_x
            p1.y = tPoint.y+_y
            
            p2.x = tPoint.x+_x
            p2.y = tPoint.y-_y
            
            p3.x = tPoint.x-_y*2
            p3.y = tPoint.y-_x*2
            
        }else if tPoint.x < fPoint.x && tPoint.y >= fPoint.y{
            //向左下角,水平向左
            p1.x = tPoint.x-_x
            p1.y = tPoint.y-_y
            
            p2.x = tPoint.x+_x
            p2.y = tPoint.y+_y
            
            p3.x = tPoint.x-_y*2
            p3.y = tPoint.y+_x*2
        }else if fPoint.x==tPoint.x {
            //竖直方向
            p1.x=tPoint.x-arrowH/2
            p1.y=tPoint.y
            p2.x=tPoint.x+arrowH/2
            p2.y=tPoint.y
            p3.x=tPoint.x
            p3.y = tPoint.y>fPoint.y ? tPoint.y+arrowH : tPoint.y-arrowH
        }
        
        return (p1,p2,p3)
    }
    /// 计算三点之间的角度
    ///
    /// - Parameters:
    ///   - p1: 点1
    ///   - p2: 点2（也是角度所在点）
    ///   - p3: 点3
    /// - Returns: 角度（180度制）
    func getAnglesWithThreePoints(p1:CGPoint,p2:CGPoint,p3:CGPoint) -> Double {
        //排除特殊情况，三个点一条线
        if (p1.x == p2.x && p2.x == p3.x) || ( p1.y == p2.x && p2.x == p3.x){
            return 0
        }
        
        let a = abs(p1.x - p2.x)
        let b = abs(p1.y - p2.y)
        let c = abs(p3.x - p2.x)
        let d = abs(p3.y - p2.y)
        
        if (a < 1.0 && b < 1.0) || (c < 1.0 && d < 1.0){
            return 0
        }
        let e = a*c+b*d
        let f = sqrt(a*a+b*b)
        let g = sqrt(c*c+d*d)
        let r = Double(acos(e/(f*g)))
        return r        //弧度值
        
//        return (180*r/Double.pi)      //角度值

    }
    
}

//MARK: 网络请求
extension WHUtils{
    
    //统计食物添加到日志的次数
    func sendAddFoodsForCountRequest(fids:NSArray) {
        let param = ["fids":fids]
        DLLog(message: "foods/selected_count_increment (param):\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_increment_count, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "sendAddFoodsForCountRequest:\(responseObject)")
        }
    }
    //统计食物到最近添加列表
    func sendAddHistoryFoods(foodsMsgArray:NSArray) {
        let param = ["foods":foodsMsgArray]
        DLLog(message: "sendAddHistoryFoods:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_history_add, parameters: param) { responseObject in
            DLLog(message: "sendAddHistoryFoods:\(responseObject)")
        }
    }
    
    func sendErrorMsgRequest(msgDict:NSDictionary){
        let param = ["message":"\(WHUtils.getJSONStringFromDictionary(dictionary: msgDict as NSDictionary))"]
        WHNetworkUtil.shareManager().POST(urlString: URL_error_msg, parameters: param as [String : AnyObject]) { responseObject in
            
        }
    }
}
