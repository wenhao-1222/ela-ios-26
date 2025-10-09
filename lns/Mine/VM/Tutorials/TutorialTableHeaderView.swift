//
//  TutorialTableHeaderView.swift
//  lns
//
//  Created by LNS2 on 2024/6/4.
//

import Foundation
import UIKit

class TutorialTableHeaderView: UIView {
    
    var selfHeight = kFitWidth(56)
    var tapBlock:(()->())?
    var isFold = true
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var bottomView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.6)
        return vi
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "tutorial_arrow_down")
        img.isUserInteractionEnabled = true
        
        return img
    }()
}

extension TutorialTableHeaderView{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        self.bottomView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.bottomView.backgroundColor = .white//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.6)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.bottomView.backgroundColor = .white//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.6)
    }

   @objc func tapAction() {
       self.bottomView.backgroundColor = .white// WHColorWithAlpha(colorStr: "007AFF", alpha: 0.6)
        if self.tapBlock != nil{
            self.isFold = !self.isFold
            self.tapBlock!()
        }
    }
}

extension TutorialTableHeaderView{
    func udpateUI(titleStr:String,index:Int) {
        numberLabel.text = "\(index+1)、"
//        numberLabel.text = ""
        titleLabel.text = titleStr
        
        if index == 3{
            self.selfHeight = kFitWidth(66)
            self.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.selfHeight)
            
            numberLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(kFitWidth(16))
            }
            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(4))
                make.top.equalTo(numberLabel)
            }
        }else if index == 9 && UserInfoModel.shared.widgetNewFuncRead == false{
            titleLabel.textColor = .THEME
            numberLabel.textColor = .THEME
        }
    }
    func updateFoldStatus() {
        if self.isFold == true{
            arrowImgView.setImgLocal(imgName: "tutorial_arrow_down")
        }else{
            arrowImgView.setImgLocal(imgName: "tutorial_arrow_up")
        }
    }
}
extension TutorialTableHeaderView{
    func initUI(){
        addSubview(bottomView)
        addSubview(numberLabel)
        addSubview(titleLabel)
        addSubview(arrowImgView)
        
        setConstrait()
    }
    func setConstrait() {
        bottomView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(2))
            make.bottom.equalTo(kFitWidth(-2))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(4))
            make.top.equalTo(numberLabel)
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
    }
}
