//
//  QuestionnaireSurveyEventVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation
import UIKit

class QuestionnaireSurveyEventVM: UIView {
    
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
        return [["name":"无活动","detail":"除少量走路通勤，无体育活动"],
                ["name":"低活跃水平","detail":"日常走路通勤，偶尔进行有氧/力量活动"],
                ["name":"中低活跃水平","detail":"每周2-3次力量/有氧训练，从事体力工作"],
                ["name":"中活跃水平","detail":"每周4-5次力量/有氧训练"],
                ["name":"高活跃水平","detail":"每周6-7次力量/有氧训练"],
                ["name":"极高活跃水平","detail":"每日2次力量/有氧训练"]]
    }()
    lazy var titleVm : QuestionnaireSurveyTopVM = {
        let vm = QuestionnaireSurveyTopVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "您的日常活动量"
        
        return vm
    }()
    
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.titleVm.frame.maxY, width: SCREEN_WIDHT, height: self.selfHeight - self.titleVm.frame.maxY), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(QuestionLoseFatTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionLoseFatTableViewCell")
        
        return vi
    }()
}

extension QuestionnaireSurveyEventVM{
    func initUI(){
        addSubview(titleVm)
        addSubview(tableView)
        
    }
}

extension QuestionnaireSurveyEventVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionLoseFatTableViewCell", for: indexPath) as? QuestionLoseFatTableViewCell
        
        let dict = dataArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict,isSelected: (self.selectedIndex == indexPath.row))
        
        return cell ?? QuestionLoseFatTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(78)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
}
