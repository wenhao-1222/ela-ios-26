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

//    private lazy var switchButton: SwitchButton = {
//        let btn = SwitchButton(frame: CGRect(x: SCREEN_WIDHT - kFitWidth(16) - SwitchButton().selfWidth,
//                                             y: (kFitWidth(51) - SwitchButton().selfHeight) * 0.5,
//                                             width: 0,
//                                             height: 0))
//        btn.tapBlock = { [weak self] isSelect in
//            self?.onSwitchChanged?(isSelect)
//            btn.setSelectStatus(status: isSelect)
//        }
//        return btn
//    }()
    lazy var switchBtn: UISwitch = {
        let btn = UISwitch()
        btn.onTintColor = .THEME
        btn.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return btn
    }()

    private let lineView: UIView = {
        let v = UIView()
        v.backgroundColor = .COLOR_LINE_F0
        v.isHidden = true
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .COLOR_CARD_BG_WHITE
        contentView.backgroundColor = .COLOR_CARD_BG_WHITE
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initUI() {
        contentView.addSubview(leftTitleLabel)
//        contentView.addSubview(switchButton)
        contentView.addSubview(switchBtn)
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
        switchBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }

    func update(isOn: Bool) {
//        switchButton.setSelectStatus(status: isOn)
        switchBtn.setOn(isOn, animated: false)
    }
    @objc private func switchChanged(_ sender: UISwitch) {
        print("isOn =", sender.isOn)
//        self.switchBlock?(sender.isOn)
        self.onSwitchChanged?(sender.isOn)
    }
}
