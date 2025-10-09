//
//  QuestionnaireSurveyBodyFatVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation
import UIKit

class QuestionnaireSurveyBodyFatVM: UIView {
    
    var selfHeight = kFitWidth(48)
    var selectedIndex = -1
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = WHColor_RGB(r: 38.0, g: 40.0, b: 49.0)
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.size.height
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var dataArray : NSArray = {
        return [["data":"3%~5%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"],
                ["data":"5%~8%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"],
                ["data":"8%~12%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"],
                ["data":"12%~15%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"],
                ["data":"15%~20%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"],
                ["data":"20%~25%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"],
                ["data":"25%~30%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"],
                ["data":"30%~40%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"],
                ["data":"40%~50%","imgUrl":"https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/devops-essentials.2.png"]]
    }()
    lazy var titleVm : QuestionnaireSurveyTopVM = {
        let vm = QuestionnaireSurveyTopVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "您的体脂肪"
        
        return vm
    }()
    lazy var scrollView : UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: self.titleVm.frame.maxY, width: SCREEN_WIDHT, height: self.selfHeight-QuestionnaireSurveyTopVM().selfHeight))
        scro.backgroundColor = .clear
        
        return scro
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "如果您不清楚自己的体脂肪的请参考图片"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
}

extension QuestionnaireSurveyBodyFatVM{
    func initUI() {
        addSubview(titleVm)
        addSubview(scrollView)
        scrollView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(QuestionnaireSurveyBodyFatDataVM().selfHeight*CGFloat((dataArray.count+1)/2))
        }
        
        refreshDataUI()
    }
    func refreshDataUI() {
        var offsetY = kFitWidth(0)
        for i in 0..<dataArray.count{
            let dict = dataArray[i]as? NSDictionary ?? [:]
            let vm = QuestionnaireSurveyBodyFatDataVM.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5*CGFloat(i%2), y: QuestionnaireSurveyBodyFatDataVM().selfHeight*CGFloat(i/2), width: 0, height: 0))
            scrollView.addSubview(vm)
            
            let imgVm = QuestionnaireSurveyBodyFatImageVM.init(frame: CGRect.init(x: SCREEN_WIDHT*0.33*CGFloat(i%3), y: QuestionnaireSurveyBodyFatImageVM().selfHeight*CGFloat(i/3)+QuestionnaireSurveyBodyFatDataVM().selfHeight*6, width: 0, height: 0))
            scrollView.addSubview(imgVm)
            
            vm.updateUI(dict: dict)
            imgVm.updateUI(dict: dict)
            offsetY = imgVm.frame.maxY
        }
        scrollView.contentSize = CGSize.init(width: 0, height: offsetY)
    }
}
