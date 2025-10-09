//
//  MineTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/11.
//

import Foundation

class MineTopVM: UIView {
    
    let selfHeight = kFitWidth(232)+WHUtils().getNavigationBarHeight()
    
    var editBlock:(()->())?
    var settinBlock:(()->())?
    
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
//        img.backgroundColor = .THEME
        img.contentMode = .scaleToFill
        img.setImgLocal(imgName: "mine_top_bg")
        
        return img
    }()
    
    lazy var leftEditButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("编辑资料", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var settingButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage.init(named: "mine_func_setting"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
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
        img.layer.cornerRadius = kFitWidth(36)
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
    lazy var nameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "\(UserInfoModel.shared.nickname)"
        
        return lab
    }()
    lazy var idLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "ID：\(UserInfoModel.shared.id)"
        
        return lab
    }()
    lazy var editTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(editAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var planListVm : MineTopFuncVM = {
        let vm = MineTopFuncVM.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(152)+WHUtils().getNavigationBarHeight(), width: 0, height: 0))
        
        return vm
    }()
    lazy var createPlanVm : MineTopFuncVM = {
        let vm = MineTopFuncVM.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5+kFitWidth(3.5), y: kFitWidth(152)+WHUtils().getNavigationBarHeight(), width: 0, height: 0))
        vm.leftIconImg.setImgLocal(imgName: "mine_func_create_plan")
        vm.textLab.text = "制作计划"
        
        return vm
    }()
}

extension MineTopVM{
    func updateUI() {
        self.headImgView.setImgUrl(urlString: "\(UserInfoModel.shared.headimgurl)")
        self.nameLabel.text = "\(UserInfoModel.shared.nickname)"
        self.idLabel.text = "ID：\(UserInfoModel.shared.id)"
        
        self.redView.isHidden = UserInfoModel.shared.settingNewFuncRead
        self.avatarStatusLabel.isHidden = UserInfoModel.shared.avatarStatus == .pass
    }
}
extension MineTopVM{
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

extension MineTopVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(leftEditButton)
        addSubview(settingButton)
        settingButton.addSubview(redView)
        addSubview(headImgView)
        headImgView.addSubview(avatarStatusLabel)
        addSubview(nameLabel)
        addSubview(idLabel)
        addSubview(editTapView)
        
        addSubview(planListVm)
        addSubview(createPlanVm)
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.width.height.bottom.equalToSuperview()
        }
        leftEditButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(statusBarHeight)
            make.height.equalTo(kFitWidth(44))
        }
        settingButton.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
//            make.width.height.equalTo(kFitWidth(24))
            make.right.equalToSuperview()
            make.width.height.equalTo(kFitWidth(56))
            make.centerY.lessThanOrEqualTo(leftEditButton)
        }
        redView.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(settingButton).offset(kFitWidth(27))
//            make.centerY.lessThanOrEqualTo(settingButton).offset(kFitWidth(-27))
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(10))
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(-10))
            make.width.height.equalTo(kFitWidth(5))
        }
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(48)+WHUtils().getNavigationBarHeight())
            make.width.height.equalTo(kFitWidth(72))
        }
        avatarStatusLabel.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(20))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(108))
            make.top.equalTo(headImgView).offset(kFitWidth(16))
            make.right.equalTo(kFitWidth(-20))
        }
        idLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(8))
        }
        editTapView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.height.equalTo(headImgView)
        }
    }
}
