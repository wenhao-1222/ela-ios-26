//
//  HonorDonationMsgVM.swift
//  lns
//  捐赠证书内容
//  Created by LNS2 on 2026/1/12.
//


import Foundation

class HonorDonationMsgVM: UIView {
    
    private var dataSource: [HonorIconModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .COLOR_BG_F2
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "donation_bg_img")
        img.backgroundColor = .white
        return img
    }()
    lazy var certNoLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var certDateLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 11, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.transform = CGAffineTransform(rotationAngle: -0.42)
        
        return lab
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(22.5)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var nickNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "0f1214")
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        
        return lab
    }()
}

extension HonorDonationMsgVM{
    func updateUI(dict:NSDictionary) {
        headImgView.setImgUrl(urlString: dict.stringValueForKey(key: "headimgurl"))
        nickNameLabel.text = dict.stringValueForKey(key: "nickname")
        certNoLabel.text = "证书编号：\(dict.stringValueForKey(key: "certificateNo"))"
        certDateLabel.text = "颁发日期：\(dict.stringValueForKey(key: "ctime"))"
    }
}

extension HonorDonationMsgVM{
    func initUI(){
        addSubview(bgImgView)
        addSubview(certNoLabel)
        addSubview(certDateLabel)
        addSubview(headImgView)
        addSubview(nickNameLabel)
        
        setConstrait()
        
//        updateUI(dict: [:])
    }
    func setConstrait()  {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        certNoLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.top.equalTo(kFitWidth(167))
            make.height.equalTo(kFitWidth(41))
        }
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.width.height.equalTo(kFitWidth(45))
            make.top.equalTo(kFitWidth(232.5))
        }
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.right.equalTo(kFitWidth(-50))
            make.height.equalTo(kFitWidth(58))
            make.top.equalTo(headImgView.snp.bottom).offset(kFitWidth(-10))
        }
        certDateLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-56))
            make.centerY.equalTo(kFitWidth(174)+kFitWidth(29))
        }
    }
}
