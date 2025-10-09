//
//  AddressTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//


class AddressTableViewCell: UITableViewCell {
    
    var editBlock:(()->())?
    var deleteBlock:(()->())?
    var setDefaultBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        backgroundColor = .COLOR_BG_F2
        contentView.backgroundColor = .COLOR_BG_F2
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(13)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var nameLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var phoneLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var addressDetailLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        
        return vi
    }()
    lazy var setDefaultButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("默认收件地址", for: .normal)
        btn.setImage(UIImage(named: "mall_address_normal_icon"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .regular)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.imagePosition(style: .left, spacing: kFitWidth(3))
        
        btn.addTarget(self, action: #selector(setDafaultAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var editButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("编辑", for: .normal)
        btn.setImage(UIImage(named: "mall_address_edit_icon"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .regular)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.imagePosition(style: .left, spacing: kFitWidth(3))
        
        btn.addTarget(self, action: #selector(editAddAction), for: .touchUpInside)
        return btn
    }()
    lazy var deleteButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("删除", for: .normal)
        btn.setImage(UIImage(named: "mall_address_delete_icon"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .regular)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.imagePosition(style: .left, spacing: kFitWidth(3))
        
        btn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return btn
    }()
}

extension AddressTableViewCell{
    @objc func setDafaultAction() {
        self.setDefaultBlock?()
    }
    @objc func editAddAction() {
        self.editBlock?()
    }
    @objc func deleteAction() {
        self.deleteBlock?()
    }
}

extension AddressTableViewCell{
    func udpateUI(model:AddressModel) {
        if model.contactName.count < 1 {
            nameLabel.text = nil
            addressDetailLabel.text = nil
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [nameLabel,addressDetailLabel,setDefaultButton,deleteButton,editButton].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [nameLabel,addressDetailLabel,setDefaultButton,deleteButton,editButton].forEach { $0.hideSkeletonWithCrossfade() }
        
        updateConstrait()
        nameLabel.text = model.contactName
        phoneLabel.text = model.contactPhone
        addressDetailLabel.text = model.detailAddressWhole
        
        if model.isDefault{
            setDefaultButton.setImage(UIImage(named: "mall_address_default_icon"), for: .normal)
        }else{
            setDefaultButton.setImage(UIImage(named: "mall_address_normal_icon"), for: .normal)
        }
    }
}

extension AddressTableViewCell{
    func initUI() {
        
        contentView.addSubview(whiteView)
        whiteView.addSubview(nameLabel)
        whiteView.addSubview(phoneLabel)
        whiteView.addSubview(addressDetailLabel)
        whiteView.addSubview(lineView)
        whiteView.addSubview(deleteButton)
        whiteView.addSubview(editButton)
        whiteView.addSubview(setDefaultButton)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.top.equalTo(kFitWidth(12))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(220))
            make.height.equalTo(kFitWidth(20))
        }
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(kFitWidth(16))
            make.centerY.lessThanOrEqualTo(nameLabel)
        }
        addressDetailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(46))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(40))
            make.bottom.equalTo(kFitWidth(-47))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-39))
        }
        deleteButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-5))
            make.height.equalTo(kFitWidth(29))
            make.width.equalTo(kFitWidth(80))
        }
        editButton.snp.makeConstraints { make in
            make.right.equalTo(deleteButton.snp.left).offset(kFitWidth(-16))
            make.bottom.width.height.equalTo(deleteButton)
        }
        setDefaultButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.width.height.equalTo(deleteButton)
        }
    }
    func updateConstrait() {
        nameLabel.snp.remakeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        addressDetailLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(46))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-47))
        }
        deleteButton.snp.remakeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.top.equalTo(lineView)
        }
        editButton.snp.remakeConstraints { make in
            make.right.equalTo(deleteButton.snp.left).offset(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.top.equalTo(lineView)
        }
        setDefaultButton.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalToSuperview()
            make.top.equalTo(lineView)
        }
    }
}
