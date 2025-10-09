//
//  NaturalStatTimeMonthFilterAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/9.
//

import Foundation

class NaturalStatTimeMonthFilterAlertVM: UIView {
    
    let whiteViewHeight = kFitWidth(204)
    let dateSourceYearArray = NaturalUtil().getNext3YearsArray()
    var choiceBlock:((NSDictionary)->())?
    var initBlock:((NSDictionary)->())?
    var hiddenBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var dateSourceMonthArray: NSArray = {
        var monthArray = NSMutableArray()
        for i in 1..<13{
            let str = "\(i)"
            monthArray.add(str)
        }
        return monthArray
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight() + kFitWidth(28), width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
    lazy var bottomWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: self.whiteView.frame.minY + kFitWidth(50), width: SCREEN_WIDHT, height: self.whiteView.frame.height-kFitWidth(50)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: CGRect.init(x: 0, y: kFitWidth(0), width: SCREEN_WIDHT, height: kFitWidth(140)))
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    lazy var confirmButton: FeedBackButton = {
        let btn = FeedBackButton.init(frame: CGRect.init(x: 0, y: whiteViewHeight-kFitWidth(48), width: SCREEN_WIDHT, height: kFitWidth(48)))
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
}

extension NaturalStatTimeMonthFilterAlertVM{
    @objc func showView(){
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
            self.bottomWhiteView.alpha = 1
        }
    }
    @objc func hiddenSelf(){
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
            self.bottomWhiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
        if self.hiddenBlock != nil{
            self.hiddenBlock!()
        }
    }
    @objc func confirmAction() {
        if self.choiceBlock != nil{
            let yearIndex = self.pickerView.selectedRow(inComponent: 0)
            let monthIndex = self.pickerView.selectedRow(inComponent: 1)
            
            let monthString = monthIndex < 9 ? "0\(self.dateSourceMonthArray[monthIndex])" : self.dateSourceMonthArray[monthIndex]
            
            self.choiceBlock!(["year":self.dateSourceYearArray[yearIndex],
                               "month":monthString])
        }
        self.hiddenSelf()
    }
    func refreshFrameForCalendar() {
        whiteView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: whiteViewHeight)
        bottomWhiteView.frame = CGRect.init(x: 0, y: self.whiteView.frame.minY + kFitWidth(50), width: SCREEN_WIDHT, height: self.whiteView.frame.height-kFitWidth(50))
    }
}

extension NaturalStatTimeMonthFilterAlertVM{
    func initUI() {
        addSubview(bottomWhiteView)
        addSubview(whiteView)
        whiteView.addSubview(pickerView)
        whiteView.addSubview(confirmButton)
        bottomWhiteView.addShadow()
        
        resetPickerViewSelect()
    }
    
    func resetPickerViewSelect() {
        let yearMonthArray = Date().currenYearMonth
        let currentYear = yearMonthArray[0]as? String ?? ""
        let currentMonth = yearMonthArray[1] as? String ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            if self.initBlock != nil{
                self.initBlock!(["year":currentYear,
                                 "month":currentMonth])
            }
        })
        
        var currentYearIndex = 0
        var currentMonthIndex = 0
        for i in 0..<dateSourceYearArray.count{
            if currentYear == dateSourceYearArray[i]as? String ?? ""{
                currentYearIndex = i
            }
        }
        for i in 0..<dateSourceMonthArray.count{
            let monthStr = (dateSourceMonthArray[i]as? String ?? "")//.mc_clipFromPrefix(to: (dateSourceMonthArray[i]as? String ?? "").count-1)
            if "\(currentMonth)" == monthStr ||
                "\(currentMonth)" == "0\(monthStr)"{
                currentMonthIndex = i
            }
        }
        
        self.pickerView.selectRow(currentYearIndex, inComponent: 0, animated: true)
        self.pickerView.selectRow(currentMonthIndex, inComponent: 1, animated: true)
    }
    func resetPickerViewSelectIndex(yearIndex:Int,monthIndex:Int) {
        var currentYearIndex = 0
        var currentMonthIndex = 0
        for i in 0..<dateSourceYearArray.count{
            if "\(yearIndex)" == dateSourceYearArray[i]as? String ?? ""{
                currentYearIndex = i
            }
        }
        for i in 0..<dateSourceMonthArray.count{
            let monthStr = (dateSourceMonthArray[i]as? String ?? "")//.mc_clipFromPrefix(to: (dateSourceMonthArray[i]as? String ?? "").count-1)
            if "\(monthIndex)" == monthStr ||
                "\(monthIndex)" == "0\(monthStr)"{
                currentMonthIndex = i
            }
        }
        
        self.pickerView.selectRow(currentYearIndex, inComponent: 0, animated: true)
        self.pickerView.selectRow(currentMonthIndex, inComponent: 1, animated: true)
    }
}

extension NaturalStatTimeMonthFilterAlertVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return dateSourceYearArray.count
        }else{
            return dateSourceMonthArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(36)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 0 {
            let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(160), height: kFitWidth(36)))
            lab.font = .systemFont(ofSize: 20, weight: .regular)
            lab.textAlignment = .right
            lab.text =  "\(dateSourceYearArray[row]as? String ?? "")年"
            setUpPickerStyleRowStyle(row: row, component: component)
            
            return lab
        }else{
            let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(20), y: 0, width: kFitWidth(60), height: kFitWidth(36)))
            lab.text = "\(dateSourceMonthArray[row]as? String ?? "")月"
            lab.textAlignment = .left
            lab.adjustsFontSizeToFitWidth = true
            lab.font = .systemFont(ofSize: 20, weight: .regular)
            setUpPickerStyleRowStyle(row: row, component: component)
            
            return lab
        }
    }
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .COLOR_GRAY_BLACK_85
//                label?.textColor = .THEME
            }
        })
    }
}

