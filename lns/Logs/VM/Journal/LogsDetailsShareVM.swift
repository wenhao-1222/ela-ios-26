//
//  LogsDetailsShareVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/12.
//

import Foundation
import UIKit
import MCToast

class LogsDetailsShareVM: UIView {
    
    var shareCode = ""
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: kFitWidth(320), height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    lazy var topVm : JournalShareTopVM = {
//        let vm = JournalShareTopVM.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(320), height: 0))
//        vm.bgImgView.setImgLocal(imgName: "logs_share_bg_img")
//        return vm
//    }()
    lazy var themeBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(320), height: kFitWidth(60)))
        vi.backgroundColor = .THEME
        return vi
    }()
    lazy var topVm : JournalShareTopVM = {
        let vm = JournalShareTopVM.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(320), height: 0))
//        vm.refreshUIForLogs(dict: self.detailsDict)
        vm.nameVm.refreshUI(name: UserInfoModel.shared.nickname, avatar: UserInfoModel.shared.headimgurl)
        vm.nameVm.tipsLabel.text = "给你分享了一个饮食日志"
        
//        vm.contentWhiteNewView.daysLabel.text = "\(self.dayString)"
        return vm
    }()
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var bottomTipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "elavatine内打开计划列表/导入计划/输入分享码使用该计划"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var shareCodeLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.backgroundColor = .THEME
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.isUserInteractionEnabled = true
        
        // 添加手势识别器
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCopyAction))
        lab.addGestureRecognizer(longPressGesture)
        
        return lab
    }()
    lazy var copyCodeTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        // 添加手势识别器
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCopyAction))
        vi.addGestureRecognizer(longPressGesture)
        
        return vi
    }()
}

extension LogsDetailsShareVM{
    @objc func longPressCopyAction(){
        UIPasteboard.general.string = "\(shareCode)"
        MCToast.mc_success("分享码已复制！")
    }
}

extension LogsDetailsShareVM{
    func initUI() {
        addSubview(themeBgView)
        addSubview(topVm)
        addSubview(whiteView)
        addSubview(shareCodeLabel)
        addSubview(copyCodeTapView)
    }
    func updateUI(dataArray:NSArray)  {
        var originY = kFitWidth(0)
        for i in 0..<dataArray.count{
            let arr = dataArray[i]as? NSArray ?? []
            if arr.count > 0 {
                let titleVm = PlanShareMealsTitleVM.init(frame: CGRect.init(x: 0, y: originY, width: kFitWidth(320), height: 0))
                whiteView.addSubview(titleVm)
                titleVm.titleLabel.text = "第 \(i+1) 餐"
                originY = originY + titleVm.selfHeight + kFitWidth(8)
                
                for j in 0..<arr.count{
                    let dict = arr[j]as? NSDictionary ?? [:]
                    
                    let foodsVm = PlanShareMealsFoodsVM.init(frame: CGRect.init(x: 0, y: originY-kFitWidth(1), width: kFitWidth(320), height: 0))
                    whiteView.addSubview(foodsVm)
                    foodsVm.updateUI(dict: dict)
                    
                    originY = originY + foodsVm.selfHeight
                }
            }
        }
        whiteView.frame = CGRect.init(x: 0, y: self.topVm.frame.maxY, width: kFitWidth(320), height: originY+kFitWidth(50)+kFitWidth(40))
        self.frame = CGRect.init(x: SCREEN_WIDHT, y: 0, width: kFitWidth(320), height: self.topVm.frame.maxY + originY+kFitWidth(50) + kFitWidth(28)+kFitWidth(40))
        
        whiteView.addSubview(bottomTipsLabel)
        bottomTipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.right.equalTo(kFitWidth(-8))
            make.bottom.equalTo(kFitWidth(-8))
        }
        shareCodeLabel.snp.makeConstraints { make in
            make.left.bottom.width.equalToSuperview()
            make.height.equalTo(kFitWidth(28))
        }
        copyCodeTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(shareCodeLabel)
            make.height.equalTo(kFitWidth(40))
            make.left.equalTo(shareCodeLabel).offset(kFitWidth(-30))
            make.right.equalTo(shareCodeLabel.snp.right).offset(kFitWidth(30))
        }
    }
    func updateUIForLog(dataArray:NSArray)  {
        var originY = kFitWidth(0)
        for i in 0..<dataArray.count{
            let arr = dataArray[i]as? NSArray ?? []
            
            if arr.count > 0 {
                let titleVm = PlanShareMealsTitleVM.init(frame: CGRect.init(x: 0, y: originY, width: kFitWidth(320), height: 0))
                titleVm.titleLabel.text = "第 \(i+1) 餐"
                
                var hasFoods = false
                
                for j in 0..<arr.count{
                    let dict = arr[j]as? NSDictionary ?? [:]
                    
                    if dict.stringValueForKey(key: "state") == "1"{
                        if hasFoods == false{
                            hasFoods = true
                            whiteView.addSubview(titleVm)
                            originY = originY + titleVm.selfHeight + kFitWidth(8)
                        }
                        
                        let foodsVm = PlanShareMealsFoodsVM.init(frame: CGRect.init(x: 0, y: originY, width: kFitWidth(320), height: 0))
                        whiteView.addSubview(foodsVm)
                        foodsVm.updateUI(dict: dict)
                        
                        originY = originY + foodsVm.selfHeight
                    }
                }
            }
        }
        whiteView.frame = CGRect.init(x: 0, y: self.topVm.frame.maxY, width: kFitWidth(320), height: originY + kFitWidth(40))
        self.frame = CGRect.init(x: SCREEN_WIDHT, y: 0, width: kFitWidth(320), height: self.topVm.frame.maxY + originY+kFitWidth(28) + kFitWidth(40))
        shareCodeLabel.isHidden = true
    }
}

