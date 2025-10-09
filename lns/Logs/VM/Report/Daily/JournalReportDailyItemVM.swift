//
//  JournalReportDailyItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//


class JournalReportDailyItemVM: UIView {
    
    let selfWidth = kFitWidth(95)
    let selfHeight = kFitWidth(76)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var detailLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var typeLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textAlignment = .center
        return lab
    }()
}

extension JournalReportDailyItemVM{
    func updateUI(dict:NSDictionary,index:Int,totalNum:Int) {
        detailLab.text = dict.stringValueForKey(key: "text")
        if dict.stringValueForKey(key: "type") == "CHO" {
            typeLabel.text = "碳水"
            imgView.setImgLocal(imgName: "report_daily_carbo_icon")
        }else if dict.stringValueForKey(key: "type") == "PRO" {
            typeLabel.text = "蛋白质"
            imgView.setImgLocal(imgName: "report_daily_protein_icon")
        }else if dict.stringValueForKey(key: "type") == "FAT" {
            typeLabel.text = "脂肪"
            imgView.setImgLocal(imgName: "report_daily_fat_icon")
        }
        
        updateFrame(index: index, totalNum: totalNum)
    }
    func updateFrame(index:Int,totalNum:Int) {
        let whiteWidth = SCREEN_WIDHT-kFitWidth(32)
        let selfCenter = self.center
        if index == 0 {
            if totalNum == 1 {
                self.center = CGPoint.init(x: whiteWidth*0.5, y: selfCenter.y)
            }else if totalNum == 2{
                self.center = CGPoint.init(x: whiteWidth*0.3, y: selfCenter.y)
            }else if totalNum == 3{
                self.center = CGPoint.init(x: kFitWidth((15)+selfWidth*0.5), y: selfCenter.y)
            }
        }else if index == 1{
            if totalNum == 2 {
                self.center = CGPoint.init(x: whiteWidth*0.7, y: selfCenter.y)
            }else if totalNum == 3 {
                self.center = CGPoint.init(x: whiteWidth*0.5, y: selfCenter.y)
            }
        }else if index == 2{
            self.center = CGPoint.init(x: whiteWidth - kFitWidth(15) - selfWidth*0.5, y: selfCenter.y)
        }
    }
}

extension JournalReportDailyItemVM{
    func initUI() {
        addSubview(imgView)
        addSubview(detailLab)
        addSubview(typeLabel)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(30))
        }
        detailLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(42))
        }
        typeLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
