//
//  NaviBackButton.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import UIKit

class NaviBackButton: UIView {
    
    var tapBlock : (()->())?
    var imgName = "back_arrow"
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: imgName)
        img.isUserInteractionEnabled = false
        //back_arrow_highlight
        return img
    }()
}

extension NaviBackButton{
    func initUI() {
        self.addSubview(backImgView)
        backImgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
    }
    func setImgName(imgName:String) {
        self.imgName = imgName
        backImgView.setImgLocal(imgName: imgName)
    }
}


extension NaviBackButton{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.imgName == "" {
            backImgView.setImgLocal(imgName: "back_arrow_highlight")
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.imgName == "" {
            backImgView.setImgLocal(imgName: imgName)
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.imgName == "" {
            backImgView.setImgLocal(imgName: imgName)
        }
    }

   @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
       backImgView.setImgLocal(imgName: imgName)
    }
}
