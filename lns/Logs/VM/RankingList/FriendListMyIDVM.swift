//
//  FriendListMyIDVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/30.
//

import MCToast

class FriendListMyIDVM: UIView {
    
    let selfHeight = kFitWidth(75)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var idLabel: UILabel = {
        let lab = UILabel()
        lab.text = "我的ID：\(UserInfoModel.shared.id)"
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var copyButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("复制", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        
        btn.addTarget(self, action: #selector(copyIdAction), for: .touchUpInside)
        
        return btn
    }()
}

extension FriendListMyIDVM{
    @objc func copyIdAction()  {
        UIPasteboard.general.string = UserInfoModel.shared.id
        MCToast.mc_success("复制ID成功",respond: .allow)
    }
}

extension FriendListMyIDVM{
    func initUI() {
        addSubview(idLabel)
        addSubview(copyButton)
        
        setConstrait()
    }
    func setConstrait() {
        idLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.centerY.lessThanOrEqualToSuperview()
        }
        copyButton.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-20))
            make.width.equalTo(kFitWidth(80))
        }
    }
}
