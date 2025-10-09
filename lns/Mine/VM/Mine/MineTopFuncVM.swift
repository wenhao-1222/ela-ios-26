//
//  MineTopFuncVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/11.
//

import Foundation

class MineTopFuncVM: UIButton {
    
    let selfHeight = kFitWidth(56)
    
    var tapBlock:(()->())?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: (SCREEN_WIDHT-kFitWidth(39))*0.5, height: selfHeight))
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
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: (SCREEN_WIDHT-kFitWidth(39))*0.5, height: selfHeight))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        
        return vi
    }()
    lazy var leftIconImg : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "mine_func_plan")
        
        return img
    }()
    lazy var textLab : UILabel = {
        let lab = UILabel()
        lab.text = "饮食计划"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    
    lazy var arrowIconImg : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "mine_top_func_arrow")
        
        return img
    }()
}

extension MineTopFuncVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        bgView.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.9)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = .white
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = .white
    }
    override var isHighlighted: Bool {
       didSet {
           if isHighlighted {
               // 当按钮被高亮时，更改按钮的状态，如颜色等
               bgView.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.9)
           } else {
               // 当按钮高亮状态结束时，恢复按钮的原始状态
               bgView.backgroundColor = .white
           }
       }
   }

   @objc func tapAction() {
       bgView.backgroundColor = .white
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension MineTopFuncVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(leftIconImg)
        bgView.addSubview(textLab)
        bgView.addSubview(arrowIconImg)
        
        bgView.addShadow()
        
        setConstrait()
    }
    func setConstrait() {
        leftIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualToSuperview()
        }
        textLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(44))
            make.centerY.lessThanOrEqualToSuperview()
        }
        arrowIconImg.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
    }
}
