//
//  JournalTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/4/24.
//

import Foundation
import MCToast
import UIKit

class JournalTableViewCell: UITableViewCell {
    
    var foodsArray = NSMutableArray()
    var addBlock:(()->())?
    var deleteBlock:((NSDictionary)->())?
    var deleteCellBlock:((NSDictionary,Int)->())?
    var timeChangeBlock:((String)->())?
    var closeMealAdviceBlock:(()->())?
    var controller = UIViewController()
    
    var caloriBlock:((NSDictionary)->())?
    
    var selectCellBlock:((Bool,Int)->())?
    var eatTapBlock:((Int)->())?
    var selectBlock:((Bool)->())?
    var selectMeaslIndexBlock:((Int)->())?
    
    var isEdit = false
    var isSelect = false
    var deleteIndex = IndexPath()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeEditStatus), name: NSNotification.Name(rawValue: "closeEditStatus"), object: nil)
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(10), y: kFitWidth(12), width: SCREEN_WIDHT-kFitWidth(20), height: kFitWidth(70)))
        vi.backgroundColor = .COLOR_BG_WHITE//UIColor(named: "color_bg_f5")
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        
        return vi
    }()
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
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(16), width: kFitWidth(80), height: kFitWidth(20))
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "第 1 餐"
        return lab
    }()
    lazy var timebutton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.addTarget(self, action: #selector(timeTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var addButton: FeedBackTapButton = {
        let btn = FeedBackTapButton()
        btn.setImage(UIImage(named: "logs_add_icon_theme"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.addPressEffect()
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var noFoodsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "请添加食物"
        lab.numberOfLines = 0
        return lab
    }()
    lazy var noTipsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("不再提示", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .regular)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.isHidden = true
        
        btn.addTarget(self, action: #selector(nextAdviceNotTipsAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var naturalVm : LogsMealsNaturalMsgVM = {
        let vm = LogsMealsNaturalMsgVM.init(frame: CGRect.init(x: 0, y: kFitWidth(46), width: 0, height: 0))
        vm.isHidden = true
        return vm
    }()
    lazy var tableView: JournalFoodsTableView = {
        let table = JournalFoodsTableView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        table.separatorStyle = .none
        table.register(PlanCreateFoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanCreateFoodsTableViewCell")
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .COLOR_BG_WHITE
        
//        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
//        swipeGesture.direction = .left
//        table.addGestureRecognizer(swipeGesture)
        
        return table
    }()
}

extension JournalTableViewCell{
    @objc func addAction(){
        if self.addBlock != nil{
            self.addBlock!()
        }
    }
    @objc func nextAdviceNotTipsAction(){
        if self.closeMealAdviceBlock != nil{
            self.closeMealAdviceBlock!()
        }
    }
    @objc func timeTapAction(){
        if self.timeChangeBlock != nil{
            self.timeChangeBlock!(timebutton.titleLabel?.text ?? "")
        }
    }
    @objc func tapAction() {
        isSelect = !isSelect
        
        selecImgView.setCheckState(isSelect,
                                  checkedImageName: "logs_edit_selected",
                                  uncheckedImageName: "logs_edit_normal")
        if self.selectBlock != nil{
            self.selectBlock!(self.isSelect)
        }
    }
    @objc private func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            // 获取触摸点在tableView上的位置
            let touchPoint = gesture.location(in: tableView)
              if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // 执行删除操作
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    @objc func closeEditStatus(){
        self.tableView.setEditing(false, animated: true)
    }
}

extension JournalTableViewCell{
    func updateUI(array:NSArray,isEdit:Bool,isToday:Bool=false,sn:String="0",queryDate:String) {
        foodsArray = NSMutableArray(array: array)
        refresEditStatus(isEdit: isEdit)
        refreshSelectStatus()
        noTipsButton.isHidden = true
        if foodsArray.count == 0 {
            noFoodsLabel.text = "请添加食物"
            noFoodsLabel.isHidden = false
            naturalVm.isHidden = true
            var btnHeight = kFitWidth(0)
            if isToday == true && UserInfoModel.shared.show_next_advice{
                let adviceDict = UserDefaults.getDictionary(forKey: .jounal_meal_advice) as? NSDictionary ?? [:]
                
                if sn == adviceDict.stringValueForKey(key: "sn") && adviceDict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId && adviceDict.stringValueForKey(key: "sdate") == queryDate && adviceDict.stringValueForKey(key: "advice").count > 0{
                    noFoodsLabel.text = adviceDict.stringValueForKey(key: "advice")
                    noTipsButton.isHidden = false
                    btnHeight = kFitWidth(20)
                }
            }
            let labelWidth = SCREEN_WIDHT - kFitWidth(20) - kFitWidth(30)
            let labelHeight = noFoodsLabel.text?.mc_getHeight(font: noFoodsLabel.font, width: labelWidth) ?? 0
            noFoodsLabel.preferredMaxLayoutWidth = labelWidth
            self.tableView.isHidden = true
            self.whiteView.frame = CGRect.init(x: kFitWidth(10), y: kFitWidth(12), width: SCREEN_WIDHT-kFitWidth(20), height: kFitWidth(42)+labelHeight+kFitWidth(12)+btnHeight)
            self.whiteView.layoutIfNeeded()
//            self.tableView.isHidden = true
//            self.whiteView.frame = CGRect.init(x: kFitWidth(10), y: kFitWidth(12), width: SCREEN_WIDHT-kFitWidth(20), height: kFitWidth(70))
            return
        }
        
        noFoodsLabel.isHidden = true
        naturalVm.isHidden = false
        self.whiteView.frame = CGRect.init(x: kFitWidth(10), y: kFitWidth(12), width: SCREEN_WIDHT-kFitWidth(20), height: kFitWidth(143)+CGFloat(foodsArray.count)*kFitWidth(55))
//        self.whiteView.frame = CGRect.init(x: kFitWidth(10), y: kFitWidth(12), width: SCREEN_WIDHT-kFitWidth(20), height: naturalVm.frame.maxY+CGFloat(foodsArray.count)*kFitWidth(55))
        self.tableView.frame = CGRect.init(x: 0, y: naturalVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(20), height: CGFloat(foodsArray.count)*kFitWidth(55))
        self.tableView.isHidden = false
        self.tableView.reloadData()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var caloriTotal = Double(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            for i in 0..<self.foodsArray.count{
                let dict = self.foodsArray[i]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "state") == "1"{
                    caloriTotal = caloriTotal + dict.doubleValueForKey(key: "calories")
                    carboTotal = carboTotal + dict.doubleValueForKey(key: "carbohydrate")
                    proteinTotal = proteinTotal + dict.doubleValueForKey(key: "protein")
                    fatTotal = fatTotal + dict.doubleValueForKey(key: "fat")
                }
            }
            
            DispatchQueue.main.async {
                self.naturalVm.caloriLabel.text = "\(String(format: "%.0f", caloriTotal.rounded()))"
                self.naturalVm.carboLabel.text = "\(String(format: "%.0f", carboTotal.rounded()))"
                self.naturalVm.proteinLabel.text = "\(String(format: "%.0f", proteinTotal.rounded()))"
                self.naturalVm.fatLabel.text = "\(String(format: "%.0f", fatTotal.rounded()))"
            }
        }
    }
//    func refreshTodayAdvice(isToday:Bool,sn:String) {
//        if isToday == false{
//            return
//        }
//        let adviceDict = UserDefaults.getDictionary(forKey: .jounal_meal_advice) as? NSDictionary ?? [:]
//        
//        if sn == adviceDict.stringValueForKey(key: "sn") && adviceDict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId && adviceDict.stringValueForKey(key: "advice").count > 0{
//            noFoodsLabel.isHidden = false
//            noFoodsLabel.text = adviceDict.stringValueForKey(key: "advice")
//        }
//    }
    func refresEditStatus(isEdit:Bool) {
        self.isEdit = isEdit
        if isEdit && foodsArray.count > 0{
            self.selecImgView.isHidden = false
            self.selectTapView.isHidden = false
            titleLabel.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(16))
                make.left.equalTo(selecImgView.snp.right).offset(kFitWidth(11))
//                make.left.equalTo(kFitWidth(44))
            }
        }else{
            selecImgView.isHidden = true
            selectTapView.isHidden = true
            
            titleLabel.snp.remakeConstraints { make in
                make.left.top.equalTo(kFitWidth(16))
            }
        }
    }
    func refreshSelectStatus(){
        var isAllSelect = true
        for j in 0..<foodsArray.count{
            let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
            if foodsDi["isSelect"]as? String ?? "" != "1"{
                isAllSelect = false
                break
            }
        }
        isSelect = isAllSelect
        
        selecImgView.setCheckState(isSelect,
                                  checkedImageName: "logs_edit_selected",
                                  uncheckedImageName: "logs_edit_normal")
    }
    func updateMealsTime(mealsDict:NSDictionary,mealsIndex:Int) {
        if UserInfoModel.shared.hiddenMeaTimeStatus{
            self.timebutton.isHidden = true
            return
        }
        let text = "（\(mealsDict.stringValueForKey(key: "mealTimeSn\(mealsIndex)"))）"
        self.timebutton.setTitle(text, for: .normal)
        if text.count > 3 {
            self.timebutton.isHidden = false
        }else{
            self.timebutton.isHidden = true
        }
    }
}
extension JournalTableViewCell{
    func initUI() {
        contentView.addSubview(whiteView)
        
        whiteView.addSubview(selecImgView)
        whiteView.addSubview(selectTapView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(timebutton)
        whiteView.addSubview(addButton)
        whiteView.addSubview(noFoodsLabel)
        whiteView.addSubview(noTipsButton)
        
        whiteView.addSubview(naturalVm)
        whiteView.addSubview(tableView)
        
        setConstrait()
    }
    func setConstrait() {
        selecImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
//            make.top.equalTo(kFitWidth(13))
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.width.height.equalTo(kFitWidth(20))
        }
        selectTapView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(44))
        }
//        titleLabel.snp.makeConstraints { make in
//            make.left.top.equalTo(kFitWidth(16))
//        }
        timebutton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(kFitWidth(2))
            make.centerY.lessThanOrEqualTo(titleLabel)
        }
        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
//            make.right.equalTo(kFitWidth(-66))
            make.right.equalToSuperview()
            make.width.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(48))
        }
        noFoodsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(42))
            make.right.equalToSuperview().offset(-kFitWidth(15))
        }
        noTipsButton.snp.makeConstraints { make in
            make.left.equalTo(noFoodsLabel)
            make.top.equalTo(noFoodsLabel.snp.bottom).offset(kFitWidth(3))
        }
    }
}

extension JournalTableViewCell:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell")as! PlanCreateFoodsTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell", for: indexPath) as? PlanCreateFoodsTableViewCell
        
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUIForLogs(dict: dict,isEdit:self.isEdit)
        
        cell?.selectTapBlock = {(isSelec)in
            if self.selectCellBlock != nil{
                self.selectCellBlock!(isSelec,indexPath.row)
            }
        }
        cell?.delTapBlock = {()in
            self.deleteIndex = indexPath
            self.tableView.setEditing(true, animated: true)
        }
        cell?.eatTapBlock = {()in
            if self.eatTapBlock != nil{
                self.eatTapBlock!(indexPath.row)
            }
        }
        cell?.longPressBlock = {()in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "longPressCellForEdit"), object: nil)
        }
        return cell ?? PlanCreateFoodsTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(55)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        TouchGenerator.shared.touchGenerator()
        if foodsArray.count <= indexPath.row{
            return
        }
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        if self.selectMeaslIndexBlock != nil{
            self.selectMeaslIndexBlock!(indexPath.row)
        }
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            let vc = FoodsCreateFastVC()
            vc.setNumber(dict: dict)
            self.controller.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let foodsDict = dict["foods"]as? NSDictionary ?? [:]
        
        if foodsDict.stringValueForKey(key: "fname").count > 0{
            let vc = FoodsMsgDetailsVC()
            vc.sourceType = .logs
            vc.foodsDetailDict = foodsDict
            
            DLLog(message: "\(dict)")
            let qtyStr = dict.stringValueForKey(key: "qty")

            if qtyStr == "" || qtyStr.count == 0 || qtyStr == "0.0" || qtyStr == "0"{
                vc.specNum = dict.stringValueForKey(key: "weight")
                vc.specName = "g"
            }else{
                vc.specNum = dict.stringValueForKey(key: "qty")
                vc.specName = dict["spec"]as? String ?? "g"
            }
            
            if (dict.stringValueForKey(key: "state") != "1" && dict.stringValueForKey(key: "state") != "1.0"){
                vc.confirmButton.setTitle("用餐", for: .normal)
            }else{
                vc.confirmButton.setTitle("保存", for: .normal)
            }
            
            self.controller.navigationController?.pushViewController(vc, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                vc.deleteButton.isHidden = true
            })
//            vc.deleteButton.isHidden = true
        }else{
//            MCToast.mc_text("该食物已删除！",respond: .respond)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if foodsArray.count <= indexPath.row{
            return
        }
        if editingStyle == .delete{
//            DLLog(message: "tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)")
            let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
//            if self.deleteBlock != nil{
//                self.deleteBlock!(dict)
//            }
            TouchGenerator.shared.touchGenerator()
            if self.deleteCellBlock != nil{
                self.deleteCellBlock!(dict,indexPath.row)
            }
//            foodsArray.removeObject(at: indexPath.row)
//            self.tableView.reloadData()
//            self.deleteFoods(dict: dict)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        DLLog(message: "tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath)")
        return true//indexPath == deleteIndex ? true : false
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        if indexPath == deleteIndex{
//            return .delete
//        }
//        DLLog(message: "tableView(_ tableView: UITableView, editingStyleForRowAt")
        return .delete
    }
}
