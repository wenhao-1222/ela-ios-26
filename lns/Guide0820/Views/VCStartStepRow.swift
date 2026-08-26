//
//  VCStartStepRow.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// “让我们开始吧”页面中的单个步骤行。
final class VCStartStepRow: UIView {
    /// 步骤行视图模型。
    private let vm: VCStartStepVM
    /// 是否展示底部连接线。
    private let showsBottomLine: Bool
    /// 序号圆点。
    private let numberView = UIView()
    /// 序号标签。
    private let numberLabel = UILabel()
    /// 已完成步骤勾选图标。
    private let checkImageView = UIImageView()
    /// 连接线。
    private let lineView = UIView()
    /// 步骤标题。
    private let titleLabel = UILabel()
    /// 步骤详情。
    private let detailLabel = UILabel()

    /// 创建步骤行。
    /// - Parameters:
    ///   - vm: 步骤行视图模型。
    ///   - showsBottomLine: 是否展示底部连接线。
    init(vm: VCStartStepVM, showsBottomLine: Bool) {
        self.vm = vm
        self.showsBottomLine = showsBottomLine
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VCStartStepRow {
    /// 初始化步骤行布局。
    func initUI() {
        numberView.backgroundColor = vm.isNumberHighlighted ? .THEME : UIColor.COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.05)
        numberView.layer.cornerRadius = kFitWidth(17)
        lineView.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.05)
        lineView.isHidden = showsBottomLine == false

        numberLabel.text = vm.number
        numberLabel.textAlignment = .center
        numberLabel.isHidden = vm.isCompleted
        numberLabel.textColor = vm.isNumberHighlighted ? .white : .COLOR_TEXT_TITLE_0f1214
        numberLabel.font = .systemFont(ofSize: kFitWidth(14), weight: vm.isActive ? .medium : .regular)

        checkImageView.image = UIImage(named: "guide0820_button_check_icon")?.withRenderingMode(.alwaysTemplate)
        checkImageView.tintColor = .COLOR_TEXT_WHITE
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.isHidden = vm.isCompleted == false

        titleLabel.text = vm.title
        titleLabel.textColor = vm.isNumberHighlighted ? .COLOR_TEXT_TITLE_0f1214 : .COLOR_TEXT_TITLE_0f1214_50
        titleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: vm.isNumberHighlighted ? .medium : .regular)
        titleLabel.guide0820SetLineHeight(kFitWidth(21))

        detailLabel.text = vm.detail
        detailLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        detailLabel.font = .systemFont(ofSize: kFitWidth(12), weight: .regular)
        detailLabel.numberOfLines = 0
        detailLabel.guide0820SetLineHeight(kFitWidth(18))

        addSubview(lineView)
        addSubview(numberView)
        numberView.addSubview(numberLabel)
        numberView.addSubview(checkImageView)
        addSubview(titleLabel)
        addSubview(detailLabel)

        numberView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(vm.isActive ? kFitWidth(21.5) : 0)
            make.width.height.equalTo(kFitWidth(34))
        }

        numberLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(kFitWidth(16))
            make.height.equalTo(kFitWidth(12))
        }

        lineView.snp.makeConstraints { make in
            make.centerX.equalTo(numberView)
            make.top.equalTo(numberView.snp.bottom)
            make.width.equalTo(kFitWidth(2))
            make.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(46))
            make.top.equalToSuperview().offset(vm.isActive ? 0 : kFitWidth(6.5))
            make.width.equalTo(kFitWidth(249))
            make.height.equalTo(kFitWidth(21))
        }

        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.width.equalTo(kFitWidth(249))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(2))
        }
    }
}
