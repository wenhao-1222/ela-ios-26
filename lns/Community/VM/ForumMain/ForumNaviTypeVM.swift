//
//  ForumNaviTypeVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/1.
//



enum FORUM_TYPE_ENUM {
    case course//教程
    case forum//帖子
    case market//商城
}

class ForumNaviTypeVM : UIView{
    
    
    let selfHeight = WHUtils().getNavigationBarHeight()
    let btnWidth = kFitWidth(60)
//    var selectType = "right"
    var selectType = FORUM_TYPE_ENUM.forum
    
    var statTypeBlock:((FORUM_TYPE_ENUM)->())?
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        initUI()
    }
    lazy var leftTitleButton: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5-btnWidth*1.5, y: selfHeight-kFitWidth(44), width: btnWidth, height: kFitWidth(44)))
        btn.setTitle("课程", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.isSelected = false
        
        btn.addTarget(self, action: #selector(leftTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var rightTitleButton: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5-btnWidth*0.5, y: selfHeight-kFitWidth(44), width: btnWidth, height: kFitWidth(44)))
        btn.setTitle("发现", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.isSelected = true
        
        btn.addTarget(self, action: #selector(rightTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var marketTitleButton: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5+btnWidth*0.5, y: selfHeight-kFitWidth(44), width: btnWidth, height: kFitWidth(44)))
        btn.setTitle("商品", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        btn.isSelected = true
        
        btn.addTarget(self, action: #selector(marketTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var selectBottomLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var publishButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "forum_publish_icon"), for: .normal)
        btn.isHidden = !UserInfoModel.shared.isAllowedPosterForum
        return btn
    }()
}

extension ForumNaviTypeVM{
    @objc func leftTapAction() {
        if selectType == .course{
            return
        }
        selectType = .course
        updateButtonStatus()
        if self.statTypeBlock != nil{
            self.statTypeBlock!(self.selectType)
        }
    }
    @objc func rightTapAction() {
        if selectType == .forum{
            return
        }
        selectType = .forum
        updateButtonStatus()
        
        if self.statTypeBlock != nil{
            self.statTypeBlock!(self.selectType)
        }
    }
    @objc func marketTapAction() {
        if selectType == .market{
            return
        }
        selectType = .market
        updateButtonStatus()
        
        if self.statTypeBlock != nil{
            self.statTypeBlock!(self.selectType)
        }
    }
    func updateButtonStatus() {
        if selectType == .course{
            leftTitleButton.isSelected = true
            marketTitleButton.isSelected = false
            rightTitleButton.isSelected = false
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.selectBottomLineView.center = CGPoint.init(x: self.leftTitleButton.center.x, y: self.selfHeight-kFitWidth(2))
            }
        }else if selectType == .market{
            leftTitleButton.isSelected = false
            marketTitleButton.isSelected = true
            rightTitleButton.isSelected = false
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.selectBottomLineView.center = CGPoint.init(x: self.marketTitleButton.center.x, y: self.selfHeight-kFitWidth(2))
            }
        }else{
            rightTitleButton.isSelected = true
            marketTitleButton.isSelected = false
            leftTitleButton.isSelected = false
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.selectBottomLineView.center = CGPoint.init(x: self.rightTitleButton.center.x, y: self.selfHeight-kFitWidth(2))
            }
        }
    }
}
extension ForumNaviTypeVM{
    func initUI() {
        addSubview(leftTitleButton)
        addSubview(rightTitleButton)
        addSubview(marketTitleButton)
        addSubview(selectBottomLineView)
        addSubview(publishButton)
        
        setConstrait()
    }
    func setConstrait() {
        selectBottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(4))
            make.centerX.lessThanOrEqualTo(rightTitleButton)
        }
        publishButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(leftTitleButton)
            make.width.height.equalTo(kFitWidth(24))
        }
    }
}
