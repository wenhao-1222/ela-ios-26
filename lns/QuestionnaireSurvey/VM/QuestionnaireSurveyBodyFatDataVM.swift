//
//  QuestionnaireSurveyBodyFatDataVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation
import UIKit

class QuestionnaireSurveyBodyFatDataVM: UIView {
    
    var selfHeight = kFitWidth(48)
    var selectedIndex = -1
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT*0.5, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var selectedImgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "protocal_normal_icon")
        
        return img
    }()
    lazy var contentLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
}

extension QuestionnaireSurveyBodyFatDataVM{
    func updateUI(dict:NSDictionary){
        contentLabel.text = "\(dict["data"]as? String ?? "")"
    }
}
extension QuestionnaireSurveyBodyFatDataVM{
    func initUI(){
        addSubview(selectedImgView)
        addSubview(contentLabel)
        
        setConstrait()
    }
    func setConstrait(){
        selectedImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(22))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
