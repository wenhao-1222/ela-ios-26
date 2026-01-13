//
//  HonorDonationEmptyCell.swift
//  lns
//
//  Created by LNS2 on 2026/1/13.
//

class HonorDonationEmptyCell: UICollectionViewCell {
    
    static let identifier = "HonorDonationEmptyCell"
    private let msgDisplaySize = CGSize(width: kFitWidth(42), height: kFitWidth(90))
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle == .dark{
//            msgContainer.layer.borderColor = WHColor_16(colorStr: "D2D3D4").cgColor
        }else{
//            msgContainer.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var emptyImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "donation_empty_icon_2")
        return img
    }()
    lazy var emptyIconView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "donation_empty_icon_1")
        return img
    }()
    lazy var bottomRectImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "donation_cell_bottom")
        return img
    }()
    lazy var titlLab: UILabel = {
        let lab = UILabel()
        lab.text = "待捐赠"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        return lab
    }()
}

extension HonorDonationEmptyCell{
    func initUI() {
        contentView.addSubview(bottomRectImageView)
        contentView.addSubview(emptyImgView)
        contentView.addSubview(emptyIconView)
        contentView.addSubview(titlLab)
        
        setConstrait()
    }
    func setConstrait() {
        bottomRectImageView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(47))
            make.width.equalTo(kFitWidth(90))
            make.height.equalTo(kFitWidth(47.5))
        }
        emptyImgView.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(msgDisplaySize.width)
            make.height.equalTo(msgDisplaySize.height)
        }
        emptyIconView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(emptyImgView)
            make.width.equalTo(kFitWidth(12))
            make.height.equalTo(kFitWidth(20))
        }
        titlLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(bottomRectImageView.snp.bottom).offset(kFitWidth(7))
        }
    }
}
