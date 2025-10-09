//
//  BannerVM.swift
//  kxf
//
//  Created by Mac on 2024/3/9.
//

import Foundation
import CHIPageControl
import Photos
import Kingfisher

class BannerVM: UIView {
    
    var selfHeight = kFitWidth(150)
    
    public var spinChainBlock: ((NSDictionary)->())?
    var remotePathGroup = NSArray()
    var imagesForUpload:[UIImage] = [UIImage]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.height))
        selfHeight = frame.height
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var banner: GXBanner = {
        let frame: CGRect = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(140))
        return GXBanner(frame: frame, margin: kFitWidth(30), minScale: GXBanner.Scale(sx: 0.9, sy: 0.9))
    }()
    
    lazy var pageControlTopbanner: CHIPageControlPuya = {
        let zhView = CHIPageControlPuya()
        zhView.isHidden = true
        zhView.padding = 15.0
        zhView.inactiveTransparency = 1.0
        zhView.hidesForSinglePage = true
        zhView.radius = kFitWidth(5)
        zhView.tintColor = WHColor_RGB(r: 241, g: 181, b: 190 )
        zhView.currentPageTintColor = WHColor_RGB(r: 255, g: 83, b: 107 )
        zhView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        return zhView
    }()
    lazy var bannerImgView : UIImageView = {
        let img = UIImageView()
        img.backgroundColor = WHColor_LineGray()
        img.isHidden = true
//        img.layer.cornerRadius = kFitWidth(8)
//        img.clipsToBounds = true
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(bannerImgTap))
        img.addGestureRecognizer(tap)
        
        return img
    }()
}

extension BannerVM{
    func initUI(){
//        addSubview(pageControlTopbanner)
        self.banner = GXBanner(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight),
                               margin: kFitWidth(5),
                               minScale: GXBanner.Scale(sx: 0.98, sy: 0.98))
        addSubview(self.banner)
        banner.backgroundColor = UIColor.clear
//        banner.autoTimeInterval = 2.0
        banner.isAutoPlay = false
        banner.dataSource = self
        banner.delegate = self
        banner.isShowPageControl = false
        banner.register(classCellType: BannerCell.self)
        
        addSubview(bannerImgView)
        bannerImgView.snp.makeConstraints({ (frame) in
            frame.width.equalTo(kFitWidth(343))
            frame.height.equalTo(kFitWidth(126))
            frame.center.lessThanOrEqualToSuperview()
//            frame.bottom.equalTo(-kFitWidth(10))
        })
    }
    
    func setDataSource(dataSourceArr:NSArray){
        remotePathGroup = dataSourceArr
        
        if dataSourceArr.count > 1{
            bannerImgView.isHidden = true
            banner.isHidden = false
            pageControlTopbanner.isHidden = false
            pageControlTopbanner.numberOfPages = self.remotePathGroup.count
            banner.reloadData()
        }else{
            bannerImgView.isHidden = false
            banner.isHidden = true
            pageControlTopbanner.isHidden = true
//            var imgUrl = URL(string: "")
            if remotePathGroup.count > 0 {
//                imgUrl = URL(string: (remotePathGroup[0] as? String ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                DSImageUploader().dealImgUrlSignForOss(urlStr:(remotePathGroup[0] as? String ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) { signUrl in
                    guard let resourceUrl = URL(string: signUrl) else{
                        return
                    }
                    
                    let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: (self.remotePathGroup[0] as? String ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    self.bannerImgView.kf.setImage(with: resource,options: [.transition(.fade(0.2))]) { [self] result in
                        DLLog(message: "result:\(result)")
                        
                        let imgOriSize = bannerImgView.image?.size
                        var bannerHeightT = SCREEN_WIDHT * (imgOriSize?.height ?? 0)/(imgOriSize?.width ?? 1)
                        if bannerHeightT > SCREEN_WIDHT*1.2{
                            bannerHeightT = SCREEN_WIDHT*1.2
                        }
                        bannerImgView.snp.remakeConstraints({ (frame) in
                            frame.width.equalTo(kFitWidth(343))
                            frame.height.equalTo(bannerHeightT)
                            frame.center.lessThanOrEqualToSuperview()
                            frame.top.bottom.equalToSuperview()
                        })
                    }
                }
            }
        }
    }
    func setDataSourcePreview(dataSourceArr:[UIImage]){
        imagesForUpload = dataSourceArr
        
        if dataSourceArr.count > 1{
            bannerImgView.isHidden = true
            banner.isHidden = false
            pageControlTopbanner.isHidden = false
            pageControlTopbanner.numberOfPages = self.remotePathGroup.count
            banner.reloadData()
        }else{
            bannerImgView.isHidden = false
            banner.isHidden = true
            pageControlTopbanner.isHidden = true
            if imagesForUpload.count > 0 {
                let image = imagesForUpload[0]
                bannerImgView.image = image
                let imgOriSize = image.size
                var bannerHeightT = SCREEN_WIDHT * (imgOriSize.height)/(imgOriSize.width)
                if bannerHeightT > SCREEN_WIDHT*1.2{
                    bannerHeightT = SCREEN_WIDHT*1.2
                }
                bannerImgView.snp.remakeConstraints({ (frame) in
                    frame.width.equalTo(kFitWidth(343))
                    frame.height.equalTo(bannerHeightT)
                    frame.center.lessThanOrEqualToSuperview()
                    frame.top.bottom.equalToSuperview()
                })
            }
        }
    }
}

extension BannerVM: GXBannerDataSource, GXBannerDelegate {
    @objc func bannerImgTap(){
        
    }
    // MARK: - GXBannerDataSource
    func numberOfItems() -> Int {
        if remotePathGroup.count > 0 {
            return remotePathGroup.count
        }else{
            return imagesForUpload.count
        }
    }
    
    // MARK: - GXBannerDelegate

    func banner(_ banner: GXBanner, didSelectItemAt indexPath: IndexPath) {
        NSLog("didSelectItemAt %d", indexPath.row)
    }
    func banner(_ banner: GXBanner, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BannerCell = banner.dequeueReusableCell(for: indexPath)
//        cell.contentView.layer.masksToBounds = true
//        cell.contentView.layer.cornerRadius = 10
//        cell.contentView.backgroundColor = UIColor.clear
        
        if remotePathGroup.count > 0 {
            if indexPath.row > remotePathGroup.count-1 {
                cell.imageUrl = remotePathGroup[remotePathGroup.count-1] as? String ?? ""
                return cell
            }
            
            cell.imageUrl = remotePathGroup[indexPath.row] as? String ?? ""//item["pictureUrl"] as! String
            pageControlTopbanner.progress = Double(indexPath.row)
            
        }else if imagesForUpload.count > 0 {
            if indexPath.row > imagesForUpload.count-1 {
                cell.imgView?.image = imagesForUpload[imagesForUpload.count-1]
                return cell
            }
            cell.imgView?.image = imagesForUpload[indexPath.row]
            pageControlTopbanner.progress = Double(indexPath.row)
        }
        
        return cell
    }

}

