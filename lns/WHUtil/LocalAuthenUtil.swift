//
//  LocalAuthenUtil.swift
//  lns
//
//  Created by LNS2 on 2024/3/21.
//

import Foundation
import LocalAuthentication
 
class LocalAuthenUtil{
    func authenticateWithTouchID() {
        let context = LAContext()
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "验证您的指纹，用于登录LNS") { success, evaluateError in
                DispatchQueue.main.async {
                    // Handle authentication result or failure reason here
                    
                        DLLog(message: "\(evaluateError)")
                    DLLog(message: "\(error)")
                    if success {
                        print("Fingerprint authentication successful")
                    } else {
                        DLLog(message: "\(evaluateError)")
    //                    switch evaluateError. {
    //                    case LAError.authenticationFailed.rawValue:
    //                        print("Fingerprint authentication failed")
    //
    //                    default:
    //                        print("Other fingerprint authentication errors occurred")
    //                    }
                    }
                }
            }
        } else {
            print("Device does not support Touch ID")
        }
    }
}


