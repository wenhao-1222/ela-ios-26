//
//  BindOtherAccountItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/15.
//

import Foundation

class BindOtherAccountItemVM: UIButton {
    
    let selfHeight = kFitWidth(56)
    var tapBlock:(()->())?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        
        return vi
    }()
    lazy var leftIconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var detailLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_BG_BLACK_045//WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "plan_arrow_gray")
        
        return img
    }()
    
}
extension BindOtherAccountItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        bgView.backgroundColor = .COLOR_BG_BLACK_04//WHColorWithAlpha(colorStr: "000000", alpha: 0.02)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = .COLOR_BG_WHITE
    }
    override var isHighlighted: Bool {
       didSet {
           if isHighlighted {
               // 当按钮被高亮时，更改按钮的状态，如颜色等
               bgView.backgroundColor = .COLOR_BG_BLACK_04//WHColorWithAlpha(colorStr: "000000", alpha: 0.02)
           } else {
               // 当按钮高亮状态结束时，恢复按钮的原始状态
               bgView.backgroundColor = .COLOR_BG_WHITE
           }
       }
   }
    
    @objc func tapAction() {
         if self.tapBlock != nil{
             self.tapBlock!()
         }
        bgView.backgroundColor = .COLOR_BG_WHITE
     }
}

extension BindOtherAccountItemVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(leftIconImgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(detailLabel)
        bgView.addSubview(arrowImgView)
        
        setConstrait()
    }
    func setConstrait() {
        leftIconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(48))
            make.centerY.lessThanOrEqualToSuperview()
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        detailLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-40))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}

