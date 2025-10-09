//
//  QuestionLoseFatTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/3/26.
//

import Foundation

class QuestionLoseFatTableViewCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    lazy var selectedImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "protocal_normal_icon")
        
        return img
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var detailLabel : UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 3
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .white
        
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
//        vi.backgroundColor = .COLOR_LINE_GREY
        return vi
    }()
}

extension QuestionLoseFatTableViewCell{
    func updateUI(dict:NSDictionary,isSelected:Bool) {
        titleLabel.text = "\(dict["name"]as? String ?? "")"
        detailLabel.text = "\(dict["detail"]as? String ?? "")"
        
        if isSelected{
            selectedImgView.setImgLocal(imgName: "protocal_selected_icon")
        }else{
            selectedImgView.setImgLocal(imgName: "protocal_normal_icon")
        }
    }
}
extension QuestionLoseFatTableViewCell{
    func initUI(){
        addSubview(selectedImgView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        selectedImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(18))
            make.width.height.equalTo(kFitWidth(22))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(selectedImgView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(selectedImgView)
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(kFitWidth(50))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(0.5))
        }
    }
}
