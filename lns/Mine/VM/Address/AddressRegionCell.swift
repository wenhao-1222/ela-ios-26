//
//  AddressRegionCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/12.
//

import UIKit

final class AddressRegionCell: UITableViewCell {

    var onTapChoose: (() -> Void)?

    private let leftTitleLabel: UILabel = {
        let l = UILabel()
        l.textColor = .COLOR_TEXT_TITLE_0f1214
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.text = "所在地区"
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.textColor = .COLOR_TEXT_TITLE_0f1214
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.numberOfLines = 0 // 多行
        l.text = "省、市、区、街道"
        l.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return l
    }()

    private let chevronBtn: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "mall_spec_arrow_down_icon"), for: .normal)

        return b
    }()

    private let lineView: UIView = {
        let v = UIView()
        v.backgroundColor = .COLOR_BG_F5
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(chevronBtn)
        contentView.addSubview(lineView)

        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
//            make.width.lessThanOrEqualTo(70)
        }
        chevronBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        valueLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(88))
            make.top.equalTo(kFitWidth(12))
            make.right.equalTo(chevronBtn.snp.left).offset(-6)
            make.bottom.equalTo(kFitWidth(-12))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        contentView.addGestureRecognizer(tap)
        chevronBtn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func tapAction() { onTapChoose?() }

    func update(with model: AddressModel?) {
        if let m = model, !m.provinceName.isEmpty {
            valueLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            // 多行完整展示（省 市 区）
            var parts: [String] = []
            if !m.provinceName.isEmpty { parts.append(m.provinceName) }
            if !m.cityName.isEmpty { parts.append(m.cityName) }
            if !m.areaName.isEmpty { parts.append(m.areaName) }
            valueLabel.text = parts.joined(separator: "  ")
        } else {
            valueLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            valueLabel.text = "省、市、区、街道"
        }
        layoutIfNeeded()
    }
}
