//
//  NaturalStatCalendarMarkView.swift
//  lns
//
//  Created by LNS2 on 2024/9/13.
//

import Foundation

class NaturalStatCalendarMarkView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(280), height: kFitWidth(122)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
//        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var arcView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(220), y: kFitWidth(32), width: kFitWidth(16), height: kFitWidth(16)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(1)
        return vi
    }()
    lazy var coverGrayView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(52), height: kFitWidth(44)))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var closeImg: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(12), y: 0, width: kFitWidth(24), height: kFitWidth(24)))
        img.setImgLocal(imgName: "stat_calendar_close_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var bgWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(0), width: kFitWidth(280), height: kFitWidth(122)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(8)
        
        return vi
    }()
    lazy var circleV : NaturalStatCalendarMarkCirCleView = {
        let v = NaturalStatCalendarMarkCirCleView.init(frame: CGRect.init(x: kFitWidth(15), y: kFitWidth(21), width: kFitWidth(80), height: kFitWidth(80)))
//        v.frame =  CGRect.init(x: kFitWidth(15), y: kFitWidth(21), width: kFitWidth(80), height: kFitWidth(80))
        return v
    }()
    lazy var cirlcCoverView : NaturalStatCalendarMarkCirCleFillView = {
        let vi = NaturalStatCalendarMarkCirCleFillView.init(frame: self.circleV.frame)
        vi.frame = self.circleV.frame
        return vi
    }()
    lazy var currentNumberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var totalNumberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var carboProgressVm : NaturalStatCalendarMarkProgressView = {
        let vm = NaturalStatCalendarMarkProgressView.init(frame: CGRect.init(x: 0, y: kFitWidth(16), width: 0, height: 0))
        vm.setProgreColor(color: .COLOR_CARBOHYDRATE)
        vm.titleLabel.text = "碳水"
        return vm
    }()
    lazy var proteinProgressVm : NaturalStatCalendarMarkProgressView = {
        let vm = NaturalStatCalendarMarkProgressView.init(frame: CGRect.init(x: 0, y: kFitWidth(50), width: 0, height: 0))
        vm.setProgreColor(color: .COLOR_PROTEIN)
        vm.titleLabel.text = "蛋白质"
        return vm
    }()
    lazy var fatProgressVm : NaturalStatCalendarMarkProgressView = {
        let vm = NaturalStatCalendarMarkProgressView.init(frame: CGRect.init(x: 0, y: kFitWidth(84), width: 0, height: 0))
        vm.setProgreColor(color: .COLOR_FAT)
        vm.titleLabel.text = "脂肪"
        return vm
    }()
}

extension NaturalStatCalendarMarkView{
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.15, delay: 0,options: .curveLinear) {
            self.bgWhiteView.alpha = 0
        }completion: { _ in
            self.isHidden = true
        }
    }
    func updateUI(originX:CGFloat,originY:CGFloat,offsetY:CGFloat,dict:NSDictionary) {
        self.bgWhiteView.alpha = 0
        let currentCalories = Int(dict.doubleValueForKey(key: "calories"))
        var targetCalories = Int(dict.doubleValueForKey(key: "caloriesden"))
        if targetCalories == 0 {
            targetCalories = 1
        }
        
        circleV.setValue(number: Double(currentCalories), total: Double(targetCalories))
        cirlcCoverView.setValue(number: Double(currentCalories), total: Double(targetCalories))
        
        currentNumberLabel.text = "\(currentCalories)"
        totalNumberLabel.text = "/\(targetCalories)千卡"
        
        carboProgressVm.udpateUI(number: dict.doubleValueForKey(key: "carbohydrate"), total: dict.doubleValueForKey(key: "carbohydrateden"))
        proteinProgressVm.udpateUI(number: dict.doubleValueForKey(key: "protein"), total: dict.doubleValueForKey(key: "proteinden"))
        fatProgressVm.udpateUI(number: dict.doubleValueForKey(key: "fat"), total: dict.doubleValueForKey(key: "fatden"))
        
        self.dealWhiteViewFrame(originX: originX, originY: originY, offsetY: offsetY)
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.bgWhiteView.alpha = 1
        }
    }
    
    func dealWhiteViewFrame(originX:CGFloat,originY:CGFloat,offsetY:CGFloat) {
        DLLog(message: "offsetY:\(offsetY)")
        var selfFrame = self.frame
        
        if originX - kFitWidth(204) < 0 {
            selfFrame.origin.x = kFitWidth(0)
        }else if originX - kFitWidth(204) <= SCREEN_WIDHT - kFitWidth(280) {
            selfFrame.origin.x = originX - kFitWidth(204)
        }else{
            selfFrame.origin.x = SCREEN_WIDHT - kFitWidth(280)
        }
        
        if originY + kFitWidth(122) + kFitWidth(78) - offsetY < SCREEN_HEIGHT - WHUtils().getNavigationBarHeight() - kFitWidth(28) - kFitWidth(48){
            selfFrame.origin.y = originY + kFitWidth(78) - offsetY
        } else {
            selfFrame.origin.y = originY - kFitWidth(122)
        }
        
        self.frame = selfFrame
    }
}

extension NaturalStatCalendarMarkView{
    func initUI() {
//        addSubview(arcView)
//        addSubview(coverGrayView)
//        coverGrayView.addSubview(closeImg)
        
        addSubview(bgWhiteView)
        bgWhiteView.addSubview(circleV)
        bgWhiteView.addSubview(cirlcCoverView)
        circleV.addSubview(currentNumberLabel)
        circleV.addSubview(totalNumberLabel)
        
        bgWhiteView.addSubview(carboProgressVm)
        bgWhiteView.addSubview(proteinProgressVm)
        bgWhiteView.addSubview(fatProgressVm)
        
//        arcView.addShadow()
//        arcView.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        bgWhiteView.addShadow()
        
        setConstrait()
    }
    
    func setConstrait() {
        currentNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(70))
            make.top.equalTo(kFitWidth(24))
        }
        totalNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(70))
            make.top.equalTo(kFitWidth(44))
        }
    }
}
