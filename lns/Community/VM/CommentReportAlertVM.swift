//
//  CommentReportAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/1/8.
//


import MCToast

class CommentReportAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    var commentModel = ForumCommentModel()
    var replyModel = ForumCommentReplyModel()
    
    let bottomGap = kFitWidth(50)
    var whiteViewHeight = kFitWidth(44) + ForumCommentFuncAlertItemVM().selfHeight*4 + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
    var whiteViewOriginY = kFitWidth(0)
    
    var reportBtnArray:[CommentReportAlertItemVM] = [CommentReportAlertItemVM]()
    
    var tapIndex = -1
    var submitBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        whiteViewHeight = kFitWidth(44) + CGFloat(ForumConfigModel.shared.reportReasonArray.count)*kFitWidth(44) + WHUtils().getBottomSafeAreaHeight() + kFitWidth(50) + kFitWidth(16) + bottomGap
        
        if whiteViewHeight > SCREEN_HEIGHT - kFitWidth(150){
            whiteViewHeight = SCREEN_HEIGHT - kFitWidth(150)
        }
        
        initUI()
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColor_16(colorStr: "EFEFEF")
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        return vi
    }()
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.layer.cornerRadius = kFitWidth(8)
        scro.clipsToBounds = true
        scro.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return scro
    }()
    lazy var topLineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        vi.layer.cornerRadius = kFitWidth(2)
        
        return vi
    }()
    lazy var topCloseTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var submitButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("提交", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        
        return btn
    }()
}

extension CommentReportAlertVM{
    @objc func showView() {
        self.isHidden = false
        for item in reportBtnArray{
            item.itemLabel.textColor = .COLOR_GRAY_BLACK_65
        }
        self.tapIndex = -1
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }
   }
   @objc func hiddenView() {
       UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
           self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
           self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
       }completion: { t in
           self.isHidden = true
       }
  }
    @objc func nothingToDo() {
        
    }
    @objc func submitAction() {
        if self.tapIndex == -1{
            return
        }
        if self.submitBlock != nil{
            self.submitBlock!(ForumConfigModel.shared.reportReasonArray[self.tapIndex])
        }
        self.hiddenView()
    }
 @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
     // 获取当前手势所在的view
     if let view = gesture.view {
         // 根据手势移动view的位置
         switch gesture.state {
         case .changed:
             let translation = gesture.translation(in: view)
             DLLog(message: "translation.y:\(translation.y)")
             if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                 return
             }
             view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
             gesture.setTranslation(.zero, in: view)
             
         case .ended:
             if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                 self.hiddenView()
             }else{
                 UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                     self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                 }
             }
         default:
             break
         }
     }
 }
}

extension CommentReportAlertVM{
    func initData() {
        for i in 0..<ForumConfigModel.shared.reportReasonArray.count{
            let itemVm = CommentReportAlertItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(44)*CGFloat(i), width: 0, height: 0))
            itemVm.itemLabel.text = ForumConfigModel.shared.reportReasonArray[i]
            itemVm.tapBlock = {()in
                self.itemTapAction(index: i)
            }
            scrollView.addSubview(itemVm)
            reportBtnArray.append(itemVm)
        }
        scrollView.contentSize = CGSize.init(width: 0, height: kFitWidth(44)*CGFloat(ForumConfigModel.shared.reportReasonArray.count))
    }
    @objc func itemTapAction(index:Int) {
        for i in 0..<reportBtnArray.count{
            let item = reportBtnArray[i]
            item.itemLabel.textColor = .COLOR_GRAY_BLACK_65
            if i == index{
                item.itemLabel.textColor = .THEME
            }
        }
        
        tapIndex = index
    }
}

extension CommentReportAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(scrollView)
        addSubview(topCloseTapView)
        
        whiteView.addSubview(topLineView)
        whiteView.addSubview(submitButton)
        
        setConstrait()
        initData()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(whiteViewHeight)
            make.bottom.equalTo(kFitWidth(16)+SCREEN_HEIGHT)
        }
        scrollView.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(343))
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(44))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(50)-kFitWidth(16)-bottomGap)
        }
        topCloseTapView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT-whiteViewHeight+kFitWidth(40))
        }
        topLineView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(18))
            make.width.equalTo(kFitWidth(43))
            make.height.equalTo(kFitWidth(4))
            make.centerX.lessThanOrEqualToSuperview()
        }
        submitButton.snp.makeConstraints { make in
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(26))
            make.width.equalTo(kFitWidth(343))
            make.centerX.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(50))
        }
    }
}

class CommentReportAlertItemVM: UIView {
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: kFitWidth(343), height: kFitWidth(44)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var itemLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension CommentReportAlertItemVM{
    func initUI() {
        addSubview(itemLabel)
        
        itemLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-16))
        }
    }
}
