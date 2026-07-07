//
//  GuideTotalProCoachStrictnessVM.swift
//  lns
//
//  Created by Codex on 2026/7/7.
//

import UIKit
import SnapKit

class GuideTotalProCoachStrictnessVM: UIView {

    struct Item {
        let title: String
        let detail: String
        let value: String
    }

    enum GoalKind {
        case gain
        case fatLoss
    }

    var selectedBlock: (() -> Void)?
    var nextBlock: (() -> Void)?
    private(set) var selectedIndex = -1
    private var currentGoalKind: GoalKind = .gain
    private var dataArray: [Item] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F5
        isUserInteractionEnabled = true
        clipsToBounds = true

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
            UIColor.COLOR_BG_F5.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F5.withAlphaComponent(1).cgColor
        ]
        topGradientLayer.colors = [
            UIColor.COLOR_BG_F5.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F5.withAlphaComponent(0).cgColor
        ]
    }

    var hasSelection: Bool {
        selectedIndex >= 0
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
        lab.text = "你后续可随时调整"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.register(GuideTotalProCoachStrictnessTableViewCell.classForCoder(), forCellReuseIdentifier: "GuideTotalProCoachStrictnessTableViewCell")
        return view
    }()

    lazy var bottomGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    lazy var topGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [
            UIColor.COLOR_BG_F5.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F5.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()

    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [
            UIColor.COLOR_BG_F5.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F5.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()

    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
//        btn.setTitle("开启 AI 教练", for: .disabled)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return btn
    }()
}

extension GuideTotalProCoachStrictnessVM {
    func refreshContentForCurrentGoal() {
        currentGoalKind = goalKindFromModel()
        titleLabel.text = "你希望 AI 教练\n按照什么标准要求你"
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
        nextButton.isEnabled = hasSelection
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
                Item(title: "非常轻松",
                     detail: "更看重大方向和习惯养成，不追求增肌速率。偏离进度时，我会按你的执行力把方案变得更易坚持，尽量把偏离缩小。",
                     value: "very_relaxed"),
                Item(title: "轻松",
                     detail: "增肌效率要求偏低到中等。进度跑偏时，我会给出解决方案，也可能根据你的习惯与生活节奏适度调整目标。",
                     value: "relaxed"),
                Item(title: "正常",
                     detail: "增肌效率要求中等，兼顾生活平衡。允许少量的进度波动，不强求完美执行，用较小的精力投入确保稳步增肌。",
                     value: "normal"),
                Item(title: "健身爱好者",
                     detail: "增肌效率要求更严格，尽可能避免脂肪堆积。进度波动会被及时纠正，每周我会为你找出可选的优化点，进一步最大化你的增肌收益。",
                     value: "enthusiast"),
                Item(title: "职业运动员",
                     detail: "竞技级标准，在避免脂肪堆积的前提下，最大化增肌效率。我会进行大量复盘与微调，主动挖掘所有可优化点，并按优先级给出执行方案。",
                     value: "athlete")
            ]
        case .fatLoss:
            return [
                Item(title: "非常轻松",
                     detail: "更看重习惯养成，不太追求减脂效率。偏离进度时，我会按你的执行力把方案变得更易坚持，尽量把偏离缩小。",
                     value: "very_relaxed"),
                Item(title: "轻松",
                     detail: "减脂效率要求偏低到中等。进度跑偏时，我会给出解决方案，也可能根据你的习惯与生活节奏适度调整目标。",
                     value: "relaxed"),
                Item(title: "正常",
                     detail: "减脂效率要求中等，兼顾生活平衡。允许少量的进度波动，不强求完美执行，用较小的精力投入确保稳步减脂。",
                     value: "normal"),
                Item(title: "健身爱好者",
                     detail: "减脂效率要求更严格，尽可能避免肌肉流失。进度波动会被及时纠正，每周我会为你找出可选的优化点，进一步最大化你的减脂进度。",
                     value: "enthusiast"),
                Item(title: "职业运动员",
                     detail: "竞技级标准，最大化减脂效率和肌肉维持。我会进行大量复盘与微调，主动挖掘所有可优化点，并按优先级给出执行方案。",
                     value: "athlete")
            ]
        }
    }

    func refreshListUI() {
        tableView.reloadData()
        nextButton.isEnabled = hasSelection
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
        return max(kFitWidth(132), max(kFitWidth(68), kFitWidth(56) + detailHeight) + kFitWidth(20))
    }

    func expandedRowHeight(for index: Int) -> CGFloat {
        guard index >= 0 && index < dataArray.count else {
            return kFitWidth(72)
        }
        return expandedCardHeight(for: dataArray[index]) + kFitWidth(12)
    }

    @objc private func nextButtonAction() {
        guard hasSelection else { return }
        nextBlock?()
    }
}

extension GuideTotalProCoachStrictnessVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(tableView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        addSubview(nextButton)

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

        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }

        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(16))
            make.bottom.equalTo(nextButton.snp.top).offset(kFitWidth(-18))
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

extension GuideTotalProCoachStrictnessVM {
    func prepareEntranceAnimation() {
        tableView.setContentOffset(.zero, animated: false)
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        tableView.alpha = 0
        topGradientView.alpha = 0
        bottomGradientView.alpha = 0
        nextButton.alpha = 0
    }

    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.55, delay: 0, options: .curveLinear) {
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.55, delay: 0.1, options: .curveLinear) {
                self.tableView.alpha = 1
                self.topGradientView.alpha = 1
                self.bottomGradientView.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
}

extension GuideTotalProCoachStrictnessVM: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuideTotalProCoachStrictnessTableViewCell", for: indexPath) as? GuideTotalProCoachStrictnessTableViewCell
        let item = dataArray[indexPath.row]
        cell?.update(item: item,
                     isSelected: selectedIndex == indexPath.row,
                     expandedCardHeight: expandedCardHeight(for: item))
        return cell ?? GuideTotalProCoachStrictnessTableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row {
            return expandedRowHeight(for: indexPath.row)
        }
        return kFitWidth(72)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectedIndex != indexPath.row else { return }

        selectedIndex = indexPath.row
        QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType = dataArray[indexPath.row].value
        nextButton.isEnabled = true

        tableView.reloadData()
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.endUpdates()

        selectedBlock?()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        kFitWidth(35)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(35)))
        view.backgroundColor = .clear
        return view
    }
}

class GuideTotalProCoachStrictnessTableViewCell: FeedBackTableViewCell {
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
        let view = UIView()
        view.backgroundColor = .COLOR_BG_BLACK_04
        view.clipsToBounds = true
        view.layer.cornerRadius = kFitWidth(30)
        return view
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        return lab
    }()

    lazy var borderRectView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_BG_WHITE
        view.layer.cornerRadius = kFitWidth(30)
        view.clipsToBounds = true
        view.layer.borderWidth = kFitWidth(0.5)
        view.layer.borderColor = UIColor.THEME.cgColor
        view.isHidden = true
        return view
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

    func update(item: GuideTotalProCoachStrictnessVM.Item, isSelected: Bool, expandedCardHeight: CGFloat) {
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
            make.right.equalTo(kFitWidth(-20))
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
