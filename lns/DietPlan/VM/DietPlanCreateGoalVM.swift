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
    lazy var titleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
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
        
        titleLabel.setLineHeight(
            textString: "你希望通过饮食计划\n达到什么目标？",
            lineHeight: (titleLabel.font.lineHeight) * 1.2
        )
    }
    func setConstrait() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(55))
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
                make.height.equalTo(itemVm.selfHeight)
            }
            itemViews.append(itemVm)
        }
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
        nextButtonEnableChangeBlock?(!selectedGoals.isEmpty)
        selectedGoalBlock?(dataArray[index])
        selectedGoalsBlock?(selectedGoals)
    }
}
