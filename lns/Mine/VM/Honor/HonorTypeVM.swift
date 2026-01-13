//
//  HonorTypeVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//


import Foundation

class HonorTypeVM: UIView {
    
    let selfHeight = kFitWidth(50)
    let fontSelect = UIFont.systemFont(ofSize: 16, weight: .medium)
    let fontNormal = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    var tapBlock:((CGFloat)->())?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(12)
        view.clipsToBounds = true
        
        return view
    }()
    lazy var iconButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("徽章", for: .normal)
        btn.titleLabel?.font = fontSelect
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.isSelected = true
        
        btn.addTarget(self, action: #selector(leftTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var donateButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("捐赠", for: .normal)
        btn.titleLabel?.font = fontNormal
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        
        btn.addTarget(self, action: #selector(rightTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        
        return vi
    }()
}

extension HonorTypeVM{
    @objc func leftTapAction() {
        if iconButton.isSelected{
            return
        }
        iconButton.isSelected = true
        donateButton.isSelected = false
        self.tapBlock?(0)
        let lineCenter = self.lineView.center
        UIView.animate(withDuration: 0.25) {
            self.lineView.center = CGPoint(x: self.iconButton.center.x, y: lineCenter.y)
        }
    }
    @objc func rightTapAction() {
        if donateButton.isSelected{
            return
        }
        iconButton.isSelected = false
        donateButton.isSelected = true
        self.tapBlock?(1)
        let lineCenter = self.lineView.center
        UIView.animate(withDuration: 0.25) {
            self.lineView.center = CGPoint(x: self.donateButton.center.x, y: lineCenter.y)
        }
    }
}

extension HonorTypeVM{
    func initUI() {
        addSubview(bgWhiteView)
        addSubview(iconButton)
        addSubview(donateButton)
        addSubview(lineView)
     
        setConstrait()
    }
    func setConstrait() {
        bgWhiteView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.bottom.equalTo(kFitWidth(12))
        }
        iconButton.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
            make.right.equalTo(-SCREEN_WIDHT*0.5-kFitWidth(50))
            make.left.equalTo(kFitWidth(32))
        }
        donateButton.snp.makeConstraints { make in
            make.left.equalTo(SCREEN_WIDHT*0.5+kFitWidth(50))
            make.right.equalTo(kFitWidth(-32))
            make.top.height.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(iconButton)
            make.width.equalTo(kFitWidth(26))
            make.height.equalTo(kFitWidth(4))
            make.bottom.equalToSuperview()
        }
    }
}
