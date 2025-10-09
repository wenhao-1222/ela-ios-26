//
//  FitnessTipsVC.swift
//  lns
//
//  Created by Elavatine on 2025/7/18.
//

import UIKit

class FitnessTipsVC: WHBaseViewVC {
    
    var bgViewHeight = kFitWidth(66)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showWhiteView()
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if getBottomSafeAreaHeight() > 0 {
//            bgViewHeight = getBottomSafeAreaHeight() + kFitWidth(55)
//        }
        view.backgroundColor = .clear // 注意此处！清除背景！
        
        initUI()
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.backgroundColor = .COLOR_BG_WHITE
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    // 白色卡片区域
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(129)+SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(129)+kFitWidth(16)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.text = "如何记录力量训练？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        return lab
    }()
    lazy var tipsImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "stat_fitness_tips_alert_img")
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var buttonBgView: UIView = {
        let vi = UIView()
//        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(129)-bgViewHeight, width: SCREEN_WIDHT, height: bgViewHeight))
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.isUserInteractionEnabled = true
        
        
        return vi
    }()
    lazy var confitmBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
//        btn.backgroundColor = .THEME
        btn.setTitle("知道了", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
    
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
}

extension FitnessTipsVC{
    func showWhiteView() {
        let toGap = getBottomSafeAreaHeight() > 0 ? kFitWidth(89) : kFitWidth(0)
        
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.frame = CGRect.init(x: 0, y: toGap, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-toGap+kFitWidth(14))
        }completion: { t in
            UIView.animate(withDuration: 0.15, delay: 0,options: .curveEaseInOut) {
                self.whiteView.frame = CGRect.init(x: 0, y: toGap, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-toGap+kFitWidth(16))
            }
        }
        
//        UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseInOut) {
//            self.whiteView.frame = CGRect.init(x: 0, y: toGap, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-toGap+kFitWidth(16))
////            self.whiteView.frame = CGRect.init(x: 0, y: kFitWidth(129), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(129)+kFitWidth(16))
//        }
    }
    @objc func hiddenSelf() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute: {
//            self.backTapAction()
            if (self.navigationController != nil) {
                self.navigationController?.popViewController(animated: true)
            }else{
                self.dismiss(animated: true) {
                }
            }
        })
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(129)+kFitWidth(16))
        }
    }
}

extension FitnessTipsVC{
    // 初始化 UI
    func initUI() {
        view.backgroundColor = .clear//UIColor.black.withAlphaComponent(0.1)//.clear // 关键点：整个 VC 背景透明
        view.addSubview(whiteView)
        whiteView.addSubview(buttonBgView)
        
        whiteView.addSubview(titleLab)
        whiteView.addSubview(tipsImgView)
        
        buttonBgView.addSubview(confitmBtn)
        
        setConstraints()
        buttonBgView.addShadow(opacity: 0.05,offset: CGSize(width: 0, height: -5))
    }

    // 自动布局
    func setConstraints() {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(24))
        }
        tipsImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(17))
//            make.bottom.equalTo(kFitWidth(-60))
        }
        buttonBgView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(tipsImgView.snp.bottom).offset(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-16))
        }
        let gap = getBottomSafeAreaHeight() > 0 ? kFitWidth(11) : kFitWidth(3)
        confitmBtn.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(gap)
            make.height.equalTo(kFitWidth(44))
        }
    }
}

extension FitnessTipsVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: whiteView)
        return !whiteView.point(inside: point, with: nil)
    }
}
