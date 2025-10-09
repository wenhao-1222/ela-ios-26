//
//  QuestionnaireSurveyFoodsVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation
import UIKit

class QuestionnaireSurveyFoodsVM: UIView {
    
    var selfHeight = kFitWidth(48)
    var selectedIndex = -1
    
    var controller = WHBaseViewVC()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = WHColor_RGB(r: 38.0, g: 40.0, b: 49.0)
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.size.height
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var dataArray : NSMutableArray = {
        return [["name":"蛋白质","foods":"杏仁（生）\n夏威夷果\n","type":1],
                ["name":"脂肪","foods":"","type":3],
                ["name":"碳水","foods":"","type":2],
                ["name":"蔬菜","foods":"","type":4],
                ["name":"水果","foods":"","type":5]]
    }()
    lazy var titleVm : QuestionnaireSurveyTopVM = {
        let vm = QuestionnaireSurveyTopVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "选择食物"
        
        return vm
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "根据您的膳食习惯，在每个食物类别中选择2-7种食物，以满足您计划内的需求"
        lab.textColor = .white
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.titleVm.frame.maxY+kFitWidth(60), width: SCREEN_WIDHT, height: self.selfHeight - self.titleVm.frame.maxY - kFitWidth(60)), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(QuestionnaireSurveyFoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionnaireSurveyFoodsTableViewCell")
        
        return vi
    }()
    
}

extension QuestionnaireSurveyFoodsVM{
    func initUI(){
        addSubview(titleVm)
        addSubview(tipsLabel)
        addSubview(tableView)
        
        setConstrait()
    }
    func setConstrait(){
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(QuestionnaireSurveyTopVM().selfHeight+kFitWidth(18)))
        }
    }
}

extension QuestionnaireSurveyFoodsVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireSurveyFoodsTableViewCell", for: indexPath) as? QuestionnaireSurveyFoodsTableViewCell
        
        let dict = dataArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        
        cell?.choiceBlock = {()in
            let vc = QuestionnaireSurveyFoodsListVC()
            vc.fType = dict["type"]as? Int ?? 0
            vc.modalPresentationStyle = .fullScreen
            self.controller.present(vc, animated: true)
            vc.submitBlock = {(array)in
                self.updateUIForFoods(array: array, index: indexPath.row)
            }
//            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell ?? QuestionnaireSurveyFoodsTableViewCell()
    }
}

extension QuestionnaireSurveyFoodsVM{
    func updateUIForFoods(array:NSArray,index:Int) {
        var foodsString = ""
        if array.count == 0 {
            foodsString = ""
        }else{
            for i in 0..<array.count{
                let dict = array[i]as? NSDictionary ?? [:]
                foodsString = "\(foodsString)\n\(dict["fname"]as? String ?? "")"
            }
        }
        var dict = self.dataArray[index]as? NSDictionary ?? [:]
        
        let mDict = NSMutableDictionary(dictionary: dict)
        
        mDict.setValue(foodsString, forKey: "foods")
        self.dataArray.replaceObject(at: index, with: mDict)
        self.tableView.reloadData()
    }
}
