//
//  FriendRankingDailyTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/7/3.
//


class FriendRankingDailyTableViewCell: UITableViewCell {
    
    var editBlock:((_ sourceView: UIView)->Void)?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        
        initUI()
    }
    lazy var rankImgView : UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var rankNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = UIFont().DDInFontSemiBold(fontSize: 28)
        lab.isHidden = true
        
        return lab
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(20)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var nickNameLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var editImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "friend_list_edit_icon")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        return img
    }()
    lazy var editTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(editTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var comleteLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var comleteLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var caloriesItemVm: FriendRankingDailyNaturalVM = {
        let vm = FriendRankingDailyNaturalVM.init(frame: CGRect.init(x: kFitWidth(91), y: kFitWidth(79), width: 0, height: 0))
        vm.titleLabel.text = ""
        vm.progressColor = .COLOR_CALORI
        
        return vm
    }()
    lazy var carboItemVm: FriendRankingDailyNaturalVM = {
        let vm = FriendRankingDailyNaturalVM.init(frame: CGRect.init(x: self.caloriesItemVm.frame.maxX+kFitWidth(20), y: kFitWidth(79), width: 0, height: 0))
        vm.titleLabel.text = ""
        vm.progressColor = .COLOR_CARBOHYDRATE
        
        return vm
    }()
    lazy var proteinItemVm: FriendRankingDailyNaturalVM = {
        let vm = FriendRankingDailyNaturalVM.init(frame: CGRect.init(x: kFitWidth(91), y: kFitWidth(137), width: 0, height: 0))
        vm.titleLabel.text = ""
        vm.progressColor = .COLOR_PROTEIN
        
        return vm
    }()
    lazy var fatItemVm: FriendRankingDailyNaturalVM = {
        let vm = FriendRankingDailyNaturalVM.init(frame: CGRect.init(x: self.proteinItemVm.frame.maxX+kFitWidth(20), y: kFitWidth(137), width: 0, height: 0))
        vm.titleLabel.text = ""
        vm.progressColor = .COLOR_FAT
        
        return vm
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
}

extension FriendRankingDailyTableViewCell{
    func updateUI(dict:NSDictionary,index:Int) {
        if dict.stringValueForKey(key: "nickname").isEmpty {
            rankImgView.image = nil
            headImgView.image = nil
            nickNameLabel.text = nil
            comleteLabel.text = nil
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            rankImgView.showSkeleton(cfg)
            headImgView.showSkeleton(cfg)
            nickNameLabel.showSkeleton(cfg)
            comleteLabel.showSkeleton(cfg)
            comleteLab.showSkeleton(cfg)
            caloriesItemVm.showCfg(cfg)
            carboItemVm.showCfg(cfg)
            proteinItemVm.showCfg(cfg)
            fatItemVm.showCfg(cfg)
            return
        }
        
        comleteLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(rankImgView)
            make.top.equalTo(kFitWidth(79))
        }
        comleteLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(comleteLab)
            make.top.equalTo(comleteLab.snp.bottom).offset(kFitWidth(2))
        }
        
        nickNameLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(135))
            make.centerY.lessThanOrEqualTo(headImgView)
            make.right.equalTo(kFitWidth(-52))
        }
        comleteLab.text = "完成率"
        rankImgView.isHidden = true
        rankNumLabel.isHidden = true
        if index < 3 {
            rankImgView.isHidden = false
            if index == 0 {
                rankImgView.setImgLocal(imgName: "friend_list_first")
            }else if index == 1{
                rankImgView.setImgLocal(imgName: "friend_list_second")
            }else{
                rankImgView.setImgLocal(imgName: "friend_list_third")
            }
        }else{
            rankNumLabel.isHidden = false
            rankNumLabel.text = "\(index+1)"
        }
        editImgView.isHidden = dict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId
        editTapView.isHidden = dict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId
        
        nickNameLabel.text = dict.stringValueForKey(key: "nickname")
        headImgView.setImgUrl(urlString: dict.stringValueForKey(key: "headimgurl"))
        caloriesItemVm.updateUI(type: .calories, currentNum: dict.doubleValueForKey(key: "calories"), totalNum: dict.doubleValueForKey(key: "caloriesDen"), sign: dict.stringValueForKey(key: "caloriesSign"))
        carboItemVm.updateUI(type: .carbo, currentNum: dict.doubleValueForKey(key: "carbohydrate"), totalNum: dict.doubleValueForKey(key: "carbohydrateDen"), sign: dict.stringValueForKey(key: "carbohydrateSign"))
        proteinItemVm.updateUI(type: .protein, currentNum: dict.doubleValueForKey(key: "protein"), totalNum: dict.doubleValueForKey(key: "proteinDen"), sign: dict.stringValueForKey(key: "proteinSign"))
        fatItemVm.updateUI(type: .fat, currentNum: dict.doubleValueForKey(key: "fat"), totalNum: dict.doubleValueForKey(key: "fatDen"), sign: dict.stringValueForKey(key: "fatSign"))
        
        let attr = NSMutableAttributedString(string: dict.stringValueForKey(key: "score"))
        let attrUnit = NSMutableAttributedString(string: "%")
        attr.yy_font = UIFont().DDInFontBold(fontSize: 25)
        attrUnit.yy_font = UIFont().DDInFontBold(fontSize: 12)
        attr.append(attrUnit)
        comleteLabel.attributedText = attr
        
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [rankImgView, headImgView, nickNameLabel,comleteLab,comleteLabel, caloriesItemVm,carboItemVm,proteinItemVm,fatItemVm].forEach { $0.hideSkeletonWithCrossfade() }
    }
    @objc func editTapAction() {
//        self.editBlock?()
        self.editBlock?(editImgView)
    }
}

extension FriendRankingDailyTableViewCell{
    func initUI() {
        contentView.addSubview(rankImgView)
        contentView.addSubview(rankNumLabel)
        contentView.addSubview(headImgView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(editImgView)
        contentView.addSubview(comleteLab)
        contentView.addSubview(comleteLabel)
        contentView.addSubview(caloriesItemVm)
        contentView.addSubview(carboItemVm)
        contentView.addSubview(proteinItemVm)
        contentView.addSubview(fatItemVm)
        contentView.addSubview(lineView)
        contentView.addSubview(editTapView)
        
        setConstrait()
    }
    func setConstrait() {
        rankImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(kFitWidth(15))
            make.width.equalTo(kFitWidth(40))
            make.height.equalTo(kFitWidth(49))
        }
        rankNumLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(25))
            make.centerX.lessThanOrEqualTo(comleteLab)
        }
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(88))
            make.top.equalTo(kFitWidth(19.5))
            make.width.height.equalTo(kFitWidth(40))
        }
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(135))
//            make.top.equalTo(kFitWidth(27.5))
            make.centerY.lessThanOrEqualTo(headImgView)
            make.right.equalTo(kFitWidth(-52))
            make.height.equalTo(kFitWidth(24))
        }
        editImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(nickNameLabel)
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(6))
            make.height.equalTo(kFitWidth(40))
        }
        editTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(editImgView)
            make.width.height.equalTo(kFitWidth(40))
        }
        comleteLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(rankImgView)
            make.top.equalTo(kFitWidth(79))
            make.height.equalTo(kFitWidth(20))
            make.width.equalTo(kFitWidth(30))
        }
        comleteLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(comleteLab)
            make.top.equalTo(comleteLab.snp.bottom).offset(kFitWidth(2))
            make.height.equalTo(kFitWidth(20))
            make.width.equalTo(kFitWidth(30))
        }
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}
