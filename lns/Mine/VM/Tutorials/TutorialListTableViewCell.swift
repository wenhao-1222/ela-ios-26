//
//  TutorialListTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/6/5.
//

import Foundation


class TutorialListTableViewCell: UITableViewCell {
    
    var tapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.15).cgColor
        vi.layer.borderWidth = kFitWidth(1)
        
        
        return vi
    }()
    lazy var stepImgView: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var contenLab: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var showButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("查看教程", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension TutorialListTableViewCell{
    func updateUI(title:String,index:Int) {
        contenLab.text = title
        
        stepImgView.setImgLocal(imgName: "tutorials_step_\(index+1)")
    }
}

extension TutorialListTableViewCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(stepImgView)
        bgView.addSubview(contenLab)
        bgView.addSubview(showButton)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(12))
            make.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(343))
        }
        stepImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(20))
            make.width.height.equalTo(kFitWidth(32))
        }
        contenLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(68))
        }
        showButton.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-20))
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
}

extension TutorialListTableViewCell{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = .white
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = .white
    }
    @objc func tapAction(){
        if self.tapBlock != nil{
            self.tapBlock!()
            bgView.backgroundColor = .white
        }
    }
}
