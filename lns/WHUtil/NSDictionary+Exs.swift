//
//  NSDictionary+Exs.swift
//  lns
//
//  Created by LNS2 on 2024/5/13.
//

import Foundation

extension NSDictionary{
    func stringValueForKey(key:String) -> String {
        let double = self.value(forKey: key)as? Double ?? Double(self.value(forKey: key) as? String ?? "")
        if (double != nil) {
//            DLLog(message: "\(double!)")
//            return "\(double!)"
//            DLLog(message: "stringValueForKey:\("\(WHUtils.convertStringToStringThreeDigit("\(double!)") ?? "")")")
            return "\(WHUtils.convertStringToStringThreeDigit("\(double!)") ?? "")"
        }
        return self.value(forKey: key) as? String ?? ""
    }
    func rawStringValueForKey(key:String) -> String {
        guard let value = self.value(forKey: key), !(value is NSNull) else {
            return ""
        }
        if let stringValue = value as? String {
            return stringValue.replacingOccurrences(of: ",", with: ".")
        }
        if let numberValue = value as? NSNumber {
            return numberValue.stringValue.replacingOccurrences(of: ",", with: ".")
        }
        return "\(value)".replacingOccurrences(of: ",", with: ".")
    }
    func doubleValueForKey(key:String) -> Double {
        var value = self.value(forKey: key)as? String ?? ""
        value = value.replacingOccurrences(of: ",", with: ".")
        if value == ""{
            return self.value(forKey: key) as? Double ?? 0
        }
        return (value as NSString).doubleValue
//        return self.value(forKey: key) as? Double ?? Double(self.value(forKey: key) as? String ?? "0")!
    }
    func floatValueForKey(key:String) -> Float {
        var value = self.value(forKey: key)as? String ?? ""
        value = value.replacingOccurrences(of: ",", with: ".")
        if value == ""{
            return self.value(forKey: key) as? Float ?? 0
        }
        return (value as NSString).floatValue
//        return self.value(forKey: key) as? Double ?? Double(self.value(forKey: key) as? String ?? "0")!
    }
}
