//
//  BannerCell.swift
//  kxf
//
//  Created by Mac on 2024/3/9.
//

import Foundation
import Kingfisher

class BannerCell: UICollectionViewCell {
    var imgView       :  UIImageView?
    
   override init(frame:CGRect){
        super.init(frame: frame)
        initUI()
//        self.layer.cornerRadius = kFitWidth(10)
//        self.clipsToBounds = true
    }
    var imageUrl: String? {
        didSet {
            guard let imgUrl = URL(string: imageUrl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
            DSImageUploader().dealImgUrlSignForOss(urlStr: imageUrl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) { signUrl in
                guard let resourceUrl = URL(string: signUrl) else{
                    return
                }
                
                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: self.imageUrl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                self.imgView?.kf.setImage(with: resource, placeholder: createImageWithColor(color: .WIDGET_COLOR_GRAY_BLACK_04), options: [.transition(.fade(0.2))])
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func initUI(){
        imgView = UIImageView()
        imgView?.backgroundColor = .clear
        self.addSubview(imgView!)
        imgView?.snp.makeConstraints({ (frame) in
            frame.left.right.width.height.equalToSuperview()
        })
//        imgView?.layer.cornerRadius = kFitWidth(10)
//        imgView?.clipsToBounds = true
        imgView?.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        }
}
