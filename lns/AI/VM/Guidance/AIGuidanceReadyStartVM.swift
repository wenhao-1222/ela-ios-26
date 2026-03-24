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
        backgroundColor = .white
        isUserInteractionEnabled = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_ai_bg"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
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
        label.text = "AI教练已准备就绪，加入ELA PRO，今天就开始朝目标前进。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .regular)
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
        addSubview(backgroundImageView)
        addSubview(heroImageView)
//        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(detailLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        }
    }
}
