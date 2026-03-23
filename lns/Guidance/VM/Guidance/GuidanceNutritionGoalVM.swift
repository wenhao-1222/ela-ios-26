//
//  GuidanceNutritionGoalVM.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit
import SnapKit

class GuidanceNutritionGoalVM: UIView {

    var saveBlock: (() -> ())?
    private let maxCaloriesValue = 9999
    private let maxMacroValue = 999

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        initUI()
        refreshContentFromModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你的卡路里和营养素目标"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .semibold)
        return lab
    }()

    lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 28, weight: .regular)
        lab.text = "0"
        return lab
    }()

    lazy var caloriesTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "卡路里 (千卡)"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    lazy var goalIconView: UIImageView = {
        let img = UIImageView()
        if #available(iOS 13.0, *) {
            img.image = UIImage(systemName: "target")
        }
        img.tintColor = .THEME
        img.contentMode = .scaleAspectFit
        return img
    }()

    lazy var carbRow = GuidanceNutritionGoalRowView(title: "碳水化合物")
    lazy var proteinRow = GuidanceNutritionGoalRowView(title: "蛋白质")
    lazy var fatRow = GuidanceNutritionGoalRowView(title: "脂肪")

    lazy var saveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveTapAction), for: .touchUpInside)
        return btn
    }()
}

extension GuidanceNutritionGoalVM {
    @objc func saveTapAction() {
        sanitizeModelValues()
        saveBlock?()
    }

    func refreshContentFromModel() {
        sanitizeModelValues()
        caloriesLabel.text = normalizedDisplayText(QuestinonaireMsgModel.shared.caloriesNumber, maxValue: maxCaloriesValue)
        carbRow.updateValue(normalizedDisplayText(QuestinonaireMsgModel.shared.carbohydratesNumber, maxValue: maxMacroValue))
        proteinRow.updateValue(normalizedDisplayText(QuestinonaireMsgModel.shared.proteinNumber, maxValue: maxMacroValue))
        fatRow.updateValue(normalizedDisplayText(QuestinonaireMsgModel.shared.fatsNumber, maxValue: maxMacroValue))
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(cardView)

        cardView.addSubview(caloriesLabel)
        cardView.addSubview(caloriesTitleLabel)
        cardView.addSubview(goalIconView)
        cardView.addSubview(carbRow)
        cardView.addSubview(proteinRow)
        cardView.addSubview(fatRow)
        cardView.addSubview(saveButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(88))
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(56))
        }

        caloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(kFitWidth(26))
        }

        caloriesTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesLabel)
            make.top.equalTo(caloriesLabel.snp.bottom).offset(kFitWidth(6))
        }

        goalIconView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-26))
            make.centerY.equalTo(caloriesLabel.snp.centerY).offset(kFitWidth(14))
            make.width.height.equalTo(kFitWidth(44))
        }

        carbRow.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-14))
            make.top.equalTo(caloriesTitleLabel.snp.bottom).offset(kFitWidth(42))
            make.height.equalTo(kFitWidth(72))
        }

        proteinRow.snp.makeConstraints { make in
            make.left.right.height.equalTo(carbRow)
            make.top.equalTo(carbRow.snp.bottom)
        }

        fatRow.snp.makeConstraints { make in
            make.left.right.height.equalTo(carbRow)
            make.top.equalTo(proteinRow.snp.bottom)
        }

        saveButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(fatRow.snp.bottom).offset(kFitWidth(40))
            make.bottom.equalTo(kFitWidth(-24))
        }
    }
}

private extension GuidanceNutritionGoalVM {
    func sanitizeModelValues() {
        QuestinonaireMsgModel.shared.caloriesNumber = normalizedDisplayText(QuestinonaireMsgModel.shared.caloriesNumber, maxValue: maxCaloriesValue)
        QuestinonaireMsgModel.shared.caloriesNumberFromServer = normalizedDisplayText(QuestinonaireMsgModel.shared.caloriesNumberFromServer, maxValue: maxCaloriesValue)
        QuestinonaireMsgModel.shared.carbohydratesNumber = normalizedDisplayText(QuestinonaireMsgModel.shared.carbohydratesNumber, maxValue: maxMacroValue)
        QuestinonaireMsgModel.shared.proteinNumber = normalizedDisplayText(QuestinonaireMsgModel.shared.proteinNumber, maxValue: maxMacroValue)
        QuestinonaireMsgModel.shared.fatsNumber = normalizedDisplayText(QuestinonaireMsgModel.shared.fatsNumber, maxValue: maxMacroValue)
    }

    func normalizedDisplayText(_ rawValue: String, maxValue: Int) -> String {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return "0" }
        let value = Int(trimmedValue) ?? 0
        return "\(min(max(value, 0), maxValue))"
    }
}

class GuidanceNutritionGoalRowView: UIView {

    init(title: String) {
        self.titleText = title
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleText: String

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = titleText
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 15, weight: .medium)
        return lab
    }()

    lazy var valueLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 15, weight: .regular)
        lab.textAlignment = .right
        return lab
    }()

    lazy var separatorLine: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        return vi
    }()
}

extension GuidanceNutritionGoalRowView {
    func updateValue(_ value: String) {
        let display = value.isEmpty ? "0" : value
        valueLabel.text = "\(display) g"
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(separatorLine)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.centerY.equalToSuperview()
        }

        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.right.equalTo(kFitWidth(-8))
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
