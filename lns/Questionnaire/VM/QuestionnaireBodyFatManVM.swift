//
//  QuestionnaireBodyFatManVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation
import UIKit

class QuestionnaireBodyFatManVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var selectIndex = -1
    var selectedBlock:(()->())?
    
    var showTipsBlock:(()->())?
    
    var vmDataArray = NSMutableArray()
    
    
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var dataArray : NSArray = {
        return [["data":"3%~5%","imgUrl":"body_fat_man_1"],
                ["data":"5%~8%","imgUrl":"body_fat_man_2"],
                ["data":"8%~12%","imgUrl":"body_fat_man_3"],
                ["data":"12%~15%","imgUrl":"body_fat_man_4"],
                ["data":"15%~20%","imgUrl":"body_fat_man_5"],
                ["data":"20%~25%","imgUrl":"body_fat_man_6"],
                ["data":"25%~30%","imgUrl":"body_fat_man_7"],
                ["data":"30%~40%","imgUrl":"body_fat_man_8"],
                ["data":"40%~50%","imgUrl":"body_fat_man_9"]]
    }()
    lazy var dataFemanArray : NSArray = {
        return [["data":"12%~15%","imgUrl":"body_fat_feman_1"],
                ["data":"15%~20%","imgUrl":"body_fat_feman_2"],
                ["data":"20%~25%","imgUrl":"body_fat_feman_3"],
                ["data":"25%~30%","imgUrl":"body_fat_feman_4"],
                ["data":"30%~35%","imgUrl":"body_fat_feman_5"],
                ["data":"35%~40%","imgUrl":"body_fat_feman_6"],
                ["data":"40%~45%","imgUrl":"body_fat_feman_7"],
                ["data":"45%~50%","imgUrl":"body_fat_feman_8"],
                ["data":"50%~60%","imgUrl":"body_fat_feman_9"]]
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "选择您现在的体脂肪"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tipsButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("体脂肪误差：为什么测量值通常偏低？", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(showTipsAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var scrollView : UIScrollView = {
        let vi = UIScrollView()
        vi.frame = CGRect.init(x: 0, y: kFitWidth(162), width: SCREEN_WIDHT, height: self.selfHeight-kFitWidth(162)-kFitWidth(12)-WHUtils().getBottomSafeAreaHeight())
        vi.backgroundColor = .clear
        vi.showsVerticalScrollIndicator = false
        vi.delegate = self
        
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

extension QuestionnaireBodyFatManVM{
    func refreshSelectStatus() {
        for i in 0..<self.vmDataArray.count{
            let vm = self.vmDataArray[i]as! QuestionnaireBodyFatItemVM
            vm.updateUIIsSelected(isSelect: (i == self.selectIndex))
        }
    }
    @objc func showTipsAction(){
        if self.showTipsBlock != nil{
            self.showTipsBlock!()
        }
    }
}

extension QuestionnaireBodyFatManVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsButton)
        addSubview(scrollView)
        
        updateScrollView()
        addSubview(coverView)
        addSubview(coverTopView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(40))
            make.height.equalTo(kFitWidth(36))
        }
        tipsButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(82))
            make.height.equalTo(kFitWidth(26))
        }
        coverView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.bottom.equalTo(self.scrollView)
        }
        coverTopView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.top.equalTo(self.scrollView).offset(kFitWidth(-5))
        }
    }
    func updateScrollView() {
        for vi in scrollView.subviews{
            vi.removeFromSuperview()
        }
        self.vmDataArray.removeAllObjects()
        QuestinonaireMsgModel.shared.bodyFat = ""
        self.selectIndex = -1
        let array = QuestinonaireMsgModel.shared.sex == "1" ? dataArray : dataFemanArray
        let colNum = isIpad() ?  3 : 2
        let itemW = SCREEN_WIDHT/CGFloat(colNum)
        var offsetY = kFitWidth(0)
        for i in 0..<array.count{
            let vm = QuestionnaireBodyFatItemVM.init(frame: CGRect.init(x: itemW*CGFloat(i%colNum), y: QuestionnaireBodyFatItemVM().selfHeight*CGFloat(i/colNum), width: 0, height: 0))
            scrollView.addSubview(vm)
            offsetY = vm.frame.maxY
            
            let dict = array[i]as? NSDictionary ?? [:]
//            if colNum == 2 {
//                vm.updateUI(dict: dict, isRight: (i%2 == 1 ? true : false))
//            }
            vm.updateUI(dict: dict, isRight: false)
            vm.tapBlock = {()in
                if self.selectIndex == i{
                    return
                }
                if self.selectIndex == -1 && self.selectedBlock != nil{
                    self.selectedBlock!()
                    
                    self.scrollView.frame = CGRect.init(x: 0, y: kFitWidth(162), width: SCREEN_WIDHT, height: self.selfHeight-kFitWidth(230)-WHUtils().getBottomSafeAreaHeight())
                    self.coverView.snp.remakeConstraints { make in
                        make.left.width.equalToSuperview()
                        make.height.equalTo(kFitWidth(40))
                        make.bottom.equalTo(self.scrollView.snp.bottom)
                    }
                }
                self.selectIndex = i
                self.refreshSelectStatus()
                QuestinonaireMsgModel.shared.bodyFat = "\(dict["data"]as? String ?? "")"
            }
            self.vmDataArray.add(vm)
        }
        
        scrollView.contentSize = CGSize.init(width: 0, height: offsetY)
    }
}

extension QuestionnaireBodyFatManVM:UIScrollViewDelegate{
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
