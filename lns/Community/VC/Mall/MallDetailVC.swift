//
//  MallDetailVC.swift
//  lns
//  商品详情页
//  Created by Elavatine on 2025/9/8.
//

import MCToast

enum CELL_TYPE {
    case text
    case spec
}

enum SPEC_TYPE{
    case popup
    case tap
}

class MallCellModel: NSObject {
    var cell_type = CELL_TYPE.text
    var cell_text = ""
    var cell_top_gap = kFitWidth(15)
    var cell_bottom_gap = kFitWidth(0)
    var cell_font = UIFont.systemFont(ofSize: 11, weight: .regular)
    var cell_color = UIColor.COLOR_TEXT_TITLE_0f1214
    var cell_spec_type = SPEC_TYPE.tap
    
    func initModel(type:CELL_TYPE,
                   cellType:SPEC_TYPE,
                   topGap:CGFloat,
                   text:String,
                   textColor:UIColor,
                   font:UIFont,
                   bottomGap:CGFloat = kFitWidth(0)) -> MallCellModel{
        let model = MallCellModel()
        model.cell_type = type
        model.cell_text = text
        model.cell_font = font
        model.cell_top_gap = topGap
        model.cell_bottom_gap = bottomGap
        model.cell_color = textColor
        model.cell_spec_type = cellType
        
        return model
    }
}

class MallDetailVC: WHBaseViewVC {
    
    var listModel = MarketListModel()
    
    var detailModel = MallDetailModel()
//    var detailImgVMList:[HeroBrowserViewModule] = []
    
    var textCellModels:[MallCellModel] = [MallCellModel]()
    
    private var bannerImagesCache: [String] = []
    private var detailImagesCache: [String] = []
    private var textCellCountCache: Int = 0
    
// 模拟后台返回的若干“图片”（这里用颜色代替）
    private var options: [SpecImageOption] = []
    private var mainSpecSelectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        DLLog(message: "\(listModel.id) -- \(listModel.name)  --\(listModel.descript)")
        sendDefaultSKURequest()
//        checkChinaExitByIP()
        
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                            scenarioType: .mall_detail,
                                            text: "\(self.listModel.id)")
    }
    lazy var naviVm: MalDetailNaviView = {
        let vm = MalDetailNaviView.init(frame: .zero)
        vm.backBlock = {()in
            self.backTapAction()
        }
        vm.shareBlock = {()in
            DLLog(message: "分享按钮点击")
        }
        
        return vm
    }()
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT), style: .plain)
        vi.separatorStyle = .none
        vi.delegate = self
        vi.dataSource = self
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.register(MallDetailTextCell.self, forCellReuseIdentifier: "MallDetailTextCell")
        vi.register(MallDetailImageCell.self, forCellReuseIdentifier: "MallDetailImageCell")
        vi.register(MallDetailSpecChangeCell.self, forCellReuseIdentifier: "MallDetailSpecChangeCell")
        vi.register(MallDetailSpecMainCell.self, forCellReuseIdentifier: "MallDetailSpecMainCell")
        vi.contentInsetAdjustmentBehavior = .never
        vi.tableHeaderView = self.bannerImgVm
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }

        return vi
    }()
    lazy var bannerImgVm: MallDetailBannerVM = {
        let vm = MallDetailBannerVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: WHUtils().getTopSafeAreaHeight() + kFitWidth(456)))
//        vm.isAutoPlayEnabled = true
        
        vm.tapBlock = {(imgIndex)in
            self.hero.browserPhoto(viewModules: self.bannerImgVm.list, initIndex: imgIndex) {
               [
                   .pageControlType(.pageControl),
                   .heroView(self.bannerImgVm.imgList[imgIndex]),
                   .heroBrowserDidLongPressHandle({ [weak self] heroBrowser,vm  in
//                       self?.longPressHandle(vm: vm)
                   }),
                   .imageDidChangeHandle({ [weak self] imageIndex in
                       guard let self = self else { return nil }
                       self.bannerImgVm.scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT*CGFloat(imageIndex), y: 0), animated: false)
                       return self.bannerImgVm.imgList[imageIndex]
                   })
               ]
           }
        }
        return vm
    }()
    lazy var bottomFuncVm: MallDetailBottomFuncVM = {
        let vm = MallDetailBottomFuncVM.init(frame: .zero)
        vm.buyButton.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
        vm.serviceBlock = {() in
            let vc = ServiceContactMarketVC()
            vc.bizType = "1"
            vc.detailModel = self.detailModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var specAlertVm: MallSpecAlertVM = {
        let vm = MallSpecAlertVM.init(frame: .zero)
        vm.selectSpecBlock = { [weak self] specId, specValueId,specValue in
            guard let self = self else { return }
            if let index = self.detailModel.selectedSpecList.firstIndex(where: { $0["specId"] == specId }) {
                self.detailModel.selectedSpecList[index] = ["specId": specId,
                                                            "specValueId": specValueId,
                                                            "specValueName":specValue]
            } else {
                self.detailModel.selectedSpecList.append(["specId": specId,
                                                          "specValueId": specValueId,
                                                          "specValueName":specValue])
            }
            if specValueId.isEmpty {
                if let index = self.detailModel.selectedSpecList.firstIndex(where: { $0["specId"] == specId }) {
                    self.detailModel.selectedSpecList.remove(at: index)
                }
            } else {
                if let index = self.detailModel.selectedSpecList.firstIndex(where: { $0["specId"] == specId }) {
                    self.detailModel.selectedSpecList[index] = ["specId": specId,
                                                                "specValueId": specValueId,
                                                                "specValueName": specValue]
                } else {
                    self.detailModel.selectedSpecList.append(["specId": specId,
                                                              "specValueId": specValueId,
                                                              "specValueName": specValue])
                }
            }
            if self.detailModel.selectedSpecList.count > 0 {
                self.sendSelectSKURequest()
            }else{
                self.sendDefaultSKURequest()
            }
        }
        vm.bottomVm.buyButton.addTarget(self, action: #selector(comfirmBuyAction), for: .touchUpInside)
        return vm
    }()
}

//MARK: 点击事件
extension MallDetailVC{
    @objc func buyAction() {
        switch self.detailModel.buyButtonStatus{
        case .sale_pre:
            DLLog(message: "预售提醒")
            self.specAlertVm.showSelf()
        case .sale_pre_no_stoke:
            DLLog(message: "预售--无库存")
        case .sale_remind:
            DLLog(message: "开售提醒")
            self.sendSubsribeRequest(bizType: "2")
        case .sale_remind_subscribe:
            DLLog(message: "开售提醒--已订阅通知")
            self.sendSubsribeCancelRequest(bizType: "2")
        case .sale_normal:
            self.specAlertVm.showSelf()
        case .sale_no_stoke:
            DLLog(message: "商品--无库存")
            self.sendSubsribeRequest(bizType: "1")
        case .sale_no_stoke_subscribe:
            DLLog(message: "商品--已订阅到货通知")
            self.sendSubsribeCancelRequest(bizType: "1")
        }
    }
    
    @objc func comfirmBuyAction() {
        let totalSpecs = self.specAlertVm.groups.count
        let selectedSpecs = self.specAlertVm.selectedPairs.count
        if totalSpecs > 0 && selectedSpecs < totalSpecs {
            MCToast.mc_text("请先选择所有规格")
            return
        }
        DLLog(message: "---------------  已选择规格  --------------------------")
        for i in 0..<self.specAlertVm.selectedPairs.count{
            let item = self.specAlertVm.selectedPairs[i]
            DLLog(message: "\(item.groupId) -- \(item.itemId)  -- \(item.itemName)")
        }
        DLLog(message: "-----------------------------------------------------")
        
        self.specAlertVm.hiddenSelf()
        let vc = MallOrderCreateVC()
        vc.listModel = self.listModel
        vc.detailModel = self.detailModel
        vc.number = self.specAlertVm.bottomVm.number
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: 判断是否为大陆
extension MallDetailVC{
    private func checkChinaExitByIP() {
        if #available(iOS 15.0, *) {
            Task { [weak self] in
                let result = await CNIPGate.isChinaMainlandByPublicIP()
                await MainActor.run {
                    self?.handleCNIPResult(result)
                }
            }
        } else {
            CNIPGate.isChinaMainlandByPublicIP { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleCNIPResult(result)
                }
            }
        }
    }
    /// 根据结果更新 UI / 继续业务逻辑
    @MainActor
    private func handleCNIPResult(_ result: Bool?) {
        switch result {
        case .some(true):
            print("中国大陆出口（CN）✅")
            // TODO: 更新你的 UI / 走中国大陆逻辑
        case .some(false):
            print("非中国大陆出口 ❌")
            // TODO: 更新你的 UI / 非大陆逻辑
        case .none:
            print("无法判断（网络不可达/被拦截）⚠️")
            // TODO: 做降级处理
        }
    }
}

extension MallDetailVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var warrantyPolicyNoticeNum = self.detailModel.warrantyPolicyNotice.count > 0 ? 1 : 0
//        if self.detailModel.mainSpecModel.isMainSpec{
            return self.textCellModels.count + self.detailModel.image_arr_detail.count// + warrantyPolicyNoticeNum
//        }else{
//            return 4 + self.detailModel.image_arr_detail.count + warrantyPolicyNoticeNum
//        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < textCellModels.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallDetailTextCell") as? MallDetailTextCell
            let model = textCellModels[indexPath.row]
            if model.cell_type == .text{
                cell?.updateText(text: model.cell_text,
                                 textColor: model.cell_color,
                                 textFont: model.cell_font,
                                 topGap: model.cell_top_gap,
                                 bottomGap: model.cell_bottom_gap)
                
                return cell ?? MallDetailTextCell()
            }else{
                if model.cell_spec_type == .tap{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MallDetailSpecChangeCell", for: indexPath) as! MallDetailSpecChangeCell
                            
                    // 配置 cell，只保留“色块选择区域”
                    cell.configure(options: options, selectedIndex: mainSpecSelectedIndex) { [weak self] newIndex, option in
                        guard let self = self else { return }
                        self.mainSpecSelectedIndex = newIndex
                        // 这里你可以把选中项传回业务层（例如给 VC 的属性、发通知、或更新下方价格等）
                        print("选中：index=\(newIndex), id=\(option.id)")
                        if self.detailModel.mainSpecModel.specValueList.count > newIndex{
                            self.detailModel.mainSpecValueModel = self.detailModel.mainSpecModel.specValueList[newIndex]
                            self.sendSelectSKURequest()
                        }
                    }
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MallDetailSpecMainCell", for: indexPath) as! MallDetailSpecMainCell
                    cell.updateText(text: self.detailModel.mainSpecValueModel.specValue)
                    cell.tapBlock = {[weak self, weak cell] in
//                        DLLog(message: "切换主规格弹窗")
                        guard let self = self, let cell = cell else { return }
                        self.showMainSpecPopup(from: cell)
                    }
                    return cell
                }
            }
        }else{
            let imgCell = tableView.dequeueReusableCell(withIdentifier: "MallDetailImageCell")as? MallDetailImageCell
            let index = indexPath.row - self.textCellModels.count
            if self.detailModel.image_arr_detail.count > index{
                let imgUrl = self.detailModel.image_arr_detail[index]
                imgCell?.updateText(imgUrl: imgUrl)
            }
            return imgCell ?? MallDetailImageCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.getBottomSafeAreaHeight() + kFitWidth(60)))
        vi.backgroundColor = .clear
        
        return  vi
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.getBottomSafeAreaHeight() + kFitWidth(60)
    }
}
extension MallDetailVC{
    func initUI() {
        view.addSubview(naviVm)
//        view.addSubview(buyButton)
        view.addSubview(bottomFuncVm)
        view.insertSubview(tableView, belowSubview: naviVm)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(specAlertVm)
        tableView.layoutIfNeeded()
        view.layoutIfNeeded()
    }
    func updateUI() {
        if self.detailModel.image_order == ""{
            self.detailModel.image_order = self.listModel.imgUrlSmall
        }
        self.updateButtonStatus()
        self.specAlertVm.updateGoodsMsg(model: self.detailModel, imgUrl: self.detailModel.image_order)
//        self.bannerImgVm.updateUI(dataArray: self.detailModel.image_arr_banner as NSArray)
        if self.detailModel.image_arr_banner != bannerImagesCache {
            self.bannerImgVm.updateUI(dataArray: self.detailModel.image_arr_banner as NSArray)
            bannerImagesCache = self.detailModel.image_arr_banner
        }
        
        if self.detailModel.mainSpecModel.isMainSpec && self.detailModel.mainSpecModel.isUrl{
            self.options.removeAll()
            self.mainSpecSelectedIndex = self.detailModel.mainSpecValueIndex
            for spec in self.detailModel.mainSpecModel.specValueList{
                self.options.append(.init(id: spec.specValueId, imageURL: spec.specValueUrl, placeholderColor: .COLOR_TEXT_TITLE_0f1214_06))
            }
        }
        
        self.textCellModels.removeAll()
        textCellModels.append(MallCellModel().initModel(type: .text,
                                                        cellType: .popup,
                                                        topGap: kFitWidth(15),
                                                        text: self.detailModel.skuName,
                                                        textColor: .COLOR_TEXT_TITLE_0f1214,
                                                        font: .systemFont(ofSize: 18, weight: .medium)))
        textCellModels.append(MallCellModel().initModel(type: .text,
                                                        cellType: .popup,
                                                        topGap: kFitWidth(2),
                                                        text: self.detailModel.subtitle,
                                                        textColor: .COLOR_TEXT_TITLE_0f1214_50,
                                                        font: .systemFont(ofSize: 13, weight: .regular)))
        textCellModels.append(MallCellModel().initModel(type: .text,
                                                        cellType: .popup,
                                                        topGap: kFitWidth(2),
                                                        text: "¥\(self.detailModel.price_sale)",
                                                        textColor: .COLOR_TEXT_TITLE_0f1214,
                                                        font: .systemFont(ofSize: 18, weight: .regular)))
        if self.detailModel.warrantyPolicyNotice.count > 0 {
            textCellModels.append(MallCellModel().initModel(type: .text,
                                                            cellType: .popup,
                                                            topGap: kFitWidth(2),
                                                            text: self.detailModel.warrantyPolicyNotice,
                                                            textColor: .THEME,
                                                            font: .systemFont(ofSize: 11, weight: .regular)))
        }
        if self.detailModel.mainSpecModel.isMainSpec{
            if self.detailModel.mainSpecModel.needPopUp{
                textCellModels.append(MallCellModel().initModel(type: .spec,
                                                                cellType: .popup,
                                                                topGap: kFitWidth(2),
                                                                text: "",
                                                                textColor: .THEME,
                                                                font: .systemFont(ofSize: 11, weight: .regular)))
            }else{
                textCellModels.append(MallCellModel().initModel(type: .spec,
                                                                cellType: .tap,
                                                                topGap: kFitWidth(2),
                                                                text: "",
                                                                textColor: .THEME,
                                                                font: .systemFont(ofSize: 11, weight: .regular)))
            }
        }
        if self.detailModel.deliveryNotice.count > 0 {
            textCellModels.append(MallCellModel().initModel(type: .text,
                                                            cellType: .popup,
                                                            topGap: kFitWidth(6),
                                                            text: self.detailModel.deliveryNotice,
                                                            textColor: .COLOR_TEXT_TITLE_0f1214_50,
                                                            font: .systemFont(ofSize: 11, weight: .regular),
                                                            bottomGap: kFitWidth(15)))
        }
        
//        self.tableView.reloadData()
        let detailChanged = self.detailModel.image_arr_detail != detailImagesCache
        let textCountChanged = self.textCellModels.count != textCellCountCache
        if detailChanged || textCountChanged {
            detailImagesCache = self.detailModel.image_arr_detail
            textCellCountCache = self.textCellModels.count
            self.tableView.reloadData()
        } else {
            let indexPaths = (0..<self.textCellModels.count).map { IndexPath(row: $0, section: 0) }
            if !indexPaths.isEmpty {
                self.tableView.reloadRows(at: indexPaths, with: .none)
            }
        }
    }
    
    func updateButtonStatus() {
        self.bottomFuncVm.detailModel = self.detailModel
        self.bottomFuncVm.updateButtonStatus()
//        buyButton.setTitle(self.detailModel.buyButtonText, for: .normal)
//        buyButton.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        switch self.detailModel.buyButtonStatus{
//        case .sale_pre_no_stoke :
//            buyButton.isEnabled = false
//        case .sale_pre:
//            let attr = NSMutableAttributedString(string: detailModel.buyButtonText)
//            let timeAttr = NSMutableAttributedString(string: "\n \(detailModel.deliveryNotice)")
//            attr.yy_font = .systemFont(ofSize: 16, weight: .regular)
//            timeAttr.yy_font = .systemFont(ofSize: 12, weight: .regular)
//            attr.append(timeAttr)
//            buyButton.setAttributedTitle(attr, for: .normal)
////            buyButton.titleLabel?.attributedText = attr
////            buyButton.setTitle("\(detailModel.buyButtonText) \n \(detailModel.deliveryNotice)", for: .normal)
//        case .sale_remind, .sale_normal,.sale_no_stoke:
//            break
//        case .sale_no_stoke_subscribe,.sale_remind_subscribe:
//            buyButton.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_C4C4C4), for: .normal)
//        }
//        UIView.animate(withDuration: 0.15, animations: {
//            self.buyButton.alpha = 1
//        })
    }
}

extension MallDetailVC{
    func sendDefaultSKURequest() {
        let param = ["spuId":self.listModel.id]
        WHNetworkUtil.shareManager().POST(urlString: URL_mall_sku_default, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDefaultSKURequest:\(dataObj)")
            
            self.detailModel = MallDetailModel().dealModelWithDict(dict: dataObj)
            self.updateUI()
        }
    }
    func sendSelectSKURequest() {
        let param: [String: AnyObject] = [
                    "spuId": self.listModel.id as AnyObject,
                    "specList": self.detailModel.selectedSpecList as AnyObject
                ]
        DLLog(message: "sendSelectSKURequest 参数:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_mall_sku_select, parameters: param,isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendSelectSKURequest:\(dataObj)")
            
            self.detailModel = MallDetailModel().dealModelWithDict(dict: dataObj)
            self.updateUI()
        }
    }
    func sendSubsribeRequest(bizType:String) {
        let param = ["id": self.detailModel.id,
                    "bizType": bizType]
        DLLog(message: "sendSelectSKURequest 参数:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_mall_sku_subscribe, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendSubsribeRequest:\(dataObj)")
            
            if bizType == "1"{
                self.detailModel.buyButtonStatus = .sale_no_stoke_subscribe
                self.detailModel.buyButtonText = "已设置到货通知"
            }else if bizType == "2"{
                self.detailModel.buyButtonStatus = .sale_remind_subscribe
                self.detailModel.buyButtonText = "已设置开售提醒"
            }
            self.updateButtonStatus()
        }
    }
    func sendSubsribeCancelRequest(bizType:String) {
        let param = ["id": self.detailModel.id,
                    "bizType": bizType]
        DLLog(message: "sendSubsribeCancelRequest 参数:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_mall_sku_subscribe_cancel, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendSubsribeRequest:\(dataObj)")
            if bizType == "1"{
                self.detailModel.buyButtonStatus = .sale_no_stoke
                self.detailModel.buyButtonText = "到货提醒"
            }else if bizType == "2"{
                self.detailModel.buyButtonStatus = .sale_remind
                self.detailModel.buyButtonText = "开售提醒"
            }
            self.updateButtonStatus()
        }
    }
    
}
// 在 MallDetailVC 里
extension MallDetailVC {
    private func showMainSpecPopup(from cell: MallDetailSpecMainCell) {
        var mainOption : [SpecOption] = [SpecOption]()
        for i in 0..<self.detailModel.mainSpecModel.specValueList.count{
            let mainSpecModel = self.detailModel.mainSpecModel.specValueList[i]
            let option = SpecOption.init(id: mainSpecModel.specValueId,
                                         title: mainSpecModel.specValue,
                                         inStock: mainSpecModel.specHasStock)
            mainOption.append(option)
        }
        let popup = SpecAnchorPopup(options: mainOption) { [weak self] index, opt in
            guard let self = self else { return }
            // 选中后的业务逻辑（更新主规格、刷新 SKU 等）
            DLLog(message: "选择规格: \(opt.title) (id=\(opt.id))")
            // 例如：找到该选项在 mainSpecModel 中对应的 index 后发请求
            if let i = self.detailModel.mainSpecModel.specValueList.firstIndex(where: { $0.specValueId == opt.id }) {
                self.detailModel.mainSpecValueModel = self.detailModel.mainSpecModel.specValueList[i]
                self.detailModel.mainSpecValueIndex = i
                self.mainSpecSelectedIndex = i
                if let idx = self.detailModel.selectedSpecList.firstIndex(where: { $0["specId"] == self.detailModel.mainSpecModel.specId }) {
                    self.detailModel.selectedSpecList[idx] = ["specId": self.detailModel.mainSpecModel.specId,
                                                              "specValueId": opt.id,
                                                              "specValueName":opt.title]
                } else {
                    self.detailModel.selectedSpecList.append(["specId": self.detailModel.mainSpecModel.specId,
                                                              "specValueId": opt.id,
                                                              "specValueName":opt.title])
                }
                self.sendSelectSKURequest()
            }
        }

        // 把弹窗加到窗口或当前控制器 view 上都可以，这里用 keyWindow
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.getKeyWindow()

        // 指向 cell（也可以传 cell 内部的某个 label/button 作为锚点）
        popup.show(from: cell.contentView, in: container, follow: tableView)
    }
}
