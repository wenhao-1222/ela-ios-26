//
//  MallPayMsgCopyCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/18.
//

class MallPayMsgCopyCell: UITableViewCell {
    
    var copyBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_WHITE
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var leftTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var rightDetailLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.customLineHeight = 1.2
        lab.textAlignment = .right
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var copyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("复制", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        
        btn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        
        return btn
    }()
}

extension MallPayMsgCopyCell{
    @objc func copyAction() {
        self.copyBlock?()
    }
}

extension MallPayMsgCopyCell{
    func updateUI(leftTitle:String,detailString:String,type:String) {
        if type == "orderId"{
            leftTitleLabel.text = leftTitle
            rightDetailLabel.text = "\(detailString) |"
            leftTitleLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(kFitWidth(10))
            }
        }else{
            leftTitleLabel.text = "\(leftTitle)：\(detailString)"
            rightDetailLabel.text = ""
            leftTitleLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(kFitWidth(16))
                make.bottom.equalTo(kFitWidth(-20))
            }
        }
    }
}

extension MallPayMsgCopyCell{
    func initUI() {
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(rightDetailLabel)
        contentView.addSubview(copyButton)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
        }
        rightDetailLabel.snp.makeConstraints { make in
            make.right.equalTo(copyButton.snp.left).offset(kFitWidth(-1))//equalTo(kFitWidth(-16))
            make.left.equalTo(kFitWidth(110))
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(-4))
        }
        copyButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
//            make.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(38))
            make.height.equalTo(kFitWidth(50))
            make.centerY.lessThanOrEqualTo(leftTitleLabel)
        }
    }
}
