//
//  TutorialsListVC.swift
//  lns
//
//  Created by LNS2 on 2024/6/5.
//

import Foundation
//import ShowBigImg

class TutorialsListVC: WHBaseViewVC {
    
    var headVmArray:[TutorialTableHeaderView] = [TutorialTableHeaderView]()
    var dataSourceArray = TutorialAttr.shared.dataSourceArray
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        UserDefaults.standard.set("1", forKey: "widgetNewFuncRead")
        UserInfoModel.shared.widgetNewFuncRead = true
        
        let indexPath = IndexPath(row: 0, section: 9)
        let cell = self.tableView.cellForRow(at: indexPath)as? TutorialTableViewCell
        cell?.isPlaying = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initHeadView()
        initUI()
    }
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
    lazy var selectStatusArray: NSMutableArray = {
        return NSMutableArray(array: [["isFold":true],
                                      ["isFold":true],
                                      ["isFold":true],
                                      ["isFold":true],
                                      ["isFold":true],
                                      ["isFold":true],
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

extension TutorialsListVC{
    func showCatalogueTypeAlert(catalogueType:catalogue_type) {
        switch catalogueType {
        case .catalogue_7:
                alertVm.setDataArray(array: [TutorialAttr.shared.tutorial_array_7[0]])
        case .catalogue_13:
                alertVm.setDataArray(array: [TutorialAttr.shared.tutorial_array_1[3]])
        default:
            break
        }
    }
}

extension TutorialsListVC{
    func initUI() {
        initNavi(titleStr: "Elavatine 使用教程")
        
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        self.navigationView.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        
        view.addSubview(tableView)
        view.addSubview(alertVm)
    }
    func initHeadView()  {
        for i in 0..<dataSourceArray.count{
            let vm = TutorialTableHeaderView.init(frame: .zero)
            let dataDict = dataSourceArray[i]as? NSDictionary ?? [:]
            
            vm.udpateUI(titleStr: dataDict["title"]as? String ?? "", index: i)
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
}

extension TutorialsListVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = selectStatusArray[section]as! NSDictionary
        let dataDict = dataSourceArray[section]as? NSDictionary ?? [:]
        let dataArr = dataDict["dataArr"]as? NSArray ?? []
        return dict["isFold"]as? Bool ?? true == false ? dataArr.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorialTableViewCell")as? TutorialTableViewCell
        
        let dataDict = dataSourceArray[indexPath.section]as? NSDictionary ?? [:]
        let dataArr = dataDict["dataArr"]as? NSArray ?? []
//        let dict = TutorialAttr.shared.step_one_attr_array[indexPath.row]
        
        if indexPath.section == 9{
            cell?.isPlaying = true
            cell?.updateUIForAVPlayer(dict:dataArr[indexPath.row]as? NSDictionary ?? [:] )
        }else{
            cell?.updateUI(dict: dataArr[indexPath.row]as? NSDictionary ?? [:])
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
