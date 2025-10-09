//
//  RankingListButton.swift
//  lns
//
//  Created by Elavatine on 2025/7/4.
//

class RankingListButton: UIView {
    
    let selfWidth = kFitWidth(80)
    let selfHeight = kFitWidth(27)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
        self.isUserInteractionEnabled = true
        
//        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(tapAction))
//        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    lazy var titleLab: UILabel = {
//        let lab = UILabel()
//        lab.text = "好友榜"
//        lab.textColor = .white
//        lab.textAlignment = .center
//        lab.font = .systemFont(ofSize: 15, weight: .regular)
//        lab.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
//        lab.layer.cornerRadius = self.selfHeight*0.5
//        lab.clipsToBounds = true
//        
//        return lab
//    }()
    lazy var addFriendButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("好友榜", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = self.selfHeight*0.5
        btn.clipsToBounds = true
        btn.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
        
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var redView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(4.5)
        vi.clipsToBounds = true
        vi.backgroundColor = WHColor_16(colorStr: "FE2C21")
        vi.isHidden = true
        
        return vi
    }()
}

extension RankingListButton{
    @objc func tapAction() {
//        titleLab.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
        self.tapBlock?()
    }
}

extension RankingListButton{
    func initUI() {
//        addSubview(titleLab)
        addSubview(addFriendButton)
        addSubview(redView)
        
        setConstrait()
    }
    func setConstrait() {
//        titleLab.snp.makeConstraints { make in
//            make.left.top.width.height.equalToSuperview()
//        }
        
        addFriendButton.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        redView.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.height.equalTo(kFitWidth(9))
        }
    }
}

//extension RankingListButton{
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        titleLab.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.4)
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        titleLab.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
//    }
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        titleLab.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
//    }
//}
