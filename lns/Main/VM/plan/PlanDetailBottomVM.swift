//
//  PlanDetailBottomVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import UIKit

class PlanDetailBottomVM: UIView {
    
    let selfHeight = WHUtils().getBottomSafeAreaHeight()+kFitWidth(56)
    
    var activeBlock:(()->())?
    var updateBlock:(()->())?
    var saveBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        self.addShadow()
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        return vi
    }()
    lazy var activeButton : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("激活计划", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .white), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_HIGHTLIGHT_GRAY), for: .highlighted)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(activeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var updateButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("编辑计划", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .white), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_HIGHTLIGHT_GRAY), for: .highlighted)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(updateAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        
        return vi
    }()
    lazy var saveButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.isHidden = true
//        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return btn
    }()
}

extension PlanDetailBottomVM{
    @objc func activeAction() {
        if self.activeBlock != nil{
            self.activeBlock!()
        }
    }
    @objc func updateAction() {
        if self.updateBlock != nil{
            self.updateBlock!()
        }
    }
    @objc func saveAction() {
        if self.saveBlock != nil{
            self.saveBlock!()
        }
    }
}

extension PlanDetailBottomVM{
    func initUI() {
        addSubview(bottomView)
        addSubview(activeButton)
        addSubview(updateButton)
        addSubview(saveButton)
        addSubview(lineView)
        
        setConstrait()
    }
    func changeStatus(isUpdate:Bool) {
        activeButton.isHidden = isUpdate
        updateButton.isHidden = isUpdate
        lineView.isHidden = isUpdate
        saveButton.isHidden = !isUpdate
        
        if isUpdate{
            self.bottomView.backgroundColor = .THEME
        }else{
            self.bottomView.backgroundColor = .white
        }
    }
    func setConstrait() {
        activeButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
            make.width.equalTo(SCREEN_WIDHT*0.5-kFitWidth(1))
        }
        updateButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
            make.width.equalTo(SCREEN_WIDHT*0.5-kFitWidth(1))
        }
        saveButton.snp.makeConstraints { make in
            make.left.width.top.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }
        bottomView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(activeButton.snp.bottom)
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(activeButton)
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(24))
        }
    }
}
