//
//  DeviceUUIDManager.swift
//  lns
//
//  Created by Elavatine on 2025/7/15.
//

import Foundation
import Security
//import DeviceKit
import UIKit

class DeviceUUIDManager {
    static let shared = DeviceUUIDManager()
    private let key = "com.elavatine.device.uuid"
    private let testKey = "com.elavatine.device.uuid.test"

    private init() {}

    /// Returns a persistent UUID stored in Keychain.
    var uuid: String {
        if let saved = readUUID() {
            return saved
        }
        let newID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        saveUUID(newID)
        return newID
    }
    /// Returns the UUID string without hyphens for sending to backend.
    var uuidWithoutHyphen: String {
        return uuid.replacingOccurrences(of: "-", with: "")
    }

    /// Test-only random UUID stored in UserDefaults, changes after app reinstall.
    var testUUIDWithoutHyphen: String {
        if let saved = UserDefaults.standard.string(forKey: testKey), !saved.isEmpty {
            return saved.replacingOccurrences(of: "-", with: "")
        }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: testKey)
        return newID.replacingOccurrences(of: "-", with: "")
    }
    
    private func saveUUID(_ uuid: String) {
        if let data = uuid.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    private func readUUID() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess {
            if let data = result as? Data, let uuid = String(data: data, encoding: .utf8) {
                return uuid
            }
        }
        return nil
    }
}
