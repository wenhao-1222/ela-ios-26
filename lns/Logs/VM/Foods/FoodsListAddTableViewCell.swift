//
//  FoodsListAddTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation

class FoodsListAddTableViewCell: FeedBackTableViewCell {
    
    var choiceBlock:(()->())?
    var addBlock:(()->())?
    
    var bgColor = UIColor.COLOR_CARD_BG_WHITE
    
    
    private let selectionButton = UIButton(type: .custom)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_CARD_BG_WHITE
        contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let shouldHighlight = highlighted || isSelected
        backgroundColor = shouldHighlight ? .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT : .COLOR_CARD_BG_WHITE
        bottomView.backgroundColor = shouldHighlight ? .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT : .COLOR_CARD_BG_WHITE
//        selectionButton.backgroundColor = shouldHighlight ? .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT : .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        let shouldHighlight = selected || isHighlighted
//        backgroundColor = shouldHighlight ? .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT : .COLOR_CARD_BG_WHITE
        bottomView.backgroundColor = shouldHighlight ? .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT : .COLOR_CARD_BG_WHITE
//        selectionButton.backgroundColor = shouldHighlight ? .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT : .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
//        backgroundColor = .COLOR_CARD_BG_WHITE
        bottomView.backgroundColor = .COLOR_CARD_BG_WHITE
//        selectionButton.backgroundColor = .clear
        selectionButton.setImage(nil, for: .normal)
        selectionButton.alpha = 1
    }
    lazy var bottomView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE//WHColor_16(colorStr: "F5F5F5")
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var foodsNameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var verifyImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_foods_verify_icon")
        
        return img
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        
        return lab
    }()
    lazy var aiLabel: UILabel = {
        let lab = UILabel()
        lab.text = "AI"
        lab.textColor = .THEME
        lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        lab.layer.cornerRadius = kFitWidth(2)
        lab.clipsToBounds = true
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 10, weight: .semibold)
        lab.isHidden = true
        
        return lab
    }()
    lazy var addImgButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "foods_add_quickly_icon"), for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.isHidden = true
        return btn
    }()
    lazy var addButtonVm: FoodsAddIconVM = {//kFitWidth(72)
        let vm = FoodsAddIconVM.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(60), y: kFitWidth(11), width: 0, height: 0))
        vm.alpha = 0
        
        return vm
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_BLACK_06//WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return vi
    }()
    lazy var disabledOverlayView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.5)
        vi.isHidden = true
        vi.isUserInteractionEnabled = false
        return vi
    }()
}

extension FoodsListAddTableViewCell{
    func setSelectionDisabled(_ disabled: Bool) {
        disabledOverlayView.isHidden = !disabled
    }

    func updateSelectionAccessory(isSelected: Bool, isDisabled: Bool) {
        selectionButton.setImage(UIImage(named: isSelected ? "question_foods_selected_icon" : "question_foods_normal_icon"), for: .normal)
        selectionButton.alpha = isDisabled ? 0.45 : 1
    }

    func updateUI(dict:NSDictionary, keywords:String = "") {
        setSelectionDisabled(false)
        backgroundColor = .COLOR_CARD_BG_WHITE
        bottomView.backgroundColor = .COLOR_CARD_BG_WHITE
        addButtonVm.isHidden = true
        aiLabel.isHidden = true
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(18))
//            make.right.equalTo(kFitWidth(-50))
            make.width.equalTo(kFitWidth(300))
            make.height.equalTo(kFitWidth(18))
        }
        if dict.stringValueForKey(key: "fname").isEmpty {
            foodsNameLabel.text = nil
            numberLabel.text = nil
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [foodsNameLabel, numberLabel].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [foodsNameLabel, numberLabel].forEach { $0.hideSkeletonWithCrossfade() }
        
        updateConstrait()
        if dict["verified"]as? String ?? "\(dict["verified"]as? Int ?? 0)" == "1"{
            foodsNameLabel.attributedText = createAttributedStringWithImage(image: verifyImgView.image!, text: dict["fname"]as? String ?? "", keywords: keywords)
        }else{
            if keywords.count > 0 {
                foodsNameLabel.attributedText = createAttributedString(text: dict["fname"]as? String ?? "", keywords: keywords)
            }else{
                foodsNameLabel.text = dict["fname"]as? String ?? ""
            }
            if dict.stringValueForKey(key: "isAi") == "1"{
                foodsNameLabel.snp.remakeConstraints { make in
                    make.left.equalTo(kFitWidth(16))
                    make.top.equalTo(kFitWidth(18))
                    make.height.equalTo(kFitWidth(18))
                }
                aiLabel.isHidden = false
            }
        }
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: dict)
        numberLabel.text = "\(WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "calories")) ?? "0")千卡/\(WHUtils.convertStringToString(specDefault.stringValueForKey(key: "specNum")) ?? "0")\(specDefault["specName"]as? String ?? "")"
    }
    
    func updateUIForMeals(dict:NSDictionary) {
        setSelectionDisabled(false)
        foodsNameLabel.text = dict.stringValueForKey(key: "name")
        updateConstrait()
    }
    
    func updateUIForMy(dict:NSDictionary,keywords:String? = "") {
        setSelectionDisabled(false)
        backgroundColor = .COLOR_CARD_BG_WHITE
        bottomView.backgroundColor = .COLOR_CARD_BG_WHITE
        addButtonVm.isHidden = true
        if dict.stringValueForKey(key: "fname").isEmpty {
            foodsNameLabel.text = nil
            numberLabel.text = nil
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [foodsNameLabel, numberLabel].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [foodsNameLabel, numberLabel].forEach { $0.hideSkeletonWithCrossfade() }

        updateConstrait()
        foodsNameLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        if dict["verified"]as? String ?? "\(dict["verified"]as? Int ?? 0)" == "1"{
            foodsNameLabel.attributedText = createAttributedStringWithImage(image: verifyImgView.image!, text: dict["fname"]as? String ?? "",keywords: keywords)
        }else{
            foodsNameLabel.attributedText = createAttributedString(text: dict["fname"]as? String ?? "",keywords: keywords)
        }
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: dict)
        numberLabel.text = "\(WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "calories")) ?? "0")千卡/\(WHUtils.convertStringToString(specDefault.stringValueForKey(key: "specNum")) ?? "0")\(specDefault["specName"]as? String ?? "")"
        
    }
    
    func updateUIForHistory(dict:NSDictionary,keywords:String? = "") {
        setSelectionDisabled(false)
        backgroundColor = .COLOR_CARD_BG_WHITE
        bottomView.backgroundColor = .COLOR_CARD_BG_WHITE
//        addButtonVm.isHidden = true
        if dict.stringValueForKey(key: "fname").isEmpty {
            foodsNameLabel.text = nil
            numberLabel.text = nil
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [foodsNameLabel, numberLabel].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [foodsNameLabel, numberLabel].forEach { $0.hideSkeletonWithCrossfade() }
        updateConstrait()
        UIView.animate(withDuration: 0.15, animations: {
            self.addButtonVm.alpha = 1
        })
        if dict.stringValueForKey(key: "qty") == "" || dict.stringValueForKey(key: "qty") == "0"{
            let foodsDict = dict["foods"]as? NSDictionary ?? [:]
            if foodsDict["verified"]as? String ?? "\(foodsDict["verified"]as? Int ?? 0)" == "1"{
                foodsNameLabel.attributedText = createAttributedStringWithImage(image: verifyImgView.image!, text: foodsDict["fname"]as? String ?? "",keywords: keywords)
            }else{
                foodsNameLabel.attributedText = createAttributedString(text: foodsDict["fname"]as? String ?? "",keywords: keywords)
            }
            
            let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsDict)
            
            numberLabel.text = "\(WHUtils.convertStringToStringNoDigit(foodsDict.stringValueForKey(key: "calories")) ?? "0")千卡/\(WHUtils.convertStringToString(specDefault.stringValueForKey(key: "specNum")) ?? "0")\(specDefault["specName"]as? String ?? "")"
        }else{
            let foodsDict = dict["foods"]as? NSDictionary ?? [:]
            if foodsDict["verified"]as? String ?? "\(foodsDict["verified"]as? Int ?? 0)" == "1"{
                foodsNameLabel.attributedText = createAttributedStringWithImage(image: verifyImgView.image!, text: foodsDict["fname"]as? String ?? "",keywords: keywords)
            }else{
                foodsNameLabel.attributedText = createAttributedString(text: foodsDict["fname"]as? String ?? "",keywords: keywords)
            }
            numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(dict.doubleValueForKey(key: "calories"))") ?? "0")千卡/\(WHUtils.convertStringToString(dict.stringValueForKey(key: "qty")) ?? "0")\(dict["spec"]as? String ?? "")"
        }
        
    }
    
    func boldKeywords(nameString:NSString,keywords:String) -> NSAttributedString{
        if nameString.contains(keywords){
            let range = nameString.range(of: keywords)
            
            let a = NSMutableAttributedString(
                string: nameString.substring(with: NSRange(location: 0, length: range.location)),
                attributes: [.foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214]
            )
            a.append(NSMutableAttributedString(
                string: keywords,
                attributes: [.foregroundColor: UIColor.THEME]
            ))
            a.append(NSMutableAttributedString(
                string: nameString.substring(from: range.location+range.length),
                attributes: [.foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214]
            ))
            
            return a
        }else{
            let a = NSMutableAttributedString(
                string: nameString as String,
                attributes: [.foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214]
            )
            return a
        }
    }
    
    func createAttributedStringWithImage(image: UIImage, text: String,keywords:String? = "") -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .medium).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        var a = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214]
        )
        if keywords?.count ?? 0 > 0 {
            a = NSMutableAttributedString(attributedString: self.boldKeywords(nameString: a.string as NSString,keywords:keywords ?? ""))
        }
        a.append(attachmentString)
        
        return a
    }
    func createAttributedString(text: String,keywords:String? = "") -> NSAttributedString {
        var string = NSMutableAttributedString(string: text)
        
        if keywords?.count ?? 0 > 0 {
            string = NSMutableAttributedString(attributedString: self.boldKeywords(nameString: string.string as NSString,keywords:keywords ?? ""))
        }
        
        return string
    }
}

extension FoodsListAddTableViewCell{
    func initUI() {
        contentView.addSubview(bottomView)
        bottomView.addSubview(foodsNameLabel)
        bottomView.addSubview(aiLabel)

        bottomView.addSubview(numberLabel)
        bottomView.addSubview(addButtonVm)
        bottomView.addSubview(lineView)
        bottomView.addSubview(disabledOverlayView)
        bottomView.addSubview(selectionButton)
        selectionButton.backgroundColor = .clear
        selectionButton.isUserInteractionEnabled = false
        
        setConstrait()
    }
    func setConstrait() {
        bottomView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(18))
            make.width.equalTo(kFitWidth(300))
            make.height.equalTo(kFitWidth(18))
        }
        aiLabel.snp.makeConstraints { make in
            make.left.equalTo(foodsNameLabel.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(foodsNameLabel)
            make.width.equalTo(kFitWidth(18))
            make.height.equalTo(kFitWidth(13))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(42))
            make.width.equalTo(kFitWidth(180))
            make.height.equalTo(kFitWidth(18))
        }
        selectionButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
        }
        disabledOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func updateConstrait() {
        foodsNameLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(18))
            make.right.equalTo(kFitWidth(-50))
        }
        numberLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(42))
        }
    }
    func updateConstraitForNextMeal() {
        self.backgroundColor = .clear
        bottomView.layer.cornerRadius = kFitWidth(12)
        bottomView.clipsToBounds = true
        lineView.isHidden = true
        bottomView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(21))
            make.top.equalTo(kFitWidth(12))
            make.bottom.equalTo(kFitWidth(-12))
            make.right.equalTo(kFitWidth(-21))
        }
        foodsNameLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-50))
        }
        numberLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(foodsNameLabel.snp.bottom).offset(kFitWidth(2))
        }
    }
}
