//
//  MallPaySuccessBottomCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/16.
//



class MallPaySuccessBottomCell: UITableViewCell {
    
    var foldBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_WHITE
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var priceLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.text = "实际总价："
        
        return lab
    }()
    lazy var priceLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 20, weight: .semibold)
        return lab
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(10), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(1)))
        
        return vi
    }()
    lazy var ifFoldButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("查看全部订单信息", for: .normal)
//        btn.setImage(UIImage(named: "mall_order_detail_arrow_down"), for: .normal)
//        btn.setImage(UIImage(named: "mall_order_detail_arrow_top"), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.isHidden = true
        
        return btn
    }()
    lazy var isFoldImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "mall_order_detail_arrow_down")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        return img
    }()
    lazy var isFoldTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        vi.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(foldTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}
extension MallPaySuccessBottomCell{
    func updateUI(money:String) {
        priceLabel.text = "¥ \(money)"
    }
    func updateStrait(hiddenDottedLine:Bool) {
        dottedLineView.isHidden = hiddenDottedLine
        
        if hiddenDottedLine{
            priceLabel.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-16))
                make.top.equalTo(kFitWidth(20))
                make.bottom.equalTo(kFitWidth(-51))
            }
        }else{
            priceLabel.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-16))
                make.top.equalTo(kFitWidth(40))
                make.bottom.equalTo(kFitWidth(-51))
            }
        }
    }
    func setFoldStatus(isFold:Bool) {
        ifFoldButton.isHidden = false
        isFoldImgView.isHidden = false
        isFoldTapView.isHidden = false
        ifFoldButton.isSelected = !isFold
        
        if isFold{
            isFoldImgView.setImgLocal(imgName: "mall_order_detail_arrow_down")
            ifFoldButton.setTitle("查看全部订单信息", for: .normal)
        }else{
            isFoldImgView.setImgLocal(imgName: "mall_order_detail_arrow_top")
            ifFoldButton.setTitle("收起订单信息", for: .normal)
        }
    }
    @objc func foldTapAction(){
        self.foldBlock?()
    }
}

extension MallPaySuccessBottomCell{
    func initUI() {
        contentView.addSubview(priceLab)
        contentView.addSubview(priceLabel)
        contentView.addSubview(dottedLineView)
        contentView.addSubview(ifFoldButton)
        contentView.addSubview(isFoldImgView)
        contentView.addSubview(isFoldTapView)
        
        setConstrait()
//        ifFoldButton.imagePosition(style: .right, spacing: kFitWidth(2))
    }
    func setConstrait() {
        priceLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(40))
            make.bottom.equalTo(kFitWidth(-25))
        }
        priceLab.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(priceLabel)
            make.right.equalTo(priceLabel.snp.left).offset(kFitWidth(-8))
        }
        ifFoldButton.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(-10))
            make.height.equalTo(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(-15))
        }
        isFoldImgView.snp.makeConstraints { make in
            make.left.equalTo(ifFoldButton.snp.right).offset(kFitWidth(1))
            make.width.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(ifFoldButton)
        }
        isFoldTapView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(kFitWidth(50))
        }
    }
}
