//
//  Data+Exs.swift
//  lns
//
//  Created by LNS2 on 2024/5/24.
//

import Foundation


extension Data {
    
    /// 按照 ASCII 转换成字符串
    func toAscii() -> String {
        return subdata2ascii(start: 0, end: self.count)
    }
    
    /// 转换成16进制字符串
    /// - Parameter withSpace: 可选参数，默认true，输出的字符串是否每两个字节之间放一个空格
    func toHex(withSpace: Bool = true) -> String {
        return subdata2hex(start: 0, end: self.count, withSpace: withSpace)
    }
    
    /// 将指定范围的数据转换成ASCII字符串
    /// - Parameter start: 起始索引（包含）
    /// - Parameter end: 结束索引（不包含）
    func subdata2ascii(start: Int, end: Int) -> String {
        if let str = String(data: self[start..<end], encoding: .ascii) {
            return str
        }
        return ""
    }
    
    /// 将指定范围的数据转换成16进制字符串
    /// - Parameter start: 起始索引（包含）
    /// - Parameter end: 结束索引（不包含）
    /// - Parameter withSpace: 可选参数，默认true，输出的字符串是否每两个字节之间放一个空格
    func subdata2hex(start: Int, end: Int, withSpace: Bool = true) -> String {
        let arr = Array<UInt8>(self[start..<end])
        let hex = arr.map({ byte -> String in
            return String(format: "%02X", byte)
        }).joined(separator: withSpace ? " " : "")
        return hex
    }
}
