//
//  PublishImagesCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/6.
//

import Photos


class PublishImagesCell: UITableViewCell {
    
    let imgWidth = kFitWidth(108)
    
    var addImgBlock:(()->())?
    var heightChangeBlock:(()->())?
    var deleteImgBlock:((Int)->())?
    var loadImgBlock:((UIImage)->())?
    
    var imgVmArray:[PublishImagesVM] = [PublishImagesVM]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var addImgButton : UIButton = {
        let img = UIButton()
        img.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(10), width: imgWidth, height: imgWidth)
        img.setImage(UIImage(named: "service_add_bg"), for: .normal)
        img.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.08)), for: .highlighted)
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return img
    }()
}

extension PublishImagesCell{
    func updateUI(assts:[PHAsset]) {
        for vi in self.contentView.subviews{
            vi.removeFromSuperview()
        }
        
        imgVmArray.removeAll()
        var originX = kFitWidth(16)
        var originY = kFitWidth(10)
        
        // 创建 PHCachingImageManager 实例
        let imageManager = PHCachingImageManager.default()
        
        for i in 0..<assts.count{
            originX = CGFloat(i%3)*(imgWidth+kFitWidth(10))+kFitWidth(16)// + (i%assts.count)*(imgWidth+kFitWidth(10))
            originY = kFitWidth(10) + CGFloat(i/3)*(imgWidth+kFitWidth(10))
            DLLog(message: "UIImageView frame:\(originX)   --   \(originY)")
            let asset = assts[i]
            let imgVm = PublishImagesVM.init(frame: CGRect.init(x: originX, y: originY, width: imgWidth, height: imgWidth))
            contentView.addSubview(imgVm)
            imgVmArray.append(imgVm)
            
            imgVm.clearImgBlock = {()in
                if self.deleteImgBlock != nil{
                    self.deleteImgBlock!(i)
                }
            }
            
            imageManager.requestImage(for: asset, targetSize: CGSize(width: SCREEN_WIDHT, height: SCREEN_HEIGHT), contentMode: .aspectFill, options: nil) { image, info in
                DispatchQueue.main.async {
                    imgVm.imgView.image = image
                    if self.loadImgBlock != nil && image != nil{
                        self.loadImgBlock!(image!)
                    }
                }
            }
            
            if i == assts.count - 1 {
                originX = CGFloat((i+1)%3)*(imgWidth+kFitWidth(10))+kFitWidth(16)// + (i%assts.count)*(imgWidth+kFitWidth(10))
                originY = kFitWidth(10) + CGFloat((i+1)/3)*(imgWidth+kFitWidth(10))
            }
        }
        
        if assts.first?.mediaType != .video{
            if assts.count < 9{
                initUI()
                addImgButton.snp.remakeConstraints { make in
                    make.top.equalTo(originY)
                    make.left.equalTo(originX)
                    make.bottom.equalTo(kFitWidth(-10))
                }
            }else{
                addLine(originY: originY)
            }
            if self.heightChangeBlock != nil{
                self.heightChangeBlock!()
            }
        }
    }
    @objc func addAction() {
        if self.addImgBlock != nil{
            self.addImgBlock!()
        }
    }
}

extension PublishImagesCell{
    func initUI() {
        contentView.addSubview(addImgButton)
        
        addImgButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(10))
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-10))
        }
    }
    func addLine(originY:CGFloat) {
        let vi = UIView()
        vi.backgroundColor = .white
        contentView.addSubview(vi)
        
        vi.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(originY)
        }
    }
}
