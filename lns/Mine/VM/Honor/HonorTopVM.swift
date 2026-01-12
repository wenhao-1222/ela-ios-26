//
//  HonorTopVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//


import Foundation

class HonorTopVM: UIView {
    
    let selfHeight = kFitWidth(267)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleToFill
        img.setImgLocal(imgName: "honor_top_img")
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "我的荣誉"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 21, weight: .medium)
        
        return lab
    }()
    lazy var honorLabel: UILabel = {
        let lab = UILabel()
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    
}

extension HonorTopVM{
    ///iconNum   徽章数   donateNum   捐赠次数
    func updateUI(iconNum:String,donateNum:String) {
        let attr = NSMutableAttributedString(string: "累计获得 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
                        .font:UIFont.systemFont(ofSize: 12, weight: .medium)])
        attr.append(NSAttributedString(string: iconNum, attributes: [.foregroundColor:UIColor.THEME,
                                                                     .font:UIFont().DDInFontBold(fontSize: 21)]))
        attr.append(NSAttributedString(string: " 个徽章，捐赠 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
                                                                     .font:UIFont.systemFont(ofSize: 12, weight: .medium)]))
        attr.append(NSAttributedString(string: donateNum, attributes: [.foregroundColor:UIColor.THEME,
                                                                     .font:UIFont().DDInFontBold(fontSize: 21)]))
        attr.append(NSAttributedString(string: " 次", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
                                                                     .font:UIFont.systemFont(ofSize: 12, weight: .medium)]))
        honorLabel.attributedText = attr
    }
}

extension HonorTopVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(titleLab)
        addSubview(honorLabel)
        
        setConstrait()
        updateUI(iconNum: "0", donateNum: "0")
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(30))
            make.top.equalTo(kFitWidth(64))
            make.height.equalTo(kFitWidth(32))
        }
        honorLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(30))
            make.top.equalTo(kFitWidth(98))
            make.height.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-20))
        }
    }
}
