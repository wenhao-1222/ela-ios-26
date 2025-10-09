//
//  LogsRemarkNewVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/22.
//


import Foundation
import UIKit

class LogsRemarkNewVM: UIView {
    
    let selfHeight = kFitWidth(98)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(20), height: selfHeight))
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
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: 0, width: SCREEN_WIDHT-kFitWidth(20), height: selfHeight))
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var leftTitleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = "注释"
        
        return lab
    }()
    lazy var dottieBgView: UIView = {
        let vi = UIView()
        vi.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
        vi.layer.borderWidth = kFitWidth(1)
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var penIcon : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_remark_add_icon")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var placeHoldLabel : UILabel = {
        let lab = UILabel()
        lab.text = "这里输入您的注释说明"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        
        return lab
    }()
}

extension LogsRemarkNewVM{
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    func updateContent(text:String) {
        if text.count > 0 {
            self.placeHoldLabel.text = text
            self.placeHoldLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            penIcon.isHidden = true
            placeHoldLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(64))
                make.centerY.lessThanOrEqualToSuperview()
                make.right.equalTo(kFitWidth(-36))
            }
        }else{
            self.placeHoldLabel.text = "这里输入您的注释说明"
            self.placeHoldLabel.textColor = .COLOR_TEXT_TITLE_0f1214_35
            penIcon.isHidden = false
            placeHoldLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(38))
                make.top.equalTo(kFitWidth(54))
                make.right.equalTo(kFitWidth(-38))
    //            make.centerY.lessThanOrEqualToSuperview()
            }
        }
    }
}

extension LogsRemarkNewVM{
    func initUI() {
        addSubview(whiteView)
//        whiteView.addShadow(opacity: 0.08,radius: kFitWidth(12))
        
        whiteView.addSubview(leftTitleLabel)
        whiteView.addSubview(dottieBgView)
        whiteView.addSubview(penIcon)
        whiteView.addSubview(placeHoldLabel)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(12))
//            make.top.height.equalToSuperview()
        }
        penIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(27))
            make.top.equalTo(kFitWidth(59))
//            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(7))
        }
        placeHoldLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(38))
            make.top.equalTo(kFitWidth(54))
            make.right.equalTo(kFitWidth(-38))
//            make.centerY.lessThanOrEqualToSuperview()
        }
        dottieBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(44))
            make.right.equalTo(kFitWidth(-15))
            make.bottom.equalTo(kFitWidth(-16))
        }
    }
}
