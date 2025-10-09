//
//  JournalFuncAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/17.
//

import Foundation
import UIKit

class JournalFuncAlertVM: UIView {
    
    var selfHeight = kFitWidth(100)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: SCREEN_HEIGHT*0.5-selfHeight*0.5, width: selfHeight*0.5, height: selfHeight))
        self.backgroundColor = .black
        self.isUserInteractionEnabled = true
        
        self.addClipCorner(corners: [.topLeft,.bottomLeft], radius: kFitWidth(20))
        self.clipsToBounds = true
        
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var copyButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: 0, width: selfHeight*0.5, height: selfHeight*0.5))
        btn.setTitle("复制", for: .normal)
        btn.setImage(UIImage(named: "logs_foods_copy_icon"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
        return vi
    }()
    lazy var saveButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: selfHeight*0.5, width: selfHeight*0.5, height: selfHeight*0.5))
        btn.setTitle("储存", for: .normal)
        btn.setImage(UIImage(named: "logs_foods_meals_create_icon"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        return btn
    }()
}

extension JournalFuncAlertVM{
    func showSelf() {
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.frame = CGRect.init(x: SCREEN_WIDHT-self.selfHeight*0.5, y: SCREEN_HEIGHT*0.5-self.selfHeight*0.5, width: self.selfHeight*0.5, height: self.selfHeight)
        }
    }
    func hiddenSelf() {
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.frame = CGRect.init(x: SCREEN_WIDHT, y: SCREEN_HEIGHT*0.5-self.selfHeight*0.5, width: self.selfHeight*0.5, height: self.selfHeight)
        }
    }
}
extension JournalFuncAlertVM{
    func initUI() {
        addSubview(copyButton)
        addSubview(saveButton)
        addSubview(lineView)
        
        copyButton.imagePosition(style: .top, spacing: kFitWidth(1))
        saveButton.imagePosition(style: .top, spacing: kFitWidth(1))
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}

