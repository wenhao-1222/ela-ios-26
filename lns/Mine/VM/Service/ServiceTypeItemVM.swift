//
//  ServiceTypeItemVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/8.
//


class ServiceTypeItemVM: UIView {
    
    let selfHeight = kFitWidth(60) + kFitWidth(12)
    
    var tapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F2
        
        initUI()
    }
    
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(20), y: 0, width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(60)))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "service_type_advice")//service_type_market
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .medium)
        
        return lab
    }()
    lazy var detailLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_arrow_gray")
        img.isUserInteractionEnabled = true
        
        return img
    }()
}

extension ServiceTypeItemVM{
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension ServiceTypeItemVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(iconImgView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(detailLab)
        whiteView.addSubview(arrowImgView)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(30))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(55))
            make.top.equalTo(kFitWidth(12))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.bottom.equalTo(kFitWidth(-12))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}

extension ServiceTypeItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        changeBgColor(color: .COLOR_TEXT_TITLE_0f1214_03)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        changeBgColor(color: .COLOR_CARD_BG_WHITE)
        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
            tapAction()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        changeBgColor(color: .COLOR_CARD_BG_WHITE)
    }
    private func changeBgColor(color:UIColor){
        self.whiteView.backgroundColor = color
    }
}
