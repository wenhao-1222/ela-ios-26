//
//  PlanCreateTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/4/15.
//

import Foundation

class PlanCreateTableViewCell: UITableViewCell {
    
    var foodsArray = NSMutableArray()
    var addBlock:(()->())?
    
    var deleteFoodsBlock:((NSDictionary,Int)->())?
    var addNewSpecBlock:((NSDictionary)->())?
    var selectMeaslIndexBlock:((Int)->())?
    var controller = WHBaseViewVC()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    
    lazy var bottomView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
//        vi.clipsToBounds = true
//        vi.layer.cornerRadius = kFitWidth(8)
        vi.isUserInteractionEnabled = true
//        vi.layer.borderColor = WHColor_16(colorStr: "F0F0F0").cgColor
//        vi.layer.borderWidth = kFitWidth(1)
        
        return vi
    }()
    lazy var mealsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var addFoodsButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("添加食物", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setImage(UIImage.init(named: "create_plan_add_foods_icon"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var contentLabel : UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "请添加食物"
        
        return lab
    }()
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        table.separatorStyle = .none
        table.register(PlanCreateFoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanCreateFoodsTableViewCell")
        table.delegate = self
        table.dataSource = self
        
        
        return table
    }()
    lazy var naturalMsgLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.isHidden = true
        
        return lab
    }()
    
    lazy var caloriesMsgLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isHidden = true
        
        return lab
    }()
}

extension PlanCreateTableViewCell{
    @objc func addAction(){
        if self.addBlock != nil{
            self.addBlock!()
        }
    }
    func updateUI(dict:NSDictionary) {
        mealsLabel.text = "第 \(dict["mealsIndex"]as? String ?? "") 餐"
        
        let foodsArray =  dict["foodsArray"]as? NSArray ?? []
        var foods = ""
        
        for i in 0..<foodsArray.count{
            let dict = foodsArray[i]as? NSDictionary ?? [:]
            let name = dict["fname"]as? String ?? ""
            foods = "\(foods)\(name)\n"
        }
        
        if foods == ""{
            contentLabel.text = "请添加食物"
        }else{
            foods = foods.mc_clipFromPrefix(to: foods.count-1)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = kFitWidth(12)
            
            // 创建NSAttributedString并设置字体和行高
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .paragraphStyle: paragraphStyle
            ]
            let attributedString = NSMutableAttributedString(string: foods)
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: foods.count))
             
            // 将设置好的NSAttributedString赋值给UILabel的attributedText属性
            contentLabel.attributedText = attributedString
        }
    }
    func setFoodsArray(dict:NSDictionary) {
        mealsLabel.text = "第 \(dict["mealsIndex"]as? String ?? "") 餐"
        foodsArray = NSMutableArray(array: dict["foodsArray"]as? NSArray ?? [])
        
        if foodsArray.count > 0{
            contentLabel.isHidden = true
            self.tableView.isHidden = false
            self.naturalMsgLabel.isHidden = false
            self.caloriesMsgLabel.isHidden = false
            self.tableView.frame = CGRect.init(x: 0, y: kFitWidth(62), width: SCREEN_WIDHT, height: CGFloat(self.foodsArray.count)*kFitWidth(55)+kFitWidth(20))
            self.tableView.reloadData()
//            self.bottomView.snp.remakeConstraints { make in
//                make.left.top.width.equalToSuperview()
//                make.bottom.equalTo(kFitWidth(-8))
//            }
            lineView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.right.equalTo(kFitWidth(-14))
//                make.top.equalTo(kFitWidth(56))
                make.bottom.equalTo(naturalMsgLabel.snp.top).offset(kFitWidth(-10))
                make.height.equalTo(kFitWidth(1))
            }
            updateNaturalNumber()
        }else{
            contentLabel.isHidden = false
            self.tableView.isHidden = true
            self.naturalMsgLabel.isHidden = true
            self.caloriesMsgLabel.isHidden = true
            lineView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.right.equalTo(kFitWidth(-14))
                make.top.equalTo(kFitWidth(56))
                make.height.equalTo(kFitWidth(1))
            }
        }
    }
    func updateNaturalNumber() {
        DispatchQueue.global(qos: .userInitiated).async {
            var caloriTotal = Double(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            for i in 0..<self.foodsArray.count{
                let dict = self.foodsArray[i]as? NSDictionary ?? [:]
   //                if dict.stringValueForKey(key: "state") == "1"{
                    caloriTotal = caloriTotal + dict.doubleValueForKey(key: "calories")
                    carboTotal = carboTotal + dict.doubleValueForKey(key: "carbohydrate")
                    proteinTotal = proteinTotal + dict.doubleValueForKey(key: "protein")
                    fatTotal = fatTotal + dict.doubleValueForKey(key: "fat")
   //                }
            }
            DispatchQueue.main.async {
                DLLog(message: "proteinTotal:\(proteinTotal)")
                self.naturalMsgLabel.text = "\(String(format: "%.0f", carboTotal.rounded()))g 碳水," +
                                            "\(String(format: "%.0f", proteinTotal.rounded()))g 蛋白质," +
                                            "\(String(format: "%.0f", fatTotal.rounded()))g 脂肪"
                self.caloriesMsgLabel.text = "\(String(format: "%.0f", caloriTotal.rounded()))千卡"
//                self.naturalVm.caloriLabel.text = "\(String(format: "%.0f", caloriTotal.rounded()))"
//                self.naturalVm.carboLabel.text = "\(String(format: "%.0f", carboTotal.rounded()))"
//                self.naturalVm.proteinLabel.text = "\(String(format: "%.0f", proteinTotal.rounded()))"
//                self.naturalVm.fatLabel.text = "\(String(format: "%.0f", fatTotal.rounded()))"
            }
        }
    }
    func deleteFoods(dict:NSDictionary) {
        if foodsArray.count > 0{
            contentLabel.isHidden = true
            self.tableView.isHidden = false
            self.naturalMsgLabel.isHidden = false
            self.caloriesMsgLabel.isHidden = false
            self.tableView.reloadData()
            self.tableView.frame = CGRect.init(x: 0, y: kFitWidth(62), width: SCREEN_WIDHT, height: CGFloat(self.foodsArray.count)*kFitWidth(55)+kFitWidth(20))
            lineView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.right.equalTo(kFitWidth(-14))
//                make.top.equalTo(kFitWidth(56))
                make.bottom.equalTo(naturalMsgLabel.snp.top).offset(kFitWidth(-10))
                make.height.equalTo(kFitWidth(1))
            }
        }else{
            contentLabel.isHidden = false
            self.tableView.isHidden = true
            self.naturalMsgLabel.isHidden = true
            self.caloriesMsgLabel.isHidden = true
            lineView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.right.equalTo(kFitWidth(-14))
                make.top.equalTo(kFitWidth(56))
                make.height.equalTo(kFitWidth(1))
            }
        }
    }
    //修改了食物的规格、数量等信息
    func updateFoodsSpec(dict:NSDictionary) {
//        self.foodsArray.replaceObject(at: indexPath.row, with: dict)
//        self.tableView.reloadData()
        var hasFoods = false
        for i in 0..<self.foodsArray.count{
            let dictT = self.foodsArray[i]as? NSDictionary ?? [:]
            
            if dict["fid"]as? String ?? "" == dictT["fid"]as? String ?? "" && dict["specName"]as? String ?? "" == dictT["specName"]as? String ?? ""{
                hasFoods = true
                self.foodsArray.replaceObject(at: i, with: dict)
                break
            }
        }
        
        self.tableView.reloadData()
        
        if hasFoods == false{
            self.foodsArray.add(dict)
            if self.addNewSpecBlock != nil{
                self.addNewSpecBlock!(dict)
            }
        }
    }
}

extension PlanCreateTableViewCell{
    func initUI() {
        contentView.addSubview(bottomView)
        bottomView.addSubview(mealsLabel)
        bottomView.addSubview(addFoodsButton)
        bottomView.addSubview(tableView)
        bottomView.addSubview(lineView)
        bottomView.addSubview(naturalMsgLabel)
        bottomView.addSubview(caloriesMsgLabel)
        contentView.addSubview(contentLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bottomView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-8))
        }
        mealsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }
        addFoodsButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.height.equalTo(mealsLabel)
            make.width.equalTo(kFitWidth(108))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-14))
            make.top.equalTo(kFitWidth(56))
            make.height.equalTo(kFitWidth(1))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(69))
            make.right.equalTo(kFitWidth(-20))
//            make.bottom.equalTo(kFitWidth(-28))
        }
        naturalMsgLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualTo(caloriesMsgLabel)
            make.right.equalTo(caloriesMsgLabel.snp.left).offset(kFitWidth(-5))
        }
        caloriesMsgLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(30))
        }
    }
}

extension PlanCreateTableViewCell:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell")as? PlanCreateFoodsTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell", for: indexPath) as! PlanCreateFoodsTableViewCell
        
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        
        return cell ?? PlanCreateFoodsTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(55)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        
        if dict.stringValueForKey(key: "fname") == "快速添加"{
            return
        }
        if self.selectMeaslIndexBlock != nil{
            self.selectMeaslIndexBlock!(indexPath.row)
        }
        let vc = FoodsMsgDetailsVC()
        vc.sourceType = .plan
//        vc.deleteButton.isHidden = true
        vc.foodsDetailDict = dict["foods"]as? NSDictionary ?? [:]
        if dict.stringValueForKey(key: "specNum") == "" || dict.stringValueForKey(key: "specNum").count == 0{
            let specDefalutDict = WHUtils.getSpecDefaultFromFoods(foodsDict: dict["foods"]as? NSDictionary ?? [:])
            vc.specNum = specDefalutDict.stringValueForKey(key: "specNum")
            vc.specName = specDefalutDict.stringValueForKey(key: "specName")
        }else{
            vc.specNum = dict.stringValueForKey(key: "specNum")
            vc.specName = dict["specName"]as? String ?? "g"
        }
        self.controller.navigationController?.pushViewController(vc, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            vc.deleteButton.isHidden = true
        })
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            TouchGenerator.shared.touchGenerator()
            let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
            if self.deleteFoodsBlock != nil{
                self.deleteFoodsBlock!(dict,indexPath.row)
            }
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}
