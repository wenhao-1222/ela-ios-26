//
//  MyAddressDetailVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//

import UIKit

class MyAddressDetailVC: WHBaseViewVC {

    var isUpdate = false

    // 选中的地址与详细地址缓存
    var addressModel = AddressModel()
    private var detailAddressText: String = ""
    var updateBlock:((AddressModel)->())?

    private enum RowType: CaseIterable {
        case name, phone, region, detail,isDefault
    }
    private let rows: [RowType] = [.name, .phone, .region, .detail,.isDefault]

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        if isUpdate{
            updateUI()
        }
    }

    lazy var tableView: UITableView = {
        let vi = UITableView(frame: CGRect(x: 0,
                                           y: self.getNavigationBarHeight()+kFitWidth(1),
                                           width: SCREEN_WIDHT,
                                           height: SCREEN_HEIGHT-(self.getNavigationBarHeight()+kFitWidth(1) + self.bottomVm.selfHeight)),
                             style: .plain)
        vi.separatorStyle = .none
        vi.bounces = false
        vi.delegate = self
        vi.dataSource = self
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .COLOR_BG_F2
        vi.contentInsetAdjustmentBehavior = .never
        vi.register(AddressDetailCell.classForCoder(), forCellReuseIdentifier: "AddressDetailCell")
        vi.register(AddressRegionCell.classForCoder(), forCellReuseIdentifier: "AddressRegionCell")
        vi.register(AddressDetailTextViewCell.classForCoder(), forCellReuseIdentifier: "AddressDetailTextViewCell")
        vi.register(AddressDefaultCell.classForCoder(), forCellReuseIdentifier: "AddressDefaultCell")
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }
        return vi
    }()

    lazy var bottomVm: AddressListBottomVM = {
        let vm = AddressListBottomVM(frame: .zero)
        vm.addButton.setTitle("保存", for: .normal)
        vm.addButton.isEnabled = false
        vm.addButton.addTarget(self, action: #selector(sendAddRequest), for: .touchUpInside)
        // 这里可设置“保存”点击回调，读取 addressModel & detailAddressText
        
        return vm
    }()
}

// MARK: - UITableView
extension MyAddressDetailVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch rows[indexPath.row] {
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressDetailCell") as? AddressDetailCell ?? AddressDetailCell()
            cell.updateUI(type: "name")
            cell.textField.text = addressModel.contactName
            cell.onTextChanged = { [weak self] text in
                self?.addressModel.contactName = text
                self?.updateAddButtonState()
            }
            return cell

        case .phone:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressDetailCell") as? AddressDetailCell ?? AddressDetailCell()
            cell.updateUI(type: "phone")
            cell.textField.text = addressModel.contactPhone
            cell.onTextChanged = { [weak self] text in
                self?.addressModel.contactPhone = text
                self?.updateAddButtonState()
            }
            return cell

        case .region:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressRegionCell") as? AddressRegionCell ?? AddressRegionCell()
            cell.update(with: addressModel)
            
            cell.onTapChoose = { [weak self] in
                guard let self = self else { return }
                // Dismiss keyboard when showing picker
                self.view.endEditing(true)
                
                let picker = AddressPickerView(defaultAddress: self.addressModel)
                picker.onConfirm = { [weak self] result in
                    guard let self = self else { return }
                    self.addressModel.provinceCode = result.provinceCode
                    self.addressModel.provinceName = result.provinceName
                    self.addressModel.cityCode = result.cityCode
                    self.addressModel.cityName = result.cityName
                    self.addressModel.areaCode = result.areaCode
                    self.addressModel.areaName = result.areaName
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    self.updateAddButtonState()
                }
                picker.onCancel = { }
                picker.show(in: self.view)
            }
            return cell

        case .detail:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressDetailTextViewCell") as? AddressDetailTextViewCell ?? AddressDetailTextViewCell()
//            cell.update(text: detailAddressText)
            cell.update(text: addressModel.detailAddressWhole)
            cell.onTextChanged = { [weak self] text in
                self?.detailAddressText = text
                self?.addressModel.detailAddress = text
                self?.updateAddButtonState()
            }
            return cell
        case .isDefault:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressDefaultCell") as? AddressDefaultCell ?? AddressDefaultCell()
            cell.update(isOn: addressModel.isDefault)
            cell.onSwitchChanged = { [weak self] isOn in
                self?.addressModel.isDefault = isOn
            }
            return cell
        
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch rows[indexPath.row] {
        case .name:  return kFitWidth(66)
        case .phone: return kFitWidth(51)
        case .region:
            // 多行内容自适应
            return kFitWidth(51)
//            return UITableView.automaticDimension
        case .detail:
            // 至少一行高度，最多三行高度由 cell 内部限制；这里给个弹性值
            return UITableView.automaticDimension
        case .isDefault:
            return kFitWidth(51)
        }
    }
}

// MARK: - 页面基础 UI
extension MyAddressDetailVC {
    func initUI() {
        if isUpdate { initNavi(titleStr: "修改地址") }
        else { initNavi(titleStr: "添加新地址") }
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(tableView)
        view.addSubview(bottomVm)
    }
    func updateUI() {
        detailAddressText = addressModel.detailAddress
        tableView.reloadData()
        updateAddButtonState()
    }
}
// MARK: - Helpers
extension MyAddressDetailVC {
    /// 根据输入内容更新按钮状态
    private func updateAddButtonState() {
        let hasName = !addressModel.contactName.isEmpty
        let phoneValid = judgePhoneNumber(phoneNum: addressModel.contactPhone)
        let hasRegion = !addressModel.provinceName.isEmpty 
//        let hasRegion = !addressModel.provinceCode.isEmpty &&
//                        !addressModel.cityCode.isEmpty &&
//                        !addressModel.areaCode.isEmpty
        let hasDetail = !addressModel.detailAddress.isEmpty
        bottomVm.addButton.isEnabled = hasName && phoneValid && hasRegion && hasDetail
    }
}

extension MyAddressDetailVC {
    @objc func sendAddRequest() {
        var param = ["recipient":self.addressModel.contactName,
                     "phone":self.addressModel.contactPhone,
                     "province":self.addressModel.provinceName,
                     "city":self.addressModel.cityName,
                     "county":self.addressModel.areaName,
                     "detail":self.addressModel.detailAddress,
                     "isDefault":"\(self.addressModel.isDefault ? 1 : 0)"]
        if self.isUpdate {
            param = ["recipient":self.addressModel.contactName,
                     "id":self.addressModel.id,
                     "phone":self.addressModel.contactPhone,
                     "province":self.addressModel.provinceName,
                     "city":self.addressModel.cityName,
                     "county":self.addressModel.areaName,
                     "detail":self.addressModel.detailAddress,
                     "isDefault":"\(self.addressModel.isDefault ? 1 : 0)"]
        }
        
        DLLog(message: "sendAddRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_user_address_addOrUpdate, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            if self.isUpdate{
                self.updateBlock?(self.addressModel)
            }
            self.backTapAction()
        }
    }
}
