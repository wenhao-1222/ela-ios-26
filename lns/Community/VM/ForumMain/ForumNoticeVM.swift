//
//  ForumNoticeVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/1.
//


class ForumNoticeVM : UIView{
    
    var selfHeight = kFitWidth(0)
    var noticeDataArray:[ForumModel] = [ForumModel]()
    var vmDataArray:[ForumNoticeItemVM] = [ForumNoticeItemVM]()
    var noticeTapBlock:((ForumModel)->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
}

extension ForumNoticeVM{
    func updateUI(dataArray:[ForumModel]) {
        for vi in bgView.subviews{
            vi.removeFromSuperview()
        }
        noticeDataArray = dataArray
        if dataArray.count == 0 {
            selfHeight = 0
            self.frame = CGRect.init(x: 0, y: 0, width: 0, height: 0)
            return
        }
        
        selfHeight = kFitWidth(24) + CGFloat(dataArray.count) * kFitWidth(40)
        var originY = kFitWidth(0)
//        if #available(iOS 26.0, *) {
//            originY = WHUtils().getNavigationBarHeight()
//            selfHeight = selfHeight + WHUtils().getNavigationBarHeight()
//        }
        bgView.frame = CGRect.init(x: kFitWidth(12), y: kFitWidth(12)+originY, width: SCREEN_WIDHT-kFitWidth(24), height: CGFloat(dataArray.count) * kFitWidth(40))
        
        for i in 0..<dataArray.count{
            let vm = ForumNoticeItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(40)*CGFloat(i), width: 0, height: 0))
            let model = dataArray[i]
            
            bgView.addSubview(vm)
            vm.updateUI(model: model)
            vm.updateNewFlag(idT: model.id)
            vmDataArray.append(vm)
            
            vm.tapBlock = {()in
                if self.noticeTapBlock != nil{
                    self.noticeTapBlock!(model)
                }
            }
        }
    }
    func refreshNewsFlag(id:String) {
        for vm in vmDataArray{
            vm.updateNewFlag(idT: id)
        }
    }
}

extension ForumNoticeVM{
    func initUI() {
        addSubview(bgView)
        //ForumNoticeItemVM
    }
}

