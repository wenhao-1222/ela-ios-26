//
//  UIAlertAction+Exs.swift
//  lns
//
//  Created by LNS2 on 2024/6/25.
//

import Foundation


extension UIAlertAction{
    static var propertyNames: [String] {
       var outCount: UInt32 = 0
       guard let ivars = class_copyIvarList(self, &outCount) else {
           return []
       }
       var result = [String]()
       let count = Int(outCount)
       for i in 0..<count {
           let pro: Ivar = ivars[i]
           guard let ivarName = ivar_getName(pro) else {
               continue
           }
           guard let name = String(utf8String: ivarName) else {
               continue
           }
           result.append(name)
       }
       return result
   }
    func isPropertyExisted(_ propertyName: String) -> Bool {
        for name in UIAlertAction.propertyNames {
//            DLLog(message: "UIAlertAction.propertyNames:\(name)")
            if name == propertyName {
                return true
            }
        }
        return false
    }
    
    func setTextColor(_ color: UIColor) {
        let key = "_titleTextColor"
        guard isPropertyExisted(key) else {
            return
        }
        self.setValue(color, forKey: key)
    }
}
