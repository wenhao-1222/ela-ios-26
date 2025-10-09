//
//  ServiceContactTableViewImageViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/6/12.
//

import Foundation

class ServiceContactTableViewImageViewCell: UITableViewCell {
    
    var imgWidth = kFitWidth(112)
    var imgHeight = kFitWidth(241)
    var imgGap = kFitWidth(6)
    
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
        img.layer.cornerRadius = kFitWidth(24)
        img.clipsToBounds = true
        
        return img
    }()
    
}

extension ServiceContactTableViewImageViewCell{
    func initUI() {
        
    }
}
