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
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()
    lazy var proBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.maskedCorners = [.layerMinXMaxYCorner]//,.layerMaxXMinYCorner]
        return vi
    }()
    lazy var proImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.setImgLocal(imgName: "ai_coach_pro_icon")
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
    func update(isVip: Bool) {
        proImgView.isHidden = isVip
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
}

extension JournalAICoachTableViewCell {
    func initUI() {
        contentView.addSubview(whiteView)
        whiteView.addSubview(iconImgView)
        whiteView.addSubview(titleLabel)
//        whiteView.addSubview(proBgView)
        whiteView.addSubview(proImgView)
        whiteView.addSubview(tapButton)
        
        whiteView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(12))
            make.left.equalTo(kFitWidth(10))
            make.right.equalTo(kFitWidth(-10))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(50))
        }
        
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(28))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(8))
            make.centerY.equalToSuperview()
        }
//        proBgView.snp.makeConstraints { make in
//            make.right.top.equalToSuperview()
//            make.height.equalTo(kFitWidth(13))
//            make.width.equalTo(kFitWidth(30))
//        }
//        proImgView.snp.makeConstraints { make in
//            make.center.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(15))
//            make.height.equalTo(kFitWidth(6))
//        }
        proImgView.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalTo(kFitWidth(30))
            make.height.equalTo(kFitWidth(13))
        }
        
        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
