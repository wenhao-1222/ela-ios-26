//
//  SportCatogaryTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//


class SportCatogaryTableViewCell: FeedBackTableViewCell {
    
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
    lazy var leftLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(2)
        
        return vi
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.lineBreakMode = .byWordWrapping
        lab.numberOfLines = 2
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
}

extension SportCatogaryTableViewCell{
    func updateUI(model:SportCatogaryModel) {
        nameLabel.text = model.name
    }
    func setSelect(isSelect:Bool, animated: Bool = false) {
        let changes = {
            self.bgView.backgroundColor = isSelect ? .COLOR_BG_WHITE : .clear
            self.nameLabel.textColor = isSelect ? .THEME : .COLOR_TEXT_TITLE_0f1214
            self.leftLineView.alpha = isSelect ? 1 : 0
        }

        if isSelect {
            leftLineView.isHidden = false
        }

        guard animated else {
            changes()
            leftLineView.isHidden = !isSelect
            return
        }

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction], animations: changes) { _ in
            self.leftLineView.isHidden = !isSelect
        }
    }
}
extension SportCatogaryTableViewCell{
    func initUI()  {
        contentView.addSubview(bgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(leftLineView)
        
        setConstrait()
//        leftLineView.addClipCorner(corners: [.topRight,.bottomRight], radius: kFitWidth(2))
//        leftLineView.backgroundColor = .THEME
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(84))
        }
        leftLineView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(-2))
            make.left.equalTo(kFitWidth(2))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(6))
            make.height.equalTo(kFitWidth(20))
        }
    }
}
