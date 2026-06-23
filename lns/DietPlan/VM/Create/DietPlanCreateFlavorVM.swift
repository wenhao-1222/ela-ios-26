//
//  DietPlanCreateFlavorVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

class DietPlanCreateFlavorVM: UIView {

    var selectedIndex = -1
    var selectedIndexes: Set<Int> = []
    var selectedBlock: (() -> ())?

    lazy var dataArray: [String] = {
        return ["清爽", "咸香", "香辣", "香甜", "不确定"]
    }()

    private var itemViews: [DietPlanCreateItemVM] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你喜欢什么类型的食物？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: kFitWidth(22), weight: .medium)
        return lab
    }()

    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.showsVerticalScrollIndicator = false
        return scro
    }()

    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()
}

extension DietPlanCreateFlavorVM {
    private var uncertainIndex: Int? {
        dataArray.firstIndex(of: "不确定")
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        setConstraint()
        refreshListUI()
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(59))
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(25))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(8)))
        }

        contentView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.top.equalTo(kFitWidth(28))
            make.bottom.equalTo(kFitWidth(-28))
            make.width.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(2))
            make.bottom.equalToSuperview().offset(kFitWidth(-2))
        }
    }

    func refreshListUI() {
        normalizeSelectionState()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()

        for (index, title) in dataArray.enumerated() {
            let itemVm = DietPlanCreateItemVM(frame: .zero)
            itemVm.updateUI(title: title, isSelected: selectedIndexes.contains(index))
            itemVm.tapBlock = { [weak self] in
                self?.selectItem(index: index)
            }
            stackView.addArrangedSubview(itemVm)
            itemVm.snp.makeConstraints { make in
                make.height.equalTo(itemVm.selfHeight)
            }
            itemViews.append(itemVm)
        }
    }

    func selectItem(index: Int) {
        guard index >= 0 && index < dataArray.count else {
            return
        }
        let wasSelected = selectedIndexes.contains(index)

        if let uncertainIndex, index == uncertainIndex {
            selectedIndexes = wasSelected ? [] : [uncertainIndex]
        } else {
            selectedIndexes.remove(uncertainIndex ?? -1)
            if wasSelected {
                selectedIndexes.remove(index)
            } else {
                selectedIndexes.insert(index)
            }
        }

        normalizeSelectionState()
        refreshSelectionUI()
        selectedBlock?()
    }

    private func normalizeSelectionState() {
        if let uncertainIndex,
           selectedIndexes.contains(uncertainIndex),
           selectedIndexes.count > 1 {
            selectedIndexes = [uncertainIndex]
        }
        selectedIndex = selectedIndexes.sorted().first ?? -1
        syncSelectedFlavorText()
    }

    private func refreshSelectionUI() {
        for (index, itemView) in itemViews.enumerated() {
            itemView.updateUI(title: dataArray[index], isSelected: selectedIndexes.contains(index))
        }
    }

    private func syncSelectedFlavorText() {
        if selectedIndexes.isEmpty {
            QuestinonaireMsgModel.shared.foodTasteType = ""
        } else {
            let selectedTitles = selectedIndexes.sorted().map { dataArray[$0] }
            QuestinonaireMsgModel.shared.foodTasteType = selectedTitles.joined(separator: ",")
        }
    }
}
