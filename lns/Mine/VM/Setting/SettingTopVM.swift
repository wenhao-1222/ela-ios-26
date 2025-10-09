//
//  SettingTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/14.
//

import Foundation
import UIKit

class SettingTopVM: UIView {
    
    let selfHeight = kFitWidth(222)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var logoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "mine_setting_logo")
        return img
    }()
    lazy var currentVersionLabel :UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        lab.text = "当前版本：\(currentVersion)"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var tipsLab :UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
//        lab.text = "Copyright © Elavatine All Rights reserved."
        lab.text = "Copyright © 2024 深圳力冠实业 版权所有"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var checkVersionButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("检查更新", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
//        btn.isHidden = true
        return btn
    }()
}

extension SettingTopVM{
    func initUI() {
        addSubview(logoImgView)
        addSubview(currentVersionLabel)
        addSubview(tipsLab)
        addSubview(checkVersionButton)
        
        setConstrait()
    }
    func setConstrait() {
        logoImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(76))
            make.top.equalTo(kFitWidth(36))
        }
        currentVersionLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(124))
        }
        tipsLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(currentVersionLabel.snp.bottom).offset(kFitWidth(8))
        }
        checkVersionButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(120))
        }
    }
}
