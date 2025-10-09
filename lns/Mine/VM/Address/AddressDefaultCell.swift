//
//  AddressDefaultCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/12.
//


import UIKit

final class AddressDefaultCell: UITableViewCell {

    var onSwitchChanged: ((Bool) -> Void)?

    private let leftTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "设为默认地址"
        l.textColor = .COLOR_TEXT_TITLE_0f1214_50
        l.font = .systemFont(ofSize: 13, weight: .regular)
        return l
    }()

    private lazy var switchButton: SwitchButton = {
        let btn = SwitchButton(frame: CGRect(x: SCREEN_WIDHT - kFitWidth(16) - SwitchButton().selfWidth,
                                             y: (kFitWidth(51) - SwitchButton().selfHeight) * 0.5,
                                             width: 0,
                                             height: 0))
        btn.tapBlock = { [weak self] isSelect in
            self?.onSwitchChanged?(isSelect)
            btn.setSelectStatus(status: isSelect)
        }
        return btn
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
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initUI() {
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(switchButton)
        contentView.addSubview(lineView)

        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }

    func update(isOn: Bool) {
        switchButton.setSelectStatus(status: isOn)
    }
}
