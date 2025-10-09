//
//  ShareAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/23.
//

import Foundation
import UIKit

class ShareAlertVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(60), height: kFitWidth(100)))
        self.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: kFitWidth(100)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothing))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var wechatButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(50), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_wechat_icon")
        btn.contenLab.text = "微信"
        btn.tapBlock = {()in
//            self.shareToSession()
        }
//        btn.addTarget(self, action: #selector(shareToSession), for: .touchUpInside)
        return btn
    }()
    lazy var circleButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(158), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_circle_icon")
        btn.contenLab.text = "朋友圈"
        btn.tapBlock = {()in
//            self.shareToTimeLine()
        }
//        btn.addTarget(self, action: #selector(shareToTimeLine), for: .touchUpInside)
        return btn
    }()
    lazy var saveButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(266), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_save_icon")
        btn.contenLab.text = "保存图片"
        btn.tapBlock = {()in
//            self.saveAction()
        }
//        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return btn
    }()
}

extension ShareAlertVM{
    func showView() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(88), width: SCREEN_WIDHT, height: kFitWidth(100))
        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: kFitWidth(100))
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func nothing(){
        
    }
}
extension ShareAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(wechatButton)
        whiteView.addSubview(circleButton)
        whiteView.addSubview(saveButton)
        
    }
}
