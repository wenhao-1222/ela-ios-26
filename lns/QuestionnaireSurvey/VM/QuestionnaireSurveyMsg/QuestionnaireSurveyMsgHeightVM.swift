//
//  QuestionnaireSurveyMsgHeightVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation
import UIKit

class QuestionnaireSurveyMsgHeightVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .black
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.size.height
        
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
        vm.titleLabel.text = "身高"
        return vm
    }()
    lazy var contentLabel : UILabel = {
        let lab = UILabel()
        lab.text = "请选择身高 厘米"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var rulerView : TTScrollRulerView = {
        let vi = TTScrollRulerView.init(frame: CGRect.init(x: kFitWidth(50), y: self.selfHeight-kFitWidth(200), width: SCREEN_WIDHT-kFitWidth(100), height: kFitWidth(100)))
        vi.backgroundColor = .clear
        vi.rulerBackgroundColor = .clear
        /*
         rulerClassic.rulerDelegate = self;
         rulerClassic.lockMax = 1000000;
         rulerClassic.unitValue = 100;
         //在执行此方法前，可先设定参数：最小值，最大值，横向，纵向等等  ------若不设定，则按照默认值绘制
         [rulerClassic classicRuler];
         */
        return vi
    }()
}

extension QuestionnaireSurveyMsgHeightVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(titleVm)
        bgView.addSubview(contentLabel)
        
        addSubview(rulerView)
        rulerView.rulerDelegate = self
        rulerView.lockMax = 280
        rulerView.lockMin = 50
        rulerView.unitValue = 1
        rulerView.classicRuler()
        rulerView.scroll(toValue: 174, animation: false)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(kFitWidth(10))
        }
        contentLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.top.height.equalToSuperview()
        }
    }
}

extension QuestionnaireSurveyMsgHeightVM:rulerDelegate{
    func ruler(with value: Int) {
        DLLog(message: "\(value)")
        contentLabel.text = "\(value) cm"
    }
    
    
}
