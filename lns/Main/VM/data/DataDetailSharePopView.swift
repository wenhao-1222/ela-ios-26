//
//  DataDetailSharePopView.swift
//  lns
//
//  Created by LNS2 on 2024/4/18.
//

import Foundation
import UIKit

@objcMembers
class DataDetailSharePopView: UIView {
    
    let selfWidth = kFitWidth(84)
    let selfHeight = kFitWidth(24)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: selfWidth, height: selfHeight))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.15)
//        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.15)
        
        return vi
    }()
    lazy var timeLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension DataDetailSharePopView{
    func updateUI(number:String,unit:String,time:String,fatherViewWidth:CGFloat,isMax:Bool,circlePoint:CGPoint) {
        let numberFloat = number.floatValue
        
        if unit == "%"{
            numberLabel.text = "\(WHUtils.convertStringToString("\(numberFloat)") ?? "?")\(unit)"
        }else{
            numberLabel.text = "\(WHUtils.convertStringToStringOneDigit("\(numberFloat)") ?? "?")\(unit)"
        }
        
//        timeLabel.text = Date().changeDateFormatter(dateString: time, formatter: "yyyy-MM-dd HH:mm:ss", targetFormatter: "MM/dd")
        timeLabel.text = Date().changeDateFormatter(dateString: time, formatter: "yyyy-MM-dd", targetFormatter: "MM/dd")
        
        if isMax == true{//最大值
            if circlePoint.x + selfWidth >= fatherViewWidth - kFitWidth(10) {
                //4象限
                self.frame = CGRect.init(x: circlePoint.x - selfWidth, y: circlePoint.y-kFitWidth(7)-selfHeight, width: selfWidth, height: selfHeight)
                self.bgView.addClipCorner(corners: [.topLeft,.topRight,.bottomLeft], radius: kFitWidth(12))
            }else{
                //1象限
                self.frame = CGRect.init(x: circlePoint.x, y: circlePoint.y-kFitWidth(7)-selfHeight, width: selfWidth, height: selfHeight)
                self.bgView.addClipCorner(corners: [.topLeft,.topRight,.bottomRight], radius: kFitWidth(12))
            }
        }else{
            if circlePoint.x + selfWidth >= fatherViewWidth {
                //3象限
                self.frame = CGRect.init(x: circlePoint.x - selfWidth, y: circlePoint.y+kFitWidth(7), width: selfWidth, height: selfHeight)
                self.bgView.addClipCorner(corners: [.topLeft,.bottomRight,.bottomLeft], radius: kFitWidth(12))
            }else{
                //2象限
                self.frame = CGRect.init(x: circlePoint.x, y: circlePoint.y+kFitWidth(7), width: selfWidth, height: selfHeight)
                self.bgView.addClipCorner(corners: [.bottomRight,.topRight,.bottomLeft], radius: kFitWidth(12))
            }
        }
    }
}
extension DataDetailSharePopView{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(numberLabel)
        bgView.addSubview(lineView)
        bgView.addSubview(timeLabel)
        
        setConstrait()
    }
    func setConstrait() {
//        bgView.snp.makeConstraints { make in
//            make.left.top.height.equalToSuperview()
//        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(2))
            make.top.height.equalToSuperview()
            make.right.equalTo(lineView.snp.left).offset(kFitWidth(-2))
        }
        lineView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-39))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(16))
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(lineView.snp.right)
            make.right.equalToSuperview()
            make.top.height.equalToSuperview()
        }
    }
}
