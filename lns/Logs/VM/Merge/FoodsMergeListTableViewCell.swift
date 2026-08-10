//
//  FoodsMergeListTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/3/14.
//



class FoodsMergeListTableViewCell: UITableViewCell {
    
    var editBlock:(()->())?
    var deleteBlock:(()->())?
    var actionViewWillShowBlock:(()->())?
    private(set) var isActionViewShown = false
    let btnWidth = kFitWidth(72)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_FA//.COLOR_GRAY_F7F8FA
        self.selectionStyle = .none
        self.layer.cornerRadius = kFitWidth(12)
        self.clipsToBounds = true
        initUI()
    }
    /// 核心代码！
    override func layoutSubviews() {
        super.layoutSubviews()
        /// 查找承载侧滑的父视图
        if let superView = self.superview, NSStringFromClass(superView.classForCoder) == "_UITableViewCellSwipeContainerView" {
            /// 修改Cell圆角样式
            let maskPath = UIBezierPath(roundedRect: superView.bounds, cornerRadius: kFitWidth(12))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = superView.bounds
            maskLayer.path = maskPath.cgPath
            superView.layer.mask = maskLayer
            /// 查找侧滑删除摁钮视图
            if let subView = superView.subviews.first, NSStringFromClass(subView.classForCoder) == "UISwipeActionPullView" {
                /// 修改侧滑视图背景色和摁钮背景色
//                subView.backgroundColor = UIColor.design(.design_FF5050)
//                let btn = subView.subviews.last
//                btn?.backgroundColor = UIColor.design(.design_FF5050)
            }
        }
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
//        contentView.backgroundColor = editing ? .lightGray : .white
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        manualEdit(isEdit: false, animated: false)
    }
    lazy var editButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("编辑", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .COLOR_BG_BLACK_65//.COLOR_GRAY_C4C4C4
        btn.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var deleteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("删除", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemRed
        btn.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5_FITNESS//.COLOR_GRAY_F7F8FA
        vi.isUserInteractionEnabled = true
        // 创建下拉手势识别器
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
//        // 将手势识别器添加到view
//        vi.addGestureRecognizer(panGestureRecognizer)
        return vi
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var weightLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var naturalLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 2
        lab.adjustsFontSizeToFitWidth = true
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var digitEditImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_merge_edit_digit_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var editTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(editTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension FoodsMergeListTableViewCell{
    func updateUI(dict:NSDictionary) {
        DLLog(message: "FoodsMergeListTableViewCell:\(dict)")
        manualEdit(isEdit: false, animated: false)
        nameLabel.text = dict.stringValueForKey(key: "fname")
        weightLabel.text = "\(dict.stringValueForKey(key: "qty"))\(dict.stringValueForKey(key: "spec"))"
        naturalLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(dict.stringValueForKey(key: "calories"))") ?? "0")千卡" +
        "｜碳水\(WHUtils.convertStringToStringOneDigit(dict.stringValueForKey(key: "carbohydrate")) ?? "0")g" +
        "｜蛋白质\(WHUtils.convertStringToStringOneDigit(dict.stringValueForKey(key: "protein")) ?? "0")g" +
        "｜脂肪\(WHUtils.convertStringToStringOneDigit(dict.stringValueForKey(key: "fat")) ?? "0")g"
        
        if dict.stringValueForKey(key: "fname") == "快速添加"{
            if dict.stringValueForKey(key: "ctype") == "3"{//以“快速添加”的方式添加到日志/计划/食谱，但展示时不显示“快速添加”，百而直接显示放到remark的食物名称
                nameLabel.text = "\(dict.stringValueForKey(key: "remark"))"
            }else if dict.stringValueForKey(key: "remark").count > 0 {
                nameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
            }
        }
    }
    @objc func editTapAction() {
        let needShow = !isActionViewShown
        if needShow {
            actionViewWillShowBlock?()
        }
        manualEdit(isEdit: needShow)
    }
    @objc func editButtonAction() {
        manualEdit(isEdit: false)
        editBlock?()
    }
    @objc func deleteButtonAction() {
        deleteBlock?()
    }
    func manualEdit(isEdit:Bool, animated: Bool = true) {
        isActionViewShown = isEdit
        let leftOffset = isEdit ? -btnWidth * 2 : 0
        bgView.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(leftOffset)
        }
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.contentView.layoutIfNeeded()
            }
        }else{
            contentView.layoutIfNeeded()
        }
    }
}

extension FoodsMergeListTableViewCell{
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            var isScrollLeft = true
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: bgView)
                DLLog(message: "translation.x:\(translation.x)")
                
//                if translation.x > 0 {
//                    isScrollLeft = false
//                }else if translation.x < 0 {
//                    isScrollLeft = true
//                }
                if translation.x < 0 && bgView.frame.maxX - kFitWidth(5) <= bgView.frame.width - self.btnWidth*2{
                    return
                }
                if translation.x > 0 && bgView.frame.minX + kFitWidth(5) > 0{
                    return
                }
                bgView.center = CGPoint(x: bgView.jf_width*0.5 + translation.x, y: bgView.center.y)
                gesture.setTranslation(.zero, in: bgView)
            case .ended:
                DLLog(message: "isScrollLeft:\(isScrollLeft)")
//                self.manualEdit(isEdit: isScrollLeft)
                break
            default:
                break
            }
        }
    }
}

extension FoodsMergeListTableViewCell{
    func initUI() {
        contentView.layer.cornerRadius = kFitWidth(12)
        contentView.clipsToBounds = true
        
        contentView.addSubview(deleteButton)
        contentView.addSubview(editButton)
        contentView.addSubview(bgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(weightLabel)
        bgView.addSubview(naturalLabel)
        bgView.addSubview(digitEditImgView)
        bgView.addSubview(editTapView)
        
        setConstrait()
    }
    func setConstrait() {
        deleteButton.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(btnWidth)
        }
        editButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(deleteButton)
            make.right.equalTo(deleteButton.snp.left)
        }
        bgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(210))
        }
        weightLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-27))
            make.centerY.lessThanOrEqualTo(nameLabel)
            make.width.equalTo(kFitWidth(78))
        }
        naturalLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(4))
            make.right.equalTo(kFitWidth(-27))
            make.bottom.equalTo(kFitWidth(-16))
        }
        digitEditImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-12))
            make.width.equalTo(kFitWidth(3))
            make.height.equalTo(kFitWidth(15))
        }
        editTapView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(27))
        }
    }
}
