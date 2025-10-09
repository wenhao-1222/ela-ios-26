//
//  QuestionnaireSurveyBottomVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/25.
//

import Foundation
import UIKit

class QuestionnaireSurveyBottomVM: UIView {
    
    let selfHeight = WHUtils().getBottomSafeAreaHeight()+kFitWidth(120)
    
    var nextBlock:(()->())?
    var preBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = WHColor_RGB(r: 38.0, g: 40.0, b: 49.0)
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(nextBtnAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var previBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("上一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.isHidden = true
        
        btn.addTarget(self, action: #selector(preBtnAction), for: .touchUpInside)
        
        
        return btn
    }()
}

extension QuestionnaireSurveyBottomVM{
    @objc func nextBtnAction(){
        if self.nextBlock != nil{
            self.nextBlock!()
        }
    }
    @objc func preBtnAction() {
        if self.preBlock != nil{
            self.preBlock!()
        }
    }
    func showPreBtn(step:Int) {
        if step == 0{
            previBtn.isHidden = true
            nextBtn.snp.remakeConstraints { make in
                make.centerX.lessThanOrEqualToSuperview()
                make.width.equalTo(kFitWidth(343))
                make.height.equalTo(kFitWidth(48))
                make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight()+kFitWidth(20)))
            }
        }else{
            previBtn.isHidden = false
            nextBtn.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-16))
                make.width.equalTo(kFitWidth(160))
                make.height.equalTo(kFitWidth(48))
                make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight()+kFitWidth(20)))
            }
        }
    }
}
extension QuestionnaireSurveyBottomVM{
    func initUI(){
        addSubview(nextBtn)
        addSubview(previBtn)
        
        setConstrait()
    }
    func setConstrait(){
        nextBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight()+kFitWidth(20)))
        }
        previBtn.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(160))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight()+kFitWidth(20)))
        }
    }
}
