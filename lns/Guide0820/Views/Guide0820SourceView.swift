//
//  Guide0820SourceView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 允许在来源选项控件上拖动时取消点击并开始滚动。
private final class Guide0820SourceScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
}

/// Guide0820 来源问卷页。
final class Guide0820SourceView: UIView {
    /// 来源问卷视图模型。
    private let vm: Guide0820SourceVM
    /// 完成引导回调。
    private let onFinish: () -> Void
    /// 所有来源选项行。
    private var rows: [Guide0820SourceRow] = []
    /// 页面标题。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = vm.title
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: kFitWidth(24), weight: .medium)
        return label
    }()
    /// 来源列表滚动视图。
    private lazy var scrollView: UIScrollView = {
        let scrollView = Guide0820SourceScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        return scrollView
    }()
    /// 来源选项垂直容器。
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = kFitWidth(12)
        return stackView
    }()
    /// 底部滚动渐变容器。
    private lazy var bottomGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    /// 顶部滚动渐变容器。
    private lazy var topGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    /// 底部滚动渐变图层。
    private lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    /// 顶部滚动渐变图层。
    private lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    /// 页面底部大面积渐隐遮罩。
    private lazy var bottomFadeView = Guide0820SourceBottomFadeView()
    /// 主按钮。
    private lazy var primaryButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: onFinish)

    /// 创建来源问卷页。
    /// - Parameters:
    ///   - vm: 来源问卷视图模型。
    ///   - onFinish: 完成引导回调。
    init(vm: Guide0820SourceVM,
         onFinish: @escaping () -> Void) {
        self.vm = vm
        self.onFinish = onFinish
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 同步渐变图层尺寸。
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
}

// Guide0820SourceView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820SourceView {
    /// 初始化页面布局。
    func initUI() {
        backgroundColor = .COLOR_BG_F2

        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(bottomFadeView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        addSubview(primaryButton)
        scrollView.addSubview(stackView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        vm.items.forEach { item in
            let row = Guide0820SourceRow(item: item, isSelected: vm.selectedItemID == item.id) { [weak self] selectedItem in
                self?.selectItem(selectedItem)
            }
            rows.append(row)
            stackView.addArrangedSubview(row)
            row.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(80))
            }
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(21))
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(kFitWidth(87))
        }

        bottomFadeView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(158))
        }

        primaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview().offset(-max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(26)))
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalTo(primaryButton.snp.top)
        }

        topGradientView.snp.makeConstraints { make in
            make.left.right.top.equalTo(scrollView)
            make.height.equalTo(kFitWidth(36))
        }

        bottomGradientView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(scrollView)
            make.height.equalTo(kFitWidth(56))
        }

        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(scrollView.frameLayoutGuide).inset(kFitWidth(21))
            make.top.equalTo(scrollView.contentLayoutGuide).offset(kFitWidth(36))
            // 给最后一项预留滚动后的底部安全空白，避免被渐变遮罩盖住。
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-kFitWidth(80))
        }
    }

    /// 处理来源选项选择。
    /// - Parameter item: 被点击的来源选项。
    func selectItem(_ item: Guide0820SourceVM.SourceItem) {
        vm.select(item)
        primaryButton.setTitle(vm.buttonTitle, for: .normal)

        rows.forEach { row in
            row.setSelected(row.item.id == vm.selectedItemID, animated: true)
        }
    }
}
