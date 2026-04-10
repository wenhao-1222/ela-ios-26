//
//  DietPlanCreateMealStyleVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

class DietPlanCreateMealStyleVM: UIView {

    var selectedIndex = -1
    var selectedBlock: (() -> ())?

    lazy var dataArray: [[String: String]] = {
        return [
            ["name": "一日三餐", "detail": "更省时间，每餐更有饱腹感，但两餐之间可能更容易饿"],
            ["name": "少吃多餐", "detail": "利于血糖平稳，更容易稳住食欲"]
        ]
    }()

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
        lab.text = "你更喜欢哪种进餐方式？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var tableView: UITableView = {
        let vi = UITableView(frame: .zero, style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.backgroundColor = .clear
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.bounces = false
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        vi.register(QuestionnaireEventsTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionnaireEventsTableViewCell")
        return vi
    }()
}

extension DietPlanCreateMealStyleVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(tableView)
        
        setConstraint()
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(59))
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(60))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(8)))
        }
    }
}

extension DietPlanCreateMealStyleVM: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireEventsTableViewCell", for: indexPath) as? QuestionnaireEventsTableViewCell
        let dict = dataArray[indexPath.row] as NSDictionary
        cell?.updateUI(dict: dict, isSelected: selectedIndex == indexPath.row)
        return cell ?? QuestionnaireEventsTableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            return
        }
        selectedIndex = indexPath.row
        selectedBlock?()
        tableView.reloadData()
        QuestinonaireMsgModel.shared.events = "\(indexPath.row + 1)"
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(82)
    }
}
