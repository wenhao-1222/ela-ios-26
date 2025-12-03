//
//  ActivityAlertVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/3.
//


import Foundation
import UIKit
import Kingfisher

class ActivityAlertVM: UIView {
    
    var whiteViewHeight = WHUtils().getBottomSafeAreaHeight()+kFitWidth(412)+kFitWidth(16)
    var controller = WHBaseViewVC()
    var pushBlock:((String)->())?
    
    var dictOne = NSDictionary()
    var dictTwo = NSDictionary()
    
    
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        } else {
            // iOS 13 以下没有深色模式，按浅色处理
            return 0.25
        }
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
   override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       super.traitCollectionDidChange(previousTraitCollection)
       if #available(iOS 13.0, *),
          previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
          !isHidden {
           UIView.animate(withDuration: 0.2) {
               self.bgView.alpha = self.targetDimAlpha
           }
       }
   }
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK//WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        
        return v
    }()

    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
//        vi.layer.cornerRadius = kFitWidth(16)
//        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(50)
        img.clipsToBounds = true
        img.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        img.layer.borderWidth = kFitWidth(1.5)
        return img
    }()
    lazy var confirmButton: FeedBackButton = {
        let btn = FeedBackButton()
//        btn.setTitle("不", for: .normal)
        btn.backgroundColor = .COLOR_BG_WHITE
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(30)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var missButton: UIButton = {
        let btn = UIButton()
//        btn.setTitle("好", for: .normal)
        btn.backgroundColor = .clear
        btn.setTitleColor(WHColorWithAlpha(colorStr: "0F1214", alpha: 0.4), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
//        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()
}
extension ActivityAlertVM{
    func updateUI(dict:NSDictionary) {
        let imgArr = dict["image"]as? NSArray ?? []
        if imgArr.count > 0{
            self.dealButtonMsg(dict: dict)
            let imgUrl = imgArr[0]as? String ?? ""
            DSImageUploader().dealImgUrlSignForOss(urlStr: imgUrl) { signUrl in
                guard let resourceUrl = URL(string: signUrl) else{
                    return
                }
                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: imgUrl)
                self.imgView.kf.setImage(with: resource,options: [.transition(.fade(0.2))]) { [self] result in
                    let imgOriSize = imgView.image?.size
                    self.whiteViewHeight = SCREEN_WIDHT * ((imgOriSize?.height ?? 0) / (imgOriSize?.width ?? 1))
                    
                    self.layoutWhiteViewFrame()
                    self.showView()
                }
            }
        }
    }
    func dealButtonMsg(dict:NSDictionary) {
        let buttonArr = dict["button"]as? NSArray ?? []
        if buttonArr.count == 1{
            dictOne = buttonArr[0]as? NSDictionary ?? [:]
            confirmButton.setTitle(dictOne.stringValueForKey(key: "text"), for: .normal)
            missButton.isHidden = true
            confirmButton.snp.remakeConstraints { make in
                make.width.equalTo(SCREEN_WIDHT-kFitWidth(40))
                make.height.equalTo(kFitWidth(60))
                make.centerX.lessThanOrEqualToSuperview()
                make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(37))
            }
        }else if buttonArr.count == 2{
            dictOne = buttonArr[0]as? NSDictionary ?? [:]
            confirmButton.setTitle(dictOne.stringValueForKey(key: "text"), for: .normal)
            dictTwo = buttonArr[1]as? NSDictionary ?? [:]
            missButton.setTitle(dictTwo.stringValueForKey(key: "text"), for: .normal)
        }
    }
    func showView() {
        self.isHidden = false
        
        bgView.isUserInteractionEnabled = false
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0
        whiteView.alpha = 1
        
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            
            self.bgView.alpha = self.targetDimAlpha//0.25
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
            
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    @objc func nothingAction(){
        
    }
    @objc func cancelAction(){
        if self.dictTwo.stringValueForKey(key: "iosTargetPage").count > 0 {
            self.pushBlock?(dictTwo.stringValueForKey(key: "iosTargetPage"))
        }
        self.hiddenView()
    }
    @objc func confirmAction(){
        if self.dictOne.stringValueForKey(key: "iosTargetPage").count > 0 {
            self.pushBlock?(dictOne.stringValueForKey(key: "iosTargetPage"))
        }
        self.hiddenView()
    }
}

extension ActivityAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(imgView)
        
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(missButton)
        
//        layoutWhiteViewFrame()
        setConstrait()
        whiteView.transform = .identity
    }
    
    private func layoutWhiteViewFrame() {
        self.whiteView.transform = .identity
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-13))
        }
        confirmButton.snp.makeConstraints { make in
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(40))
            make.height.equalTo(kFitWidth(60))
            make.centerX.lessThanOrEqualToSuperview()
//            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(44))
            make.bottom.equalTo(imgView).offset(kFitWidth(-65))
        }
        missButton.snp.makeConstraints { make in
            make.width.equalTo(confirmButton)
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(confirmButton.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(kFitWidth(36))
        }
    }
}
