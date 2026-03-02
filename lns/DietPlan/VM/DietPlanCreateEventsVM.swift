//
//  DietPlanCreateEventsVM.swift
//  lns
//
//  Created by Codex on 2026/2/25.
//


class DietPlanCreateEventsVM: UIView {

    var selectedIndex = -1
    var selectedBlock: (() -> ())?

    lazy var dataArray: [[String: String]] = {
        return [
            ["name": "无活动", "detail": "除少量走路通勤，无体育活动"],
            ["name": "低活跃水平", "detail": "日常走路通勤，偶尔进行有氧/力量活动"],
            ["name": "中低活跃水平", "detail": "每周2-3次力量/有氧训练，或从事体力工作"],
            ["name": "中活跃水平", "detail": "每周4-5次力量/有氧训练"],
            ["name": "高活跃水平", "detail": "每周6-7次力量/有氧训练"],
            ["name": "极高活跃水平", "detail": "每日2次力量/有氧训练"]
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "您的日常活动量是多少？"
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
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        vi.register(QuestionnaireEventsTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionnaireEventsTableViewCell")
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

extension DietPlanCreateEventsVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(tableView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        setConstraint()
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(55))
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)//.offset(kFitWidth(24))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(8)))
        }

        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }

        bottomGradientView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom).offset(kFitWidth(-56))
        }
    }
}

extension DietPlanCreateEventsVM: UITableViewDataSource, UITableViewDelegate {
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
        let isFirstSelect = selectedIndex < 0
        selectedIndex = indexPath.row
        if isFirstSelect {
            selectedBlock?()
        }
        tableView.reloadData()
        QuestinonaireMsgModel.shared.events = "\(indexPath.row + 1)"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(82)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(35)))
        vi.backgroundColor = .clear
        return vi
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(35)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(35)))
        vi.backgroundColor = .clear
        return vi
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return kFitWidth(35)
    }
}
