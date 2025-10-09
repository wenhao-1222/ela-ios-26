//
//  TutorialVideoTypeVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/23.
//


class TutorialVideoTypeVM: UIView {
    
    var selfHeight = kFitWidth(48)
    
    var selectIndex = 0
    var typeDataArray = NSArray()
    var typeBtnArray:[UIButton] = [UIButton]()
    
    var tapBlock:((Int)->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        initUI()
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        scro.showsHorizontalScrollIndicator = false
        scro.bounces = false
        return scro
    }()
    lazy var bottomeLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(1.5)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension TutorialVideoTypeVM{
    @objc func tapAction(tapSender:UIButton) {
        let tapTag = tapSender.tag - 3010
        if tapTag == selectIndex{
            return
        }
        selectIndex = tapTag
        
        for btn in typeBtnArray{
            btn.isSelected = false
        }
        tapSender.isSelected = true
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.bottomeLineView.frame = CGRect.init(x: tapSender.frame.minX+kFitWidth(40), y: self.selfHeight-kFitWidth(3), width: kFitWidth(20), height: kFitWidth(3))
        }completion: { t in
            self.refereshContentOffset()
        }
        
        if self.tapBlock != nil{
            self.tapBlock!(self.selectIndex)
        }
    }
    func changeType(index:Int) {
        selectIndex = index
        for i in 0..<typeBtnArray.count{
            let btn = typeBtnArray[i]
            btn.isSelected = false
            if i == selectIndex{
                btn.isSelected = true
                UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                    self.bottomeLineView.frame = CGRect.init(x: btn.frame.minX+kFitWidth(40), y: self.selfHeight-kFitWidth(3), width: kFitWidth(20), height: kFitWidth(3))
                }completion: { t in
                    self.refereshContentOffset()
                }
            }
        }
    }
    func refereshContentOffset() {
        let scrollContentWidth = CGFloat(typeBtnArray.count) * kFitWidth(100)
        let btnOriginX = CGFloat(selectIndex) * kFitWidth(100)
        let btnCenterX = btnOriginX + kFitWidth(100)*0.5
        DLLog(message: "btnCenterX:\(btnCenterX)")
        
        for btn in typeBtnArray{
            DLLog(message: "\(btn.titleLabel?.text ?? "***") --- \(btn.isSelected)")
        }
        
        if btnCenterX - SCREEN_WIDHT*0.5 < 0 {
            self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }else if abs(scrollContentWidth - btnCenterX) < SCREEN_WIDHT*0.5{
            self.scrollView.setContentOffset(CGPoint(x: scrollContentWidth-SCREEN_WIDHT, y: 0), animated: true)
        }else{
            self.scrollView.setContentOffset(CGPoint(x: btnCenterX - SCREEN_WIDHT*0.5, y: 0), animated: true)
        }
    }
}
extension TutorialVideoTypeVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.addSubview(bottomeLineView)
        bottomeLineView.frame = CGRect.init(x: kFitWidth(40), y: selfHeight-kFitWidth(3), width: kFitWidth(20), height: kFitWidth(3))
    }
    
    func updateUI(dataArray:NSArray) {
        self.typeDataArray = dataArray
//        var lastButton = UIButton()
//        scrollView.addSubview(lastButton)
        scrollView.contentSize = CGSize.init(width: kFitWidth(100)*CGFloat(typeDataArray.count), height: 0)
        
        typeBtnArray.removeAll()
        for vi in self.scrollView.subviews{
//            if vi.isEqual(UIButton.classForCoder()){
                vi.removeFromSuperview()
//            }
        }
        scrollView.addSubview(bottomeLineView)
        for i in 0..<typeDataArray.count{
            let dict = typeDataArray[i]as? NSDictionary ?? [:]
            
            let btn = UIButton()
            btn.setTitle("\(dict.stringValueForKey(key: "title"))", for: .normal)
            btn.setTitleColor(.COLOR_GRAY_BLACK_25, for: .normal)
            btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
            btn.setTitleColor(.COLOR_GRAY_BLACK_65, for: .highlighted)
            btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            btn.titleLabel?.numberOfLines = 2
            btn.titleLabel?.lineBreakMode = .byWordWrapping
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.tag = 3010 + i
            btn.addTarget(self, action: #selector(tapAction(tapSender: )), for: .touchUpInside)
            
//            let leftGap = i == 0 ? kFitWidth(12) : kFitWidth(20)
//            lastButton = btn
            scrollView.addSubview(btn)
            typeBtnArray.append(btn)
            
            btn.snp.makeConstraints { make in
                make.top.height.equalToSuperview()
//                make.left.equalTo(lastButton.snp.right).offset(leftGap)
                make.width.equalTo(kFitWidth(100))
                make.left.equalTo(kFitWidth(100)*CGFloat(i))
            }
            if i == selectIndex {
                btn.isSelected = true
                UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                    self.bottomeLineView.frame = CGRect.init(x: kFitWidth(100)*CGFloat(i)+kFitWidth(40), y: self.selfHeight-kFitWidth(3), width: kFitWidth(20), height: kFitWidth(3))
                }
            }
        }
    }
}
