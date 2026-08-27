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
        detail: "许多人倾向于低估自己的体脂率，部分原因在于常用的测量方法（如电阻体脂仪和体脂秤）可能不够准确。"
    )

    /// 当前选中的体脂值。
    var selectedBodyFatValue: String? {
        guard selectIndex >= 0 else { return nil }
        let sourceArray: [[String: String]]
        if Guide0820Model.shared.sex == "1" {
            sourceArray = dataArray
        } else if Guide0820Model.shared.sex == "2" {
            sourceArray = dataFemanArray
        } else {
            return nil
        }
        guard selectIndex < sourceArray.count else { return nil }
        let value = (sourceArray[selectIndex]["data"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    /// `bodyFatSex` 属性，保存该类型对外提供或内部使用的状态与配置。
    override var bodyFatSex: String { Guide0820Model.shared.sex }

    /// 执行 `setBodyFatModelValue` 操作，完成当前引导页面的状态更新或交互处理。
    override func setBodyFatModelValue(_ value: String) {
        Guide0820Model.shared.bodyFat = value
    }

    /// 执行 `commitCurrentValue` 操作，完成当前引导页面的状态更新或交互处理。
    override func commitCurrentValue() {
        updateBodyFatValue(index: selectIndex)
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
        applyGuide0820BodyFatGridLayout()
        applyGuide0820Layout()
        updateScrollView()
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
            make.top.equalTo(guide0820InfoCardTop)
            make.height.equalTo(guide0820Design(178))
        }
    }

    /// 按 MasterGo 选中画布：左右 42px 不变，三列图片之间间距 10px。
    private func applyGuide0820BodyFatGridLayout() {
        let horizontalInset = guide0820Design(42)
        let interitemSpacing = guide0820Design(10)
        let contentWidth = SCREEN_WIDHT - horizontalInset * 2
        let imageSide = (contentWidth - interitemSpacing * 2) / 3

        bodyFatColumnCount = 3
        bodyFatListHorizontalInset = horizontalInset
        bodyFatListInteritemSpacing = interitemSpacing
        bodyFatListTopInset = kFitWidth(35)
        bodyFatListBottomInset = guide0820Design(24)
        bodyFatItemHeight = imageSide + guide0820Design(24)
        bodyFatItemImageSide = imageSide
        bodyFatItemImageLeftInset = 0
        bodyFatItemImageRightInset = 0
        bodyFatItemSelectedInset = guide0820Design(8)
        bodyFatItemSelectedImageSide = max(imageSide - guide0820Design(16), 0)
        bodyFatSelectIconSize = guide0820Design(16)
        bodyFatSelectIconLeft = guide0820Design(28)
        bodyFatSelectIconTop = guide0820Design(49)
        bodyFatSelectedTitleIconSpacing = guide0820Design(8)
        bodyFatCentersSelectedContent = true
    }

    // `guide0820InfoCardTop` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var guide0820InfoCardTop: CGFloat {
        let rowCount = ceil(CGFloat(max(dataArray.count, dataFemanArray.count)) / CGFloat(bodyFatColumnCount))
        let imageListBottom = guide0820Design(378) + max(rowCount - 1, 0) * bodyFatItemHeight + bodyFatItemImageSide
        return imageListBottom + guide0820Design(24)
    }
}
