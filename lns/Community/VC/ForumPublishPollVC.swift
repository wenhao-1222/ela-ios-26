//
//  ForumPublishPollVC.swift
//  lns
//
//  Created by Elavatine on 2024/12/12.
//

import MCToast

class ForumPublishPollVC: WHBaseViewVC {
    
    var pollHasImage = false//投票选项是否带图
    var pollIsMultiple = false//是否允许多选
    var choiceNum = 2//非多选时，为 1
    var pollDataArray:[ForumPollModel] = [ForumPollModel]()
    var pollTitle = ""
    
    var deletePollBlock:(()->())?
    var saveBlock:(([ForumPollModel])->())?
    
    var isUpdateData = false
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pollDataArray.count == 0 {
            pollDataArray.append(ForumPollModel())
            pollDataArray.append(ForumPollModel())
        }else{
//            let model = pollDataArray.first
//            self.pollHasImage = model?.hasPhoto ?? false ? true : false
            
            if self.pollHasImage{
                self.switchButton.setSelectStatus(status: true)
            }
        }
        initUI()
        self.numberHeadView.updateNumber(number: "\(choiceNum)")
        self.switchButtonMultiple.setSelectStatus(status: self.pollIsMultiple)
        
        if self.pollIsMultiple{
            let tableOriginY = self.numberHeadView.frame.maxY+kFitWidth(8)
            self.multipleChoiceAlertVm.selectNum = self.choiceNum
            self.multipleChoiceAlertVm.selectIndex = self.choiceNum - 2
            self.multipleChoiceAlertVm.initDataArray(num: self.pollDataArray.count)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                self.tableView.frame = CGRect.init(x: 0, y: tableOriginY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(48)-self.getBottomSafeAreaHeight()-kFitWidth(12)-tableOriginY)
            }
        }
        enableInteractivePopGesture()
        let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
        panGes.edges = .left
        view.addGestureRecognizer(panGes)
    }
    lazy var deleteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("删除投票", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_DISABLE_BG_THEME, for: .highlighted)
        
        btn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var leftLabel: UILabel = {
        let lab = UILabel()
        lab.text = "图文投票"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var switchButton: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-SwitchButton().selfWidth, y: getNavigationBarHeight()+kFitWidth(12), width: 0, height: 0))
        btn.tapBlock = {(isSelect)in
            self.isUpdateData = true
            self.switchButton.setSelectStatus(status: isSelect)
            self.pollHasImage = isSelect
            self.tableView.beginUpdates()
            self.updateHasImageStatus()
            self.tableView.endUpdates()
        }
        return btn
    }()
    lazy var multipleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "允许多选"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var switchButtonMultiple: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-SwitchButton().selfWidth, y: switchButton.frame.maxY + kFitWidth(16), width: 0, height: 0))
        btn.tapBlock = {(isSelect)in
            self.isUpdateData = true
            self.switchButtonMultiple.setSelectStatus(status: isSelect)
            self.pollIsMultiple = isSelect
//            self.tableView.beginUpdates()
//            self.tableView.endUpdates()
//            let nameFrame = self.nameVm.frame
            let nameOriginY = isSelect ? self.numberHeadView.frame.maxY + kFitWidth(8) : self.switchButtonMultiple.frame.maxY + kFitWidth(12)
            let tableOriginY = nameOriginY + self.nameVm.selfHeight
            
            UIView.animate(withDuration: 0.3, delay: 0,options:.curveLinear) {
                self.nameVm.frame = CGRect.init(x: 0, y: nameOriginY, width: SCREEN_WIDHT, height: self.nameVm.selfHeight)
                self.tableView.frame = CGRect.init(x: 0, y: tableOriginY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(48)-self.getBottomSafeAreaHeight()-kFitWidth(12)-tableOriginY)
            } completion: { t in
//                let tableOriginY = self.nameVm.frame.maxY//isSelect ? self.numberHeadView.frame.maxY+kFitWidth(8) : (self.switchButtonMultiple.frame.maxY+kFitWidth(12))
//                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {
//                    
//                }
            }
            if isSelect && self.pollDataArray.count < 3 {
                let num = 3 - self.pollDataArray.count
                for i in 0..<num{
                    self.pollDataArray.append(ForumPollModel())
                }
                
                self.tableView.reloadData()
            }
        }
        return btn
    }()
    lazy var nameVm: PublishPollTitleNameVM = {
        let vm = PublishPollTitleNameVM.init(frame: CGRect.init(x: 0, y: self.switchButtonMultiple.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.textField.text = self.pollTitle
        return vm
    }()
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: self.nameVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: (SCREEN_HEIGHT-kFitWidth(48)-getBottomSafeAreaHeight() - kFitWidth(12))-(self.nameVm.frame.maxY+kFitWidth(12))), style: .grouped)
        vi.delegate = self
        vi.dataSource = self
        vi.dragDelegate = self
        vi.dropDelegate = self
        vi.separatorStyle = .none
        vi.backgroundColor = .white
        vi.isEditing = true
        vi.dragInteractionEnabled = true
        vi.register(PublishPollItemCell.classForCoder(), forCellReuseIdentifier: "PublishPollItemCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        return vi
    }()
    lazy var numberHeadView: PublishPollHeadVM = {
        let vm = PublishPollHeadVM.init(frame: CGRect.init(x: 0, y: self.switchButtonMultiple.frame.maxY+kFitWidth(12), width: 0, height: 0))
//        vm.numberButton.addTarget(self, action: #selector(choiceMultipleAction), for: .touchUpInside)
        vm.tapBlock = {()in
            self.choiceMultipleAction()
        }
        
        return vm
    }()
    lazy var foodView: PublishPollFootVM = {
        let vm = PublishPollFootVM.init(frame: .zero)
        vm.tapBlock = {()in
            self.isUpdateData = true
            self.pollDataArray.append(ForumPollModel())
            self.tableView.insertRows(at: [IndexPath(row: self.pollDataArray.count-1, section: 0)], with: .fade)
            
            self.dealPollData()
            self.tableView.reloadData()
            self.multipleChoiceAlertVm.initDataArray(num: self.pollDataArray.count)
        }
        return vm
    }()
    lazy var multipleChoiceAlertVm: PublishPollMultipleAlertVM = {
        let vm = PublishPollMultipleAlertVM.init(frame: .zero)
        vm.numChoiceBlock = {(num)in
            self.isUpdateData = true
            self.choiceNum = num.intValue
            self.numberHeadView.updateNumber(number: num)
        }
        return vm
    }()
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: SCREEN_HEIGHT-kFitWidth(48)-getBottomSafeAreaHeight() - kFitWidth(12), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(48))
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
}

extension ForumPublishPollVC{
    func updateHasImageStatus() {
        for i in 0..<pollDataArray.count{
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? PublishPollItemCell
            cell?.updateUIForHasImage(hasImage: self.pollHasImage)
        }
    }
    func registCellIdentifier() {
        for i in 0..<pollDataArray.count{
            self.tableView.register(PublishPollItemCell.classForCoder(), forCellReuseIdentifier: "PublishPollItemCell\(i)")
        }
        self.tableView.reloadData()
    }
    func dealPollData() {
        for i in 0..<pollDataArray.count{
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? PublishPollItemCell
            if cell != nil{
                let model = pollDataArray[i]
                model.sn = "\(i+1)"
                model.title = cell?.pollTitleText.text ?? ""
                DLLog(message: "dealPollData:\(i) ----  \(cell?.pollTitleText.text ?? "")")
                pollDataArray[i] = model
            }
        }
    }
    @objc func choiceMultipleAction() {
        self.multipleChoiceAlertVm.showView()
    }
    func refreshMultiple() {
        if self.pollIsMultiple {
            if self.pollDataArray.count < 3 {
                self.switchButtonMultiple.setSelectStatus(status: false)
                self.pollIsMultiple = false
                self.multipleChoiceAlertVm.initDataArray(num: 3)
                let tableOriginY = self.switchButtonMultiple.frame.maxY+kFitWidth(12)
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                    self.tableView.frame = CGRect.init(x: 0, y: tableOriginY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(48)-self.getBottomSafeAreaHeight()-kFitWidth(12)-tableOriginY)
                }
            }
            
            if self.pollDataArray.count < self.multipleChoiceAlertVm.selectNum{
                self.multipleChoiceAlertVm.selectIndex = self.pollDataArray.count - 2
                self.multipleChoiceAlertVm.selectNum = self.pollDataArray.count
                self.multipleChoiceAlertVm.initDataArray(num: pollDataArray.count)
                self.numberHeadView.updateNumber(number: "\(self.pollDataArray.count)")
                self.choiceNum = self.pollDataArray.count
            }
        }
    }
    func checkRepeatPollItem() -> Bool {
        for i in 0..<pollDataArray.count{
            let model = pollDataArray[i]
            
            for j in i..<pollDataArray.count{
                let modelS = pollDataArray[j]
                if model != modelS && model.title.trimmingCharacters(in: .whitespacesAndNewlines) == modelS.title.trimmingCharacters(in: .whitespacesAndNewlines){
                    MCToast.mc_text("选项\(i+1) 与 选项\(j+1)标题重复",offset: kFitWidth(200),respond: .allow)
                    return true
                }
            }
        }
        
        return false
    }
    @objc func saveAction() {
        if pollDataArray.count < 2{
            MCToast.mc_text("投票选项请至少编辑两项",offset: kFitWidth(200),respond: .allow)
            return
        }
        for i in 0..<pollDataArray.count{
            let model = pollDataArray[i]
            if model.title.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
                MCToast.mc_text("选项\(i+1) 标题不能为空",offset: kFitWidth(200),respond: .allow)
                return
            }
            if self.pollHasImage && model.hasPhoto == false{
                MCToast.mc_text("选项\(i+1) 图片不能为空",offset: kFitWidth(200),respond: .allow)
                return
            }
        }
        if checkRepeatPollItem(){
            return
        }
        self.pollTitle = self.nameVm.textField.text ?? ""
        if self.saveBlock != nil{
            self.saveBlock!(self.pollDataArray)
        }
        self.backTapAction()
    }
    @objc func deleteAction() {
        self.presentAlertVc(confirmBtn: "删除", message: "是否删除所有的投票选项？", title: "温馨提示", cancelBtn: "取消", handler: { action in
            if self.deletePollBlock != nil{
                self.deletePollBlock!()
            }
            self.backTapAction()
        }, viewController: self)
    }
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended:
            selfBackAction()
            break
        default:
            break
        }
    }
    @objc func selfBackAction(){
        if isUpdateData {
            self.presentAlertVc(confirmBtn: "退出", message: "", title: "当前修改未保存，是否退出？", cancelBtn: "否，不退出", handler: { action in
                self.backTapAction()
            }, viewController: self)
        }else{
            self.backTapAction()
        }
    }
}

extension ForumPublishPollVC{
    func initUI() {
        initNavi(titleStr: "投票组件")
        navigationView.addSubview(deleteButton)
        self.backArrowButton.tapBlock = {()in
            self.selfBackAction()
        }
        
        view.isUserInteractionEnabled = true
        view.addSubview(leftLabel)
        view.addSubview(switchButton)
        view.addSubview(multipleLabel)
        view.addSubview(switchButtonMultiple)
        view.addSubview(numberHeadView)
        view.addSubview(nameVm)
        view.addSubview(tableView)
        
        view.addSubview(saveButton)
        
//        registCellIdentifier()
        setConstarit()
        
        view.addSubview(multipleChoiceAlertVm)
    }
    func setConstarit() {
        deleteButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(44))
            make.centerY.lessThanOrEqualTo(naviTitleLabel)
        }
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualTo(switchButton)
        }
        multipleLabel.snp.makeConstraints { make in
            make.left.equalTo(leftLabel)
            make.centerY.lessThanOrEqualTo(switchButtonMultiple)
        }
    }
}

extension ForumPublishPollVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublishPollItemCell") as? PublishPollItemCell
        
        let model = pollDataArray[indexPath.row]
        cell?.updateUI(model: model, index: indexPath.row, hasImage: self.pollHasImage)
        cell?.updateUIForHasImage(hasImage: self.pollHasImage)
        
        cell?.imgTapBlock = {()in
            //开始选择照片，最多允许选择9张
            UserConfigModel.shared.selectType = .IMAGE
            UserConfigModel.shared.photsSelectCount = 1
            _ = self.presentHGImagePicker(maxSelected:1) { (assets) in
                //结果处理
                print("共选择了\(assets.count)张图片，分别如下：")
                self.isUpdateData = true
                for asset in assets {
                    DLLog(message: "\(asset)")
                    model.photoAsset = asset
                    model.hasPhoto = true
                }
                cell?.updatePhoto(model: model)
                self.pollDataArray[indexPath.row] = model
            }
        }
        cell?.imgCompleteBlock = {(img)in
            model.image = img
            self.pollDataArray[indexPath.row] = model
        }
        cell?.textChangedBlock = {(text)in
            model.title = text
            self.isUpdateData = true
            self.pollDataArray[indexPath.row] = model
        }
        
        return cell ?? PublishPollItemCell()
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            self.isUpdateData = true
            self.pollDataArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.dealPollData()
            self.tableView.reloadData()
            self.multipleChoiceAlertVm.initDataArray(num: self.pollDataArray.count)
            self.refreshMultiple()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.pollHasImage{
            return kFitWidth(88)
        }else{
            return kFitWidth(56)
        }
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if pollIsMultiple{
//            return numberHeadView
//        }else{
//            return nil
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if pollIsMultiple{
//            return numberHeadView.selfHeight
//        }else{
//            return 0
//        }
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if pollDataArray.count < 20 {
            return foodView
        }else{
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if pollDataArray.count < 20{
            return foodView.selfHeight
        }else{
            return 0
        }
    }
}
//MARK: - UITableView ios11以上拖拽drag,dropDelegate
extension ForumPublishPollVC:UITableViewDragDelegate,UITableViewDropDelegate{
    /***
     *  iOS11以上版本,实现UITableViewDragDelegate,UITableViewDropDelegate代理方法,使用原生方式实现拖拽功能.
     */
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = UIDragItem(itemProvider: NSItemProvider(object: UIImage()))
        return [item]
    }
    // MARK: UITableViewDropDelegate
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {

    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        // Only receive image data
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    /// 这是UITableViewDataSourceDelegate中的方法,但是只有iOS11以上版本拖拽中才用的到,方便查看放在这里.
    /// 当拖拽完成时调用.将tableView数据源更新
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        objc_sync_enter(self)
        let model = pollDataArray[sourceIndexPath.row]
        self.isUpdateData = true
        
        self.pollDataArray.remove(at: sourceIndexPath.row)
        if destinationIndexPath.row > self.pollDataArray.count{
            self.pollDataArray.append(model)
        }else{
            self.pollDataArray.insert(model, at: destinationIndexPath.row)
        }
        objc_sync_exit(self)
        tableView.reloadData()
    }
}
