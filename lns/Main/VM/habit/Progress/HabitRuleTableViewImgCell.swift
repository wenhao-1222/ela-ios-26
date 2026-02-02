//
//  HabitRuleTableViewImgCell.swift
//  lns
//
//  Created by LNS2 on 2026/2/2.
//



class HabitRuleTableViewImgCell: FeedBackTableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
}

extension HabitRuleTableViewImgCell{
    func updateUI(imgString:String,bottomGap:CGFloat) {
        imgView.setImgLocal(imgName: imgString)
        imgView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalToSuperview()
            make.bottom.equalTo(kFitWidth(bottomGap))
//            make.right.equalTo(kFitWidth(-32))
            make.width.equalTo(kFitWidth(311))
            make.height.equalTo(kFitWidth(272))
        }
        setNeedsDisplay()
    }
}

extension HabitRuleTableViewImgCell{
    func initUI() {
        contentView.addSubview(imgView)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-32))
        }
    }
}

