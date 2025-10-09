//
//  PlanCreateFoodsAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/15.
//

import Foundation
import UIKit
import Charts
import MCToast

class PlanCreateFoodsAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    var selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()
    
    var foodsType = "1"
    var foodsName = ""
    
    var dataSourceArray = NSMutableArray()
    var dataDictShow = NSMutableDictionary()
    
    var foodsSelectedArray = NSMutableArray()//存储所有已选择的食物
    
    var changeFoodsBlock:(()->())?
    var submitBlock:(()->())?
    
    var whiteViewOriginY = WHUtils().getNavigationBarHeight()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.0)
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var topTapViewForHidden : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenAlertVm))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(16)
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
//        vi.addGestureRecognizer(tap)
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        return vi
    }()
    lazy var closeImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_alert_close_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenAlertVm))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var closeTapView : UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenAlertVm))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var submitBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("提交", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var arrowImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_alert_arrow_down_icon")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var typeTapView : UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(typeChangeAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var searchVm : QuestionnairePlanFoodsSearchVM = {
        let vm = QuestionnairePlanFoodsSearchVM.init(frame: CGRect.init(x: 0, y: kFitWidth(68), width: 0, height: 0))
        vm.searchBlock = {()in
            self.foodsName = self.searchVm.textField.text ?? ""
            self.sendFoodsDataRequest()
        }
        return vm
    }()
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: kFitWidth(140), width: SCREEN_WIDHT, height: self.selfHeight-kFitWidth(140)), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(QuestionnairePlanFoodsAlertTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionnairePlanFoodsAlertTableViewCell")
        
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
    lazy var typeVm : QuestionnairePlanFoodsTypeAlertVM = {
        let vm = QuestionnairePlanFoodsTypeAlertVM.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(0), width: 0, height: 0))
        vm.isHidden = true
        vm.typeVm.itemOneVm.tapBlock = {()in
            self.titleLabel.text = "蛋白质"
            self.searchVm.textField.text = ""
            self.foodsName = ""
            self.foodsType = "1"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 1)
        }
        vm.typeVm.itemTwoVm.tapBlock = {()in
            self.titleLabel.text = "脂肪"
            self.searchVm.textField.text = ""
            self.foodsName = ""
            self.foodsType = "3"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 2)
        }
        vm.typeVm.itemThreeVm.tapBlock = {()in
            self.titleLabel.text = "碳水"
            self.searchVm.textField.text = ""
            self.foodsName = ""
            self.foodsType = "2"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 3)
        }
        vm.typeVm.itemFourVm.tapBlock = {()in
            self.titleLabel.text = "蔬菜"
            self.searchVm.textField.text = ""
            self.foodsName = ""
            self.foodsType = "4"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 4)
        }
        vm.typeVm.itemFiveVm.tapBlock = {()in
            self.titleLabel.text = "水果"
            self.searchVm.textField.text = ""
            self.foodsName = ""
            self.foodsType = "5"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 5)
        }
        return vm
    }()
    lazy var foodsDetailVm : QuestionnairePlanFoodsDetailAlertVM = {
        let vm = QuestionnairePlanFoodsDetailAlertVM.init(frame: .zero)
        vm.isHidden = true
        return vm
    }()
}

extension PlanCreateFoodsAlertVM{
    @objc func nothingToDo(){
        
    }
    @objc func typeChangeAction(){
        self.typeVm.showSelf()
    }
    @objc func submitAction() {
        if self.submitBlock != nil{
            self.submitBlock!()
        }
        hiddenAlertVm()
    }
    
    @objc func showAlertVM() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        }completion: { t in
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }
    }
    @objc func hiddenAlertVm() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        }completion: { t in
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
            self.whiteView.frame = CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
    }
    func judgeDataSource(){
//        for i in 0..<self.dataSourceArray.count{
//            let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
//            if dict["foodsType"]as? String ?? "" == self.foodsType{
//                //之前请求过此类食物的数据，不能再次请求，因为已经有选择状态
//                dataDictShow = NSMutableDictionary.init(dictionary: dict)
//                tableView.reloadData()
//                return
//            }
//        }
        sendFoodsDataRequest()
    }
    func dealFoodsDataSource() {
        for i in 0..<self.dataSourceArray.count{
            let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
            if dict["foodsType"]as? String ?? "" == self.foodsType{
                self.dataSourceArray.replaceObject(at: i, with: dataDictShow)
            }
        }
//        if self.changeFoodsBlock != nil{
//            self.changeFoodsBlock!()
//        }
    }
    func deleteFoods(foodsDict:NSDictionary) {
        for i in 0..<self.foodsSelectedArray.count{
            let dict = self.foodsSelectedArray[i]as? NSDictionary ?? [:]
            if dict["fid"]as? String ?? "" == foodsDict["fid"]as? String ?? "" && dict["specName"]as? String ?? "" == foodsDict["specName"]as? String ?? ""{
                foodsSelectedArray.removeObject(at: i)
                break
            }
        }
        if self.submitBlock != nil{
            self.submitBlock!()
        }
    }
    //已选择的食物，添加了一种新的规格
    func addNewSpecFoods(dict:NSDictionary) {
        foodsSelectedArray.add(dict)
        if self.submitBlock != nil{
            self.submitBlock!()
        }
    }
    //储存所有已选择的食物
    func dealSelectedData(dictSender:NSDictionary) {
        for i in 0..<foodsSelectedArray.count{
            let dictTemp = foodsSelectedArray[i]as? NSDictionary ?? [:]
            if dictTemp["fid"]as? String ?? "" == dictSender["fid"]as? String ?? "" && dictTemp["specName"]as? String ?? "" == dictSender["specName"]as? String ?? "" {
                if dictSender["select"]as? String ?? "" == "1"{
                    foodsSelectedArray.replaceObject(at: i, with: dictSender)
                }else{
                    foodsSelectedArray.remove(dictTemp)
                }
                return
            }
        }
        if dictSender["select"]as? String ?? "" == "1"{
            foodsSelectedArray.add(dictSender)
        }
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: view)
//                DLLog(message: "translation.y:\(translation.y)")
                if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                    self.hiddenAlertVm()
                }else{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+SCREEN_HEIGHT*0.5)
                    }
                }
            default:
                break
            }
        }
    }
}

extension PlanCreateFoodsAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(closeImgView)
        whiteView.addSubview(submitBtn)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(arrowImgView)
        whiteView.addSubview(closeTapView)
        whiteView.addSubview(typeTapView)
        
        whiteView.addSubview(searchVm)
        whiteView.addSubview(tableView)
        whiteView.addSubview(coverView)
        whiteView.addSubview(coverTopView)
        
        whiteView.addSubview(typeVm)
        
        addSubview(topTapViewForHidden)
        
        addSubview(foodsDetailVm)
        
        setConstrait()
    }
    
    func setConstrait() {
        topTapViewForHidden.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(WHUtils().getNavigationBarHeight())
        }
        closeImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(16))
        }
        submitBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
            make.width.equalTo(kFitWidth(60))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(closeImgView)
        }
        arrowImgView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        closeTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(closeImgView)
            make.width.height.equalTo(kFitWidth(30))
        }
        typeTapView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(arrowImgView)
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(44))
        }
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

extension PlanCreateFoodsAlertVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = self.dataDictShow["foodsArray"]as? NSArray ?? []
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnairePlanFoodsAlertTableViewCell") as? QuestionnairePlanFoodsAlertTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnairePlanFoodsAlertTableViewCell", for: indexPath) as? QuestionnairePlanFoodsAlertTableViewCell
        
        let array = self.dataDictShow["foodsArray"]as? NSMutableArray ?? []
        let dict = array[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict, selecFoodsArray: self.foodsSelectedArray)
        cell?.selectedImgView.isHidden = true
        cell?.selectTapView.isHidden = true
        cell?.choiceBlock = {()in
            let dictTemp = NSMutableDictionary.init(dictionary: dict)
            if dictTemp["select"]as? String ?? "" == "1"{
                dictTemp.setValue("0", forKey: "select")
            }else{
                dictTemp.setValue("1", forKey: "select")
            }
            array.replaceObject(at: indexPath.row, with: dictTemp)
            self.dataDictShow.setValue(array, forKey: "foodsArray")
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            self.dealFoodsDataSource()
            self.dealSelectedData(dictSender: dictTemp)
//            DLLog(message: "foodsSelectedArray:\(self.foodsSelectedArray)")
        }
        return cell ?? QuestionnairePlanFoodsAlertTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(84)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let array = self.dataDictShow["foodsArray"]as? NSMutableArray ?? []
        let dict = array[indexPath.row]as? NSDictionary ?? [:]
        
//        self.foodsDetailVm.showView(dict: dict)
        let vc = FoodsDetailVC()
        vc.foodsMsgDict = dict
        vc.fid = Int(dict["fid"]as? String ?? "-1") ?? -1
        self.controller.navigationController?.pushViewController(vc, animated: true)
        vc.selectBlock = {(dict)in
            let array = self.dataDictShow["foodsArray"]as? NSMutableArray ?? []
            array.replaceObject(at: indexPath.row, with: dict)
            self.dataDictShow.setValue(array, forKey: "foodsArray")
//            self.tableView.reloadRows(at: [indexPath], with: .fade)
            self.dealFoodsDataSource()
            self.dealSelectedData(dictSender: dict)
            if self.submitBlock != nil{
                self.submitBlock!()
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.coverTopView.isHidden = false
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 滑动已经结束且没有减速
            // 在这里进行相应的操作
//            DLLog(message: "\(scrollView.contentOffset.y)")
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

extension PlanCreateFoodsAlertVM{
    func sendFoodsDataRequest() {
        MCToast.mc_loading()
        let param = ["fname":foodsName,
                     "ftype":foodsType]
        UserInfoModel.shared.postNum = 3
        UserInfoModel.shared.failToastNum = 0
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list, parameters: param as [String:AnyObject]) { responseObject in
//            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
//            let dataArr = responseObject["data"]as? NSArray ?? []
            self.dealQueryFoodsIsSelect(foodsArr: dataArr)
            
        }
    }
    func dealQueryFoodsIsSelect(foodsArr:NSArray) {
        let dataArrayTemp = NSMutableArray.init(array: foodsArr)
//        DLLog(message: "请求回来的数据：\(dataArrayTemp)")
//        DLLog(message: "已选择的数据：\(foodsSelectedArray)")
        
        for i in 0..<dataArrayTemp.count{
            let dictTemp = dataArrayTemp[i]as? NSDictionary ?? [:]
            for j in 0..<foodsSelectedArray.count{
                let dictS = foodsSelectedArray[j]as? NSDictionary ?? [:]
                if dictTemp["fid"]as? String ?? "" == dictS["fid"]as? String ?? ""{
                    let dictR = NSMutableDictionary.init(dictionary: dictTemp)
                    dictR.setValue("1", forKey: "select")
                    dataArrayTemp.replaceObject(at: i, with: dictR)
                    continue
                }
            }
        }
        
        let dict = ["foodsType":"\(self.foodsType)",
                    "foodsName":"\(self.foodsName)",
                    "foodsArray":dataArrayTemp] as [String : Any]
        self.dataDictShow = NSMutableDictionary.init(dictionary: dict)
        self.dataSourceArray.add(self.dataDictShow)
        self.tableView.reloadData()
    }
}

