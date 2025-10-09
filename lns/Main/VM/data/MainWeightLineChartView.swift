//
//  MainWeightLineChartView.swift
//  lns
//
//  Created by LNS2 on 2024/6/11.
//

import Foundation
import UIKit

class MainWeightLineChartView: UIView {
    
    let selfHeight = kFitWidth(236)
    let chartHeight = kFitWidth(40)*3+kFitWidth(36)
    
    var dataSourceArray = NSArray()
    
    var tapBlock:(()->())?
    var addBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(selfTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.text = "体重数据"
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var addButton : FeedBackTapButton = {
        let btn = FeedBackTapButton()
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
//        btn.setBackgroundImage(UIImage.init(named: "main_add_data_button"), for: .normal)
//        btn.setBackgroundImage(UIImage.init(named: "logs_add_icon_theme"), for: .normal)
        btn.setImage(UIImage(named: "logs_add_icon_theme"), for: .normal)
        btn.addPressEffect()
        
        btn.addTarget(self, action: #selector(addTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        
        return vi
    }()
    lazy var tapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
//        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(addTapAction))
//        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: kFitWidth(30), y: self.frame.height-chartHeight, width: SCREEN_WIDHT-kFitWidth(78), height: chartHeight))
//        scro.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        scro.bounces = true
        scro.showsHorizontalScrollIndicator = false
        return scro
    }()
    var extendLineView: DataMainLineExtendView?
    lazy var lineChartView: DataMainLineView = {
        let vi = DataMainLineView.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(0), width: SCREEN_WIDHT-kFitWidth(78), height:chartHeight))
        return vi
    }()
    lazy var yXaisView: MainDataLineChartYXaisView = {
        let vi = MainDataLineChartYXaisView.init(frame: CGRect.init(x: 0, y: self.frame.height-chartHeight, width: kFitWidth(40), height: chartHeight-kFitWidth(34)))
        return vi
    }()
}

extension MainWeightLineChartView{
    @objc func selfTapAction(){
//        TouchGenerator.shared.touchGenerator()
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    @objc func addTapAction(){
        if self.addBlock != nil{
            self.addBlock!()
        }
    }
}
extension MainWeightLineChartView{
    func setDataSourceArray(dataArray:NSArray) {
//        titleLab.text = "体重数据(\(UserInfoModel.shared.weightUnitName))"
        dataSourceArray = dataArray
        var xStringArray:[String] = [String]()
        let yDataArrayWeight = NSMutableArray()
        
        if dataArray.count > 0 {
            for i in 0..<dataArray.count{
                let dict = dataArray[i]as? NSDictionary ?? [:]
                
                var timeString = dict["ctime"]as? String ?? ""
                timeString = timeString.replacingOccurrences(of: "-", with: "/")
                timeString = timeString.mc_cutToSuffix(from: 5)
                xStringArray.append(timeString)
                
                if dict.doubleValueForKey(key: "weight") > 0 {
                    let dict = ["xIndex":i,
                                "value":(dict.doubleValueForKey(key: "weight") * UserInfoModel.shared.weightCoefficient)] as [String : Any]
                    yDataArrayWeight.add(dict)
                }
            }
        }
        lineChartView.yXaisNum = 4
        lineChartView.dataSourceArray = xStringArray
        lineChartView.dataArray = [yDataArrayWeight]
        extendLineView?.removeFromSuperview()
        let ext = DataMainLineExtendView(frame: lineChartView.frame)
        ext.yXaisNum = Int(lineChartView.yXaisNum)
        ext.chartGap = CGFloat(lineChartView.chartGap)
        
        scrollView.insertSubview(ext, belowSubview: lineChartView)
        extendLineView = ext
        scrollView.contentSize = CGSize.init(width: lineChartView.frame.size.width, height: 0)

        yXaisView.labelGap = CGFloat(lineChartView.chartGap)
        yXaisView.setData(min: Int(lineChartView.minYXAisValue), max: Int(lineChartView.maxYXAisValue), gap: Int(lineChartView.yXaisValueGap))
        
//        let bottomOffset = CGPointMake(scrollView.contentSize.width - scrollView.bounds.size.width + scrollView.contentInset.right,0);
        let maxOffsetX = max(scrollView.contentSize.width - scrollView.bounds.size.width, 0)
                let bottomOffset = CGPoint(x: maxOffsetX, y: 0)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
}
extension MainWeightLineChartView{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(addButton)
        whiteView.addSubview(lineView)
//        whiteView.addSubview(tapView)
        whiteView.addShadow(opacity: 0.05)
        
        whiteView.addSubview(scrollView)
        scrollView.addSubview(lineChartView)
        
        whiteView.addSubview(yXaisView)
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        addButton.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(kFitWidth(16))
//            make.width.height.equalTo(kFitWidth(15))
            make.top.equalToSuperview()
//            make.right.equalTo(kFitWidth(-66))
            make.right.equalToSuperview()
            make.width.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(48))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(52))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(0.5))
        }
//        tapView.snp.makeConstraints { make in
//            make.center.lessThanOrEqualTo(addButton)
//            make.width.height.equalTo(kFitWidth(56))
//        }
    }
}
