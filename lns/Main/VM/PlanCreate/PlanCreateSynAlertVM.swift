//
//  PlanCreateSynAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/17.
//

import Foundation
import UIKit

class PlanCreateSynAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(0)
    var whiteViewOriginY = kFitWidth(0)
    
    var daysNumber = 1
    var currentDayIndex = 0
    var daysVmArray = [PlanCreateSynDaysVM]()
    
    var synBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var closeImgView : FeedBackUIImageView = {
        let img = FeedBackUIImageView()
        img.setImgLocal(imgName: "date_fliter_cancel_img")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(cancelAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.text = "同步用餐"
        
        return lab
    }()
    lazy var allButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("全选", for: .normal)
        btn.imagePosition(style: .left, spacing: kFitWidth(2))
        btn.setImage(UIImage(named: "logs_edit_normal"), for: .normal)
        btn.setImage(UIImage(named: "logs_edit_selected"), for: .selected)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(selectAllVm), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "将当前（第3天）用餐同步到其他日期"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    
    lazy var synButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("确认同步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(synAction), for: .touchUpInside)
        
        return btn
    }()
}

extension PlanCreateSynAlertVM{
    func refreshDaysNum(days:Int) {
        daysNumber = days
        for i in 0..<daysVmArray.count{
            let vm = daysVmArray[i]
            
            if i < days{
                vm.isHidden = false
            }else{
                vm.isHidden = true
            }
        }
        
        let vmMaxY = kFitWidth(130) + (kFitWidth(56)+kFitWidth(8)) * CGFloat((days+2)/3)
        let bgViewHeight = vmMaxY + kFitWidth(76) + WHUtils().getBottomSafeAreaHeight()
        
        bgView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: bgViewHeight+kFitWidth(16))
        whiteViewHeight = bgViewHeight + kFitWidth(16)
        whiteViewOriginY = SCREEN_HEIGHT - bgViewHeight
    }
    func setCurrentDay(dayIndex:Int){
        self.currentDayIndex = dayIndex
        tipsLabel.text = "将当前（第\(dayIndex+1)天）用餐同步到其他日期"
        for i in 0..<daysVmArray.count{
            let vm = daysVmArray[i]
            vm.isUserInteractionEnabled = true
            vm.contentLabel.text = "第 \(i+1) 天"
            vm.contentLabel.textColor = .COLOR_GRAY_BLACK_85
            if i == dayIndex{
                vm.isUserInteractionEnabled = false
                vm.contentLabel.text = "第 \(i+1) 天\n当前"
                vm.contentLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
            }
        }
    }
    func clearSelectStatu() {
        allButton.isSelected = false
        synButton.isEnabled = false
        for i in 0..<daysVmArray.count{
            let vm = daysVmArray[i]
            vm.setSelectStatus(select: false)
        }
    }
    @objc func selectAllVm() {
        allButton.isSelected = !allButton.isSelected
        synButton.isEnabled = allButton.isSelected ? true : false
        for i in 0..<daysVmArray.count{
            if i != currentDayIndex{
                let vm = daysVmArray[i]
                vm.setSelectStatus(select: allButton.isSelected)
            }
        }
    }
    func judgeSelectStatus() {
        synButton.isEnabled = false
        var isSelecteAll = true
        for i in 0..<daysNumber{
            if i != currentDayIndex{
                let vm = daysVmArray[i]
                if vm.isSelect == true{
                    synButton.isEnabled = true
                    break
                }
            }
        }
        for i in 0..<daysNumber{
            if i != currentDayIndex{
                let vm = daysVmArray[i]
                if vm.isSelect == false{
                    isSelecteAll = false
                    break
                }
            }
        }
        if isSelecteAll{
            allButton.isSelected = true
        }else{
            allButton.isSelected = false
        }
    }
    @objc func nothingToDo(){
        
    }
    @objc func cancelAction() {
        self.hiddenView()
   }
    @objc func synAction(){
        if self.synBlock != nil{
            self.synBlock!()
        }
        self.hiddenView()
    }
    @objc func showView() {
        self.isHidden = false
        self.clearSelectStatu()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.bgView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }
   }
   @objc func hiddenView() {
       UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
           self.bgView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
           self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
       }completion: { t in
           self.isHidden = true
       }
  }
}
extension PlanCreateSynAlertVM{
    func initUI() {
        addSubview(bgView)
        
        bgView.addSubview(lineView)
        bgView.addSubview(closeImgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(allButton)
        bgView.addSubview(tipsLabel)
        bgView.addSubview(synButton)
        
        initVmsArray()
        
        setConstrait()
        setCurrentDay(dayIndex: 0)
    }
    
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(55))
            make.height.equalTo(kFitWidth(1))
        }
        closeImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(24))
        }
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(55))
        }
        allButton.snp.makeConstraints { make in
//            make.centerY.lessThanOrEqualTo(closeImgView)
            make.right.equalToSuperview()
            make.width.equalTo(kFitWidth(88))
            make.top.height.equalTo(titleLab)
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(24))
        }
        synButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-12)-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(48))
        }
    }
    
    func initVmsArray(){
        var originX = kFitWidth(16)
        var originY = kFitWidth(130)
        let vmWidth = isIpad() ? ((SCREEN_WIDHT-kFitWidth(48))/3) : kFitWidth(109)
        for i in 0..<7{
            originX = kFitWidth(16) + (vmWidth+kFitWidth(8)) * CGFloat(i%3)
            originY = kFitWidth(130) + (kFitWidth(56)+kFitWidth(8)) * CGFloat(i/3)
            let vm = PlanCreateSynDaysVM.init(frame: CGRect.init(x: originX, y: originY, width: vmWidth, height: kFitWidth(56)))
            vm.contentLabel.text = "第 \(i+1) 天"
            vm.days = "\(i+1)"
            
            bgView.addSubview(vm)
            daysVmArray.append(vm)
            
            vm.tapBlock = {()in
                self.judgeSelectStatus()
            }
        }
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: view)
                DLLog(message: "translation.y:\(translation.y)")
                if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                    self.hiddenView()
                }else{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.bgView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                    }
                }
            default:
                break
            }
        }
    }
}
