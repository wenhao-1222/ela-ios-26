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

    lazy var coverView: UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "bottom_cover_img")
        vi.isHidden = true
        return vi
    }()

    lazy var coverTopView: UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "bottom_cover_img")
        vi.transform = CGAffineTransform(scaleX: -1, y: -1)
        vi.isHidden = true
        vi.alpha = 0
        return vi
    }()
}

extension DietPlanCreateEventsVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(tableView)
        addSubview(coverView)
        addSubview(coverTopView)

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
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(24))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(8)))
        }

        coverView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.bottom.equalTo(tableView.snp.bottom)
        }

        coverTopView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.top.equalTo(tableView.snp.top)
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
        selectedIndex = indexPath.row
//        if selectedIndex > 0 {
            selectedBlock?()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                self.coverView.center = CGPoint(x: SCREEN_WIDHT * 0.5, y: self.tableView.frame.maxY - kFitWidth(20))
            }
//        }
        tableView.reloadData()
        QuestinonaireMsgModel.shared.events = "\(indexPath.row + 1)"
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(82)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        coverTopView.isHidden = false
        UIView.animate(withDuration: 0.65) {
            self.coverTopView.alpha = 1
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if scrollView.contentOffset.y <= kFitWidth(40){
                UIView.animate(withDuration: 0.65) {
                    self.coverTopView.alpha = 0
                }
            }else{
                UIView.animate(withDuration: 0.65) {
                    self.coverTopView.alpha = 1
                }
            }
//            coverTopView.isHidden = scrollView.contentOffset.y <= kFitWidth(40)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= kFitWidth(40){
            UIView.animate(withDuration: 0.65) {
                self.coverTopView.alpha = 0
            }
        }else{
            UIView.animate(withDuration: 0.65) {
                self.coverTopView.alpha = 1
            }
        }
//        coverTopView.isHidden = scrollView.contentOffset.y <= kFitWidth(40)
    }
}
