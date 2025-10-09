//
//  QuestionnaireSurveyMsgBirthdayVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/25.
//

import Foundation
import UIKit

class QuestionnaireSurveyMsgBirthdayVM: UIView {
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .black
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
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
        vm.titleLabel.text = "出生年月"
        return vm
    }()
    lazy var timeLabel : UILabel = {
        let lab = UILabel()
        lab.text = "请选择出生年月"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
}

extension QuestionnaireSurveyMsgBirthdayVM{
    @objc func tapAction(){
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension QuestionnaireSurveyMsgBirthdayVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(titleVm)
        bgView.addSubview(timeLabel)
        
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(kFitWidth(10))
        }
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.top.height.equalToSuperview()
        }
    }
}
