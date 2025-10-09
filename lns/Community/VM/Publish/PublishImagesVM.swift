//
//  PublishImagesVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/6.
//


class PublishImagesVM: UIView {
    
    let selfWidth = kFitWidth(108)
    
    var clearImgBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfWidth))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: selfWidth, height: selfWidth))
        img.contentMode = .scaleAspectFill
        return img
    }()
    lazy var clearImageIcon : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "data_img_clear_icon")
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clearImgAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var coverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_65
        
        return vi
    }()
}

extension PublishImagesVM{
    @objc func clearImgAction(){
        if self.clearImgBlock != nil{
            self.clearImgBlock!()
        }
    }
    func updateUI(img:UIImage) {
        self.imgView.image = img
    }
    func updatePercent(percent:Float) {
        DispatchQueue.main.async {
            self.coverView.snp.remakeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(self.selfWidth*CGFloat(percent))
            }
        }
        
    }
}

extension PublishImagesVM{
    func initUI() {
        addSubview(imgView)
        addSubview(clearImageIcon)
        addSubview(coverView)
        
        setConstrait()
    }
    func setConstrait() {
        clearImageIcon.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }
}
