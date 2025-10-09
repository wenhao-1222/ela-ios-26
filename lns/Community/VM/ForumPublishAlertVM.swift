//
//  ForumPublishAlertVM.swift
//  lns
//  发帖浮窗
//  Created by Elavatine on 2025/2/25.
//

class ForumPublishAlertVM: UIView {
    
    var selfHeight = kFitWidth(64)
    var whiteViewWidth = kFitWidth(0)
    
    var timer: Timer?
    var isShow = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
//        self.clipsToBounds = true
        
        self.alpha = 0
        whiteViewWidth = SCREEN_WIDHT-kFitWidth(20)
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(publishSuccess), name: NSNotification.Name(rawValue: "uploadForumThreadFinished"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(publishFailed(obj:)), name: NSNotification.Name(rawValue: "uploadForumThreadFailed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(compressFailed(obj:)), name: NSNotification.Name(rawValue: "compressVideoError"), object: nil)
//
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "compressVideoError"), object: ["code":"400",
//                                                                                                            "message":"未找到视频资源"])
//        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(10), y:-selfHeight, width: whiteViewWidth, height: selfHeight-kFitWidth(6)))
        vi.layer.cornerRadius = kFitWidth(16)
//                vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
//        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(4)
        img.clipsToBounds = true
        img.setImgLocal(imgName: "body_fat_man_1")
        
        return img
    }()
    lazy var imgCoverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_65
        
        return vi
    }()
    lazy var progressLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textColor = .white
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
//        lab.text = "4%"
        return lab
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "发帖测试标题急急急服务i哦额叫哦发i哦忘记哦if额我i额外"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.text = "正在上传中"
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    
    lazy var progressBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var progressView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        
        return vi
    }()
}

extension ForumPublishAlertVM{
    func showView() {
        self.isShow = true
        self.detailLabel.text = "正在上传中"
        self.updateUI()
        self.alpha = 1
        self.startCountdown()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: kFitWidth(10), y:kFitWidth(6), width: self.whiteViewWidth, height: self.selfHeight-kFitWidth(6))
        }
    }
    
    @objc func hiddenView() {
        self.isShow = false
        self.disableTimer()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: kFitWidth(10), y:-self.selfHeight, width: self.whiteViewWidth, height: self.selfHeight-kFitWidth(6))
        }completion: { t in
            self.alpha = 0
        }
    }
    @objc func publishSuccess() {
        DispatchQueue.main.async {
            self.detailLabel.text = "已发布"
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.hiddenView()
            })
        }
    }
    @objc func publishFailed(obj:Notification) {
        let failObj = obj.object as? NSDictionary ?? [:]
        DispatchQueue.main.async {
            self.detailLabel.text = "\(failObj["message"] as? String ?? "网络异常，请稍后重试")"
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.hiddenView()
            })
        }
        
    }
    @objc func compressFailed(obj:Notification) {
        let failObj = obj.object as? NSDictionary ?? [:]
        DispatchQueue.main.async {
            self.detailLabel.text = "\(failObj["message"] as? String ?? "视频资源获取异常")"
            DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                self.hiddenView()
            })
        }
        
    }
    func updateUI() {
        DispatchQueue.main.async {
            if ForumPublishManager.shared.coverImg != nil{
                self.imgView.isHidden = false
                self.imgView.image = ForumPublishManager.shared.coverImg
                self.imgView.snp.remakeConstraints { make in
                    make.left.equalTo(kFitWidth(15))
                    make.centerY.lessThanOrEqualToSuperview()
                    make.width.height.equalTo(kFitWidth(44))
                }
            }else{
                self.imgView.isHidden = true
                self.imgView.snp.remakeConstraints { make in
                    make.left.equalTo(kFitWidth(15))
                    make.centerY.lessThanOrEqualToSuperview()
                    make.width.equalTo(kFitWidth(0))
                    make.height.equalTo(kFitWidth(44))
                }
            }
            
            self.titleLabel.text = ForumPublishManager.shared.publshMsgDict.stringValueForKey(key: "title")
            self.updatePercent()
        }
    }
    @objc func updatePercent() {
        if self.isShow{
            let percentDict = ForumPublishSqlite.getInstance().queryProgress(ctime: ForumPublishManager.shared.publishModel.ctime)
    //        var percent = ForumPublishManager.shared.publshMsgDict.stringValueForKey(key: "progress").intValue
            var percent = percentDict.stringValueForKey(key: "progress").floatValue * 100
            if ForumPublishManager.shared.publshMsgDict.stringValueForKey(key: "contentType") == "2" {
                let compressPercentDict = ForumPublishSqlite.getInstance().queryCompressProgress(ctime: ForumPublishManager.shared.publishModel.ctime)
                let compressPercent = compressPercentDict.stringValueForKey(key: "progress").floatValue * 100
                DLLog(message: "ForumPublishAlertVM:\(compressPercentDict)")
                percent = percent * 0.5 + compressPercent * 0.5
            }
            
            if percent > 100 {
                percent = 100
            }
            DLLog(message: "ForumPublishAlertVM:\(percent)")
    //        percent = Float(String(format: "%.0f", percent).intValue)
            let progressWidth = Float(self.whiteViewWidth) * Float(percent) * 0.01
            DispatchQueue.main.async {
                if percent < 100{
                    self.progressLabel.text = "\(String(format: "%.1f", percent))%"
                }else{
                    self.progressLabel.text = "\(String(format: "%.0f", percent))%"
                }
                
//                self.progressLabel.text = "\(WHUtils.convertStringToStringOneDigit("\(percent)") ?? "0")%"
                self.progressView.snp.remakeConstraints { make in
                    make.left.bottom.equalToSuperview()
                    make.height.equalTo(kFitWidth(2))
                    make.width.equalTo(progressWidth)
                }
            }
        }else{
            self.disableTimer()
        }
    }
    func startCountdown() {
        //一般倒计时是操作UI，使用主队列
        DispatchQueue.global().async { [self] in
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatePercent), userInfo: nil, repeats: true)
            RunLoop.current.run()
        }
//        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
//            // 定时器执行的操作
//            if self.isShow {
//                self.updatePercent()
//            }else{
//                self.disableTimer()
//            }
//        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

extension ForumPublishAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(imgView)
        imgView.addSubview(imgCoverView)
        imgView.addSubview(progressLabel)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(detailLabel)
        whiteView.addSubview(progressBottomView)
        progressBottomView.addSubview(progressView)
        
        setConstrait()
        whiteView.addShadow()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(44))
        }
        imgCoverView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        progressLabel.snp.makeConstraints { make in
//            make.left.width.equalToSuperview()
            make.left.equalTo(kFitWidth(4))
            make.right.equalTo(kFitWidth(-4))
            make.centerY.lessThanOrEqualToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(kFitWidth(15))
            make.right.equalTo(kFitWidth(-15))
            make.top.equalTo(imgView)
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(imgView)
        }
        progressBottomView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(4))
        }
        progressView.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(2))
            make.width.equalTo(whiteViewWidth*0.43)
        }
    }
}
