//
//  Untitled.swift
//  lns
//
//  Created by Elavatine on 2024/9/25.
//

import AppIntents

@available(iOS 18, *)
struct LaunchAppIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Elavatine"
//    static var description: IntentDescription? = "abcd"
    
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        return .result()
    }
}
