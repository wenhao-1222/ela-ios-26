//
//  LogsMealsAlertSetWeekVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/15.
//


class LogsMealsAlertSetWeekVM: UIView {
    
    let selfHeight = kFitWidth(50)
    
    let btnGap = kFitWidth(12)
    let leftGap = kFitWidth(16)
    
    var btnWidth = kFitWidth(0)
    
    let weekDayTitleArray = ["一","二","三","四","五","六","日"]
    var btnArray:[FeedBackButton] = [FeedBackButton]()
    
    var btnTapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("CancelAccountItemVM  required init?(coder: NSCoder)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        btnWidth = (SCREEN_WIDHT - leftGap * 2 - btnGap * 6)/7
        
        initUI()
    }
    
}

extension LogsMealsAlertSetWeekVM{
    @objc func btnTapAction(btnSender:UIButton) {
        btnSender.isSelected = !btnSender.isSelected
        if btnSender.isSelected == true{
            btnSender.layer.borderColor = UIColor.THEME.cgColor
        }else{
            btnSender.layer.borderColor = UIColor.COLOR_GRAY_BLACK_25.cgColor
        }
        
        if self.btnTapBlock != nil{
            self.btnTapBlock!()
        }
    }
}

extension LogsMealsAlertSetWeekVM{
    func initUI() {
        for i in 0..<weekDayTitleArray.count{
            let btn = FeedBackButton()
            btn.frame = CGRect.init(x: leftGap + (btnWidth + btnGap) * CGFloat(i), y: (selfHeight-btnWidth)*0.5, width: btnWidth, height: btnWidth)
            btn.setTitle("\(weekDayTitleArray[i])", for: .normal)
            btn.setTitleColor(.COLOR_GRAY_BLACK_25, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
            btn.setTitleColor(.white, for: .selected)
            btn.layer.borderColor = UIColor.COLOR_GRAY_BLACK_25.cgColor
            btn.layer.borderWidth = kFitWidth(1)
            btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .selected)
            btn.layer.cornerRadius = btnWidth*0.5
            btn.clipsToBounds = true
            btn.addTarget(self, action: #selector(btnTapAction(btnSender: )), for: .touchUpInside)
            
            addSubview(btn)
            btnArray.append(btn)
        }
    }
}
