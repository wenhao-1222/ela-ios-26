//
//  NetworkCountryDetector.swift
//  lns
//
//  Created by Elavatine on 2025/9/29.
//
import Foundation

enum NetworkCountryDetector {
    // 多路冗余接口
    private static let endpoints: [URL] = [
        URL(string: "https://ipapi.co/country/")!,
        URL(string: "https://ifconfig.co/country-iso")!,
        URL(string: "https://ipwho.is/?fields=country_code")!
    ]

    /// 基于公网 IP 判断是否为中国大陆网络出口（回调版）
    /// - Parameters:
    ///   - deliverOn: 结果回调投递队列（默认主线程）
    ///   - completion: true=CN，false=非CN，nil=无法判断
    static func isChinaMainlandByPublicIP(
        deliverOn queue: DispatchQueue = .main,
        completion: @escaping (Bool?) -> Void
    ) {
        let session = makeSession()

        func finish(_ result: Bool?) {
            queue.async { completion(result) }
        }

        func attempt(at index: Int) {
            guard index < endpoints.count else {
                finish(nil); return
            }

            let url = endpoints[index]
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 2 // 秒

            let task = session.dataTask(with: req) { data, response, error in
                defer { /* 保证异常时继续下一个 */ }

                guard error == nil,
                      let http = response as? HTTPURLResponse,
                      200..<300 ~= http.statusCode,
                      let data = data, !data.isEmpty
                else {
                    // 失败：继续下一个
                    attempt(at: index + 1)
                    return
                }

                if let code = extractCountryCode(from: data, endpoint: url) {
                    #if DEBUG
                    print("[IPCountry] 当前网络出口：code = \(code)")
                    #endif
                    finish(code == "CN")
                } else {
                    // 解析不到：继续下一个
                    attempt(at: index + 1)
                }
            }
            task.resume()
        }

        attempt(at: 0)
    }

    // MARK: - Helpers

    private static func makeSession() -> URLSession {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = 2
        cfg.timeoutIntervalForResource = 4
        cfg.waitsForConnectivity = false
        return URLSession(configuration: cfg)
    }

    private static func extractCountryCode(from data: Data, endpoint: URL) -> String? {
        if endpoint.host?.contains("ipwho.is") == true {
            struct Resp: Decodable { let country_code: String? }
            if let obj = try? JSONDecoder().decode(Resp.self, from: data),
               let code = obj.country_code?.trimmingCharacters(in: .whitespacesAndNewlines),
               isISO2(code) {
                return code.uppercased()
            }
            return nil
        } else {
            let text = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let prefix2 = String(text.prefix(2))
            return isISO2(prefix2) ? prefix2.uppercased() : nil
        }
    }

    private static func isISO2(_ s: String) -> Bool {
        let up = s.uppercased()
        guard up.count == 2 else { return false }
        let letters = CharacterSet.uppercaseLetters
        return up.unicodeScalars.allSatisfy { letters.contains($0) }
    }
}
