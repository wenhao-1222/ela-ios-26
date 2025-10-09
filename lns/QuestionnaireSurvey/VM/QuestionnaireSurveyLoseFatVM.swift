//
//  QuestionnaireSurveyLoseFatVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation
import UIKit

class QuestionnaireSurveyLoseFatVM: UIView {
    
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
        return [["name":"急速减脂","selected":"0","detail":"适合希望短时间内准备摄影写真集，参加活动，前任婚礼等的用户。反弹风险高，建议不超过4周。"],
                ["name":"中高强度减脂","selected":"0","detail":"适合希望达到短期身材目标，参加健美比赛的运动员/健身爱好者等。有一定反弹风险，建议时长：8-16周。"],
                ["name":"日常减脂","selected":"0","detail":"适合任何希望达到长期身材，健康目标人群。低反弹风险，建议时长：15-20周。"],
                ["name":"干净增肌","selected":"0","detail":"适合在希望保持低体脂肪/不增加体脂肪情况下进行增肌的运动员/健身爱好者等。建议时长：8-12周"],
                ["name":"增肌","selected":"0","detail":"适合希望在最短时间内增加最大维度（肌肉和少部分脂肪）的偏瘦人群。建议时长：8-12周"],
                ["name":"维持","selected":"0","detail":"适合希望在保持体型不变情况下增加身体线条的用户/减脂瓶颈期需要提高代谢的用户。建议时长：≥1周"],
                ["name":"提升力量","selected":"0","detail":"适合希望最大化提升力量的人群。建议时长：6-8周"],
                ["name":"提高运动表现","selected":"0","detail":"适合希望最大化提升功能性表现的篮球/足球/橄榄球/拳击运动员等。建议计划时长：8-16周"]]
    }()
    lazy var titleVm : QuestionnaireSurveyTopVM = {
        let vm = QuestionnaireSurveyTopVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "您的目标"
        
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

extension QuestionnaireSurveyLoseFatVM{
    func initUI(){
        addSubview(titleVm)
        addSubview(tableView)
        
    }
}

extension QuestionnaireSurveyLoseFatVM:UITableViewDelegate,UITableViewDataSource{
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
        return kFitWidth(98)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
}
