//
//  AddressListBottomVM.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//


class AddressListBottomVM: UIView {
    
    var selfHeight = kFitWidth(56)+WHUtils().getBottomSafeAreaHeight()
    
    override init(frame:CGRect){
        if WHUtils().getBottomSafeAreaHeight() == 0 {
            selfHeight += kFitWidth(10)
        }
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitle("新增地址", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_C4C4C4), for: .disabled)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        
        btn.enablePressEffect()
        
        return btn
    }()
}

extension AddressListBottomVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(addButton)
        
        whiteView.addShadow()
        
        addButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(22))
            make.right.equalTo(kFitWidth(-22))
            make.top.equalTo(kFitWidth(11))
            make.height.equalTo(kFitWidth(44))
        }
    }
}
