//
//  DataDetailTableHeadVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/18.
//

import Foundation
import UIKit

class DataDetailTableHeadVM: UIView {
    
    let selfHeight = kFitWidth(44)
    var scrollBlock:((CGFloat)->())?
    
    let itemsWidth = SCREEN_WIDHT-kFitWidth(147)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: NSNotification.Name(rawValue: "updateBodyDataSetting"), object: nil)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var topGapView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(8)))
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        return vi
    }()
    lazy var timeLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(4), width: kFitWidth(94), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "时间"
        lab.backgroundColor = .clear
        
        return lab
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scro = UIScrollView(frame: CGRect.init(x: kFitWidth(90), y: 0, width: itemsWidth, height: kFitWidth(44)))
        scro.backgroundColor = .clear
        scro.isUserInteractionEnabled = true
        scro.bounces = false
        scro.delegate = self
//        scro.showsHorizontalScrollIndicator = true
        
        return scro
    }()
    lazy var weightLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(4), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "体重"
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var yaoLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(60), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "腰围"
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var tunLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(116), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "臀围"
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var armLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(172), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "手臂"
        lab.backgroundColor = .clear
        
        return lab
    }()
    
    lazy var shoulderLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(228), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "肩宽"
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var bustLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(284), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "胸围"
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var thighLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(340), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "大腿围"
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var calfLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(396), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "小腿围"
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var bfpLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(452), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "体脂率"
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var photoLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: self.contentScrollView.frame.maxX, y: kFitWidth(4), width: kFitWidth(57), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.text = "照片"
        lab.backgroundColor = .clear
        
        return lab
    }()
    
    lazy var lineView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(43), width: SCREEN_WIDHT, height: kFitWidth(1)))
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
}

extension DataDetailTableHeadVM{
    func initUI() {
        addSubview(topGapView)
        addSubview(timeLabel)
        
        addSubview(contentScrollView)
        
        contentScrollView.addSubview(weightLabel)
        contentScrollView.addSubview(yaoLabel)
        contentScrollView.addSubview(tunLabel)
        contentScrollView.addSubview(armLabel)
        contentScrollView.addSubview(shoulderLabel)
        contentScrollView.addSubview(bustLabel)
        contentScrollView.addSubview(thighLabel)
        contentScrollView.addSubview(calfLabel)
        contentScrollView.addSubview(bfpLabel)
        
//        contentScrollView.contentSize = CGSize.init(width: calfLabel.frame.maxX, height: 0)
        refreshUI()
        addSubview(photoLabel)
        addSubview(lineView)
    }
    @objc func refreshUI() {
        let settingMsgDict = UserDefaults().getBodyDataSetting()
        var showItemNum = 4
        if settingMsgDict.stringValueForKey(key: "shoulder") == "1"{
            showItemNum = showItemNum + 1
        }
        if settingMsgDict.stringValueForKey(key: "bust") == "1"{
            showItemNum = showItemNum + 1
        }
        if settingMsgDict.stringValueForKey(key: "thigh") == "1"{
            showItemNum = showItemNum + 1
        }
        if settingMsgDict.stringValueForKey(key: "calf") == "1"{
            showItemNum = showItemNum + 1
        }
        
        let labelWidth = max(itemsWidth/CGFloat(showItemNum), kFitWidth(56))
        
        weightLabel.frame = CGRect.init(x: kFitWidth(4), y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
        yaoLabel.frame = CGRect.init(x: weightLabel.frame.maxX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
        tunLabel.frame = CGRect.init(x: yaoLabel.frame.maxX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
        armLabel.frame = CGRect.init(x: tunLabel.frame.maxX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
        
        var originX = armLabel.frame.maxX
        if settingMsgDict.stringValueForKey(key: "shoulder") == "1"{
            shoulderLabel.isHidden = false
            shoulderLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            shoulderLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "bust") == "1"{
            bustLabel.isHidden = false
            bustLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            bustLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "thigh") == "1"{
            thighLabel.isHidden = false
            thighLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            thighLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "calf") == "1"{
            calfLabel.isHidden = false
            calfLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            calfLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "bfp") == "1"{
            bfpLabel.isHidden = false
            bfpLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            bfpLabel.isHidden = true
        }
        
        contentScrollView.contentSize = CGSize.init(width: originX, height: 0)
    }
}

extension DataDetailTableHeadVM:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollBlock != nil{
            self.scrollBlock!(scrollView.contentOffset.x)
        }
    }
}
