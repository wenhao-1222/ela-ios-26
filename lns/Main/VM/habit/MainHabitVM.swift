//
//  MainHabitVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//



class MainHabitVM: UIView {
    
    let selfHeight = kFitWidth(60)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(selfTapAction))
        vi.addGestureRecognizer(tap)
//        
        return vi
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.text = "自律习惯养成"
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_arrow_theme")
        img.isUserInteractionEnabled = true
        return img
    }()
}

extension MainHabitVM{
    @objc func selfTapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension MainHabitVM{
    
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(arrowImgView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-11))
            make.width.height.equalTo(kFitWidth(25))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
