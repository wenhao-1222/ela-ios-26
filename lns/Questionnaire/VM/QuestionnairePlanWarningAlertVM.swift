//
//  QuestionnairePlanWarningAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/1.
//

import Foundation
import UIKit
class QuestionnairePlanWarningAlertVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.0)
        self.isUserInteractionEnabled = true
        
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var contentBgView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_85
        vi.layer.cornerRadius = kFitWidth(6)
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var imgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "alert_warning_icon")
        
        return img
    }()
    lazy var contentLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
}

extension QuestionnairePlanWarningAlertVM{
    func initUI() {
        addSubview(contentBgView)
    }
}
