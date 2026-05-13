//
//  QuestionResultExplainVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/29.
//


class QuestionResultExplainVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    var showTipsBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.text = "接下来我们将根据你的目标计算缺口/盈余，和营养素的配比。"
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
//        lab.textAlignment = .center
        
        return lab
    }()
}

extension QuestionResultExplainVM{
    func initUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            if isIpad() {
                make.top.equalTo(kFitWidth(112))
            } else {
                make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(110))
            }
        }
    }
}
