//
//  AIGuidanceReadyStartVM.swift
//  lns
//
//  Created by Codex on 2026/3/24.
//

import UIKit
import SnapKit

class AIGuidanceReadyStartVM: UIView {

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var heroImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_ai_end_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

//    private lazy var logoImageView: UIImageView = {
//        let imageView = UIImageView(image: UIImage(named: "ela_pro_icon"))
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "准备好开始改变了吗？"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
//        label.text = "AI教练已准备就绪，加入ELA PRO，今天就开始朝目标前进。"
//        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5

        label.attributedText = NSAttributedString(
            string: "AI教练已准备就绪，加入ELA PRO，今天就开始朝目标前进。",
            attributes: [
                .font: label.font as Any,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.text = "告别猜测和纠结，把注意力留给坚持。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
}

private extension AIGuidanceReadyStartVM {
    func initUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(heroImageView)
//        addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(detailLabel)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.greaterThanOrEqualTo(scrollView.snp.height)
        }

        heroImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(17))
            make.width.equalTo(kFitWidth(299))
            make.height.equalTo(kFitWidth(415))
        }

//        logoImageView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(32))
//            make.top.equalTo(heroImageView.snp.bottom).offset(kFitWidth(20))
//            make.width.equalTo(kFitWidth(165))
//            make.height.equalTo(kFitWidth(29))
//        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(heroImageView.snp.bottom).offset(kFitWidth(35))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }

        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(90)))
        }
    }
}
