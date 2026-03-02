//
//  DietPlanCreateAllergyVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

class DietPlanCreateAllergyVM: UIView {

    var selectedIndex = -1
    var selectedIndexes: Set<Int> = []
    var selectedBlock: (() -> ())?

    private let fullDataArray: [String] = ["无", "花生", "坚果", "乳制品", "豆制品", "海鲜", "猪肉"]
    var dataArray: [String] = ["无", "花生", "坚果", "乳制品", "豆制品", "海鲜", "猪肉"]

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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你是否有过敏或忌口？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
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
        st.spacing = kFitWidth(4)
        return st
    }()
    
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    
    lazy var topGradientLayer: CAGradientLayer = {
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
    
    lazy var bottomGradientLayer: CAGradientLayer = {
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
}

extension DietPlanCreateAllergyVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        setConstraint()
        applyGoalFilter()
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(55))
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)//.offset(kFitWidth(28))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(8)))
        }
        
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }
        
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom)
            make.height.equalTo(kFitWidth(35))
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

    func applyGoalFilter() {
        let oldDataArray = dataArray
        let oldSelectedTitles = selectedIndexes.compactMap { index -> String? in
            guard index >= 0, index < oldDataArray.count else { return nil }
            return oldDataArray[index]
        }

        let shouldExcludePurine = QuestinonaireMsgModel.shared.goal.contains("降低尿酸")
        if shouldExcludePurine {
            dataArray = fullDataArray.filter { $0 != "豆制品" && $0 != "海鲜" }
        } else {
            dataArray = fullDataArray
        }

        var newSelectedIndexes: Set<Int> = []
        for title in oldSelectedTitles {
            if let newIndex = dataArray.firstIndex(of: title) {
                newSelectedIndexes.insert(newIndex)
            }
        }
        selectedIndexes = newSelectedIndexes
        selectedIndex = selectedIndexes.sorted().first ?? -1

        if selectedIndexes.isEmpty {
            QuestinonaireMsgModel.shared.foodAllergy = ""
        } else {
            let selectedTitles = selectedIndexes.sorted().map { dataArray[$0] }
            QuestinonaireMsgModel.shared.foodAllergy = selectedTitles.joined(separator: ",")
        }

        refreshListUI()
        selectedBlock?()
    }

    func selectItem(index: Int) {
        guard index >= 0 && index < dataArray.count else {
            return
        }
        
        let oldSelectedIndexes = selectedIndexes
        
        if index == 0 {
            if selectedIndexes.contains(0) {
                selectedIndexes.remove(0)
            } else {
                selectedIndexes.removeAll()
                selectedIndexes.insert(0)
            }
        } else {
            if selectedIndexes.contains(index) {
                selectedIndexes.remove(index)
            } else {
                selectedIndexes.remove(0)
                selectedIndexes.insert(index)
            }
        }
        
        selectedIndex = selectedIndexes.sorted().first ?? -1
        
        for (i, itemView) in itemViews.enumerated() {
            let oldIsSelected = oldSelectedIndexes.contains(i)
            let newIsSelected = selectedIndexes.contains(i)
            guard oldIsSelected != newIsSelected else {
                continue
            }
            itemView.updateUI(title: dataArray[i], isSelected: newIsSelected)
        }
        
        if selectedIndexes.isEmpty {
            QuestinonaireMsgModel.shared.foodAllergy = ""
        } else {
            let selectedTitles = selectedIndexes.sorted().map { dataArray[$0] }
            QuestinonaireMsgModel.shared.foodAllergy = selectedTitles.joined(separator: ",")
        }
        selectedBlock?()
    }
}
