//
//  MineSubscriptionPlanVC.swift
//  lns
//
//  Created by Codex on 2026/4/14.
//

import UIKit
import SnapKit

final class MineSubscriptionPlanVC: WHBaseViewVC {
    private lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()

    private lazy var statusLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()

    private lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(16)
        vi.layer.masksToBounds = true
        return vi
    }()

    private lazy var logoImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_expired_alert_icon")
        img.contentMode = .scaleAspectFit
        return img
    }()

    private lazy var planTypeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = .right
        lab.isHidden = true
        return lab
    }()

    private lazy var expireLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()

    private lazy var purchaseDescLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.numberOfLines = 0
        return lab
    }()

    private lazy var manageButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("管理订阅", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(manageButtonTapAction), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        refreshUI(with: VIPModel.shared)
        sendVipInfoRequest()
    }
}

private extension MineSubscriptionPlanVC {
    func initUI() {
        initNavi(titleStr: "我的订阅计划", naviBgColor: .COLOR_BG_F2)
        view.backgroundColor = .COLOR_BG_F2
        scrollViewBase.backgroundColor = .COLOR_BG_F2
        scrollViewBase.alwaysBounceVertical = false

        view.addSubview(scrollViewBase)
        scrollViewBase.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollViewBase)
        }

        contentView.addSubview(statusLabel)
        contentView.addSubview(cardView)
        contentView.addSubview(manageButton)

        cardView.addSubview(logoImageView)
        cardView.addSubview(planTypeLabel)
        cardView.addSubview(expireLabel)
        cardView.addSubview(purchaseDescLabel)

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(20))
            make.left.equalTo(kFitWidth(16))
        }

        cardView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(kFitWidth(12))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }

        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(80))
//            make.height.equalTo(kFitWidth(1))
        }

        planTypeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(logoImageView)
            make.right.equalTo(kFitWidth(-16))
            make.left.greaterThanOrEqualTo(logoImageView.snp.right).offset(kFitWidth(12))
        }

        expireLabel.snp.makeConstraints { make in
            make.left.equalTo(logoImageView)
            make.right.equalTo(planTypeLabel)
            make.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(14))
        }

        purchaseDescLabel.snp.makeConstraints { make in
            make.left.equalTo(logoImageView)
            make.right.equalTo(planTypeLabel)
            make.top.equalTo(expireLabel.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalToSuperview().offset(-kFitWidth(16))
        }

        manageButton.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(kFitWidth(18))
            make.centerX.equalToSuperview()
            make.height.equalTo(kFitWidth(24))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(20)))
        }
    }

    func sendVipInfoRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_info, parameters: nil) { [weak self] responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let vipModel = VIPModel.shared.update(with: dataDict)

            DispatchQueue.main.async {
                self?.refreshUI(with: vipModel)
            }
        } failure: { _ in
        }
    }

    func refreshUI(with model: VIPModel) {
        statusLabel.text = displayStatusText(for: model.status)
        planTypeLabel.text = displayPlanText(for: model)
        expireLabel.text = displayExpireText(for: model)
        purchaseDescLabel.text = displayPurchaseText(for: model)
    }

    func displayStatusText(for status: VIP_STATUS?) -> String {
        switch status {
        case .valid:
            return "使用中"
        case .expired:
            return "已过期"
        case .banned:
            return "不可用"
        case .invalid, .none:
            return "未订阅"
        }
    }

    func displayPlanText(for model: VIPModel) -> String {
        if model.isLifetime || model.vipType == .lifetime {
            return "永久"
        }

        switch model.vipType {
        case .month:
            return "1个月"
        case .year:
            return "1年"
        case .lifetime:
            return "永久"
        case .none:
            switch model.status {
            case .expired:
                return "已过期"
            case .banned:
                return "不可用"
            default:
                return "未开通"
            }
        }
    }

    func displayExpireText(for model: VIPModel) -> String {
        if model.isLifetime || model.vipType == .lifetime {
            return "永久有效"
        }

        if model.expireTimeUtc > 0 {
            let expireDate = Date(timeIntervalSince1970: TimeInterval(model.expireTimeUtc) / 1000.0)
            if Calendar.current.isDateInToday(expireDate) {
                return "今日\(expireDate.toLocalString("HH:mm"))到期"
            }
            return "\(expireDate.toLocalString("yyyy年MM月dd日")) 到期"
        }

        if model.expireTime.isEmpty == false {
            let format = model.expireTime.contains(".") ? "yyyy-MM-dd HH:mm:ss.SSSSSSSSS" : "yyyy-MM-dd HH:mm:ss"
            let expireDate = Date().changeDateStringToDate(dateString: model.expireTime, formatter: format)
            if Calendar.current.isDateInToday(expireDate) {
                return "今日\(expireDate.toLocalString("HH:mm"))到期"
            }
            return "\(expireDate.toLocalString("yyyy年MM月dd日")) 到期"
        }

        switch model.status {
        case .expired:
            return "当前订阅已过期"
        case .banned:
            return "当前订阅暂不可用"
        default:
            return "当前暂无有效订阅"
        }
    }

    func displayPurchaseText(for model: VIPModel) -> String {
        switch model.status {
        case .invalid:
            return "当前暂无 App Store 有效订阅"
        case .banned:
            return "当前订阅状态异常，请联系支持"
        default:
            return "在苹果App Store内购买订阅"
        }
    }

    @objc func manageButtonTapAction() {
        let vc = MineManageSubscriptionVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}
