//
//  SportHealthDataUpdateAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/16.
//



class SportHealthDataUpdateAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(190) + WHUtils().getBottomSafeAreaHeight()// + kFitWidth(340)
    var confirmBlock:(()->())?
    
    var tipsTapBlock:((String)->())?
    
    var historyModel = SportHistoryModel()
    var isSyn = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(10))
        vi.backgroundColor = .white
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "运动消耗"
//        lab.text = "来自于苹果\"健康\"APP"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var confirmBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    lazy var metsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()
    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "-数据来自于苹果\"健康\"体能训练"
        return lab
    }()
    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "是否计入当日营养目标"
        
        return lab
    }()
    lazy var alertButton : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.setBackgroundImage(UIImage.init(named: "tips_gray_icon"), for: .normal)
        btn.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var switchButton: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-SwitchButton().selfWidth, y: (whiteViewHeight-SwitchButton().selfHeight)*0.5, width: 0, height: 0))
        btn.tapBlock = {(isSelect)in
            self.switchButton.setSelectStatus(status: isSelect)
            self.isSyn = isSelect
        }
        return btn
    }()
    lazy var noSynBottomView: UIView = {
        let vi = UIView()
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var noSynLabel: UILabel = {
        let lab = UILabel()
        lab.text = "1、未计入营养目标（例：营养目标为2000千卡）"
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var goalNoSynVm : MainTopMsgVM = {
        let vm = MainTopMsgVM.init(frame: .zero)
        
        return vm
    }()
    lazy var synBottomView: UIView = {
        let vi = UIView()
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var synLabel: UILabel = {
        let lab = UILabel()
        lab.text = "2、计入营养目标（例：营养目标为2000千卡）"
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var goalSynVm : MainTopMsgVM = {
        let vm = MainTopMsgVM.init(frame: .zero)
        
        return vm
    }()
}

extension SportHealthDataUpdateAlertVM{
    func updateUIForHistort(sModel:SportHistoryModel) {
        self.historyModel = sModel
        nameLabel.text = sModel.name
        metsLabel.text = "\(Int(sModel.calories.doubleValue.rounded()))千卡 / \(sModel.duration)分钟"
        
        switchButton.setSelectStatus(status: self.historyModel.isSyn)
        self.isSyn = self.historyModel.isSyn
        
//        goalNoSynVm.updateUIForSportExample(targetNum: "2000", sportCalories: "0")
//        goalSynVm.updateUIForSportExample(targetNum: "2000", sportCalories: "\(Int(sModel.calories.doubleValue.rounded()))")
//        caloriesLabel.text = "消耗：\(Int(sModel.calories.doubleValue.rounded()))千卡"
    }
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.whiteViewHeight)
        } completion: { t in
//            self.alpha = 0
            self.isHidden = true
            self.backgroundColor = .clear
        }
    }
    func showSelf() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.whiteViewHeight, width: SCREEN_WIDHT, height: self.whiteViewHeight)
        } completion: { t in
        }
    }
    @objc func nothingToDo() {
        
    }
    @objc func tipsTapAction() {
        if self.tipsTapBlock != nil{
            self.tipsTapBlock!("\(Int(self.historyModel.calories.doubleValue.rounded()))")
        }
    }
    @objc func confirmAction() {
        if self.confirmBlock != nil{
            self.confirmBlock!()
        }
        self.hiddenSelf()
    }
}

extension SportHealthDataUpdateAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(lineView)
        
        whiteView.addSubview(nameLabel)
        whiteView.addSubview(metsLabel)
        whiteView.addSubview(caloriesLabel)
        
        whiteView.addSubview(detailLabel)
        whiteView.addSubview(alertButton)
        whiteView.addSubview(switchButton)
        
//        whiteView.addSubview(noSynBottomView)
//        noSynBottomView.addSubview(noSynLabel)
//        noSynBottomView.addSubview(goalNoSynVm)
//        
//        whiteView.addSubview(synBottomView)
//        synBottomView.addSubview(synLabel)
//        synBottomView.addSubview(goalSynVm)
        
        setConstrait()
        
//        let goalFrame = goalNoSynVm.frame
//        goalNoSynVm.frame = CGRect.init(x: 0, y: kFitWidth(30), width: SCREEN_WIDHT, height: goalNoSynVm.selfHeight)
//        goalSynVm.frame = CGRect.init(x: 0, y: kFitWidth(30), width: SCREEN_WIDHT, height: goalSynVm.selfHeight)
        
    }
    
    func setConstrait()  {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(56))
        }
        cancelBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(56))
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(cancelBtn)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(56))
            make.height.equalTo(kFitWidth(1))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(24))
        }
        metsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(54))
        }
        caloriesLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(metsLabel)
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(90))
        }
        alertButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(detailLabel)
            make.left.equalTo(detailLabel.snp.right).offset(kFitWidth(4))
            make.width.height.equalTo(kFitWidth(16))
        }
        switchButton.snp.remakeConstraints { make in
            make.centerY.lessThanOrEqualTo(detailLabel)
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(28))
        }
//        noSynBottomView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(detailLabel.snp.bottom).offset(kFitWidth(12))
//            make.height.equalTo(kFitWidth(170))
//        }
//        noSynLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(kFitWidth(14))
//        }
//        synBottomView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(noSynBottomView.snp.bottom).offset(kFitWidth(8))
//            make.height.equalTo(noSynBottomView)
//        }
//        synLabel.snp.makeConstraints { make in
//            make.left.equalTo(noSynLabel)
//            make.top.equalToSuperview()
//        }
    }
}
