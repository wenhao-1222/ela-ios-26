//
//  PersonalTopVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/20.
//


import Foundation

class PersonalTopVM: UIView {
    
    let selfHeight = kFitWidth(303)+WHUtils().getTopSafeAreaHeight()//kFitWidth(271)+WHUtils().getTopSafeAreaHeight()

    var editBlock:(()->())?
    var settinBlock:(()->())?
    
    let avatar = RoundedShadowImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
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
        img.contentMode = .scaleAspectFill
//        img.setImgLocal(imgName: "mine_top_bg")
        
        return img
    }()
    
    lazy var settingButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage.init(named: "mine_func_setting"), for: .normal)
        
        btn.addTarget(self, action: #selector(settingAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var redView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .systemRed//.THEME
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(33)
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = kFitWidth(2)
        img.isUserInteractionEnabled = true
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .clear
//        img.setImgLocal(imgName: "avatar_default")
        img.setImgLocal(imgName: "avatar_default_new")
        img.setImgUrl(urlString: "\(UserInfoModel.shared.headimgurl)")
        
        return img
    }()
    
    lazy var avatarStatusLabel: UILabel = {
        let lab = UILabel()
        lab.text = "审核中"
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textAlignment = .center
        lab.textColor = .white
        lab.backgroundColor = UIColor(white: 0, alpha: 0.5)
        lab.isHidden = true
        return lab
    }()
    lazy var nameLabel : LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 21, weight: .semibold)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "\(UserInfoModel.shared.nickname)"
//        lab.backgroundColor = WHColor_ARC()
        
        return lab
    }()
    lazy var idLabel : LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "ID：\(UserInfoModel.shared.id)"
//        lab.backgroundColor = WHColor_ARC()
        
        return lab
    }()
    lazy var tapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(editAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var funcWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var goalVm: PersonalTopItemVM = {
        let vm = PersonalTopItemVM.init(frame: CGRect.init(x: kFitWidth(8), y: 0, width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "mine_func_goal")
        vm.titleLab.text = "我的目标"
        return vm
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        return vi
    }()
    lazy var statVm: PersonalTopItemVM = {
        let vm = PersonalTopItemVM.init(frame: CGRect.init(x: kFitWidth(106), y: 0, width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "mine_func_stat")
        vm.titleLab.text = "数据统计"
        return vm
    }()
    lazy var mealVm: PersonalTopItemVM = {
        let vm = PersonalTopItemVM.init(frame: CGRect.init(x: self.statVm.frame.maxX, y: 0, width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "mine_func_meal")
        vm.titleLab.text = "食物/食谱"
        return vm
    }()
    lazy var fastingVm: PersonalTopItemVM = {
        let vm = PersonalTopItemVM.init(frame: CGRect.init(x: self.mealVm.frame.maxX, y: 0, width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "mine_func_fasting")
        vm.titleLab.text = "轻断食"
        return vm
    }()
}
extension PersonalTopVM{
    func updateUI() {
        self.headImgView.setImgUrl(urlString: "\(UserInfoModel.shared.headimgurl)")
        self.nameLabel.text = "\(UserInfoModel.shared.nickname)"
        self.idLabel.text = "ID：\(UserInfoModel.shared.id)"
        
        self.redView.isHidden = UserInfoModel.shared.settingNewFuncRead
        self.avatarStatusLabel.isHidden = UserInfoModel.shared.avatarStatus == .pass
    }
}

extension PersonalTopVM{
    @objc func editAction() {
        if self.editBlock != nil{
            self.editBlock!()
        }
    }
    @objc func settingAction() {
        if self.settinBlock != nil{
            self.settinBlock!()
        }
    }
}

extension PersonalTopVM{
    func initUI() {
        avatar.isCircle = true
//        addSubview(bgImgView)
        addSubview(settingButton)
        settingButton.addSubview(redView)
        addSubview(avatar)
        addSubview(headImgView)
        headImgView.addSubview(avatarStatusLabel)
        addSubview(nameLabel)
        addSubview(idLabel)
        addSubview(tapView)
//        addSubview(editTapView)
        
        addSubview(funcWhiteView)
        funcWhiteView.addSubview(goalVm)
        funcWhiteView.addSubview(statVm)
        funcWhiteView.addSubview(mealVm)
        funcWhiteView.addSubview(fastingVm)
        funcWhiteView.addSubview(lineView)
        
        setConstrait()
//        funcWhiteView.backgroundColor = WHColor_ARC()
    }
    func setConstrait() {
//        bgImgView.snp.makeConstraints { make in
//            make.left.width.height.bottom.equalToSuperview()
//        }
        settingButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-3))
//            make.width.height.equalTo(kFitWidth(24))
//            make.right.equalToSuperview()
            make.width.height.equalTo(kFitWidth(44))
            make.top.equalTo(statusBarHeight)
        }
        redView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(10))
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(-10))
            make.width.height.equalTo(kFitWidth(5))
        }
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(27))
            make.top.equalTo(kFitWidth(109)+WHUtils().getTopSafeAreaHeight())
//            make.top.equalTo(kFitWidth(86)+WHUtils().getTopSafeAreaHeight())
            make.width.height.equalTo(kFitWidth(66))
        }
        avatar.snp.makeConstraints { make in
            make.left.top.width.height.equalTo(headImgView)
        }
        avatarStatusLabel.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(20))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(114))
            make.top.equalTo(headImgView).offset(kFitWidth(10.5))
            make.right.equalTo(kFitWidth(-20))
        }
        idLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(3))
        }
        tapView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalTo(headImgView)
        }
//        editTapView.snp.makeConstraints { make in
//            make.left.width.equalToSuperview()
//            make.top.height.equalTo(headImgView)
//        }
        funcWhiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-10))
            make.height.equalTo(kFitWidth(97))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(95))
            make.top.equalTo(kFitWidth(34))
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(30))
        }
    }
}
