//
//  FoodsDetailCaloriItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/23.
//

import Foundation
import UIKit

class FoodsDetailCaloriItemVM: UIView {
    override init(frame:CGRect){
//        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(60), height: kFitWidth(114)))
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(60), height: kFitWidth(96)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView : UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        lab.isHidden = true
        
        return lab
    }()
    lazy var percentLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.85)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    
}

extension FoodsDetailCaloriItemVM{
    func initUI() {
        addSubview(imgView)
        addSubview(titleLabel)
        addSubview(numberLabel)
        addSubview(percentLabel)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(48))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(8))
        }
        percentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
//            make.top.equalTo(kFitWidth(82))
            make.top.equalTo(percentLabel.snp.bottom).offset(kFitWidth(5))
        }
    }
    func refresConstrait() {
        numberLabel.snp.remakeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(82))
//            make.top.equalTo(percentLabel.snp.bottom).offset(kFitWidth(5))
        }
        percentLabel.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.top.equalTo(numberLabel.snp.bottom).offset(kFitWidth(5))
        }
        
    }
}

