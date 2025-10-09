//
//  MallOrderDetailVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/18.
//

import MCToast


class MallOrderDetailVC: WHBaseViewVC {
    
    var orderDict = NSDictionary()
    var orderModel = MallDetailModel()
    var number = 1
    var dataArray:[cell_model] = [cell_model]()
    var expressArray:[ExpressMsgModel] = [ExpressMsgModel]()
    var afterSaleDict = NSDictionary()
    var expressTracking = NSDictionary()
    
    var isFold = false
    var cellNumber = 2
    private var hasAfterSaleSectionVisible = false

    private var countdownTimer: Timer?
    private var remainingSeconds: Int = 0
    private var deadlineTime: Date?
    
    var timeOutBlock:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendOrderDetailRequest()
    }
    
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-(self.getNavigationBarHeight()+kFitWidth(1))), style: .grouped)
        vi.separatorStyle = .none
        vi.delegate = self
        vi.dataSource = self
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .COLOR_BG_F2
        vi.contentInsetAdjustmentBehavior = .never
        vi.sectionFooterHeight = 0
        vi.register(MallOrderAfterSaleMsgCell.classForCoder(), forCellReuseIdentifier: "MallOrderAfterSaleMsgCell")
        vi.register(MallPaySuccessTopCell.classForCoder(), forCellReuseIdentifier: "MallPaySuccessTopCell")
        vi.register(MallPayMsgCopyCell.classForCoder(), forCellReuseIdentifier: "MallPayMsgCopyCell")
        vi.register(MallPaySuccessTextCell.classForCoder(), forCellReuseIdentifier: "MallPaySuccessTextCell")
        vi.register(MallPaySuccessBottomCell.classForCoder(), forCellReuseIdentifier: "MallPaySuccessBottomCell")
        vi.register(MallOrderExpressCell.classForCoder(), forCellReuseIdentifier: "MallOrderExpressCell")
        
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }
        

        return vi
    }()
    lazy var bottomVm: MallPaySuccessBottomVM = {
        let vm = MallPaySuccessBottomVM.init(frame: .zero)
        vm.payButton.setTitle("去支付", for: .normal)
        vm.payBlocK = {()in
//            DLLog(message: "查看订单")
            let vc = CourseOrderPayAlertVC()
            vc.bizType = "2" 
            vc.msgDict = self.orderDict
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                // iPhone：保持你原有的视觉（透明背景 + 自定义底部弹出）
                vc.modalPresentationStyle = .pageSheet
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true)
            }
        
            vc.paySuccessBlock = { dic in
                self.sendOrderDetailRequest()
//                let v = CoursePayResultVC()
//                v.msgDict = self.orderDict
//                v.orderDict = dic
//                self.navigationController?.pushViewController(v, animated: true)
            }
        }
        
        return vm
    }()
}

extension MallOrderDetailVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.afterSaleDict.stringValueForKey(key: "reason").count > 0 {//有售后
            return self.expressArray.count > 0 ? 3 : 2
        }else{//无售后
            return self.expressArray.count > 0 ? 2 : 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.afterSaleDict.stringValueForKey(key: "reason").count > 0{
            if section == 0 {
                return 1
            }else if section == 1{
                if isFold {
                    self.cellNumber = 2
                    return 2
                }else{
                    self.cellNumber = 2 + dataArray.count
                    return 2 + dataArray.count
                }
            }else{
                return expressArray.count + 1
            }
        }else{
            if section == 0 {
                if isFold {
                    self.cellNumber = 2
                    return 2
                }else{
                    self.cellNumber = 2 + dataArray.count
                    return 2 + dataArray.count
                }
            }else{
                return expressArray.count + 1
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if self.afterSaleDict.stringValueForKey(key: "reason").count > 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderAfterSaleMsgCell")as? MallOrderAfterSaleMsgCell
                cell?.updateUI(dict: self.afterSaleDict)
                
                return cell ?? MallOrderAfterSaleMsgCell()
            }
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessTopCell")as? MallPaySuccessTopCell
                cell?.updateUI(model: self.orderModel, number: self.number)
                
                return cell ?? MallPaySuccessTopCell()
            }else{
                if indexPath.row == self.cellNumber - 1{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessBottomCell")as? MallPaySuccessBottomCell
                    cell?.updateUI(money: orderDict.stringValueForKey(key: "payAmount"))
                    cell?.updateStrait(hiddenDottedLine: self.cellNumber == 2)
                    cell?.setFoldStatus(isFold: self.isFold)
                    
                    cell?.foldBlock = {()in
                        self.toggleFoldState()
                    }
                    
                    return cell ?? MallPaySuccessBottomCell()
                }else{
                    let model = dataArray[indexPath.row-1]
                    if model.title == "订单编号"{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "MallPayMsgCopyCell")as? MallPayMsgCopyCell
                        cell?.updateUI(leftTitle: model.title,
                                       detailString: model.detailString,
                                       type: "orderId")
                        cell?.copyBlock = {()in
                            UIPasteboard.general.string = "\(model.detailString)"
                            MCToast.mc_success("订单编号已复制！")
                        }
                        return cell ?? MallPayMsgCopyCell()
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessTextCell")as? MallPaySuccessTextCell
                        cell?.updateUI(leftTitle: model.title,
                                       detailString: model.detailString,
                                       textColor: model.textColor)
                        
                        return cell ?? MallPaySuccessTextCell()
                    }
                }
            }
        }else if indexPath.section == 1{
            if self.afterSaleDict.stringValueForKey(key: "reason").count > 0{
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessTopCell")as? MallPaySuccessTopCell
                    cell?.updateUI(model: self.orderModel, number: self.number)
                    
                    return cell ?? MallPaySuccessTopCell()
                }else{
                    if indexPath.row == self.cellNumber - 1{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessBottomCell")as? MallPaySuccessBottomCell
                        cell?.updateUI(money: orderDict.stringValueForKey(key: "payAmount"))
                        cell?.updateStrait(hiddenDottedLine: self.cellNumber == 2)
                        cell?.setFoldStatus(isFold: self.isFold)
                        
                        cell?.foldBlock = {()in
                            self.toggleFoldState()
                        }
                        
                        return cell ?? MallPaySuccessBottomCell()
                    }else{
                        let model = dataArray[indexPath.row-1]
                        if model.title == "订单编号"{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "MallPayMsgCopyCell")as? MallPayMsgCopyCell
                            cell?.updateUI(leftTitle: model.title,
                                           detailString: model.detailString,
                                           type: "orderId")
                            cell?.copyBlock = {()in
                                UIPasteboard.general.string = "\(model.detailString)"
                                MCToast.mc_success("订单编号已复制！")
                            }
                            return cell ?? MallPayMsgCopyCell()
                        }else{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessTextCell")as? MallPaySuccessTextCell
                            cell?.updateUI(leftTitle: model.title,
                                           detailString: model.detailString,
                                           textColor: model.textColor)
                            
                            return cell ?? MallPaySuccessTextCell()
                        }
                    }
                }
            }else{
                if indexPath.row == 0{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MallPayMsgCopyCell")as? MallPayMsgCopyCell
                    cell?.updateUI(leftTitle: expressTracking.stringValueForKey(key: "expressCompany"),
                                   detailString: expressTracking.stringValueForKey(key: "expressTrackingId"),
                                   type: "express")
                    cell?.copyBlock = {()in
                        UIPasteboard.general.string = "\(self.expressTracking.stringValueForKey(key: "expressTrackingId"))"
                        MCToast.mc_success("物流单号已复制！")
                    }
                    return cell ?? MallPayMsgCopyCell()
                }else{
                    let expModel = expressArray[indexPath.row-1]
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderExpressCell")as? MallOrderExpressCell
                    cell?.udpateUI(model:expModel,
                                   textColor: indexPath.row == 1 ? .COLOR_TEXT_TITLE_0f1214 : .COLOR_TEXT_TITLE_0f1214_50,
                                   circleType: indexPath.row == 1 ? 0 : 1)
                    cell?.updateLine(index: indexPath.row, dataCount: expressArray.count)
                    
                    return cell ?? MallPaySuccessTextCell()
                }
            }
        }else{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MallPayMsgCopyCell")as? MallPayMsgCopyCell
                cell?.updateUI(leftTitle: expressTracking.stringValueForKey(key: "expressCompany"),
                               detailString: expressTracking.stringValueForKey(key: "expressTrackingId"),
                               type: "express")
                cell?.copyBlock = {()in
                    UIPasteboard.general.string = "\(self.expressTracking.stringValueForKey(key: "expressTrackingId"))"
                    MCToast.mc_success("物流单号已复制！")
                }
                return cell ?? MallPayMsgCopyCell()
            }else{
                let expModel = expressArray[indexPath.row-1]
                let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderExpressCell")as? MallOrderExpressCell
                cell?.udpateUI(model:expModel,
                               textColor: indexPath.row == 1 ? .COLOR_TEXT_TITLE_0f1214 : .COLOR_TEXT_TITLE_0f1214_50,
                               circleType: indexPath.row == 1 ? 0 : 1)
                cell?.updateLine(index: indexPath.row, dataCount: expressArray.count)
                
                return cell ?? MallPaySuccessTextCell()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.afterSaleDict.stringValueForKey(key: "reason").count > 0 {
            return section <= 1 ? kFitWidth(12) : 0
        }
        return section == 0 ? kFitWidth(12) : 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let vi = UIView.init(frame: cgre)
        return nil
    }
}

extension MallOrderDetailVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        if orderDict.stringValueForKey(key: "status") == "1"{
            initNavi(titleStr: "待支付")
        }else if orderDict.stringValueForKey(key: "status") == "2"{
            initNavi(titleStr: "已取消")
        }else if orderDict.stringValueForKey(key: "status") == "3"{
            initNavi(titleStr: "待发货")
        }else if orderDict.stringValueForKey(key: "status") == "4"{
            initNavi(titleStr: "运输中")
        }else if orderDict.stringValueForKey(key: "status") == "5"{
            initNavi(titleStr: "已签收")
        }else if orderDict.stringValueForKey(key: "status") == "6"{
            initNavi(titleStr: "已退款")
        }else if orderDict.stringValueForKey(key: "status") == "7"{
            initNavi(titleStr: "已换货")
        }
        
        view.addSubview(tableView)
    }
    func updateNaviTitle() {
        if orderDict.stringValueForKey(key: "status") == "1"{
            self.naviTitleLabel.text = "待支付"
        }else if orderDict.stringValueForKey(key: "status") == "2"{
            self.naviTitleLabel.text = "已取消"
        }else if orderDict.stringValueForKey(key: "status") == "3"{
            self.naviTitleLabel.text = "待发货"
        }else if orderDict.stringValueForKey(key: "status") == "4"{
            self.naviTitleLabel.text = "运输中"
        }else if orderDict.stringValueForKey(key: "status") == "5"{
            self.naviTitleLabel.text = "已签收"
        }else if orderDict.stringValueForKey(key: "status") == "6"{
            self.naviTitleLabel.text = "已退款"
        }else if orderDict.stringValueForKey(key: "status") == "7"{
            self.naviTitleLabel.text = "已换货"
        }
        
        if afterSaleDict.stringValueForKey(key: "reason").count > 0{
            if afterSaleDict.stringValueForKey(key: "status") == "1"{
                naviTitleLabel.text = "售后服务中"
            }else if afterSaleDict.stringValueForKey(key: "status") == "3"{
                //naviTitleLabel.text = "已换货"//statusLabel.text = "不符合退/换货"
            }else{
//                naviTitleLabel.text = "已换货"//statusLabel.text = "换货完成"
            }
        }
    }
    func dealDataSource() {
        dataArray.removeAll()
        if self.orderDict.stringValueForKey(key: "status") == "1"{
            updatePayTimeCountDown(time: self.orderDict.stringValueForKey(key: "timeExpire"))
            view.addSubview(bottomVm)
            tableView.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-(self.getNavigationBarHeight()+kFitWidth(1)+self.bottomVm.selfHeight))
        }else{
            self.bottomVm.removeFromSuperview()
            tableView.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-(self.getNavigationBarHeight()+kFitWidth(1)))
            self.updateNaviTitle()
        }
        if self.orderDict.stringValueForKey(key: "id").count > 0 {
            dataArray.append(cell_model().initModel(title: "订单编号", detail: orderDict.stringValueForKey(key: "id")))
        }
        if self.orderDict.stringValueForKey(key: "address").count > 0 {
            dataArray.append(cell_model().initModel(title: "收件信息", detail: "\(orderDict.stringValueForKey(key: "address"))"))
        }
        if self.orderDict.stringValueForKey(key: "recipient").count > 0 && self.orderDict.stringValueForKey(key: "phone").count > 0 {
            dataArray.append(cell_model().initModel(title: "收件人信息", detail: "\(orderDict.stringValueForKey(key: "recipient"))    \(self.orderDict.stringValueForKey(key: "phone"))"))
        }
        if self.orderDict.stringValueForKey(key: "ctime").count > 0 {
            dataArray.append(cell_model().initModel(title: "下单时间", detail: orderDict.stringValueForKey(key: "ctime")))
        }
        if self.orderDict.stringValueForKey(key: "expectedExpressStartTime").count > 0 {
            dataArray.append(cell_model().initModel(title: "发货时间", detail: orderDict.stringValueForKey(key: "expectedExpressStartTime")))
        }
        if self.orderDict.stringValueForKey(key: "payTime").count > 0 {
            dataArray.append(cell_model().initModel(title: "支付时间", detail: orderDict.stringValueForKey(key: "payTime")))
        }
        if self.orderDict.stringValueForKey(key: "payChannel").count > 0 && self.orderDict.stringValueForKey(key: "status").intValue > 2{
            dataArray.append(cell_model().initModel(title: "付款方式", detail: orderDict.stringValueForKey(key: "payChannel")))
        }
        if self.orderDict.stringValueForKey(key: "totalAmount").count > 0 {
            dataArray.append(cell_model().initModel(title: "商品总价", detail: "¥\(orderDict.stringValueForKey(key: "totalAmount"))"))
        }
        if self.orderDict.stringValueForKey(key: "shippingFee").count > 0 {
            if self.orderDict.stringValueForKey(key: "freeShipping") == "1"{
                dataArray.append(cell_model().initModel(title: "运费", detail: "包邮"))
            }else{
                dataArray.append(cell_model().initModel(title: "运费", detail: "¥\(orderDict.stringValueForKey(key: "shippingFee"))"))
            }
        }
        if self.orderDict.stringValueForKey(key: "discountAmount").floatValue > 0 {
            dataArray.append(cell_model().initModel(title: "优惠金额",
                                                    detail: "-¥\(orderDict.stringValueForKey(key: "discountAmount"))",
                                                    color: .THEME))
        }
        
        expressArray.removeAll()
        expressTracking = self.orderDict["expressTracking"]as? NSDictionary ?? [:]
        if let checked = self.expressTracking["checked"] as? NSArray,
           checked.count > 0{
            for i in 0..<checked.count{
                let dict = checked[i]as? NSDictionary ?? [:]
                let model = ExpressMsgModel()
                if i == 0{
                    model.title = "已签收"
                }
                model.time = dict.stringValueForKey(key: "ftime")
                model.msg = dict.stringValueForKey(key: "context")
                expressArray.append(model)
            }
        }
        if let inTransit = self.expressTracking["inTransit"] as? NSArray,
           inTransit.count > 0{
            for i in 0..<inTransit.count{
                let dict = inTransit[i]as? NSDictionary ?? [:]
                let model = ExpressMsgModel()
                if i == 0{
                    model.title = "运输中"
                }
                model.time = dict.stringValueForKey(key: "ftime")
                model.msg = dict.stringValueForKey(key: "context")
                expressArray.append(model)
            }
        }
        //揽件
        if let shipped = self.expressTracking["shipped"] as? NSArray,
           shipped.count > 0{
            for i in 0..<shipped.count{
                let dict = shipped[i]as? NSDictionary ?? [:]
                let model = ExpressMsgModel()
                if i == 0{
                    model.title = "已发货"
                }
                model.time = dict.stringValueForKey(key: "ftime")
                model.msg = dict.stringValueForKey(key: "context")
                expressArray.append(model)
            }
        }
        let hadAfterSaleSection = hasAfterSaleSectionVisible
        self.afterSaleDict = self.orderDict["afterSale"]as? NSDictionary ?? [:]
        let hasAfterSaleSection = self.afterSaleDict.stringValueForKey(key: "reason").count > 0
        hasAfterSaleSectionVisible = hasAfterSaleSection
        self.tableView.reloadData()
        if !hadAfterSaleSection && hasAfterSaleSection {
            DispatchQueue.main.async { [weak self] in
                self?.animateAfterSaleCellAppearance()
            }
        }
    }
    
    private func toggleFoldState() {
        let newStatus = !isFold
        isFold = newStatus
        cellNumber = newStatus ? 2 : 2 + dataArray.count

        guard !dataArray.isEmpty else {
            updateBottomCellFoldStatus()
            return
        }

        let section = self.afterSaleDict.stringValueForKey(key: "reason").count > 0 ? 1 : 0
        let detailIndexPaths = (0..<dataArray.count).map { IndexPath(row: $0 + 1, section: section) }

        tableView.beginUpdates()
        if newStatus {
            tableView.deleteRows(at: detailIndexPaths, with: .fade)
        } else {
            tableView.insertRows(at: detailIndexPaths, with: .fade)
        }
        tableView.endUpdates()

        updateBottomCellFoldStatus()
    }

    private func updateBottomCellFoldStatus() {
        let bottomRow = isFold ? 1 : dataArray.count + 1
        let section = self.afterSaleDict.stringValueForKey(key: "reason").count > 0 ? 1 : 0
        let bottomIndexPath = IndexPath(row: bottomRow, section: section)

//        UIView.animate(withDuration: 0.15) {
            if let bottomCell = self.tableView.cellForRow(at: bottomIndexPath) as? MallPaySuccessBottomCell {
//                bottomCell.updateUI(money: orderDict.stringValueForKey(key: "payAmount"))
                bottomCell.setFoldStatus(isFold: self.isFold)
                bottomCell.updateStrait(hiddenDottedLine: self.cellNumber == 2)
            } else {
                self.tableView.reloadRows(at: [bottomIndexPath], with: .none)
            }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            self.tableView.reloadRows(at: [bottomIndexPath], with: .none)
        })
//        } completion: { _ in
//            self.tableView.reloadRows(at: [bottomIndexPath], with: .none)
//        }
    }
    private func animateAfterSaleCellAppearance() {
        guard hasAfterSaleSectionVisible else { return }

        let indexPath = IndexPath(row: 0, section: 0)
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows,
              visibleIndexPaths.contains(indexPath) else { return }

        tableView.layoutIfNeeded()

        guard let afterSaleCell = tableView.cellForRow(at: indexPath) else { return }

        let cellHeight = tableView.rectForRow(at: indexPath).height
        guard cellHeight > 0 else { return }

        let transform = CGAffineTransform(translationX: 0, y: -cellHeight)
        let otherCells = tableView.visibleCells.filter { $0 !== afterSaleCell }

        afterSaleCell.transform = transform
        for cell in otherCells {
            cell.transform = transform
        }

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
            afterSaleCell.transform = .identity
            for cell in otherCells {
                cell.transform = .identity
            }
        }, completion: { _ in
            afterSaleCell.transform = .identity
            for cell in otherCells {
                cell.transform = .identity
            }
        })
    }
    func updatePayTimeCountDown(time: String) {
        countdownTimer?.invalidate()
        countdownTimer = nil

        guard let timestamp = TimeInterval(time) else {
            bottomVm.payButton.setTitle("去支付 00:00", for: .normal)
            return
        }

        let serverDeadline = Date(timeIntervalSince1970: timestamp)
        let now = Date()
        remainingSeconds = Int(serverDeadline.timeIntervalSince(now))
        deadlineTime = serverDeadline

        if remainingSeconds <= 0 {
            bottomVm.payButton.setTitle("去支付 00:00", for: .normal)
            self.timeOutBlock?()
            self.sendOrderDetailRequest()
            return
        }

        bottomVm.payButton.isHidden = false
        updateCountdownLabel()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickCountdown()
        }
        RunLoop.main.add(countdownTimer!, forMode: .common)
    }
    

    private func tickCountdown() {
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            countdownTimer?.invalidate()
            bottomVm.payButton.setTitle("去支付 00:00", for: .normal)
            self.timeOutBlock?()
            self.sendOrderDetailRequest()
            return
        }
        updateCountdownLabel()
    }

    private func updateCountdownLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        let timeStr = String(format: "去支付 %02d:%02d", minutes, seconds)
        bottomVm.payButton.setTitle(timeStr, for: .normal)
    }
}

extension MallOrderDetailVC{
    func sendOrderDetailRequest() {
        let param = ["bizType":"2",
                     "id":self.orderDict.stringValueForKey(key: "id")]
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_order_detail, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendOrderDetailRequest:\(dataDict)")
            
            self.orderDict = dataDict
            self.dealDataSource()
        }
    }
}
