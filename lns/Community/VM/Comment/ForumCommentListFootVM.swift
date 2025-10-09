//
//  ForumCommentListFootVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/15.
//



class ForumCommentListFootVM: UIView {
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(46)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "3D6999")
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var loadinView: LoadingSpinner = {
        let vi = LoadingSpinner.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(0), width: SCREEN_WIDHT, height: kFitWidth(46)))
        vi.isHidden = true
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
}

extension ForumCommentListFootVM{
    @objc func tapAction() {
        showLoadingSpinner(isShow: true)
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    
    func showLoadingSpinner(isShow:Bool) {
        loadinView.isHidden = !isShow
        self.contentLabel.isHidden = isShow
        
        if isShow == false{
            self.contentLabel.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                self.contentLabel.alpha = 1
            })
        }
    }
}
extension ForumCommentListFootVM{
    func initUI() {
        addSubview(contentLabel)
        addSubview(loadinView)
//        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(100))
            make.centerY.lessThanOrEqualToSuperview()
        }
//        lineView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
//            make.bottom.equalToSuperview()
//            make.height.equalTo(kFitWidth(1))
//        }
    }
}

extension ForumCommentListFootVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentLabel.textColor = WHColorWithAlpha(colorStr: "3D6999", alpha: 0.45)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentLabel.textColor = WHColor_16(colorStr: "3D6999")
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentLabel.textColor = WHColor_16(colorStr: "3D6999")
    }
}
