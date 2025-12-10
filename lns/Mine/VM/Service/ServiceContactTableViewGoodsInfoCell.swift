//
//  ServiceContactTableViewGoodsInfoCell.swift
//  lns
//
//  Created by LNS2 on 2025/12/10.
//


class ServiceContactTableViewGoodsInfoCell: UITableViewCell {
    
    private var avatarRequestID = UUID()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarRequestID = UUID()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(19)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        
        return vi
    }()
    lazy var goodgBgView: UIView = {
        let vi = UIView()
        
        return vi
    }()
}


extension ServiceContactTableViewGoodsInfoCell{
    func initUI() {
        
    }
}
