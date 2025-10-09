//
//  QuestionnairePreVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/22.
//

import Foundation


class QuestionnairePreVC: WHBaseViewVC {
    
    
    public override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        
    }
//    public override func viewDidDisappear(_ animated: Bool) {
//        self.navigationController?.fd_interactivePopDisabled = true
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_pre_img")
        
        return img
    }()
    lazy var titlLab : UILabel = {
        let lab = UILabel()
        lab.text = "Hi，\(UserInfoModel.shared.nickname)"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var contentLab : UILabel = {
        let lab = UILabel()
//        lab.text = "通过填写由职业运动员和健身教练共同设计的调查问卷，我们将根据您的目标，生活及饮食习惯为您量身定制一个适合您的饮食计划。"
//        lab.text = "通过填写由运动员和营养师联合设计的问卷，我们将根据您的目标和日常习惯为您量身定制一个营养参考值。"
        lab.text = "填写由运动员和营养师联合设计的问卷，我们将为您量身定制一个营养目标。"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var startButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("开始吧", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(startAction), for: .touchUpInside)
        
        return btn
    }()
}

extension QuestionnairePreVC{
    @objc func startAction() {
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        if UserInfoModel.shared.birthDay.count > 0 && (UserInfoModel.shared.gender == "1" || UserInfoModel.shared.gender == "2"){
            QuestinonaireMsgModel.shared.sex = UserInfoModel.shared.gender
            QuestinonaireMsgModel.shared.weight = ""
            QuestinonaireMsgModel.shared.birthDay = Date().changeDateFormatter(dateString: UserInfoModel.shared.birthDay, formatter: "yyyy-MM-dd", targetFormatter: "yyyy")
//            let vc = NewQuestionnaireNoSexVC()
            let vc = SurveyNoSexVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
//            let vc = NewQuestionnaireVC()
            let vc = SurveyVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension QuestionnairePreVC{
    func initUI() {
        initNavi(titleStr: "")
        
        navigationView.backgroundColor = WHColor_16(colorStr: "F6F6F6")
        view.backgroundColor = WHColor_16(colorStr: "F6F6F6")
        
        view.addSubview(imgView)
        view.addSubview(titlLab)
        view.addSubview(contentLab)
        view.addSubview(startButton)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(41)+getNavigationBarHeight())
            make.width.equalTo(kFitWidth(224))
            make.height.equalTo(kFitWidth(150))
        }
        titlLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(250)+getNavigationBarHeight())
        }
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(titlLab.snp.bottom).offset(kFitWidth(12))
        }
        startButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(kFitWidth(-12)-getBottomSafeAreaHeight())
        }
    }
}
