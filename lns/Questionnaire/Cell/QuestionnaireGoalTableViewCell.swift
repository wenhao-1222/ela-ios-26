//
//  QuestionnaireGoalTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation

class QuestionnaireGoalTableViewCell: FeedBackTableViewCell {
    
    private var generator = UIImpactFeedbackGenerator(style: .rigid)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        generator.prepare()
        initUI()
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.bottomView.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT
        }else{
            self.bottomView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        }
    }
    lazy var bottomView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.clipsToBounds = true
        vi.layer.cornerRadius = kFitWidth(30)
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var borderRectView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(30)
        vi.clipsToBounds = true
        vi.layer.borderWidth = kFitWidth(0.5)
        vi.layer.borderColor = UIColor.THEME.cgColor
        vi.isHidden = true
        return vi
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 3
        lab.adjustsFontSizeToFitWidth = true
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var goalImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_goal_selected")
        
        return img
    }()
}

extension QuestionnaireGoalTableViewCell{
    func updateUI(dict:NSDictionary,isSelected:Bool) {
        if isSelected{
            bottomView.isHidden = true
            borderRectView.isHidden = false
        }else{
            bottomView.isHidden = false
            borderRectView.isHidden = true
        }
        titleLabel.text = "\(dict["name"]as? String ?? "")"
        titleLab.text = "\(dict["name"]as? String ?? "")"
        
        contentLabel.text = "\(dict["detail"]as? String ?? "")"
    }
}

extension QuestionnaireGoalTableViewCell{
    func initUI() {
        contentView.addSubview(bottomView)
        bottomView.addSubview(titleLabel)
        
        contentView.addSubview(borderRectView)
        borderRectView.addSubview(titleLab)
        borderRectView.addSubview(contentLabel)
        borderRectView.addSubview(goalImgView)
        
        setConstrait()
    }
    func setConstrait() {
        bottomView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(60))
        }
        titleLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
        borderRectView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(132))
        }
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(20))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(52))
            make.width.equalTo(kFitWidth(234))
//            make.height.equalTo(kFitWidth(66))
        }
        goalImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(20))
            make.width.height.equalTo(kFitWidth(48))
        }
    }
}

extension QuestionnaireGoalTableViewCell{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let scale: CGFloat = 0.99
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        self.generator.impactOccurred()
        generator.prepare()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
