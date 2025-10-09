//
//  InviteRewardsCodeVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//

import Foundation
import MCToast

class InviteRewardsCodeVM: UIView {
    
    let selfHeight = kFitWidth(112)
    
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "invite_rewards_code_bg")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var copyCodeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("复制邀请码", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.addTarget(self, action: #selector(copyCodeAction), for: .touchUpInside)
        return btn
    }()
}

extension InviteRewardsCodeVM{
    @objc func copyCodeAction() {
        UIPasteboard.general.string = UserInfoModel.shared.inviteCode
        MCToast.mc_success("邀请码已复制",respond: .allow)
    }
}
extension InviteRewardsCodeVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(copyCodeButton)
        
        setConstrait()
        refreshCodeView()
    }
    func setConstrait()  {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        copyCodeButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(52))
        }
    }
    func refreshCodeView() {
        let shareCode = UserInfoModel.shared.inviteCode
        
        let labelWidth = kFitWidth(40)
        let labelGap = kFitWidth(12)
        let labelOriginY = kFitWidth(20)
        var labelOriginX = kFitWidth(0)
        
        if shareCode.count % 2 == 0 {
            labelOriginX = SCREEN_WIDHT*0.5 - CGFloat(CGFloat(shareCode.count/2)*CGFloat(labelWidth+labelGap)) + CGFloat(labelGap*0.5)
        }else{
            labelOriginX = SCREEN_WIDHT*0.5 - CGFloat(CGFloat(shareCode.count/2)*CGFloat(labelWidth+labelGap)) - CGFloat(labelWidth*0.5)
        }
        
        for i in 0..<shareCode.count{
            let lab = UILabel()
            lab.backgroundColor = WHColor_16(colorStr: "F5F5F5")
            lab.layer.borderColor = WHColor_16(colorStr: "D9D9D9").cgColor
            lab.layer.borderWidth = kFitWidth(1)
            lab.layer.cornerRadius = kFitWidth(4)
            lab.clipsToBounds = true
            lab.textAlignment = .center
            lab.font = .systemFont(ofSize: 20, weight: .medium)
            lab.textColor = .COLOR_GRAY_BLACK_85
            lab.frame = CGRect.init(x: labelOriginX, y: labelOriginY, width: labelWidth, height: labelWidth)
            
            labelOriginX = labelOriginX + labelWidth + labelGap
            lab.text = shareCode.mc_clip(range: (i,1))
            addSubview(lab)
        }
    }
}
