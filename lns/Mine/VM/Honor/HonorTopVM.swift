//
//  HonorTopVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//


import Foundation

class HonorTopVM: UIView {
    
    let selfHeight = kFitWidth(267)
    private var iconCount = 0
    private var donateCount = 0
    private var countDisplayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var fromIconCount = 0
    private var toIconCount = 0
    private var fromDonateCount = 0
    private var toDonateCount = 0
    private let countAnimationDuration: CFTimeInterval = 0.85
    
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
    
    deinit {
        stopCountAnimation()
    }
    
}

extension HonorTopVM{
    ///iconNum   徽章数   donateNum   捐赠次数
    func updateUI(iconNum:String,donateNum:String, animated: Bool = true) {
        let targetIconCount = Int(iconNum) ?? 0
        let targetDonateCount = Int(donateNum) ?? 0
        
        guard animated else {
            stopCountAnimation()
            iconCount = targetIconCount
            donateCount = targetDonateCount
            updateHonorText(iconNum: "\(targetIconCount)", donateNum: "\(targetDonateCount)")
            return
        }
        
        fromIconCount = iconCount
        toIconCount = targetIconCount
        fromDonateCount = donateCount
        toDonateCount = targetDonateCount
        animationStartTime = CACurrentMediaTime()
        
        stopCountAnimation()
        let link = CADisplayLink(target: self, selector: #selector(handleCountAnimation(_:)))
        link.add(to: .main, forMode: .common)
        countDisplayLink = link
        handleCountAnimation(link)
    }
    
    private func updateHonorText(iconNum:String,donateNum:String) {
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
    
    @objc private func handleCountAnimation(_ link: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - animationStartTime
        let rawProgress = min(max(elapsed / countAnimationDuration, 0), 1)
        let progress = 1 - pow(1 - rawProgress, 3)
        let currentIcon = fromIconCount + Int(round(Double(toIconCount - fromIconCount) * progress))
        let currentDonate = fromDonateCount + Int(round(Double(toDonateCount - fromDonateCount) * progress))
        
        iconCount = currentIcon
        donateCount = currentDonate
        updateHonorText(iconNum: "\(currentIcon)", donateNum: "\(currentDonate)")
        
        if rawProgress >= 1 {
            stopCountAnimation()
        }
    }
    
    private func stopCountAnimation() {
        countDisplayLink?.invalidate()
        countDisplayLink = nil
    }
}

extension HonorTopVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(titleLab)
        addSubview(honorLabel)
        
        setConstrait()
        updateUI(iconNum: "0", donateNum: "0", animated: false)
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
