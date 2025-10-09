//
//  LLButton.swift
//  swiftStudy01
//
//  Created by 刘恋 on 2019/6/6.
//  Copyright © 2019 刘恋. All rights reserved.
//

import UIKit

public let LLLUibuttonRatio = 0.7

class LLButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.imageView?.contentMode = .center
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        addSubview(conentLab)
        addSubview(redView)
        
        conentLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-4))
        }
        redView.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-33))
            make.width.height.equalTo(kFitWidth(5))
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(12))
            make.top.equalTo(kFitWidth(3))
        }
    }
    
    lazy var conentLab : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12)
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var redView: UIView = {
        let vi = UIView()//.init(frame: CGRect.init(x: self.frame.width-kFitWidth(30), y: kFitWidth(5), width: kFitWidth(5), height: kFitWidth(5)))
        vi.backgroundColor = .systemRed//.THEME
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()
    
    override var isHighlighted: Bool{
        set{
            
        }
        get {
            return false
        }
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
//        let imageW:CGFloat = contentRect.size.width
//        let imageH:CGFloat = contentRect.size.height * CGFloat(LLLUibuttonRatio)
//        return CGRect(x: 0,y: 5,width: imageW,height: imageH)
        let imgWidth = kFitWidth(30)
        let imgHeight = kFitWidth(30)
        return CGRect(x: (contentRect.size.width-imgWidth)*0.5, y: kFitWidth(2), width: imgWidth, height: imgHeight)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleY:CGFloat = contentRect.size.height * CGFloat(LLLUibuttonRatio)
        let titleW:CGFloat = contentRect.size.width
        let titleH:CGFloat = contentRect.size.height - titleY
//        return CGRect(x: 0,y: titleY,width: titleW,height: titleH)
        
        return CGRect(x: 0, y: contentRect.size.height-kFitWidth(15), width: titleW, height: kFitWidth(15))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
