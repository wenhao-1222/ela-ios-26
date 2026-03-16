//
//  DietPlanCreatePaceSecondVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/16.
//



class DietPlanCreatePaceSecondVM: UIView {

    var selectedIndex = -1
    var selectedBlock: (() -> ())?

    lazy var dataArray: [[String: String]] = {
        return [
            ["name": "循序渐进", "detail": "我希望尽量少改饮食习惯，也能慢慢看到进展"],
            ["name": "稳步推进", "detail": "我愿意在合理范围内做出改变，并长期稳定坚持"],
            ["name": "快速达成", "detail": "我愿意做出更明显的调整，希望更快看到进展"]
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
        lab.text = "你想以什么节奏推进目标？"
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

extension DietPlanCreatePaceSecondVM {
    func restoreSelection(modelValue: String) {
        let normalizedValue = modelValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let targetIndex: Int
        switch normalizedValue {
        case "1", "slight":
            targetIndex = 0
        case "3", "major":
            targetIndex = 2
        default:
            targetIndex = 1
        }
        applySelection(index: targetIndex, notify: false)
    }

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
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(80))
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

    func applySelection(index: Int, notify: Bool) {
        guard index >= 0 && index < dataArray.count else {
            return
        }
        if selectedIndex == index && notify {
            return
        }
        selectedIndex = index
        QuestinonaireMsgModel.shared.paceLevel = "\(index + 1)"

        if notify {
            selectedBlock?()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                self.coverView.center = CGPoint(x: SCREEN_WIDHT * 0.5, y: self.tableView.frame.maxY - kFitWidth(20))
            }
        }
        tableView.reloadData()
    }
}

extension DietPlanCreatePaceSecondVM: UITableViewDataSource, UITableViewDelegate {
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
        applySelection(index: indexPath.row, notify: true)
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
