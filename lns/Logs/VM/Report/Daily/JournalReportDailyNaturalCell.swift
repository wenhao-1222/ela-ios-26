//
//  JournalReportDailyNaturalCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//

class JournalReportDailyNaturalCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isSkeletonable = true
        
        return vi
    }()
    lazy var dottlieView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(15), y: 0, width: SCREEN_WIDHT-kFitWidth(62), height: kFitHeight(1)))
        return vi
    }()
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3.5)
        vi.clipsToBounds = true
        vi.isSkeletonable = true
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.isSkeletonable = true
        lab.updateAnimatedSkeleton(usingColor: .red)
        
        return lab
    }()
    lazy var pieSketeView: UIView = {
        let vi = UIView()
        vi.isSkeletonable = true
        
        return vi
    }()
    
}

extension JournalReportDailyNaturalCell{
    func updateUI(dataArr:NSArray) {
//        let whiteViewWidth = SCREEN_WIDHT - kFitWidth(32)
        if dataArr.count > 0 {
            self.hideSkeleton()
            self.pieSketeView.isHidden = true
            titleLab.text = "今日你比原计划"
            for i in 0..<dataArr.count{
                let vm = JournalReportDailyItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(72), width: 0, height: 0))
                let dict = dataArr[i]as? NSDictionary ?? [:]
                vm.updateUI(dict: dict,index: i,totalNum: dataArr.count)
                bgView.addSubview(vm)
            }
        }
    }
}

extension JournalReportDailyNaturalCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(dottlieView)
        bgView.addSubview(circleView)
        bgView.addSubview(titleLab)
        bgView.addSubview(pieSketeView)
        
        setConstrait()
    }
    func setConstrait(){
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(173))
            make.top.bottom.equalToSuperview()
        }
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(32))
            make.width.height.equalTo(kFitWidth(7))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(circleView.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(circleView)
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(20))
        }
        pieSketeView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.right.equalTo(kFitWidth(-15))
            make.top.equalTo(kFitWidth(72))
            make.height.equalTo(kFitWidth(76))
        }
    }
}
