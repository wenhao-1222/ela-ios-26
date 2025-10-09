//
//  FoodsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation

class FoodsTableViewCell: UITableViewCell {
    
    var isSelect = false
    var choiceBlock:((Bool)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var detailLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
//        lab.adjustsFontSizeToFitWidth = true
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var selectedImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "protocal_normal_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(choiceAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_GREY
         
        return vi
    }()
}

extension FoodsTableViewCell{
    func updateUI(dict:NSDictionary){
        nameLabel.text = "\(dict["fname"]as? String ?? "")"
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: dict)
        detailLabel.text = "\(dict["calories"]as? String ?? "")千卡/\(specDefault["specNum"]as? String ?? "")\(specDefault["specName"]as? String ?? "")"
    }
    @objc func choiceAction() {
        self.isSelect = !self.isSelect
        if self.choiceBlock != nil{
            self.choiceBlock!(self.isSelect)
        }
        if self.isSelect{
            selectedImgView.setImgLocal(imgName: "protocal_selected_icon")
        }else{
            selectedImgView.setImgLocal(imgName: "protocal_normal_icon")
        }
    }
}
extension FoodsTableViewCell{
    func initUI(){
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(selectedImgView)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait(){
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.top.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-60))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(kFitWidth(46))
            make.bottom.equalTo(kFitWidth(-16))
        }
        selectedImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualTo(nameLabel)
            make.width.height.equalTo(kFitWidth(20))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.right.equalTo(kFitWidth(-20))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(0.3))
        }
    }
}
