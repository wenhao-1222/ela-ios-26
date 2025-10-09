//
//  PublishImageCollectionCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/13.
//


class PublishImageCollectionCell: UICollectionViewCell {
    
    let selfWidht = SCREEN_WIDHT*0.7*0.333
    var clearImgBlock:(()->())?
    
    
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
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        img.layer.cornerRadius = kFitWidth(4)
        
        return img
    }()
//    lazy var clearImageIcon : UIImageView = {
//        let img = UIImageView()
//        img.isUserInteractionEnabled = true
//        img.setImgLocal(imgName: "data_img_clear_icon")
//        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clearImgAction))
//        img.addGestureRecognizer(tap)
//        
//        return img
//    }()
    lazy var snLabel: UILabel = {
        let lab = UILabel()
        lab.layer.cornerRadius = kFitWidth(4)
        lab.backgroundColor = .THEME
        lab.clipsToBounds = true
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
}
extension PublishImageCollectionCell{
    @objc func clearImgAction(){
        if self.clearImgBlock != nil{
            self.clearImgBlock!()
        }
    }
}

extension PublishImageCollectionCell{
    func initUI() {
        contentView.addSubview(imgView)
//        contentView.addSubview(clearImageIcon)
        imgView.addSubview(snLabel)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
//            make.left.top.right.bottom.equalToSuperview()
//            make.left.top.equalTo(kFitWidth(2))
//            make.right.bottom.equalTo(kFitWidth(-2))
            make.left.equalTo(kFitWidth(4))
            make.width.height.equalTo(selfWidht-kFitWidth(8))
            make.top.equalToSuperview()
        }
        snLabel.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalTo(kFitWidth(18))
            make.height.equalTo(kFitWidth(14))
        }
//        clearImageIcon.snp.makeConstraints { make in
//            make.right.top.equalTo(imgView)
//            make.width.height.equalTo(kFitWidth(14))
//        }
    }
}
