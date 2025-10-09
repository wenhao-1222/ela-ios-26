//
//  ForumCommentVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/8.
//


class ForumCommentVM: UIView {
    
    var selfHeight = kFitWidth(56)+WHUtils().getBottomSafeAreaHeight()
    
    var model = ForumModel()
    
    var commomTapBlock:(()->())?
    var thumbUpTapBlock:(()->())?
    
    var hiddenSelfBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
//        vi.layer.cornerRadius = kFitWidth(16)
//        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var textField: ForumCommentTextVM = {
        let text = ForumCommentTextVM.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(10), width: SCREEN_WIDHT-kFitWidth(180), height: kFitWidth(36)))
        text.textField.isEnabled = false
        return text
    }()
    //点赞
    lazy var thumbsUpButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("点赞", for: .normal)
        btn.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        
        btn.addTarget(self, action: #selector(thumbTapAction), for: .touchUpInside)
        
        return btn
    }()
    //评论
    lazy var commonButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("评论", for: .normal)
        btn.setImage(UIImage(named: "forum_comment_icon_max"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .highlighted)
        
        btn.addTarget(self, action: #selector(commentTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
}

extension ForumCommentVM{
    @objc func nothingAction() {
        
    }
    @objc func thumbTapAction() {
        if self.thumbUpTapBlock != nil{
            self.thumbUpTapBlock!()
        }
    }
    @objc func commentTapAction() {
        if self.commomTapBlock != nil{
            self.commomTapBlock!()
        }
    }
    //帖子禁止评论
    func setDisableComment() {
        self.commonButton.isHidden = true
    }
    //刷新
    func refreshUI(model:ForumModel) {
        if model.likable == .refuse{
            thumbsUpButton.isHidden = true
        }else{
            thumbsUpButton.isHidden = false
        }
        if model.commentable == .refuse{
            commonButton.isHidden = true
            thumbsUpButton.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-8))
                make.width.equalTo(kFitWidth(70))
                make.height.equalTo(kFitWidth(54))
                make.top.equalTo(kFitWidth(1))
            }
        }else{
            commonButton.isHidden = false
        }
        
        if model.likable == .refuse && model.commentable == .refuse{
            self.isHidden = true
            if self.hiddenSelfBlock != nil{
                self.hiddenSelfBlock!()
            }
        }else if model.likable == .refuse || model.commentable == .refuse{
            if isIpad(){
                textField.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(10), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(36))
            }else{
                textField.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(10), width: kFitWidth(190)+kFitWidth(70), height: kFitWidth(36))
            }
        }
    }
}

extension ForumCommentVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(textField)
        whiteView.addSubview(thumbsUpButton)
        whiteView.addSubview(commonButton)
        whiteView.addSubview(lineView)
        
        setConstrait()
        thumbsUpButton.imagePosition(style: .left, spacing: kFitWidth(3))
        commonButton.imagePosition(style: .left, spacing: kFitWidth(3))
    }
    func setConstrait()  {
        lineView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
//            make.top.equalTo(kFitWidth(0))
            make.height.equalTo(kFitWidth(1))
//            make.centerX.lessThanOrEqualToSuperview()
//            make.width.equalTo(SCREEN_WIDHT)
        }
        commonButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-8))
            make.width.equalTo(kFitWidth(70))
            make.height.equalTo(kFitWidth(54))
//            make.centerY.lessThanOrEqualTo(pageViewNumLabel)
            make.top.equalTo(kFitWidth(1))
        }
        thumbsUpButton.snp.makeConstraints { make in
            make.right.equalTo(commonButton.snp.left).offset(kFitWidth(-8))
            make.centerY.width.height.equalTo(commonButton)
        }
    }
}
