//
//  MalDetailNaviView.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//



class MalDetailNaviView : UIView{
    
    let selfHeight = WHUtils().getTopSafeAreaHeight() + kFitWidth(35)+kFitWidth(13)*2
    var controller = WHBaseViewVC()
    
    var backBlock:(()->())?
    var shareBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        initUI()
        
    }
    lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "mall_detail_back_icon"), for: .normal)
        
        btn.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var shareButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "mall_detail_share_icon"), for: .normal)
        
        btn.addTarget(self, action: #selector(shareTapAction), for: .touchUpInside)
        return btn
    }()
}

extension MalDetailNaviView{
    @objc func backTapAction() {
        self.backBlock?()
    }
    @objc func shareTapAction() {
        self.shareBlock?()
    }
}

extension MalDetailNaviView{
    func initUI() {
        addSubview(backButton)
        addSubview(shareButton)
        
        setConstrait()
    }
    func setConstrait() {
        backButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.width.height.equalTo(kFitWidth(35))
            make.top.equalTo(WHUtils().getTopSafeAreaHeight()+kFitWidth(13))
        }
        shareButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.width.height.equalTo(backButton)
            make.centerY.lessThanOrEqualTo(backButton)
        }
    }
}
