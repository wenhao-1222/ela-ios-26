//
//  CoursePayResultBottomVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/22.
//


class CoursePayResultBottomVM : UIView{
    
    var selfHeight = kFitWidth(66)
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        if WHUtils().getBottomSafeAreaHeight() > 0 {
            selfHeight = kFitWidth(55) + WHUtils().getBottomSafeAreaHeight()
        }
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var showButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("查看课程", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.backgroundColor = .THEME
        
        btn.enablePressEffect()
        
        return btn
    }()
}

extension CoursePayResultBottomVM{
    func initUI() {
        addSubview(showButton)
        
        showButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(57))
            make.right.equalTo(kFitWidth(-57))
            make.height.equalTo(kFitWidth(44))
            make.top.equalTo(kFitWidth(11))
        }
    }
}
