//
//  PromotionTagView.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//

import UIKit
import SnapKit

final class PromotionTagView: UIView {
    
    // MARK: - UI
    
    private let leftImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "course_avtivity_bg_left"))
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    private let rightImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "course_avtivity_bg_right"))
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 10, weight: .medium)
        lab.numberOfLines = 1
        return lab
    }()
    
    private let middleContainer = UIView()
    
    
    // MARK: - Public
    
    var text: String? {
        didSet {
            titleLabel.text = text
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
        isHidden = true
        addSubview(leftImageView)
        addSubview(middleContainer)
        addSubview(rightImageView)
        middleContainer.addSubview(titleLabel)
        middleContainer.backgroundColor = WHColor_16(colorStr: "FF5C25")
        
        // 高度固定
        snp.makeConstraints { make in
            make.height.equalTo(21)
        }
        
        leftImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(leftImageView.image?.size.width ?? 8)
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(rightImageView.image?.size.width ?? 8)
        }
        
        middleContainer.snp.makeConstraints { make in
            make.left.equalTo(leftImageView.snp.right)
            make.right.equalTo(rightImageView.snp.left)
            make.top.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()//.offset(6)
            make.right.equalToSuperview()//.offset(-6)
            make.centerY.equalToSuperview()
        }
        
        // 防止被压缩
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
