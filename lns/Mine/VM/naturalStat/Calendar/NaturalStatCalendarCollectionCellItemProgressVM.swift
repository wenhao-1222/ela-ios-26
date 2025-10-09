//
//  NaturalStatCalendarCollectionCellItemProgressVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/12.
//

import Foundation

class NaturalStatCalendarCollectionCellItemProgressVM: UIView {
    
    var selfWidth = kFitWidth(52)
    let selfHeight = kFitWidth(12)
    
    var progressColor = UIColor.THEME
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: selfHeight))
        selfWidth = frame.width
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var progressBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var progressView: UIView = {
        let vi = UIView()
        vi.backgroundColor = progressColor
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 8, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var overflowImgView : UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(2)
        img.clipsToBounds = true
        img.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        img.setImgLocal(imgName: "main_nutrient_span_img_2")
        img.contentMode = .center
        img.isUserInteractionEnabled = true
        
        img.isHidden = true
        return img
    }()
}

extension NaturalStatCalendarCollectionCellItemProgressVM{
    func udpateUI(number:Double,total:Double) {
        let totalNum = total > 0 ? total : 1
        var percent = number/totalNum
        if percent > 1{
            percent = 1
        }
//        DLLog(message: "\(percent)   ---    \(number)-\(totalNum)")
        progressView.snp.remakeConstraints { make in
            make.left.top.height.equalToSuperview()
//            make.width.equalTo(kFitWidth(20)*percent)
            make.width.equalTo((selfWidth-kFitWidth(30))*percent)
        }
        
        numberLabel.text = "\(Int(number.rounded()))"
        
        let remainNum = totalNum - number
        overflowImgView.isHidden = true
        if remainNum < 0 {
            overflowImgView.isHidden = false
            
            let fullNum = number - totalNum
            
            let fullPercent = Float(fullNum)/Float(totalNum)
            var coverWidth = (1 - fullPercent) * Float((selfWidth-kFitWidth(30)))
            if fullPercent >= 1 {
                coverWidth = 0
            }
            overflowImgView.snp.remakeConstraints { make in
                make.top.height.equalToSuperview()
                make.width.equalTo((selfWidth-kFitWidth(30)))
                make.left.equalTo(-coverWidth)
            }
        }
    }
    func setProgreColor(color:UIColor) {
        progressView.backgroundColor = color
    }
    func resetColorForGoal() {
        progressBottomView.backgroundColor = .clear
        progressView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
    }
}

extension NaturalStatCalendarCollectionCellItemProgressVM{
    func initUI() {
        addSubview(progressBottomView)
        progressBottomView.addSubview(progressView)
        progressBottomView.addSubview(overflowImgView)
        addSubview(numberLabel)
        
        setConstrait()
    }
    func setConstrait() {
        
//        if isIpad(){
            progressBottomView.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(3))
                make.centerY.lessThanOrEqualToSuperview()
                make.height.equalTo(kFitWidth(4))
                make.width.equalTo(selfWidth-kFitWidth(30))
            }
//        }else{
//            progressBottomView.snp.makeConstraints { make in
//                make.left.equalTo(kFitWidth(3))
//                make.centerY.lessThanOrEqualToSuperview()
//                make.height.equalTo(kFitWidth(4))
//                make.width.equalTo(kFitWidth(20))
//            }
//            
//        }
        progressView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(0))
        }
        overflowImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(25))
//            make.left.equalTo(progressBottomView.snp.right).offset(kFitWidth(2))
            make.width.equalTo(kFitWidth(27))
            make.right.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
