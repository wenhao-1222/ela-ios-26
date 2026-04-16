//
//  AIGuidanceCoachStrictnessVM.swift
//  lns
//
//  Created by Codex on 2026/3/24.
//

import UIKit
import SnapKit

class AIGuidanceCoachStrictnessVM: UIView {

    struct Item {
        let title: String
        let detail: String
        let value: String
    }

    enum GoalKind {
        case gain
        case fatLoss
    }

    var selectedBlock: (() -> ())?
    private(set) var selectedIndex = -1
    private var currentGoalKind: GoalKind = .gain
    private var dataArray: [Item] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true

        initUI()
        refreshContentForCurrentGoal()
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

    var hasSelection: Bool {
        return selectedIndex >= 0
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var subtitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你可以随时调整标准"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    lazy var tableView: UITableView = {
        let vi = UITableView(frame: .zero, style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        vi.register(AIGuidanceCoachStrictnessTableViewCell.classForCoder(), forCellReuseIdentifier: "AIGuidanceCoachStrictnessTableViewCell")
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

extension AIGuidanceCoachStrictnessVM {
    func refreshContentForCurrentGoal() {
        currentGoalKind = goalKindFromModel()
        titleLabel.text = "你希望 AI 教练的\n执行标准有多严格？"
        dataArray = items(for: currentGoalKind)
        refreshSelectionFromModel()
        refreshListUI()
    }

    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType
        if let index = dataArray.firstIndex(where: { $0.value == selectedValue }) {
            selectedIndex = index
        } else {
            selectedIndex = -1
            QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType = ""
        }
    }

    func goalKindFromModel() -> GoalKind {
        switch QuestinonaireMsgModel.shared.goal {
        case "4", "5", "7":
            return .gain
        default:
            return .fatLoss
        }
    }

    func items(for goalKind: GoalKind) -> [Item] {
        switch goalKind {
        case .gain:
            return [
                Item(title: "非常放松",
                     detail: "更看重习惯养成，不追求效率。出现偏差时，我会按你的执行力把方案变得更易坚持，尽量把偏离缩小。",
                     value: "very_relaxed"),
                Item(title: "放松",
                     detail: "增肌效率要求偏低到中等。进度跑偏时会给出解决方案，也可能根据你的习惯与生活节奏适度调整目标。",
                     value: "relaxed"),
                Item(title: "正常",
                     detail: "增肌效率要求中等，允许少量波动。每周只给你 1 个最关键的执行重点，确保稳步进步。",
                     value: "normal"),
                Item(title: "健身爱好者",
                     detail: "增肌效率要求更严格，尽可能避免脂肪堆积。波动会被及时纠正，每周 1 个执行重点，附带少量可选优化点，尽量兼顾效率。",
                     value: "enthusiast"),
                Item(title: "职业运动员",
                     detail: "竞技级标准，在避免脂肪堆积的前提下，最大化增肌效率。我会进行大量复盘与微调，主动挖掘所有可优化点，并按优先级给出执行方案。",
                     value: "athlete")
            ]
        case .fatLoss:
            return [
                Item(title: "非常放松",
                     detail: "更看重习惯养成，不追求减脂效率。出现偏差时，我会按你的执行力把方案变得更易坚持，尽量把偏离缩小。",
                     value: "very_relaxed"),
                Item(title: "放松",
                     detail: "减脂效率要求偏低到中等。进度跑偏时会给出解决方案，也可能根据你的习惯与生活节奏适度调整目标。",
                     value: "relaxed"),
                Item(title: "正常",
                     detail: "减脂效率要求中等，允许少量波动。每周只给你 1 个最关键的执行重点，确保稳步进步。",
                     value: "normal"),
                Item(title: "健身爱好者",
                     detail: "减脂效率要求更严格，追求稳定进步。波动会被及时纠正，每周 1 个执行重点，附带少量可选优化点，尽量兼顾效率。",
                     value: "enthusiast"),
                Item(title: "职业运动员",
                     detail: "竞技级标准，最大化减脂效率和肌肉维持。我会进行大量复盘与微调，主动挖掘所有可优化点，并按优先级给出执行方案。",
                     value: "athlete")
            ]
        }
    }

    func refreshListUI() {
        tableView.reloadData()
    }

    func applySelection(index: Int, notify: Bool) {
        guard index >= 0 && index < dataArray.count else {
            return
        }

        if selectedIndex == index {
            return
        }

        selectedIndex = index
        QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType = dataArray[index].value

        UIView.performWithoutAnimation {
            self.tableView.reloadData()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }

        if notify {
            selectedBlock?()
        }
    }

    func expandedCardHeight(for item: Item) -> CGFloat {
        let detailWidth = SCREEN_WIDHT - kFitWidth(72)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .paragraphStyle: paragraphStyle
        ]
        let detailHeight = ceil((item.detail as NSString).boundingRect(with: CGSize(width: detailWidth, height: .greatestFiniteMagnitude),
                                                                       options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                                       attributes: attributes,
                                                                       context: nil).height)
        let contentHeight = max(kFitWidth(132), max(kFitWidth(68), kFitWidth(56) + detailHeight) + kFitWidth(20))
        return contentHeight
    }

    func expandedRowHeight(for index: Int) -> CGFloat {
        guard index >= 0 && index < dataArray.count else {
            return kFitWidth(72)
        }
        return expandedCardHeight(for: dataArray[index]) + kFitWidth(12)
    }
}

extension AIGuidanceCoachStrictnessVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(tableView)
        
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(35))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
        }

        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(16))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(74)))
        }
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }

        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(tableView)
            make.height.equalTo(kFitWidth(35))
        }
    }
}

extension AIGuidanceCoachStrictnessVM: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AIGuidanceCoachStrictnessTableViewCell", for: indexPath) as? AIGuidanceCoachStrictnessTableViewCell
        let item = dataArray[indexPath.row]
        cell?.update(item: item,
                     isSelected: selectedIndex == indexPath.row,
                     expandedCardHeight: expandedCardHeight(for: item))
        return cell ?? AIGuidanceCoachStrictnessTableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row {
            return expandedRowHeight(for: indexPath.row)
        }
        return kFitWidth(72)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            return
        }
//        applySelection(index: indexPath.row, notify: true)
        selectedIndex = indexPath.row
        QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType = dataArray[indexPath.row].value
        self.tableView.reloadData()
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        
        selectedBlock?()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(35)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(35)))
        vi.backgroundColor = .clear
        
        return vi
    }
}

class AIGuidanceCoachStrictnessTableViewCell: FeedBackTableViewCell {
    private let generator = UIImpactFeedbackGenerator(style: .rigid)
    private var currentSelectedState = false
    private var borderHeightConstraint: Constraint?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        generator.prepare()
        initUI()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            bottomView.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT
        } else if !currentSelectedState {
            bottomView.backgroundColor = .COLOR_BG_BLACK_04
        }
    }

    lazy var bottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_BLACK_04
        vi.clipsToBounds = true
        vi.layer.cornerRadius = kFitWidth(30)
        return vi
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        return lab
    }()

    lazy var borderRectView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(30)
        vi.clipsToBounds = true
        vi.layer.borderWidth = kFitWidth(0.5)
        vi.layer.borderColor = UIColor.THEME.cgColor
        vi.isHidden = true
        return vi
    }()

    lazy var selectedTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        return lab
    }()

    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return lab
    }()

    lazy var selectedImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_goal_selected")
        return img
    }()

    func update(item: AIGuidanceCoachStrictnessVM.Item, isSelected: Bool, expandedCardHeight: CGFloat) {
        currentSelectedState = isSelected
        titleLabel.text = item.title
        selectedTitleLabel.text = item.title
        detailLabel.attributedText = detailAttributedText(item.detail)
        borderHeightConstraint?.update(offset: expandedCardHeight)

        if isSelected {
            bottomView.isHidden = true
            borderRectView.isHidden = false
        } else {
            bottomView.isHidden = false
            borderRectView.isHidden = true
            bottomView.backgroundColor = .COLOR_BG_BLACK_04
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        }
    }

    func detailAttributedText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        return NSAttributedString(string: text, attributes: [
            .font: detailLabel.font as Any,
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
            .paragraphStyle: paragraphStyle
        ])
    }

    func initUI() {
        contentView.addSubview(bottomView)
        bottomView.addSubview(titleLabel)

        contentView.addSubview(borderRectView)
        borderRectView.addSubview(selectedTitleLabel)
        borderRectView.addSubview(detailLabel)
        borderRectView.addSubview(selectedImageView)

        bottomView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT - kFitWidth(32))
            make.height.equalTo(kFitWidth(60))
        }

        titleLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }

        borderRectView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT - kFitWidth(32))
            borderHeightConstraint = make.height.equalTo(kFitWidth(132)).constraint
        }

        selectedTitleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(20))
            make.right.lessThanOrEqualTo(selectedImageView.snp.left).offset(kFitWidth(-12))
        }

        selectedImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-15))
            make.top.equalTo(kFitWidth(15))
            make.width.height.equalTo(kFitWidth(48))
        }

        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(selectedTitleLabel.snp.bottom).offset(kFitWidth(12))
            make.bottom.lessThanOrEqualToSuperview().offset(-kFitWidth(20))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
        }
        generator.impactOccurred()
        generator.prepare()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
