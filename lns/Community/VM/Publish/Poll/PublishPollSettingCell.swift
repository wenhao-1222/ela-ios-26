//
//  PublishPollSettingCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/12.
//


class PublishPollSettingCell: UITableViewCell {
    
    var tapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var leftLabel: UILabel = {
        let lab = UILabel()
        lab.text = "图文投票"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var switchButton: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-SwitchButton().selfWidth, y: (kFitWidth(48)-SwitchButton().selfHeight)*0.5, width: 0, height: 0))
        
        return btn
    }()
}

extension PublishPollSettingCell{
    func initUI() {
        contentView.addSubview(leftLabel)
        contentView.addSubview(switchButton)
        
        setConstrait()
    }
    func setConstrait() {
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(-10))
            make.height.equalTo(kFitWidth(20))
        }
    }
}
