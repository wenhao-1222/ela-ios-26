//
//  NaturalStatNaviVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/3.
//

import Foundation

class NaturalStatNaviVM: UIView {
    
    let selfHeight = WHUtils().getNavigationBarHeight() + kFitWidth(28)
    
    var selectType = "left"
    
    var statTypeBlock:((String)->())?
    var timetypeBlock:(()->())?
    var monthBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var topLogoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "navi_logo_img")
        return img
    }()
    lazy var backArrowButton: NaviBackButton = {
        let btn = NaviBackButton.init(frame: CGRect.init(x: 0, y: statusBarHeight+kFitWidth(28), width: kFitWidth(44), height: kFitWidth(44)))
        return btn
    }()
    lazy var leftTitleButton: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5-kFitWidth(60), y: selfHeight-kFitWidth(44), width: kFitWidth(60), height: kFitWidth(44)))
        btn.setTitle("统计", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.85), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.isSelected = true
        
        btn.addTarget(self, action: #selector(leftTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var rightTitleButton: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5, y: selfHeight-kFitWidth(44), width: kFitWidth(60), height: kFitWidth(44)))
        btn.setTitle("日历", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.85), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        
        btn.addTarget(self, action: #selector(rightTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var selectBottomLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var bodyTypeButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(88), y: selfHeight-kFitWidth(44), width: kFitWidth(88), height: kFitWidth(44)))
        btn.setTitle("近一周", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.imagePosition(style: .right, spacing: kFitWidth(2))
        
        btn.addTarget(self, action: #selector(typeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var monthButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(98), y: selfHeight-kFitWidth(44), width: kFitWidth(98), height: kFitWidth(44)))
        let yearMonth = Date().currenYearMonthM
        btn.setTitle("\(yearMonth[0]as? String ?? "")年\(yearMonth[1]as? String ?? "")月", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.imagePosition(style: .right, spacing: kFitWidth(2))
        btn.isHidden = true
        
        btn.addTarget(self, action: #selector(monthAction), for: .touchUpInside)
        
        return btn
    }()
}

extension NaturalStatNaviVM{
    @objc func leftTapAction() {
        if selectType == "left"{
            return
        }
        selectType = "left"
        leftTitleButton.isSelected = true
        rightTitleButton.isSelected = false
        if self.statTypeBlock != nil{
            self.statTypeBlock!(self.selectType)
        }
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.selectBottomLineView.center = CGPoint.init(x: self.leftTitleButton.center.x, y: self.selfHeight-kFitWidth(2))
        }
    }
    @objc func rightTapAction() {
        if selectType == "right"{
            return
        }
        selectType = "right"
        rightTitleButton.isSelected = true
        leftTitleButton.isSelected = false
        if self.statTypeBlock != nil{
            self.statTypeBlock!(self.selectType)
        }
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.selectBottomLineView.center = CGPoint.init(x: self.rightTitleButton.center.x, y: self.selfHeight-kFitWidth(2))
        }
    }
    @objc func typeAction(){
        if self.timetypeBlock != nil{
            self.timetypeBlock!()
        }
    }
    @objc func monthAction(){
        if self.monthBlock != nil{
            self.monthBlock!()
        }
    }
    func changeStatType(type:String) {
        if type == "left"{
            bodyTypeButton.isHidden = false
            monthButton.isHidden = true
        }else{
            bodyTypeButton.isHidden = true
            monthButton.isHidden = false
        }
    }
    func updateTimeText(name:String){
        bodyTypeButton.setTitle("\(name)", for: .normal)
        bodyTypeButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        bodyTypeButton.imagePosition(style: .right, spacing: kFitWidth(2))
    }
    func updateTimeTextForMonth(name:String){
        monthButton.setTitle("\(name)", for: .normal)
        monthButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        monthButton.imagePosition(style: .right, spacing: kFitWidth(2))
    }
}
extension NaturalStatNaviVM{
    func initUI() {
        addSubview(topLogoImgView)
        
        addSubview(backArrowButton)
        addSubview(leftTitleButton)
        addSubview(rightTitleButton)
        addSubview(selectBottomLineView)
        
        addSubview(bodyTypeButton)
        addSubview(monthButton)
        
        setConstrait()
    }
    func setConstrait() {
        topLogoImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(statusBarHeight+kFitWidth(4))
            make.width.equalTo(kFitWidth(83.5))
            make.height.equalTo(kFitWidth(15))
        }
//        leftTitleButton.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
//            make.height.equalTo(kFitWidth(44))
//            make.right.equalTo(SCREEN_WIDHT*0.5)
//            make.width.equalTo(kFitWidth(60))
//        }
//        rightTitleButton.snp.makeConstraints { make in
//            make.left.equalTo(SCREEN_WIDHT*0.5)
//            make.width.height.bottom.equalTo(leftTitleButton)
//        }
        selectBottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(4))
            make.centerX.lessThanOrEqualTo(leftTitleButton)
        }
    }
}
