//
//  LogsRemarkVM.swift
//  lns
//  日志 注释
//  Created by LNS2 on 2024/4/22.
//

import Foundation
import UIKit

class LogsRemarkVM: UIView {
    
    let selfHeight = kFitWidth(48)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(16), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: 0, width: SCREEN_WIDHT-kFitWidth(16), height: selfHeight))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var leftTitleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = "注释"
        
        return lab
    }()
    lazy var penIcon : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_pen_icon")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var placeHoldLabel : UILabel = {
        let lab = UILabel()
        lab.text = "这里输入您的注释说明"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        
        return lab
    }()
    lazy var arrowButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "logs_remark_arrow_down"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()
    
}

extension LogsRemarkVM{
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    func updateContent(text:String) {
        if text.count > 0 {
            self.placeHoldLabel.text = text
            self.placeHoldLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.85)
            penIcon.isHidden = true
            placeHoldLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(64))
                make.centerY.lessThanOrEqualToSuperview()
                make.right.equalTo(kFitWidth(-36))
            }
        }else{
            self.placeHoldLabel.text = "这里输入您的注释说明"
            self.placeHoldLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
            penIcon.isHidden = false
            placeHoldLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(84))
                make.centerY.lessThanOrEqualToSuperview()
            }
        }
    }
}

extension LogsRemarkVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addShadow(opacity: 0.08,radius: kFitWidth(12))
        
        whiteView.addSubview(leftTitleLabel)
        whiteView.addSubview(penIcon)
        whiteView.addSubview(placeHoldLabel)
        whiteView.addSubview(arrowButton)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.height.equalToSuperview()
        }
        penIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        placeHoldLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(84))
            make.centerY.lessThanOrEqualToSuperview()
        }
        arrowButton.snp.makeConstraints { make in
            make.top.height.right.equalToSuperview()
            make.width.equalTo(kFitWidth(40))
        }
    }
}
