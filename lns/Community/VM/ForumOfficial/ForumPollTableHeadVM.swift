//
//  ForumPollTableHeadVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/19.
//


class ForumPollTableHeadVM: UIView {
    
    let selfHeight = kFitWidth(40)
    
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
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "投票选项"
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
//    lazy var submitButton: UIButton = {
//        let btn = UIButton()
//        btn.setTitle("提交", for: .normal)
//        btn.setTitleColor(.THEME, for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
//        btn.isHidden = true
//        
//        return btn
//    }()
}

extension ForumPollTableHeadVM{
    func initUI() {
        addSubview(lineView)
        addSubview(titleLab)
//        addSubview(submitButton)
        
        lineView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-10))
        }
//        submitButton.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
//            make.centerY.lessThanOrEqualTo(titleLab)
//        }
    }
}
