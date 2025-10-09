//
//  JournalShareReceiptVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/30.
//


class JournalShareReceiptVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var themView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.layer.borderColor = WHColor_16(colorStr: "0055FF").cgColor
        vi.layer.borderWidth = kFitWidth(4)
        vi.layer.cornerRadius = kFitWidth(22)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "202423")
        vi.layer.borderColor = WHColor_16(colorStr: "FFFFFF").cgColor
        vi.layer.borderWidth = kFitWidth(4)
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        
        return vi
    }()
}


extension JournalShareReceiptVM{
    func initUI() {
        addSubview(themView)
        addSubview(whiteView)
        
        setConstrait()
    }
    func setConstrait() {
        themView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.height.equalToSuperview()
            make.top.equalToSuperview()
        }
        whiteView.snp.makeConstraints { make in
            make.top.left.equalTo(themView).offset(kFitWidth(4))
            make.right.bottom.equalTo(themView).offset(kFitWidth(-4))
        }
    }
}
