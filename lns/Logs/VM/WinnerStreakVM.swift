//
//  WinnerStreakVM.swift
//  lns
//  
//  Created by LNS2 on 2024/8/2.
//

import Foundation
import UIKit

class WinnerStreakVM: UIView {
    
    let selfHeight = kFitWidth(18)
    
    var currentIndex = 0
    var goalsDataArray = NSMutableArray()
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT - kFitWidth(16) - selfHeight*2 - kFitWidth(17), y: frame.origin.y, width: selfHeight*2.5, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var numerLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "FF9500")
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .left
        lab.adjustsFontSizeToFitWidth = true
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
}

extension WinnerStreakVM{
    func updateUI(dict:NSDictionary) {
        if dict.stringValueForKey(key: "protection_period") == "0"{
            iconImgView.setImgLocal(imgName: "streak_icon_\(dict.doubleValueForKey(key: "level") - 1)")
            numerLabel.textColor = WHColor_16(colorStr: "FF9500")
        }else{
            iconImgView.setImgLocal(imgName: "streak_icon_gray_\(dict.doubleValueForKey(key: "level") - 1)")
            numerLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        }
        numerLabel.text = dict.stringValueForKey(key: "streak")
        
        if dict.doubleValueForKey(key: "level") < 2 || dict.doubleValueForKey(key: "streak") == 0{
            self.isHidden = true
        }else{
            self.isHidden = false
        }
    }
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension WinnerStreakVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(numerLabel)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
//            make.top.equalTo(kFitWidth(14))
            make.width.height.equalTo(kFitWidth(18))
            make.left.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
        }
        numerLabel.snp.makeConstraints { make in
//            make.top.equalTo(iconImgView.snp.bottom)
            make.right.equalTo(kFitWidth(0))
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(2))
            make.centerY.lessThanOrEqualToSuperview()
//            make.left.width.equalToSuperview()
        }
    }
}
