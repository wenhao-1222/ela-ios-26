//
//  BodyDataDetailVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/17.
//

import Foundation
import DGCharts
import MCToast
//import ShowBigImg

enum DATA_TYPE {
    case weight
    case hips
    case waistline
    case arm
    case shoulder
    case bust
    case thigh
    case calf
    case bfp
}

class BodyDataDetailVC : WHBaseViewVC {
    
    var dataSourceArray = NSArray()
    var dataType = DATA_TYPE.weight
    
    let weightDataArray = NSMutableArray()
    let yaoDataArray = NSMutableArray()
    let hipsDataArray = NSMutableArray()
    let armDataArray = NSMutableArray()
    let shoulderDataArray = NSMutableArray()
    let bustDataArray = NSMutableArray()
    let thighDataArray = NSMutableArray()
    let calfDataArray = NSMutableArray()
    let bfpDataArray = NSMutableArray()
    
    /// Indicates whether to pop directly to overview when returning
    var popToOverview = false

    var showDataArray = NSArray()
    var showTypeString = "weight"
    var showDayaUnit = "kg"
    var showColor = "008858"
    
    var timeType = "5"//2025年08月18日11:19:40   改为默认3个月的数据
    var lineChartView = LineChartView()
    
    var offsetX = CGFloat(0)
    
    var allDataArray = NSMutableArray()
    
    /// Flag used to avoid refreshing when the interactive pop gesture is cancelled
    private var cancelInteractivePop = false
    
    override func viewWillAppear(_ animated: Bool) {
//        sendBodyStatRequest()
        
        guard !cancelInteractivePop else {
            cancelInteractivePop = false
            return
        }
        changeTimeType()
        getAllImagesDataSource()
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let coordinator = transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { [weak self] context in
                if context.isCancelled {
                    self?.cancelInteractivePop = true
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is DataAddVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    lazy var shareButton : GJVerButton = {
        let button = GJVerButton()
        button.setImage(UIImage(named: "plan_detail_share_icon"), for: .normal)
        button.setTitle("分享", for: .normal)
        button.setTitleColor(.THEME, for: .normal)
//        button.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.enablePressEffect()
        
        button.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        return button
    }()
    lazy var topVm : DataDetailTopVM = {
        let vm = DataDetailTopVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        vm.typeBlock = {()in
            self.typeFilterAlertVm.showView()
        }
        vm.timeBlock = {()in
            self.timeTypeAlertVm.showView()
        }
        vm.addBlock = {()in
//            TouchGenerator.shared.touchGeneratorMedium()
            let vc = DataAddVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var lineWhiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY, width: SCREEN_WIDHT, height: kFitWidth(205)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var headView : DataDetailTableHeadVM = {
        let vi = DataDetailTableHeadVM.init(frame: CGRect.init(x: 0, y: self.lineWhiteView.frame.maxY, width: SCREEN_WIDHT, height: 0))
        vi.scrollBlock = {(offsetX)in
            self.offsetX = offsetX
            self.scrollTableViewHor()
        }
        return vi
    }()
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: self.headView.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.headView.frame.maxY), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(DataDetailTableViewCell.classForCoder(), forCellReuseIdentifier: "DataDetailTableViewCell")
        table.separatorStyle = .none
//        table.isEditing = true
        
        return table
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()
    lazy var typeFilterAlertVm : DataDetailTypeFilterAlertVM = {
        let vm = DataDetailTypeFilterAlertVM.init(frame: .zero)
        vm.choiceBlock = {(dict)in
            self.dataType = dict["type"]as? DATA_TYPE ?? .weight
            self.changeType()
        }
        return vm
    }()
    lazy var timeTypeAlertVm: DataDetailTimeTypeFilterAlertVM = {
        let vm = DataDetailTimeTypeFilterAlertVM.init(frame: .zero)
        vm.setSelectIndex(index: 4)
        vm.choiceBlock = {(dict)in
            self.timeType = dict["qtype"]as? String ?? ""
            self.topVm.timeButton.setTitle(dict["name"]as? String ?? "", for: .normal)
            
            self.changeTimeType()
        }
        return vm
    }()
    lazy var timeFilterAlertVm : DataDetailTimeFilterAlertVM = {
        let vm = DataDetailTimeFilterAlertVM.init(frame: .zero)
        vm.confirmBlock = {(dict)in
            self.timeType = dict["qtype"]as? String ?? ""
            self.topVm.timeButton.setTitle(dict["name"]as? String ?? "", for: .normal)
//            self.sendBodyStatRequest()
            
            self.changeTimeType()
//            queryDaya
        }
        return vm
    }()
}

extension BodyDataDetailVC{
    func changeTimeType() {
        var dataArr = NSArray()
        if self.timeType == "0"{
            dataArr = BodyDataSQLiteManager.getInstance().queryData(type: .all)
        }else if self.timeType == "1"{
            dataArr = BodyDataSQLiteManager.getInstance().queryData(type: .week)
        }else if self.timeType == "3"{
            dataArr = BodyDataSQLiteManager.getInstance().queryData(type: .moneth)
        }else if self.timeType == "4"{
            dataArr = BodyDataSQLiteManager.getInstance().queryData(type: .two_moneth)
        }else if self.timeType == "5"{
            dataArr = BodyDataSQLiteManager.getInstance().queryData(type: .three_moneth)
        }else if self.timeType == "6"{
            dataArr = BodyDataSQLiteManager.getInstance().queryData(type: .six_moneth)
        }else if self.timeType == "7"{
            dataArr = BodyDataSQLiteManager.getInstance().queryData(type: .one_year)
        }
        dataArr = dataArr.reversed() as NSArray
        if dataArr.count == 0 {
            sendBodyStatRequest()
        }else{
            self.dealBodyStatData(dataArray: dataArr)
        }
        DLLog(message: "BodyDataSQLiteManager:\(dataArr)")
    }
    @objc func shareAction() {
        let vc = BodyDataDetailShareVC()
        vc.dataTypeName = topVm.bodyTypeButton.titleLabel?.text ?? "体重"
        vc.unitString = showDayaUnit
        vc.dataArray = self.showDataArray
        vc.showTypeString = self.showTypeString
//        vc.showColor = self.showColor
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func changeType() {
        switch dataType {
        case .weight:
            showTypeString = "weight"
            showDataArray = weightDataArray
            showDayaUnit = "\(UserInfoModel.shared.weightUnitName)"
//            showDayaUnit = "kg"
//            showColor = "008858"
            showColor = "00B853"
//            topVm.bodyTypeButton.setTitle("体重", for: .normal)
            topVm.updateTypeButton(type: "体重")
        case .waistline:
            showTypeString = "waistline"
            showDataArray = yaoDataArray
            showDayaUnit = "cm"
//            showColor = "F5BA18"
            showColor = "FFDB25"
//            topVm.bodyTypeButton.setTitle("腰围", for: .normal)
            topVm.updateTypeButton(type: "腰围")
        case .hips:
            showTypeString = "hips"
            showDataArray = hipsDataArray
            showDayaUnit = "cm"
//            showColor = "029CD4"
            showColor = "3897FF"
//            topVm.bodyTypeButton.setTitle("臀围", for: .normal)
            topVm.updateTypeButton(type: "臀围")
        case .arm:
            showTypeString = "armcircumference"
            showDataArray = armDataArray
            showDayaUnit = "cm"
            showColor = "C43695"
//            topVm.bodyTypeButton.setTitle("臂围", for: .normal)
            topVm.updateTypeButton(type: "手臂")
        case .shoulder:
            showTypeString = "shoulder"
            showDataArray = shoulderDataArray
            showDayaUnit = "cm"
            showColor = "96CDCD"
//            topVm.bodyTypeButton.setTitle("肩宽", for: .normal)
            topVm.updateTypeButton(type: "肩宽")
        case .bust:
            showTypeString = "bust"
            showDataArray = bustDataArray
            showDayaUnit = "cm"
            showColor = "FF6A6A"
//            topVm.bodyTypeButton.setTitle("胸围", for: .normal)
            topVm.updateTypeButton(type: "胸围")
        case .thigh:
            showTypeString = "thigh"
            showDataArray = thighDataArray
            showDayaUnit = "cm"
            showColor = "E066FF"
//            topVm.bodyTypeButton.setTitle("大腿围", for: .normal)
            topVm.updateTypeButton(type: "大腿围")
        case .calf:
            showTypeString = "calf"
            showDataArray = calfDataArray
            showDayaUnit = "cm"
            showColor = "FFBBFF"
//            topVm.bodyTypeButton.setTitle("小腿围", for: .normal)
            topVm.updateTypeButton(type: "小腿围")
        case .bfp:
            showTypeString = "bfp"
            showDataArray = bfpDataArray
            showDayaUnit = "%"
            showColor = "FFBBFF"
//            topVm.bodyTypeButton.setTitle("小腿围", for: .normal)
            topVm.updateTypeButton(type: "体脂率")
        }
        setDataArray()
    }
    func getAllImagesDataSource() {
        let array = BodyDataSQLiteManager.getInstance().queryData(type: .all)
        
        if array.count == 0 {
            sendAllBodyDataRequest()
        }else{
            dealImageDataSourceArray(array: array)
        }
    }
    func dealImageDataSourceArray(array:NSArray){
        self.allDataArray.removeAllObjects()
        for i in 0..<array.count{
            let dict = array[i]as? NSDictionary ?? [:]
            let imgArr = dict["image"]as? NSArray ?? []
            var imagesString = dict["image"]as? String ?? "\(dict.stringValueForKey(key: "images"))"
            if imgArr.count > 0 {
                imagesString = self.getJSONStringFromArray(array: imgArr)
            }
            
            let imageArr = self.getArrayFromJSONString(jsonString: imagesString)
            
            let imageArray = self.dealImgArray(array: imageArr)
            
            var hasImage = false
            var imgsArr:[String] = [String]()
            var imgsAliasArr:[String] = imageArray.count > 0 ? [String]() : ["角度一","角度二","角度三"]
            for j in 0..<imageArray.count{
                let imgdict = imageArray[j]as? NSDictionary ?? [:]
                if imgdict.stringValueForKey(key: "url").count > 2{
                    hasImage = true
                    imgsArr.append(imgdict.stringValueForKey(key: "url"))
                }else{
                    imgsArr.append("")
                }
                
                if j == 0 {
                    imgsAliasArr.append(imgdict.stringValueForKey(key: "alias").count > 0 ? imgdict.stringValueForKey(key: "alias") : "角度一")
                }else if j == 1{
                    imgsAliasArr.append(imgdict.stringValueForKey(key: "alias").count > 0 ? imgdict.stringValueForKey(key: "alias") : "角度二")
                }else if j == 2{
                    imgsAliasArr.append(imgdict.stringValueForKey(key: "alias").count > 0 ? imgdict.stringValueForKey(key: "alias") : "角度三")
                }
            }
            if hasImage{
                self.allDataArray.add(["ctime":"\(dict.stringValueForKey(key: "ctime"))",
                                       "alias":imgsAliasArr,
                                       "imgs":imgsArr])
            }
        }
    }
    func dealImgArray(array:NSArray) -> NSArray {
        let dataArray = NSMutableArray(array: [["sn":"1",
                                                "url":""],
                                               ["sn":"2",
                                               "url":""],
                                               ["sn":"3",
                                               "url":""]])
        
        for i in 0..<dataArray.count{
            let dict = dataArray[i]as? NSDictionary ?? [:]
            for j in 0..<array.count{
                let serverDict = array[j]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "sn") == serverDict.stringValueForKey(key: "sn"){
                    dataArray.replaceObject(at: i, with: serverDict)
                }
            }
        }
        
        return dataArray
    }
}

extension BodyDataDetailVC{
    func initUI() {
        initNavi(titleStr: "身体数据")
//        self.backArrowButton.tapBlock = {()in
//            self.backTapActi()
//        }
        
        self.navigationView.addSubview(shareButton)
        
        view.addSubview(topVm)
        view.addSubview(lineWhiteView)
        
        initLineChartParam()
        
        view.addSubview(headView)
        view.addSubview(tableView)
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: self.tableView.frame.height * 0.5)
        
        view.addSubview(typeFilterAlertVm)
        view.addSubview(timeTypeAlertVm)
        
        if self.dataType == .waistline{
            typeFilterAlertVm.setSelectIndex(index: 1)
        }
        
        setConstrait()
        
        self.tableView.reloadData()
    }
    func setConstrait() {
        shareButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.height.equalTo(kFitWidth(44))
            make.centerY.lessThanOrEqualTo(self.naviTitleLabel)
            make.width.equalTo(kFitWidth(64))
        }
    }
    func initLineChartParam() {
        lineChartView.removeFromSuperview()
        lineChartView = LineChartView(frame: CGRect.init(x: kFitWidth(20), y: kFitWidth(24), width: SCREEN_WIDHT-kFitWidth(20), height: kFitWidth(181)))
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.chartDescription.text = ""
        lineChartView.legend.enabled = false
        lineChartView.legend.form = .circle
        lineChartView.legend.verticalAlignment = .top
        lineChartView.delegate = self
        lineChartView.dragEnabled = true
        lineChartView.highlightPerTapEnabled = false
        
        lineChartView.noDataText = "暂无数据"
        lineChartView.noDataTextColor = .COLOR_GRAY_BLACK_65
        lineChartView.rightAxis.enabled = false
        
        lineWhiteView.addSubview(lineChartView)
        
        let leftYAxis = lineChartView.leftAxis
        leftYAxis.labelCount = 5
        leftYAxis.forceLabelsEnabled = true
        leftYAxis.axisLineColor = .clear
        leftYAxis.granularityEnabled = true
        leftYAxis.drawGridLinesEnabled = false
        leftYAxis.drawZeroLineEnabled = false
//        leftYAxis.axisMinimum = 0
//        leftYAxis.valueFormatter = IntAxisFormatter()
//        leftYAxis.drawAxisLineEnabled =  true
        
        let xAxis = lineChartView.xAxis
        xAxis.granularityEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.axisLineColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.15)
        xAxis.axisLineWidth = kFitWidth(1)
        xAxis.axisMinimum = -0.2
        xAxis.drawGridLinesEnabled = false
//        xAxis.drawAxisLineEnabled = false
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .regular)
        xAxis.labelTextColor = .COLOR_GRAY_BLACK_65
//        lineChartView.setVisibleXRangeMaximum(5)
        
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.dragYEnabled = false
    }
}

extension BodyDataDetailVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = dataSourceArray.count > 0 ? true : false
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataDetailTableViewCell") as? DataDetailTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DataDetailTableViewCell", for: indexPath) as! DataDetailTableViewCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        
        cell?.contentScrollView.setContentOffset(CGPoint.init(x: self.offsetX, y: 0), animated: false)
        
        cell?.imgTapBlock = {()in
            let vc = BodyDataShowImageVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        cell?.tapBlock = {()in
            let vc = DataAddVC()
            vc.msgDict = dict
            vc.updateUIForUpdate()
            vc.deleteBlock = {()in
                self.sendDeleteDataRequest(dict: dict)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell?.imagesTapBlock = {(imgUrls)in
            if imgUrls.count > 0 {
                let vc = BodyDataShowImageVC()
                vc.sdate = dict.stringValueForKey(key: "ctime")
                vc.dataSourceArray = self.allDataArray
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        cell?.scrollBlock = {(offsetX)in
            self.offsetX = offsetX
            self.scrollTableViewHor()
            self.headView.contentScrollView.setContentOffset(CGPoint.init(x: self.offsetX, y: 0), animated: false)
        }
        
        return cell ?? DataDetailTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(44)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        let vc = DataAddVC()
        vc.msgDict = dict
        vc.updateUIForUpdate()
        vc.deleteBlock = {()in
            self.sendDeleteDataRequest(dict: dict)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            TouchGenerator.shared.touchGenerator()
            let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
            self.sendDeleteDataRequest(dict: dict)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func scrollTableViewHor() {
        
        for i in 0..<self.dataSourceArray.count{
            let indexPath = IndexPath(row: i, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath)as? DataDetailTableViewCell
            cell?.contentScrollView.setContentOffset(CGPoint.init(x: self.offsetX, y: 0), animated: false)
        }
    }
}

extension BodyDataDetailVC{
    func sendDeleteDataRequest(dict:NSDictionary) {
//        MCToast.mc_loading()
        
        BodyDataSQLiteManager.getInstance().deleteTableData(cTime: "\(dict["ctime"]as? String ?? "")")
        let param = ["ctime":"\(dict["ctime"]as? String ?? "")"]
        WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_delete, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: responseObject)
            UserDefaults.deleteWeightDate(sdate: "\(dict["ctime"]as? String ?? "")")
            self.sendBodyStatRequest()
            
            let healthManager = HealthKitManager()
            healthManager.saveWeight(value: 0, sdate: "\(dict["ctime"]as? String ?? "")")
            healthManager.saveBodyFatPercentage(value: 0, sdate: "\(dict["ctime"]as? String ?? "")")
            healthManager.saveWaistCircumference(value: 0, sdate: "\(dict["ctime"]as? String ?? "")")
        }
    }
    func sendAllBodyDataRequest() {
        let param = ["uid":"\(UserInfoModel.shared.uId)",
                     "qtype":"0"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_query, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            self.dealImageDataSourceArray(array: dataArray)
        }
    }
    func sendBodyStatRequest(){
        //"qtype": "0"// 0-全部；1-一个星期内；2-一个月内；3-两个月内；4-三个月内；5-半年内；6-一年内
        let param = ["uid":"\(UserInfoModel.shared.uId)",
                     "qtype":"\(timeType)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_query, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            self.dealBodyStatData(dataArray: dataObj)
        }
    }
    func dealBodyStatData(dataArray:NSArray) {
        self.dataSourceArray = dataArray//.reversed() as NSArray
        weightDataArray.removeAllObjects()
        yaoDataArray.removeAllObjects()
        hipsDataArray.removeAllObjects()
        armDataArray.removeAllObjects()
        shoulderDataArray.removeAllObjects()
        bustDataArray.removeAllObjects()
        thighDataArray.removeAllObjects()
        calfDataArray.removeAllObjects()
        bfpDataArray.removeAllObjects()
        
        for i in 0..<self.dataSourceArray.count{
            let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
            
            if dict.doubleValueForKey(key: "weight") > 0 {
                weightDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                     "weight":"\(WHUtils.convertStringToStringOneDigit("\((dict.doubleValueForKey(key: "weight") * UserInfoModel.shared.weightCoefficient))") ?? "")"])
            }
            if dict.doubleValueForKey(key: "waistline") > 0{
                yaoDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                  "waistline":dict.stringValueForKey(key: "waistline")])
            }
            if dict.doubleValueForKey(key: "hips") > 0{
                hipsDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                   "hips":dict.stringValueForKey(key: "hips")])
            }
            if dict.doubleValueForKey(key: "armcircumference") > 0{
                armDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                  "armcircumference":dict.stringValueForKey(key: "armcircumference")])
            }
            if dict.doubleValueForKey(key: "shoulder") > 0{
                shoulderDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                       "shoulder":dict.stringValueForKey(key: "shoulder")])
            }
            if dict.doubleValueForKey(key: "bust") > 0{
                bustDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                   "bust":dict.stringValueForKey(key: "bust")])
            }
            if dict.doubleValueForKey(key: "thigh") > 0{
                thighDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                    "thigh":dict.stringValueForKey(key: "thigh")])
            }
            if dict.doubleValueForKey(key: "calf") > 0{
                calfDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                   "calf":dict.stringValueForKey(key: "calf")])
            }
            if dict.doubleValueForKey(key: "bfp") > 0 {
                bfpDataArray.add(["ctime":dict.stringValueForKey(key: "ctime"),
                                  "bfp":dict.stringValueForKey(key: "bfp")])
            }
        }
        changeType()
        self.tableView.reloadData()
//        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    func setDataArray() {
        initLineChartParam()
        var yDataArray = [ChartDataEntry]()
        var xStringArray = [String]()
        
        var firstNumber = CGFloat(0)
        var currentNumber = CGFloat(0)
        
        if showDataArray.count > 0 {
            showDataArray = showDataArray.reversed() as NSArray
            for i in 0..<showDataArray.count{
                let dict = showDataArray[i]as? NSDictionary ?? [:]
                
//                let timeString = dict["ctime"]as? String ?? ""
                var timeString = dict["ctime"]as? String ?? ""
                timeString = timeString.replacingOccurrences(of: "-", with: "/")
                timeString = timeString.mc_cutToSuffix(from: 5)
                xStringArray.append(timeString)
                
                let entry = ChartDataEntry.init(x: Double(i), y: Double(dict.doubleValueForKey(key: showTypeString)))
                yDataArray.append(entry)
                
                if i == 0 {
                    firstNumber = CGFloat(dict.doubleValueForKey(key: showTypeString))
                }
                if i == showDataArray.count - 1 {
                    currentNumber = CGFloat(dict.doubleValueForKey(key: showTypeString))
                }
            }
            self.topVm.updateUI(startNumber: firstNumber, currentNumber: currentNumber, unit: showDayaUnit)
            
            let set = LineChartDataSet.init(entries: yDataArray, label: "\(showDayaUnit)");
            set.colors = [WHColor_16(colorStr: showColor)]
            set.drawCirclesEnabled = true
            set.drawFilledEnabled = true
            //渐变
            let gradientColors = [WHColorWithAlpha(colorStr: showColor, alpha: 0.2).cgColor,WHColorWithAlpha(colorStr: showColor, alpha: 1).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: [0,1])!
            // 设置渐变填充
            set.fill = LinearGradientFill.init(gradient: gradient, angle: 90.0)
            
            set.lineWidth = 2.0;
            set.circleColors = [WHColor_16(colorStr: showColor)]
            set.circleRadius = kFitWidth(2)
            set.drawCircleHoleEnabled = false
    //        set.drawValuesEnabled = false
            set.drawHorizontalHighlightIndicatorEnabled = false
            set.drawVerticalHighlightIndicatorEnabled = false
            
            set.valueFormatter = IntValueFormatter()
            set.valueFont = .systemFont(ofSize: 12, weight: .regular)
            
    //        lineChartView.animate(xAxisDuration: 0.7, yAxisDuration: 0.7, easingOption: .linear)
            let data = LineChartData.init(dataSets: [set])
            
            lineChartView.data = data
            lineChartView.leftAxis.valueFormatter = IntAxisFormatter()
            if self.dataType == .bfp{
                lineChartView.leftAxis.valueFormatter = MyValueFormatter()
            }
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter.init(values: xStringArray)
            
            if xStringArray.count > 5 {
                lineChartView.setVisibleXRangeMaximum(5)
        //         获取最右边的Entry的xIndex   滑动到最右边
                lineChartView.xAxis.granularityEnabled = true
                lineChartView.xAxis.labelCount = 5
                lineChartView.moveViewToX(Double((lineChartView.data?.entryCount ?? 1) - 1))
                lineChartView.xAxis.axisMinimum = -0.2
            }else{
                lineChartView.moveViewToX(Double(0))
                lineChartView.xAxis.labelCount = showDataArray.count
            }
            lineChartView.xAxis.axisMaximum = Double(showDataArray.count - 1) + 0.2
            lineChartView.noDataText = "暂无数据"
            lineChartView.noDataTextColor = .COLOR_GRAY_BLACK_65
//            lineChartView.leftAxis.labelCount = 5
            lineChartView.leftAxis.drawGridLinesEnabled = false
            lineChartView.leftAxis.resetCustomAxisMin()
            lineChartView.leftAxis.resetCustomAxisMax()
            
            let center = (lineChartView.chartYMax + lineChartView.chartYMin)*0.5
            let gap = (lineChartView.chartYMax - lineChartView.chartYMin)*0.5
            
            if lineChartView.chartYMax-lineChartView.chartYMin >= 5 {
                lineChartView.leftAxis.granularity = (lineChartView.chartYMax-lineChartView.chartYMin + 4)/5
                lineChartView.leftAxis.axisMinimum = center - gap - 2//lineChartView.chartYMin
                lineChartView.leftAxis.axisMaximum = center + gap + 2//lineChartView.chartYMax
            }else{
                lineChartView.leftAxis.granularity = 1
                lineChartView.leftAxis.axisMinimum = center - 2.5
                lineChartView.leftAxis.axisMaximum = center + 2.5
            }
            lineChartView.leftAxis.labelCount = 5
            lineChartView.leftAxis.axisMinLabels = 5
            lineChartView.leftAxis.axisMaxLabels = 5
        }else{
//            let toDay = Date().todayDate.mc_cutToSuffix(from: 5)
            self.topVm.updateUI(startNumber: firstNumber, currentNumber: currentNumber, unit: showDayaUnit)
            xStringArray.append("")
            let entry = ChartDataEntry.init(x: Double(0), y: Double(50))
            yDataArray.append(entry)
            
            let set = LineChartDataSet.init(entries: yDataArray, label: "");
            set.colors = [.clear]
            set.drawCirclesEnabled = true;
            set.circleColors = [.clear]
            set.circleRadius = kFitWidth(2)
            set.drawCircleHoleEnabled = false
            set.drawValuesEnabled = false
            set.drawHorizontalHighlightIndicatorEnabled = false
            set.drawVerticalHighlightIndicatorEnabled = false
            set.valueFormatter = IntValueFormatter()
            
            let data = LineChartData.init(dataSets: [set])
            
            lineChartView.data = data
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter.init(values: xStringArray)
            lineChartView.xAxis.axisMaximum = Double(0)
            lineChartView.setVisibleXRangeMaximum(1)
            lineChartView.leftAxis.valueFormatter = IntAxisFormatter()
            if self.dataType == .bfp{
                lineChartView.leftAxis.valueFormatter = MyValueFormatter()
            }
//            lineChartView.moveViewToX(Double(0))
//            lineChartView.xAxis.labelCount = 1
            lineChartView.leftAxis.labelCount = 3
            lineChartView.leftAxis.drawGridLinesEnabled = true
            lineChartView.leftAxis.axisMinimum = 0
            lineChartView.leftAxis.axisMaximum = 100
            lineChartView.leftAxis.granularity = 50
            lineChartView.leftAxis.granularityEnabled = true
        }
    }
}

extension BodyDataDetailVC{
    func backTapActi() {
        if popToOverview {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            super.backTapAction()
        }
    }
}

extension BodyDataDetailVC:ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLLog(message: "\(entry)")
    }
}
//转化为整型
class IntValueFormatter: NSObject, ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return WHUtils.convertStringToString("\(entry.y)") ?? ""
    }
}
// 自定义Formatter类
class MyValueFormatter: NSObject, AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // 如果是整数刻度，则直接返回整数字符串
        if value == Double(Int(value)) {
            return "\(Int(value)) %"
        } else {
            // 如果不是整数刻度，做处理
            return "\(String(format: "%.0f", value)) %"
        }
    }
}
