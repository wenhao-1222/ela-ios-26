//
//  DataAddItemImageVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/17.
//

import Foundation
import UIKit

class DataAddItemImageVM: UIView {
    
    let selfHeight = kFitWidth(112)
    
    var imgTapBlock:(()->())?
    var clearImgBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var leftTitleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var imageView : UIImageView = {
        let img = UIImageView()
        img.backgroundColor = WHColor_16(colorStr: "F3F3F3")
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var addImageIcon : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "data_add_icon")
        
        return img
    }()
    lazy var clearImageIcon : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "data_img_clear_icon")
        img.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clearImgAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
}

extension DataAddItemImageVM{
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
        addImageIcon.isHidden = true
        clearImageIcon.isHidden = false
    }
}

extension DataAddItemImageVM{
    func initUI() {
        addSubview(leftTitleLabel)
        addSubview(imageView)
        imageView.addSubview(addImageIcon)
        imageView.addSubview(clearImageIcon)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(kFitWidth(80))
        }
        addImageIcon.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(28))
        }
        clearImageIcon.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(0.5))
            make.bottom.equalToSuperview()
        }
    }
}
