//
//  LoginPhoneTypeAlertItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/15.
//

import Foundation

class LoginPhoneTypeAlertItemVM: UIView {
    
    let selfHeight = kFitWidth(36)
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(200), height: selfHeight))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
//        img.setImgLocal(imgName: "idc_icon_china")
        img.contentMode = .scaleAspectFit

        return img
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var selectImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_type_selected_icon")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        return img
    }()
    
    @objc func tapAction() {
        self.backgroundColor = .clear
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    
    func updateUI(dict:NSDictionary) {
        self.imgView.setImgUrl(urlString: dict.stringValueForKey(key: "flags"))
        self.titleLabel.text = "\(dict.stringValueForKey(key: "region"))(+\(dict.stringValueForKey(key: "idc")))"
    }
    
    func initUI() {
        addSubview(imgView)
        addSubview(titleLabel)
        addSubview(lineView)
//        addSubview(selectImgView)
        
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(10))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(28))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(kFitWidth(5))
            make.right.equalTo(kFitWidth(-10))
            make.centerY.lessThanOrEqualToSuperview()
        }
//        selectImgView.snp.makeConstraints { make in
////            make.top.equalTo(kFitWidth(16))
//            make.centerY.lessThanOrEqualToSuperview()
//            make.right.equalTo(kFitWidth(-16))
//            make.width.height.equalTo(kFitWidth(16))
//        }
        lineView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension LoginPhoneTypeAlertItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .clear
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .clear
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
    }
}
