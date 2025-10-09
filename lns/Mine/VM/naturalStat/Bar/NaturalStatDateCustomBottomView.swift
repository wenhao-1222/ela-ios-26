//
//  NaturalStatDateCustomBottomView.swift
//  lns
//
//  Created by LNS2 on 2024/9/10.
//

import Foundation

class NaturalStatDateCustomBottomView: UIView {
    
    var confirmBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: kFitWidth(110)))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        
        return vi
    }()
    lazy var startLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "开始"
        
        return lab
    }()
    lazy var startLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "-"
        
        return lab
    }()
    lazy var tipsLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "最长选择三个月"
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "至"
        
        return lab
    }()
    lazy var endLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "结束"
        
        return lab
    }()
    lazy var endLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "-"
        
        return lab
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
}

extension NaturalStatDateCustomBottomView{
    @objc func confirmAction(){
        if self.confirmBlock != nil{
            self.confirmBlock!()
        }
    }
    func updateUI(startTime:String,endTime:String) {
        if startTime.count > 0 {
            self.startLabel.text = startTime
            if endTime.count > 0{
                self.endLabel.text = endTime
            }else{
                self.endLabel.text = "-"
            }
        }else{
            self.startLabel.text = "-"
            self.endLabel.text = "-"
        }
    }
}

extension NaturalStatDateCustomBottomView{
    func initUI() {
        addSubview(lineView)
        addSubview(startLab)
        addSubview(startLabel)
        addSubview(tipsLabel)
        addSubview(tipsLab)
        addSubview(endLab)
        addSubview(endLabel)
        addSubview(confirmButton)
        
        setConstrait()
    }
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        startLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(12))
        }
        tipsLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(startLab)
        }
        endLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(startLab)
        }
        startLabel.snp.makeConstraints { make in
            make.left.equalTo(startLab)
            make.top.equalTo(kFitWidth(32))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(startLabel)
        }
        endLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(startLabel)
        }
        confirmButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.bottom.equalTo(kFitWidth(-12))
            make.height.equalTo(kFitWidth(40))
        }
    }
}
