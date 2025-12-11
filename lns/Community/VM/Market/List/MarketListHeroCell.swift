//
//  MarketListHeroCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/5.
//


class MarketListHeroCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        img.backgroundColor = .COLOR_BG_F2
        
        return img
    }()
}

extension MarketListHeroCell{
    func updateUI(model:MarketListModel) {
        imgView.setImgUrl(urlString: model.imgUrlForListShow)
    }
}

extension MarketListHeroCell{
    func initUI() {
        contentView.addSubview(imgView)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(11))
            make.top.equalTo(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(-20))
            make.right.equalToSuperview()
        }
    }
}
