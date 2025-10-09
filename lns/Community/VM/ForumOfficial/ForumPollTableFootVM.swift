//
//  ForumPollTableFootVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/20.
//


class ForumPollTableFootVM: UIView {
    
    var selfHeight = kFitWidth(76)//kFitWidth(40)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
    lazy var leftTipsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "点击上方选项，选择你的观点"
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.text = ""
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var submitButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("投票", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.isEnabled = false
        btn.enablePressEffect()
        
        return btn
    }()
}

extension ForumPollTableFootVM{
    func initUI() {
//        addSubview(lineView)
        addSubview(leftTipsLabel)
        addSubview(numberLabel)
        addSubview(submitButton)
//        
//        lineView.snp.makeConstraints { make in
//            make.left.bottom.width.equalToSuperview()
//            make.height.equalTo(kFitWidth(1))
//        }
        numberLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(5))
        }
        leftTipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(5))
        }
        submitButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(44))
//            make.top.equalTo(leftTipsLabel.snp.bottom).offset(kFitWidth(5))
            make.bottom.equalTo(kFitWidth(-2))
        }
    }
}
