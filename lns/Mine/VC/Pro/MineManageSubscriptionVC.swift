//
//  MineManageSubscriptionVC.swift
//  lns
//
//  Created by Codex on 2026/4/14.
//

import UIKit
import SnapKit
import StoreKit
import MCToast
#if DEBUG
import Network
#endif

final class MineManageSubscriptionVC: WHBaseViewVC {
    private lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(14)
        vi.layer.masksToBounds = true
        return vi
    }()

    private lazy var learnMoreButton = makeRowButton(title: "了解更多ELA PRO权益",
                                                     action: #selector(learnMoreTapAction))
    private lazy var cancelSubscriptionButton = makeRowButton(title: "取消我的订阅",
                                                              action: #selector(cancelSubscriptionTapAction))

    private lazy var dividerView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.12)
        return vi
    }()

#if DEBUG
    private lazy var refundDebugCardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(14)
        vi.layer.masksToBounds = true
        return vi
    }()

    private lazy var refundDebugTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "退款调试中心"
        lb.textColor = .COLOR_TEXT_TITLE_0f1214
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        return lb
    }()

    private lazy var refundDebugHintLabel: UILabel = {
        let lb = UILabel()
        lb.text = "一键拉起 Apple 官方退款申请，并把客户端关键链路写入本地日志。仓库根目录的 iap-refund-simulator/ 可配合本地后台回调模拟一起使用。"
        lb.textColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
        lb.font = .systemFont(ofSize: 12, weight: .regular)
        lb.numberOfLines = 0
        return lb
    }()

    private lazy var beginRefundDebugButton = makeRowButton(title: "一键发起 Apple 退款申请",
                                                            action: #selector(beginRefundDebugTapAction))
    private lazy var showRefundDebugLogsButton = makeRowButton(title: "查看退款调试日志",
                                                               action: #selector(showRefundDebugLogsTapAction))
    private lazy var openAppleRefundWebButton = makeRowButton(title: "打开 Apple 网页退款",
                                                              action: #selector(openAppleRefundWebTapAction))
    private lazy var clearRefundDebugLogsButton = makeRowButton(title: "清空退款调试日志",
                                                                action: #selector(clearRefundDebugLogsTapAction))

    private lazy var refundDebugDividerOne = makeDividerView()
    private lazy var refundDebugDividerTwo = makeDividerView()
    private lazy var refundDebugDividerThree = makeDividerView()
#endif

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
}

private extension MineManageSubscriptionVC {
    func initUI() {
        initNavi(titleStr: "管理订阅", naviBgColor: .COLOR_BG_F2)
        view.backgroundColor = .COLOR_BG_F2

        view.addSubview(cardView)
        cardView.addSubview(learnMoreButton)
        cardView.addSubview(dividerView)
        cardView.addSubview(cancelSubscriptionButton)

        cardView.snp.makeConstraints { make in
            make.top.equalTo(getNavigationBarHeight() + kFitWidth(16))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }

        learnMoreButton.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }

        dividerView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalToSuperview()
            make.top.equalTo(learnMoreButton.snp.bottom)
            make.height.equalTo(1)
        }

        cancelSubscriptionButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(dividerView.snp.bottom)
            make.height.equalTo(kFitWidth(56))
        }

#if DEBUG
        setupRefundDebugSection()
#endif
    }

    func makeDividerView() -> UIView {
        let vi = UIView()
        vi.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.12)
        return vi
    }

    func makeRowButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: action, for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.isUserInteractionEnabled = false

        let arrowView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowView.tintColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.withAlphaComponent(0.6)
        arrowView.contentMode = .scaleAspectFit
        arrowView.isUserInteractionEnabled = false

        btn.addSubview(titleLabel)
        btn.addSubview(arrowView)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.equalToSuperview()
        }

        arrowView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(8))
            make.height.equalTo(kFitWidth(14))
        }

        return btn
    }

    func openManageSubscriptions() {
        guard #available(iOS 15.0, *), let scene = view.window?.windowScene else {
            openManageSubscriptionsFallback()
            return
        }

        Task { @MainActor in
            do {
                let groupID = ElaProIAPConfig.subscriptionGroupID.trimmingCharacters(in: .whitespacesAndNewlines)
                if groupID.isEmpty {
                    try await AppStore.showManageSubscriptions(in: scene)
                } else {
                    if #available(iOS 17.0, *) {
                        try await AppStore.showManageSubscriptions(in: scene, subscriptionGroupID: groupID)
                    } else {
                        try await AppStore.showManageSubscriptions(in: scene)
                    }
                }
            } catch {
                openManageSubscriptionsFallback()
            }
        }
    }

    func openManageSubscriptionsFallback() {
        let urlStrings = [
            "itms-apps://apps.apple.com/account/subscriptions",
            "https://apps.apple.com/account/subscriptions"
        ]

        for urlString in urlStrings {
            guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
                continue
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
    }

#if DEBUG
    func setupRefundDebugSection() {
        view.addSubview(refundDebugCardView)
        refundDebugCardView.addSubview(refundDebugTitleLabel)
        refundDebugCardView.addSubview(refundDebugHintLabel)
        refundDebugCardView.addSubview(beginRefundDebugButton)
        refundDebugCardView.addSubview(refundDebugDividerOne)
        refundDebugCardView.addSubview(showRefundDebugLogsButton)
        refundDebugCardView.addSubview(refundDebugDividerTwo)
        refundDebugCardView.addSubview(openAppleRefundWebButton)
        refundDebugCardView.addSubview(refundDebugDividerThree)
        refundDebugCardView.addSubview(clearRefundDebugLogsButton)

        refundDebugCardView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(kFitWidth(16))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }

        refundDebugTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(16))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }

        refundDebugHintLabel.snp.makeConstraints { make in
            make.top.equalTo(refundDebugTitleLabel.snp.bottom).offset(kFitWidth(8))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }

        beginRefundDebugButton.snp.makeConstraints { make in
            make.top.equalTo(refundDebugHintLabel.snp.bottom).offset(kFitWidth(12))
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }

        refundDebugDividerOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalToSuperview()
            make.top.equalTo(beginRefundDebugButton.snp.bottom)
            make.height.equalTo(1)
        }

        showRefundDebugLogsButton.snp.makeConstraints { make in
            make.top.equalTo(refundDebugDividerOne.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }

        refundDebugDividerTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalToSuperview()
            make.top.equalTo(showRefundDebugLogsButton.snp.bottom)
            make.height.equalTo(1)
        }

        openAppleRefundWebButton.snp.makeConstraints { make in
            make.top.equalTo(refundDebugDividerTwo.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }

        refundDebugDividerThree.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalToSuperview()
            make.top.equalTo(openAppleRefundWebButton.snp.bottom)
            make.height.equalTo(1)
        }

        clearRefundDebugLogsButton.snp.makeConstraints { make in
            make.top.equalTo(refundDebugDividerThree.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }
    }
#endif

    @objc func learnMoreTapAction() {
        guard let navigationController = navigationController else {
            dismiss(animated: true)
            return
        }

        if let targetVC = navigationController.viewControllers.first(where: { $0 is MineElaProVC }) {
            navigationController.popToViewController(targetVC, animated: true)
        } else {
            navigationController.pushViewController(MineElaProVC(), animated: true)
        }
    }

    @objc func cancelSubscriptionTapAction() {
        openManageSubscriptions()
    }

#if DEBUG
    @objc func beginRefundDebugTapAction() {
        guard let scene = view.window?.windowScene else {
            MCToast.mc_text("当前页面还没有可用窗口，请稍后重试")
            return
        }

        ElaProIAPManager.shared.beginRefundDebugFlow(in: scene) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    MCToast.mc_text(message, respond: .allow)
                case .failure(let error):
                    MCToast.mc_text(error.localizedDescription)
                }
            }
        }
    }

    @objc func showRefundDebugLogsTapAction() {
        navigationController?.pushViewController(ElaProRefundDebugLogVC(), animated: true)
    }

    @objc func openAppleRefundWebTapAction() {
        guard let url = URL(string: "https://reportaproblem.apple.com") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func clearRefundDebugLogsTapAction() {
        ElaProIAPManager.shared.clearRefundDebugLogs()
        MCToast.mc_text("退款调试日志已清空", respond: .allow)
    }
#endif
}

#if DEBUG
final class ElaProRefundDebugLogVC: WHBaseViewVC {
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .COLOR_CARD_BG_WHITE
        tv.textColor = .COLOR_TEXT_TITLE_0f1214
        tv.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.isEditable = false
        tv.alwaysBounceVertical = true
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 20, right: 16)
        tv.layer.cornerRadius = kFitWidth(14)
        tv.layer.masksToBounds = true
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavi(titleStr: "退款调试日志", naviBgColor: .COLOR_BG_F2)
        view.backgroundColor = .COLOR_BG_F2

        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(getNavigationBarHeight() + kFitWidth(16))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(kFitWidth(-16))
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshLogs),
                                               name: ElaProIAPManager.refundDebugLogUpdatedNotification,
                                               object: nil)
        refreshLogs()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func refreshLogs() {
        let header = """
        客户端日志区域
        - 一键退款按钮会调用 Apple 官方退款申请 sheet
        - “打开 Apple 网页退款”会直达 Apple 官方 reportaproblem 页面
        - 仓库根目录 iap-refund-simulator/ 里有本地后台回调模拟脚本
        - 实际 Apple Server Notification 仍需要公网 HTTPS 回调地址

        """
        let diagnosis = ElaProIAPManager.shared.refundDebugDiagnosisText()
        let network = RefundNetworkDiagnostics.shared.summaryText
        textView.text = """
        \(diagnosis)

        \(network)

        \(header)\(ElaProIAPManager.shared.refundDebugLogText())
        """
        textView.setContentOffset(.zero, animated: false)
    }
}

private final class RefundNetworkDiagnostics {
    static let shared = RefundNetworkDiagnostics()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ela.pro.refund.network.monitor")
    private var latestPath: NWPath?

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.latestPath = path
        }
        monitor.start(queue: queue)
    }

    var summaryText: String {
        guard let path = latestPath else {
            return "网络诊断\n- 还在收集当前网络状态，请稍等 1 秒后重进日志页。"
        }

        let status: String
        switch path.status {
        case .satisfied:
            status = "已联网"
        case .unsatisfied:
            status = "未联网"
        case .requiresConnection:
            status = "需要额外连接步骤"
        @unknown default:
            status = "未知"
        }

        var interfaces: [String] = []
        if path.usesInterfaceType(.wifi) { interfaces.append("Wi-Fi") }
        if path.usesInterfaceType(.cellular) { interfaces.append("蜂窝") }
        if path.usesInterfaceType(.wiredEthernet) { interfaces.append("有线") }
        if path.usesInterfaceType(.other) { interfaces.append("其他") }

        return """
        网络诊断
        - 当前状态: \(status)
        - 当前链路: \(interfaces.isEmpty ? "未知" : interfaces.joined(separator: " + "))
        - 是否昂贵网络: \(path.isExpensive ? "是" : "否")
        - 是否受限网络: \(path.isConstrained ? "是" : "否")
        """
    }
}
#endif
