//
//  MallOrderAfterSaleSubmitTopCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/22.
//


class MallOrderAfterSaleSubmitTopCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F2
        
        return vi
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "mall_order_success_icon")
        
        return img
    }()
    lazy var successLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "提交成功"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .semibold)
        
        return lab
    }()
    lazy var successLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "可以在个人中心“我的订单”查看"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
}

extension MallOrderAfterSaleSubmitTopCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(iconImgView)
        bgView.addSubview(successLab)
        bgView.addSubview(successLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(247))
        }
        iconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(88))
            make.width.height.equalTo(kFitWidth(55))
        }
        successLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(iconImgView.snp.bottom).offset(kFitWidth(20))
        }
        successLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(successLab.snp.bottom).offset(kFitWidth(6))
        }
    }
}
