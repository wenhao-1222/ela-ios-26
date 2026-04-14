//
//  MineElaProSectionBlockView.swift
//  lns
//
//  Created by LNS2 on 2026/4/14.
//

class MineElaProSectionBlockView: UIView {
    let title: String
    let features: [MineElaProFeature]
    
    init(title: String, features: [MineElaProFeature]) {
        self.title = title
        self.features = features
        super.init(frame: .zero)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = title
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        lab.numberOfLines = 0
        return lab
    }()
    
    private lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(20)
        vi.clipsToBounds = true
        return vi
    }()
    
    private lazy var stackView: UIStackView = {
        let vi = UIStackView()
        vi.axis = .vertical
        vi.spacing = 0
        vi.alignment = .fill
        vi.distribution = .fill
        return vi
    }()
}

private extension MineElaProSectionBlockView {
    func initUI() {
        addSubview(titleLabel)
        addSubview(cardView)
        cardView.addSubview(stackView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        cardView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
            make.left.right.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for (index, feature) in features.enumerated() {
            let rowView = MineElaProFeatureRowView(feature: feature, showsDivider: index != features.count - 1)
            stackView.addArrangedSubview(rowView)
        }
    }
}
