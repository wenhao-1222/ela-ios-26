//
//  NaturalStatCaloriesBarChartYAxisView.swift
//  lns
//
//  Created by LNS2 on 2024/9/9.
//

import Foundation

class NaturalStatCaloriesBarChartYAxisView: UIView {
    
    let selfHeight = kFitWidth(200)
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: kFitWidth(36), width: kFitWidth(359), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    lazy var firstLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var secondLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var thirdLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var fourthLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var fifthLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "0"
        
        return lab
    }()
    lazy var lineOneView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    lazy var lineTwoView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    lazy var lineThreeView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    lazy var lineFourView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    lazy var lineFiveView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
}

extension NaturalStatCaloriesBarChartYAxisView{
    func updateUI(minValue:Int) {
        fourthLabel.text = "\(minValue)"
        thirdLabel.text = "\(minValue*2)"
        secondLabel.text = "\(minValue*3)"
        firstLabel.text = "\(minValue*4)"
    }
}

extension NaturalStatCaloriesBarChartYAxisView{
    func initUI() {
        addSubview(firstLabel)
        addSubview(secondLabel)
        addSubview(thirdLabel)
        addSubview(fourthLabel)
        addSubview(fifthLabel)
        
        addSubview(lineOneView)
        addSubview(lineTwoView)
        addSubview(lineThreeView)
        addSubview(lineFourView)
        addSubview(lineFiveView)
        
        setConstrait()
    }
    func setConstrait() {
        lineOneView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(49))
            make.right.equalTo(kFitWidth(-14))
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(kFitWidth(40))
        }
        lineTwoView.snp.makeConstraints { make in
            make.left.right.height.equalTo(lineOneView)
            make.top.equalTo(kFitWidth(80))
        }
        lineThreeView.snp.makeConstraints { make in
            make.left.right.height.equalTo(lineOneView)
            make.top.equalTo(kFitWidth(120))
        }
        lineFourView.snp.makeConstraints { make in
            make.left.right.height.equalTo(lineOneView)
            make.top.equalTo(kFitWidth(160))
        }
        lineFiveView.snp.makeConstraints { make in
            make.left.right.height.equalTo(lineOneView)
            make.bottom.equalToSuperview()
        }
        firstLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(kFitWidth(45))
            make.bottom.equalTo(lineOneView).offset(kFitWidth(0))
        }
        secondLabel.snp.makeConstraints { make in
            make.left.right.equalTo(firstLabel)
            make.bottom.equalTo(lineTwoView).offset(kFitWidth(0))
        }
        thirdLabel.snp.makeConstraints { make in
            make.left.right.equalTo(firstLabel)
            make.bottom.equalTo(lineThreeView).offset(kFitWidth(0))
        }
        fourthLabel.snp.makeConstraints { make in
            make.left.right.equalTo(firstLabel)
            make.bottom.equalTo(lineFourView).offset(kFitWidth(0))
        }
        fifthLabel.snp.makeConstraints { make in
            make.left.right.equalTo(firstLabel)
            make.bottom.equalTo(lineFiveView).offset(kFitWidth(0))
        }
        
    }
}
