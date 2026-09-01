//
//  Guide0820PrivacyView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820 隐私确认页。
final class Guide0820PrivacyView: UIView {
    /// 隐私页视图模型。
    private let vm: Guide0820PrivacyVM
    /// 打开协议回调。
    private let onOpenAgreement: (Guide0820AgreementType) -> Void
    /// 下一步回调。
    private let onNext: () -> Void
    /// 标题组视图。
    private lazy var titleGroupView = makeTitleGroupView()
    /// 协议卡片视图。
    private lazy var agreementCardView = makeAgreementCardView()
    /// 协议说明文本。
    private lazy var legalTextView = Guide0820AgreementLegalTextView(onOpenAgreement: onOpenAgreement)
    /// 主按钮。
    private lazy var primaryButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: onNext)

    /// 创建隐私确认页。
    /// - Parameters:
    ///   - vm: 隐私页视图模型。
    ///   - onOpenAgreement: 打开协议回调。
    ///   - onNext: 下一步回调。
    init(vm: Guide0820PrivacyVM,
         onOpenAgreement: @escaping (Guide0820AgreementType) -> Void,
         onNext: @escaping () -> Void) {
        self.vm = vm
        self.onOpenAgreement = onOpenAgreement
        self.onNext = onNext
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Guide0820PrivacyView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820PrivacyView {
    /// 初始化页面布局。
    func initUI() {
        backgroundColor = .COLOR_BG_F2

        addSubview(titleGroupView)
        addSubview(agreementCardView)
        addSubview(legalTextView)
        addSubview(primaryButton)

        titleGroupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(kFitWidth(143.75) - SCREEN_HEIGHT / 2)
            make.width.equalTo(kFitWidth(333))
        }

        agreementCardView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(kFitWidth(284) - SCREEN_HEIGHT / 2)
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(120))
        }

        primaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        legalTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(primaryButton.snp.top).offset(-kFitWidth(14))
            make.width.equalTo(kFitWidth(291))
            make.height.equalTo(kFitWidth(18))
        }
    }

    /// 创建标题组视图。
    /// - Returns: 标题组容器。
    func makeTitleGroupView() -> UIView {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = vm.title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(24), weight: .medium)

        let subtitleLabel = UILabel()
        subtitleLabel.text = vm.subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        subtitleLabel.font = .systemFont(ofSize: kFitWidth(13), weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.guide0820SetLineSpacing(kFitWidth(4.1))

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(36))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(7))
            make.height.equalTo(kFitWidth(44.2))
            make.bottom.equalToSuperview()
        }

        return container
    }

    /// 创建协议卡片。
    /// - Returns: 协议卡片容器。
    func makeAgreementCardView() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .COLOR_CARD_BG_WHITE
        cardView.layer.cornerRadius = kFitWidth(12)
        cardView.clipsToBounds = true

        var previousRow: UIView?
        for (index, item) in vm.agreements.enumerated() {
            let row = Guide0820AgreementRow(item: item) { [weak self] in
                self?.onOpenAgreement(item.id)
            }
            cardView.addSubview(row)
            row.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(kFitWidth(60))
                if let previousRow = previousRow {
                    make.top.equalTo(previousRow.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                if index == vm.agreements.count - 1 {
                    make.bottom.equalToSuperview()
                }
            }

            if index != vm.agreements.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
                cardView.addSubview(separator)
                separator.snp.makeConstraints { make in
                    make.left.equalTo(kFitWidth(42.5))
                    make.right.equalTo(kFitWidth(-16))
                    make.top.equalTo(row.snp.bottom)
                    make.height.equalTo(0.5)
                }
            }

            previousRow = row
        }

        return cardView
    }
}
