//
//  MainTopGoalVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/10.
//

import Foundation
import UIKit

class MainTopGoalVM: UIView {
    
    let selfHeight = kFitWidth(32)
    var number = 10
    
    var editBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(135), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(4)
        self.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(editActtion))
        self.addGestureRecognizer(tap)
        
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    lazy var themeBgView : UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .THEME//.WIDGET_COLOR_GRAY_BLACK_04
//        vi.clipsToBounds = true
//        vi.layer.cornerRadius = kFitWidth(4)
//        vi.isUserInteractionEnabled = true
//        
//        return vi
//    }()
    lazy var themeBgView : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME//.WIDGET_COLOR_GRAY_BLACK_04
        btn.clipsToBounds = true
        btn.layer.cornerRadius = kFitWidth(4)
        btn.isUserInteractionEnabled = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(editActtion), for: .touchUpInside)

        return btn
    }()
    lazy var leftLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.text = "目标"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = UIFont().DDInFontSemiBold(fontSize: 18)
//        lab.font = UIFont().DDInFontMedium(fontSize: 16)
        lab.text = "-"
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var rightLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.text = "千卡"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
//        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.25)
        vi.backgroundColor = .clear
        
        return vi
    }()
    lazy var editImgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
//        img.setImgLocal(imgName: "main_edit_icon")
//        img.setImgLocal(imgName: "main_pencil_icon")
        
        return img
    }()
//    lazy var editTapView : UIView = {
//        let vi = UIView()
//        vi.isUserInteractionEnabled = true
//        vi.backgroundColor = .clear
//        
////        let tap = UITapGestureRecognizer.init(target: self, action: #selector(editActtion))
////        vi.addGestureRecognizer(tap)
//        
//        return vi
//    }()
}

extension MainTopGoalVM{
    func updateNumber() {
        number = number + WHBaseViewVC().randomInteger(min: 50, max: 100)
        numberLabel.text = "\(number)"
        
        if number < 2400{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.updateNumber()
            })
        }
    }
    func updateContent(targetNum:String,sportNum:String) {
        if sportNum.floatValue > 0 && UserInfoModel.shared.statSportDataToTarget == "1"{
            leftLab.isHidden = true
            themeBgView.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
            rightLab.textColor = .COLOR_GRAY_BLACK_85
            editImgView.setImgLocal(imgName: "main_edit_icon_theme")
//            editImgView.setImgLocal(imgName: "main_pencil_icon")//main_edit_icon_theme
            numberLabel.textColor = .THEME
            numberLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(8))
                make.top.height.equalToSuperview()
                make.right.equalTo(kFitWidth(-69))
            }
            let attr = NSMutableAttributedString(string: "\(Int(targetNum.floatValue.rounded()))")
            let sportAttr = NSMutableAttributedString(string: " +\(Int(sportNum.floatValue.rounded()))")
            sportAttr.yy_color = .COLOR_SPORT
            attr.append(sportAttr)
            numberLabel.attributedText = attr
        }else{
            leftLab.isHidden = false
            themeBgView.backgroundColor = .THEME
            numberLabel.text = "\(targetNum)"
            rightLab.textColor = .white
            numberLabel.textColor = .white
            editImgView.image = UIImage(named: "main_edit_icon")
//            editImgView.image = UIImage(named: "main_pencil_icon")?.WHImageWithTintColor(color: .white)
            numberLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(36))
                make.top.height.equalToSuperview()
                make.right.equalTo(kFitWidth(-69))
            }
        }
    }
    @objc func editActtion() {
        if self.editBlock != nil{
            self.editBlock!()
        }
    }
}

extension MainTopGoalVM{
    func initUI() {
        addSubview(themeBgView)
        themeBgView.addSubview(leftLab)
        themeBgView.addSubview(numberLabel)
        themeBgView.addSubview(rightLab)
        themeBgView.addSubview(lineView)
        themeBgView.addSubview(editImgView)
        
//        themeBgView.addSubview(editTapView)
        setConstrait()
    }
    func setConstrait(){
        themeBgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.height.equalToSuperview()
        }
        leftLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.top.height.equalToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.top.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-69))
        }
        rightLab.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(4))
            make.top.height.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-32))
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualToSuperview()
        }
        editImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-9))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
//        editTapView.snp.makeConstraints { make in
//            make.left.equalTo(lineView)
//            make.top.right.height.equalToSuperview()
//        }
    }
}
