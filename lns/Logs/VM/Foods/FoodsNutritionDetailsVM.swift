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
    let displayMaximumFractionDigits: Int
}

private class FoodsNutritionDetailRowView: UIView {
    let titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()

    let valueLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
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

private class FoodsNutritionDetailEntryVM: UIView {
    var tapBlock: (() -> Void)?

    private let iconImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.setImgLocal(imgName: "elements_detail_icon")
        return img
    }()

    private let titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "查看今日营养达标情况"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = kFitWidth(8)
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .COLOR_BG_F2
        layer.cornerRadius = kFitWidth(20)
        clipsToBounds = true
        isUserInteractionEnabled = true

        addSubview(contentStackView)
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(titleLabel)

        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(17))
        }
        contentStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(kFitWidth(16))
            make.right.lessThanOrEqualTo(kFitWidth(-16))
        }

        enablePreseeRippleEffect { [weak self] in
            self?.tapBlock?()
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
    var detailTapBlock: (() -> Void)?

    private let collapsedHeight = kFitWidth(55)
    private let headerHeight = kFitWidth(55)
    private let rowHeight = kFitWidth(36)
    private let whiteWidth = SCREEN_WIDHT - kFitWidth(32)
    private var rowViews: [FoodsNutritionDetailRowView] = []
    private var isExpanded = false

    private let detailItems: [FoodsNutritionDetailItem] = FoodsNutritionCatalog.shared.flatItems.map {
        FoodsNutritionDetailItem(title: $0.title, key: $0.key, unit: $0.unit, displayMaximumFractionDigits: $0.displayMaximumFractionDigits)
    }

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
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        return vi
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "营养详情"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
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
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()

    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private lazy var detailEntryVm: FoodsNutritionDetailEntryVM = {
        let vm = FoodsNutritionDetailEntryVM()
        vm.tapBlock = { [weak self] in
            self?.detailTapBlock?()
        }
        return vm
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
        whiteView.addSubview(detailEntryVm)
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
            make.left.equalTo(kFitWidth(17))
            make.top.equalTo(kFitWidth(21))
        }
        arrowImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-17))
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(kFitWidth(20))
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
        detailEntryVm.snp.makeConstraints { make in
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
        if let decimal = Decimal(string: rawText),
           NSDecimalNumber(decimal: decimal).compare(NSDecimalNumber.zero) == .orderedSame {
            return "-"
        }

        let displayText = WHUtils.convertStringToString(rawText, digitNumer: item.displayMaximumFractionDigits) ?? rawText

        return "\(displayText) \(item.unit)"
    }

    private func refreshExpandedState(animated: Bool) {
        arrowImageView.setImgLocal(imgName: isExpanded ? "arrow_up_icon" : "arrow_down_icon")
        if isExpanded {
            lineView.isHidden = false
            stackView.isHidden = false
            detailEntryVm.isHidden = false
        }
        
        let changes = {
            self.frame.size.height = self.currentHeight
            self.whiteView.frame = CGRect(x: kFitWidth(16), y: 0, width: self.whiteWidth, height: self.currentHeight)
            self.layoutIfNeeded()
        }
        let completion = { (_: Bool) in
            self.lineView.isHidden = !self.isExpanded
            self.stackView.isHidden = !self.isExpanded
            self.detailEntryVm.isHidden = !self.isExpanded
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: changes, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                changes()
                completion(true)
            }
        }
    }
}

extension FoodsNutritionDetailsVM {
    @objc func toggleAction() {
        isExpanded.toggle()
        refreshExpandedState(animated: true)
        heightChangeBlock?()
    }
}
