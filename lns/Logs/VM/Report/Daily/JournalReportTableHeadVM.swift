//
//  JournalReportTableHeadVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//
class JournalReportTableHeadVM: UIView {
    
    let selfHeight = kFitWidth(56)
    
    override init(frame:CGRect){
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true // 防止内容撑出视图
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: UIView.noIntrinsicMetric, height: kFitWidth(56))
//    }

    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        lab.numberOfLines = 1
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    func initUI() {
        addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.lessThanOrEqualToSuperview().offset(-kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.bottom.lessThanOrEqualToSuperview().offset(-kFitWidth(10)) // 避免撑高
        }
    }
}
