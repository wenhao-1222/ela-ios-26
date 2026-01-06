//
//  HabitRankListSectionVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/6.
//   habit_rank_up_icon   habit_rank_down_icon


class HabitRankListSectionVM: UIView {
    
    let selfHeight = kFitWidth(60)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var leftImgView: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var rightImgView: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var centerLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()
}

extension HabitRankListSectionVM{
    func updateUI(isUp:Bool) {
        centerLabel.text = isUp ? "段位上升" : "段位下降"
        leftImgView.image = isUp ? UIImage(named: "habit_rank_up_icon") : UIImage(named: "habit_rank_down_icon")
        rightImgView.image = isUp ? UIImage(named: "habit_rank_up_icon") : UIImage(named: "habit_rank_down_icon")
    }
}

extension HabitRankListSectionVM{
    func initUI() {
        addSubview(centerLabel)
        addSubview(leftImgView)
        addSubview(rightImgView)
        
        setConstrait()
    }
    func setConstrait() {
        centerLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
        leftImgView.snp.makeConstraints { make in
            make.right.equalTo(centerLabel.snp.left).offset(kFitWidth(-4))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        rightImgView.snp.makeConstraints { make in
            make.left.equalTo(centerLabel.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }
}
