//
//  AddressDataLoader.swift
//  lns
//
//  Created by Elavatine on 2025/9/12.
//

import Foundation

public struct AreaNode: Codable {
    public let code: String
    public let name: String
    public let children: [AreaNode]?
}

@objcMembers
public class AddressModel: NSObject {
    var id = ""
    var provinceCode = ""
    var provinceName = ""
    var cityCode = ""
    var cityName = ""
    var areaCode = ""
    var areaName = ""
    var detailAddressWhole = ""
    var detailAddress = ""
    var contactName = ""
    var contactPhone = ""
    var isDefault = false
    
    func dealModelWithDict(dict:NSDictionary) -> AddressModel {
        let model = AddressModel()
        model.id = dict.stringValueForKey(key: "id")
        model.contactName = dict.stringValueForKey(key: "recipient")
        model.contactPhone = dict.stringValueForKey(key: "phone")
        model.provinceName = dict.stringValueForKey(key: "province")
        model.cityName = dict.stringValueForKey(key: "city")
        model.areaName = dict.stringValueForKey(key: "county")
        model.detailAddress = dict.stringValueForKey(key: "detail")
        model.detailAddressWhole = "\(dict.stringValueForKey(key: "province"))" +
                                " \(dict.stringValueForKey(key: "city"))" +
                                " \(dict.stringValueForKey(key: "county"))" +
                                " \(dict.stringValueForKey(key: "detail"))"
        model.isDefault = dict.stringValueForKey(key: "isDefault") == "1"
        
        return model
    }
}

public final class AddressDataLoader {
    public static let shared = AddressDataLoader()
    private init() {}
    private(set) var provinces: [AreaNode] = []

    public func loadIfNeeded(jsonFileName: String = "pca-code") throws {
        guard provinces.isEmpty else { return }

        // 读取原始文本（避免直接 Data→decode 导致 Extra data 错误）
        let url: URL
        if let u = Bundle.main.url(forResource: jsonFileName, withExtension: "json") {
            url = u
        } else {
            url = URL(fileURLWithPath: "/mnt/data/\(jsonFileName).json")
        }
        let raw = try String(contentsOf: url, encoding: .utf8)

        // —— 清洗：只取第一个完整 JSON 数组 —— //
        let cleaned = AddressDataLoader.firstJSONArray(in: raw) ?? raw

        // 解码
        let data = Data(cleaned.utf8)
        let decoder = JSONDecoder()
        provinces = try decoder.decode([AreaNode].self, from: data)
    }

    /// 从文本中提取“第一个完整的 JSON 数组”
    /// 例如文本是  [ ... ] [ ... ]，会只返回第一段 [ ... ]
    private static func firstJSONArray(in s: String) -> String? {
        guard let start = s.firstIndex(of: "[") else { return nil }
        var depth = 0
        var inString = false
        var prevChar: Character?

        for i in s.indices[start...] {
            let ch = s[i]
            if ch == "\"" && prevChar != "\\" { inString.toggle() }
            if !inString {
                if ch == "[" { depth += 1 }
                if ch == "]" {
                    depth -= 1
                    if depth == 0 {
                        // 取从第一个 '[' 到与之配对的 ']'
                        return String(s[start...i])
                    }
                }
            }
            prevChar = ch
        }
        return nil
    }
}

