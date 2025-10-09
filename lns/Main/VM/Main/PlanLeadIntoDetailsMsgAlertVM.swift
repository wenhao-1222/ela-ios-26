//
//  PlanLeadIntoDetailsMsgAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit
import MCToast

class PlanLeadIntoDetailsMsgAlertVM: UIView {
    
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    
    var saveBlock:(()->())?
    
    var whiteViewFrame = CGRect()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.alpha = 0
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
        
        self.whiteViewFrame = whiteView.frame
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(28), y: kFitWidth(160)+statusBarHeight, width: kFitWidth(320), height: kFitWidth(386)))
        vi.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        vi.backgroundColor = .white
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var bgImgView : UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(320), height: kFitWidth(314)))
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "plan_get_alert_bg_img")
        
        return img
    }()
    lazy var nameVm : PlanShareDetailsNameVM = {
        let vm = PlanShareDetailsNameVM.init(frame: CGRect.init(x: kFitWidth(20), y: kFitWidth(20), width: kFitWidth(280), height: kFitWidth(28)))
        
        return vm
    }()
    lazy var contentWhiteView : PlanShareDetailsContentVM = {
        let vm  = PlanShareDetailsContentVM.init(frame: CGRect.init(x: kFitWidth(20), y: kFitWidth(56), width: kFitWidth(280), height: kFitWidth(170)))
        
        return vm
    }()
    
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(20), y: kFitWidth(274), width: kFitWidth(280), height: kFitWidth(48))
        btn.setTitle("确认导入该计划", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var cancelButton : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(20), y: kFitWidth(330), width: kFitWidth(280), height: kFitWidth(48))
        btn.setTitle("暂不导入", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
}

extension PlanLeadIntoDetailsMsgAlertVM{
    
    @objc func nothingToDo() {
        
    }
    @objc func nextAction(){
        if self.saveBlock != nil{
            self.saveBlock!()
        }
    }
    func refreshUI(dict:NSDictionary) {
        nameVm.refreshUI(name: dict["nickname"]as? String ?? "用户名称", avatar: dict["avatar"]as? String ?? "")
        contentWhiteView.refreshUI(dict: dict)
        self.showView()
    }
    func showView() {
        self.isHidden = false
        whiteView.alpha = 0
        self.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
            self.alpha = 1
        }
    }
    
    @objc func hiddenView() {
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.alpha = 0
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
}
extension PlanLeadIntoDetailsMsgAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(bgImgView)
        whiteView.addSubview(nameVm)
        whiteView.addSubview(contentWhiteView)
        
        whiteView.addSubview(nextBtn)
        whiteView.addSubview(cancelButton)
        
        setConstrait()
    }
    func setConstrait() {
        
    }
}
