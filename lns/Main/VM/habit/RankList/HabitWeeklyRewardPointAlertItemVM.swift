//
//  HabitWeeklyRewardPointAlertItemVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/21.
//


class HabitWeeklyRewardPointAlertItemVM: UIView {
    
    let selfHeight = kFitWidth(72)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return lab
    }()
    lazy var pointLabel: UILabel = {
        let lab = UILabel()
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension HabitWeeklyRewardPointAlertItemVM{
    func updateDict(dict:NSDictionary) {
        iconImgView.setImgLocal(imgName: "rank_\(dict.stringValueForKey(key: "tier"))_reached")
        nameLabel.text = dict.stringValueForKey(key: "tierName")
        
        let attr = NSMutableAttributedString(string: "周结算奖励：冠军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
           .font:UIFont.systemFont(ofSize: 12, weight: .regular)])
        attr.append(NSAttributedString(string: "+\(dict.stringValueForKey(key: "champion"))", attributes: [.foregroundColor:UIColor.THEME,
            .font:UIFont.systemFont(ofSize: 13, weight: .medium)]))
        attr.append(NSAttributedString(string: " 分｜亚军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
          .font:UIFont.systemFont(ofSize: 12, weight: .regular)]))
        attr.append(NSAttributedString(string: "+\(dict.stringValueForKey(key: "runnerUp"))", attributes: [.foregroundColor:UIColor.THEME,
             .font:UIFont.systemFont(ofSize: 13, weight: .medium)]))
        attr.append(NSAttributedString(string: " 分｜季军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
              .font:UIFont.systemFont(ofSize: 12, weight: .regular)]))
        attr.append(NSAttributedString(string: "+\(dict.stringValueForKey(key: "thirdPlace"))", attributes: [.foregroundColor:UIColor.THEME,
             .font:UIFont.systemFont(ofSize: 13, weight: .medium)]))
        attr.append(NSAttributedString(string: " 分", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
      .font:UIFont.systemFont(ofSize: 12, weight: .regular)]))
        pointLabel.attributedText = attr
    }
}

extension HabitWeeklyRewardPointAlertItemVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(nameLabel)
        addSubview(pointLabel)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32.5))
            make.top.equalTo(kFitWidth(8))
            make.width.equalTo(kFitWidth(19))
            make.height.equalTo(kFitWidth(25))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(6))
            make.centerY.lessThanOrEqualTo(iconImgView)
        }
        pointLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.bottom.equalTo(kFitWidth(-8))
            make.height.equalTo(kFitWidth(26))
            make.right.equalTo(kFitWidth(-32))
        }
    }
}
