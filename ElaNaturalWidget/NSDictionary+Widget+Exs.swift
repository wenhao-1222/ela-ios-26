//
//  NSDictionary+Widget+Exs.swift
//  ElaNaturalWidgetExtension
//
//  Created by LNS2 on 2024/8/16.
//

import Foundation

extension NSDictionary{
    func stringValueForKeyWidget(key:String) -> String {
        let double = self.value(forKey: key)as? Double ?? Double(self.value(forKey: key) as? String ?? "")
        if (double != nil) {
            return "\(double ?? 0)"
        }
        return self.value(forKey: key) as? String ?? ""
    }
    func doubleValueForKeyWidget(key:String) -> Double {
        var value = self.value(forKey: key)as? String ?? ""
        value = value.replacingOccurrences(of: ",", with: ".")
        if value == ""{
            return self.value(forKey: key) as? Double ?? 0
        }
        return (value as NSString).doubleValue
//        return self.value(forKey: key) as? Double ?? Double(self.value(forKey: key) as? String ?? "0")!
    }
}
