//
//  MealsNaviEditButton.swift
//  lns
//
//  Created by LNS2 on 2024/7/24.
//

import Foundation
import UIKit

class MealsNaviEditButton: UIView {
    
    var selfHeight = kFitWidth(44)
    var controller = WHBaseViewVC()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT * 0.5, y: statusBarHeight, width: SCREEN_WIDHT * 0.5, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var saveButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.setTitleColor(.white, for: .normal)
        
        return btn
    }()
    lazy var editButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("编辑", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.setTitleColor(.white, for: .normal)
        
        return btn
    }()
    lazy var delButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("删除", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.setTitleColor(.white, for: .normal)
        
        return btn
    }()
}

extension MealsNaviEditButton{
    func showSave(isSave:Bool) {
        self.saveButton.isHidden = !isSave
        self.editButton.isHidden = isSave
        self.delButton.isHidden = isSave
    }
}
extension MealsNaviEditButton{
    func initUI() {
        addSubview(saveButton)
        addSubview(editButton)
        addSubview(delButton)
        
        setConstrait()
        
        self.showSave(isSave: true)
    }
    func setConstrait() {
        saveButton.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
            make.top.height.right.equalToSuperview()
//            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(56))
        }
        editButton.snp.makeConstraints { make in
            make.top.width.height.right.equalTo(saveButton)
        }
        delButton.snp.makeConstraints { make in
            make.right.equalTo(editButton.snp.left)
            make.top.height.equalTo(saveButton)
            make.width.equalTo(kFitWidth(48))
        }
    }
}
