//
//  HabitExchangeTipsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2026/1/6.
//


class HabitExchangeTipsTableViewCell: UITableViewCell {
    
    let whiteViewWidth = SCREEN_WIDHT-kFitWidth(32)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.isSkeletonable = true
        contentView.isSkeletonable = true
        initUI()
    }
}

extension HabitExchangeTipsTableViewCell{
    func initUI() {
        
    }
}
