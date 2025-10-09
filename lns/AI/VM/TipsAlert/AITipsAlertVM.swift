//
//  AITipsAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITipsAlertVM: UIView {
    
    var whiteViewHeight = SCREEN_HEIGHT-kFitWidth(67)+kFitWidth(16)
    var whiteViewOriginY = kFitWidth(67)
    
    var isFirstLoad = true
    var listHeight = kFitWidth(0)
    
    var aiTipsBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        initUI()
        
//        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(67) + SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "AI识别"
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        
        return lab
    }()
    lazy var closeImgView: FeedBackUIImageView = {
        let img = FeedBackUIImageView()
        img.setImgLocal(imgName: "ai_alert_close_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(closeAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var tableView: ForumCommentListTableView = {
        let tableHeight = whiteViewHeight-kFitWidth(54)-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16)
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: kFitWidth(54), width: SCREEN_WIDHT, height: whiteViewHeight-kFitWidth(54)-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16)), style: .plain)
//        self.listHeight = tableHeight
        vi.tableHeaderView = self.headImgVm
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
//        vi.bounces = false
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .white
        vi.register(AITipsTitleCell.classForCoder(), forCellReuseIdentifier: "AITipsTitleCell")
        vi.register(AITipsContentCell.classForCoder(), forCellReuseIdentifier: "AITipsContentCell")
        vi.register(AITipsDonationCell.classForCoder(), forCellReuseIdentifier: "AITipsDonationCell")
        vi.register(AITipsDonationTypeCell.classForCoder(), forCellReuseIdentifier: "AITipsDonationTypeCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        
        vi.reloadCompletion = {()in
            let size = self.tableView.contentSize
//            if abs(self.listHeight - size.height) > 1{
            self.listHeight = size.height + kFitWidth(20)
//                self.updateCommentListFrame()
                
//            }
        }
        
        return vi
    }()
    lazy var headImgVm: AITipsAlertHeadImgVM = {
        let vm = AITipsAlertHeadImgVM.init(frame: .zero)
        return vm
    }()
    lazy var confirmVm: AITipsAlertConfirmBtn = {
        let vm = AITipsAlertConfirmBtn.init(frame: CGRect.init(x: 0, y: self.whiteViewHeight-WHUtils().getBottomSafeAreaHeight()-kFitWidth(55)-kFitWidth(16), width: 0, height: 0))
        
        vm.canCloseBlock = {()in
            self.isFirstLoad = false
            self.closeImgView.isHidden = false
        }
        vm.confirmBlock = {()in
            self.hiddenView()
        }
        return vm
    }()
}

extension AITipsAlertVM{
    @objc func showView() {
        if self.isFirstLoad == false{
            confirmVm.isHidden = true
            closeImgView.isHidden = false
//            tableView.frame = CGRect.init(x: 0, y: kFitWidth(54), width: SCREEN_WIDHT, height: whiteViewHeight-kFitWidth(54)-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16))
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }
   }
   @objc func hiddenView() {
       if UserDefaults.getString(forKey: .isShowAiTipsAlert)?.intValue != 1{
           UserDefaults.set(value: "2", forKey: .isShowAiTipsAlert)
       }
       
       UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
           self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
           self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
       }completion: { t in
           self.isHidden = true
       }
  }
    @objc func closeAction() {
        self.hiddenView()
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if self.isFirstLoad{
            return
        }
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: view)
//                DLLog(message: "translation.y:\(translation.y)")
                if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                    self.hiddenView()
                }else{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                    }
                }
            default:
                break
            }
        }
    }
}

extension AITipsAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(closeImgView)
        whiteView.addSubview(tableView)
        
        if UserDefaults.getString(forKey: .isShowAiTipsAlert)?.count ?? 0 == 0 || UserDefaults.getString(forKey: .isShowAiTipsAlert)?.intValue == 2{
            isFirstLoad = true
            whiteView.addSubview(confirmVm)
//            UserDefaults.set(value: "2", forKey: .isShowAiTipsAlert)
        }else{
            isFirstLoad = false
        }
        
        setConstrait()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.refreshAlert(showView: self.isFirstLoad)
        })
        
    }
    func refreshAlert(showView:Bool=false) {
        whiteViewHeight = listHeight + kFitWidth(32) + kFitWidth(54) + WHUtils().getBottomSafeAreaHeight()
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
        whiteView.frame = CGRect.init(x: 0, y: whiteViewOriginY+SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-whiteViewOriginY)
        confirmVm.frame =  CGRect.init(x: 0, y: self.whiteViewHeight-WHUtils().getBottomSafeAreaHeight()-kFitWidth(55)-kFitWidth(16), width: SCREEN_WIDHT, height: confirmVm.selfHeight)
        if self.isFirstLoad {
            closeImgView.isHidden = true
            confirmVm.isHidden = false
            tableView.frame = CGRect.init(x: 0, y: kFitWidth(54), width: SCREEN_WIDHT, height: whiteViewHeight-kFitWidth(54)-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16))
//            tableView.frame = CGRect.init(x: 0, y: kFitWidth(54), width: SCREEN_WIDHT, height: self.whiteViewHeight-WHUtils().getBottomSafeAreaHeight()-kFitWidth(109)-kFitWidth(16))
        }else{
            confirmVm.isHidden = true
            closeImgView.isHidden = false
            tableView.frame = CGRect.init(x: 0, y: kFitWidth(54), width: SCREEN_WIDHT, height: whiteViewHeight-kFitWidth(54)-kFitWidth(16))
//            tableView.frame = CGRect.init(x: 0, y: kFitWidth(54), width: SCREEN_WIDHT, height: whiteViewHeight-kFitWidth(54)-WHUtils().getBottomSafeAreaHeight()-kFitWidth(16))
        }
        if self.isFirstLoad{
            self.showView()
            self.confirmVm.startCountdown()
        }
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
        }
        closeImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.width.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(titleLab)
        }
    }
}

extension AITipsAlertVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AITipsTitleCell") as? AITipsTitleCell
        
        if indexPath.row == 0 {
            cell?.titleLab.text = "提示"
        }else if indexPath.row == 1{
            let tipsCell = tableView.dequeueReusableCell(withIdentifier: "AITipsContentCell")as? AITipsContentCell
            tipsCell?.updateUI()
            tipsCell?.aiTipsBlock = {()in
//                TouchGenerator.shared.touchGenerator()
                self.aiTipsBlock?()
            }
            return tipsCell ?? AITipsContentCell()
        }
//        else if indexPath.row == 3{
//            let tipsCell = tableView.dequeueReusableCell(withIdentifier: "AITipsDonationCell")as? AITipsDonationCell
//            let tipsString = "AI识别会持续消耗大量的成本，100%的捐款将用于功能维护。"
//            tipsCell?.contentLab.setLineSpace(lineSpcae: kFitWidth(5), textString: tipsString)
//            
//            
//            return tipsCell ?? AITipsDonationCell()
//        }else if indexPath.row == 4{
//            let donationCell = tableView.dequeueReusableCell(withIdentifier: "AITipsDonationTypeCell")as? AITipsDonationTypeCell
//            let tipsString = "提示：\n1.你的捐赠能够帮助我们在持续更新优化的过程中减少变现压力\n2.无需捐赠也可免费使用Elavatine全功能，请理性支持\n3.感谢大家的共同努力，使得Elavatine能够维持免费"
//            donationCell?.contentLab.setLineSpace(lineSpcae: kFitWidth(5), textString: tipsString)
//            return donationCell ?? AITipsDonationTypeCell()
//        }else{
//            cell?.titleLab.text = "捐款"
//        }
        
        return cell ?? AITipsTitleCell()
    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.height - kFitWidth(20){
//            self.confirmVm.disableTimer()
//        }
//    }
}
