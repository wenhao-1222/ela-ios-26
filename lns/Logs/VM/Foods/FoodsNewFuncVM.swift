//
//  FoodsNewFuncVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/25.
//


class FoodsNewFuncVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(40), height: kFitHeight(15)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_new_func_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var contentLab: UILabel = {
        let lab = UILabel()
//        lab.text = "新功能"
        lab.text = "新"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.isUserInteractionEnabled = true
        lab.textAlignment = .center
        
        return lab
    }()
}

extension FoodsNewFuncVM{
    func initUI() {
        addSubview(imgView)
        addSubview(contentLab)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        contentLab.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
    }
}
