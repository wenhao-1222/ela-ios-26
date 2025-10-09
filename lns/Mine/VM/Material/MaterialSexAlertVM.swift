//
//  MaterialSexAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/11.
//

import Foundation

class MaterialSexAlertVM: FeedBackView {
    
    let sexArray = ["男","女","保密"]
    var gender = "1"
    var sex = "男"
    var confirmBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.alpha = 0
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(260)-WHUtils().getBottomSafeAreaHeight(), width: SCREEN_WIDHT, height: kFitWidth(260)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(16)))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var closeButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
    lazy var confirmButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "选择性别"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        
        return picker
    }()
}

extension MaterialSexAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(lineView)
        whiteView.addSubview(pickerView)
        
        setConstrait()
    }
    
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(55))
            make.height.equalTo(kFitWidth(1))
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(lineView)
        }
        closeButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.bottom.equalTo(lineView)
            make.width.equalTo(kFitWidth(56))
        }
        confirmButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.bottom.width.equalTo(closeButton)
        }
        pickerView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(lineView.snp.bottom)
            make.width.equalTo(kFitWidth(343))
        }
    }
}


extension MaterialSexAlertVM{
    @objc func showView() {
        self.isHidden = false
        let whiteViewFrame = self.whiteView.frame
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.alpha = 1
            self.whiteView.alpha = 1
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-whiteViewFrame.height+kFitWidth(16), width: SCREEN_WIDHT, height: whiteViewFrame.height)
        }
    }
    @objc func hiddenView() {
        let whiteViewFrame = self.whiteView.frame
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.alpha = 0
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewFrame.height)
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func nothingToDo() {
        
    }
    @objc func confirmAction(){
        if self.confirmBlock != nil{
            self.confirmBlock!(self.gender)
        }
        self.hiddenView()
    }
}

extension MaterialSexAlertVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sexArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sexArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.sex = sexArray[row]
        if row == 0 {
            self.gender = "1"
        }else if row == 1{
            self.gender = "2"
        }else{
            self.gender = "3"
        }
    }
}
