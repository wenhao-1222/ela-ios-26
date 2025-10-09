//
//  LoginAlertVm.swift
//  lns
//
//  Created by LNS2 on 2024/4/2.
//

import Foundation
import UIKit

class LoginAlertVm: UIView {
    
    var whiteViewHeight = kFitWidth(473)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(16)
    var whiteViewOriginY = kFitWidth(0)
    
    var weChatLoginBlock:(()->())?
    var appleLoginBlock:(()->())?
    var phoneLoginBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        initUI()
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
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
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        return vi
    }()
    lazy var topLineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        vi.layer.cornerRadius = kFitWidth(2)
        
        return vi
    }()
    lazy var topCloseTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenLoginView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "登录Elavatine"
        lab.textColor = WHColor_16(colorStr: "262626")
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var weChatButton : GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("使用微信账户登录", for: .normal)
        btn.setImage(UIImage.init(named: "login_alert_wechat_icon"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = WHColor_16(colorStr: "1F9947")
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(weChatLoginAction), for: .touchUpInside)
        
        btn.enablePressEffect()
        
        if WXApi.isWXAppInstalled() == false{
            btn.isHidden = true
        }
        
        return btn
    }()
    lazy var appleButton : GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("使用 Apple 账户登录", for: .normal)
        btn.setImage(UIImage.init(named: "login_alert_apple_icon"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .COLOR_GRAY_BLACK_85
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(appleLoginAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
    lazy var phoneButton : GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("使用手机号登录", for: .normal)
        btn.setImage(UIImage.init(named: "login_alert_phone_icon"), for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.1)), for: .highlighted)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.layer.borderColor = UIColor.COLOR_GRAY_BLACK_85.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.addTarget(self, action: #selector(phoneLoginAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
    lazy var orLineLeft : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var orLabel : UILabel = {
        let lab = UILabel()
        lab.text = "或者"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var orLineRight : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var notLoginBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("暂不登录", for: .normal)
        btn.backgroundColor = .clear
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.addTarget(self, action: #selector(hiddenLoginView), for: .touchUpInside)
        
        return btn
    }()
}

extension LoginAlertVm{
     @objc func weChatLoginAction() {
//         hiddenLoginView()
         if self.weChatLoginBlock != nil{
             self.weChatLoginBlock!()
         }
     }
     @objc func appleLoginAction() {
         if self.appleLoginBlock != nil{
             self.appleLoginBlock!()
         }
     }
     @objc func phoneLoginAction() {
         if self.phoneLoginBlock != nil{
             self.phoneLoginBlock!()
         }
     }
     @objc func showLoginView() {
         self.isHidden = false
         
         bgView.isUserInteractionEnabled = false
         
         // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
         whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
         bgView.alpha = 0

         UIView.animate(withDuration: 0.45,
                        delay: 0.02,
                        usingSpringWithDamping: 0.88,
                        initialSpringVelocity: 0.1,
                        options: [.curveEaseOut, .allowUserInteraction]) {
             self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
             self.bgView.alpha = 0.25
         } completion: { _ in
             self.bgView.isUserInteractionEnabled = true
             
         }
         UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
             self.whiteView.transform = .identity
         }
//         UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
////             self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
////             self.whiteView.frame = CGRect.init(x: 0, y: self.whiteViewOriginY, width: SCREEN_WIDHT, height: self.whiteViewHeight)
//             self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
//             self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
//         }completion: { t in
////             self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
//         }
    }
    @objc func hiddenLoginView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
//        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
//        }completion: { t in
//            self.isHidden = true
//        }
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
                    self.hiddenLoginView()
                }else{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                    }
                }
            default:
                break
            }
        }
    }
}

extension LoginAlertVm{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        addSubview(topCloseTapView)
        
        whiteView.addSubview(topLineView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(weChatButton)
        whiteView.addSubview(appleButton)
        whiteView.addSubview(phoneButton)
        
        whiteView.addSubview(orLineLeft)
        whiteView.addSubview(orLabel)
        whiteView.addSubview(orLineRight)
        whiteView.addSubview(notLoginBtn)
        
        layoutWhiteViewFrame()
        setConstrait()
        // 初始位置放在最终停靠位置，实际展示用 transform 下移
        whiteView.transform = .identity
    }
    
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait() {
//        whiteView.snp.makeConstraints { make in
//            make.left.width.equalToSuperview()
//            make.height.equalTo(whiteViewHeight)
//            make.bottom.equalTo(kFitWidth(16)+SCREEN_HEIGHT)
//        }
        topCloseTapView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT-whiteViewHeight+kFitWidth(40))
        }
        topLineView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(18))
            make.width.equalTo(kFitWidth(43))
            make.height.equalTo(kFitWidth(4))
            make.centerX.lessThanOrEqualToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
        }
        weChatButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(327))
            make.height.equalTo(kFitWidth(56))
            make.top.equalTo(kFitWidth(124))
        }
        appleButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(weChatButton)
            make.top.equalTo(weChatButton.snp.bottom).offset(kFitWidth(12))
        }
        phoneButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(appleButton)
            make.top.equalTo(kFitWidth(300))
        }
        orLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(268))
        }
        orLineLeft.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(48))
            make.width.equalTo(kFitWidth(120))
            make.height.equalTo(kFitWidth(1))
            make.centerY.lessThanOrEqualTo(orLabel)
        }
        orLineRight.snp.makeConstraints { make in
            make.width.height.equalTo(orLineLeft)
            make.centerY.lessThanOrEqualTo(orLabel)
            make.right.equalTo(kFitWidth(-48))
        }
        notLoginBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(phoneButton.snp.bottom).offset(kFitWidth(25))
            make.height.equalTo(kFitWidth(20))
        }
    }
}
