//
//  CancelAccountItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/16.
//

import Foundation
import UIKit

class CancelAccountItemVM: UIView {
    
    let selfHeight = kFitWidth(56)
    var tapBlock: (()->())?
    var isSelect = false
    
    required init?(coder: NSCoder) {
        fatalError("CancelAccountItemVM  required init?(coder: NSCoder)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var leftImgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "cancel_account_normal")
        
        return img
    }()
    lazy var contenLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    
}

extension CancelAccountItemVM{
    func initUI() {
        addSubview(leftImgView)
        addSubview(contenLabel)
        
        setConstrait()
    }
    func setConstrait() {
        leftImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(24))
        }
        contenLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(52))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-16))
        }
    }
}

extension CancelAccountItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .clear
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .clear
    }
    @objc func tapAction() {
        isSelect = !isSelect
//        if isSelect{
//            leftImgView.setImgLocal(imgName: "cancel_account_selected")
//        }else{
//            leftImgView.setImgLocal(imgName: "cancel_account_normal")
//        }
        
        leftImgView.setCheckState(isSelect,
                                  checkedImageName: "cancel_account_selected",
                                  uncheckedImageName: "cancel_account_normal")
        
         if self.tapBlock != nil{
             self.tapBlock!()
         }
        self.backgroundColor = .clear
     }
}
