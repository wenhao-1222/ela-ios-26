//
//  QuestionnairePlanDailyFoodsSqtyVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/1.
//

import Foundation
import UIKit
import MCToast

class QuestionnairePlanDailyFoodsSqtyVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var selectedIndex = -1
    
    var selectedBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var dataArray : NSArray = {
        return [["name":"简易","detail":"每类食物单种"],
                ["name":"丰富","detail":"每类食物多种"]]
//        return [["name":"极简","detail":"每类食物 1 种"],
//                ["name":"简易","detail":"每类食物 2 种"],
//                ["name":"普通","detail":"每类食物 3 种"],
//                ["name":"丰富","detail":"每类食物 4~5 种"]]
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "选择单日食物种类"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "选择每日包含的蛋白质、碳水化合物、脂肪和\n蔬菜种类"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: kFitWidth(184), width: SCREEN_WIDHT, height: self.selfHeight-kFitWidth(184)-kFitWidth(84)-WHUtils().getBottomSafeAreaHeight()), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(QuestionnaireEventsTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionnaireEventsTableViewCell")
        
        return vi
    }()
    lazy var coverView : UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "bottom_cover_img")
        
        return vi
    }()
    lazy var coverTopView : UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "bottom_cover_img")
        vi.transform = CGAffineTransform(scaleX: -1, y: -1)
        vi.isHidden = true
        
        return vi
    }()
}

extension QuestionnairePlanDailyFoodsSqtyVM{
    func initUI(){
        addSubview(titleLabel)
        addSubview(tableView)
        addSubview(coverView)
        addSubview(coverTopView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
            make.height.equalTo(kFitWidth(72))
        }
        coverView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.top.equalTo(tableView.snp.bottom).offset(kFitWidth(-40))
        }
        coverTopView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.top.equalTo(self.tableView)
        }
    }
}

extension QuestionnairePlanDailyFoodsSqtyVM:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireEventsTableViewCell")as! QuestionnaireEventsTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireEventsTableViewCell", for: indexPath) as? QuestionnaireEventsTableViewCell
        
        let dict = dataArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict, isSelected: (selectedIndex == indexPath.row ? true : false))
        
        return cell ?? QuestionnaireEventsTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndex < 0 && self.selectedBlock != nil{
            self.selectedBlock!()
            
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.coverView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.tableView.frame.maxY-kFitWidth(20))
            }
        }
        self.selectedIndex = indexPath.row
        self.tableView.reloadData()
        
        QuestinonaireMsgModel.shared.dailyfoodsqty = "\(indexPath.row + 1)"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(92)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.coverTopView.isHidden = false
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 滑动已经结束且没有减速
            // 在这里进行相应的操作
            DLLog(message: "\(scrollView.contentOffset.y)")
            if scrollView.contentOffset.y > kFitWidth(40){
                self.coverTopView.isHidden = false
            }else{
                self.coverTopView.isHidden = true
            }
        }
    }
     
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DLLog(message: "\(scrollView.contentOffset.y)")
        if scrollView.contentOffset.y > kFitWidth(40){
            self.coverTopView.isHidden = false
        }else{
            self.coverTopView.isHidden = true
        }
    }
}
