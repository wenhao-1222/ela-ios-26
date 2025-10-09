//
//  WelcomeVC.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation
import Reachability

class WelcomeVC: WHBaseViewVC {
    
    var isAgreeData = false
    var isAgreeProtocal = false
    var isAgreeAll = false
    var tapBtnType = "1"//1 点第一个checkbox  2  点第二个checkbox  3    我接受全部
    
    var agreeAllBtnCenterY = SCREEN_HEIGHT-(kFitWidth(64)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(8))
//    var startBtnCenterY = kFitWidth(287)+SCREEN_WIDHT
    //kFitWidth(-64)-getBottomSafeAreaHeight()
    let reachability = try! Reachability()
    var netWorkisConnect = false
    
    override func viewWillDisappear(_ animated: Bool) {
        reachability.stopNotifier()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        checkNetWork()
    }
    lazy var bgImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_bg")
        img.isUserInteractionEnabled = true
//        img.contentMode = .scaleAspectFit
        
        return img
    }()
    lazy var logoImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "welcome_logo_icon")
        
        return img
    }()
    lazy var logoLabel : UILabel = {
        let lab = UILabel()
        lab.font = .monospacedSystemFont(ofSize: 48, weight: .bold)
        lab.text = "elavatine"
        lab.textColor = .white
        
        return lab
    }()
    lazy var loganLabel : UILabel = {
        let lab = UILabel()
//        lab.text = "你身边的专业健康指导"
//        lab.text = "专业饮食记录方案"
//        lab.text = "专业健身饮食记录"
//        lab.text = "专业饮食记录平台"
        lab.text = "专业饮食记录系统"
        //你身边的专业健康指导  为每个人免费定制的专业健康指导
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var checkBoxDataImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_checkbox_normal")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var checkBoxDataTapView : FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(checkBoxDadaTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var dalaLabel : UILabel = {
        let lab = UILabel()
        lab.text = "我同意elavatine出于向我提供应用程序功能的目的处理我的个人健康数据"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var checkBoxProtocalImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_checkbox_normal")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var checkBoxProtocalTapView : FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(checkBoxProtocalTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var protocalLabel : UILabel = {
        let lab = UILabel()
        lab.text = "我同意隐私政策和使用条款。"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var moreProtocalLabel : UILabel = {
        let lab = UILabel()
        lab.text = "更多详细信息参考"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var arrowImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_arrow_right")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var privaceBtn : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("隐私政策", for: .normal)
        btn.setImage(UIImage.init(named: "question_arrow_right"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(privaceTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var agreeAllBtn : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("我接受全部", for: .normal)
//        btn.setTitle("I Agree", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(agreeAllTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var startBtn : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("开始体验", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.clipsToBounds = true
        btn.backgroundColor = .white
        btn.alpha = 0
        btn.isHidden = true
        btn.addTarget(self, action: #selector(startBtnAction), for: .touchUpInside)
        
        return btn
    }()
}

extension WelcomeVC{
    @objc func privaceTapAction(){
        openNetWorkServiceWithBolck(action: { netConnect in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if netConnect == true{
                    let vc = WHCommonH5VC()
                    vc.urlString = URL_privacy as NSString
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.presentAlertVc(confirmBtn: "设置", message: "可以在“设置->App->无线数据”中开启“无线数据”，连接网络后才能流畅使用。", title: "“Elavatine”已关闭网络权限", cancelBtn: "取消", handler: { action in
                        self.openUrl(urlString: UIApplication.openSettingsURLString)
                    }, viewController: self)
                }
            })
        })
    }
    @objc func startBtnAction(){
        let vc = NeedBuildPlanVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func checkBoxDadaTapAction(){
        tapBtnType = "1"
        isAgreeData = !isAgreeData
//        if isAgreeData {
//            checkBoxDataImgView.setImgLocal(imgName: "question_checkbox_selected")
//        }else{
//            checkBoxDataImgView.setImgLocal(imgName: "question_checkbox_normal")
//        }
        checkBoxDataImgView.setCheckState(isAgreeData,
                                          checkedImageName: "question_checkbox_selected",
                                          uncheckedImageName: "question_checkbox_normal")
        
        changeBtnCenter()
    }
    @objc func checkBoxProtocalTapAction(){
        tapBtnType = "2"
        isAgreeProtocal = !isAgreeProtocal
        
//        if isAgreeProtocal {
//            checkBoxProtocalImgView.setImgLocal(imgName: "question_checkbox_selected")
//        }else{
//            checkBoxProtocalImgView.setImgLocal(imgName: "question_checkbox_normal")
//        }
        checkBoxProtocalImgView.setCheckState(isAgreeData,
                                          checkedImageName: "question_checkbox_selected",
                                          uncheckedImageName: "question_checkbox_normal")
        changeBtnCenter()
    }
    @objc func protocalTapAction(){
        self.presentAlertVcNoAction(title: "隐私政策暂无，待H5页面", viewController: self)
    }
    @objc func agreeAllTapAction(){
        isAgreeData = true
        isAgreeProtocal = true
        
        tapBtnType = "3"
//        checkBoxDataImgView.setImgLocal(imgName: "question_checkbox_selected")
//        checkBoxProtocalImgView.setImgLocal(imgName: "question_checkbox_selected")
        checkBoxDataImgView.setCheckState(true,
                                  checkedImageName: "question_checkbox_selected",
                                  uncheckedImageName: "question_checkbox_normal")
        checkBoxProtocalImgView.setCheckState(true,
                                      checkedImageName: "question_checkbox_selected",
                                      uncheckedImageName: "question_checkbox_normal")
        changeBtnCenter()
    }
    func changeBtnCenter() {
        if tapBtnType == "1"{
            checkBoxDataTapView.isUserInteractionEnabled = false
        }else if tapBtnType == "2"{
            checkBoxProtocalTapView.isUserInteractionEnabled = false
        }else if tapBtnType == "3"{
            checkBoxProtocalTapView.isUserInteractionEnabled = false
            checkBoxDataTapView.isUserInteractionEnabled = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.7, execute: {
            self.checkBoxDataTapView.isUserInteractionEnabled = true
            self.checkBoxProtocalTapView.isUserInteractionEnabled = true
        })
        let offsetY = kFitWidth(60)
        if isAgreeData && isAgreeProtocal{
            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut) {
                let agreeAllBtnCenter = self.agreeAllBtn.center
                self.agreeAllBtn.center = CGPoint.init(x: agreeAllBtnCenter.x, y: self.agreeAllBtnCenterY-offsetY)
                self.agreeAllBtn.alpha = 0
            }
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut) {
                let startBtnCenter = self.startBtn.center
                self.startBtn.center = CGPoint.init(x: startBtnCenter.x, y: self.agreeAllBtnCenterY-offsetY+kFitWidth(44))
                self.startBtn.isHidden = false
                self.startBtn.alpha = 1
            }completion: { t in
                
            }
        }else{
            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut){
                self.startBtn.alpha = 0
                let startBtnCenter = self.startBtn.center
                self.startBtn.center = CGPoint.init(x: startBtnCenter.x, y: self.agreeAllBtnCenterY+kFitWidth(62))
            } completion: { isComplete in
                if self.isAgreeData && self.isAgreeProtocal{
                    self.startBtn.isHidden = false
                }else{
                    self.startBtn.isHidden = true
                }           
            }
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut){
                self.agreeAllBtn.alpha = 1
                let agreeAllBtnCenter = self.agreeAllBtn.center
                self.agreeAllBtn.center = CGPoint.init(x: agreeAllBtnCenter.x, y: self.agreeAllBtnCenterY)
            }
        }
    }
    func checkNetWork(){
        reachability.whenReachable = { reachability in
            reachability.stopNotifier()
            self.netWorkisConnect = true
            
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            self.netWorkisConnect = false
            print("Not reachable")
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

extension WelcomeVC{
    func initUI() {
        view.addSubview(bgImgView)
//        view.addSubview(logoLabel)
        view.addSubview(logoImgView)
        view.addSubview(loganLabel)
        view.addSubview(checkBoxDataImgView)
        view.addSubview(checkBoxDataTapView)
        view.addSubview(dalaLabel)
        view.addSubview(checkBoxProtocalImgView)
        view.addSubview(checkBoxProtocalTapView)
        view.addSubview(protocalLabel)
        view.addSubview(moreProtocalLabel)
//        view.addSubview(arrowImgView)
        view.addSubview(privaceBtn)
        view.addSubview(agreeAllBtn)
        view.addSubview(startBtn)
        
        setConstrait()
        
        privaceBtn.imagePosition(style: .right, spacing: kFitWidth(0))
//        view.addSubview(alertVm)
    }
    func setConstrait(){
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        logoImgView.snp.makeConstraints { make in
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(32))
            make.width.equalTo(kFitWidth(280))
            make.height.equalTo(kFitWidth(80))
            make.centerX.lessThanOrEqualToSuperview()
        }
//        logoLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(getNavigationBarHeight()+kFitWidth(95))
//        }
        loganLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(300))
            make.top.equalTo(logoImgView.snp.bottom).offset(kFitWidth(17))
        }
        dalaLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(56))
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(260))
            make.right.equalTo(kFitWidth(-32))
        }
        checkBoxDataImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
//            make.top.equalTo(dalaLabel)
            make.centerY.lessThanOrEqualTo(dalaLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        checkBoxDataTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(checkBoxDataImgView)
            make.width.height.equalTo(kFitWidth(26))
        }
        protocalLabel.snp.makeConstraints { make in
            make.left.right.equalTo(dalaLabel)
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(308))
        }
        checkBoxProtocalImgView.snp.makeConstraints { make in
            make.left.width.height.equalTo(checkBoxDataImgView)
//            make.top.equalTo(protocalLabel)
            make.centerY.lessThanOrEqualTo(protocalLabel)
        }
        
        checkBoxProtocalTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(checkBoxProtocalImgView)
            make.width.height.equalTo(kFitWidth(26))
        }
        moreProtocalLabel.snp.makeConstraints { make in
            make.left.equalTo(protocalLabel)
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(338))
        }
        privaceBtn.snp.makeConstraints { make in
//            make.left.equalTo(moreProtocalLabel.snp.right).offset(kFitWidth(-14))
            make.left.equalTo(moreProtocalLabel.snp.right).offset(kFitWidth(2))
            make.centerY.lessThanOrEqualTo(moreProtocalLabel)
        }
//        arrowImgView.snp.makeConstraints { make in
//            make.left.equalTo(moreProtocalLabel.snp.right).offset(kFitWidth(4))
//            make.centerY.lessThanOrEqualTo(moreProtocalLabel)
//            make.width.height.equalTo(kFitWidth(16))
//        }
        agreeAllBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-32))
            make.height.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-48)-getBottomSafeAreaHeight())
        }
        agreeAllBtnCenterY = SCREEN_HEIGHT-(kFitWidth(48)+getBottomSafeAreaHeight()+kFitWidth(8))
//        startBtn.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(231)+SCREEN_WIDHT)
//            make.width.equalTo(kFitWidth(112))
//            make.height.equalTo(kFitWidth(48))
//            make.bottom.equalTo(kFitWidth(-48)-getBottomSafeAreaHeight())
//        }
        startBtn.snp.makeConstraints { make in
            make.centerX.equalTo(agreeAllBtn)
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(agreeAllBtn.snp.bottom).offset(kFitWidth(30))
        }
    }
}
