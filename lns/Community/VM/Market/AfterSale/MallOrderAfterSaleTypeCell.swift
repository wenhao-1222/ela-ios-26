//
//  MallOrderAfterSaleTypeCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/19.
//


class MallOrderAfterSaleTypeCell: UITableViewCell {
    
    var typeBlock:((Int)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = .COLOR_BG_F2
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "请选择售后类型"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return lab
    }()
    lazy var returnButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("退货退款", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_20, for: .disabled)
        btn.setTitleColor(.white, for: .selected)
        btn.setBackgroundImage(createImageWithColor(color: .white), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .selected)
        btn.setTitleColor(.white, for: .selected)
        btn.layer.cornerRadius = kFitWidth(18)
        btn.layer.borderWidth = kFitWidth(1)
        btn.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.cgColor
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(returnTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var changeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("换货", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_20, for: .disabled)
        btn.setTitleColor(.white, for: .selected)
        btn.setBackgroundImage(createImageWithColor(color: .white), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .selected)
        btn.setTitleColor(.white, for: .selected)
        btn.layer.cornerRadius = kFitWidth(18)
        btn.layer.borderWidth = kFitWidth(1)
        btn.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.cgColor
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(changeTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension MallOrderAfterSaleTypeCell{
    func updateUI(type:Int) {
        if type == 0 {
            returnButton.isEnabled = false
            changeButton.isEnabled = false
            returnButton.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
            changeButton.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
        }
    }
    @objc func returnTapAction() {
        if returnButton.isSelected == true{
            return
        }
        returnButton.isSelected = true
        changeButton.isSelected = false
        
        returnButton.layer.borderColor = UIColor.clear.cgColor
        changeButton.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.cgColor
        self.typeBlock?(1)
    }
    @objc func changeTapAction() {
        if changeButton.isSelected == true{
            return
        }
        returnButton.isSelected = false
        changeButton.isSelected = true
        
        changeButton.layer.borderColor = UIColor.clear.cgColor
        returnButton.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_50.cgColor
        self.typeBlock?(2)
    }
}

extension MallOrderAfterSaleTypeCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(returnButton)
        bgView.addSubview(changeButton)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(kFitWidth(11))
        }
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        returnButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(53))
            make.height.equalTo(kFitWidth(36))
            make.width.equalTo(SCREEN_WIDHT*0.5-kFitWidth(22))
            make.bottom.equalTo(kFitWidth(-4))
        }
        changeButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.width.height.equalTo(returnButton)
        }
    }
}
