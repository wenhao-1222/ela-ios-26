//
//  NaturalStatCalendarVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/12.
//

import Foundation

class NaturalStatCalendarVM: UIView {
    
    var timeDataSourceArray = NSArray()// UserInfoModel.shared.dateArrayForStat
    
    var selfHeight = kFitWidth(0)
    var controller = WHBaseViewVC()
    
    var selectDateTypeName = ""
    var startDate = ""
    var endDate = ""
    
    var monthChangeBlock:((String)->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: controller.getNavigationBarHeight() + kFitWidth(28), width: SCREEN_WIDHT, height: SCREEN_HEIGHT - controller.getNavigationBarHeight() - kFitWidth(28)))
        selfHeight = SCREEN_HEIGHT - controller.getNavigationBarHeight() - kFitWidth(28)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        timeDataSourceArray = UserInfoModel.shared.dateArrayForStat
        
        initUI()
    }
    lazy var headView: NaturalStatCalendarHeadView = {
        let vm = NaturalStatCalendarHeadView.init(frame: .zero)
        return vm
    }()
    let collectView : JournalCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemHeight = SCREEN_HEIGHT - WHUtils().getNavigationBarHeight() - kFitWidth(28) - kFitWidth(48)
        layout.itemSize = CGSize(width: SCREEN_WIDHT, height: itemHeight)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let vi = JournalCollectionView.init(frame: CGRect.init(x: 0, y:kFitWidth(48), width: SCREEN_WIDHT, height: itemHeight), collectionViewLayout: layout)
        
        vi.collectionViewLayout = layout
        vi.isPagingEnabled = true
        vi.canScroll = false
        vi.isScrollEnabled = false
//        vi.dataSource = self
        vi.showsHorizontalScrollIndicator = false
        vi.showsVerticalScrollIndicator = false
        
        return vi
    }()
    lazy var monthPickerView: NaturalStatTimeMonthFilterAlertVM = {
        let vm = NaturalStatTimeMonthFilterAlertVM.init(frame: .zero)
        vm.choiceBlock = {(dict)in
            self.startDate = "\(dict.stringValueForKey(key: "year"))-\(dict["month"]as? String ?? "")-01"
            self.endDate = "\(dict.stringValueForKey(key: "year"))-\(dict["month"]as? String ?? "")-\(NaturalUtil().getDaysInMonth(year: Int(dict.doubleValueForKey(key: "year")),month:Int(dict.doubleValueForKey(key: "month"))))"
            self.setCollectionView(yearIndex: Int(dict.doubleValueForKey(key: "year")), monthIndex: Int(dict.doubleValueForKey(key: "month")))
            self.selectDateTypeName = "\(dict.stringValueForKey(key: "year"))年\(Int(dict.doubleValueForKey(key: "month")))月"
            if self.monthChangeBlock != nil{
                self.monthChangeBlock!(self.selectDateTypeName)
            }
        }
        vm.hiddenBlock = {()in
              
        }
        vm.initBlock = {(dict)in
            self.selectDateTypeName = "\(dict.stringValueForKey(key: "year"))年\(dict.stringValueForKey(key: "month"))月"
        }
        return vm
    }()
}

extension NaturalStatCalendarVM{
    func initUI() {
        addSubview(headView)
        self.refreshCollectionDataSource()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(monthPickerView)
    }
    func refreshCollectionDataSource() {
        if UserInfoModel.shared.dateArrayDealComplete == false{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                self.refreshCollectionDataSource()
            })
        }else{
            addSubview(collectView)
            
            for i in 0..<timeDataSourceArray.count{
                collectView.register(NaturalStatCalendarCollectionCell.classForCoder(), forCellWithReuseIdentifier: "NaturalStatCalendarCollectionCell\(i)")
            }
            
            collectView.delegate = self
            collectView.dataSource = self
            resetCollectionView()
        }
    }
    
    func resetCollectionView() {
        let monthArray = Date().currenYearMonth
        let currentYear = monthArray[0]as? String ?? ""
        let currentMonth = monthArray[1]as? String ?? ""
        
        let yearIndex = currentYear.intValue
        let monthIndex = currentMonth.intValue
        
        var currentIndex = (yearIndex-2021)*12 + monthIndex - 1
        if currentIndex < 0 {
            currentIndex = 0
        }else if currentIndex > self.timeDataSourceArray.count - 1{
            currentIndex = self.timeDataSourceArray.count - 1
        }
        self.collectView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .bottom, animated: false)
    }
    func setCollectionView(yearIndex:Int,monthIndex:Int) {
        var selectIndex = (yearIndex-2021)*12 + monthIndex - 1
        if selectIndex < 0 {
            selectIndex = 0
        }else if selectIndex > self.timeDataSourceArray.count - 1{
            selectIndex = self.timeDataSourceArray.count - 1
        }
        self.collectView.scrollToItem(at: IndexPath(row: selectIndex, section: 0), at: .bottom, animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hiddenMarkView"), object: nil)
    }
}

extension NaturalStatCalendarVM:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeDataSourceArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NaturalStatCalendarCollectionCell\(indexPath.row)", for: indexPath)as? NaturalStatCalendarCollectionCell
//        cell?.backgroundColor = WHColor_ARC()
        
        let dict = timeDataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.setQueryMonth(year: Int(dict.doubleValueForKey(key: "yearIndex")), month: Int(dict.doubleValueForKey(key: "monthIndex")))
            
        return cell ?? NaturalStatCalendarCollectionCell()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int((collectView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        refreshNaviTime(currentPage: currentPage)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hiddenMarkView"), object: nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int((collectView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        refreshNaviTime(currentPage: currentPage)
    }
    
    func refreshNaviTime(currentPage:Int) {
        if currentPage >= 0 && currentPage < timeDataSourceArray.count{
            let dict = timeDataSourceArray[currentPage]as? NSDictionary ?? [:]
            
            self.selectDateTypeName = dict.stringValueForKey(key: "month")
            if self.monthChangeBlock != nil{
                self.monthChangeBlock!(self.selectDateTypeName)
            }
            self.monthPickerView.resetPickerViewSelectIndex(yearIndex: Int(dict.doubleValueForKey(key: "yearIndex")), monthIndex: Int(dict.doubleValueForKey(key: "monthIndex")))
        }
    }
}

