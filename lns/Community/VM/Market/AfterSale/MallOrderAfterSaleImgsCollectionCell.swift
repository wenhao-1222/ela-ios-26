//
//  MallOrderAfterSaleImgsCollectionCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/26.
//


class MallOrderAfterSaleImgsCollectionCell: UICollectionViewCell {
    
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
    lazy var clearImageIcon : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "mall_order_img_clear_icon")//mall_order_img_add_icon

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clearImgAction))
        img.addGestureRecognizer(tap)

        return img
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "mall_order_img_add_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var numberLab: UILabel = {
        let lab = UILabel()
        lab.text = "0/3"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        return lab
    }()
    lazy var progressRing: ServiceVideoProgressRing = {
        let ring = ServiceVideoProgressRing()
        ring.isUserInteractionEnabled = false
        ring.displayState = .hidden
        return ring
    }()
}
extension MallOrderAfterSaleImgsCollectionCell{
    @objc func clearImgAction(){
        if self.clearImgBlock != nil{
            self.clearImgBlock!()
        }
    }
    func updateUploadProgress(progress:CGFloat) {
        let clamped = max(0, min(1, progress))
        if progress < 0 {
            progressRing.displayState = .hidden
        }else{
            progressRing.displayState = .uploading(progress: clamped)
        }
    }
}

extension MallOrderAfterSaleImgsCollectionCell{
    func updateNum(hiddenIconImg:Bool,num:Int) {
//        if num == 3 {
//            
//        }else{
//            iconImgView.isHidden = false
//            numberLab.isHidden = false
//        }
        iconImgView.isHidden = hiddenIconImg
        numberLab.isHidden = hiddenIconImg
        numberLab.text = "\(num)/3"
//        imgView.isHidden = num == 0
        clearImageIcon.isHidden = !hiddenIconImg
        if hiddenIconImg == false{
            imgView.image = nil
        }
    }
}

extension MallOrderAfterSaleImgsCollectionCell{
    func initUI() {
        contentView.addSubview(imgView)
        contentView.addSubview(clearImageIcon)
        contentView.addSubview(iconImgView)
        contentView.addSubview(numberLab)
        contentView.addSubview(progressRing)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(4))
            make.width.height.equalTo(selfWidht-kFitWidth(8))
            make.top.equalToSuperview()
        }
        clearImageIcon.snp.makeConstraints { make in
            make.right.top.equalTo(imgView)
            make.width.height.equalTo(kFitWidth(14))
        }
        iconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(30))
            make.top.equalTo(kFitWidth(10))
        }
        numberLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(iconImgView.snp.bottom).offset(kFitWidth(3))
        }
        progressRing.snp.makeConstraints { make in
            make.center.equalTo(imgView)
            make.width.height.equalTo(selfWidht*0.45)
        }
    }
}
