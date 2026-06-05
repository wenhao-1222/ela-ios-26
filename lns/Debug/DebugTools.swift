//
//  DebugTools.swift
//  lns
//
//  Debug-only floating tools entry, adapted from Milo's ladybug button.
//

#if DEBUG

import SwiftUI
import UIKit

enum DebugTools {

    private static var floatingWindow: DebugFloatingButtonWindow?
    private static var sceneObserver: NSObjectProtocol?

    static func bootstrap() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
                attach(to: scene)
                return
            }

            if UIApplication.shared.delegate?.window??.windowScene == nil {
                attachToLegacyWindow()
                return
            }

            sceneObserver = NotificationCenter.default.addObserver(
                forName: UIScene.didActivateNotification,
                object: nil,
                queue: .main
            ) { note in
                guard let scene = note.object as? UIWindowScene else { return }
                attach(to: scene)
            }
        }
    }

    private static func attach(to scene: UIWindowScene) {
        guard floatingWindow == nil else { return }
        floatingWindow = DebugFloatingButtonWindow(scene: scene)
        if let observer = sceneObserver {
            NotificationCenter.default.removeObserver(observer)
            sceneObserver = nil
        }
    }

    private static func attachToLegacyWindow() {
        guard floatingWindow == nil else { return }
        floatingWindow = DebugFloatingButtonWindow(frame: UIScreen.main.bounds)
    }
}

final class DebugFloatingButtonWindow: UIWindow {

    private let buttonSize: CGFloat = 56
    private let edgeMargin: CGFloat = 12
    private let buttonView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(initialBounds: frame)
    }

    init(scene: UIWindowScene) {
        super.init(windowScene: scene)
        commonInit(initialBounds: scene.coordinateSpace.bounds)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if rootViewController?.presentedViewController != nil {
            return super.hitTest(point, with: event)
        }

        guard buttonView.frame.contains(point) else {
            return nil
        }

        return super.hitTest(point, with: event)
    }

    private func commonInit(initialBounds: CGRect) {
        windowLevel = .alert + 1
        backgroundColor = .clear
        isHidden = false

        let root = PassthroughViewController()
        root.view.backgroundColor = .clear
        rootViewController = root

        configureButtonView()
        root.view.addSubview(buttonView)

        let initialX = initialBounds.width - buttonSize - edgeMargin
        let initialY = initialBounds.height * 0.7
        buttonView.frame = CGRect(x: initialX, y: initialY, width: buttonSize, height: buttonSize)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.require(toFail: pan)
        buttonView.addGestureRecognizer(pan)
        buttonView.addGestureRecognizer(tap)
    }

    private func configureButtonView() {
        buttonView.backgroundColor = UIColor.black.withAlphaComponent(0.78)
        buttonView.layer.cornerRadius = buttonSize / 2
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOpacity = 0.25
        buttonView.layer.shadowOffset = CGSize(width: 0, height: 4)
        buttonView.layer.shadowRadius = 8
        buttonView.isUserInteractionEnabled = true

        let icon = UIImageView(image: UIImage(systemName: "ladybug.fill"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26),
        ])
    }

    @objc private func handleTap() {
        presentDebugMenu()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        buttonView.center = CGPoint(
            x: buttonView.center.x + translation.x,
            y: buttonView.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: self)

        if gesture.state == .ended || gesture.state == .cancelled {
            snapToEdge()
        }
    }

    private func snapToEdge() {
        let targetX: CGFloat = buttonView.center.x < bounds.width / 2
            ? buttonSize / 2 + edgeMargin
            : bounds.width - buttonSize / 2 - edgeMargin
        let minY = safeAreaInsets.top + buttonSize / 2 + edgeMargin
        let maxY = bounds.height - safeAreaInsets.bottom - buttonSize / 2 - edgeMargin
        let clampedY = min(max(buttonView.center.y, minY), maxY)

        UIView.animate(withDuration: 0.25) {
            self.buttonView.center = CGPoint(x: targetX, y: clampedY)
        }
    }

    private func presentDebugMenu() {
        guard let root = rootViewController, root.presentedViewController == nil else { return }
        let host = UIHostingController(rootView: DebugMenuView())
        host.modalPresentationStyle = .fullScreen
        root.present(host, animated: true)
    }

    private final class PassthroughViewController: UIViewController {
        override func loadView() {
            view = PassthroughView()
        }
    }

    private final class PassthroughView: UIView {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            for subview in subviews where subview.frame.contains(point) && subview.isHidden == false {
                return true
            }
            return false
        }
    }
}

private struct DebugMenuView: View {

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            TabView {
                DebugNetworkView()
                    .tabItem { Label("Network", systemImage: "network") }

                DebugInfoView()
                    .tabItem { Label("Info", systemImage: "info.circle") }

                DebugActionsView()
                    .tabItem { Label("Actions", systemImage: "wrench.and.screwdriver") }
            }
            .navigationTitle("lns Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

final class DebugNetworkLogStore: ObservableObject {

    static let shared = DebugNetworkLogStore()

    @Published private(set) var entries: [DebugNetworkEntry] = []

    private let maxEntries = 120

    private init() {}

    @discardableResult
    func recordRequest(method: String,
                       url: String,
                       parameters: Any?,
                       encodedParameters: Any? = nil,
                       taskId: String = "") -> UUID {
        let entry = DebugNetworkEntry(
            id: UUID(),
            method: method,
            url: url,
            taskId: taskId,
            requestAt: Date(),
            requestParameters: DebugNetworkLogStore.prettyText(parameters),
            encodedParameters: DebugNetworkLogStore.prettyText(encodedParameters),
            responseAt: nil,
            statusCode: nil,
            responseText: nil,
            errorText: nil
        )

        let insertEntry = {
            self.entries.insert(entry, at: 0)
            if self.entries.count > self.maxEntries {
                self.entries.removeLast(self.entries.count - self.maxEntries)
            }
        }

        if Thread.isMainThread {
            insertEntry()
        } else {
            DispatchQueue.main.sync(execute: insertEntry)
        }

        return entry.id
    }

    func recordResponse(id: UUID,
                        statusCode: Int?,
                        response: Any?,
                        error: Error?) {
        DispatchQueue.main.async {
            guard let index = self.entries.firstIndex(where: { $0.id == id }) else { return }
            self.entries[index].responseAt = Date()
            self.entries[index].statusCode = statusCode
            self.entries[index].responseText = DebugNetworkLogStore.prettyText(
                DebugNetworkLogStore.responseForDisplay(response)
            )
            self.entries[index].errorText = error?.localizedDescription
        }
    }

    func clear() {
        entries.removeAll()
    }

    func copyAllText() {
        UIPasteboard.general.string = entries.map { $0.detailText }.joined(separator: "\n\n---\n\n")
    }

    private static func prettyText(_ value: Any?) -> String {
        guard let value else { return "-" }

        if let string = value as? String {
            return string.isEmpty ? "-" : string
        }

        if JSONSerialization.isValidJSONObject(value),
           let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted]),
           let string = String(data: data, encoding: .utf8) {
            return string
        }

        if let data = value as? Data, let string = String(data: data, encoding: .utf8) {
            return string
        }

        return String(describing: value)
    }

    private static func responseForDisplay(_ response: Any?) -> Any? {
        guard let response else { return nil }

        if let dictionary = response as? [String: Any] {
            return decryptedResponseDictionary(dictionary)
        }

        if let dictionary = response as? NSDictionary {
            return decryptedResponseDictionary(dictionary as? [String: Any] ?? [:])
        }

        return response
    }

    private static func decryptedResponseDictionary(_ dictionary: [String: Any]) -> [String: Any] {
        guard responseCode(dictionary["code"]) == 200,
              let encryptedData = dictionary["data"] as? String,
              encryptedData.isEmpty == false else {
            return dictionary
        }

        var displayDictionary = dictionary
        displayDictionary["data_encrypted"] = encryptedData

        let decryptedString = AESEncyptUtil.aesDecrypt(hexString: encryptedData) ?? ""
        if let parsed = jsonObject(from: decryptedString) {
            displayDictionary["data"] = parsed
        } else {
            displayDictionary["data"] = decryptedString
        }

        return displayDictionary
    }

    private static func responseCode(_ value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }
        if let numberValue = value as? NSNumber {
            return numberValue.intValue
        }
        if let stringValue = value as? String {
            return Int(stringValue)
        }
        return nil
    }

    private static func jsonObject(from string: String) -> Any? {
        guard let data = string.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data, options: []),
              JSONSerialization.isValidJSONObject(object) else {
            return nil
        }
        return object
    }
}

struct DebugNetworkEntry: Identifiable {
    let id: UUID
    let method: String
    let url: String
    let taskId: String
    let requestAt: Date
    let requestParameters: String
    let encodedParameters: String
    var responseAt: Date?
    var statusCode: Int?
    var responseText: String?
    var errorText: String?

    var pathTitle: String {
        guard let url = URL(string: url) else { return self.url }
        let path = url.path.isEmpty ? url.absoluteString : url.path
        return path
    }

    var statusText: String {
        if let statusCode {
            return "\(statusCode)"
        }
        if errorText != nil {
            return "Error"
        }
        return "Pending"
    }

    var durationText: String {
        guard let responseAt else { return "..." }
        let duration = responseAt.timeIntervalSince(requestAt)
        return String(format: "%.2fs", duration)
    }

    var detailText: String {
        [
            "\(method) \(url)",
            taskId.isEmpty ? nil : "Task ID: \(taskId)",
            "Status: \(statusText)",
            "Duration: \(durationText)",
            "Request Parameters:\n\(requestParameters)",
            "Encoded Parameters:\n\(encodedParameters)",
            "Response:\n\(responseText ?? "-")",
            errorText.map { "Error:\n\($0)" },
        ].compactMap { $0 }.joined(separator: "\n\n")
    }
}

private struct DebugNetworkView: View {

    @ObservedObject private var store = DebugNetworkLogStore.shared
    @State private var copiedMessage = ""

    var body: some View {
        NavigationView {
            List {
                if store.entries.isEmpty {
                    Section {
                        Text("No requests captured yet.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Section {
                        ForEach(store.entries) { entry in
                            NavigationLink(destination: DebugNetworkDetailView(entry: entry)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text(entry.method)
                                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        Text(entry.statusText)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(statusColor(entry))
                                        Text(entry.durationText)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    Text(entry.pathTitle)
                                        .font(.system(size: 13, weight: .medium))
                                        .lineLimit(2)
                                    Text(entry.url)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }

                if copiedMessage.isEmpty == false {
                    Section {
                        Text(copiedMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Network")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        store.clear()
                        copiedMessage = ""
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Copy") {
                        store.copyAllText()
                        copiedMessage = "Network logs copied."
                    }
                    .disabled(store.entries.isEmpty)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func statusColor(_ entry: DebugNetworkEntry) -> Color {
        if entry.errorText != nil { return .red }
        guard let code = entry.statusCode else { return .orange }
        if (200..<300).contains(code) { return .green }
        if (400..<600).contains(code) { return .red }
        return .secondary
    }
}

private struct DebugNetworkDetailView: View {

    let entry: DebugNetworkEntry
    @State private var message = ""

    var body: some View {
        List {
            Section("Request") {
                row("Method", entry.method)
                row("URL", entry.url, monospaced: true)
                if entry.taskId.isEmpty == false {
                    row("Task ID", entry.taskId)
                }
            }

            Section("Timing") {
                row("Status", entry.statusText)
                row("Duration", entry.durationText)
            }

            Section("Request Parameters") {
                textBlock(entry.requestParameters)
            }

            Section("Encoded Parameters") {
                textBlock(entry.encodedParameters)
            }

            Section("Response") {
                textBlock(entry.responseText ?? "-")
            }

            if let errorText = entry.errorText {
                Section("Error") {
                    textBlock(errorText)
                }
            }

            Section {
                Button {
                    UIPasteboard.general.string = entry.detailText
                    message = "Request copied."
                } label: {
                    Label("Copy This Request", systemImage: "doc.on.doc")
                }

                if message.isEmpty == false {
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(entry.pathTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func row(_ title: String, _ value: String, monospaced: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(.system(size: 13, design: monospaced ? .monospaced : .default))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func textBlock(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, design: .monospaced))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DebugInfoView: View {

    var body: some View {
        List {
            Section("Environment") {
                row(label: "Server Type", value: serverTypeDescription)
                row(label: "Base URL", value: WHGetInterface_javaWithType(), monospaced: true)
            }

            Section("Current User") {
                row(label: "Logged In", value: UserInfoModel.shared.token.isEmpty ? "No" : "Yes")
                row(label: "User ID", value: bestValue(UserInfoModel.shared.uId, UserDefaults.standard.string(forKey: userId)))
                row(label: "Phone", value: bestValue(UserInfoModel.shared.phone, UserDefaults.standard.string(forKey: userPhone)))
                row(label: "Nickname", value: UserInfoModel.shared.nickname)
            }

            Section("Auth") {
                row(label: "Token", value: bestValue(UserInfoModel.shared.token, UserDefaults.standard.string(forKey: token)), monospaced: true)
            }

            Section("App / Device") {
                row(label: "Bundle ID", value: Bundle.main.bundleIdentifier)
                row(label: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
                row(label: "Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String)
                row(label: "iOS", value: UIDevice.current.systemVersion)
                row(label: "Device", value: deviceModel)
                row(label: "Top VC", value: String(describing: type(of: UIApplication.topViewController() ?? UIViewController())))
            }
        }
    }

    @ViewBuilder
    private func row(label: String, value: String?, monospaced: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 96, alignment: .leading)

            Text(displayValue(value))
                .font(.system(size: 13, weight: .regular, design: monospaced ? .monospaced : .default))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let value, value.isEmpty == false {
                Button {
                    UIPasteboard.general.string = value
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 13))
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 2)
    }

    private var serverTypeDescription: String {
        switch WHGetInterfaceType().intValue {
        case 0: return "release"
        case 1: return "develop"
        case 2: return "cs"
        default: return "unknown"
        }
    }

    private var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.compactMap { element -> String? in
            guard let value = element.value as? Int8, value != 0 else { return nil }
            return String(UnicodeScalar(UInt8(value)))
        }.joined()
        return identifier.isEmpty ? UIDevice.current.model : identifier
    }
}

private struct DebugActionsView: View {

    @State private var message = ""

    var body: some View {
        List {
            Section("Clipboard") {
                Button {
                    UIPasteboard.general.string = debugSnapshot
                    message = "Debug snapshot copied."
                } label: {
                    Label("Copy Debug Snapshot", systemImage: "doc.on.doc")
                }
            }

            Section("Session") {
                Button(role: .destructive) {
                    UserDefaults.standard.setValue("", forKey: token)
                    UserDefaults.standard.setValue("", forKey: userId)
                    UserInfoModel.shared.token = ""
                    UserInfoModel.shared.uId = ""
                    message = "Login cache cleared. Restart the app to verify the logged-out flow."
                } label: {
                    Label("Clear Login Cache", systemImage: "person.crop.circle.badge.xmark")
                }
            }

            if message.isEmpty == false {
                Section {
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var debugSnapshot: String {
        [
            "Bundle ID: \(Bundle.main.bundleIdentifier ?? "-")",
            "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")",
            "Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-")",
            "Server Type: \(WHGetInterfaceType())",
            "Base URL: \(WHGetInterface_javaWithType())",
            "User ID: \(bestValue(UserInfoModel.shared.uId, UserDefaults.standard.string(forKey: userId)) ?? "-")",
            "Phone: \(bestValue(UserInfoModel.shared.phone, UserDefaults.standard.string(forKey: userPhone)) ?? "-")",
            "iOS: \(UIDevice.current.systemVersion)",
            "Device: \(UIDevice.current.model)",
        ].joined(separator: "\n")
    }
}

private func bestValue(_ primary: String?, _ fallback: String?) -> String? {
    if let primary, primary.isEmpty == false {
        return primary
    }
    return fallback
}

private func displayValue(_ value: String?) -> String {
    guard let value, value.isEmpty == false else {
        return "-"
    }
    return value
}

#endif
