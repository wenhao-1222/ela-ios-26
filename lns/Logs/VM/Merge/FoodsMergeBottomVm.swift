//
//  FoodsMergeBottomVm.swift
//  lns
//
//  Created by Elavatine on 2025/3/17.
//


class FoodsMergeBottomVm: UIView {
    
    let selfHeight = kFitWidth(55)+WHUtils().getBottomSafeAreaHeight()
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
        
        self.addShadow()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var saveButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(3.5), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(48))
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
}

extension FoodsMergeBottomVm{
    @objc func saveAction() {
        self.tapBlock?()
    }
}

extension FoodsMergeBottomVm{
    func initUI() {
        addSubview(saveButton)
        
    }
}

extension FoodsMergeBottomVm{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
