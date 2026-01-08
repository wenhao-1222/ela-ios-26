//
//  RegionSelector.swift
//  lns
//
//  Created by LNS2 on 2025/10/29.
//

import Foundation
import CoreTelephony

enum PlayEnv { case cn, sea }

enum RegionSelector {
  static func decideEnv(accountEnv: PlayEnv?, playbackBaseURL: URL?) -> PlayEnv {
    // 1) 服务端优先
    if let server = accountEnv { return server }

    // 2) 业务域名信号
    if let host = playbackBaseURL?.host?.lowercased() {
      if host.contains("intl.") || host.contains(".com") { return .sea }
      if host.hasSuffix(".cn") { return .cn }
      // 也可根据你们自己的域名分组更精细地匹配
    }

    // 3) 本地兜底：MCC -> Locale
    let mccs = currentMCCs() // 可能多 SIM
    let cnLikeMCCs: Set<String> = ["460","454","455","466"] // 内地/港/澳/台
    if mccs.contains(where: { cnLikeMCCs.contains($0) }) { return .cn }

    // 无蜂窝或取不到，参考系统区域
    if let rc = Locale.current.regionCode?.uppercased(), ["CN","HK","MO","TW"].contains(rc) {
      return .cn
    }
    return .sea
  }
    private static func currentMCCs() -> [String] {
        let info = CTTelephonyNetworkInfo()

        // iOS 12+ 多卡：serviceSubscriberCellularProviders
        var carriers = Array((info.serviceSubscriberCellularProviders ?? [:]).values)

        // 兜底（旧接口，部分设备上还会返回单卡）
        if carriers.isEmpty, let legacy = info.subscriberCellularProvider {
            carriers = [legacy]
        }

        return carriers.compactMap { $0.mobileCountryCode } // 例如 "460","454","455","466"
    }

}
