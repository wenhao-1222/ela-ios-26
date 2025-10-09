//
//  QuestionDaylyMealsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation

class QuestionDaylyMealsTableViewCell: UITableViewCell {
    
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
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_GREY
        
        return vi
    }()
}

extension QuestionDaylyMealsTableViewCell{
    func updateUI(dict:NSDictionary,isSelected:Bool) {
        if isSelected{
            selectedImgView.setImgLocal(imgName: "protocal_selected_icon")
            tipsLabel.text = "\(dict["detail"]as? String ?? "")"
        }else{
            selectedImgView.setImgLocal(imgName: "protocal_normal_icon")
            tipsLabel.text = ""
        }
        contentLabel.text = "\(dict["name"]as? String ?? "")"
        
    }
}
extension QuestionDaylyMealsTableViewCell{
    func initUI() {
        contentView.addSubview(selectedImgView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(tipsLabel)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        selectedImgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(17))
            make.left.equalTo(kFitWidth(12))
            make.width.height.equalTo(kFitWidth(22))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalTo(kFitWidth(12))
            make.height.equalTo(kFitWidth(32))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(46))
            make.bottom.equalTo(kFitWidth(-10))
            make.right.equalTo(kFitWidth(-20))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(0.6))
        }
    }
}
