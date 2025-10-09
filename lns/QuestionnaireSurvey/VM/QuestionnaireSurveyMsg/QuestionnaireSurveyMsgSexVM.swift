//
//  QuestionnaireSurveyMsgVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/25.
//

import Foundation
import UIKit

class QuestionnaireSurveyMsgSexVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .black
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "050505")
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var titleVm : QuestionnaireSurveyMsgItemVM = {
        let vm = QuestionnaireSurveyMsgItemVM.init(frame: .zero)
        vm.titleLabel.text = "性别"
        return vm
    }()
    lazy var checkBoxMan : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "protocal_normal_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var manLabel: UILabel = {
        let lab = UILabel()
        lab.text = "男"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var manTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var checkBoxFeman : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "protocal_normal_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var femanLabel: UILabel = {
        let lab = UILabel()
        lab.text = "女"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var femanTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
}

extension QuestionnaireSurveyMsgSexVM{
    func initUI(){
        addSubview(bgView)
        bgView.addSubview(titleVm)
        bgView.addSubview(manLabel)
        bgView.addSubview(checkBoxMan)
        bgView.addSubview(manTapView)
        bgView.addSubview(femanLabel)
        bgView.addSubview(checkBoxFeman)
        bgView.addSubview(femanTapView)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(kFitWidth(10))
        }
        femanLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-14))
            make.centerY.lessThanOrEqualToSuperview()
        }
        checkBoxFeman.snp.makeConstraints { make in
            make.right.equalTo(femanLabel.snp.left).offset(kFitWidth(-3))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(22))
        }
        femanTapView.snp.makeConstraints { make in
            make.right.equalTo(femanLabel)
            make.left.equalTo(checkBoxFeman)
            make.top.height.equalToSuperview()
        }
        manLabel.snp.makeConstraints { make in
            make.right.equalTo(femanTapView.snp.left).offset(kFitWidth(-20))
            make.centerY.lessThanOrEqualToSuperview()
        }
        checkBoxMan.snp.makeConstraints { make in
            make.right.equalTo(manLabel.snp.left).offset(kFitWidth(-3))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(22))
        }
        manTapView.snp.makeConstraints { make in
            make.left.equalTo(checkBoxMan)
            make.right.equalTo(manLabel)
            make.top.height.equalToSuperview()
        }
    }
}
