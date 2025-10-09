//
//  PlanListSearchVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import UIKit

class PlanListSearchVM: UIView {
    
    let selfHeight = kFitWidth(56)+WHUtils().getNavigationBarHeight()
    
    var backBlock:(()->())?
    var searchBlock:(()->())?
    var getPlanBlock:(()->())?
    var leadPlanBlock:(()->())?
    var createPlanBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var seachBgView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var seachImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_search_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(searchTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var textField: ChineseTextField = {
        let text = ChineseTextField()
        text.placeholder = "搜索饮食计划"
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.returnKeyType = .search
        text.delegate = self
        text.textContentType = nil
        text.textNumber = 50
        
        return text
    }()
    lazy var backArrowImg : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "back_arrow")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var backTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var getPlanButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "plan_get_icon"), for: .normal)
        btn.setTitle("获取计划", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        btn.addTarget(self, action: #selector(getPlanTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var leadPlanButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "plan_lead_icon"), for: .normal)
        btn.setTitle("导入计划", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        btn.addTarget(self, action: #selector(leadPlanTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var createPlanButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "plan_create_icon"), for: .normal)
        btn.setTitle("制作计划", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        btn.addTarget(self, action: #selector(createPlanTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        
        return vi
    }()
    lazy var lineViewTwo : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        
        return vi
    }()
}

extension PlanListSearchVM{
    @objc func backAction() {
        if self.backBlock != nil{
            self.backBlock!()
        }
    }
    @objc func searchTapAction(){
        if self.searchBlock != nil{
            self.searchBlock!()
        }
        self.textField.resignFirstResponder()
    }
    @objc func getPlanTapAction(){
        if self.getPlanBlock != nil{
            self.getPlanBlock!()
        }
        self.textField.resignFirstResponder()
    }
    @objc func leadPlanTapAction(){
        if self.leadPlanBlock != nil{
            self.leadPlanBlock!()
        }
        self.textField.resignFirstResponder()
    }
    @objc func createPlanTapAction(){
        if self.createPlanBlock != nil{
            self.createPlanBlock!()
        }
        self.textField.resignFirstResponder()
    }
}

extension PlanListSearchVM{
    func initUI() {
        addSubview(seachBgView)
        seachBgView.addSubview(seachImgView)
        seachBgView.addSubview(textField)
        
        addSubview(backArrowImg)
        addSubview(backTapView)
        addSubview(getPlanButton)
        addSubview(leadPlanButton)
        addSubview(createPlanButton)
        addSubview(lineView)
        addSubview(lineViewTwo)
        
        setConstrait()
    }
    func setConstrait() {
        seachBgView.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(314))
            make.height.equalTo(kFitWidth(36))
            make.top.equalTo(statusBarHeight+kFitWidth(4))
            make.left.equalTo(kFitWidth(45))
        }
        seachImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.top.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-36))
        }
        backArrowImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualTo(seachBgView)
            make.width.height.equalTo(kFitWidth(24))
        }
        backTapView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.lessThanOrEqualTo(backArrowImg)
            make.height.equalTo(kFitWidth(44))
            make.right.equalTo(seachBgView.snp.left)
        }
        getPlanButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
            make.width.equalTo(SCREEN_WIDHT*0.33)
        }
        leadPlanButton.snp.makeConstraints { make in
//            make.left.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
            make.width.equalTo(SCREEN_WIDHT*0.33)
        }
        createPlanButton.snp.makeConstraints { make in
            make.bottom.height.width.equalTo(getPlanButton)
            make.right.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
            make.left.equalTo(leadPlanButton)
            make.centerY.lessThanOrEqualTo(getPlanButton)
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(24))
        }
        lineViewTwo.snp.makeConstraints { make in
            make.left.equalTo(createPlanButton)
            make.centerY.lessThanOrEqualTo(getPlanButton)
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(24))
        }
    }
}

extension PlanListSearchVM:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapAction()
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
//        if string.isNineKeyBoard() {
//            return true
//        }else{
//            if string.hasEmoji() || string.containsEmoji() || string.isChineseNumberAscii(){
//                return false
//            }
//        }

        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        
        return true
    }
}
