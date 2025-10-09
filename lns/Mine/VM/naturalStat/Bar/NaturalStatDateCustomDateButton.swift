//
//  NaturalStatDateCustomDateButton.swift
//  lns
//
//  Created by LNS2 on 2024/9/10.
//

import Foundation


class NaturalStatDateCustomDateButton : UIButton{
    
     var dateString = ""
    let lightThemeBgColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
    
     override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
         self.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
         self.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
         self.clipsToBounds = true
         
         addSubview(lightBgView)
         addSubview(bgView)
         addSubview(topTipsLabel)
         
         self.bringSubviewToFront(self.titleLabel ?? UILabel())
         bgView.snp.makeConstraints { make in
             make.left.top.right.bottom.equalToSuperview()
         }
         lightBgView.snp.makeConstraints { make in
             make.left.right.top.bottom.equalToSuperview()
//             make.left.equalTo(kFitWidth(8))
         }
         topTipsLabel.snp.makeConstraints { make in
             make.centerX.lessThanOrEqualToSuperview()
             make.top.equalTo(kFitWidth(4))
         }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = false
        vi.isHidden = true
        return vi
    }()
    lazy var lightBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = lightThemeBgColor
        vi.isUserInteractionEnabled = false
        vi.isHidden = true
        return vi
    }()
    lazy var topTipsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 8, weight: .medium)
        lab.isHidden = true
        lab.isUserInteractionEnabled = false
        
        return lab
    }()
}

extension NaturalStatDateCustomDateButton{
    func setSelect(isSelct:Bool,isStartTime:Bool?=false) {
        lightBgView.layer.cornerRadius = kFitWidth(0)
        self.layer.cornerRadius = kFitWidth(0)
        self.topTipsLabel.isHidden = true
        if isSelct{
            self.backgroundColor = lightThemeBgColor
            bgView.isHidden = false
            lightBgView.isHidden = false
            topTipsLabel.isHidden = false
            self.setTitleColor(.white, for: .normal)
            if isStartTime == true{
                lightBgView.addClipCorner(corners: [.topLeft,.bottomLeft], radius: kFitWidth(8))
                self.addClipCorner(corners: [.topLeft,.bottomLeft], radius: kFitWidth(8))
                topTipsLabel.text = "开始"
            }else{
                lightBgView.addClipCorner(corners: [.topRight,.bottomRight], radius: kFitWidth(8))
                self.addClipCorner(corners: [.topRight,.bottomRight], radius: kFitWidth(8))
                topTipsLabel.text = "结束"
            }
        }else{
            self.backgroundColor = .clear
            bgView.isHidden = true
            lightBgView.isHidden = true
            self.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        }
    }
    func setBetweenStatus(){
        self.backgroundColor = lightThemeBgColor
    }
    func setDate(yearInt:Int,monthInt:Int,dayInt:Int) {
        var dateStr = "\(yearInt)"
        if monthInt < 10{
            dateStr = "\(dateStr)-0\(monthInt)"
        }else{
            dateStr = "\(dateStr)-\(monthInt)"
        }
        if dayInt < 10{
            dateStr = "\(dateStr)-0\(dayInt)"
        }else{
            dateStr = "\(dateStr)-\(dayInt)"
        }
        dateString = dateStr
    }
    func setWeekDay(weekDay:Int) {
        if weekDay == 7 {
            self.addClipCorner(corners: [.topLeft,.bottomLeft], radius: kFitWidth(8))
        }else if weekDay == 6{
            self.addClipCorner(corners: [.topRight,.bottomRight], radius: kFitWidth(8))
        }
    }
}
