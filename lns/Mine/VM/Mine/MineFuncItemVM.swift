//
//  MineFuncItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/11.
//

import Foundation

class MineFuncItemVM: UIButton {
    
    let selfHeight = kFitWidth(56)
    var tapBlock:(()->())?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
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
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var leftIconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var detailLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var redView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .systemRed//.THEME
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "mine_func_arrow")
        
        return img
    }()
    lazy var unreadNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.layer.cornerRadius = kFitWidth(9)
        lab.clipsToBounds = true
        lab.backgroundColor = .systemRed
        lab.textAlignment = .center
        lab.isHidden = true

        return lab
    }()
    
}
extension MineFuncItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        TouchGenerator.shared.touchGenerator()
        bgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.02)
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
               bgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.02)
           } else {
               // 当按钮高亮状态结束时，恢复按钮的原始状态
               bgView.backgroundColor = .white
           }
       }
   }
    
    @objc func tapAction() {
         if self.tapBlock != nil{
             self.tapBlock!()
         }
        bgView.backgroundColor = .white
     }
}

extension MineFuncItemVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(leftIconImgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(detailLabel)
        bgView.addSubview(arrowImgView)
        bgView.addSubview(redView)
        bgView.addSubview(unreadNumLabel)
        
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
        redView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-33))
            make.width.height.equalTo(kFitWidth(5))
            make.centerY.lessThanOrEqualToSuperview()
        }
        unreadNumLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-33))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(18))
        }
    }
}

