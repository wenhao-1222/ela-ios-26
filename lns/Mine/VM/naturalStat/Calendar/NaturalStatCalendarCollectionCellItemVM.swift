//
//  NaturalStatCalendarCollectionCellItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/12.
//

import Foundation

class NaturalStatCalendarCollectionCellItemVM: UIView {
    
    var selfWidth = kFitWidth(52)
    var selfHeight = kFitWidth(78)
    
    var isSelect = false
    var tapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height))
        selfHeight = frame.height
        selfWidth = frame.width
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var bottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        return vi
    }()
    lazy var daysLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var caloriesItemVm: NaturalStatCalendarCollectionCellItemProgressVM = {
        let vm = NaturalStatCalendarCollectionCellItemProgressVM.init(frame: CGRect.init(x: kFitWidth(5), y: kFitWidth(30), width: self.selfWidth, height: 0))
        return vm
    }()
    lazy var carboItemVm: NaturalStatCalendarCollectionCellItemProgressVM = {
        let vm = NaturalStatCalendarCollectionCellItemProgressVM.init(frame: CGRect.init(x: kFitWidth(5), y: kFitWidth(42), width: self.selfWidth, height: 0))
        vm.setProgreColor(color: .COLOR_CARBOHYDRATE)
        return vm
    }()
    lazy var proteinItemVm: NaturalStatCalendarCollectionCellItemProgressVM = {
        let vm = NaturalStatCalendarCollectionCellItemProgressVM.init(frame: CGRect.init(x: kFitWidth(5), y: kFitWidth(54), width: self.selfWidth, height: 0))
        vm.setProgreColor(color: .COLOR_PROTEIN)
        return vm
    }()
    lazy var fatItemVm: NaturalStatCalendarCollectionCellItemProgressVM = {
        let vm = NaturalStatCalendarCollectionCellItemProgressVM.init(frame: CGRect.init(x: kFitWidth(5), y: kFitWidth(66), width: self.selfWidth, height: 0))
        vm.setProgreColor(color: .COLOR_FAT)
        return vm
    }()
    lazy var fitnessLabel: PaddingLabel = {
        let lab = PaddingLabel()
        lab.contentInsets = UIEdgeInsets(top: kFitWidth(2), left: kFitWidth(2), bottom: kFitWidth(2), right: kFitWidth(2))
        lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        lab.layer.cornerRadius = kFitWidth(2)
        lab.clipsToBounds = true
        lab.textAlignment = .center
        lab.textColor = .THEME
        lab.adjustsFontSizeToFitWidth = true
        lab.font = .systemFont(ofSize: 8, weight: .medium)
        
        return lab
    }()
    lazy var coverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.75)
        vi.isHidden = true
        vi.isUserInteractionEnabled = false
        
        return vi
    }()
    lazy var closeImg: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "stat_calendar_close_icon")
        img.isHidden = true
        
        return img
    }()
}

extension NaturalStatCalendarCollectionCellItemVM{
    func updateUI(dict:NSDictionary,yearMonth:String) {
        let sdate = dict.stringValueForKey(key: "sdate")
        let sdateArr = sdate.components(separatedBy: "-")
        daysLabel.text = "\((sdateArr[2]).intValue)"
        
//        DLLog(message: "--- sdate --  \(sdate)")
        caloriesItemVm.udpateUI(number:dict.doubleValueForKey(key: "calories"),total:dict.doubleValueForKey(key: "caloriesden"))
        carboItemVm.udpateUI(number:dict.doubleValueForKey(key: "carbohydrate"),total:dict.doubleValueForKey(key: "carbohydrateden"))
        proteinItemVm.udpateUI(number:dict.doubleValueForKey(key: "protein"),total:dict.doubleValueForKey(key: "proteinden"))
        fatItemVm.udpateUI(number:dict.doubleValueForKey(key: "fat"),total:dict.doubleValueForKey(key: "fatden"))
        
        if sdate.contains(yearMonth){
            coverView.isHidden = true
            self.isUserInteractionEnabled = true
        }else{
            coverView.isHidden = false
            self.isUserInteractionEnabled = false
        }
        updateFitness(fitnessArray: dict["fitnessLabelArray"]as? NSArray ?? [])
    }
    func updateFitness(fitnessArray:NSArray){
        fitnessLabel.isHidden = true
        if fitnessArray.count > 0 {
            fitnessLabel.isHidden = false
            var fitnessString = ""
            for i in 0..<fitnessArray.count{
                let str = "\(fitnessArray[i]as? String ?? "")"
                if str != "-"{
                    fitnessString = fitnessString + str.mc_clipFromPrefix(to: 1)
                    if i < fitnessArray.count - 1 {
                        fitnessString = fitnessString + "+"
                    }
                }
            }
            fitnessLabel.text = fitnessString
        }
    }
    
    func updateDaysLabel(sdate:String) {
        if sdate == Date().todayDate{
            daysLabel.text = "今天"
            daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        }else{
            let sdateArr = sdate.components(separatedBy: "-")
            daysLabel.text = "\((sdateArr[2]).intValue)"
        }
    }
    func updateUI(dict:NSDictionary,caloriesden:String,carbohydrateden:String,proteinden:String,fatden:String) {
//        caloriesItemVm.resetColorForGoal()
//        carboItemVm.resetColorForGoal()
//        proteinItemVm.resetColorForGoal()
//        fatItemVm.resetColorForGoal()
        
        caloriesItemVm.progressBottomView.backgroundColor = .clear
        caloriesItemVm.progressView.backgroundColor = .THEME
        carboItemVm.progressBottomView.backgroundColor = .clear
        carboItemVm.progressView.backgroundColor = .COLOR_CARBOHYDRATE
        proteinItemVm.progressBottomView.backgroundColor = .clear
        proteinItemVm.progressView.backgroundColor = .COLOR_PROTEIN
        fatItemVm.progressBottomView.backgroundColor = .clear
        fatItemVm.progressView.backgroundColor = .COLOR_FAT
        
        caloriesItemVm.udpateUI(number:dict.doubleValueForKey(key: "calories"),total:caloriesden.doubleValue)
        carboItemVm.udpateUI(number:dict.doubleValueForKey(key: "carbohydrates"),total:carbohydrateden.doubleValue)
        proteinItemVm.udpateUI(number:dict.doubleValueForKey(key: "proteins"),total:proteinden.doubleValue)
        fatItemVm.udpateUI(number:dict.doubleValueForKey(key: "fats"),total:fatden.doubleValue)
    }
    func updateBgColor(color:UIColor) {
        bottomView.backgroundColor = color
        bottomView.frame = CGRect.init(x: 0, y: 0, width: 0, height: selfHeight)
        UIView.animate(withDuration: 0.5, delay: 0.3,options: .curveLinear) {
            self.bottomView.frame = CGRect.init(x: 0, y: 0, width: self.selfWidth, height: self.selfHeight)
        }
    }
    @objc func tapAction() {
        if self.tapBlock != nil{
            TouchGenerator.shared.touchGenerator()
            self.tapBlock!()
        }
    }
    
    func changeSelectStatus(isSelect:Bool) {
        self.isSelect = isSelect
        closeImg.isHidden = !self.isSelect
        caloriesItemVm.isHidden = self.isSelect
        carboItemVm.isHidden = self.isSelect
        proteinItemVm.isHidden = self.isSelect
        fatItemVm.isHidden = self.isSelect
    }
}
extension NaturalStatCalendarCollectionCellItemVM{
    func initUI() {
        addSubview(bottomView)
        addSubview(daysLabel)
        addSubview(caloriesItemVm)
        addSubview(carboItemVm)
        addSubview(proteinItemVm)
        addSubview(fatItemVm)
        addSubview(fitnessLabel)
        addSubview(closeImg)
        addSubview(coverView)
        
        daysLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(32))
        }
        coverView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-2))
        }
        closeImg.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(32))
            make.width.height.equalTo(kFitWidth(24))
        }
        fitnessLabel.snp.makeConstraints { make in
            make.top.equalTo(fatItemVm.snp.bottom).offset(kFitWidth(2))
//            make.bottom.equalTo(kFitWidth(-8))
            make.left.equalTo(proteinItemVm).offset(kFitWidth(3))
            make.height.equalTo(kFitWidth(12))
        }
    }
}
