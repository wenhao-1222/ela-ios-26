//
//  PublishPollMultipleAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/18.
//


class PublishPollMultipleAlertVM: UIView {
    
    let whiteViewWidth = kFitWidth(100)
    var dataArrayForShow = NSMutableArray()
    var selectIndex = 0
    var selectNum = 2
    var vmDataArray = [QuestionnairePlanFoodsTypeItemVM]()
    
    var numChoiceBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "updateBodyDataSetting"), object: nil)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
    lazy var scrollViewBase: UIScrollView = {
        let scro = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: whiteViewWidth, height: kFitWidth(48)*5))
        scro.backgroundColor = .white
        scro.showsVerticalScrollIndicator = true
        return scro
    }()
}

extension PublishPollMultipleAlertVM{
    @objc func showView(){
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
    }
    @objc func hiddenSelf(){
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    func initDataArray(num:Int)  {
        if num < 2{
            return
        }
        dataArrayForShow.removeAllObjects()
        for i in 2...num{
            dataArrayForShow.add("\(i)")
        }
        
        if dataArrayForShow.count < 5 {
            whiteView.frame = CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-whiteViewWidth, y: WHUtils().getNavigationBarHeight()+kFitWidth(126), width: whiteViewWidth, height: kFitWidth(48)*CGFloat(dataArrayForShow.count))
//            scrollViewBase.frame = whiteView.bounds
            scrollViewBase.contentSize = CGSize.init(width: 0, height: 0)
        }else{
            whiteView.frame = CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-whiteViewWidth, y: WHUtils().getNavigationBarHeight()+kFitWidth(126), width: whiteViewWidth, height: kFitWidth(48)*CGFloat(4)+kFitWidth(24))
//            scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: whiteViewWidth, height: kFitWidth(48)*5)
            scrollViewBase.contentSize = CGSize.init(width: 0, height: kFitWidth(48)*CGFloat(dataArrayForShow.count))
        }
        scrollViewBase.frame = whiteView.bounds
        initAlertView()
    }
    func setSelectStatus(daysIndex:Int) {
        for vm in vmDataArray{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        let vm = vmDataArray[daysIndex]
        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
        
        selectIndex = daysIndex
        selectNum = (self.dataArrayForShow[self.selectIndex] as! String).intValue
        if self.numChoiceBlock != nil{
            self.numChoiceBlock!(self.dataArrayForShow[self.selectIndex] as! String)
        }
    }
}


extension PublishPollMultipleAlertVM{
    func initUI()  {
        addSubview(whiteView)
        whiteView.addSubview(scrollViewBase)
        whiteView.addShadow()
//        updateUI()
        initDataArray(num: 3)
    }
    
    func initAlertView()  {
        vmDataArray.removeAll()
        for vi in scrollViewBase.subviews{
            vi.removeFromSuperview()
        }
        for i in 0..<dataArrayForShow.count{
            let num = dataArrayForShow[i]as? String ?? ""
            let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(i), width: 0, height: 0))
            vm.frame = CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(i), width: whiteViewWidth, height: vm.selfHeight)
            vm.titleLabel.text = "\(num)"
            vm.titleLabel.textAlignment = .center
            
            if i == selectIndex {
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
            }else{
                vm.selectImgView.isHidden = true
                vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
            }
            scrollViewBase.addSubview(vm)
            vmDataArray.append(vm)
            
            vm.tapBlock = {()in
                self.setSelectStatus(daysIndex: i)
                self.hiddenSelf()
            }
        }
        
    }
}
