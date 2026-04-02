//
//  DietPlanCreateGoalVM.swift
//  lns
//  目标。通过饮食计划达到什么？
//  Created by LNS2 on 2026/2/24.
//


class DietPlanCreateGoalVM: UIView {
    
    var selectedIndex = -1
    var selectedIndexes: Set<Int> = []
    var selectedGoalBlock:((String)->())?
    var selectedGoalsBlock:(([String])->())?
    var selectedUserGoalsBlock:(([Int])->())?
    var nextButtonEnableChangeBlock:((Bool)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var dataArray: [String] = {
        return ["增肌",
                "减脂",
                "保持体型",
                "提升力量",
                "提高运动表现",
                "提升整体健康",
                "改善血脂",
                "降低尿酸",
                "养成规律饮食习惯",
                "节省时间",
                "节省外食开销"]
    }()
    lazy var itemViews: [DietPlanCreateItemVM] = {
        return []
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
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
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomGradientLayer.frame = bottomGradientView.bounds
        topGradientLayer.frame = topGradientView.bounds
    }
}

extension DietPlanCreateGoalVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)
        
        setConstrait()
        refreshListUI()
        updateTitleLabel()
    }
    func setConstrait() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe > 0 ? (bottomSafe + kFitWidth(44)) : kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(41))
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(25))
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
            make.bottom.equalTo(scrollView)
//            make.top.equalTo(scrollView.snp.bottom).offset(kFitWidth(-56))
            make.height.equalTo(kFitWidth(35))
//            make.top.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(56)))
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
        stackView.arrangedSubviews.forEach({
            $0.removeFromSuperview()
        })
        itemViews.removeAll()
        
        for (index,title) in dataArray.enumerated() {
            let itemVm = DietPlanCreateItemVM(frame: .zero)
            itemVm.updateUI(title: title, isSelected: selectedIndexes.contains(index))
            itemVm.tapBlock = {[weak self] in
                self?.selectItem(index: index)
            }
            stackView.addArrangedSubview(itemVm)
            itemVm.snp.makeConstraints { make in
//                make.height.equalTo(itemVm.selfHeight)
                make.height.equalTo(kFitWidth(60))
            }
            itemViews.append(itemVm)
        }
    }

    private func updateTitleLabel() {
        let text = "你希望通过饮食计划\n达到什么目标？"
        let targetLineHeight = titleLabel.font.lineHeight * 1.2
        let baselineOffset = (targetLineHeight - titleLabel.font.lineHeight) / 2

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = titleLabel.textAlignment
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.minimumLineHeight = targetLineHeight
        paragraphStyle.maximumLineHeight = targetLineHeight

        titleLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: titleLabel.font as Any,
                .foregroundColor: titleLabel.textColor as Any,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: baselineOffset
            ]
        )
    }
    
    func selectItem(index:Int) {
        guard index >= 0 && index < dataArray.count else {
            return
        }
        let oldSelectedIndexes = selectedIndexes

        if index == 0 || index == 1 || index == 2{
            if selectedIndexes.contains(index) {
                selectedIndexes.remove(index)
            } else {
                selectedIndexes.remove(0)
                selectedIndexes.remove(1)
                selectedIndexes.remove(2)
                selectedIndexes.insert(index)
            }
        } else {
            if selectedIndexes.contains(index) {
                selectedIndexes.remove(index)
            } else {
                selectedIndexes.insert(index)
            }
        }

        selectedIndex = selectedIndexes.sorted().first ?? -1
        for (i,itemView) in itemViews.enumerated() {
            let oldIsSelected = oldSelectedIndexes.contains(i)
            let newIsSelected = selectedIndexes.contains(i)
            guard oldIsSelected != newIsSelected else {
                continue
            }
            itemView.updateUI(title: dataArray[i], isSelected: newIsSelected)
        }

        let selectedGoals = selectedIndexes.sorted().map({ dataArray[$0] })
        let userGoal = buildUserGoal()
        nextButtonEnableChangeBlock?(!selectedGoals.isEmpty)
        selectedGoalBlock?(dataArray[index])
        selectedGoalsBlock?(selectedGoals)
        selectedUserGoalsBlock?(userGoal)
    }

    // 后台 userGoal 枚举映射：
    // 1减脂 2增肌 3保持体型 4提升力量 5提高运动表现 6提升整体健康
    // 7改善血脂 8降低尿酸 9养成规律饮食习惯 10节省时间 11节省外食开销
    func buildUserGoal() -> [Int] {
        return selectedIndexes.sorted().compactMap { mapUserGoalValue(fromSelectedIndex: $0) }
    }

    private func mapUserGoalValue(fromSelectedIndex index: Int) -> Int? {
        guard index >= 0 && index < dataArray.count else {
            return nil
        }
        switch index {
        case 0: return 2 // 增肌
        case 1: return 1 // 减脂
        default: return index + 1
        }
    }
}
