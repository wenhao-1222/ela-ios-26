//
//  EmptyViewWithBtn.swift
//  ttjx
//
//  Created by 文 on 2019/12/10.
//  Copyright © 2019 ttjx. All rights reserved.
//

import Foundation
import UIKit

class EmptyViewWithBtn: UIView {
    
    var bottomView = UIView()
    var emptyImgView = UIImageView()
    var contentLabel = UILabel()
    
    public var buyBlock: (()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(256), height: kFitWidth(310)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmptyViewWithBtn{
    func initUI(){
        self.addSubview(bottomView)
        bottomView.layer.cornerRadius = kFitWidth(10)
        bottomView.clipsToBounds = true
        bottomView.isUserInteractionEnabled = true
        bottomView.backgroundColor = .clear
        bottomView.snp.makeConstraints { (frame) in
            frame.width.height.left.top.equalToSuperview()
        }
        
        bottomView.addSubview(emptyImgView)
        emptyImgView.image = UIImage.init(named: "list_empty_img")
        emptyImgView.snp.makeConstraints { (frame) in
            frame.center.lessThanOrEqualToSuperview()
            frame.width.height.equalTo(kFitWidth(188))
        }
        
        bottomView.addSubview(contentLabel)
        contentLabel.textColor = WHColor_16(colorStr: "9D9D9D")
        contentLabel.font = .systemFont(ofSize: 15, weight: .regular)
        contentLabel.snp.makeConstraints { (frame) in
            frame.top.equalTo(emptyImgView.snp_bottom).offset(kFitWidth(10))
            frame.centerX.lessThanOrEqualToSuperview()
        }
        
    }
    
    @objc func gotoBuy(){
        if buyBlock != nil {
            buyBlock!()
        }
    }
}
