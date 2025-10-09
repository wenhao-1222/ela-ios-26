//
//  ElaLaunchVC.swift
//  lns
//
//  Created by Elavatine on 2025/5/7.
//

class ElaLaunchVC: WHBaseViewVC {
    
    var lchBlock:(()->())?
    
    private var adDict: NSDictionary?
    private var didTap = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        let uId = UserDefaults.standard.value(forKey: userId) as? String ?? ""
        let token = UserDefaults.standard.value(forKey: token) as? String ?? ""
        
        if uId.count > 0 && token.count > 0{
            loadSplashImage()
        }else{
            self.peacockImgView.isHidden = true
            tapButton.isHidden = true
            UIView.animate(withDuration: 0.5, delay: 0.25,options: .curveLinear) {
                self.logoImgView.alpha = 1
                self.logoLabel.alpha = 1
            }
        }
        
//        UIView.animate(withDuration: 0.5, delay: 0.25,options: .curveLinear) {
//            self.logoImgView.alpha = 1
//            self.logoLabel.alpha = 1
//            self.peacockImgView.alpha = 1
//            self.tapButton.alpha = 1
//        }
        DLLog(message: "ElaLaunchVC start：\(Date().currentSeconds)   - \(Date().timeStampMill)")
        DispatchQueue.main.asyncAfter(deadline: .now()+3.2, execute: {
//            DispatchQueue.main.asyncAfter(deadline: .now()+3.6, execute: {
            DLLog(message: "ElaLaunchVC end:\(Date().currentSeconds)   - \(Date().timeStampMill)")
            self.lchBlock?()
        })
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
//        img.setImgLocal(imgName: "lch_bg")
        img.setImgLocal(imgName: "launch_bg_img")
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var logoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "welcome_logo_icon")
        img.contentMode = .scaleAspectFit
        img.alpha = 0
        
        return img
    }()
    lazy var logoLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "你身边的专业健康指导"
//        lab.text = "专业饮食记录方案"
//        lab.text = "专业健身饮食记录"
//        lab.text = "专业饮食记录平台"
        lab.text = "专业饮食记录系统"
        lab.textColor = .white
        lab.alpha = 0
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var peacockImgView: UIImageView = {
        let img = UIImageView()
//        img.setImgLocal(imgName: "peacock_img")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        img.alpha = 0
        return img
    }()
    lazy var tapButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("了解更多", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        btn.alpha = 0
        btn.addTarget(self, action: #selector(adTap), for: .touchUpInside)
        
        return btn
    }()
}

extension ElaLaunchVC{
    func initUI() {
        view.backgroundColor = .THEME
        view.addSubview(bgImgView)
        view.addSubview(logoImgView)
        view.addSubview(logoLabel)
        view.addSubview(peacockImgView)
        view.addSubview(tapButton)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(adTap))
//        peacockImgView.addGestureRecognizer(tap)

        setConstrait()
    }
    func setConstrait() {
        peacockImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        tapButton.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(140))
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(323)+getTopSafeAreaHeight())
//            make.height.equalTo(kFitWidth(30))
        }
        logoImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(200)
            make.width.equalTo(280)
            make.height.equalTo(80)
        }
        logoLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(logoImgView.snp.bottom)
        }
    }
    func loadSplashImage() {
        let array = UserDefaults.getSplashMaterials()
        
        if array.count > 0 {
//            let index = Int.random(in: 0..<array.count)
//            if let dict = array[index] as? NSDictionary {
            var selectDict: NSDictionary?
            if let list = array as? [NSDictionary] {
                var total: Double = 0
                var weights: [Double] = []
                for item in list {
                    let w = item.doubleValueForKey(key: "weight")
                    let weight = w > 0 ? w : 0
                    total += weight
                    weights.append(weight)
                }
                if total > 0 {
                    var random = Double.random(in: 0..<total)
                    for (index, weight) in weights.enumerated() {
                        random -= weight
                        if random <= 0 {
                            selectDict = list[index]
                            break
                        }
                    }
                }
                if selectDict == nil {
                    let index = Int.random(in: 0..<list.count)
                    selectDict = list[index]
                }
            }
            if let dict = selectDict {
                adDict = dict
                var localPath = dict.stringValueForKey(key: "localPath")
                if localPath.count > 0 {
                    // If absolute path not found, try relative path (cached file name)
                    if !FileManager.default.fileExists(atPath: localPath) {
                        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                        let fileName = (localPath as NSString).lastPathComponent
                        let relativePath = caches.appendingPathComponent("SplashAds").appendingPathComponent(fileName).path
                        localPath = relativePath
                    }
                    if FileManager.default.fileExists(atPath: localPath) {
                        peacockImgView.image = UIImage(contentsOfFile: localPath)
                        peacockImgView.isHidden = false
                        tapButton.isHidden = false
                        logoImgView.isHidden = true
                        logoLabel.isHidden = true
                        UIView.animate(withDuration: 0.5, delay: 0.25,options: .curveLinear) {
                            self.peacockImgView.alpha = 1
                            self.tapButton.alpha = 1
                        }
                        let params = adDict?["params"]as? NSDictionary ?? [:]
                        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                                            scenarioType: .launch_view,
                                                            text: "\(params.stringValueForKey(key: "id"))")
                        return
                    }
                }
//                let urlString = dict.stringValueForKey(key: "ossUrl")
//                if urlString.count > 0 {
//                    peacockImgView.setImgUrl(urlString: urlString)
//                }
            }
        }
        
        logoImgView.isHidden = false
        logoLabel.isHidden = false
        peacockImgView.isHidden = true
        tapButton.isHidden = true
        UIView.animate(withDuration: 0.5, delay: 0.25,options: .curveLinear) {
            self.logoImgView.alpha = 1
            self.logoLabel.alpha = 1
        }
    }
    @objc private func adTap() {
        guard didTap == false else { return }
        didTap = true
//        let target = "CourseListVC"
//        guard let dict = adDict,
        let params = adDict?["params"]as? NSDictionary ?? [:]
        guard let target = params["ios_target_page"] as? String,
              target.count > 0 else { return }
        UserConfigModel.shared.splashId = params.stringValueForKey(key: "id")
        if let block = lchBlock {
            lchBlock = nil
            block()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.45) {
//                (UIApplication.shared.delegate as? AppDelegate)?.dealNotification(target_page: target)
                self.openTarget(target)
            }
        } else {
//            (UIApplication.shared.delegate as? AppDelegate)?.dealNotification(target_page: target)
            self.openTarget(target)
        }
    }
    private func openTarget(_ className: String) {
        guard let vc = createVCObjectFromString(className: className) else {
//            (UIApplication.shared.delegate as? AppDelegate)?.dealNotification(target_page: className)
            return
        }
        UserInfoModel.shared.event_log_session_id = Date().todaySeconds
        EventLogUtils().sendEventLogRequest(eventName: .CLICK_BUTTON,
                                            scenarioType: .launch_view,
                                            text: "教程:\(UserConfigModel.shared.splashId)")
        let topVC = UIApplication.topViewController()
        if let nav = topVC?.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            topVC?.present(vc, animated: true)
        }
    }
}
