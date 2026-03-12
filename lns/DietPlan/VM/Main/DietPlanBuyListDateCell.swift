//
//  DietPlanBuyListDateCell.swift
//  lns
//
//  Created by LNS2 on 2026/3/12.
//

class DietPlanBuyListDateCell: UITableViewCell {
    static let reuseId = "DietPlanBuyListDateCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(14)
        view.layer.borderWidth = kFitWidth(1.5)
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(checkImageView)
        
        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-45))
            make.top.equalTo(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-6))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(checkImageView.snp.left).offset(kFitWidth(-10))
        }
        checkImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(30))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(title: String, isSelected: Bool) {
        titleLabel.text = title
//        checkImageView.setCheckState(isSelected,
//                                          checkedImageName: "circle_today_select_icon",
//                                          uncheckedImageName: "circle_today_normal_icon")
        checkImageView.setCheckState(isSelected,
                              checkedImageName: "circle_today_select_icon",
                              uncheckedImageName: "question_foods_normal_icon")
        if isSelected {
            cardView.layer.borderColor = UIColor.THEME.cgColor
        } else {
            cardView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
