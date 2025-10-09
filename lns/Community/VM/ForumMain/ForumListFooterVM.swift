//
//  ForumListFooterVM.swift
//  lns
//
//  Created by Elavatine on 2025/1/22.
//



class ForumListFooterVM : UIView{
    
    let selfHeight = kFitWidth(150)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var topLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.isHidden = true
        return vi
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.text = "- 已全部加载完 -"
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.isHidden = true
        return lab
    }()
    lazy var loadinView: LoadingSpinner = {
        let vi = LoadingSpinner.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(40), width: SCREEN_WIDHT, height: kFitWidth(46)))
        
        return vi
    }()
}

extension ForumListFooterVM{
    func endRefreshingNoMoreData() {
        self.loadinView.isHidden = true
        self.topLineView.isHidden = false
        self.contentLabel.isHidden = false
    }
    func resetStatus() {
        self.loadinView.isHidden = false
        self.topLineView.isHidden = true
        self.contentLabel.isHidden = true
    }
}

extension ForumListFooterVM{
    func initUI() {
        addSubview(topLineView)
        addSubview(contentLabel)
        addSubview(loadinView)
        
        setConstreait()
    }
    func setConstreait(){
        topLineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kFitWidth(6))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(topLineView.snp.bottom)
        }
    }
}
