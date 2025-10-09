//
//  AddressCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/12.
//

import UIKit

final class AddressCell: UITableViewCell {

    static let reuseId = "AddressCell"
    static let defaultHeight: CGFloat = kFitWidth(72)

    var onTapCheck: (() -> Void)?

    private let nameLab: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 15, weight: .medium)
        v.textColor = .COLOR_TEXT_TITLE_0f1214
        return v
    }()

    private let phoneLab: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 15)
        v.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return v
    }()

    private let addrLab: UILabel = {
        let v = UILabel()
        v.numberOfLines = 2
        v.font = .systemFont(ofSize: 12)
        v.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return v
    }()

    private let defaultTag: UILabel = {
        let v = UILabel()
        v.text = "默认"
        v.textColor = .white
        v.font = .systemFont(ofSize: 10, weight: .medium)
        v.backgroundColor = WHColorWithAlpha(colorStr: "0FA96E", alpha: 1.0)
        v.layer.cornerRadius = 3
        v.layer.masksToBounds = true
        v.textAlignment = .center
        v.isHidden = true
        return v
    }()

    private lazy var checkBtn: UIButton = {
        let b = UIButton(type: .custom)
        // 替换为你项目中的勾选/未勾选资源名
        b.setImage(UIImage(named: "mall_address_normal_icon"), for: .normal)
        b.setImage(UIImage(named: "mall_address_default_icon"), for: .selected)
        b.addTarget(self, action: #selector(tapCheck), for: .touchUpInside)
        return b
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(nameLab)
        contentView.addSubview(phoneLab)
//        contentView.addSubview(defaultTag)
        contentView.addSubview(addrLab)
        contentView.addSubview(checkBtn)
        contentView.addSubview(divider)

        checkBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(22))
        }
        nameLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(kFitWidth(14))
            make.left.equalToSuperview().inset(kFitWidth(20))
        }
//        defaultTag.snp.makeConstraints { make in
//            make.left.equalTo(nameLab.snp.right).offset(kFitWidth(8))
//            make.centerY.equalTo(nameLab)
//            make.width.greaterThanOrEqualTo(kFitWidth(28))
//            make.height.equalTo(kFitWidth(16))
//        }
        phoneLab.snp.makeConstraints { make in
            make.centerY.equalTo(nameLab)
            make.left.greaterThanOrEqualTo(nameLab.snp.right).offset(kFitWidth(8))
//            make.right.lessThanOrEqualTo(checkBtn.snp.left).offset(-kFitWidth(10))
        }
        addrLab.snp.makeConstraints { make in
            make.top.equalTo(nameLab.snp.bottom).offset(kFitWidth(8))
            make.left.equalTo(nameLab)
            make.right.equalTo(checkBtn.snp.left).offset(-kFitWidth(10))
            make.bottom.equalToSuperview().inset(kFitWidth(12))
        }
        divider.snp.makeConstraints { make in
            make.left.equalTo(nameLab)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func tapCheck() { onTapCheck?() }

    func config(model: AddressModel, chosen: Bool) {
        nameLab.text = model.contactName
        phoneLab.text = model.contactPhone
        addrLab.text = model.detailAddressWhole
//        defaultTag.isHidden = !model.isDefault
        checkBtn.isSelected = chosen
    }
}
