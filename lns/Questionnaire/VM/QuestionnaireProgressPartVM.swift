//
//  QuestionnaireProgressPartVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/2.
//

import Foundation
import UIKit

class QuestionnaireProgressPartVM: UIView {
    
    let selfHeight = kFitWidth(44)
    let progressWidthPerStep = kFitWidth(42.5)
    
    var backBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backImgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "back_arrow")
        img.isHidden = true
        return img
    }()
    lazy var backTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var backArrowButton: NaviBackButton = {
        let btn = NaviBackButton.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(44), height: kFitWidth(44)))
        btn.tapBlock = {()in
            self.backAction()
        }
        return btn
    }()
    lazy var bottomView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var progressView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.85)
        
        return vi
    }()
    lazy var progressLabel : YYLabel = {
        let lab = YYLabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.85)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        let step = NSMutableAttributedString.init(string: "1")
        let totalStep = NSMutableAttributedString.init(string: "/6")
        step.yy_font = .systemFont(ofSize: 20, weight: .medium)
        
        step.append(totalStep)
        lab.attributedText = step
        
        return lab
    }()
}


extension QuestionnaireProgressPartVM{
    func setProgressStep(step:Int){
        let stepString = NSMutableAttributedString.init(string: "\(step)")
        let totalStep = NSMutableAttributedString.init(string: "/6")
        stepString.yy_font = .systemFont(ofSize: 20, weight: .medium)
        
        stepString.append(totalStep)
        progressLabel.attributedText = stepString
        
//        if step > 1 {
//            backImgView.isHidden = false
//            backTapView.isHidden = false
//        }else{
//            backImgView.isHidden = true
//            backTapView.isHidden = true
//        }
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.45) {
            self.progressView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.top.bottom.equalToSuperview()
                make.width.equalTo(self.progressWidthPerStep*CGFloat(step))
            }
            self.layoutIfNeeded()
        }
        
    }
    @objc func backAction(){
        if self.backBlock != nil{
            self.backBlock!()
        }
    }
}

extension QuestionnaireProgressPartVM{
    func initUI(){
        addSubview(backImgView)
        addSubview(backTapView)
        addSubview(backArrowButton)
        addSubview(bottomView)
        bottomView.addSubview(progressView)
        addSubview(progressLabel)
        
        setConstrait()
    }
    func setConstrait() {
        backImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        backTapView.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(kFitWidth(48))
        }
        bottomView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(44))
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(2))
            make.width.equalTo(kFitWidth(255))
        }
        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(progressWidthPerStep)
        }
        progressLabel.snp.makeConstraints { make in
            make.left.equalTo(bottomView.snp.right).offset(kFitWidth(28))
            make.top.equalTo(kFitWidth(10))
        }
    }
}

