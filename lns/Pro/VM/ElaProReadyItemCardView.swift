//
//  ElaProReadyItemCardView.swift
//  lns
//
//  Created by LNS2 on 2026/4/17.
//

class ElaProReadyItemCardView: UIView {
    private let titleColor = UIColor.COLOR_TEXT_TITLE_0f1214
    private let descColor = UIColor.COLOR_TEXT_TITLE_0f1214_60
    
    private lazy var iconView: UIImageView = {
        let img = UIImageView()
//        img.backgroundColor = WHColor_16(colorStr: "CFCFD2")
//        img.layer.cornerRadius = kFitWidth(10)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 1
        return lab
    }()
    
    private lazy var descLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .COLOR_CARD_BG_WHITE//UIColor.white.withAlphaComponent(0.72)
        layer.cornerRadius = kFitWidth(12)
        clipsToBounds = true
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descLabel)
        
        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(20))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(7))
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalTo(iconView)
        }
        
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView)
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(iconView.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalTo(kFitWidth(-16))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(icon:String,title: String, desc: String, highlights: [String]) {
        iconView.setImgLocal(imgName: icon)
        titleLabel.text = title
        let attr = NSMutableAttributedString(string: desc)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        attr.addAttributes([
            .foregroundColor: descColor,
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: desc.count))
        
        for keyword in highlights where !keyword.isEmpty {
            var searchRange = desc.startIndex..<desc.endIndex
            while let range = desc.range(of: keyword, options: [], range: searchRange) {
                let nsRange = NSRange(range, in: desc)
                attr.addAttributes([
                    .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium)
                ], range: nsRange)
                searchRange = range.upperBound..<desc.endIndex
            }
        }
        
        descLabel.attributedText = attr
    }
}
