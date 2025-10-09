//
//  NaturalStatCalendarMarkProgressView.swift
//  lns
//
//  Created by LNS2 on 2024/9/13.
//

import Foundation

class NaturalStatCalendarMarkProgressView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: kFitWidth(115), y: frame.origin.y, width: kFitWidth(150), height: kFitWidth(22)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .bold)
        
        return lab
    }()
    lazy var totalLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    
    lazy var progressBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var progressView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var overflowImgView : UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(3)
        img.clipsToBounds = true
        img.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        img.setImgLocal(imgName: "main_nutrient_span_img_2")
        img.contentMode = .scaleToFill
        img.isUserInteractionEnabled = true
        
        img.isHidden = true
        return img
    }()
}

extension NaturalStatCalendarMarkProgressView{
    func udpateUI(number:Double,total:Double) {
        let totalNum = total > 0 ? total : 1
        let percent = number/totalNum
        
        progressView.snp.remakeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(150)*percent)
        }
        
        numberLabel.text = "\(Int(number.rounded()))"
        totalLabel.text = "/\(Int(total.rounded()))g"
        
        let remainNum = totalNum - number
        overflowImgView.isHidden = true
        if remainNum < 0 {
            overflowImgView.isHidden = false
            
            let fullNum = number - totalNum
            
            let fullPercent = Float(fullNum)/Float(totalNum)
            var coverWidth = (1 - fullPercent) * Float(kFitWidth(150))
            if fullPercent >= 1 {
                coverWidth = 0
            }
            overflowImgView.snp.remakeConstraints { make in
                make.top.height.equalToSuperview()
                make.width.equalTo(kFitWidth(150))
                make.left.equalTo(-coverWidth)
            }
        }
    }
    func setProgreColor(color:UIColor) {
        progressView.backgroundColor = color
    }
}
extension NaturalStatCalendarMarkProgressView{
    func initUI() {
        addSubview(titleLabel)
        addSubview(totalLabel)
        addSubview(numberLabel)
        addSubview(progressBottomView)
        progressBottomView.addSubview(progressView)
        progressBottomView.addSubview(overflowImgView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
        totalLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.right.equalTo(totalLabel.snp.left)
            make.top.equalToSuperview()
        }
        progressBottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(kFitWidth(0))
            make.height.equalTo(kFitWidth(6))
//            make.width.equalTo(kFitWidth(20))
        }
        progressView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(0))
        }
        overflowImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
    }
}
