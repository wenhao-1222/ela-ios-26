//
//  LogsNaviVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation
import UIKit

class LogsNaviVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    var choiceTimeBlock:(()->())?
    var lastDayBlock:(()->())?
    var nextDayBlock:(()->())?
    var delBlock:(()->())?
    var shareBlock:(()->())?
    var fitnessBlock:(()->())?
    var controller = WHBaseViewVC()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.alpha = 0
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var editButton: FeedBackTapButton = {
        let btn = FeedBackTapButton()
        btn.setTitle("编辑", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        btn.addTarget(self, action: #selector(delAction), for: .touchUpInside)
        btn.generatorWeight = 0.9
        btn.addPressEffect()
//        btn.enablePressEffect()
        
        return btn
    }()
    lazy var lastButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "plan_detail_arrow_icon_left"), for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.setTitle("", for: .normal)
        btn.setImage(UIImage(named: "plan_detail_arrow_highlight_icon_left"), for: .highlighted)
        
        btn.addTarget(self, action: #selector(lastAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var dateButton : GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("今日", for: .normal)
        
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(choiceTimeAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
    lazy var nextButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "plan_detail_arrow_icon_right"), for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.setImage(UIImage(named: "plan_detail_arrow_highlight_icon"), for: .highlighted)
        
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return btn
    }()
//    lazy var listIcon: GJVerButton = {
//        let btn = GJVerButton()
//        btn.setImage(UIImage.init(named: "logs_navi_list_icon"), for: .normal)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
//        
//        btn.addTarget(self, action: #selector(planListTapAction), for: .touchUpInside)
//        
//        return btn
//    }()
    lazy var fitnessLabel: UILabel = {
        let lab = UILabel()
        lab.layer.cornerRadius = kFitWidth(3)
        lab.clipsToBounds = true
        lab.textAlignment = .center
//        lab.text = "一"
        lab.text = "-"
        lab.adjustsFontSizeToFitWidth = true
        lab.font = .systemFont(ofSize: 10, weight: .semibold)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.layer.borderWidth = kFitWidth(1.5)
        lab.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor
        
        lab.isUserInteractionEnabled = true
//        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(fitnessTapAction))
//        lab.addGestureRecognizer(tap)
        
        return lab
    }()
    lazy var fitnessTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(fitnessTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var shareIcon: GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage.init(named: "logs_navi_share_icon"), for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        
        btn.addTarget(self, action: #selector(shareTapAction), for: .touchUpInside)
        return btn
    }()
}

extension LogsNaviVM {
    func changeBgAlpha(offsetY:CGFloat) {
        if offsetY > 0 {
            let percent = offsetY/kFitWidth(280)//offsetY/selfHeight
            self.bgView.alpha = percent
        }else{
            self.bgView.alpha = 0
        }
    }
    
    @objc func delAction(){
        if delBlock != nil{
            delBlock!()
        }
    }
    @objc func lastAction(){
        disableButton()
        if lastDayBlock != nil{
            lastDayBlock!()
        }
    }
    @objc func nextAction(){
        disableButton()
        if nextDayBlock != nil{
            nextDayBlock!()
        }
    }
    @objc func planListTapAction() {
        let vc = PlanListVC()
        self.controller.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func shareTapAction() {
        if self.shareBlock != nil{
            self.shareBlock!()
        }
    }
    @objc func fitnessTapAction() {
        self.fitnessBlock?()
    }
    @objc func choiceTimeAction() {
        if self.choiceTimeBlock != nil{
            self.choiceTimeBlock!()
        }
    }
    func disableButton() {
//        self.lastButton.isEnabled = false
//        self.nextButton.isEnabled = false
    }
    func enableButton() {
        self.lastButton.isEnabled = true
        self.nextButton.isEnabled = true
    }
    func setDate(time:String) {
//        if time == 
        dateButton.setTitle("\(time)", for: .normal)
        dateButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        dateButton.imagePosition(style: .right, spacing: kFitWidth(2))
//        lastButton.snp.remakeConstraints { make in
//            make.right.equalTo(dateButton.snp.left)
//            make.centerY.lessThanOrEqualToSuperview()
//            make.width.height.equalTo(kFitWidth(24))
//        }
    }
    @objc func changeDate(date:String){
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"// 自定义时间格式
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")
        let dateT = dateformatter.date(from: date) ?? Date()
        
        if dateformatter.string(from: dateT) == Date().nextDay(days: 0){
            setDate(time: "今日")
//            setDate(time: "今日 \(getWeekDaysText(date: dateT))")
        }else{
            setDate(time: changeDate(date: dateT))
        }
//        DLLog(message: "weekIndex:  --- \(date)")
    }
    private func changeDate(date:Date) -> String{
        let  dateFormater = DateFormatter.init()
//        dateFormater.dateFormat = "yyyy-MM-dd"
        dateFormater.dateFormat = "M月d日 \(getWeekDaysText(date: date))"
        
        return "\(dateFormater.string(from: date))"
    }
    private func getWeekDaysText(date:Date) -> String{
        let weekIndex = Date().getWeekdayIndex(from: date)
//        DLLog(message: "weekIndex:  --- \(weekIndex)")
        if weekIndex == 1 {
            return "周一"
        }else if weekIndex == 2 {
            return "周二"
        }else if weekIndex == 3 {
            return "周三"
        }else if weekIndex == 4 {
            return "周四"
        }else if weekIndex == 5 {
            return "周五"
        }else if weekIndex == 6 {
            return "周六"
        }else{
            return "周日"
        }
    }
}
extension LogsNaviVM {
    func initUI() {
        addSubview(bgView)
        addSubview(editButton)
        addSubview(dateButton)
        addSubview(lastButton)
        addSubview(nextButton)
//        addSubview(listIcon)
        addSubview(fitnessLabel)
        addSubview(fitnessTapView)
        addSubview(shareIcon)
        setConstrait()
        dateButton.imagePosition(style: .right, spacing: kFitWidth(2))
//        bgView.addShadow(opacity: 0.05)
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.top.equalTo(-statusBarHeight)
            make.left.width.bottom.equalToSuperview()
        }
        editButton.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(60))
        }
        shareIcon.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-8))
            make.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(40))
        }
//        listIcon.snp.makeConstraints { make in
//            make.right.equalTo(shareIcon.snp.left)
//            make.width.top.height.equalTo(shareIcon)
//        }
        fitnessLabel.snp.makeConstraints { make in
            make.right.equalTo(shareIcon.snp.left).offset(kFitWidth(-10))
            make.width.height.equalTo(kFitWidth(18))
            make.centerY.lessThanOrEqualTo(shareIcon)
        }
        fitnessTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(fitnessLabel)
            make.width.height.equalTo(kFitWidth(40))
        }
        dateButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(114))
            make.top.height.equalToSuperview()
        }
        lastButton.snp.makeConstraints { make in
            make.right.equalTo(dateButton.snp.left).offset(kFitWidth(-4))
//            make.left.equalTo(kFitWidth(115))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(28))
        }
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(dateButton.snp.right).offset(kFitWidth(-4))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(28))
        }
        
    }
}
