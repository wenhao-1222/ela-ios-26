//
//  DataDetailTimeTypeFilterAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/9/27.
//


import UIKit

class DataDetailTimeTypeFilterAlertVM: UIView {
    
    var choiceBlock:((NSDictionary)->())?
    
    var dataArrayForShow = [["qtype":"0","name":"全部"],
                     ["qtype":"1","name":"一周"],
                     ["qtype":"3","name":"1个月"],
                     ["qtype":"4","name":"2个月"],
                     ["qtype":"5","name":"3个月"],
                     ["qtype":"6","name":"6个月"],
                     ["qtype":"7","name":"1年"]]
    var selectIndex = 0
    
    var vmDataArray = [QuestionnairePlanFoodsTypeItemVM]()
    
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
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        return vi
    }()
}


extension DataDetailTimeTypeFilterAlertVM{
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
    func setSelectStatus(daysIndex:Int) {
        for vm in vmDataArray{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        let vm = vmDataArray[daysIndex]
        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
        
        let dict = dataArrayForShow[daysIndex] as NSDictionary
        
        selectIndex = daysIndex
        
        if self.choiceBlock != nil{
            self.choiceBlock!(dict)
        }
    }
    func setSelectIndex(index:Int) {
        for vm in vmDataArray{
            vm.selectImgView.isHidden = true
            vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        }
        selectIndex = index
        let vm = vmDataArray[index]
        vm.selectImgView.isHidden = false
        vm.titleLabel.textColor = .THEME
    }
}


extension DataDetailTimeTypeFilterAlertVM{
    func initUI()  {
        addSubview(whiteView)
        whiteView.frame = CGRect.init(x: kFitWidth(16), y: WHUtils().getNavigationBarHeight()+kFitWidth(64), width: kFitWidth(200), height: kFitWidth(48)*CGFloat(dataArrayForShow.count))
        
        let whiteViewCenter = whiteView.center
        whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: whiteViewCenter.y)
        
        whiteView.addShadow()
        
        initAlertView()
    }
    func initAlertView()  {
        vmDataArray.removeAll()
        for vi in whiteView.subviews{
            vi.removeFromSuperview()
        }
        for i in 0..<dataArrayForShow.count{
            let dict = dataArrayForShow[i]
            let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*CGFloat(i), width: 0, height: 0))
            vm.titleLabel.text = "\(dict["name"] ?? "")"
            
            if i == selectIndex {
                vm.selectImgView.isHidden = false
                vm.titleLabel.textColor = .THEME
            }else{
                vm.selectImgView.isHidden = true
                vm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
            }
            whiteView.addSubview(vm)
//            vm.tag = 1050 + i
            vmDataArray.append(vm)
            
            vm.tapBlock = {()in
                self.setSelectStatus(daysIndex: i)
                self.hiddenSelf()
            }
        }
        
    }
}
