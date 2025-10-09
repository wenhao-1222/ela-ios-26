//
//  SportHealthDataExampleAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/16.
//


class SportHealthDataExampleAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(360) + kFitWidth(30) + kFitWidth(48)
    var confirmBlock:(()->())?
    
    var historyModel = SportHistoryModel()
    var isSyn = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
//        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: kFitWidth(343), height: whiteViewHeight))
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(16)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "首页营养目标"
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        return lab
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
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        return vi
    }()
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("我知道了", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
    
}

extension SportHealthDataExampleAlertVM{
    func showView(sportNum:String){
        goalNoSynVm.updateUIForSportExample(targetNum: "2000", sportCalories: "0")
        goalSynVm.updateUIForSportExample(targetNum: "2000", sportCalories: sportNum)
        
        self.isHidden = false
        whiteView.alpha = 0
        self.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
        UIView.animate(withDuration: 0.4, delay: 0.1,options: .curveLinear) {
            self.alpha = 1
        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.alpha = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0.2,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { c in
            self.isHidden = true
        }
    }
    @objc func nothingToDo() {
        
    }
}

extension SportHealthDataExampleAlertVM{
    func initUI() {
        addSubview(whiteView)
        
        whiteView.addSubview(titleLab)
        
        whiteView.addSubview(noSynBottomView)
        noSynBottomView.addSubview(goalNoSynVm)
        noSynBottomView.addSubview(noSynLabel)
        
        whiteView.addSubview(synBottomView)
        synBottomView.addSubview(goalSynVm)
        synBottomView.addSubview(synLabel)
        
        whiteView.addSubview(lineView)
        whiteView.addSubview(confirmBtn)
        
        setConstrait()
        
        let goalVmFrame = self.goalNoSynVm.frame
        goalNoSynVm.frame = CGRect.init(x: kFitWidth(-16), y: kFitWidth(10), width: kFitWidth(343), height: goalVmFrame.size.height)
        
        let goalSynVmFrame = self.goalSynVm.frame
        goalSynVm.frame = CGRect.init(x: kFitWidth(-16), y: kFitWidth(10), width: kFitWidth(343), height: goalSynVmFrame.size.height)
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
        }
//        UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: kFitWidth(343), height: whiteViewHeight))
        whiteView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(whiteViewHeight)
        }
        noSynBottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(42))
            make.height.equalTo(kFitWidth(160))
        }
        noSynLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(4))
        }
        synBottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(noSynBottomView.snp.bottom).offset(kFitWidth(8))
            make.height.equalTo(noSynBottomView)
        }
        synLabel.snp.makeConstraints { make in
            make.left.equalTo(noSynLabel)
            make.top.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-48))
        }
        confirmBtn.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
        }
    }
}
