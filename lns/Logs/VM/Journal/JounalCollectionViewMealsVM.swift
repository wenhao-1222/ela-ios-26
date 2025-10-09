//
//  JounalCollectionViewMealsVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/10.
//

import Foundation
import UIKit

class JounalCollectionViewMealsVM: UIView {
    
    var selfHeight = kFitWidth(78)
    var controller = WHBaseViewVC()
    var foodsArray = NSMutableArray()
    var calculatBlock:((NSDictionary)->())?
    var isEdit = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.size.height
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(8), width: kFitWidth(359), height: kFitWidth(70)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(8)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.text = "第 1 餐"
        return lab
    }()
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "logs_add_icon_theme"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        return btn
    }()
    lazy var noFoodsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "请添加食物"
        return lab
    }()
    lazy var naturalVm : LogsMealsNaturalMsgVM = {
        let vm = LogsMealsNaturalMsgVM.init(frame: CGRect.init(x: 0, y: kFitWidth(59), width: 0, height: 0))
        vm.isHidden = true
        return vm
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        table.separatorStyle = .none
        table.register(PlanCreateFoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanCreateFoodsTableViewCell")
        table.delegate = self
        table.dataSource = self
        return table
    }()
}

extension JounalCollectionViewMealsVM{
    func refreshUI(array:NSArray) {
        if array.count > 0 {
            tableView.isHidden = false
            naturalVm.isHidden = false
            noFoodsLabel.isHidden = true
            foodsArray = NSMutableArray(array: array)
            
            self.whiteView.frame = CGRect.init(x: kFitWidth(8), y: kFitWidth(8), width: kFitWidth(359), height: kFitWidth(159)+CGFloat(foodsArray.count)*kFitWidth(55))
            self.tableView.frame = CGRect.init(x: 0, y: kFitWidth(149), width: kFitWidth(359), height: CGFloat(foodsArray.count)*kFitWidth(55))
            tableView.reloadData()
            
            self.selfHeight = kFitWidth(159)+CGFloat(foodsArray.count)*kFitWidth(55) + kFitWidth(8)
        }else{
            tableView.isHidden = true
            naturalVm.isHidden = true
            noFoodsLabel.isHidden = false
        }
        
    }
}

extension JounalCollectionViewMealsVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(addButton)
        whiteView.addSubview(noFoodsLabel)
        
        whiteView.addSubview(naturalVm)
        whiteView.addSubview(tableView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        addButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(kFitWidth(52))
            make.height.equalTo(kFitWidth(50))
        }
        noFoodsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(42))
        }
    }
}

extension JounalCollectionViewMealsVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell")as? PlanCreateFoodsTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell", for: indexPath) as? PlanCreateFoodsTableViewCell
        
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUIForLogs(dict: dict,isEdit:self.isEdit)
        
        cell?.selectTapBlock = {(isSelec)in
//            if self.selectCellBlock != nil{
//                self.selectCellBlock!(isSelec,indexPath.row)
//            }
        }
        cell?.delTapBlock = {()in
//            self.deleteIndex = indexPath
//            self.tableView.setEditing(true, animated: true)
        }
        
        return cell ?? PlanCreateFoodsTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(55)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            return
        }
        
//        if self.selectMeaslIndexBlock != nil{
//            self.selectMeaslIndexBlock!()
//        }
        
        let vc = FoodsMsgVC()
        vc.foodsMsgDict = dict
        if dict["fid"]as? Int ?? -1 > 0 {
            vc.fid = dict["fid"]as? Int ?? -1
        }else{
            vc.fid = Int(dict["fid"]as? String ?? "-1") ?? -1
        }
        
        vc.isFromPlanCreate = false
        vc.isFromLogs = true
//        vc.confirmButton.setTitle("保存", for: .normal)
        self.controller.navigationController?.pushViewController(vc, animated: true)
        vc.selectBlock = {(dict)in
            self.foodsArray.replaceObject(at: indexPath.row, with: dict)
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
//            if self.deleteBlock != nil{
//                self.deleteBlock!(dict)
//            }
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true//indexPath == deleteIndex ? true : false
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        if indexPath == deleteIndex{
//            return .delete
//        }
        return .delete
    }
}
