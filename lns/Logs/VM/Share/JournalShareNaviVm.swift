//
//  JournalShareNaviVm.swift
//  lns
//
//  Created by Elavatine on 2025/4/30.
//


class JournalShareNaviVm: UIView {
    
    let selfHeight = kFitWidth(44)
    var closeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var closeImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "back_close_icon")
        return img
    }()
    lazy var backTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(closeAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_icon_img")
        return img
    }()
    
}

extension JournalShareNaviVm{
    @objc func closeAction() {
        self.closeBlock?()
    }
}

extension JournalShareNaviVm{
    func initUI() {
        addSubview(closeImgView)
        addSubview(backTapView)
        addSubview(iconImgView)
        
        setConstrait()
    }
    func setConstrait() {
        closeImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(12))
            make.width.height.equalTo(kFitWidth(20))
        }
        backTapView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.right.equalTo(closeImgView).offset(kFitWidth(12))
        }
        iconImgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(142))
            make.height.equalTo(kFitWidth(26))
        }
    }
}
