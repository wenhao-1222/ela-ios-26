//
//  LogsNaviEditVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/29.
//

import Foundation

class LogsNaviEditVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    var doneBlock:(()->())?
    var deleteBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.alpha = 0
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var editButton: FeedBackTapButton = {
        let btn = FeedBackTapButton()
        btn.addPressEffect()
        btn.setTitle("完成", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        btn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "编辑日志"
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textColor = WHColor_16(colorStr: "222222")
        return lab
    }()
    lazy var delButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("删除", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        btn.addTarget(self, action: #selector(delAction), for: .touchUpInside)
        return btn
    }()
}

extension LogsNaviEditVM{
    @objc func doneAction() {
        if self.doneBlock != nil{
            self.doneBlock!()
        }
    }
    @objc func delAction() {
        if self.deleteBlock != nil{
            self.deleteBlock!()
        }
    }
    func changeBgAlpha(offsetY:CGFloat) {
        if offsetY > 0 {
            let percent = offsetY/kFitWidth(280)//offsetY/selfHeight
            self.bgView.alpha = percent
        }else{
            self.bgView.alpha = 0
        }
    }
}

extension LogsNaviEditVM{
    func initUI() {
        addSubview(bgView)
        addSubview(editButton)
        addSubview(titleLabel)
        addSubview(delButton)
        
        setConstrait()
//        bgView.addShadow(opacity: 0.05)
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.top.equalTo(-statusBarHeight)
            make.left.width.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
        editButton.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(60))
        }
        delButton.snp.makeConstraints { make in
            make.right.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(60))
        }
    }
}
