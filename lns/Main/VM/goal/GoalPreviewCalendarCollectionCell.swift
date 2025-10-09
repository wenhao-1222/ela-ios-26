//
//  GoalPreviewCalendarCollectionCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/3.
//



class GoalPreviewCalendarCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        initUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GoalPreviewCalendarCollectionCell{
    func initUI() {
        
    }
}
