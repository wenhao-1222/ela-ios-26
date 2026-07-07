//
//  GuideTotalProReadyStartVM.swift
//  lns
//
//  Created by Codex on 2026/7/6.
//

import UIKit
import SnapKit

class GuideTotalProReadyStartVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(() -> Void)?
    
    override init(frame:CGRect){
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        clipsToBounds = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var heroImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_ai_end_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "让每一次记录都为你工作"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var subtitleLab: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        
        lab.attributedText = NSAttributedString(
            string: "接下来，\n让我们激活 ELA PRO 专属的 AI 教练",
            attributes: [
                .font: lab.font as Any,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
        return lab
    }()
    
    lazy var detailLab: UILabel = {
        let lab = UILabel()
        lab.text = "你只需记录，剩下的交给 AI 教练"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("激活 AI 教练", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return btn
    }()
}

extension GuideTotalProReadyStartVM {
    @objc private func nextButtonAction() {
        nextBlock?()
    }
}

extension GuideTotalProReadyStartVM {
    func initUI() {
        addSubview(scrollView)
        addSubview(nextButton)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(heroImageView)
        contentView.addSubview(titleLab)
        contentView.addSubview(subtitleLab)
        contentView.addSubview(detailLab)
        
        setConstrait()
    }
    
    func setConstrait() {
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(kFitWidth(-18))
        }
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        heroImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getTabbarHeight() + kFitWidth(5))
            make.width.equalTo(kFitWidth(296))
            make.height.equalTo(kFitWidth(376))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(heroImageView.snp.bottom).offset(kFitWidth(35))
        }
        subtitleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(20))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(subtitleLab.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalToSuperview().offset(kFitWidth(-24))
        }
    }
}

extension GuideTotalProReadyStartVM {
    func prepareEntranceAnimation() {
        scrollView.setContentOffset(.zero, animated: false)
        heroImageView.alpha = 0
        titleLab.alpha = 0
        subtitleLab.alpha = 0
        detailLab.alpha = 0
        nextButton.alpha = 0
    }
    
    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.55, delay: 0, options: .curveLinear) {
            self.heroImageView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.55, delay: 0.1, options: .curveLinear) {
                self.titleLab.alpha = 1
                self.subtitleLab.alpha = 1
                self.detailLab.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
}
