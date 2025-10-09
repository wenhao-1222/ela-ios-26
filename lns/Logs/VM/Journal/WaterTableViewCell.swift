//
//  WaterTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/6/25.
//


class WaterTableViewCell: UITableViewCell {
    
    var addBlock:(()->())?
    var totalBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = UIFont().DDInFontSemiBold(fontSize: 16)//.systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
//    lazy var totalTapView: UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .clear
//        vi.isUserInteractionEnabled = true
//        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(totalTapAction))
//        vi.addGestureRecognizer(tap)
//        
//        return vi
//    }()
    
}

extension WaterTableViewCell{
    func updateUI(num:String) {
        var numAttr = NSMutableAttributedString(string: "\(num)")
        let unitAttr = NSMutableAttributedString(string: " ml")
        unitAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
        unitAttr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        
        if num.intValue <= 0 {
            numAttr = NSMutableAttributedString(string: "0")
        }
        numAttr.append(unitAttr)
        numberLabel.attributedText = numAttr
    }
    @objc func totalTapAction(){
        if self.totalBlock != nil{
            self.totalBlock!()
        }
    }
}

extension WaterTableViewCell{
    func initUI()  {
        contentView.addSubview(whiteView)
        contentView.addSubview(numberLabel)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(-10))
        }
    }
}
