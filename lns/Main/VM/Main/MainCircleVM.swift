//
//  MainCircleVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/9.
//

import Foundation
import UIKit

class MainCircleVM: UIView {
    
    
    var editBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(180), y: 0, width: kFitWidth(156), height: kFitWidth(156)))
//        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: kFitWidth(156), height: kFitWidth(156)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(editActtion))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var circleImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_circle_bg")
        
        return img
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.text = "-"
        lab.font = UIFont().DDInFontMedium(fontSize: 32)
        lab.adjustsFontSizeToFitWidth = true
        lab.textColor = .THEME
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "剩余摄入 (千卡)"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    
}

extension MainCircleVM{
    @objc func editActtion() {
        if self.editBlock != nil{
            self.editBlock!()
        }
    }
}

extension MainCircleVM{
    func initUI() {
        addSubview(circleImgView)
        addSubview(numberLabel)
        addSubview(tipsLabel)
        
        setConstrait()
    }
    func setConstrait() {
        circleImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(52))
            make.width.equalTo(kFitWidth(82))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(92))
        }
    }
    func setConstraitForLogsShare() {
        numberLabel.font = UIFont().DDInFontMedium(fontSize: 26)
        tipsLabel.font = .systemFont(ofSize: 10, weight: .regular)
        numberLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(-8))
            make.width.equalTo(kFitWidth(70))
        }
        tipsLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(numberLabel.snp.bottom).offset(kFitWidth(2))
        }
    }
}
