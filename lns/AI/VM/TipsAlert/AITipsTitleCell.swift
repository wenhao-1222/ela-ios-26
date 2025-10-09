//
//  AITipsTitleCell.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITipsTitleCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
}

extension AITipsTitleCell{
    func initUI() {
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.bottom.equalToSuperview()
        }
    }
}
