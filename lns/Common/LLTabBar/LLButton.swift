//
//  LLButton.swift
//  swiftStudy01
//
//  Created by 刘恋 on 2019/6/6.
//  Copyright © 2019 刘恋. All rights reserved.
//
import UIKit
import SnapKit

public let LLLUibuttonRatio = 0.7

class LLButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        imageView?.contentMode = .center
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 12)

        addSubview(conentLab)
        addSubview(redView)

        // ✅ 居中对齐用 equalTo，避免跑偏；并减小底部内边距
        conentLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(kFitWidth(-4))
        }
        redView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(5))
            make.centerX.equalToSuperview().offset(kFitWidth(12))
            make.top.equalToSuperview().offset(kFitWidth(3))
        }
    }

    lazy var conentLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12)
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        return lab
    }()

    lazy var redView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .systemRed
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()

    override var isHighlighted: Bool {
        set { /* 禁止高亮态变色 */ }
        get { return false }
    }

    // 图片区域
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imgWidth = kFitWidth(30)
        let imgHeight = kFitWidth(30)
        return CGRect(x: (contentRect.size.width - imgWidth) * 0.5,
                      y: kFitWidth(2),
                      width: imgWidth,
                      height: imgHeight)
    }

    // 我们不使用 UIButton 自带的 titleLabel 来显示标题（避免与 conentLab 重复）
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return .zero
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
