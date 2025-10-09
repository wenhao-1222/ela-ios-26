//
//  ForumCommentListTableView.swift
//  lns
//
//  Created by Elavatine on 2024/11/14.
//

class ForumCommentListTableView: UITableView {
    var reloadCompletion: (() -> Void)?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.separatorStyle = .none
        self.showsVerticalScrollIndicator = false
        self.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
            UITableView.appearance().isPrefetchingEnabled = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadCompletion?()
    }
}
