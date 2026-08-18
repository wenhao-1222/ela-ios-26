//
//  JournalAICoachTableViewCell.swift
//  lns
//
//  Created by Codex on 2026/4/3.
//

import UIKit

class JournalAICoachTableViewCell: UITableViewCell {
    
    var tapBlock: (() -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        initUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        whiteView.transform = .identity
        titleLabel.text = "AI教练"
        subtitleLabel.isHidden = true
        unreadImgView.isHidden = true
        iconImgView.setImgLocal(imgName: "ai_coach_icon")
        proImgView.layer.removeAllAnimations()
        proImgView.alpha = 0
        proImgView.isHidden = true
        updateLayout(hasUnreadLatestReport: false)
    }
    
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }()
    
    lazy var iconImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.setImgLocal(imgName: "ai_coach_icon")
        return imgView
    }()
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "AI教练"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    
    lazy var subtitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "查看营养缺口与调整建议"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.isHidden = true
        return lab
    }()
    
    lazy var proImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.setImgLocal(imgName: "ai_coach_pro_icon")
        imgView.alpha = 0
        imgView.isHidden = true
        return imgView
    }()
    
    lazy var unreadImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.setImgLocal(imgName: "ai_coach_new_msg_icon")
        imgView.isHidden = true
        return imgView
    }()
    
    lazy var tapButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.enablePressEffect(style: UIImpactFeedbackGenerator(style: .soft), weight: 1)
        btn.addTarget(self, action: #selector(handlePressDown), for: .touchDown)
        btn.addTarget(self, action: #selector(handlePressDown), for: .touchDragEnter)
        btn.addTarget(self, action: #selector(handlePressUp), for: .touchUpInside)
        btn.addTarget(self, action: #selector(handlePressUp), for: .touchUpOutside)
        btn.addTarget(self, action: #selector(handlePressUp), for: .touchCancel)
        btn.addTarget(self, action: #selector(handlePressUp), for: .touchDragExit)
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return btn
    }()
}

extension JournalAICoachTableViewCell {
    func update(isVip: Bool, isMembershipStatusConfirmed: Bool, shouldAnimateProBadge: Bool, hasUnreadLatestReport: Bool) {
        updateLayout(hasUnreadLatestReport: hasUnreadLatestReport)
        proImgView.layer.removeAllAnimations()
        unreadImgView.isHidden = !hasUnreadLatestReport

        if hasUnreadLatestReport && isVip{
            proImgView.alpha = 0
            proImgView.isHidden = true
            titleLabel.text = "新的教练报告已准备好"
            subtitleLabel.isHidden = false
            return
        }

        titleLabel.text = "AI教练"
        subtitleLabel.isHidden = true

        guard isMembershipStatusConfirmed, !isVip else {
            proImgView.alpha = 0
            proImgView.isHidden = true
            return
        }

        proImgView.isHidden = false
        guard shouldAnimateProBadge else {
            proImgView.alpha = 1
            return
        }

        UIView.animate(withDuration: 0.35) {
            self.proImgView.alpha = 1
        }
    }

    func update(isVip: Bool, isMembershipStatusConfirmed: Bool, shouldAnimateProBadge: Bool, hasUnreadLatestReport: Bool, shouldDisplayLogWeightRemind: Bool) {
        let shouldUseMessageLayout = (shouldDisplayLogWeightRemind || hasUnreadLatestReport) && isVip
        updateLayout(hasUnreadLatestReport: shouldUseMessageLayout)
        proImgView.layer.removeAllAnimations()
        unreadImgView.isHidden = !shouldUseMessageLayout

        if shouldDisplayLogWeightRemind {
            proImgView.alpha = 0
            proImgView.isHidden = true
            titleLabel.text = "教练反馈暂未更新"
            subtitleLabel.text = "缺少近期体重数据，请记录体重"
            subtitleLabel.isHidden = false
            return
        }

        if hasUnreadLatestReport && isVip{
            proImgView.alpha = 0
            proImgView.isHidden = true
            titleLabel.text = "新的教练报告已准备好"
            subtitleLabel.text = "查看营养缺口与调整建议"
            subtitleLabel.isHidden = false
            return
        }

        titleLabel.text = "AI教练"
        subtitleLabel.text = "查看营养缺口与调整建议"
        subtitleLabel.isHidden = true

        guard isMembershipStatusConfirmed, !isVip else {
            proImgView.alpha = 0
            proImgView.isHidden = true
            return
        }

        proImgView.isHidden = false
        guard shouldAnimateProBadge else {
            proImgView.alpha = 1
            return
        }

        UIView.animate(withDuration: 0.35) {
            self.proImgView.alpha = 1
        }
    }

    @objc private func handlePressDown() {
        updateWhiteViewPressState(isPressed: true)
    }

    @objc private func handlePressUp() {
        updateWhiteViewPressState(isPressed: false)
    }

    @objc func tapAction() {
        tapBlock?()
    }

    private func updateWhiteViewPressState(isPressed: Bool) {
        let transform: CGAffineTransform = isPressed ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.whiteView.transform = transform
        }
    }

    private func updateLayout(hasUnreadLatestReport: Bool) {
        whiteView.snp.updateConstraints { make in
            make.height.equalTo(kFitWidth(hasUnreadLatestReport ? 64 : 50))
        }

        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(12))
            make.right.lessThanOrEqualTo(hasUnreadLatestReport ? unreadImgView.snp.left : proImgView.snp.left).offset(kFitWidth(-8))
            make.height.equalTo(kFitWidth(21))
            if hasUnreadLatestReport {
                make.top.equalToSuperview().offset(kFitWidth(12.5))
            } else {
                make.centerY.equalToSuperview()
            }
        }
        
        subtitleLabel.snp.remakeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(unreadImgView.snp.left).offset(kFitWidth(-8))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(1.5))
            make.height.equalTo(kFitWidth(18))
        }
    }
}

extension JournalAICoachTableViewCell {
    func initUI() {
        contentView.addSubview(whiteView)
        whiteView.addSubview(iconImgView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(subtitleLabel)
        whiteView.addSubview(proImgView)
        whiteView.addSubview(unreadImgView)
        whiteView.addSubview(tapButton)
        
        whiteView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(12))
            make.left.equalTo(kFitWidth(10))
            make.right.equalTo(kFitWidth(-10))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(50))
        }
        
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12.5))
//            make.centerY.equalToSuperview()
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.width.height.equalTo(kFitWidth(24))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(8))
            make.centerY.equalToSuperview()
        }
        proImgView.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalTo(kFitWidth(30))
            make.height.equalTo(kFitWidth(13))
        }
        
        unreadImgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-12.5))
            make.width.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(29.5))
        }
        
        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
