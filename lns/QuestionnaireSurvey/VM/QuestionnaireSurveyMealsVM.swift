//
//  QuestionnaireSurveyMealsVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation
import UIKit

class QuestionnaireSurveyMealsVM: UIView {
    
    var selfHeight = kFitWidth(48)
    var selectedIndex = -1
    
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
    lazy var dataArray : NSArray = {
        return [["name":"每日一餐","detail":"根据您的选择来为您制定特殊计划"],
                ["name":"每日二餐","detail":"根据您的选择来为您制定特殊计划"],
                ["name":"每日三餐","detail":"根据您的选择来为您制定特殊计划"],
                ["name":"每日四餐","detail":"根据您的选择来为您制定特殊计划"],
                ["name":"每日五餐","detail":"根据您的选择来为您制定特殊计划"],
                ["name":"每日六餐","detail":"根据您的选择来为您制定特殊计划"]]
    }()
    lazy var titleVm : QuestionnaireSurveyTopVM = {
        let vm = QuestionnaireSurveyTopVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "每日餐数"
        
        return vm
    }()
    
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.titleVm.frame.maxY, width: SCREEN_WIDHT, height: self.selfHeight - self.titleVm.frame.maxY), style: .plain)
        vi.delegate = self
        vi.dataSource = self
//        vi.rowHeight = uitableviewdim
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(QuestionDaylyMealsTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionDaylyMealsTableViewCell")
        
        return vi
    }()
}

extension QuestionnaireSurveyMealsVM{
    func initUI(){
        addSubview(titleVm)
        addSubview(tableView)
    }
}

extension QuestionnaireSurveyMealsVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionDaylyMealsTableViewCell", for: indexPath) as? QuestionDaylyMealsTableViewCell
        
        let dict = dataArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict, isSelected: (self.selectedIndex == indexPath.row))
        
        return cell ?? QuestionDaylyMealsTableViewCell()
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return kFitWidth(56)
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
}
