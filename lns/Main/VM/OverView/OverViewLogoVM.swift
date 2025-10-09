//
//  OverViewLogoVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/30.
//


class OverViewLogoVM: UIView {
    
    let selfHeight = kFitWidth(38)+statusBarHeight+kFitWidth(4)
    var number = 0
    
    var planTapBlock:(()->())?
    var editBlock:(()->())?
    
    let logoImg = UIImage(named: "main_top_logo_cj")
    let imgWidth = kFitWidth(139)
    let imgHeight = kFitWidth(25)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
//        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.alpha = 0
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var logoImgView: UIImageView = {
        let img = UIImageView(frame: CGRect(x: kFitWidth(32), y: self.selfHeight-kFitWidth(25)-kFitWidth(10), width: kFitWidth(139), height: kFitWidth(25)))
                img.image = logoImg?.withRenderingMode(.alwaysTemplate)
                img.tintColor = .white
        img.contentMode = .scaleAspectFit
        return img
    }()
}

extension OverViewLogoVM{
    func updateAlpha(offsetY:CGFloat) {
        var percent = offsetY / selfHeight
        percent = min(max(percent, 0), 1)

        bgView.alpha = percent

        let value = pow(percent, 3)
        backgroundColor = UIColor(white: 1, alpha: value)

        let start = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        let end = WHColorWithAlpha(colorStr: "007AFF", alpha: 1)
        logoImgView.tintColor = blendColor(from: start, to: end, progress: value)
        
        percent = min(percent, 0.4)
        percent = 1 - percent
//        logoImgView.frame = CGRect.init(x: kFitWidth(32), y: self.selfHeight-kFitWidth(25)-kFitWidth(4), width: imgWidth*percent, height: imgHeight*percent)
        logoImgView.frame = CGRect.init(x: kFitWidth(32), y: self.selfHeight-kFitWidth(25)-kFitWidth(10), width: imgWidth*percent, height: imgHeight*percent)
    }
}
private func blendColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
    let ratio = min(max(progress, 0), 1)
    var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
    var tr: CGFloat = 0, tg: CGFloat = 0, tb: CGFloat = 0, ta: CGFloat = 0
    from.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
    to.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
    return UIColor(red: fr + (tr - fr) * ratio,
                   green: fg + (tg - fg) * ratio,
                   blue: fb + (tb - fb) * ratio,
                   alpha: fa + (ta - fa) * ratio)
}

extension OverViewLogoVM{
    func initUI() {
        addSubview(bgView)
        addSubview(logoImgView)
        
        bgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        bgView.addShadow(opacity: 0.05)
    }
}
