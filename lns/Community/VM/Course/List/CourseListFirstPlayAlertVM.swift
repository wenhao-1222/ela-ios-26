//
//  CourseListFirstPlayAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/24.
//


import MCToast


import Foundation
import UIKit

class CourseListFirstPlayAlertVM: UIView {
    
    var whiteViewHeight = WHUtils().getBottomSafeAreaHeight()+kFitWidth(210)+kFitWidth(16)
    var controller = WHBaseViewVC()
    
    var confirmBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
//        self.alpha = 0
//        self.isHidden = true
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: CGRect.init(x: 0, y: -SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT*2))
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
//        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
//        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
//        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "是否要在当前设备播放？"
        lab.text = "是否确认在当前设备播放？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        
        return lab
    }()
    lazy var detailLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.text = "在当前设备播放即课程绑定当前设备\n课程换绑设备仅允许一次"
        lab.text = "注意：点击“确认播放”后，课程将绑定至本设备\n操作不可撤销"
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.adjustsFontSizeToFitWidth = true
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textInsets = UIEdgeInsets(top: kFitWidth(4), left: 0, bottom: kFitWidth(4), right: 0)
        
        return lab
    }()
    lazy var buttonBgView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(145), width: SCREEN_WIDHT, height: whiteViewHeight-kFitWidth(145)))
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.backgroundColor = .COLOR_BG_WHITE
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.layer.borderColor = UIColor.COLOR_GRAY_808080.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("确认播放", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
}

extension CourseListFirstPlayAlertVM{
    func showView() {
//        self.isHidden = false
        bgView.alpha = 0
        self.bgView.isUserInteractionEnabled = false
        UserInfoModel.shared.showNotifiAuthoriAlertVM = false
        
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5-kFitWidth(2))
            self.bgView.alpha = 0.1
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
//        UIView.animate(withDuration: 0.25, delay: 0.05, options: .curveEaseInOut) {
//            self.bgView.alpha = 0.1
//        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        }
        
//        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
//            self.alpha = 1
//            self.whiteView.alpha = 1
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
//        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
            self.bgView.alpha = 0
        }completion: { t in
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.whiteViewHeight, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
//        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
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
    @objc func confirmAction() {
        self.confirmBlock?()
        self.hiddenView()
    }
}

extension CourseListFirstPlayAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(detailLabel)
        
        whiteView.addSubview(buttonBgView)
        buttonBgView.addSubview(cancelButton)
        buttonBgView.addSubview(confirmButton)
        
        setConstrait()
        buttonBgView.addShadow(opacity: 0.05,offset: CGSize.init(width: 0, height: kFitWidth(-5)))
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(19))
            make.height.equalTo(kFitWidth(31))
        }
        detailLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(68))
//            make.left.equalTo(kFitWidth(5))
//            make.right.equalTo(kFitWidth(-5))
        }
        cancelButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.height.equalTo(kFitWidth(44))
            make.top.equalTo(kFitWidth(11))
            make.width.equalTo(SCREEN_WIDHT*0.5-kFitWidth(16)-kFitWidth(8))
        }
        confirmButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(cancelButton)
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(cancelButton)
        }
    }
}

