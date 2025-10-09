//
//  AINaviVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//

class AINaviVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    var backBlock:(()->())?
    var tipsBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "ai_back_icon")
        
        return img
    }()
    lazy var tipsImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "ai_tips_icon")
        
        return img
    }()
    lazy var backTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var tipsTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(tipsAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
}

extension AINaviVM{
    @objc func backAction() {
        self.backBlock?()
    }
    @objc func tipsAction() {
        self.tipsBlock?()
    }
    func refreshShowStatus(isShow:Bool) {
        if isShow{
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.alpha = 1
            }
        }else{
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.alpha = 0
            }
        }
    }
}

extension AINaviVM{
    func initUI() {
        addSubview(backImgView)
        addSubview(backTapView)
        addSubview(tipsImgView)
        addSubview(tipsTapView)
        
        setConstrait()
    }
    func setConstrait() {
        backImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(13.5))
            make.width.height.equalTo(kFitWidth(30))
        }
        backTapView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.right.equalTo(backImgView).offset(kFitWidth(15))
        }
        tipsImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-18.5))
            make.width.height.equalTo(kFitWidth(30))
            make.centerY.lessThanOrEqualToSuperview()
        }
        tipsTapView.snp.makeConstraints { make in
            make.right.top.height.equalToSuperview()
            make.left.equalTo(tipsImgView).offset(kFitWidth(-15))
        }
    }
}
