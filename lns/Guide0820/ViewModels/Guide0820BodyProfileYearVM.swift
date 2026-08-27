//
//  Guide0820BodyProfileYearVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820 出生年份页 VM，复用 DietPlanCreateYearVM 的 pickerView 和年份数据逻辑。
final class Guide0820BodyProfileYearVM: DietPlanCreateYearVM {
    /// 出生年份变化回调，用于外层实时保存当前选择。
    var birthYearChangedBlock: ((String) -> Void)?

    /// Guide0820 设计稿里的选中行背景。
    private let selectionBackgroundView = UIView()

    /// 出生年份页始终有效，外层可直接允许下一步。
    var isStepValid: Bool { true }

    /// 初始化旧年份 VM，并在其基础上重排 Guide0820 页面样式。
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyGuide0820Layout()
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 将当前 pickerView 选中的出生年份写入问卷模型。
    func commitCurrentValue() {
        getBirthDayData()
        Guide0820Model.shared.birthDay = Guide0820Model.shared.birthYear
    }

    /// 页面显示钩子，保留给外层流程统一调用。
    func pageWillAppear() {}

    /// 用户滚动年份后实时同步到本地进度。
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Guide0820Model.shared.birthYear = "\(yearDataArray[row] as? Int ?? 0)"
        Guide0820Model.shared.birthDay = Guide0820Model.shared.birthYear
        DLLog(message: "生日：\(Guide0820Model.shared.birthYear)")
        birthYearChangedBlock?(Guide0820Model.shared.birthYear)
    }

    /// 当前选中的出生年份。
    var currentBirthYear: String {
        getBirthDayData()
        return Guide0820Model.shared.birthYear
    }

    /// 恢复本地保存的出生年份。
    func restore(birthYear: String?) {
        guard let birthYear,
              let targetYear = Int(birthYear),
              let yearArray = yearDataArray as? [Int],
              let index = yearArray.firstIndex(of: targetYear) else { return }
        pickerView.selectRow(index, inComponent: 0, animated: false)
        Guide0820Model.shared.birthYear = birthYear
        Guide0820Model.shared.birthDay = birthYear
    }

    /// 执行 `layoutSubviews` 操作，完成当前引导页面的状态更新或交互处理。
    override func layoutSubviews() {
        super.layoutSubviews()
        hidePickerSystemIndicator()
    }

    /// 在 DietPlanCreateYearVM 默认 UI 基础上，调整为 Guide0820 设计稿布局。
    private func applyGuide0820Layout() {
        pickerRowHeight = guide0820Design(120)
        pickerView.reloadAllComponents()
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: guide0820Design(48), weight: .medium)
        titleLabel.setLineHeight(textString: titleLabel.text ?? "", lineHeight: guide0820Design(72))
        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        insertSubview(selectionBackgroundView, belowSubview: pickerView)
        selectionBackgroundView.backgroundColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.05)
        selectionBackgroundView.layer.cornerRadius = guide0820Design(24)
        selectionBackgroundView.layer.cornerCurve = .continuous
        selectionBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(32))
            make.top.equalTo(guide0820Design(835))
            make.height.equalTo(guide0820Design(120))
        }
        pickerView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.top.equalTo(guide0820Design(640))
            make.height.equalTo(kFitWidth(252))
        }

        yearUnitLabel.removeFromSuperview()
        addSubview(yearUnitLabel)
        yearUnitLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        yearUnitLabel.snp.makeConstraints { make in
            make.centerY.equalTo(selectionBackgroundView)
            make.left.equalTo(pickerView.snp.centerX).offset(guide0820Design(85))
        }

        DispatchQueue.main.async { [weak self] in
            self?.hidePickerSystemIndicator()
        }
    }

    // 执行 `hidePickerSystemIndicator` 操作，完成当前引导页面的状态更新或交互处理。
    private func hidePickerSystemIndicator() {
        pickerView.subviews.forEach { subview in
            guard !(subview is UILabel) else { return }

            let className = NSStringFromClass(type(of: subview))
            let height = subview.bounds.height
            let isSelectionView = className.contains("Selection")
            let isIndicatorSizedView = height > 0 && height <= pickerRowHeight + 1

            if isSelectionView || isIndicatorSizedView {
                subview.backgroundColor = .clear
                subview.isHidden = true
            }
        }
    }
}
