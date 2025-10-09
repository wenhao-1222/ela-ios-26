//
//  DataAddFilterVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/17.
//

import Foundation
import UIKit

class DataAddFilterVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var timeButton : GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        
        btn.setTitleColor(.THEME, for: .normal)
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.enablePressEffect()
        
        return btn
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isHidden = true
        lab.textAlignment = .center
        return lab
    }()
}

extension DataAddFilterVM{
    func setTime(time:String) {
        timeButton.setTitle("\(time)", for: .normal)
        timeButton.setImage(UIImage(named: "arrow_img_down"), for: .normal)
        timeButton.imagePosition(style: .right, spacing: kFitWidth(5))
    }
    func updateUIForUpdate(date:String) {
        timeLabel.text = date
        timeLabel.isHidden = false
        timeButton.isHidden = true
        self.isUserInteractionEnabled = false
    }
}
extension DataAddFilterVM{
    func initUI() {
        addSubview(timeButton)
        addSubview(timeLabel)
    }
}
