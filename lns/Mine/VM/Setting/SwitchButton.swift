//
//  SwitchButton.swift
//  lns
//
//  Created by Elavatine on 2024/9/23.
//

import Foundation
import UIKit

class SwitchButton: FeedBackView {
    
    let selfWidth = kFitWidth(48)
    let selfHeight = kFitWidth(28)
    
    let toggleGap = kFitWidth(3)
    var toggleViewWidth = kFitWidth(0)
    
    var tapBlock:((Bool)->())?
    var isSelect = false
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .COLOR_LIGHT_GREY
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = self.selfHeight*0.5
        self.clipsToBounds = true
        
        toggleViewWidth = selfHeight-toggleGap*2
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(1), y: kFitWidth(1), width: selfWidth-kFitWidth(2), height: selfHeight-kFitWidth(2)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_LINE_GREY//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08)
        vi.layer.cornerRadius = (self.selfHeight-kFitWidth(2))*0.5
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var toggleView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: toggleGap, y: toggleGap, width: toggleViewWidth, height: toggleViewWidth))
//        vi.center = CGPoint.init(x: kFitWidth(1)+self.toggleViewWidth*0.5, y: self.selfHeight*0.5)
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = toggleViewWidth*0.5
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        
        return vi
    }()
}

extension SwitchButton{
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!(!isSelect)
        }
    }
}

extension SwitchButton{
    func setSelectStatus(status:Bool) {
        isSelect = status
        UIView.animate(withDuration: 0.1, delay: 0,options: .curveLinear) {
            if self.isSelect {
                self.toggleView.center = CGPoint.init(x: self.selfWidth-self.toggleGap-self.toggleViewWidth*0.5, y: self.selfHeight*0.5)
            }else{
                self.toggleView.center = CGPoint.init(x: self.toggleGap+self.toggleViewWidth*0.5, y: self.selfHeight*0.5)
            }
        }completion: { t in
            if self.isSelect {
                self.bgView.backgroundColor = .THEME//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.4)
            }else{
                self.bgView.backgroundColor = .COLOR_LINE_GREY//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08)
            }
        }
    }
}
extension SwitchButton{
    func initUI() {
        addSubview(bgView)
        addSubview(toggleView)
    }
}
