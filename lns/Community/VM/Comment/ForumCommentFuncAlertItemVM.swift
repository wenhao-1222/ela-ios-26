//
//  ForumCommentFuncAlertItemVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/13.
//


class ForumCommentFuncAlertItemVM: UIView {
    
    let selfHeight = kFitWidth(44)
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgWhiteView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.isHidden = true
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
}

extension ForumCommentFuncAlertItemVM{
    @objc func tapAction() {
        whiteView.backgroundColor = .white
        bgWhiteView.backgroundColor = .white
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    
    func addCorners(corners:UIRectCorner) {
//        bgWhiteView.isHidden = false
//        bgWhiteView.addClipCorner(corners: corners, radius: kFitWidth(8))
//        bgWhiteView.backgroundColor = .white
        bgWhiteView.isHidden = false
        bgWhiteView.backgroundColor = .white
        if corners.contains(.topLeft){
            bgWhiteView.snp.remakeConstraints { make in
                make.width.equalTo(kFitWidth(343))
                make.height.equalTo(kFitWidth(8))
                make.bottom.equalToSuperview()
                make.centerX.lessThanOrEqualToSuperview()
            }
        }
    }
}

extension ForumCommentFuncAlertItemVM{
    func initUI() {
        addSubview(bgWhiteView)
        addSubview(whiteView)
        whiteView.addSubview(iconImgView)
        whiteView.addSubview(titleLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgWhiteView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
//            make.height.equalToSuperview()
            make.height.equalTo(kFitWidth(8))
            make.top.equalToSuperview()
        }
        whiteView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalToSuperview()
        }
        iconImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(18))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}

extension ForumCommentFuncAlertItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        whiteView.backgroundColor = .COLOR_LIGHT_GREY
        bgWhiteView.backgroundColor = .COLOR_LIGHT_GREY
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        whiteView.backgroundColor = .white
        bgWhiteView.backgroundColor = .white
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        whiteView.backgroundColor = .white
        bgWhiteView.backgroundColor = .white
    }
}
