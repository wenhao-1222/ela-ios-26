//
//  NaturalPerVM.swift
//  lns
//  统计--上方的均值
//  Created by LNS2 on 2024/9/9.
//

import Foundation

class NaturalPerVM: UIView {
    
    let selfHeight = kFitWidth(106)+kFitWidth(16)
    let whiteWidth = SCREEN_WIDHT-kFitWidth(16)
    var isFirst = true
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var whiteBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(8), width: whiteWidth, height: kFitWidth(106)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        
        var attr = NSMutableAttributedString(string: "均值")
        let detailAttr = NSMutableAttributedString(string: "(每日)")
        
        attr.yy_font = .systemFont(ofSize: 18, weight: .bold)
        attr.yy_color = .COLOR_GRAY_BLACK_85
        
        detailAttr.yy_font = .systemFont(ofSize: 12, weight: .medium)
        detailAttr.yy_color = .COLOR_GRAY_BLACK_45

        attr.append(detailAttr)
        
        lab.attributedText = attr
        
        return lab
    }()
    lazy var caloriesNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var caloriesNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "热量(千卡)"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var carboNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var carboNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "碳水(g)"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var proteinNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var proteinNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "蛋白质(g)"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var fatNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var fatNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "脂肪(g)"
        lab.textAlignment = .center
        
        return lab
    }()
}

extension NaturalPerVM{
    func updateUI(dict:NSDictionary){
        if isFirst{
            isFirst = false
            animateLabel(caloriesNumLabel, text: String(format: "%.0f", dict.doubleValueForKey(key: "caloriesAvg").rounded()))
            animateLabel(carboNumLabel, text: String(format: "%.0f", dict.doubleValueForKey(key: "carbohydrateAvg").rounded()))
            animateLabel(proteinNumLabel, text: String(format: "%.0f", dict.doubleValueForKey(key: "proteinAvg").rounded()))
            animateLabel(fatNumLabel, text: String(format: "%.0f", dict.doubleValueForKey(key: "fatAvg").rounded()))
        }else{
            self.caloriesNumLabel.text = String(format: "%.0f", dict.doubleValueForKey(key: "caloriesAvg").rounded())
            self.carboNumLabel.text = String(format: "%.0f", dict.doubleValueForKey(key: "carbohydrateAvg").rounded())
            self.proteinNumLabel.text = String(format: "%.0f", dict.doubleValueForKey(key: "proteinAvg").rounded())
            self.fatNumLabel.text = String(format: "%.0f", dict.doubleValueForKey(key: "fatAvg").rounded())
        }
    }

    private func animateLabel(_ label: UILabel, text: String) {
        label.text = text
        label.alpha = 0
        UIView.animate(withDuration: 0.3) {
            label.alpha = 1
        }
    }
    
}

extension NaturalPerVM{
    func initUI() {
        addSubview(whiteBgView)
        whiteBgView.addSubview(titleLabel)
        whiteBgView.addSubview(caloriesNumLabel)
        whiteBgView.addSubview(caloriesNumLab)
        whiteBgView.addSubview(carboNumLab)
        whiteBgView.addSubview(carboNumLabel)
        whiteBgView.addSubview(proteinNumLab)
        whiteBgView.addSubview(proteinNumLabel)
        whiteBgView.addSubview(fatNumLab)
        whiteBgView.addSubview(fatNumLabel)
        
        whiteBgView.addShadow(opacity: 0.05)
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        caloriesNumLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(kFitWidth(54))
            make.centerX.lessThanOrEqualTo(whiteWidth*0.5*0.25)
            make.width.equalTo(kFitWidth(80))
            make.bottom.equalTo(kFitWidth(-16))
        }
        caloriesNumLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(caloriesNumLab)
            make.width.equalTo(caloriesNumLab)
            make.bottom.equalTo(caloriesNumLab.snp.top).offset(kFitWidth(-8))
        }
        carboNumLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(kFitWidth(138))
            make.centerX.lessThanOrEqualTo(whiteWidth*0.5*0.75)
            make.width.equalTo(kFitWidth(80))
            make.bottom.equalTo(caloriesNumLab)
        }
        carboNumLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(carboNumLab)
            make.width.equalTo(caloriesNumLab)
            make.bottom.equalTo(carboNumLab.snp.top).offset(kFitWidth(-8))
        }
        proteinNumLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(kFitWidth(222))
            make.centerX.lessThanOrEqualTo(whiteWidth*0.5*0.25+whiteWidth*0.5)
            make.width.equalTo(kFitWidth(80))
            make.bottom.equalTo(caloriesNumLab)
        }
        proteinNumLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(proteinNumLab)
            make.width.equalTo(caloriesNumLab)
            make.bottom.equalTo(proteinNumLab.snp.top).offset(kFitWidth(-8))
        }
        fatNumLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(kFitWidth(306))
            make.centerX.lessThanOrEqualTo(whiteWidth*0.5*0.75+whiteWidth*0.5)
            make.width.equalTo(kFitWidth(80))
            make.bottom.equalTo(caloriesNumLab)
        }
        fatNumLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(fatNumLab)
            make.width.equalTo(caloriesNumLab)
            make.bottom.equalTo(fatNumLab.snp.top).offset(kFitWidth(-8))
        }
    }
}
