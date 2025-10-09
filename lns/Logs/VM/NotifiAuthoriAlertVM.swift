//
//  NotifiAuthoriAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/11.
//


import Foundation
import UIKit

class NotifiAuthoriAlertVM: UIView {
    
    var whiteViewHeight = WHUtils().getBottomSafeAreaHeight()+kFitWidth(412)+kFitWidth(16)
    var controller = WHBaseViewVC()
    var acceptBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
//        self.alpha = 0
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
//        vi.addGestureRecognizer(tap)
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
//        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
//        v.addGestureRecognizer(tap)
        return v
    }()

    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "接受 Elavatine 向你发送 \n的「漏记提醒」通知"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.setLineHeight(textString: "接受 Elavatine 向你发送 \n的「漏记提醒」通知",lineHeight: kFitWidth(30))
        
        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "notifi_tips_img")
        
        return img
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.setLineHeight(textString: "放心，我们没事不会打扰你\n只有漏记才提示，助你养成自律习惯",lineHeight: kFitWidth(24))
        
        return lab
    }()
    lazy var buttonBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var negativeButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("不", for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.layer.borderWidth = kFitWidth(1)
        btn.layer.borderColor = UIColor.COLOR_GRAY_808080.cgColor
        
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var acceptButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("好", for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        return btn
    }()
}
extension NotifiAuthoriAlertVM{
    func showView() {
        self.isHidden = false
        UserInfoModel.shared.showNotifiAuthoriAlertVM = false
        
        bgView.isUserInteractionEnabled = false
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0
        whiteView.alpha = 1
//        self.alpha = 1
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(14)))
            self.bgView.alpha = 0.25
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
            
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
        }
        
//        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//            self.alpha = 1
//            self.whiteView.alpha = 1
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
//        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
//        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//            self.alpha = 0
//            self.whiteView.alpha = 0.7
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
//        }completion: { t in
//            self.isHidden = true
//        }
    }
    
    
    @objc func nothingAction(){
        
    }
    @objc func cancelAction(){
        self.hiddenView()
    }
    @objc func acceptAction(){
        self.hiddenView()
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .denied {
                DLLog(message:"denied")
                DispatchQueue.main.async {
                    self.controller.openUrl(urlString: UIApplication.openSettingsURLString)
                }
            }else{
                DLLog(message:"other")
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { granted, _ in
                    if granted == false {
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            if settings.authorizationStatus == .denied {
                                
                            }
                        }
                    }
                }
            }
        }
    }
}

extension NotifiAuthoriAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(imgView)
        whiteView.addSubview(tipsLabel)
        
        whiteView.addSubview(buttonBgView)
        buttonBgView.addSubview(negativeButton)
        buttonBgView.addSubview(acceptButton)
        
        layoutWhiteViewFrame()
        setConstrait()
        
        buttonBgView.addShadow()
        
        // 初始位置放在最终停靠位置，实际展示用 transform 下移
        whiteView.transform = .identity
    }
    
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
//        whiteView.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(34))
        }
        imgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(112))
            make.width.equalTo(kFitWidth(325))
            make.height.equalTo(kFitWidth(150))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(18))
        }
        buttonBgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-16))
            make.height.equalTo(WHUtils().getBottomSafeAreaHeight()+kFitWidth(55))
        }
        negativeButton.snp.makeConstraints { make in
            make.right.equalTo(-SCREEN_WIDHT*0.5-kFitWidth(8))
            make.width.equalTo(kFitWidth(164))
            make.height.equalTo(kFitWidth(44))
            make.top.equalTo(kFitWidth(5))
        }
        acceptButton.snp.makeConstraints { make in
            make.width.height.top.equalTo(negativeButton)
            make.left.equalTo(SCREEN_WIDHT*0.5+kFitWidth(8))
        }
    }
}
