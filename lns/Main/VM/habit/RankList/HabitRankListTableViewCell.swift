//
//  HabitRankListTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//


class HabitRankListTableViewCell: FeedBackTableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var degreeImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_ranklist_one")
        
        return img
    }()
    lazy var degreeLabel: UILabel = {
        let lab = UILabel()
        lab.font = UIFont().DDInFontMedium(fontSize: 20)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.isHidden = true
        
        return lab
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(22.5)
        img.clipsToBounds = true
        img.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor
        img.layer.borderWidth = kFitWidth(1)
//        img.backgroundColor =
        return img
    }()
    
    private lazy var nameStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            nameLabel,
            fireIcon,
            fireLabel
        ])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let fireIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "flame.fill")
        iv.tintColor = .systemOrange
        return iv
    }()

    private let fireLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .right
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return label
    }()
}

extension HabitRankListTableViewCell{
    func initUI() {
        
    }
}
