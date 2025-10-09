//
//  CNIPGate.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//  基于公网 IP 判断是否为中国大陆网络出口。
//  返回：true=CN，false=非CN，nil=无法判断（全部请求失败/被拦截）
//  依赖：Foundation（URLSession）
//  说明：该方法依赖公网出口 IP，若走代理/VPN/企业海外出口或被防火墙拦截，结果可能为 false 或 nil。
//

/*调用示例代码
 // iOS 15+
 if #available(iOS 15.0, *) {
     Task {
         let result = await CNIPGate.isChinaMainlandByPublicIP()
         // true / false / nil
         print("CN 出口？", result as Any)
     }
 } else {
     // 低系统
     CNIPGate.isChinaMainlandByPublicIP { result in
         print("CN 出口？", result as Any)
     }
 }

 */

import Foundation

public final class CNIPGate {

    // MARK: - Public API

    /// iOS 15+ / macOS 12+：异步调用
    /// - Returns: true=CN，false=非CN，nil=无法判断（全部端点失败）
    @available(iOS 15.0, macOS 12.0, *)
    public static func isChinaMainlandByPublicIP(
        session: URLSession = CNIPGate.defaultSession
    ) async -> Bool? {
        for url in endpoints {
            do {
                var req = URLRequest(url: url)
                req.httpMethod = "GET"
                req.setValue("text/plain,application/json;q=0.9,*/*;q=0.1", forHTTPHeaderField: "Accept")

                let (data, resp) = try await session.data(for: req)
                guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else { continue }
                if let code = parseCountryCode(from: data, host: url.host) {
                    return code == "CN"
                }
            } catch {
                // 超时/无网/证书等异常：尝试下一个端点
                continue
            }
        }
        return nil
    }

    /// 回调版（兼容更低系统）
    /// - Parameter completion: true=CN，false=非CN，nil=无法判断
    public static func isChinaMainlandByPublicIP(
        completion: @escaping (Bool?) -> Void
    ) {
        attempt(index: 0, completion: completion)
    }

    // MARK: - Configuration

    /// 端点列表：任一返回两位国家码或 JSON 即可
    /// - https://ipapi.co/country/        -> "CN"
    /// - https://ifconfig.co/country-iso  -> "CN"
    /// - https://ipwho.is/?fields=country_code -> {"country_code":"CN"}
    public static var endpoints: [URL] = [
        URL(string: "https://ipapi.co/country/")!,
        URL(string: "https://ifconfig.co/country-iso")!,
        URL(string: "https://ipwho.is/?fields=country_code")!
    ]

    /// 默认会话（无缓存、短超时）
    public static var defaultSession: URLSession = {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.requestCachePolicy = .reloadIgnoringLocalCacheData
        cfg.timeoutIntervalForRequest = 5
        cfg.timeoutIntervalForResource = 5
        // 如有需要可在此增加自定义 Header（如 User-Agent）
        return URLSession(configuration: cfg)
    }()

    // MARK: - Internal (Callback flow)

    private static func attempt(index: Int, completion: @escaping (Bool?) -> Void) {
        guard index < endpoints.count else { completion(nil); return }
        let url = endpoints[index]

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("text/plain,application/json;q=0.9,*/*;q=0.1", forHTTPHeaderField: "Accept")

        let task = defaultSession.dataTask(with: req) { data, resp, _ in
            defer {
                // 如果本次未能得出 country code，继续下一个端点
                if data == nil || ((resp as? HTTPURLResponse).map({ (200...299).contains($0.statusCode) }) == nil) ?? false {
                    attempt(index: index + 1, completion: completion)
                }
            }
            guard
                let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode),
                let data = data,
                let code = parseCountryCode(from: data, host: url.host)
            else { return }

            completion(code == "CN")
        }
        task.resume()
    }

    // MARK: - Parsing

    /// 解析国家码：ipwho.is 走 JSON，其它端点直接取前两字符
    private static func parseCountryCode(from data: Data, host: String?) -> String? {
        if host?.contains("ipwho.is") == true {
            // 优先 JSON 解析
            if let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
               let code = (json["country_code"] as? String)?.uppercased(),
               code.count == 2 {
                return code
            }
            // 兜底：正则在文本里提取
            if let body = String(data: data, encoding: .utf8) {
                let pattern = #"\"country_code\"\s*:\s*\"([A-Z]{2})\""#
                if let range = body.range(of: pattern, options: .regularExpression) {
                    let matched = String(body[range])
                    let cleaned = matched.replacingOccurrences(of: #"[^A-Z]"#, with: "", options: .regularExpression)
                    return cleaned.count == 2 ? cleaned : nil
                }
            }
            return nil
        } else {
            // 纯文本端点：前两个字符即国家码
            if let body = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               body.count >= 2 {
                return String(body.prefix(2)).uppercased()
            }
            return nil
        }
    }
}
