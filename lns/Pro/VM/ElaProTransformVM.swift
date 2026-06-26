//
//  ElaProTransformVM.swift
//  lns
//
//  Created by Codex on 2026/3/4.
//

import UIKit
import SnapKit

class ElaProTransformVM: UIView {
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let gradientLayer = CAGradientLayer()
    
    private lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_4_bg")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
//    private lazy var maskView: UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .clear
//        vi.isUserInteractionEnabled = false
//        return vi
//    }()
    
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "即刻开启你的蜕变之旅"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 24, weight: .semibold)
        lab.numberOfLines = 0
        return lab
    }()
    
    private lazy var descTopLabel: UILabel = {
        let lab = UILabel()
        let text = "你的计划已经准备就绪，加入 ELA PRO，今天就开始朝目标前进。"
        let font = UIFont.systemFont(ofSize: 16, weight: .regular)
        let color = UIColor.white
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        lab.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]
        )
        lab.textColor = color
        lab.font = font
        lab.numberOfLines = 0
        return lab
    }()
    
    private lazy var descBottomLabel: UILabel = {
        let lab = UILabel()
        lab.text = "告别猜测和纠结，把注意力留给坚持。"
        lab.textColor = UIColor.white.withAlphaComponent(0.5)
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        return lab
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        gradientLayer.frame = maskView.bounds
    }
}

private extension ElaProTransformVM {
    func initUI() {
        addSubview(bgImgView)
//        addSubview(maskView)
        addSubview(titleLabel)
        addSubview(descTopLabel)
        addSubview(descBottomLabel)
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.04).cgColor,
            UIColor.black.withAlphaComponent(0.38).cgColor,
            UIColor.black.withAlphaComponent(0.65).cgColor
        ]
        gradientLayer.locations = [0, 0.55, 1]
//        maskView.layer.addSublayer(gradientLayer)
        
        setConstrait()
    }
    
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        maskView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        descBottomLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(92)))
        }
        
        descTopLabel.snp.makeConstraints { make in
            make.left.right.equalTo(descBottomLabel)
            make.bottom.equalTo(descBottomLabel.snp.top).offset(kFitWidth(-12))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(descBottomLabel)
            make.bottom.equalTo(descTopLabel.snp.top).offset(kFitWidth(-20))
        }
    }
}
