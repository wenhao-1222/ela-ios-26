//
//  DataDetailTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/4/18.
//

import Foundation

class DataDetailTableViewCell: UITableViewCell {
    
    var imgTapBlock:(()->())?
    var scrollBlock:((CGFloat)->())?
    var tapBlock:(()->())?
    
    var imagesTapBlock:((NSArray)->())?
    
    let itemsWidth = SCREEN_WIDHT-kFitWidth(147)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUIFrame), name: NSNotification.Name(rawValue: "updateBodyDataSetting"), object: nil)
        
        initUI()
    }
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        // 允许 scrollView 与 tableView 同时识别
//        return true
//    }
//
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        // 如果是 tableView 的左滑手势（用于显示删除），优先让它识别
//        if let other = otherGestureRecognizer as? UISwipeGestureRecognizer,
//           other.direction == .left {
//            return true
//        }
//        return false
//    }
////
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        // 判断滑动方向，只有水平滑动时 scrollView 才响应
//        if gestureRecognizer == contentScrollView.panGestureRecognizer {
//            let velocity = contentScrollView.panGestureRecognizer.velocity(in: contentScrollView)
//            return abs(velocity.x) > abs(velocity.y)
//        }
//        return true
//    }
    lazy var timeLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(4), width: kFitWidth(94), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.backgroundColor = .clear
        
        return lab
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scro = UIScrollView(frame: CGRect.init(x: kFitWidth(90), y: 0, width: SCREEN_WIDHT-kFitWidth(147), height: kFitWidth(44)))
        scro.backgroundColor = .white
        scro.isUserInteractionEnabled = true
        scro.bounces = false
        scro.delegate = self
//        scro.panGestureRecognizer.delegate = self
        scro.showsHorizontalScrollIndicator = false
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        scro.addGestureRecognizer(tap)
        
        return scro
    }()
    lazy var weightLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(94), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(4), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var yaoLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(150), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(60), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var tunLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(206), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(116), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var armLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(262), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(172), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        
        return lab
    }()
    lazy var shoulderLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(262), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(228), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        lab.isHidden = true
        
        return lab
    }()
    lazy var bustLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(262), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(284), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        lab.isHidden = true
        
        return lab
    }()
    lazy var thighLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(262), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(340), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        lab.isHidden = true
        
        return lab
    }()
    lazy var calfLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(262), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(396), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        lab.isHidden = true
        
        return lab
    }()
    lazy var bfpLabel : UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(262), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(452), y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40)))
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = .clear
        lab.isHidden = true
        
        return lab
    }()
    lazy var photoImgView : FeedBackUIImageView = {
        let img = FeedBackUIImageView()
        img.layer.cornerRadius = kFitWidth(4)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.setImgLocal(imgName: "data_photo_default")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var tapView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT - kFitWidth(55), height: kFitWidth(44)))
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var imgVm: DataDetailCellImageVM = {
        let vm = DataDetailCellImageVM.init(frame: .zero)
        
        vm.tapBlock = {()in
            if self.imagesTapBlock != nil{
                self.imagesTapBlock!(self.imgVm.imgUrls)
            }
        }
        
        return vm
    }()
}

extension DataDetailTableViewCell{
    func updateUI(dict:NSDictionary) {
        var imageArr : NSArray = [[],[],[]]
        if (dict["images"]as? String ?? "").count > 0 {
            //本地数据库 数据  存的是images 字符串
            imageArr = WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "images"))
        }else{
            //服务器数据，返回的是image 数组
            imageArr = dict["image"]as? NSArray ?? [[],[],[]]
        }
        timeLabel.text = Date().changeDateFormatter(dateString: dict["ctime"]as? String ?? "", formatter: "yyyy-MM-dd", targetFormatter: "yyyy-MM-dd")
        
        if dict.doubleValueForKey(key: "weight") > 0 {
            var num = (dict.doubleValueForKey(key: "weight") * UserInfoModel.shared.weightCoefficient)
            num = String(format: "%.1f",(num * 10).rounded()/10).doubleValue
            weightLabel.text = "\(WHUtils.convertStringToStringOneDigit("\(num)") ?? "-")"
        }else{
            weightLabel.text = "-"
        }
        if dict.doubleValueForKey(key: "waistline") > 0 {
            yaoLabel.text = "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "waistline"))") ?? "-")"
        }else{
            yaoLabel.text = "-"
        }
        if dict.doubleValueForKey(key: "hips") > 0 {
            tunLabel.text = "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "hips"))") ?? "-")"
        }else{
            tunLabel.text = "-"
        }
        if dict.doubleValueForKey(key: "armcircumference") > 0 {
            armLabel.text = "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "armcircumference"))") ?? "-")"
        }else{
            armLabel.text = "-"
        }
        
        if dict.doubleValueForKey(key: "shoulder") > 0 {
            shoulderLabel.text = "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "shoulder"))") ?? "-")"
        }else{
            shoulderLabel.text = "-"
        }
        
        if dict.doubleValueForKey(key: "bust") > 0 {
            bustLabel.text = "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "bust"))") ?? "-")"
        }else{
            bustLabel.text = "-"
        }
        
        if dict.doubleValueForKey(key: "thigh") > 0 {
            thighLabel.text = "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "thigh"))") ?? "-")"
        }else{
            thighLabel.text = "-"
        }
        
        if dict.doubleValueForKey(key: "calf") > 0 {
            calfLabel.text = "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "calf"))") ?? "-")"
        }else{
            calfLabel.text = "-"
        }
        if dict.doubleValueForKey(key: "bfp") > 0 {
            bfpLabel.text = "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "bfp"))") ?? "-")"
        }else{
            bfpLabel.text = "-"
        }
        
        imgVm.updateUI(imgs: imageArr)
    }
    
    @objc func imgTapAction() {
        if self.imgTapBlock != nil{
            self.imgTapBlock!()
        }
    }
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}
extension DataDetailTableViewCell{
    func initUI() {
        contentView.addSubview(timeLabel)
        
        contentView.addSubview(contentScrollView)
        contentScrollView.addSubview(weightLabel)
        contentScrollView.addSubview(yaoLabel)
        contentScrollView.addSubview(tunLabel)
        contentScrollView.addSubview(armLabel)
        contentScrollView.addSubview(shoulderLabel)
        contentScrollView.addSubview(bustLabel)
        contentScrollView.addSubview(thighLabel)
        contentScrollView.addSubview(calfLabel)
        contentScrollView.addSubview(bfpLabel)
        contentView.addSubview(imgVm)
        refreshUIFrame()
//        setConstrait()
    }
    func setConstrait() {
        photoImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(kFitWidth(24))
        }
    }
    @objc func refreshUI() {
        var originX = shoulderLabel.frame.minX
        let settingMsgDict = UserDefaults().getBodyDataSetting()
        if settingMsgDict.stringValueForKey(key: "shoulder") == "1"{
            shoulderLabel.isHidden = false
            originX = originX + kFitWidth(56)
        }else{
            shoulderLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "bust") == "1"{
            bustLabel.isHidden = false
            bustLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40))
            originX = originX + kFitWidth(56)
        }else{
            bustLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "thigh") == "1"{
            thighLabel.isHidden = false
            thighLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40))
            originX = originX + kFitWidth(56)
        }else{
            thighLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "calf") == "1"{
            calfLabel.isHidden = false
            calfLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40))
            originX = originX + kFitWidth(56)
        }else{
            calfLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "bfp") == "1"{
            bfpLabel.isHidden = false
            bfpLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: kFitWidth(56), height: kFitWidth(40))
            originX = originX + kFitWidth(56)
        }else{
            bfpLabel.isHidden = true
        }
        
        contentScrollView.contentSize = CGSize.init(width: originX, height: 0)
    }
    @objc func refreshUIFrame() {
        let settingMsgDict = UserDefaults().getBodyDataSetting()
        var showItemNum = 4
        if settingMsgDict.stringValueForKey(key: "shoulder") == "1"{
            showItemNum = showItemNum + 1
        }
        if settingMsgDict.stringValueForKey(key: "bust") == "1"{
            showItemNum = showItemNum + 1
        }
        if settingMsgDict.stringValueForKey(key: "thigh") == "1"{
            showItemNum = showItemNum + 1
        }
        if settingMsgDict.stringValueForKey(key: "calf") == "1"{
            showItemNum = showItemNum + 1
        }
        
        let labelWidth = max(itemsWidth/CGFloat(showItemNum), kFitWidth(56))
        
        weightLabel.frame = CGRect.init(x: kFitWidth(4), y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
        yaoLabel.frame = CGRect.init(x: weightLabel.frame.maxX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
        tunLabel.frame = CGRect.init(x: yaoLabel.frame.maxX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
        armLabel.frame = CGRect.init(x: tunLabel.frame.maxX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
        
        var originX = armLabel.frame.maxX
        if settingMsgDict.stringValueForKey(key: "shoulder") == "1"{
            shoulderLabel.isHidden = false
            shoulderLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            shoulderLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "bust") == "1"{
            bustLabel.isHidden = false
            bustLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            bustLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "thigh") == "1"{
            thighLabel.isHidden = false
            thighLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            thighLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "calf") == "1"{
            calfLabel.isHidden = false
            calfLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            calfLabel.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "bfp") == "1"{
            bfpLabel.isHidden = false
            bfpLabel.frame = CGRect.init(x: originX, y: kFitWidth(4), width: labelWidth, height: kFitWidth(40))
            originX = originX + labelWidth//kFitWidth(56)
            showItemNum = showItemNum + 1
        }else{
            bfpLabel.isHidden = true
        }
        
        contentScrollView.contentSize = CGSize.init(width: originX, height: 0)
    }
}

extension DataDetailTableViewCell:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.x >= calfLabel.frame.maxX{
//            self.contentScrollView.isUserInteractionEnabled = false
//        }else{
//            self.contentScrollView.isUserInteractionEnabled = true
            if self.scrollBlock != nil{
                self.scrollBlock!(scrollView.contentOffset.x)
            }
//        }
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == contentScrollView.panGestureRecognizer else {
            return true
        }
        let translation = contentScrollView.panGestureRecognizer.translation(in: contentScrollView)
        if translation.x < 0 {
            let maxOffsetX = contentScrollView.contentSize.width - contentScrollView.bounds.width
            if contentScrollView.contentOffset.x >= maxOffsetX {
                return false
            }
        }
        return true
    }

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
