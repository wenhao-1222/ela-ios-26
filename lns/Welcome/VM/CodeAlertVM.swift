//
//  CodeAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/15.
//

import Foundation
import UIKit

class CodeAlertVM: UIView {
    
    var choiceBlock:((String)->())?
    var dataSourceArray = NSArray()
    var vmDataArray = [LoginPhoneTypeAlertItemVM]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
//        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
//        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        vi.backgroundColor = .white//WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
    lazy var checkBoxDataImgView : UIImageView = {
        let img = UIImageView()
//        img.setImgLocal(imgName: "question_checkbox_selected")
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(2)
        img.layer.borderColor = UIColor.COLOR_LIGHT_GREY.cgColor
        img.layer.borderWidth = kFitWidth(1)
        
        return img
    }()
    lazy var dalaLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        let attr1 = NSMutableAttributedString(string: "Read and agree")
        let attr2 = NSMutableAttributedString(string: "《Service terms》")
        let attr3 = NSMutableAttributedString(string: "and")
        let attr4 = NSMutableAttributedString(string: "《Privacy policy》")
        
        attr2.yy_color = .THEME
        attr4.yy_color = .THEME
        
        attr1.append(attr2)
        attr1.append(attr3)
        attr1.append(attr4)
        lab.attributedText = attr1
        
        return lab
    }()
    lazy var checkBoxProtocalImgView : UIImageView = {
        let img = UIImageView()
//        img.setImgLocal(imgName: "question_checkbox_selected")
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(2)
        img.layer.borderColor = UIColor.COLOR_LIGHT_GREY.cgColor
        img.layer.borderWidth = kFitWidth(1)
        
        return img
    }()
    lazy var dalaLabel2 : UILabel = {
        let lab = UILabel()
        lab.text = "l agree to receive text message"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var dalaLabel222 : UILabel = {
        let lab = UILabel()
        lab.text = "Message and data rates may apply. Enter your phone number tosubscribe to recurring Accotnt updates to your phone from Elavatine. Msg freg may vary Reply \"HELP\" for help. Reply \"Stop\" to cancel."
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
}

extension CodeAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(checkBoxDataImgView)
        whiteView.addSubview(dalaLabel)
        whiteView.addSubview(checkBoxProtocalImgView)
        whiteView.addSubview(dalaLabel2)
        whiteView.addSubview(dalaLabel222)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(355))
            make.height.equalTo(kFitWidth(300))
        }
        checkBoxDataImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.width.height.equalTo(kFitWidth(16))
        }
        dalaLabel.snp.makeConstraints { make in
            make.left.equalTo(checkBoxDataImgView.snp.right).offset(kFitWidth(8))
//            make.centerY.lessThanOrEqualTo(checkBoxDataImgView)
            make.top.equalTo(checkBoxDataImgView)
            make.right.equalTo(kFitWidth(-20))
        }
        checkBoxProtocalImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(16))
            make.top.equalTo(dalaLabel.snp.bottom).offset(kFitWidth(10))
        }
        dalaLabel2.snp.makeConstraints { make in
            make.left.equalTo(checkBoxProtocalImgView.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(checkBoxProtocalImgView)
        }
        dalaLabel222.snp.makeConstraints { make in
            make.left.equalTo(checkBoxProtocalImgView)
            make.top.equalTo(checkBoxProtocalImgView.snp.bottom).offset(kFitWidth(10))
            make.right.equalTo(kFitWidth(-20))
        }
    }
}
