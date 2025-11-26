//
//  QuestionnairePlanFoodsDetailAlertVM.swift
//  lns
//   20   60
//  Created by LNS2 on 2024/4/2.
//

import Foundation
import UIKit
import DGCharts

class QuestionnairePlanFoodsDetailAlertVM: UIView {

    let nameArray = ["蛋白质","脂肪","碳水化合物"]
    let colors: [UIColor] = [.COLOR_PROTEIN,.COLOR_FAT,.COLOR_CARBOHYDRATE]
    var dataArray = NSArray()
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.15
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
   override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       super.traitCollectionDidChange(previousTraitCollection)
       if #available(iOS 13.0, *),
          previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
          !isHidden {
           UIView.animate(withDuration: 0.2) {
               self.bgView.alpha = self.targetDimAlpha
           }
       }
   }
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.isHidden = true
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
//        self.addGestureRecognizer(tap)
        
        initUI()
        updateUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK//WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(16)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var detailsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "每100g所含营养素比例"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var pieChartView : WHPieChartView = {
        let vi = WHPieChartView.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(94), width: kFitWidth(340), height: kFitWidth(200)))
        
        return vi
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        return vi
    }()
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("我知道了", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
}

extension QuestionnairePlanFoodsDetailAlertVM{
    func showView(dict:NSDictionary) {
        self.isHidden = false
        whiteView.alpha = 0
//        self.alpha = 0
        bgView.alpha = 0
        self.titleLabel.text = dict["fname"]as? String ?? ""
        
        dataArray = [Float(dict.stringValueForKey(key: "protein")) ?? 0.00,
                     Float(dict.stringValueForKey(key: "fat")) ?? 0.00,
                     Float(dict.stringValueForKey(key: "carbohydrate")) ?? 0.00]
        
        pieChartView.setPercents(numer: dataArray)
        
        updateCenterAttr(calories: dict.stringValueForKey(key: "calories"))
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
            self.bgView.alpha = self.targetDimAlpha//0.15
        }
    }
    
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
            self.bgView.alpha = 0
        }completion: { c in
            self.isHidden = true
        }
    }
    @objc func nothingToDo() {
        
    }
    func updateCenterAttr(calories:String)  {
        ////饼状图中心的富文本
        let carNumber = calories
        let attr = NSMutableAttributedString.init(string: carNumber)
        let unitStr = NSMutableAttributedString.init(string: "\n热量")
        attr.yy_font = .systemFont(ofSize: 20, weight: .medium)
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214
        
        unitStr.yy_font = .systemFont(ofSize: 12, weight: .regular)
        unitStr.yy_color = .COLOR_TEXT_TITLE_0f1214
        attr.append(unitStr)
        attr.yy_alignment = .center
        pieChartView.centerLabel.attributedText = attr
//        pieChartView.centerAttributedText = attr
    }
}

extension QuestionnairePlanFoodsDetailAlertVM{
    func updateUI() {
//        setChart(dataPoints: months, values: unitsSold)
    }
}

extension QuestionnairePlanFoodsDetailAlertVM{
    func setChart(dataPoints: [String], values: [Double]) {
    }
    //设置饼状图字体配置
      func setPieChartDataSetConfig(pichartDataSet: PieChartDataSet){
      }
      
      //设置饼状图字体样式
      func setPieChartDataConfig(pieChartData: PieChartData){
      }
      
      //设置饼状图中心文本
      func setDrawHoleState(){
      }
    
}

extension QuestionnairePlanFoodsDetailAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(detailsLabel)
        whiteView.addSubview(pieChartView)
        whiteView.addSubview(lineView)
        whiteView.addSubview(confirmBtn)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(340))
            make.height.equalTo(kFitWidth(360))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(23))
            make.height.equalTo(kFitWidth(20))
        }
        detailsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(54))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-48))
        }
        confirmBtn.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
        }
    }
    
}

extension QuestionnairePlanFoodsDetailAlertVM:ChartViewDelegate{
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
}

//        pieChartData.setValueFormatter(DigitValueFormatter() //设置百分比
//转化为带%
class DigitValueFormatter: NSObject, ValueFormatter {
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let pieEntry = entry as! PieChartDataEntry
        
        let valueWithoutDecimalPart = String(format: "%@%.0f%%\n%.1fg",pieEntry.label ?? "" ,value,entry.y)
        DLLog(message: "pieEntry:\(pieEntry)   -- value:\(value)")
        
        let step = NSMutableAttributedString.init(string: String(format: "%@%.0f%%\n",pieEntry.label ?? "" ,value))
        let totalStep = NSMutableAttributedString.init(string: String(format: "%.1fg",entry.y))
        
        let colors: [UIColor] = [.COLOR_PROTEIN,.COLOR_FAT,.COLOR_CARBOHYDRATE]
        step.yy_color = colors[dataSetIndex]
        
        step.append(totalStep)
        step.yy_font = .systemFont(ofSize: 12, weight: .regular)
        
        return step.string
    }
}

