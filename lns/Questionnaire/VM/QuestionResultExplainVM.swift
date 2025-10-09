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
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(24), y: kFitWidth(112), width: kFitWidth(340), height: kFitWidth(80)))
        if isIpad(){
            lab.frame = CGRect.init(x: kFitWidth(24), y: kFitWidth(112), width: SCREEN_WIDHT-kFitWidth(48), height: kFitWidth(80))
        }
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 22, weight: .medium)
        lab.text = "接下来我们将根据您的目标计算缺口/盈余，和营养素的配比。"
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
//        lab.textAlignment = .center
        
        return lab
    }()
}

extension QuestionResultExplainVM{
    func initUI() {
        addSubview(titleLabel)
        
//        titleLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(28))
//            make.right.equalTo(kFitWidth(-28))
//            make.width.equalTo(kFitWidth(320))
////            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(112))
//        }
    }
}
