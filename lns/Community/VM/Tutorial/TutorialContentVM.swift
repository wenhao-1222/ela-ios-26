//
//  TutorialContentVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/25.
//


class TutorialContentVM: UIView {
    
    var selfHeight = kFitWidth(98)
    
    var heightChangeBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        
        initUI()
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var contentLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_GRAY_BLACK_45//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
}

extension TutorialContentVM{
    func updateUI(model:ForumTutorialModel) {
//        DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: { [self] in
            updateConstrait()
            // 3) 最后统一把骨架优雅淡出 + 内容淡入
            [titleLab, contentLab].forEach { $0.hideSkeletonWithCrossfade() }
            
            contentLab.numberOfLines = 0
            titleLab.text = model.title
            contentLab.text = model.subTitle//"\(model.subTitle)\(model.title)"
            
            let labelMaxWidth = SCREEN_WIDHT-kFitWidth(32)
            let titleSize = titleLab.sizeThatFits(CGSize(width: labelMaxWidth, height: CGFloat.greatestFiniteMagnitude))
            let contentSize = contentLab.sizeThatFits(CGSize(width: labelMaxWidth, height: CGFloat.greatestFiniteMagnitude))
            
            self.selfHeight = titleSize.height + contentSize.height + kFitWidth(32)
            if self.heightChangeBlock != nil{
                self.heightChangeBlock!()
            }
//        })
    }
}

extension TutorialContentVM{
    func initUI() {
        addSubview(titleLab)
        addSubview(contentLab)
        
        setConstrait()
        // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
        let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                 highlightColorLight: .COLOR_GRAY_E2,
                                 cornerRadius: kFitWidth(4),
                                 shimmerWidth: 0.22,
                                 shimmerDuration: 1.15)
        
        [titleLab, contentLab].forEach { $0.showSkeleton(cfg) }
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(18))
        }
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-8))
            make.height.equalTo(kFitWidth(64))
        }
    }
    func updateConstrait() {
        titleLab.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }
        contentLab.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-8))
        }
    }
}
