//
//  QuestionnaireHeightVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation
import UIKit

class QuestionnaireHeightVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "您的身高是多少?"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var numberLabel : YYLabel = {
        let lab = YYLabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var unitLabel : UILabel = {
        let lab = UILabel()
        lab.text = "厘米"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    
    lazy var rulerView : TTScrollRulerView = {
        let vi = TTScrollRulerView.init(frame: CGRect.init(x: kFitWidth(183), y: self.selfHeight-kFitWidth(172), width: kFitWidth(200), height: kFitWidth(343)))
        vi.backgroundColor = .clear
        vi.rulerBackgroundColor = .clear
        return vi
    }()
    lazy var topCoverImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ruler_cover_top")
        
        return img
    }()
    lazy var bottomCoverImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ruler_cover_bottom")
        
        return img
    }()
}
extension QuestionnaireHeightVM{
    func initUI(){
        addSubview(titleLabel)
        addSubview(numberLabel)
//        addSubview(unitLabel)
        addSubview(rulerView)
        rulerView.addSubview(topCoverImgView)
        rulerView.addSubview(bottomCoverImgView)
        
        rulerView.rulerDelegate = self
        rulerView.rulerDirection = .vertical
        rulerView.rulerFace = .down_right
        rulerView.lockMax = 300
        rulerView.lockMin = 30
        rulerView.pointerBackgroundColor = .THEME
        rulerView.h_height = Float(kFitWidth(36))
        rulerView.m_height = Float(kFitWidth(24))
        rulerView.customRuler(with: customColorMake(217.0/255.0, 217.0/255.0, 217.0/255.0), numColor: WHColorWithAlpha(colorStr: "000000", alpha: 0.15), scrollEnable: true)
        rulerView.unitValue = 1
        rulerView.classicRuler()
        rulerView.scroll(toValue: 160, animation: false)
        
        rulerView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: kFitWidth(342))
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
            make.height.equalTo(kFitWidth(72))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(59))
            make.top.equalTo(kFitWidth(322))
            make.height.equalTo(kFitWidth(40))
//            make.width.equalTo(kFitWidth(64))
        }
//        unitLabel.snp.makeConstraints { make in
//            make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(6))
////            make.top.equalTo(kFitWidth(346))
//            make.bottom.equalTo(numberLabel.snp.bottom)
//        }
        topCoverImgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(kFitWidth(100))
            make.width.equalTo(kFitWidth(80))
            make.height.equalTo(kFitWidth(64))
        }
        bottomCoverImgView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(kFitWidth(100))
            make.width.equalTo(kFitWidth(80))
            make.height.equalTo(kFitWidth(64))
        }
        
    }
}

extension QuestionnaireHeightVM:rulerDelegate{
    func ruler(with value: Int) {
        DLLog(message: "\(value)")
        numberLabel.text = "\(value)"
        
        let numString = NSMutableAttributedString.init(string: "\(value)")
        let totalStep = NSMutableAttributedString.init(string: "厘米")
        numString.yy_font = .systemFont(ofSize: 40, weight: .medium)
        numString.yy_color = .THEME
        
        numString.append(totalStep)
        numberLabel.attributedText = numString
        
        QuestinonaireMsgModel.shared.height = "\(value)"
        DLLog(message: "身高：\(QuestinonaireMsgModel.shared.height)")
    }
}
