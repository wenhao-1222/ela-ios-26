//
//  TutorialsVC.swift
//  lns
//
//  Created by LNS2 on 2024/6/4.
//

import Foundation
//import ShowBigImg
import UIKit

class TutorialsVC: WHBaseViewVC {
    
    var headVmArray:[TutorialTableHeaderView] = [TutorialTableHeaderView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initHeadView()
        initUI()
    }
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        return vi
    }()
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight()), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(TutorialTableViewCell.classForCoder(), forCellReuseIdentifier: "TutorialTableViewCell")
        vi.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        
        return vi
    }()
    lazy var titleArray: NSArray = {
        return ["获取饮食计划，执行计划",
                "获取营养目标，根据目标\n自行添加/修改食物",
                "自定义营养目标",
                "自定义计划，分享计划",
                "记录身体状态，维度数据"]
    }()
    lazy var selectStatusArray: NSMutableArray = {
        return NSMutableArray(array: [["isFold":true],
                                      ["isFold":true],
                                      ["isFold":true],
                                      ["isFold":true],
                                      ["isFold":true]])
    }()
    lazy var alertVm: TutorialsAlertVM = {
        let vm = TutorialsAlertVM.init(frame: .zero)
        vm.controller = self
        return vm
    }()
}

extension TutorialsVC{
    func initUI() {
        initNavi(titleStr: "Elavatine 使用教程")
        
        self.navigationView.addSubview(lineView)
        
        view.addSubview(tableView)
        setConstrait()
        
        view.addSubview(alertVm)
    }
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
    func initHeadView()  {
        for i in 0..<titleArray.count{
            let vm = TutorialTableHeaderView.init(frame: .zero)
            vm.udpateUI(titleStr: titleArray[i] as! String, index: i)
            headVmArray.append(vm)
            vm.tapBlock = {()in
                let dict = self.selectStatusArray[i]as! NSDictionary
                var isFold = dict["isFold"]as? Bool ?? true
                isFold = !isFold
                let dictTemp = ["isFold":isFold]
                
                self.selectStatusArray.replaceObject(at: i, with: dictTemp)
                self.tableView.reloadSections(NSIndexSet(index: i) as IndexSet, with: .fade)
            }
        }
    }
    func showCatalogueTypeAlert(catalogueType:catalogue_type) {
        switch catalogueType {
            case .catalogue_12:
                alertVm.setDataArray(array: [TutorialAttr.shared.step_one_attr_array[1]])
            case .catalogue_13:
                alertVm.setDataArray(array: [TutorialAttr.shared.step_one_attr_array[2],
                                             TutorialAttr.shared.step_one_attr_array[3]])
            case .catalogue_14:
                alertVm.setDataArray(array: [TutorialAttr.shared.step_one_attr_array[4],
                                         TutorialAttr.shared.step_one_attr_array[5],
                                             TutorialAttr.shared.step_one_attr_array[6],
                                             TutorialAttr.shared.step_one_attr_array[7]])
            case .catalogue_15:
                alertVm.setDataArray(array: [TutorialAttr.shared.step_one_attr_array[8]])
            case .catalogue_16:
                alertVm.setDataArray(array: [TutorialAttr.shared.step_one_attr_array[9]])
            case .catalogue_17:
                alertVm.setDataArray(array: [TutorialAttr.shared.step_one_attr_array[10]])
            case .catalogue_18:
                alertVm.setDataArray(array: [TutorialAttr.shared.step_one_attr_array[11]])
        case .catalogue_7:
                alertVm.setDataArray(array: [TutorialAttr.shared.step_one_attr_array[11]])
        }
    }
}

extension TutorialsVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = selectStatusArray[section]as! NSDictionary
        if section == 0 {
            return dict["isFold"]as? Bool ?? true == false ? TutorialAttr.shared.step_one_attr_array.count : 0
        }else if section == 1{
            return dict["isFold"]as? Bool ?? true == false ? TutorialAttr.shared.step_two_attr_array.count : 0
        }else if section == 2{
            return dict["isFold"]as? Bool ?? true == false ? TutorialAttr.shared.step_three_attr_array.count : 0
        }else if section == 3{
            return dict["isFold"]as? Bool ?? true == false ? TutorialAttr.shared.step_four_attr_array.count : 0
        }else{
            return dict["isFold"]as? Bool ?? true == false ? TutorialAttr.shared.step_five_attr_array.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorialTableViewCell")as? TutorialTableViewCell
        
        if indexPath.section == 0 {
            let dict = TutorialAttr.shared.step_one_attr_array[indexPath.row]
            cell?.updateUI(dict: dict as! NSDictionary)
        }else if indexPath.section == 1{
            let dict = TutorialAttr.shared.step_two_attr_array[indexPath.row]
            cell?.updateUI(dict: dict as! NSDictionary)
        }else if indexPath.section == 2{
            let dict = TutorialAttr.shared.step_three_attr_array[indexPath.row]
            cell?.updateUI(dict: dict as! NSDictionary)
        }else if indexPath.section == 3{
            let dict = TutorialAttr.shared.step_four_attr_array[indexPath.row]
            cell?.updateUI(dict: dict as! NSDictionary,isFourLayout: true)
        }else{
            let dict = TutorialAttr.shared.step_five_attr_array[indexPath.row]
            cell?.updateUI(dict: dict as! NSDictionary)
        }
        
        cell?.imgTapBlock = {(imgView)in
            let showController = ShowBigImgController(imgs: [imgView.image!], img: imgView.image!,isNavi: true)
//            showController.modalPresentationStyle = .overFullScreen
//            self.present(showController, animated: false, completion: nil)
            self.navigationController?.pushViewController(showController, animated: true)
        }
        cell?.buttonTapBlock = {(catalogueType)in
            self.showCatalogueTypeAlert(catalogueType: catalogueType)
        }
        
        return cell ?? TutorialTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headVmArray[section]
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let dict = selectStatusArray[section]as! NSDictionary
        
        let vm = headVmArray[section]
        vm.isFold = dict["isFold"]as? Bool ?? true == true ? true : false
        vm.updateFoldStatus()
        
        return vm.selfHeight
    }
    
}
