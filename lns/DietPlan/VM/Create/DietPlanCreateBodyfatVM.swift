//
//  DietPlanCreateBodyfatVM.swift
//  lns
//
//  Created by Codex on 2026/2/25.
//


class DietPlanCreateBodyfatVM: UIView {

    var selectIndex = -1
    var selectedBlock: (() -> ())?
    var showTipsBlock: (() -> ())?
    var selectStateChangeBlock: ((Bool) -> ())?

    private var itemViews: [QuestionnaireBodyFatItemVM] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true

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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bottomGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        topGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
    }

    lazy var dataArray: [[String: String]] = {
        return [["data":"3%~5%","imgUrl":"body_fat_man_1"],
                ["data":"5%~8%","imgUrl":"body_fat_man_2"],
                ["data":"8%~12%","imgUrl":"body_fat_man_3"],
                ["data":"12%~15%","imgUrl":"body_fat_man_4"],
                ["data":"15%~20%","imgUrl":"body_fat_man_5"],
                ["data":"20%~25%","imgUrl":"body_fat_man_6"],
                ["data":"25%~30%","imgUrl":"body_fat_man_7"],
                ["data":"30%~40%","imgUrl":"body_fat_man_8"],
                ["data":"40%~50%","imgUrl":"body_fat_man_9"]]
    }()

    lazy var dataFemanArray: [[String: String]] = {
        return [["data":"12%~15%","imgUrl":"body_fat_feman_1"],
                ["data":"15%~20%","imgUrl":"body_fat_feman_2"],
                ["data":"20%~25%","imgUrl":"body_fat_feman_3"],
                ["data":"25%~30%","imgUrl":"body_fat_feman_4"],
                ["data":"30%~35%","imgUrl":"body_fat_feman_5"],
                ["data":"35%~40%","imgUrl":"body_fat_feman_6"],
                ["data":"40%~45%","imgUrl":"body_fat_feman_7"],
                ["data":"45%~50%","imgUrl":"body_fat_feman_8"],
                ["data":"50%~60%","imgUrl":"body_fat_feman_9"]]
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你现在的体脂率是？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var tipsButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("体脂率误差：为什么测量值通常偏低？", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.addTarget(self, action: #selector(showTipsAction), for: .touchUpInside)
        return btn
    }()

    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView()
        vi.backgroundColor = .clear
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        return vi
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
}

extension DietPlanCreateBodyfatVM {
    @objc func showTipsAction() {
        showTipsBlock?()
    }

    func restoreSelection(modelValue: String) {
        let normalizedValue = modelValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard QuestinonaireMsgModel.shared.sex == "1" || QuestinonaireMsgModel.shared.sex == "2" else {
            selectIndex = -1
            refreshSelectStatus()
            QuestinonaireMsgModel.shared.bodyFat = ""
            selectStateChangeBlock?(false)
            return
        }
        let array = QuestinonaireMsgModel.shared.sex == "1" ? dataArray : dataFemanArray

        guard let index = array.firstIndex(where: { ($0["data"] ?? "") == normalizedValue }) else {
            selectIndex = -1
            refreshSelectStatus()
            QuestinonaireMsgModel.shared.bodyFat = ""
            selectStateChangeBlock?(false)
            return
        }

        selectIndex = index
        refreshSelectStatus()
        updateBodyFatValue(index: index)
        selectStateChangeBlock?(true)
    }

    func refreshSelectStatus() {
        for (index, itemView) in itemViews.enumerated() {
            itemView.updateUIIsSelected(isSelect: index == selectIndex)
        }
    }
}

extension DietPlanCreateBodyfatVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsButton)
        addSubview(scrollView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)

        setConstraint()
        updateScrollView()
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(55))
        }

        tipsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(8))
            make.height.equalTo(kFitWidth(26))
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(tipsButton.snp.bottom)//.offset(kFitWidth(24))
            make.left.right.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-WHUtils().getBottomSafeAreaHeight())
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
            make.height.equalTo(kFitWidth(35))
//            make.top.equalTo(scrollView.snp.bottom).offset(kFitWidth(-35))
        }
    }

    func updateScrollView() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()
        QuestinonaireMsgModel.shared.bodyFat = ""
        selectIndex = -1
        selectStateChangeBlock?(false)

        let array: [[String: String]]
        if QuestinonaireMsgModel.shared.sex == "1" {
            array = dataArray
        } else if QuestinonaireMsgModel.shared.sex == "2" {
            array = dataFemanArray
        } else {
            scrollView.contentSize = .zero
            scrollView.setContentOffset(.zero, animated: false)
            return
        }
        let colNum = 2
        let itemWidth = SCREEN_WIDHT / CGFloat(colNum)

        var offsetY: CGFloat = 0
        for i in 0..<array.count {
            let row = i / colNum
            let col = i % colNum
            let itemVm = QuestionnaireBodyFatItemVM(frame: CGRect(x: itemWidth * CGFloat(col), y: QuestionnaireBodyFatItemVM().selfHeight * CGFloat(row)+kFitWidth(35), width: 0, height: 0))
            scrollView.addSubview(itemVm)

            let dict = array[i]
            itemVm.updateUI(dict: dict as NSDictionary, isRight: false)
            itemVm.tapBlock = { [weak self] in
                guard let self else { return }
                if self.selectIndex == i {
                    return
                }
                if self.selectIndex == -1 {
                    self.selectedBlock?()
                }
                self.selectIndex = i
                self.refreshSelectStatus()
                self.updateBodyFatValue(index: i)
                self.selectStateChangeBlock?(true)
            }

            itemViews.append(itemVm)
            offsetY = itemVm.frame.maxY
        }

        scrollView.contentSize = CGSize(width: 0, height: offsetY + kFitWidth(35))
        scrollView.setContentOffset(.zero, animated: false)
    }

    func updateBodyFatValue(index: Int) {
        guard QuestinonaireMsgModel.shared.sex == "1" || QuestinonaireMsgModel.shared.sex == "2" else {
            QuestinonaireMsgModel.shared.bodyFat = ""
            return
        }
        let array = QuestinonaireMsgModel.shared.sex == "1" ? dataArray : dataFemanArray
        guard index >= 0 && index < array.count else {
            QuestinonaireMsgModel.shared.bodyFat = ""
            return
        }
        QuestinonaireMsgModel.shared.bodyFat = array[index]["data"] ?? ""
    }

}
