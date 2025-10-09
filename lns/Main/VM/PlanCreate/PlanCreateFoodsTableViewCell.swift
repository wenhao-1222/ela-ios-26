//
//  PlanCreateFoodsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/4/23.
//

import Foundation
import SwiftUI

class PlanCreateFoodsTableViewCell: UITableViewCell {
    
    var isSelect = false
    var selectTapBlock:((Bool)->())?
    var delTapBlock:(()->())?
    var eatTapBlock:(()->())?
    var longPressBlock:(()->())?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
        
        let pressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        pressGes.minimumPressDuration = 0.5
        self.addGestureRecognizer(pressGes)
    }
    
    lazy var selecImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_edit_normal")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        return img
    }()
    lazy var selectTapView : FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        vi.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var foodsNameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isUserInteractionEnabled = true
//        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var foodsWeightLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var foodsCaloriLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_arrow_gray")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var eatButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "logs_foods_eat_icon"), for: .normal)
//        btn.setImage(UIImage(named: "logs_foods_eat_icon_cj"), for: .normal)
        btn.setTitle("用餐", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.imagePosition(style: .left, spacing: kFitWidth(2))
        btn.isHidden = true
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        
        btn.addTarget(self, action: #selector(eatAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var eatTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(eatAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension PlanCreateFoodsTableViewCell{
    @objc func eatAction(){
        if self.eatTapBlock != nil{
            self.eatTapBlock!()
        }
    }
    @objc func tapAction() {
        isSelect = !isSelect
        
        selecImgView.setCheckState(isSelect,
                          checkedImageName: "logs_edit_selected",
                          uncheckedImageName: "logs_edit_normal")

        if self.selectTapBlock != nil{
            self.selectTapBlock!(self.isSelect)
        }
    }
    @objc func longPressAction(gesture:UILongPressGestureRecognizer) {
        if gesture.state != .began{
            return
        }
        TouchGenerator.shared.touchGenerator()
        self.longPressBlock?()
        self.tapAction()
    }
}

extension PlanCreateFoodsTableViewCell{
    func updateUI(dict:NSDictionary) {
        foodsNameLabel.text = dict["fname"]as? String ?? ""
        arrowImgView.isHidden = false
        if dict["fname"]as? String ?? "" == "快速添加"{
            foodsWeightLabel.text = ""
            arrowImgView.isHidden = true
            foodsCaloriLabel.text = "\(WHUtils.convertStringToString("\(dict["caloriesNumber"]as? String ?? "0")") ?? "0") 千卡"
            
            if dict["caloriesNumber"]as? String ?? "0" == "0"{
                foodsCaloriLabel.text = "\(WHUtils.convertStringToString("\(dict["calories"]as? Int ?? 0)") ?? "0") 千卡"
            }
            foodsWeightLabel.text = "\(String(format: "%.0f", dict.doubleValueForKey(key: "carbohydrate").rounded()))g 碳水，\(String(format: "%.0f", dict.doubleValueForKey(key: "protein").rounded()))g 蛋白质，\(String(format: "%.0f", dict.doubleValueForKey(key: "fat").rounded()))g 脂肪"
            
//            if dict.stringValueForKey(key: "remark").count > 0{
//                foodsNameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
//            }
            if dict.stringValueForKey(key: "ctype") == "3"{
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "remark"))"
            }else if dict.stringValueForKey(key: "remark").count > 0 {
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
            }
            return
        }
        foodsWeightLabel.text = "\(WHUtils.convertStringToString(String(format: "%.2f", (dict.doubleValueForKey(key: "specNum")))) ?? "0")\(dict["specName"]as? String ?? "g")"
        
        foodsCaloriLabel.text = "\(String(format: "%.0f", dict.doubleValueForKey(key: "calories"))) 千卡"
    }
    func updateUIForMeals(dict:NSDictionary,isEdit:Bool) {
        self.refresEditStatus(isEdit: isEdit)
        foodsNameLabel.text = dict["fname"]as? String ?? ""
        foodsCaloriLabel.text = "\(String(format: "%.0f", dict.doubleValueForKey(key: "calories").rounded())) 千卡"
        if isEdit == false{
            arrowImgView.isHidden = true
        }else{
            arrowImgView.isHidden = false
        }
        
        if dict.stringValueForKey(key: "isSelect") == "1"{
            self.isSelect = true
        }else{
            self.isSelect = false
        }
        selecImgView.setCheckState(isSelect,
                          checkedImageName: "logs_edit_selected",
                          uncheckedImageName: "logs_edit_normal")
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            foodsWeightLabel.text = "\(String(format: "%.0f", dict.doubleValueForKey(key: "carbohydrate").rounded()))g 碳水，\(String(format: "%.0f", dict.doubleValueForKey(key: "protein").rounded()))g 蛋白质，\(String(format: "%.0f", dict.doubleValueForKey(key: "fat").rounded()))g 脂肪"
//            if dict.stringValueForKey(key: "remark").count > 0 {
//                foodsNameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
//            }
            if dict.stringValueForKey(key: "ctype") == "3"{
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "remark"))"
            }else if dict.stringValueForKey(key: "remark").count > 0 {
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
            }
            return
        }
        
        let foodsDict = dict["foods"]as? NSDictionary ?? [:]
        arrowImgView.isHidden = false
        if foodsDict.stringValueForKey(key: "fname").count == 0 || foodsDict.stringValueForKey(key: "fname") == "" || isEdit == false{
            arrowImgView.isHidden = true
        }
        foodsWeightLabel.text = "\(WHUtils.convertStringToString(String(format: "%.2f", (dict.doubleValueForKey(key: "qty")))) ?? "0")\(dict["spec"]as? String ?? "g")"
    }
    func updateUIForLogs(dict:NSDictionary,isEdit:Bool) {
        self.refresEditStatus(isEdit: isEdit)
        foodsNameLabel.text = dict["fname"]as? String ?? ""
        isSelect = dict["isSelect"]as? String ?? "" == "1" ? true : false
        
        selecImgView.setCheckState(isSelect,
                          checkedImageName: "logs_edit_selected",
                          uncheckedImageName: "logs_edit_normal")
        arrowImgView.setImgLocal(imgName: "plan_detail_arrow_icon_right")
        arrowImgView.isHidden = false
        foodsCaloriLabel.text = "\(String(format: "%.0f", dict.doubleValueForKey(key: "calories").rounded())) 千卡"
        
        refresStateUI(state: dict.stringValueForKey(key: "state"), isEdit: isEdit)
        
        if dict["fname"]as? String ?? "" == "快速添加"{
//            arrowImgView.isHidden = true
            foodsWeightLabel.text = "\(String(format: "%.0f", dict.doubleValueForKey(key: "carbohydrate").rounded()))g 碳水，\(String(format: "%.0f", dict.doubleValueForKey(key: "protein").rounded()))g 蛋白质，\(String(format: "%.0f", dict.doubleValueForKey(key: "fat").rounded()))g 脂肪"
            if dict.stringValueForKey(key: "ctype") == "3"{
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "remark"))"
            }else if dict.stringValueForKey(key: "remark").count > 0 {
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
            }
            
            return
        }
        let foodsDict = dict["foods"]as? NSDictionary ?? [:]
        
        if foodsDict.stringValueForKey(key: "fname").count == 0 || foodsDict.stringValueForKey(key: "fname") == ""{
            arrowImgView.isHidden = true
        }
        foodsWeightLabel.text = "\(WHUtils.convertStringToString(String(format: "%.2f", (dict.doubleValueForKey(key: "qty")))) ?? "0")\(dict.stringValueForKey(key: "spec"))"
        //本地选择的食物
//        if (dict["specName"]as? String ?? "").count > 0 {
//            //直接本地修改的食物
//            foodsWeightLabel.text = "\(WHUtils.convertStringToString(String(format: "%.2f", (dict.doubleValueForKey(key: "specNum")))) ?? "0")\(dict["specName"]as? String ?? "g")"
//        }else if dict.doubleValueForKey(key: "qty") > 0{
//            //经过了本地添加，或者修改了数值的食物，则会有qty 和  spec 字段
//            foodsWeightLabel.text = "\(WHUtils.convertStringToString(String(format: "%.2f", (dict.doubleValueForKey(key: "qty")))) ?? "0")\(dict["spec"]as? String ?? "g")"
//        }else{
//            //此种情况是后台做问卷生成的计划，导入到日志后，食物没有qty  和  apec 字段
//            //此时默认用   weight   ，单位是  g
//            foodsWeightLabel.text = "\(WHUtils.convertStringToString("\(dict["weight"]as? Double ?? 0)") ?? "0")\(dict["spec"]as? String ?? "g")"
//        }
    }
    func refresStateUI(state:String,isEdit:Bool) {
        if state == "1" || state == "1.0"{
            arrowImgView.isHidden = false
            eatButton.isHidden = true
            eatTapView.isHidden = true
            
            foodsNameLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            foodsCaloriLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            foodsWeightLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            
            foodsCaloriLabel.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-40))
                make.top.equalTo(kFitWidth(10))
            }
        }else{
            arrowImgView.isHidden = true
            eatButton.isHidden = false
            eatTapView.isHidden = false
            foodsNameLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            foodsCaloriLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            foodsWeightLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
//            foodsCaloriLabel.textColor = .THEME
            
            foodsCaloriLabel.snp.remakeConstraints { make in
//                make.right.equalTo(kFitWidth(-62))
                make.right.equalTo(eatButton.snp.left).offset(kFitWidth(-1))
                make.top.equalTo(kFitWidth(10))
            }
        }
    }
    func refresEditStatus(isEdit:Bool) {
        if isEdit {
            selecImgView.isHidden = false
            selectTapView.isHidden = false
            foodsNameLabel.snp.remakeConstraints { make in
//                make.centerY.lessThanOrEqualTo(selecImgView)
                make.top.equalTo(kFitWidth(10))
                make.right.equalTo(kFitWidth(-140))
                make.left.equalTo(selecImgView.snp.right).offset(kFitWidth(11))
//                make.left.equalTo(kFitWidth(44))
            }
            foodsWeightLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(44))
                make.top.equalTo(kFitWidth(33))
            }
            selectTapView.snp.remakeConstraints { make in
                make.left.top.height.equalToSuperview()
                make.width.equalTo(kFitWidth(50))
            }
        }else{
            selecImgView.isHidden = true
            selectTapView.isHidden = true
            foodsNameLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(kFitWidth(10))
                make.right.equalTo(kFitWidth(-140))
            }
            foodsWeightLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(kFitWidth(33))
            }
            selectTapView.snp.remakeConstraints { make in
                make.left.top.height.equalToSuperview()
                make.width.equalTo(kFitWidth(10))
            }
        }
    }
}
extension PlanCreateFoodsTableViewCell{
    func initUI() {
        contentView.addSubview(selecImgView)
        contentView.addSubview(foodsNameLabel)
        contentView.addSubview(foodsWeightLabel)
        contentView.addSubview(foodsCaloriLabel)
        contentView.addSubview(selectTapView)
        contentView.addSubview(arrowImgView)
        contentView.addSubview(eatButton)
        contentView.addSubview(eatTapView)
        
        setConstrait()
    }
    func setConstrait() {
        selecImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        selectTapView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(40))
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
            make.right.equalTo(kFitWidth(-140))
        }
        foodsWeightLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(33))
        }
        foodsCaloriLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-40))
            make.top.equalTo(kFitWidth(10))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(10))
            make.width.height.equalTo(kFitWidth(16))
        }
        eatButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-8))
            make.centerY.lessThanOrEqualTo(foodsCaloriLabel)
//            make.width.equalTo(kFitWidth(30))
//            make.height.equalTo(kFitWidth(30))
            make.width.equalTo(kFitWidth(56))
            make.height.equalTo(kFitWidth(30))
        }
        eatTapView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.height.equalToSuperview()
            make.left.equalTo(foodsCaloriLabel)
        }
    }
}
