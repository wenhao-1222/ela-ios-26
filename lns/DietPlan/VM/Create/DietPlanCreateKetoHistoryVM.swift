//
//  DietPlanCreateKetoHistoryVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

class DietPlanCreateKetoHistoryVM: UIView {

    var selectedIndex = -1
    var selectedBlock: (() -> ())?

    private let optionTitles = ["没有", "有", "我正在使用"]
    private var itemViews: [UIView] = []
    private var titleLabels: [UILabel] = []

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
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()
}

extension DietPlanCreateKetoHistoryVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(stackView)

//        titleLabel.setLineHeight(
//            textString: "你之前有尝试过\n高蛋白/低碳/生酮饮食吗？",
//            lineHeight: titleLabel.font.lineHeight * 0.8
//        )

        for (index, text) in optionTitles.enumerated() {
            let card = UIView()
            card.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05//WHColor_16(colorStr: "E8E8EA")
            card.layer.cornerRadius = kFitWidth(24)
//            card.layer.borderWidth = kFitWidth(2)
//            card.layer.borderColor = UIColor.clear.cgColor
            card.clipsToBounds = true
            card.tag = index

            let tap = UITapGestureRecognizer(target: self, action: #selector(itemTapAction(_:)))
            card.addGestureRecognizer(tap)

            let lab = UILabel()
            lab.text = text
            lab.textColor = .COLOR_TEXT_TITLE_0f1214
            lab.font = .systemFont(ofSize: 20, weight: .medium)
            lab.textAlignment = .center

            card.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            // 这一页选项高度单独定制，与其他页面不一致
            card.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(60))
            }

            stackView.addArrangedSubview(card)
            itemViews.append(card)
            titleLabels.append(lab)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(41))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(60))
        }
    }

    @objc func itemTapAction(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view else { return }
        select(index: view.tag)
    }

    func select(index: Int) {
        guard index >= 0 && index < optionTitles.count else { return }
        if selectedIndex == index { return }

        let oldIndex = selectedIndex
        selectedIndex = index

        if oldIndex >= 0 {
            itemViews[oldIndex].backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_05
            titleLabels[oldIndex].textColor = .COLOR_TEXT_TITLE_0f1214
        }

        itemViews[index].backgroundColor = UIColor.THEME
        titleLabels[index].textColor = .white//.COLOR_TEXT_TITLE_0f1214

        QuestinonaireMsgModel.shared.dietHistoryType = "\(index)"
        selectedBlock?()
    }
}
