//
//  HonorIconCell.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//

class HonorIconCell: UICollectionViewCell {
    
    static let identifier = "HonorIconCell"
    
    private let bgView = UIView()
    private let iconImageView = UIImageView()
    private let percentLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(iconImageView)
        bgView.addSubview(percentLabel)
        bgView.addSubview(titleLabel)
        bgView.addSubview(dateLabel)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bgView.layer.cornerRadius = kFitWidth(12)
        bgView.clipsToBounds = true
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kFitWidth(8))
            make.centerX.equalToSuperview()
            make.width.height.equalTo(kFitWidth(95))
        }

        percentLabel.snp.makeConstraints { make in
            make.center.equalTo(iconImageView)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(kFitWidth(8))
            make.centerX.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(4))
            make.centerX.equalToSuperview()
        }
        
        percentLabel.font = .boldSystemFont(ofSize: kFitWidth(18))
        percentLabel.textColor = .white
        
        titleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: .medium)
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        
        dateLabel.font = .systemFont(ofSize: kFitWidth(12))
        dateLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
    }
    
    func config(model: HonorIconModel) {
        titleLabel.text = model.title
//        percentLabel.text = model.percentText
        
        if model.isAchieved {
            iconImageView.image = UIImage(named: model.iconName)
            bgView.backgroundColor = .clear
            dateLabel.text = model.dateText
//            dateLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            iconImageView.alpha = 1.0
        } else {
            iconImageView.image = UIImage(named: model.iconName)
            bgView.backgroundColor = .clear
//            dateLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            dateLabel.text = "未获得"
//            iconImageView.alpha = 0.3
        }
    }
}
