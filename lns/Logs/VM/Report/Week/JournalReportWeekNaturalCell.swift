//
//  JournalReportWeekNaturalCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/14.
//


class JournalReportWeekNaturalCell: UITableViewCell {
    
    let whiteViewWidth = SCREEN_WIDHT-kFitWidth(32)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.isSkeletonable = true
        contentView.isSkeletonable = true
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isSkeletonable = true
        
        return vi
    }()
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.text = "你在过去一周平均每天摄入"
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        lab.adjustsFontSizeToFitWidth = true
        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "report_ela_img")
        return img
    }()
    lazy var lineHorView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        
        return vi
    }()
    lazy var lineVerTopView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        
        return vi
    }()
    lazy var lineVerBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        
        return vi
    }()
    lazy var caloriesItemVm: JournalReportWeekNaturalItemVM = {
        let vm = JournalReportWeekNaturalItemVM.init(frame: CGRect.init(x: kFitWidth(27), y: kFitWidth(55), width: 0, height: 0))
        vm.numberTypeLabel.text = "卡路里"
        vm.circleView.backgroundColor = .THEME
        vm.numberUnitLabel.text = "千卡"
//        vm.numberLabel.text = "2999"
        return vm
    }()
    lazy var carboItemVm: JournalReportWeekNaturalItemVM = {
        let vm = JournalReportWeekNaturalItemVM.init(frame: CGRect.init(x: whiteViewWidth*0.5 + kFitWidth(15), y: kFitWidth(55), width: 0, height: 0))
        vm.numberTypeLabel.text = "碳水"
        vm.circleView.backgroundColor = .COLOR_CARBOHYDRATE
        vm.numberUnitLabel.text = "g"
//        vm.numberLabel.text = "222"
        return vm
    }()
    lazy var proteinItemVm: JournalReportWeekNaturalItemVM = {
        let vm = JournalReportWeekNaturalItemVM.init(frame: CGRect.init(x: kFitWidth(27), y: kFitWidth(117), width: 0, height: 0))
        vm.numberTypeLabel.text = "蛋白质"
        vm.circleView.backgroundColor = .COLOR_PROTEIN
        vm.numberUnitLabel.text = "g"
//        vm.numberLabel.text = "239"
        return vm
    }()
    lazy var fatItemVm: JournalReportWeekNaturalItemVM = {
        let vm = JournalReportWeekNaturalItemVM.init(frame: CGRect.init(x: whiteViewWidth*0.5 + kFitWidth(15), y: kFitWidth(117), width: 0, height: 0))
        vm.numberTypeLabel.text = "脂肪"
        vm.circleView.backgroundColor = .COLOR_FAT
        vm.numberUnitLabel.text = "g"
//        vm.numberLabel.text = "114"
        return vm
    }()
    lazy var gapTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "本周你的总摄入量与目标相比的差距"
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var gapCaloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var gapCarboLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var gapProteinLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var gapFatLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.isSkeletonable = true
        
        return lab
    }()
}

extension JournalReportWeekNaturalCell{
    func updateUI(dict:NSDictionary) {
        
        let gapCalDict = dict["gapCal"]as? NSDictionary ?? [:]
        
        let calories = "\(gapCalDict.stringValueForKey(key: "sign"))\(gapCalDict.stringValueForKey(key: "gap"))"
        if calories.count > 0 {
            hideSkeleton()
            caloriesItemVm.hideSkeletonForFrame()
            carboItemVm.hideSkeletonForFrame()
            proteinItemVm.hideSkeletonForFrame()
            fatItemVm.hideSkeletonForFrame()
            
            let gapChoDict = dict["gapCho"]as? NSDictionary ?? [:]
            let gapProDict = dict["gapPro"]as? NSDictionary ?? [:]
            let gapFatDict = dict["gapFat"]as? NSDictionary ?? [:]
            let carbo = "\(gapChoDict.stringValueForKey(key: "sign"))\(gapChoDict.stringValueForKey(key: "gap"))"
            let protein = "\(gapProDict.stringValueForKey(key: "sign"))\(gapProDict.stringValueForKey(key: "gap"))"
            let fat = "\(gapFatDict.stringValueForKey(key: "sign"))\(gapFatDict.stringValueForKey(key: "gap"))"
            
            let caloriesAttr = NSMutableAttributedString(string: "卡路里")
            let caloriesAttrNum = NSMutableAttributedString(string: calories)
            let caloriesAttrUnit = NSMutableAttributedString(string: "千卡（\(gapCalDict.stringValueForKey(key: "rate"))%）")
            
            caloriesAttrNum.yy_font = .systemFont(ofSize: 16, weight: .medium)
            caloriesAttrNum.yy_color = .THEME
            caloriesAttr.append(caloriesAttrNum)
            caloriesAttr.append(caloriesAttrUnit)
            gapCaloriesLabel.attributedText = caloriesAttr
            
            let carboAttr = NSMutableAttributedString(string: "碳水")
            let carboAttrNum = NSMutableAttributedString(string: carbo)
            let carboAttrUnit = NSMutableAttributedString(string: "g（\(gapChoDict.stringValueForKey(key: "rate"))%）")
            carboAttrNum.yy_font = .systemFont(ofSize: 16, weight: .medium)
            carboAttrNum.yy_color = .THEME
            carboAttr.append(carboAttrNum)
            carboAttr.append(carboAttrUnit)
            gapCarboLabel.attributedText = carboAttr
            
            let proteinAttr = NSMutableAttributedString(string: "蛋白质")
            let proteinAttrNum = NSMutableAttributedString(string: protein)
            let proteinAttrUnit = NSMutableAttributedString(string: "g（\(gapProDict.stringValueForKey(key: "rate"))%）")
            proteinAttrNum.yy_font = .systemFont(ofSize: 16, weight: .medium)
            proteinAttrNum.yy_color = .THEME
            proteinAttr.append(proteinAttrNum)
            proteinAttr.append(proteinAttrUnit)
            gapProteinLabel.attributedText = proteinAttr
            
            let fatAttr = NSMutableAttributedString(string: "脂肪")
            let fatAttrNum = NSMutableAttributedString(string: fat)
            let fatAttrUnit = NSMutableAttributedString(string: "g（\(gapFatDict.stringValueForKey(key: "rate"))%）")
            fatAttrNum.yy_font = .systemFont(ofSize: 16, weight: .medium)
            fatAttrNum.yy_color = .THEME
            fatAttr.append(fatAttrNum)
            fatAttr.append(fatAttrUnit)
            gapFatLabel.attributedText = fatAttr
            
            caloriesItemVm.numberLabel.text = dict.stringValueForKey(key: "avgCal")
            carboItemVm.numberLabel.text = dict.stringValueForKey(key: "avgCho")
            proteinItemVm.numberLabel.text = dict.stringValueForKey(key: "avgPro")
            fatItemVm.numberLabel.text = dict.stringValueForKey(key: "avgFat")
            
            gapCaloriesLabel.snp.remakeConstraints { make in
                make.left.equalTo(gapTitleLabel)
                make.top.equalTo(gapTitleLabel.snp.bottom).offset(kFitWidth(17))
                make.right.equalTo(carboItemVm.snp.left).offset(kFitWidth(-4))
            }
        }
    }
}

extension JournalReportWeekNaturalCell{
    func initUI() {
        contentView.addSubview(bgView)
        contentView.addSubview(circleView)
        bgView.addSubview(titleLabel)
        contentView.addSubview(iconImgView)
        
        bgView.addSubview(caloriesItemVm)
        bgView.addSubview(carboItemVm)
        bgView.addSubview(proteinItemVm)
        bgView.addSubview(fatItemVm)
        bgView.addSubview(lineHorView)
        bgView.addSubview(lineVerTopView)
        bgView.addSubview(lineVerBottomView)
        bgView.addSubview(gapTitleLabel)
        bgView.addSubview(gapCaloriesLabel)
        bgView.addSubview(gapCarboLabel)
        bgView.addSubview(gapProteinLabel)
        bgView.addSubview(gapFatLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(288))
            make.bottom.equalToSuperview()
        }
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(27))
            make.width.height.equalTo(kFitWidth(6))
        }
        titleLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(45))
            make.left.equalTo(caloriesItemVm)
//            make.right.equalTo(kFitWidth(-40))
//            make.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(circleView)
        }
        iconImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-32))
            make.centerY.lessThanOrEqualTo(circleView)
            make.width.equalTo(kFitWidth(67))
            make.height.equalTo(kFitWidth(12))
        }
        lineHorView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(29))
            make.left.equalTo(caloriesItemVm)
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(0.5))
            make.top.equalTo(kFitWidth(111))
        }
        lineVerTopView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(55))
            make.width.equalTo(kFitWidth(0.5))
            make.centerX.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(50))
        }
        lineVerBottomView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(0.5))
            make.top.equalTo(kFitWidth(117))
            make.height.equalTo(kFitWidth(50))
        }
        gapTitleLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(29))
            make.left.equalTo(caloriesItemVm)
            make.top.equalTo(kFitWidth(193))
        }
        gapCaloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(gapTitleLabel)
            make.top.equalTo(gapTitleLabel.snp.bottom).offset(kFitWidth(17))
            make.right.equalTo(carboItemVm.snp.left).offset(kFitWidth(-4))
            make.height.equalTo(kFitWidth(20))
        }
        gapCarboLabel.snp.makeConstraints { make in
            make.left.equalTo(carboItemVm)
            make.centerY.lessThanOrEqualTo(gapCaloriesLabel)
            make.right.equalTo(carboItemVm.snp.right).offset(kFitWidth(-4))
            make.height.equalTo(gapCaloriesLabel)
        }
        gapProteinLabel.snp.makeConstraints { make in
            make.left.equalTo(gapTitleLabel)
            make.top.equalTo(gapCaloriesLabel.snp.bottom).offset(kFitWidth(7))
            make.right.equalTo(carboItemVm.snp.left).offset(kFitWidth(-4))
            make.height.equalTo(gapCaloriesLabel)
        }
        gapFatLabel.snp.makeConstraints { make in
            make.left.equalTo(carboItemVm)
            make.centerY.lessThanOrEqualTo(gapProteinLabel)
            make.right.equalTo(carboItemVm.snp.right).offset(kFitWidth(-4))
            make.height.equalTo(gapCaloriesLabel)
        }
    }
}
