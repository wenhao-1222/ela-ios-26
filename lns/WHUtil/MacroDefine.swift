//
//  MacroDefine.swift
//  lns
//
//  Created by LNS2 on 2024/3/21.
//

import Foundation
import UIKit
import DeviceKit

let token = "token_lns"
let userId = "user_id"
let userPhone = "user_phone"
let launchNum = "launchNum"
let isLaunchWelcome = "isLaunchWelcome"

let guide_main_natural = "guide_main_natural"
let guide_foods_list_logs = "guide_foods_list_logs"
let guide_foods_list_main = "guide_foods_list_main"
let guide_foods_list_plan = "guide_foods_list_plan"
let guide_goal_week_set = "guide_goal_week_set"

let guide_logs_plan = "guide_logs_plan"
let guide_foods_add = "guide_foods_add"
let guide_add_first_foods = "guide_add_first_foods"
let guide_foods_list_search = "guide_foods_list_search"
let guide_mine_create_plan = "guide_mine_create_plan"
let guide_total = "guide_total"

let self_shareCode = "self_shareCode"

let playerViewTag = 3999

let appDelegate = UIApplication.shared.delegate as! AppDelegate
/********页面属性************/
//MARK: -全局尺寸
let SCREEN_WIDHT     = UIScreen.main.bounds.width //屏幕宽度
let SCREEN_HEIGHT    = UIScreen.main.bounds.height //屏幕高度

//适配iPhoneX
//获取状态栏的高度，全面屏手机的状态栏高度为44pt，非全面屏手机的状态栏高度为20pt
//状态栏高度
let statusBarHeight = UIApplication.shared.statusBarFrame.height;

let kFitWidth: (CGFloat) -> CGFloat = { width in
    if UIDevice.current.userInterfaceIdiom == .pad {
        return width * min(SCREEN_WIDHT / 375.0,SCREEN_HEIGHT / 812.0)
    }else{
        return width * SCREEN_WIDHT / 375.0
    }
}
let kFitHeight: (CGFloat) -> CGFloat = { width in
    return width * SCREEN_HEIGHT / 812.0
}

func isIpad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

// 把要打印的日志写在和AppDelegate同一个等级的方法中,即不从属于AppDelegate这个类，这样在真个项目中才能使用这个打印日志,因为这就是程序的入口,
//这里的T表示不指定message参数类型
func DLLog<T>(message: T, fileName: String = #file, funcName: String = #function, lineNum : Int = #line) {
    
    #if DEBUG
//        /**
//         * 此处还要在项目的build settings中搜索swift flags,找到 Other Swift Flags 找到Debug
//         * 添加 -D DEBUG,即可。
//         */
//         // 1.对文件进行处理
//        let file = (fileName as NSString).lastPathComponent
//        // 2.打印内容
////    print("[\(file)][\(funcName)](第\(lineNum)行)\(message)")
//    
//        let messageString = String(describing: message) // 关键修改
//        print("[\(file)][\(funcName)](第\(lineNum)行)\(messageString)")
        
    
    /**
         * 此处还要在项目的build settings中搜索swift flags,找到 Other Swift Flags 找到Debug
         * 添加 -D DEBUG,即可。
         */
        // 1.对文件进行处理
        let file = (fileName as NSString).lastPathComponent
        // 2.打印内容
        //    print("[\(file)][\(funcName)](第\(lineNum)行)\(message)")

        var messageString: String
        if let dict = message as? [String: Any],
           let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
           let str = String(data: data, encoding: .utf8) {
            messageString = str
        } else if let arr = message as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: arr, options: .prettyPrinted),
                  let str = String(data: data, encoding: .utf8) {
            messageString = str
        } else {
            messageString = "\(message)"
        }

        print("[\(file)][\(funcName)](第\(lineNum)行)\(messageString)")
    #endif
}
