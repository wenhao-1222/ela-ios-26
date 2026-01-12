//
//  HonorDonationCell.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//


class HonorDonationCell: UICollectionViewCell {
    
    static let identifier = "HonorDonationCell"
    
    private let bgView = UIView()
    private let bottomRectImageView = UIImageView()
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
    
    lazy var msgVm: HonorDonationMsgVM = {
        let vm = HonorDonationMsgVM(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(42), height: kFitWidth(90)))
        return vm
    }()
    
    private func setupUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(bottomRectImageView)
        bgView.addSubview(msgVm)
        bgView.addSubview(percentLabel)
        bgView.addSubview(titleLabel)
        bgView.addSubview(dateLabel)
        
        bottomRectImageView.setImgLocal(imgName: "donation_cell_bottom")
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomRectImageView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(47))
            make.width.equalTo(kFitWidth(90))
            make.height.equalTo(kFitWidth(47.5))
        }
        percentLabel.snp.makeConstraints { make in
            make.center.equalTo(msgVm)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(msgVm.snp.bottom).offset(kFitWidth(8))
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
    
    func config(dict:NSDictionary) {
        titleLabel.text = "2026.01.12"//model.title
        msgVm.updateUI(dict: dict)
        
        
        msgVm.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(kFitWidth(42))
            make.height.equalTo(kFitWidth(90))
        }
    }
}
