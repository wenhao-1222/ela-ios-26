//
//  JournalReportWeekMsgShareVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/20.
//


import Photos
import MCToast

class JournalReportWeekMsgShareVM: UIView {
    
    var controller = WHBaseViewVC()
    var selfHeight = kFitWidth(0)
    let bottomWidthHeight = kFitWidth(55)+WHUtils().getBottomSafeAreaHeight()
    var weekMsgDict = NSDictionary()
    var commenListHeight = kFitWidth(0)
    var badgesImagesLoaded = false
    var pendingSaveBlock: (() -> Void)?
    weak var badgesCell: JournalReportWeekBadgesCell?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight-bottomWidthHeight), style: .grouped)
        vi.backgroundColor = .clear
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
//        vi.tableFooterView = nil
        vi.sectionHeaderHeight = 0
        vi.register(JournalReportWeekTopCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekTopCell")
        vi.register(JournalReportWeekScoreCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekScoreCell")
        vi.register(JournalReportWeekNaturalCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekNaturalCell")
        vi.register(JournalReportWeightCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeightCell")
        vi.register(JournalReportWeekCalendarCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekCalendarCell")
        vi.register(JournalReportWeekAdviceCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekAdviceCell")
        vi.register(JournalReportWeekBadgesCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekBadgesCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
//            vi.sectionFooterHeight = 0
        }
        vi.contentInsetAdjustmentBehavior = .never
        vi.contentInset = .zero
        vi.scrollIndicatorInsets = .zero
        vi.reloadCompletion = {()in
            let size = self.tableView.contentSize
            if abs(self.commenListHeight - size.height) > 1{
                self.commenListHeight = size.height
                self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.commenListHeight)
            }
        }
        return vi
    }()
}

extension JournalReportWeekMsgShareVM{
    @objc func saveAction() {
        if !badgesImagesLoaded {
            pendingSaveBlock = { [weak self] in
                self?.saveAction()
            }
            return
        }
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                if status == .restricted || status == .denied{
                    self.controller.presentAlertVc(confirmBtn: "打开", message: "无访问相册权限，是否去打开权限?", title: "提示", cancelBtn: "取消", handler: { (actions) in
                        let url = NSURL.init(string: UIApplication.openSettingsURLString)
                        if UIApplication.shared.canOpenURL(url! as URL){
                            UIApplication.shared.openURL(url! as URL)
                        }
                    }, viewController: self.controller)
                }else{
//                    MCToast.mc_loading(duration: 30)
                    if let image = self.tableView.snapshotFullContentWithPadding(padding: kFitWidth(-16),topPadding: kFitWidth(-20),bottomPadding: kFitWidth(-40)){//mc_makeImage()
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                    }else{
                        MCToast.mc_remove()
                        MCToast.mc_text("截图失败")
                    }
                }
            }
        }
    }
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject){
        MCToast.mc_remove()
        if error != nil{
            MCToast.mc_text("保存失败。")
        }else{
            MCToast.mc_text("已保存到系统相册")
        }
    }
    func cancelPendingSave() {
        pendingSaveBlock = nil
        badgesCell?.cancelLoad()
    }
}
extension JournalReportWeekMsgShareVM:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        let badgesArray = weekMsgDict["badges"]as? NSArray ?? []
        if badgesArray.count > 0 {
            return 4
        }
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else if section == 1{
            let weightChange = self.weekMsgDict["weightChange"]as? NSDictionary ?? [:]
            if weightChange.stringValueForKey(key: "diff").count > 0 {
                return 3
            }else{
                return 2
            }
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekTopCell") as? JournalReportWeekTopCell
                cell?.updateUIShare(dict: self.weekMsgDict)
                return cell ?? JournalReportWeekTopCell()
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekScoreCell") as? JournalReportWeekScoreCell
                cell?.updateUI(dict: self.weekMsgDict)
                return cell ?? JournalReportWeekScoreCell()
                
            }
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekNaturalCell") as? JournalReportWeekNaturalCell
                cell?.updateUI(dict: self.weekMsgDict)
                return cell ?? JournalReportWeekNaturalCell()
            }else if indexPath.row == 1{
                let weightChange = self.weekMsgDict["weightChange"]as? NSDictionary ?? [:]
                if weightChange.stringValueForKey(key: "diff").count > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeightCell") as? JournalReportWeightCell
                    cell?.updateUI(dict: weightChange)
                    return cell ?? JournalReportWeightCell()
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekCalendarCell") as? JournalReportWeekCalendarCell
                    cell?.updateUI(dict: self.weekMsgDict)
                    return cell ?? JournalReportWeekCalendarCell()
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekCalendarCell") as? JournalReportWeekCalendarCell
                cell?.updateUI(dict: self.weekMsgDict)
                return cell ?? JournalReportWeekCalendarCell()
            }
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekAdviceCell") as? JournalReportWeekAdviceCell
            cell?.updateUI(dict: self.weekMsgDict)
            return cell ?? JournalReportWeekAdviceCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekBadgesCell") as? JournalReportWeekBadgesCell
//            cell?.updateUIForShare(dict: self.weekMsgDict)
            cell?.loadImagesComplete = { [weak self] in
                guard let self = self else { return }
                self.badgesImagesLoaded = true
                self.pendingSaveBlock?()
                self.pendingSaveBlock = nil
            }
            cell?.updateUIForShare(dict: self.weekMsgDict)
            self.badgesCell = cell
            return cell ?? JournalReportWeekBadgesCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 3{
            return nil
        }else if section == 2{
            let badgesArray = weekMsgDict["badges"]as? NSArray ?? []
            if badgesArray.count > 0 {
                let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(16)))
                let vm = JournalReportWeekDashVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
                vi.addSubview(vm)
                
                return vi
            }else{
                let footV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(20)))
                footV.backgroundColor = .clear
                let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(20)))
                vi.backgroundColor = .white
                vi.addClipCorner(corners: [.bottomLeft,.bottomRight], radius: kFitWidth(12))
                
                footV.addSubview(vi)
                
                return footV
            }
        }else{
            let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(16)))
            let vm = JournalReportWeekDashVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
            vi.addSubview(vm)
            
            return vi
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3{
            return 0
        }else if section == 2{
            let badgesArray = weekMsgDict["badges"]as? NSArray ?? []
            if badgesArray.count > 0 {
                
            }else{
                return kFitWidth(20)
            }
        }
        return kFitWidth(16)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension JournalReportWeekMsgShareVM:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0{
            scrollView.contentOffset.y = 0
        }else{
//            self.offsetChangeBlock?(self.scrollView.contentOffset.y)
        }
    }
}

extension JournalReportWeekMsgShareVM{
    func initUI() {
        addSubview(tableView)
        
//        initSkeleton()
    }
    func initSkeleton() {
        self.isSkeletonable = true
        self.tableView.isSkeletonable = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.03, execute: {
            self.tableView.showAnimatedGradientSkeleton()
            self.tableView.isUserInteractionEnabled = true
        })
    }
}
