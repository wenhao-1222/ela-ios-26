//
//  QuestionnaireEventsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation

class QuestionnaireEventsTableViewCell: FeedBackTableViewCell {
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let feedbackWeight: CGFloat = 0.6
    private var lastFeedbackTime: TimeInterval = 0
    private let minimumFeedbackInterval: TimeInterval = 0.1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
//        if highlighted {
//            self.bottomView.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT
//        }else{
////            self.bottomView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
//        }
    }
    lazy var bottomView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.clipsToBounds = true
        vi.layer.cornerRadius = kFitWidth(36)
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
}

extension QuestionnaireEventsTableViewCell{
    func updateUI(dict:NSDictionary,isSelected:Bool) {
        titleLabel.text = "\(dict["name"]as? String ?? "")"
        contentLabel.text = "\(dict["detail"]as? String ?? "")"
        
        if isSelected{
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.titleLabel.textColor = .white
                self.contentLabel.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
                self.bottomView.backgroundColor = .THEME
            })
            
        }else{
            titleLabel.textColor = .COLOR_GRAY_BLACK_85
            contentLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
            bottomView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        }
    }
}
extension QuestionnaireEventsTableViewCell{
    func initUI() {
        contentView.addSubview(bottomView)
        bottomView.addSubview(titleLabel)
        bottomView.addSubview(contentLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bottomView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(72))
            make.top.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(16))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(40))
        }
    }
}

extension QuestionnaireEventsTableViewCell{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let scale: CGFloat = 0.99
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
//        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
//        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
////            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.9)
//            triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
//        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
//    private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
//        let now = Date().timeIntervalSince1970
//        guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
//        generator.impactOccurred(intensity: intensity)
//        lastFeedbackTime = now
//    }
}
