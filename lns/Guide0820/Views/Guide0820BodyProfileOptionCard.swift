//
//  Guide0820BodyProfileOptionCard.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 身体资料页通用选项卡，包含图标、标题、副标题和选择圆点。
final class Guide0820BodyProfileOptionCard: UIControl {
    /// 当前卡片绑定的选项数据。
    private let item: Guide0820BodyProfileOption

    /// 左侧图标文本 Label，缺少图标资源时兜底展示。
    private let iconLabel = UILabel()

    /// 左侧图标图片视图。
    private let iconImageView = UIImageView()

    /// 选项标题 Label。
    private let titleLabel = UILabel()

    /// 选项副标题 Label。
    private let subtitleLabel = UILabel()

    /// 右侧选择圆点视图。
    private let selectCircle = UIView()

    /// 当前选项提交值。
    var value: String { item.value }

    /// 使用选项数据初始化卡片。
    init(item: Guide0820BodyProfileOption) {
        self.item = item
        super.init(frame: .zero)
        initUI()
        updateSelectedState(false)
    }

    /// Storyboard 初始化入口，本控件不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 选中态变化时刷新右侧圆点。
    override var isSelected: Bool {
        didSet { updateSelectedState(isSelected) }
    }

    /// 按 MasterGo 设计稿创建卡片内部视图和约束。
    private func initUI() {
        backgroundColor = .white
        layer.cornerRadius = guide0820Design(24)
        layer.cornerCurve = .continuous
        clipsToBounds = true

        if let iconName = item.iconName {
            iconImageView.setImgLocal(imgName: iconName)
            iconImageView.contentMode = .scaleAspectFit
        } else {
            iconLabel.text = item.iconText
            iconLabel.textAlignment = .center
            iconLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            iconLabel.font = .systemFont(ofSize: guide0820Design(40), weight: .medium)
        }

        titleLabel.text = item.title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(32), weight: .medium)

        subtitleLabel.text = item.subtitle
        subtitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.5)
        subtitleLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        subtitleLabel.isHidden = item.subtitle == nil

        selectCircle.backgroundColor = .clear
        selectCircle.layer.borderWidth = guide0820Design(3)
        selectCircle.layer.cornerRadius = guide0820Design(24)

        let iconView: UIView = item.iconName == nil ? iconLabel : iconImageView
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(selectCircle)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(32))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(guide0820Design(item.iconName == nil ? 40 : 50))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(116))
            make.right.lessThanOrEqualTo(selectCircle.snp.left).offset(guide0820Design(-36))
            if item.subtitle == nil {
                make.centerY.equalToSuperview()
            } else {
                make.top.equalTo(guide0820Design(40))
            }
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(12))
            make.right.lessThanOrEqualTo(selectCircle.snp.left).offset(guide0820Design(-36))
        }

        selectCircle.snp.makeConstraints { make in
            make.right.equalTo(guide0820Design(-32))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(guide0820Design(48))
        }
    }

    /// 根据选中态更新圆点边框、背景和对勾。
    private func updateSelectedState(_ selected: Bool) {
        selectCircle.layer.borderColor = selected ? UIColor.THEME.cgColor : UIColor.COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.15).cgColor
        selectCircle.backgroundColor = selected ? .THEME : .clear
        if selected {
            let checkLayerName = "guide0820_check"
            selectCircle.layer.sublayers?.removeAll(where: { $0.name == checkLayerName })
            let path = UIBezierPath()
            path.move(to: CGPoint(x: guide0820Design(12), y: guide0820Design(24)))
            path.addLine(to: CGPoint(x: guide0820Design(20), y: guide0820Design(32)))
            path.addLine(to: CGPoint(x: guide0820Design(36), y: guide0820Design(16)))
            let layer = CAShapeLayer()
            layer.name = checkLayerName
            layer.path = path.cgPath
            layer.strokeColor = UIColor.white.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = guide0820Design(4)
            layer.lineCap = .round
            layer.lineJoin = .round
            selectCircle.layer.addSublayer(layer)
        } else {
            selectCircle.layer.sublayers?.removeAll(where: { $0.name == "guide0820_check" })
        }
    }
}
