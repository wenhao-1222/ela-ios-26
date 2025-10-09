//
//  JournalBottomFuncAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/17.
//

import Foundation
import UIKit

class JournalBottomFuncAlertVM: UIView {
    
    var selfHeight = WHUtils().getTabbarHeight()+kFitWidth(20)
    
    var bgColor = UIColor.white//WHColor_16(colorStr: "ABABAB")
    
    var copyBlock:(()->())?
    var saveBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = bgColor//.COLOR_BUTTON_DISABLE_BG_THEME
        self.isUserInteractionEnabled = true
        self.addShadow()
        initUI()
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
//        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var copyButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT*0.5, height: selfHeight-WHUtils().getBottomSafeAreaHeight()))
        btn.setTitle("复制", for: .normal)
        btn.backgroundColor = bgColor
        btn.setImage(UIImage(named: "logs_foods_copy_icon"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
//        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
        return vi
    }()
    lazy var saveButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT*0.5, height: selfHeight-WHUtils().getBottomSafeAreaHeight()))
        btn.setTitle("保存食谱", for: .normal)
        btn.backgroundColor = bgColor
        btn.setImage(UIImage(named: "logs_foods_meals_create_icon"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return btn
    }()
}

extension JournalBottomFuncAlertVM{
    func showSelf() {
        UIView.animate(withDuration: 0.2,delay: 0,options: .curveLinear) {
//            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
            self.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.selfHeight, width: SCREEN_WIDHT, height: self.selfHeight)
        }
    }
    func hiddenSelf() {
        UIView.animate(withDuration: 0.2,delay: 0,options: .curveLinear) {
            self.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.selfHeight)
        }
    }
    @objc func copyAction() {
        if self.copyBlock != nil{
            self.copyBlock!()
        }
    }
    @objc func saveAction() {
        if self.saveBlock != nil{
            self.saveBlock!()
        }
    }
}
extension JournalBottomFuncAlertVM{
    func initUI() {
        addSubview(copyButton)
        addSubview(saveButton)
        addSubview(lineView)
        
        copyButton.imagePosition(style: .left, spacing: kFitWidth(8))
        saveButton.imagePosition(style: .left, spacing: kFitWidth(8))
        lineView.addShadow()
        
        setConstrait()
    }
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(2))
//            make.top.equalTo(kFitWidth(10))
        }
        copyButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
//            make.right.equalTo(lineView.snp.left)
            make.width.equalTo(SCREEN_WIDHT*0.5)
            make.height.equalTo(selfHeight-WHUtils().getBottomSafeAreaHeight())
        }
        saveButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT*0.5)
            make.height.equalTo(selfHeight-WHUtils().getBottomSafeAreaHeight())
        }
    }
}
