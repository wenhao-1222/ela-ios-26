//
//  JournalReportDailyNutritionNoProVM.swift
//  lns
//
//  Created by Codex on 2026/7/20.
//

class JournalReportDailyNutritionNoProVM: UIView {
    
    var selfHeight = (SCREEN_WIDHT-kFitWidth(32))*1030.0/686.0
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ele_nutrition_no_pro")
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.isUserInteractionEnabled = true
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noProTapAction)))
        
        return img
    }()
}

extension JournalReportDailyNutritionNoProVM{
    @objc func noProTapAction() {
        tapBlock?()
    }
}

extension JournalReportDailyNutritionNoProVM{
    func initUI() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }
    }
}
