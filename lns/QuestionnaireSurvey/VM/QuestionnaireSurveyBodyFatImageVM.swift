//
//  QuestionnaireSurveyBodyFatImageVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation
import UIKit

class QuestionnaireSurveyBodyFatImageVM: UIView {
    
    var selfHeight = kFitWidth(98)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT*0.33, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        img.layer.cornerRadius = kFitWidth(6)
        img.clipsToBounds = true
        return img
    }()
    lazy var contentLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        
        return lab
    }()
}

extension QuestionnaireSurveyBodyFatImageVM{
    func updateUI(dict:NSDictionary){
        contentLabel.text = "\(dict["data"]as? String ?? "")"
        imgView.setImgUrl(urlString: "\(dict["imgUrl"]as? String ?? "")")
    }
}
extension QuestionnaireSurveyBodyFatImageVM{
    func initUI(){
        addSubview(imgView)
        addSubview(contentLabel)
        
        setConstrait()
    }
    func setConstrait(){
        imgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(10))
            make.width.equalTo(kFitWidth(68))
            make.height.equalTo(kFitWidth(79))
        }
        contentLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(imgView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
}

