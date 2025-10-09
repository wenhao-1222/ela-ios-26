//
//  WHTool_ProjectInfo.swift
//  ttjx
//
//  Created by 文 on 2019/8/30.
//  Copyright © 2019 ttjx. All rights reserved.
//

import Foundation

// =========================读取配置plist里的接口信息
// 接口的处理
public func WHGetInterfaceInfo() -> NSMutableDictionary {
    let plistPath = Bundle.main.path(forResource: "Interface", ofType: "plist")
    let dictM : NSMutableDictionary = NSMutableDictionary.init(contentsOfFile: plistPath!)!
    return dictM
}
public func WHGetInterfaceType() -> NSNumber {
    let dictM = WHGetInterfaceInfo()
    let isProduct = dictM["server_type"] as? NSNumber ?? 0

    return isProduct
}
public func WHGetInterface_javaWithType() -> String {
    let dictM = WHGetInterfaceInfo()
    let isProduct = WHGetInterfaceType()
    let url_debug   = dictM["url_develop"] as? String ?? ""
    let url_release = dictM["url_release"] as? String ?? ""
    let url_cs     = dictM["url_cs"] as? String ?? ""
    
#if DEBUG
    if isProduct == 0 {
        return url_release
    } else if isProduct == 1{
        return url_debug
    }else if isProduct == 2{
        return url_cs
    }
#else
    return url_release
#endif
    return url_release
}

//MARK- *** 三方平台的key ***

// 获取微信key    未用
//public func WHGetConfiguration_wxKey() -> String {
//    let dictM = WHGetInterfaceInfo()
//    let key   = dictM["WHKey_wx"] as? String ?? ""
//    return key
//}


