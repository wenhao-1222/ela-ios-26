//
//  FoodsNutritionDetailsVM.swift
//  lns
//
//  Created by Codex on 2026/7/15.
//

import Foundation
import UIKit

private struct FoodsNutritionDetailItem {
    let title: String
    let key: String
    let unit: String
}

private class FoodsNutritionDetailRowView: UIView {
    let titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    let valueLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.8
        return lab
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(valueLabel.snp.left).offset(kFitWidth(-12))
        }
        valueLabel.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(kFitWidth(96))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FoodsNutritionDetailsVM: UIView {
    var foodsDetailDict = NSDictionary() {
        didSet {
            updateRows()
        }
    }
    var heightChangeBlock: (() -> Void)?
    var detailButtonBlock: (() -> Void)?

    private let collapsedHeight = kFitWidth(68)
    private let headerHeight = kFitWidth(68)
    private let rowHeight = kFitWidth(41)
    private let whiteWidth = SCREEN_WIDHT - kFitWidth(32)
    private var rowViews: [FoodsNutritionDetailRowView] = []
    private var isExpanded = false

    private let detailItems: [FoodsNutritionDetailItem] = [
        FoodsNutritionDetailItem(title: "纤维", key: "fibre", unit: "g"),
        FoodsNutritionDetailItem(title: "糖", key: "sugar", unit: "g"),
        FoodsNutritionDetailItem(title: "饱和脂肪", key: "saturatedFat", unit: "g"),
        FoodsNutritionDetailItem(title: "反式脂肪", key: "transFat", unit: "g"),
        FoodsNutritionDetailItem(title: "胆固醇", key: "cholesterol", unit: "mg"),
        FoodsNutritionDetailItem(title: "钠", key: "sodium", unit: "mg"),
        FoodsNutritionDetailItem(title: "钾", key: "potassium", unit: "mg"),
        FoodsNutritionDetailItem(title: "钙", key: "calcium", unit: "mg"),
        FoodsNutritionDetailItem(title: "铁", key: "iron", unit: "mg"),
        FoodsNutritionDetailItem(title: "维生素 A", key: "vitaminA", unit: "μg"),
        FoodsNutritionDetailItem(title: "维生素 C", key: "vitaminC", unit: "mg"),
        FoodsNutritionDetailItem(title: "嘌呤", key: "purine", unit: "mg"),
        FoodsNutritionDetailItem(title: "咖啡因", key: "caffeine", unit: "mg"),
        FoodsNutritionDetailItem(title: "肌酸", key: "creatine", unit: "mg")
    ]

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: collapsedHeight))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var whiteView: UIView = {
        let vi = UIView(frame: CGRect(x: kFitWidth(16), y: 0, width: whiteWidth, height: collapsedHeight))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        return vi
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "营养详情"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()

    lazy var arrowImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.setImgLocal(imgName: "arrow_down_icon")
        return img
    }()

    lazy var headerTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        return vi
    }()

    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_BLACK_06
        return vi
    }()

    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    lazy var detailButton: GJVerButton = {
        let btn = GJVerButton()
        btn.backgroundColor = .COLOR_BG_F2
        btn.layer.cornerRadius = kFitWidth(20)
        btn.clipsToBounds = true
        btn.setTitle("查看今日营养达标情况", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setImage(UIImage(named: "elements_detail_icon"), for: .normal)
        btn.imagePosition(style: .left, spacing: kFitWidth(8))
        btn.addTarget(self, action: #selector(detailButtonTapAction), for: .touchUpInside)
        return btn
    }()
}

extension FoodsNutritionDetailsVM {
    var currentHeight: CGFloat {
        if isExpanded == false {
            return collapsedHeight
        }
        return headerHeight + kFitWidth(1) + kFitWidth(16) + CGFloat(detailItems.count) * rowHeight + kFitWidth(20) + kFitWidth(40) + kFitWidth(28)
    }

    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(arrowImageView)
        whiteView.addSubview(lineView)
        whiteView.addSubview(stackView)
        whiteView.addSubview(detailButton)
        whiteView.addSubview(headerTapView)

        detailItems.forEach { item in
            let rowView = FoodsNutritionDetailRowView()
            rowView.titleLabel.text = item.title
            rowViews.append(rowView)
            stackView.addArrangedSubview(rowView)
            rowView.snp.makeConstraints { make in
                make.height.equalTo(rowHeight)
            }
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleAction))
        headerTapView.addGestureRecognizer(tap)

        setConstrait()
        refreshExpandedState(animated: false)
        updateRows()
    }

    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(22))
        }
        arrowImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-24))
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        headerTapView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(headerHeight)
            make.height.equalTo(kFitWidth(1))
        }
        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(16))
        }
        detailButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom).offset(kFitWidth(20))
            make.width.equalTo(kFitWidth(252))
            make.height.equalTo(kFitWidth(40))
        }
    }

    func updateRows() {
        for (index, item) in detailItems.enumerated() {
            guard index < rowViews.count else { continue }
            rowViews[index].valueLabel.text = valueText(for: item)
        }
    }

    private func valueText(for item: FoodsNutritionDetailItem) -> String {
        guard let value = foodsDetailDict[item.key], !(value is NSNull) else {
            return "-"
        }

        let rawText: String
        if let string = value as? String {
            rawText = string.replacingOccurrences(of: ",", with: ".")
        } else if let number = value as? NSNumber {
            rawText = number.stringValue
        } else {
            rawText = "\(value)"
        }

        if rawText.count == 0 || rawText == "-" {
            return "-"
        }

        let displayText: String
        if let decimal = Decimal(string: rawText) {
            displayText = NSDecimalNumber(decimal: decimal).stringValue
        } else {
            displayText = rawText
        }

        return "\(displayText) \(item.unit)"
    }

    private func refreshExpandedState(animated: Bool) {
        frame.size.height = currentHeight
        whiteView.frame = CGRect(x: kFitWidth(16), y: 0, width: whiteWidth, height: currentHeight)
        lineView.isHidden = !isExpanded
        stackView.isHidden = !isExpanded
        detailButton.isHidden = !isExpanded
        arrowImageView.setImgLocal(imgName: isExpanded ? "arrow_up_icon" : "arrow_down_icon")

        let changes = {
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: changes)
        } else {
            changes()
        }
    }
}

extension FoodsNutritionDetailsVM {
    @objc func toggleAction() {
        isExpanded.toggle()
        refreshExpandedState(animated: true)
        heightChangeBlock?()
    }

    @objc func detailButtonTapAction() {
        detailButtonBlock?()
    }
}
