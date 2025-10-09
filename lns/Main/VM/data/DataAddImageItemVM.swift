//
//  DataAddImageItemVM.swift
//  lns
//
//  Created by Elavatine on 2024/9/28.
//


class DataAddImageItemVM: UIView {
    
    let selfHeight = kFitWidth(112)
    let selfWidth = kFitWidth(80)
    
    var imgTapBlock:(()->())?
    var clearImgBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView : UIImageView = {
        let img = UIImageView()
        img.backgroundColor = WHColor_16(colorStr: "F3F3F3")
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var addImageIcon : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "data_add_icon")
        
        return img
    }()
    lazy var clearImageIcon : FeedBackUIImageView = {
        let img = FeedBackUIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "data_img_clear_icon")
        img.isHidden = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(clearImgAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        
        return lab
    }()
}

extension DataAddImageItemVM{
    @objc func imgTapAction(){
        if self.imgTapBlock != nil{
            self.imgTapBlock!()
        }
    }
    @objc func clearImgAction(){
        if self.clearImgBlock != nil{
            self.clearImgBlock!()
        }
        imageView.setImgLocal(imgName: "")
        addImageIcon.isHidden = false
        clearImageIcon.isHidden = true
    }
    func updateUI(imgUrl:String) {
        imageView.setImgUrl(urlString: imgUrl)
        if imgUrl.count > 0 {
            addImageIcon.isHidden = true
            clearImageIcon.isHidden = false
        }
    }
    func updateUI(localImg:UIImage) {
        imageView.image = localImg
        addImageIcon.isHidden = true
        clearImageIcon.isHidden = false
    }
}

extension DataAddImageItemVM{
    func initUI() {
        addSubview(imageView)
        imageView.addSubview(addImageIcon)
        imageView.addSubview(clearImageIcon)
        
        addSubview(titleLabel)
        
        setConstrait()
    }
    func setConstrait() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(8))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(68))
        }
        addImageIcon.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(28))
        }
        clearImageIcon.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(kFitWidth(8))
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
}
