//
//  QuestionnaireSurveyTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation
import UIKit

class QuestionnaireSurveyTopVM: UIView {
    
    let selfHeight = kFitWidth(44)
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .black
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var iconImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "icon_calendar_gray")
        
        return img
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
}

extension QuestionnaireSurveyTopVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(titleLabel)
        
        setConstrait()
    }
    func setConstrait(){
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(22))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(47))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
