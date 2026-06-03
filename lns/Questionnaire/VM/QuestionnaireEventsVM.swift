//
//  QuestionnaireEventsVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation
import UIKit

class QuestionnaireEventsVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var selectedIndex = -1
    
    var selectedBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_BG_F2
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bottomGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        topGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
    }
    lazy var dataArray : NSArray = {
        return [["name":"无活动","detail":"除少量走路通勤，无体育活动"],
                ["name":"低活跃水平","detail":"日常走路通勤，偶尔进行有氧/力量活动"],
                ["name":"中低活跃水平","detail":"每周2-3次力量/有氧训练，或从事体力工作"],
                ["name":"中活跃水平","detail":"每周4-5次力量/有氧训练"],
                ["name":"高活跃水平","detail":"每周6-7次力量/有氧训练"],
                ["name":"极高活跃水平","detail":"每日2次力量/有氧训练"]]
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "你的日常活动量是多少？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: kFitWidth(152)-kFitWidth(35), width: SCREEN_WIDHT, height: self.selfHeight-kFitWidth(152)+kFitWidth(35)-kFitWidth(84)-WHUtils().getBottomSafeAreaHeight()), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(QuestionnaireEventsTableViewCell.classForCoder(), forCellReuseIdentifier: "QuestionnaireEventsTableViewCell")
        
        return vi
    }()
    
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
//    lazy var coverView : UIImageView = {
//        let vi = UIImageView.init(frame: CGRect.init(x: 0, y: self.selfHeight, width: SCREEN_WIDHT, height: kFitWidth(40)))
//        vi.setImgLocal(imgName: "bottom_cover_img")
//        
//        return vi
//    }()
//    lazy var coverTopView : UIImageView = {
//        let vi = UIImageView()
//        vi.setImgLocal(imgName: "bottom_cover_img")
//        vi.transform = CGAffineTransform(scaleX: -1, y: -1)
//        vi.isHidden = true
//        
//        return vi
//    }()
}

extension QuestionnaireEventsVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(tableView)
//        addSubview(coverView)
//        addSubview(coverTopView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
            make.height.equalTo(kFitWidth(72))
        }
        
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(tableView).offset(kFitWidth(4))
            make.height.equalTo(kFitWidth(35))
//            make.top.equalTo(scrollView.snp.bottom).offset(kFitWidth(-35))
        }
//        coverTopView.snp.makeConstraints { make in
//            make.left.width.equalToSuperview()
//            make.height.equalTo(kFitWidth(40))
//            make.top.equalTo(self.tableView)
//        }
    }
}

extension QuestionnaireEventsVM:UITableViewDataSource,UITableViewDelegate{
    
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
        if self.selectedIndex == indexPath.row{
            return
        }
        if self.selectedIndex < 0 && self.selectedBlock != nil{
            self.selectedBlock!()
//            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//                self.coverView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.tableView.frame.maxY-kFitWidth(20))
//            }
        }
        self.selectedIndex = indexPath.row
        self.tableView.reloadData()
        QuestinonaireMsgModel.shared.events = "\(indexPath.row + 1)"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(82)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(35)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(35)))
        vi.backgroundColor = .clear
        return vi
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.coverTopView.isHidden = false
//    }
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            // 滑动已经结束且没有减速
//            // 在这里进行相应的操作
//            DLLog(message: "\(scrollView.contentOffset.y)")
//            if scrollView.contentOffset.y > kFitWidth(40){
//                self.coverTopView.isHidden = false
//            }else{
//                self.coverTopView.isHidden = true
//            }
//        }
//    }
//     
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        DLLog(message: "\(scrollView.contentOffset.y)")
//        if scrollView.contentOffset.y > kFitWidth(40){
//            self.coverTopView.isHidden = false
//        }else{
//            self.coverTopView.isHidden = true
//        }
//    }
}
