//
//  HonorDonationCell.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//


class HonorDonationCell: UICollectionViewCell {
    
    static let identifier = "HonorDonationCell"
    
    private let msgBaseSize = CGSize(width: kFitWidth(375), height: kFitWidth(812))
    private let msgDisplaySize = CGSize(width: kFitWidth(42), height: kFitWidth(90))
    private let msgContainer = UIView()
    
    private let bgView = UIView()
    private let bottomRectImageView = UIImageView()
    private let percentLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle == .dark{
            msgContainer.layer.borderColor = WHColor_16(colorStr: "D2D3D4").cgColor
        }else{
            msgContainer.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var msgVm: HonorDonationMsgVM = {
        let vm = HonorDonationMsgVM(frame: CGRect(origin: .zero, size: msgBaseSize))
        
        return vm
    }()
    
    private func setupUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(bottomRectImageView)
        bgView.addSubview(msgContainer)
        msgContainer.addSubview(msgVm)
        bgView.addSubview(percentLabel)
        bgView.addSubview(titleLabel)
        bgView.addSubview(dateLabel)
        
        msgContainer.layer.cornerRadius = kFitWidth(4)
        msgContainer.clipsToBounds = true
        msgContainer.layer.borderWidth = kFitWidth(1)
        if traitCollection.userInterfaceStyle == .dark{
            msgContainer.layer.borderColor = WHColor_16(colorStr: "D2D3D4").cgColor
        }else{
            msgContainer.layer.borderColor = UIColor.black.cgColor
        }
        
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
//            make.center.equalTo(msgVm)
            make.center.equalTo(msgContainer)
        }

        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(msgVm.snp.bottom).offset(kFitWidth(8))
            make.top.equalTo(msgContainer.snp.bottom).offset(kFitWidth(8))
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
        titleLabel.text = dict.stringValueForKey(key: "ctime")
        dateLabel.text = "捐赠 \(dict.stringValueForKey(key: "qty")) 餐"
        msgVm.updateUI(dict: dict)
        
        msgContainer.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(msgDisplaySize.width)
            make.height.equalTo(msgDisplaySize.height)
        }
        msgVm.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(msgBaseSize.width)
            make.height.equalTo(msgBaseSize.height)
        }
        
        let scale = min(
            msgDisplaySize.width / msgBaseSize.width,
            msgDisplaySize.height / msgBaseSize.height
        )
        msgVm.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    func msgContainerFrame(in view: UIView) -> CGRect {
        return msgContainer.convert(msgContainer.bounds, to: view)
    }

    func msgContainerSnapshot() -> UIView? {
        return msgContainer.snapshotView(afterScreenUpdates: false)
    }
}
