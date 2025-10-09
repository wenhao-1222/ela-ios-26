//
//  QuestionnaireGoalVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//  

import Foundation
import UIKit

class QuestionnaireGoalVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var selectIndex = -1
    
    var nextBlock:(()->())?
    var choiceBlock:(()->())?
    
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
        return [["name":"急速减脂","selected":"0","detail":"适合希望短时间内准备摄影写真集，参加活动，前任婚礼等的用户。反弹风险高，建议不超过4周"],
                ["name":"中高强度减脂","selected":"0","detail":"适合希望达到短期身材目标，参加健美比赛的运动员/健身爱好者等。有一定反弹风险，建议时长：8-16周"],
                ["name":"日常减脂","selected":"0","detail":"适合任何希望达到长期身材，健康目标人群。低反弹风险，建议时长：15-20周"],
                ["name":"干净增肌","selected":"0","detail":"适合在希望保持低体脂肪/不增加体脂肪情况下进行增肌的运动员/健身爱好者等。建议时长：8-12周"],
                ["name":"增肌","selected":"0","detail":"适合希望在最短时间内增加最大维度（肌肉和少部分脂肪）的偏瘦人群。建议时长：8-12周"],
                ["name":"维持","selected":"0","detail":"适合希望在保持体型不变情况下增加身体线条的用户/减脂瓶颈期需要提高代谢的用户。建议时长：≥1周"],
                ["name":"提升力量","selected":"0","detail":"适合希望最大化提升力量的人群。建议时长：6-8周"],
                ["name":"提高运动表现","selected":"0","detail":"适合希望最大化提升功能性表现的篮球/足球/橄榄球/拳击运动员等。建议计划时长：8-16周"]]
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "选择您的目标"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: kFitWidth(152), width: SCREEN_WIDHT, height: self.selfHeight-kFitWidth(152)-kFitWidth(84)-WHUtils().getBottomSafeAreaHeight()), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(QuestionnaireGoalTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionnaireGoalTableViewCell")
        
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
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: SCREEN_HEIGHT, width: kFitWidth(343), height: kFitWidth(48))
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        return btn
    }()
}

extension QuestionnaireGoalVM{
    @objc func nextAction()  {
        if self.nextBlock != nil{
            self.nextBlock!()
        }
    }
}
extension QuestionnaireGoalVM{
    func initUI(){
        addSubview(titleLabel)
        addSubview(tableView)
        addSubview(coverView)
        addSubview(coverTopView)
//        addSubview(nextBtn)
        
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
    func refresNextBtnCenter() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.nextBtn.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.selfHeight-kFitWidth(36)-WHUtils().getBottomSafeAreaHeight())
        }
    }
}

extension QuestionnaireGoalVM:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireGoalTableViewCell") as! QuestionnaireGoalTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionnaireGoalTableViewCell", for: indexPath) as? QuestionnaireGoalTableViewCell
        
        let dict = self.dataArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict, isSelected: self.selectIndex==indexPath.row)
        
        return cell ?? QuestionnaireGoalTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.selectIndex == indexPath.row ? kFitWidth(144) : kFitWidth(72)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectIndex == indexPath.row{
            return
        }
        if self.selectIndex < 0 {
//            self.refresNextBtnCenter()
            if self.choiceBlock != nil{
                self.choiceBlock!()
            }
        }
        self.selectIndex = -1
        self.tableView.reloadData()
        
        self.selectIndex = indexPath.row
        
//        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
//        self.tableView.reloadData()
        QuestinonaireMsgModel.shared.goal = "\(self.selectIndex+1)"
        DLLog(message: "目标：\(QuestinonaireMsgModel.shared.goal)")
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
