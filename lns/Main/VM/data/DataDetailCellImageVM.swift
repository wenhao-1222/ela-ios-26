//
//  DataDetailCellImageVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/7.
//


import Foundation
import UIKit

class DataDetailCellImageVM: FeedBackView {
    
    let selfHeight = kFitWidth(44)
    var imgMsgs = NSMutableArray()
    var imgUrls = NSMutableArray()
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(55), y: frame.origin.y, width: kFitWidth(55), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DataDetailCellImageVM{
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension DataDetailCellImageVM{
    func initUI() {
        
    }
    func updateUI(imgs:NSArray) {
        for vi in self.subviews{
            vi.removeFromSuperview()
        }
        imgMsgs.removeAllObjects()
        imgUrls.removeAllObjects()
        
        var imgsCount = 0
        
        for i in 0..<imgs.count{
            let dict = imgs[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "url").count > 0 {
                imgsCount = imgsCount + 1
                imgMsgs.add(dict)
                imgUrls.add(dict.stringValueForKey(key: "url"))
            }
        }
        var imgWidth = kFitWidth(24)
        var imgGap = kFitWidth(1)
        var leftGap = kFitWidth(15)
        
        if imgsCount == 2 {
            imgWidth = kFitWidth(23)
            imgGap = kFitWidth(2)
            leftGap = kFitWidth(2.5)
        }else if imgsCount == 3{
            imgWidth = kFitWidth(15)
            imgGap = kFitWidth(2)
            leftGap = kFitWidth(2.5)
        }else if imgsCount == 0 {
            let img = UIImageView()
            img.layer.cornerRadius = kFitWidth(4)
            img.clipsToBounds = true
            img.contentMode = .scaleAspectFit
            img.isUserInteractionEnabled = true
            addSubview(img)
            
            img.setImgLocal(imgName: "data_photo_default")
            
            img.snp.makeConstraints { make in
                make.right.equalTo(kFitWidth(-16))
                make.centerY.lessThanOrEqualToSuperview()
                make.width.equalTo(imgWidth)
                make.height.equalTo(kFitWidth(24))
            }
            return
        }
        
        var imgIndex = 0
        var imgView = UIImageView()
        for i in 0..<imgs.count{
            let dict = imgs[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "url").count > 0 {
                let img = UIImageView()
                img.layer.cornerRadius = kFitWidth(4)
                img.clipsToBounds = true
                img.contentMode = .scaleAspectFit
                img.isUserInteractionEnabled = true
                addSubview(img)
                
                if imgIndex > 0 {
                    self.insertSubview(img, belowSubview: imgView)
                }
                imgView = img
                
                img.setImgUrl(urlString: dict.stringValueForKey(key: "url"))
                let imgOriginX = leftGap + (imgWidth + imgGap) * CGFloat(imgIndex)
                img.snp.makeConstraints { make in
                    make.centerX.lessThanOrEqualToSuperview()
                    make.centerY.lessThanOrEqualToSuperview()
                    make.width.equalTo(kFitWidth(24))
                    make.height.equalTo(kFitWidth(24))
                }
                img.transform = img.transform.rotated(by: CGFloat.pi/18 * CGFloat(imgIndex))
                imgIndex = imgIndex + 1
            }
        }
    }
}
