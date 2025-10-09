//
//  MainNutrientItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/10.
//

import Foundation
import UIKit

class MainNutrientItemVM: UIView {
    
    var selfWidth = (SCREEN_WIDHT-kFitWidth(32)-kFitWidth(55))/3//kFitWidth(96)
    
    var progressColor = UIColor()
    private let normalColor = WHColor_16(colorStr: "008858")
    private let overflowColor = WHColor_16(colorStr: "D54941")
    
    var editBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: kFitWidth(80)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(editActtion))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var progressBottomView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_06
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var progressView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var overflowImgView : UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(3)
        img.clipsToBounds = true
        img.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        img.setImgLocal(imgName: "main_nutrient_span_img_2")
        img.contentMode = .scaleAspectFit
    
//        img.setImgLocal(imgName: "main_nutrient_span_img")
        
        img.isHidden = true
        return img
    }()
    lazy var bottomBgView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        return vi
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "0/0g"
        
        return lab
    }()
    lazy var numberTipsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = normalColor
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "剩余0g"
        
        return lab
    }()
}

extension MainNutrientItemVM{
    @objc func editActtion() {
        if self.editBlock != nil{
            self.editBlock!()
        }
    }
    func setNumberMsg(num:String,total:String) {
        let numInt = Int((num as NSString).floatValue)
        let totalInt = Int((total as NSString).floatValue)
        let remainNum = totalInt - numInt
        
//        numberLabel.text = "\(numInt)/\(totalInt)g"
        numberTipsLabel.text = "剩余\(remainNum)g"
        numberTipsLabel.textColor = normalColor
        
//        lab.textColor = .COLOR_GRAY_BLACK_65
//        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        let attr = NSMutableAttributedString(string: "\(numInt)")
        let totalAttrt = NSMutableAttributedString(string: "/\(totalInt)g")
        
        attr.yy_font = .systemFont(ofSize: 12, weight: .medium)
        attr.yy_color = .COLOR_GRAY_BLACK_65
        totalAttrt.yy_font = .systemFont(ofSize: 12, weight: .regular)
        totalAttrt.yy_color = .COLOR_GRAY_BLACK_65
        attr.append(totalAttrt)
        
        numberLabel.attributedText = attr
        
        overflowImgView.isHidden = true
        if remainNum < 0 {
            numberTipsLabel.text = "超出\(numInt - totalInt)g"
            numberTipsLabel.textColor = overflowColor
            overflowImgView.isHidden = false
            
            let fullNum = numInt - totalInt
            
            let fullPercent = Float(fullNum)/Float(totalInt)
            var coverWidth = (1 - fullPercent) * Float(selfWidth)
            if fullPercent >= 1 {
                coverWidth = 0
            }
            overflowImgView.snp.remakeConstraints { make in
                make.top.height.equalToSuperview()
                make.width.equalTo(selfWidth)
                make.left.equalTo(-coverWidth)
            }
        }
        var percent = CGFloat(0)
        if totalInt > 0 {
            percent = CGFloat(numInt)/CGFloat(totalInt)
        }
        let progressWidth = percent * selfWidth
        
        progressView.backgroundColor = progressColor
        progressView.frame = CGRect.init(x: 0, y: 0, width: progressWidth, height: kFitWidth(6))
    }
}
extension MainNutrientItemVM{
    func initUI()  {
        addSubview(titleLabel)
        addSubview(progressBottomView)
        progressBottomView.addSubview(progressView)
        progressBottomView.addSubview(overflowImgView)
        
        addSubview(bottomBgView)
        bottomBgView.addSubview(numberLabel)
        bottomBgView.addSubview(numberTipsLabel)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
        progressBottomView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(22))
            make.height.equalTo(kFitWidth(6))
        }
        overflowImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        bottomBgView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(46))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-8))
        }
        numberTipsLabel.snp.makeConstraints { make in
            make.left.right.equalTo(numberLabel)
            make.top.equalTo(numberLabel.snp.bottom).offset(kFitWidth(6))
//            make.top.equalTo(kFitWidth(26))
        }
    }
    func setConstraitForLogsShare() {
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        titleLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(kFitWidth(4))
        }
        progressBottomView.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(selfWidth)
            make.top.equalTo(kFitWidth(22))
            make.height.equalTo(kFitWidth(6))
        }
        overflowImgView.snp.remakeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(selfWidth)
        }
        bottomBgView.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-2))
            make.height.equalTo(kFitWidth(46))
            make.width.equalTo(selfWidth)
        }
        numberLabel.snp.remakeConstraints { make in
            make.left.top.equalTo(kFitWidth(8))
            make.right.equalTo(kFitWidth(-8))
        }
        numberTipsLabel.snp.remakeConstraints { make in
            make.left.right.equalTo(numberLabel)
            make.top.equalTo(kFitWidth(26))
        }
    }
}
