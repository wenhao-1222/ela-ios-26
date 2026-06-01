//
//  MaterialItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/11.
//

import Foundation
import UIKit

class MaterialItemVM: UIButton {
    
    let selfHeight = kFitWidth(56)
    
    var tapBlock:(()->())?
    var switchBlock:((Bool)->())?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        adjustsImageWhenHighlighted = false
        
        initUI()

        addTarget(self, action: #selector(touchDownAction), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchCancelAction), for: [.touchUpOutside, .touchCancel, .touchDragExit])
        addTarget(self, action: #selector(touchUpInsideAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        vi.isUserInteractionEnabled = false
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        
        return vi
    }()
    lazy var leftLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214//WHColor_16(colorStr: "222222")
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
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
    lazy var arrowImgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = false
//        img.setImgLocal(imgName: "mine_func_arrow")
        img.setImgLocal(imgName: "plan_arrow_gray")
        
        return img
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(16)
        img.clipsToBounds = true
        img.backgroundColor = .THEME
        img.isUserInteractionEnabled = false
        img.isHidden = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var avatarStatusLabel: UILabel = {
        let lab = UILabel()
        lab.text = "审核中"
        lab.font = .systemFont(ofSize: 5, weight: .regular)
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_WHITE
        lab.backgroundColor = UIColor(white: 0, alpha: 0.5)
        lab.isHidden = true
        return lab
    }()
    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var switchButton: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-SwitchButton().selfWidth, y: (selfHeight-SwitchButton().selfHeight)*0.5, width: 0, height: 0))
        btn.isHidden = true
        
        return btn
    }()
    lazy var switchBtn: UISwitch = {
        let btn = UISwitch()
        btn.isHidden = true
        btn.onTintColor = .THEME
        btn.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return btn
    }()
}

extension MaterialItemVM{
    @objc private func touchDownAction() {
        setPressedBackground(true)
    }

    @objc private func touchCancelAction() {
        setPressedBackground(false)
    }

    @objc private func touchUpInsideAction() {
        setPressedBackground(false)
        tapBlock?()
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        print("isOn =", sender.isOn)
        self.switchBlock?(sender.isOn)
    }

    private func setPressedBackground(_ isPressed: Bool) {
        bgView.backgroundColor = isPressed ? .COLOR_BG_BLACK_04 : .COLOR_CARD_BG_WHITE
    }
}

extension MaterialItemVM{
    func initUI(){
        addSubview(bgView)
        addSubview(leftLabel)
        addSubview(arrowImgView)
        addSubview(headImgView)
        headImgView.addSubview(avatarStatusLabel)
        addSubview(detailLabel)
        addSubview(redView)
        addSubview(switchButton)
        addSubview(switchBtn)
        
        setConstrait()
    }
    func setConstrait() {
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        redView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-33))
            make.width.height.equalTo(kFitWidth(5))
            make.centerY.lessThanOrEqualToSuperview()
        }
        headImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-40))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(32))
        }
        
        avatarStatusLabel.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(10))
        }
        detailLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-40))
            make.centerY.lessThanOrEqualToSuperview()
        }
        switchBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}

extension MaterialItemVM{
    override var isHighlighted: Bool {
       didSet {
           setPressedBackground(isHighlighted)
       }
   }

    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                setPressedBackground(false)
            }
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            setPressedBackground(false)
        }
    }
}
