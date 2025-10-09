//
//  BodyDataImageAbbreVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/9.
//

import Foundation
import UIKit

class BodyDataImageAbbreVM: UIView {
    
    let selfHeight = WHUtils().getBottomSafeAreaHeight() + kFitWidth(100)
    let imgWidth = kFitWidth(44)
    let imgHeight = kFitWidth(44)
    
    let coverColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
    let selectColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.45)
    
    var imgMsgs = NSArray()
    var aliasArray = NSArray()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85)
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "角度一"
        return lab
    }()
    lazy var imgOne: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(6)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .COLOR_LIGHT_GREY
        
        return img
    }()
    lazy var imgOneCoverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = coverColor
        
        return vi
    }()
    lazy var imgTwo: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(6)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .COLOR_LIGHT_GREY
        
        return img
    }()
    lazy var imgTwoCoverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = coverColor
        
        return vi
    }()
    lazy var imgThree: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(6)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .COLOR_LIGHT_GREY
        
        return img
    }()
    lazy var imgThreeCoverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = coverColor
        
        return vi
    }()
}

extension BodyDataImageAbbreVM{
    func initUI()  {
        addSubview(contentLabel)
        addSubview(imgOne)
        imgOne.addSubview(imgOneCoverView)
        addSubview(imgTwo)
        imgTwo.addSubview(imgTwoCoverView)
        addSubview(imgThree)
        imgThree.addSubview(imgThreeCoverView)
        setConstrait()
    }
    func setConstrait() {
        contentLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(5))
        }
        imgTwo.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(contentLabel.snp.bottom).offset(kFitWidth(8))
            make.width.equalTo(imgWidth)
            make.height.equalTo(imgHeight)
        }
        imgOne.snp.makeConstraints { make in
            make.width.height.top.equalTo(imgTwo)
            make.right.equalTo(imgTwo.snp.left).offset(kFitWidth(-10))
        }
        imgThree.snp.makeConstraints { make in
            make.width.height.top.equalTo(imgTwo)
            make.left.equalTo(imgTwo.snp.right).offset(kFitWidth(10))
        }
        imgOneCoverView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        imgTwoCoverView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        imgThreeCoverView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
    }
    func updateSelectIndex(index:Int) {
        if aliasArray.count > index{
            contentLabel.text = aliasArray[index]as? String ?? ""
        }
        
        imgOneCoverView.backgroundColor = coverColor
        imgTwoCoverView.backgroundColor = coverColor
        imgThreeCoverView.backgroundColor = coverColor
        if index == 0 {
            imgOneCoverView.backgroundColor = selectColor
        }else if index == 1{
            imgTwoCoverView.backgroundColor = selectColor
        }else if index == 2{
            imgThreeCoverView.backgroundColor = selectColor
        }
    }
    func updateUI(imgs:NSArray) {
        self.imgMsgs = imgs
//        imgTwoCoverView.backgroundColor = selectColor
        if self.imgMsgs.count > 0 {
            let imgUrl = imgMsgs[0]as? String ?? ""
            if imgUrl.count > 2 {
                imgOne.setImgUrl(urlString: imgUrl)
            }else{
                imgOne.setImgLocal(imgName: "data_photo_default")
            }
        }
        if self.imgMsgs.count > 1 {
            let imgUrl = imgMsgs[1]as? String ?? ""
            if imgUrl.count > 2 {
                imgTwo.setImgUrl(urlString: imgUrl)
            }else{
                imgTwo.setImgLocal(imgName: "data_photo_default")
            }
        }
        if self.imgMsgs.count > 2 {
            let imgUrl = imgMsgs[2]as? String ?? ""
            if imgUrl.count > 2 {
                imgThree.setImgUrl(urlString: imgUrl)
            }else{
                imgThree.setImgLocal(imgName: "data_photo_default")
            }
        }
    }
}
