//
//  Guide0820BodyProfileBodyfatVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 体脂率页 VM，复用旧体脂选择控件并按 Guide0820 设计稿重排外层布局。
final class Guide0820BodyProfileBodyfatVM: DietPlanCreateBodyfatVM {
    /// 体脂说明卡，点击后复用旧体脂说明弹窗。
    private let infoCard = Guide0820BodyProfileInfoCard(
        title: "体脂肪误差：为什么测量值通常偏低？",
        detail: "大多数家用体脂秤受水分、时间、设备算法影响，测量值通常会比真实体脂率偏低..."
    )

    /// 当前选中的体脂值。
    var selectedBodyFatValue: String? {
        guard selectIndex >= 0 else { return nil }
        let sourceArray: [[String: String]]
        if QuestinonaireMsgModel.shared.sex == "1" {
            sourceArray = dataArray
        } else if QuestinonaireMsgModel.shared.sex == "2" {
            sourceArray = dataFemanArray
        } else {
            return nil
        }
        guard selectIndex < sourceArray.count else { return nil }
        let value = (sourceArray[selectIndex]["data"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    /// 初始化并覆盖旧体脂 VM 的默认视觉布局。
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        titleLabel.font = .systemFont(ofSize: guide0820Design(48), weight: .medium)
        titleLabel.text = "你现在的体脂率是？"
        tipsButton.isHidden = true
        topGradientView.isHidden = true
        bottomGradientView.isHidden = true
        applyGuide0820Layout()
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 重排标题、体脂列表和说明卡到 Guide0820 设计稿位置。
    private func applyGuide0820Layout() {
        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        scrollView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(guide0820Design(378) - kFitWidth(35))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + guide0820Design(120)))
        }

        addSubview(infoCard)
        infoCard.addTarget(self, action: #selector(showTipsAction), for: .touchUpInside)
        infoCard.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(guide0820Design(1413))
            make.height.equalTo(guide0820Design(178))
        }
    }
}
