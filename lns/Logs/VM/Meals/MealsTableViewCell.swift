//
//  MealsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/7/24.
//

import Foundation
import SwiftUI

class MealsTableViewCell: UITableViewCell {
    
    var imgTapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(2)
        img.clipsToBounds = true
        img.setImgLocal(imgName: "meals_icon_default")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var foodsNameLabel : UILabel = {
        let lab = UILabel()
//        lab.textColor = .COLOR_GRAY_BLACK_65
//        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var foodsWeightLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var foodsCaloriLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_arrow_gray")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        return img
    }()
    lazy var addButtonVm: FoodsAddIconVM = {
        let vm = FoodsAddIconVM.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(60), y: kFitWidth(10), width: 0, height: 0))
//        vm.isHidden = true
        vm.alpha = 0
        return vm
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return vi
    }()
}

extension MealsTableViewCell{
    func updateUI(dict:NSDictionary,keywords:String) {
        if dict.stringValueForKey(key: "name").count == 0 {
            updateConstraitForSkeleton()
            iconImgView.image = nil
            foodsNameLabel.text = nil
            foodsWeightLabel.text = nil
            arrowImgView.alpha = 0
            addButtonVm.alpha = 0
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [iconImgView, foodsNameLabel,foodsWeightLabel].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [iconImgView, foodsNameLabel,foodsWeightLabel].forEach { $0.hideSkeletonWithCrossfade() }
//        addButtonVm.isHidden = false
//        addButtonVm.alpha = 0
        
        UIView.animate(withDuration: 0.15, animations: {
            self.addButtonVm.alpha = 1
        })
        
        updateConstrait()
        if dict.stringValueForKey(key: "image").count > 0 {
            iconImgView.setImgUrl(urlString: dict.stringValueForKey(key: "image"))
        }else{
            //meals_top_bg    data_photo_default   meals_icon_default   meals_foods_photo   meals_foods_default
            iconImgView.setImgLocal(imgName: "meals_icon_default")
        }
        
        foodsCaloriLabel.text = ""
        foodsWeightLabel.text = "每份/\(WHUtils.convertStringToStringNoDigit("\(dict.doubleValueForKey(key: "calories").rounded())") ?? "")千卡"
        
        foodsNameLabel.textColor = .COLOR_GRAY_BLACK_85
        if keywords.count > 0 {
            foodsNameLabel.attributedText = createAttributedString(text: dict.stringValueForKey(key: "name"),keywords: keywords)
        }else{
            foodsNameLabel.attributedText = NSAttributedString(string: dict.stringValueForKey(key: "name"))
        }
    }
    func boldKeywords(nameString:NSString,keywords:String) -> NSAttributedString{
        if nameString.contains(keywords){
            let range = nameString.range(of: keywords)
//            DLLog(message: "boldKeywords:\(range):\(nameString)  --  \(keywords)")
            let firstStr = NSMutableAttributedString(string: nameString.substring(with: NSRange(location: 0, length: range.location)))
            let secondStr = NSMutableAttributedString(string: nameString.substring(from: range.location+range.length))
            
            let boldAttr = NSMutableAttributedString(string: keywords)
//            boldAttr.yy_font = .systemFont(ofSize: 16, weight: .heavy)
            boldAttr.yy_color = .THEME
            
            firstStr.append(boldAttr)
            firstStr.append(secondStr)
            return firstStr
        }else{
            return NSMutableAttributedString(string: nameString as String)
        }
    }
    
    func createAttributedStringWithImage(image: UIImage, text: String,keywords:String? = "") -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .medium).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        var string = NSMutableAttributedString(string: text)
        
        if keywords?.count ?? 0 > 0 {
            string = NSMutableAttributedString(attributedString: self.boldKeywords(nameString: string.string as NSString,keywords:keywords ?? ""))
        }
        
        string.append(attachmentString)
//        foodsNameLabel.attributedText = string
        return string
    }
    func createAttributedString(text: String,keywords:String? = "") -> NSAttributedString {
        var string = NSMutableAttributedString(string: text)
        
        if keywords?.count ?? 0 > 0 {
            string = NSMutableAttributedString(attributedString: self.boldKeywords(nameString: string.string as NSString,keywords:keywords ?? ""))
        }
        
        return string
    }
    
    @objc func imgTapAction() {
        if self.imgTapBlock != nil{
            self.imgTapBlock!()
        }
    }
}


extension MealsTableViewCell{
    func initUI() {
        contentView.addSubview(iconImgView)
        contentView.addSubview(foodsNameLabel)
        contentView.addSubview(foodsWeightLabel)
        contentView.addSubview(foodsCaloriLabel)
        contentView.addSubview(arrowImgView)
        contentView.addSubview(addButtonVm)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(60))
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(5))
            make.top.equalTo(iconImgView).offset(kFitWidth(4))
            make.right.equalTo(kFitWidth(-50))
            make.width.equalTo(kFitWidth(160))
            make.height.equalTo(kFitWidth(18))
        }
        foodsWeightLabel.snp.makeConstraints { make in
            make.left.equalTo(foodsNameLabel)
            make.bottom.equalTo(iconImgView).offset(kFitWidth(-4))
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(18))
        }
        foodsCaloriLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-40))
            make.top.equalTo(kFitWidth(10))
            make.width.equalTo(kFitWidth(46))
            make.height.equalTo(kFitWidth(18))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(kFitWidth(10))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.width.equalTo(kFitWidth(343))
        }
    }
    func updateConstrait() {
        foodsNameLabel.snp.remakeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(5))
            make.top.equalTo(iconImgView).offset(kFitWidth(4))
            make.right.equalTo(kFitWidth(-50))
        }
        foodsWeightLabel.snp.remakeConstraints { make in
            make.left.equalTo(foodsNameLabel)
            make.bottom.equalTo(iconImgView).offset(kFitWidth(-4))
        }
        foodsCaloriLabel.snp.remakeConstraints { make in
            make.right.equalTo(kFitWidth(-40))
            make.top.equalTo(kFitWidth(10))
        }
    }
    func updateConstraitForSkeleton() {
        foodsNameLabel.snp.remakeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(5))
            make.top.equalTo(iconImgView).offset(kFitWidth(4))
            make.right.equalTo(kFitWidth(-50))
            make.width.equalTo(kFitWidth(160))
            make.height.equalTo(kFitWidth(18))
        }
        foodsWeightLabel.snp.remakeConstraints { make in
            make.left.equalTo(foodsNameLabel)
            make.bottom.equalTo(iconImgView).offset(kFitWidth(-4))
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(18))
        }
        foodsCaloriLabel.snp.remakeConstraints { make in
            make.right.equalTo(kFitWidth(-40))
            make.top.equalTo(kFitWidth(10))
            make.width.equalTo(kFitWidth(46))
            make.height.equalTo(kFitWidth(18))
        }
    }
}
