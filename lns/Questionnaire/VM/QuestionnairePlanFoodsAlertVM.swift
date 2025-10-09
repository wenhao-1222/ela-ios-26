//
//  QuestionnairePlanFoodsAlertVM.swift
//  lns
//seach_icon
//  Created by LNS2 on 2024/3/31.
//

import Foundation
import UIKit
import Charts
import MCToast

class QuestionnairePlanFoodsAlertVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()
    
    var foodsType = "1"
    var foodsTypeName = "蛋白质"
    var foodsName = ""
    
    var dataSourceArray = NSMutableArray()
    var dataDictShow = NSMutableDictionary()
    
    var foodsSelectedArray = NSMutableArray()//存储所有已选择的食物
    
    var changeFoodsBlock:(()->())?
    var submitBlock:(()->())?
    
    var whiteViewOriginY = WHUtils().getNavigationBarHeight()
    
    var controller = WHBaseViewVC()
    /// work item used to delay showing loading toast
    private var loadingWorkItem: DispatchWorkItem?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.0)
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
//        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
//        v.addGestureRecognizer(tap)
        return v
    }()
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
    lazy var closeImgView : FeedBackUIImageView = {
        let img = FeedBackUIImageView()
        img.setImgLocal(imgName: "question_alert_close_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenAlertVm))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var closeTapView : FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenAlertVm))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var submitBtn : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("提交", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
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
    lazy var typeTapView : FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(typeChangeAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var searchVm : QuestionnairePlanFoodsSearchVM = {
        let vm = QuestionnairePlanFoodsSearchVM.init(frame: CGRect.init(x: 0, y: kFitWidth(68), width: 0, height: 0))
        vm.searchBlock = {()in
            self.foodsName = (self.searchVm.textField.text ?? "").disable_emoji(text: (self.searchVm.textField.text ?? "") as NSString)
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
            self.foodsTypeName = "蛋白质"
            self.foodsType = "1"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 1)
        }
        vm.typeVm.itemTwoVm.tapBlock = {()in
            self.titleLabel.text = "脂肪"
            self.foodsTypeName = "脂肪"
            self.searchVm.textField.text = ""
            self.foodsName = ""
            self.foodsType = "3"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 2)
        }
        vm.typeVm.itemThreeVm.tapBlock = {()in
            self.titleLabel.text = "碳水"
            self.foodsTypeName = "碳水"
            self.searchVm.textField.text = ""
            self.foodsName = ""
            self.foodsType = "2"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 3)
        }
        vm.typeVm.itemFourVm.tapBlock = {()in
            self.titleLabel.text = "蔬菜"
            self.foodsTypeName = "蔬菜"
            self.searchVm.textField.text = ""
            self.foodsName = ""
            self.foodsType = "4"
            self.typeVm.hiddenSelf()
            self.sendFoodsDataRequest()
            self.typeVm.typeVm.setSelecteIndex(index: 4)
        }
        vm.typeVm.itemFiveVm.tapBlock = {()in
            self.titleLabel.text = "水果"
            self.foodsTypeName = "水果"
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

extension QuestionnairePlanFoodsAlertVM{
    @objc func nothingToDo(){
        
    }
    @objc func typeChangeAction(){
        self.typeVm.showSelf()
    }
    @objc func submitAction() {
//        if self.submitBlock != nil{
//            self.submitBlock!()
//        }
        hiddenAlertVm()
    }
    
    @objc func showAlertVM() {
        bgView.alpha = 0
        
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5-kFitWidth(2))
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut) {
            self.bgView.alpha = 0.1
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        }
    }
    @objc func hiddenAlertVm() {
        self.searchVm.textField.resignFirstResponder()
        if self.submitBlock != nil{
            self.submitBlock!()
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
            self.bgView.alpha = 0
        }completion: { t in
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
            self.whiteView.frame = CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
    }
    func judgeDataSource(){
        self.searchVm.textField.text = ""
        self.foodsName = ""
        
        let dict = ["foodsType":"\(self.foodsType)",
                    "foodsName":"\(self.foodsTypeName)",
                    "foodsArray":[]] as [String : Any]
        self.dataDictShow = NSMutableDictionary.init(dictionary: dict)
        self.tableView.reloadData()
        sendFoodsDataRequest()
    }
    //储存所有已选择的食物
    func dealSelectedData(dictSender:NSDictionary) {
        for i in 0..<foodsSelectedArray.count{
            let dictTemp = foodsSelectedArray[i]as? NSDictionary ?? [:]
            if dictTemp.stringValueForKey(key: "fid") == dictSender.stringValueForKey(key: "fid") {
                if dictSender.stringValueForKey(key: "select") == "1"{
                    foodsSelectedArray.replaceObject(at: i, with: dictSender)
                }else{
                    foodsSelectedArray.remove(dictTemp)
                }
                return
            }
        }
        if dictSender.stringValueForKey(key: "select") == "1"{
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
                DLLog(message: "translation.y:\(translation.y)")
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
    func judgeSelectNum() -> Bool {
        var number = 0
        for i in 0..<foodsSelectedArray.count{
            let dict = foodsSelectedArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "ftype") == self.foodsType{
                number = number + 1
            }
        }
        
        if number >= 7 {
            return false
        }
        return true
    }
}

extension QuestionnairePlanFoodsAlertVM{
    func initUI() {
        addSubview(bgView)
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

extension QuestionnairePlanFoodsAlertVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = self.dataDictShow["foodsArray"]as? NSArray ?? []
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnairePlanFoodsAlertTableViewCell") as! QuestionnairePlanFoodsAlertTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnairePlanFoodsAlertTableViewCell", for: indexPath) as? QuestionnairePlanFoodsAlertTableViewCell
        
        let array = self.dataDictShow["foodsArray"]as? NSMutableArray ?? []
        let dict = array[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict, selecFoodsArray: self.foodsSelectedArray)
        cell?.choiceBlock = {()in
            self.searchVm.textField.resignFirstResponder()
            let dictTemp = NSMutableDictionary.init(dictionary: dict)
            if dictTemp["select"]as? String ?? "" == "1"{
                dictTemp.setValue("0", forKey: "select")
            }else{
                if self.judgeSelectNum() == true{
                    dictTemp.setValue("1", forKey: "select")
                }else{
                    MCToast.mc_text("\"\(self.foodsTypeName)\"食物种类不超过7种",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
                    return
                }
            }
            array.replaceObject(at: indexPath.row, with: dictTemp)
            self.dealSelectedData(dictSender: dictTemp)
            self.dataDictShow.setValue(array, forKey: "foodsArray")
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
        return cell ?? QuestionnairePlanFoodsAlertTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(84)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let array = self.dataDictShow["foodsArray"]as? NSMutableArray ?? []
        let dict = array[indexPath.row]as? NSDictionary ?? [:]
        self.foodsDetailVm.showView(dict: dict)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchVm.textField.resignFirstResponder()
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
        DLLog(message: "\(scrollView.contentOffset.y)")
        if scrollView.contentOffset.y > kFitWidth(40){
            self.coverTopView.isHidden = false
        }else{
            self.coverTopView.isHidden = true
        }
    }
}

extension QuestionnairePlanFoodsAlertVM{
    func sendFoodsDataRequest() {
//        MCToast.mc_loading()
        // Cancel any previous delayed task
        loadingWorkItem?.cancel()

        // Delay showing loading toast by 1 second
        let workItem = DispatchWorkItem {
            MCToast.mc_loading()
        }
        loadingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)

        
        let param = ["fname":foodsName,
                     "ftype":foodsType]
        self.tableView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
        
        UserInfoModel.shared.postNum = 3
        UserInfoModel.shared.failToastNum = 0
        
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            // Cancel loading toast display if not shown yet and remove if shown
            self.loadingWorkItem?.cancel()
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            let dataArray = NSMutableArray()
            
//            let foodsDict = responseObject["data"]as? NSDictionary ?? [:]
            let bestArray = foodsDict["best"]as? NSArray ?? []
            let moreArray = foodsDict["more"]as? NSArray ?? []
            
            dataArray.addObjects(from: bestArray as! [Any])
            dataArray.addObjects(from: moreArray as! [Any])
            
            self.dealQueryFoodsIsSelect(foodsArr: dataArray)
        }
    }
    func dealQueryFoodsIsSelect(foodsArr:NSArray) {
        let dataArrayTemp = NSMutableArray.init(array: foodsArr)
        
        for i in 0..<dataArrayTemp.count{
            let dictTemp = dataArrayTemp[i]as? NSDictionary ?? [:]
            for j in 0..<foodsSelectedArray.count{
                let dictS = foodsSelectedArray[j]as? NSDictionary ?? [:]
                if dictTemp.stringValueForKey(key: "fid") == dictS.stringValueForKey(key: "fid"){
                    dataArrayTemp.replaceObject(at: i, with: dictS)
                    continue
                }
            }
        }
        
        let dict = ["foodsType":"\(self.foodsType)",
                    "foodsName":"\(self.foodsTypeName)",
                    "foodsArray":dataArrayTemp] as [String : Any]
        self.dataDictShow = NSMutableDictionary.init(dictionary: dict)
//        self.dataSourceArray.add(self.dataDictShow)
        self.tableView.reloadData()
    }
}
