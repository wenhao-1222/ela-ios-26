//
//  HabitRankListEmptyVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//



class HabitRankListEmptyVM: UIView {
    
    let selfHeight = kFitWidth(60)
    
    var togoRecordBlock:(()->())?
    
    override init(frame:CGRect){
//        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        super.init(frame: frame)
        self.isHidden = true
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var emptyImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_ranklist_empty_img")
//        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var emptyLabel: UILabel = {
        let lab = UILabel()
        lab.text = "完成任意目标后解锁"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 21, weight: .semibold)
        
        return lab
    }()
    lazy var recordButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("去记录", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = .THEME
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(recordTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension HabitRankListEmptyVM{
    @objc func recordTapAction() {
        self.togoRecordBlock?()
    }
}

extension HabitRankListEmptyVM{
    func initUI() {
        addSubview(emptyImgView)
        addSubview(emptyLabel)
        addSubview(recordButton)
        
        setConstrait()
    }
    func setConstrait() {
        emptyImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(222))
            make.center.lessThanOrEqualToSuperview()
        }
        recordButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(210))
            make.height.equalTo(kFitWidth(44))
            make.top.equalTo(emptyLabel.snp.bottom).offset(kFitWidth(50))
        }
    }
}
