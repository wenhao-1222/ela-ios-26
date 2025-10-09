//
//  Character+Exs.swift
//  lns
//
//  Created by LNS2 on 2024/5/24.
//

import Foundation

extension Character {
    var ishexDigit: Bool {
        return "0"..."9" ~= self || "a"..."f" ~= self || "A"..."F" ~= self
    }
 
    var hexDigitValue: UInt8? {
        switch self {
        case "0"..."9": return UInt8(self.utf16.first!) - UInt8("0".utf16.first!)
        case "a"..."f": return UInt8(self.utf16.first!) - UInt8("a".utf16.first!) + 10
        case "A"..."F": return UInt8(self.utf16.first!) - UInt8("A".utf16.first!) + 10
        default: return nil
        }
    }
}
