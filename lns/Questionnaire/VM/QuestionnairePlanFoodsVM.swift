//
//  QuestionnairePlanFoodsVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/31.
//

import Foundation
import UIKit
import MCToast

class QuestionnairePlanFoodsVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var selectedIndex = -1
    
    var submitFoodsMsg = NSMutableArray()
    
    var selectedBlock:(()->())?
    var showTipsBlock:(()->())?
    
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "选择食物"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tipsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("为什么找不到我想要的食物？", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(showTipsAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
//        lab.text = "根据您的膳食习惯，在每个食物类别中选择\n1-7种食物，以满足您计划内的需求"
//        lab.text = "请在每个类别中选择1-7种食物，以便我们\n根据您的喜好和需求定制饮食计划"
        lab.text = "为了确保准确性，我们筛选掉了不符合计划的食物\n如需添加更多，请在激活计划后前往日志添加"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.textAlignment = .center
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: kFitWidth(164), width: SCREEN_WIDHT, height: self.selfHeight-kFitWidth(152)-kFitWidth(84)-WHUtils().getBottomSafeAreaHeight()), style: .grouped)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(QuestionnairePlanFoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionnairePlanFoodsTableViewCell")
        
        return vi
    }()
    lazy var coverView : UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "bottom_cover_img")
        
        return vi
    }()
    lazy var coverTopView : UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "bottom_cover_img")
        vi.transform = CGAffineTransform(scaleX: -1, y: -1)
        vi.isHidden = true
        
        return vi
    }()
    lazy var choiceFoodsAlertVm : QuestionnairePlanFoodsAlertVM = {
        let vm = QuestionnairePlanFoodsAlertVM.init(frame: .zero)
//        vm.changeFoodsBlock = {()in
//            self.dealFoodsMsg()
//        }
        vm.submitBlock = {()in
            self.dealFoodsMsg()
        }
        return vm
    }()
    lazy var foodsOneArray : NSMutableArray = {
        return [["name":"蛋白质","type":"1","foods":[]],
                ["name":"脂肪","type":"3","foods":[]],
                ["name":"碳水","type":"2","foods":[]]]
    }()
    lazy var foodsTwoArray : NSMutableArray = {
        return [["name":"蔬菜","type":"4","foods":[]],
                ["name":"水果","type":"5","foods":[]]]
    }()
}

extension QuestionnairePlanFoodsVM{
    @objc func showTipsAction(){
        if self.showTipsBlock != nil{
            self.showTipsBlock!()
        }
    }
}
extension QuestionnairePlanFoodsVM:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return foodsOneArray.count
        }else{
            return foodsTwoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnairePlanFoodsTableViewCell") as! QuestionnairePlanFoodsTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnairePlanFoodsTableViewCell", for: indexPath) as? QuestionnairePlanFoodsTableViewCell
        
        var dictTemp = NSDictionary()
        if indexPath.section == 0 {
            let dict = foodsOneArray[indexPath.row]as? NSDictionary ?? [:]
            cell?.updateUI(dict: dict)
            dictTemp = dict
        }else{
            let dict = foodsTwoArray[indexPath.row]as? NSDictionary ?? [:]
            cell?.updateUI(dict: dict)
            dictTemp = dict
        }
        
        cell?.addBlock = {()in
            self.choiceFoodsAlertVm.titleLabel.text = dictTemp["name"]as? String ?? ""
            self.choiceFoodsAlertVm.foodsType = dictTemp["type"]as? String ?? ""
            self.choiceFoodsAlertVm.foodsTypeName = dictTemp["name"]as? String ?? ""
            self.choiceFoodsAlertVm.judgeDataSource()
            self.choiceFoodsAlertVm.showAlertVM()
            if indexPath.section == 1{
                self.choiceFoodsAlertVm.typeVm.typeVm.setSelecteIndex(index: indexPath.row+4)
            }else{
                self.choiceFoodsAlertVm.typeVm.typeVm.setSelecteIndex(index: indexPath.row+1)
            }
        }
        
        return cell ?? QuestionnairePlanFoodsTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(40)))
        headView.backgroundColor = .clear
        
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(32), y: 0, width: kFitWidth(300), height: kFitWidth(40)))
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        headView.addSubview(lab)
        
        if section == 0 {
            lab.text = "必填项（每类不超过7种）："
        }else{
            lab.text = "选填项："
        }
        
        return headView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(40)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.coverTopView.isHidden = false
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 滑动已经结束且没有减速
            // 在这里进行相应的操作
            DLLog(message: "\(scrollView.contentOffset.y)")
            if scrollView.contentOffset.y > kFitWidth(40){
                self.coverTopView.isHidden = false
            }else{
                self.coverTopView.isHidden = true
            }
        }
    }
     
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        DLLog(message: "\(scrollView.contentOffset.y)")
        if scrollView.contentOffset.y > kFitWidth(40){
            self.coverTopView.isHidden = false
        }else{
            self.coverTopView.isHidden = true
        }
    }
}

extension QuestionnairePlanFoodsVM{
    func initUI() {
        addSubview(titleLabel)
//        addSubview(tipsLabel)
        addSubview(tipsButton)
        addSubview(tableView)
        addSubview(coverView)
        addSubview(coverTopView)
        
        UIApplication.shared.keyWindow?.addSubview(choiceFoodsAlertVm)
        
        setConstrait()
        
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(40))
        }
        
        tipsButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(82))
            make.height.equalTo(kFitWidth(26))
        }
//        tipsLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(88))
//        }
        coverView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.top.equalTo(tableView.snp.bottom).offset(kFitWidth(-40))
        }
        coverTopView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.top.equalTo(self.tableView)
        }
    }
}

extension QuestionnairePlanFoodsVM{
    func dealFoodsMsg() {
        submitFoodsMsg.removeAllObjects()
        for i in 0..<foodsOneArray.count{
            let foodsOneDict = foodsOneArray[i]as? NSDictionary ?? [:]
            let foodTempArr = NSMutableArray()
            for j in 0..<choiceFoodsAlertVm.foodsSelectedArray.count{
                let selectDict = choiceFoodsAlertVm.foodsSelectedArray[j]as? NSDictionary ?? [:]
                if selectDict.stringValueForKey(key: "ftype") == foodsOneDict.stringValueForKey(key: "type"){
                    foodTempArr.add(selectDict)
                    self.getSubmitFoodsMsg(dict: selectDict)
                }
            }
            let foodsDict = ["type":foodsOneDict.stringValueForKey(key: "type"),
                             "name":foodsOneDict.stringValueForKey(key: "name"),
                             "foods":foodTempArr] as [String : Any]
            foodsOneArray.replaceObject(at: i, with: foodsDict)
        }
        for i in 0..<foodsTwoArray.count{
            let foodsOneDict = foodsTwoArray[i]as? NSDictionary ?? [:]
            let foodTempArr = NSMutableArray()
            for j in 0..<choiceFoodsAlertVm.foodsSelectedArray.count{
                let selectDict = choiceFoodsAlertVm.foodsSelectedArray[j]as? NSDictionary ?? [:]
                if selectDict.stringValueForKey(key: "ftype") == foodsOneDict.stringValueForKey(key: "type"){
                    foodTempArr.add(selectDict)
                    self.getSubmitFoodsMsg(dict: selectDict)
                }
            }
            let foodsDict = ["type":foodsOneDict.stringValueForKey(key: "type"),
                             "name":foodsOneDict.stringValueForKey(key: "name"),
                             "foods":foodTempArr] as [String : Any]
            foodsTwoArray.replaceObject(at: i, with: foodsDict)
        }
        self.tableView.reloadData()
    }
    func getSubmitMsgForModel(){
        QuestinonaireMsgModel.shared.dealFoodsMsg(dataArr: submitFoodsMsg)
        QuestinonaireMsgModel.shared.printModelMsg()
    }
    func getSubmitFoodsMsg(dict:NSDictionary) {
        if dict["select"]as? String ?? "" == "1"{
            submitFoodsMsg.add(["type":"\(dict.stringValueForKey(key: "ftype"))","fname":"\(dict["fname"]as? String ?? "")","fid":"\(dict.stringValueForKey(key: "fid"))"])
        }
    }
    func checkValue() -> Bool {
        for i in 0..<foodsOneArray.count{
            let dict = foodsOneArray[i]as? NSDictionary ?? [:]
            let foodsArr = dict["foods"]as? NSArray ?? []
            
            if foodsArr.count < 1{
                MCToast.mc_text("请选择\(dict["name"]as? String ?? "")食物",respond: .allow)
                return false
            }else if foodsArr.count > 7{
                MCToast.mc_text("\(dict["name"]as? String ?? "")食物不能超过7种",respond: .allow)
                return false
            }
        }
        
        return true
    }
}
