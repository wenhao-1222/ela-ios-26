//
//  PromotionDeadlineTagView.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//

import UIKit
import SnapKit

final class PromotionDeadlineTagView: UIView {
    
    // MARK: - UI
    
    private let leftContainer: UIView = {
        let v = UIView()
        v.backgroundColor = WHColor_16(colorStr: "FF8725")
        return v
    }()
    
    private let leftLabel: UILabel = {
        let lab = UILabel()
        lab.text = "优惠"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .semibold)
        lab.textAlignment = .center
        return lab
    }()
    
    private let rightContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    private let rightLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "FF8725")
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.numberOfLines = 1
        return lab
    }()
    
    
    // MARK: - Public
    
    /// 右侧动态文字
    var text: String? {
        didSet {
            rightLabel.text = text
            isHidden = (text?.isEmpty ?? true)
        }
    }
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = WHColorWithAlpha(colorStr: "FF8725", alpha: 0.1)
        isHidden = true
        
        addSubview(leftContainer)
        addSubview(rightContainer)
        
        leftContainer.addSubview(leftLabel)
        rightContainer.addSubview(rightLabel)
        
        // 圆角 + 描边
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = WHColor_16(colorStr: "FF8725").cgColor
        layer.masksToBounds = true
        
        // 高度固定
        snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        // 左侧
        leftContainer.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        
        leftLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        // 右侧
        rightContainer.snp.makeConstraints { make in
            make.left.equalTo(leftContainer.snp.right)
            make.top.bottom.right.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        // 防止被压缩
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
