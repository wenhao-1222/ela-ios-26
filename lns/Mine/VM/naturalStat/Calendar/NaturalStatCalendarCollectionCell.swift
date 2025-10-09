//
//  NaturalStatCalendarCollectionCell.swift
//  lns
//
//  Created by LNS2 on 2024/9/12.
//

import Foundation

class NaturalStatCalendarCollectionCell: UICollectionViewCell {
    
    var controller = WHBaseViewVC()
    var queryMonthDict = NSDictionary()
    var dataSourceArray = NSArray()
    
    var dateArray = NSMutableArray()
    var serveDataArray = NSArray()
    
    var startDate = ""
    var endDate = ""
    var yearMonthString = ""
    
    let itemVmWidth = (SCREEN_WIDHT-kFitWidth(11))/7
    let itemVmHeight = kFitWidth(98)//kFitWidth(76)
    
    var tapIndex = -1
    var selectVm = NaturalStatCalendarCollectionCellItemVM()
    var vmDataArray:[NaturalStatCalendarCollectionCellItemVM] = [NaturalStatCalendarCollectionCellItemVM]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(hiddenMarkView), name: NSNotification.Name(rawValue: "hiddenMarkView"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var scrollView : UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(48)-WHUtils().getNavigationBarHeight()-kFitWidth(28)))
        scro.showsVerticalScrollIndicator = false
        scro.backgroundColor = .clear
        scro.layer.cornerRadius = kFitWidth(12)
//        scro.bounces = false
        scro.delegate = self
        
        return scro
    }()
    lazy var favoriteFoodsVm: NaturalStatFavoriteFoodsVM = {
        let vm = NaturalStatFavoriteFoodsVM.init(frame: .zero)
        vm.updateBlock = {()in
            if Date().currentMonth == self.yearMonthString{
                self.scrollView.contentSize = CGSize.init(width: 0, height: self.favoriteFoodsVm.frame.maxY+kFitWidth(10)+WHUtils().getBottomSafeAreaHeight())
            }
        }
        
        return vm
    }()
    lazy var dateBottomView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var tapCoverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenMarkView))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var markView: NaturalStatCalendarMarkView = {
        let vm = NaturalStatCalendarMarkView.init(frame: .zero)
        //stat_calendar_close_icon
        return vm
    }()
}

extension NaturalStatCalendarCollectionCell{
    func setQueryMonth(year:Int,month:Int) {
        if month < 10{
            self.startDate = "\(year)-0\(month)-01"
            self.endDate = "\(year)-0\(month)-\(NaturalUtil().getDaysInMonth(year: year,month:month))"
        }else{
            self.startDate = "\(year)-\(month)-01"
            self.endDate = "\(year)-\(month)-\(NaturalUtil().getDaysInMonth(year: year,month:month))"
        }
        
        yearMonthString = self.startDate.mc_clipFromPrefix(to: self.startDate.count - 3)
        resetDate()
        
        dateArray = NSMutableArray(array: NaturalUtil().getDaysSourceArray(startDate: self.startDate, endDate: self.endDate))
        sendStatDataRequest()
    }
    func resetDate() {
        let startWeekDay = Date().getWeekdayIndex(from: self.startDate)
        if startWeekDay != 7 {
            let date = Date().nextDay(days: -startWeekDay, baseDate: self.startDate)
            self.startDate = date
        }
        
        let endWeekDay  = Date().getWeekdayIndex(from: self.endDate)
        if endWeekDay != 6 {
            if endWeekDay == 7{
                let date = Date().nextDay(days: 6, baseDate: self.endDate)
                self.endDate = date
            }else{
                let date = Date().nextDay(days: 6-endWeekDay, baseDate: self.endDate)
                self.endDate = date
            }
        }
    }
    @objc func hiddenMarkView() {
        self.selectVm.changeSelectStatus(isSelect: false)
        self.markView.hiddenSelf()//isHidden = true
        self.tapCoverView.isHidden = true
        self.tapIndex = -1
    }
}

extension NaturalStatCalendarCollectionCell{
    func updateUI(dataArray:NSArray) {
        self.dataSourceArray = dataArray
        
        for vi  in scrollView.subviews{
            if Date().currentMonth == yearMonthString{
                if vi != favoriteFoodsVm{
                    vi.removeFromSuperview()
                }
            }else{
                vi.removeFromSuperview()
            }
        }
        vmDataArray.removeAll()
        
//
        
        for i in 0..<self.dataSourceArray.count {
            let dayDict = self.dataSourceArray[i] as? NSDictionary ?? [:]
            let weekDay = Date().getWeekdayIndex(from: dayDict.stringValueForKey(key: "sdate"))
            let originX = kFitWidth(11) + self.getButtonOriginX(weekDay: weekDay)
            let originY = self.itemVmHeight * CGFloat(i / 7)
            
            let vm = NaturalStatCalendarCollectionCellItemVM(frame: CGRect(x: originX, y: originY, width: self.itemVmWidth, height: self.itemVmHeight))
            vm.updateUI(dict: dayDict, yearMonth: self.yearMonthString)
            self.scrollView.addSubview(vm)
            vm.tapBlock = { [weak self] in
                guard let self = self else { return }
                self.selectVm.changeSelectStatus(isSelect: false)
                if self.tapIndex == i {
                    self.hiddenMarkView()
                } else {
                    self.selectVm = vm
                    self.selectVm.changeSelectStatus(isSelect: true)
                    self.tapIndex = i
                    self.itemTapAction(originX: vm.frame.minX, originY: vm.frame.minY, dict: dayDict)
                }
            }
            if i % 7 == 0 {
                if i > 0 {
                    let vi = UIView(frame: CGRect(x: 0, y: originY-kFitWidth(1), width: SCREEN_WIDHT, height: kFitWidth(1)))
                    vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
                    self.scrollView.addSubview(vi)
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                        self.scrollView.bringSubviewToFront(vi)
                }
//                })
            }
            let vmLeft = NaturalStatCalendarCollectionCellItemLeftVM(frame: CGRect(x: 0, y: originY, width: 0, height: 0))
            self.scrollView.addSubview(vmLeft)
        }
            
//            serialQueue.async {
//                DispatchQueue.main.sync(execute: {
//                    let vm = NaturalStatCalendarCollectionCellItemVM.init(frame: CGRect.init(x: originX, y: originY, width: self.itemVmWidth, height: self.itemVmHeight))
//                    vm.updateUI(dict: dayDict,yearMonth: self.yearMonthString)
//                    self.scrollView.addSubview(vm)
//                    vm.tapBlock = {()in
//                        self.selectVm.changeSelectStatus(isSelect: false)
//                        if self.tapIndex == i {
//                            self.markView.isHidden = true
//                            self.tapIndex = -1
//                        }else{
//                            self.selectVm = vm
//                            self.selectVm.changeSelectStatus(isSelect: true)
//                            self.tapIndex = i
//                            self.itemTapAction(originX: vm.frame.minX, originY: vm.frame.minY, dict: dayDict)
//                        }
//                    }
//                    
//                    if i % 7 == 0 {
//                        if i > 0 {
//                            let vi = UIView.init(frame: CGRect.init(x: 0, y: originY-kFitWidth(1), width: SCREEN_WIDHT, height: kFitWidth(1)))
//                            vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
////                            self.scrollView.insertSubview(vi, aboveSubview: vm)
//                            self.scrollView.addSubview(vi)
//                            DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
//                                self.scrollView.bringSubviewToFront(vi)
//                            })
//                        }
//                        let vm = NaturalStatCalendarCollectionCellItemLeftVM.init(frame: CGRect.init(x: 0, y: originY, width: 0, height: 0))
//                        self.scrollView.addSubview(vm)
//                    }
//                })
//            }
        }
        
        if Date().currentMonth == yearMonthString{
            favoriteFoodsVm.frame = CGRect.init(x: 0, y: CGFloat((self.dataSourceArray.count+6)/7)*self.itemVmHeight+kFitWidth(10), width: SCREEN_WIDHT, height: favoriteFoodsVm.selfHeight)
            favoriteFoodsVm.isHidden = false
            scrollView.contentSize = CGSize.init(width: 0, height: self.favoriteFoodsVm.frame.maxY+kFitWidth(10)+WHUtils().getBottomSafeAreaHeight())
        }else{
            favoriteFoodsVm.isHidden = true
            scrollView.contentSize = CGSize.init(width: 0, height: CGFloat((self.dataSourceArray.count+6)/7)*self.itemVmHeight + WHUtils().getBottomSafeAreaHeight())
        }
        
    }
    func getButtonOriginX(weekDay:Int) -> CGFloat{
        if weekDay == 7 {
            return kFitWidth(0)
        }else{
            return itemVmWidth*CGFloat(weekDay)
        }
    }
    func itemTapAction(originX:CGFloat,originY:CGFloat,dict:NSDictionary) {
        self.tapCoverView.isHidden = false
        self.markView.isHidden = false
        self.markView.updateUI(originX: originX, originY: originY,offsetY:self.scrollView.contentOffset.y, dict: dict)
    }
}
extension NaturalStatCalendarCollectionCell{
    func initUI() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(dateBottomView)
        scrollView.addSubview(favoriteFoodsVm)
        
        contentView.addSubview(tapCoverView)
        contentView.addSubview(markView)
        
        setConstrait()
    }
    func setConstrait() {
        dateBottomView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        tapCoverView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func dealDataSource() {
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0..<self.dateArray.count{
                let sDate = self.dateArray[i]as? String ?? ""
                var hasData = false
                for j in 0..<self.serveDataArray.count{
                    let dict = self.serveDataArray[j]as? NSDictionary ?? [:]
                    if dict.stringValueForKey(key: "sdate") == sDate{
                        hasData = true
                        self.dateArray.replaceObject(at: i, with: dict)
                        break
                    }
                }
                if hasData == false{
                    NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
                    
                    let dict = ["caloriesden":NutritionDefaultModel.shared.calories,
                                "carbohydrateden":NutritionDefaultModel.shared.carbohydrate,
                                "proteinden":NutritionDefaultModel.shared.protein,
                                "fatden":NutritionDefaultModel.shared.fat,
                                "sdate":sDate]
                    self.dateArray.replaceObject(at: i, with: dict)
                }
            }
            DLLog(message: "dateArray(\(self.startDate) - \(self.endDate)):\(self.dateArray)")
            
            DispatchQueue.main.sync(execute: {
                self.updateUI(dataArray: self.dateArray)
            })
        }
    }
}

extension NaturalStatCalendarCollectionCell{
    func sendStatDataRequest() {
        let param = ["qtype":"99",
                     "start_date":self.startDate,
                     "end_date":self.endDate]
        DLLog(message: "sendStatDataRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_stat, parameters: param as [String:AnyObject],isNeedToast: true,vc: controller) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = self.controller.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "\(dataObj)")
            self.serveDataArray = dataObj["logs"]as? NSArray ?? []
            
            self.dealDataSource()
        }
    }
}

extension NaturalStatCalendarCollectionCell:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.markView.isHidden = true
        self.hiddenMarkView()
    }
}
