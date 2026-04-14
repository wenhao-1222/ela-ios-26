//
//  MineManageSubscriptionVC.swift
//  lns
//
//  Created by Codex on 2026/4/14.
//

import UIKit
import SnapKit
import StoreKit

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
                        // Fallback on earlier versions
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
}
