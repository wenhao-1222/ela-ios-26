//
//  QuestionnairePlanFoodsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/3/31.
//

import Foundation

class QuestionnairePlanFoodsTableViewCell: UITableViewCell {
    
    var addBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//        
//        if highlighted {
//            self.addBtn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .normal)
//        }else{
//            self.addBtn.setTitleColor(.THEME, for: .normal)
//        }
//    }
    lazy var bottomView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.clipsToBounds = true
        vi.layer.cornerRadius = kFitWidth(8)
        vi.isUserInteractionEnabled = true
        vi.layer.borderColor = WHColor_16(colorStr: "F0F0F0").cgColor
        vi.layer.borderWidth = kFitWidth(1)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()
//    lazy var addBtn : UIButton = {
//        let btn = UIButton()
//        btn.setTitle("添加食物", for: .normal)
//        btn.setTitleColor(.THEME, for: .normal)
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
//        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
//        
//        return btn
//    }()
//    lazy var arrowImgView : UIImageView = {
//        let img = UIImageView()
//        img.setImgLocal(imgName: "question_arrow_right_theme")
//        
//        return img
//    }()
//    lazy var addTapView : UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .clear
//        vi.isUserInteractionEnabled = true
//        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(addAction))
//        vi.addGestureRecognizer(tap)
//        
//        return vi
//    }()
    
    lazy var addFoodsButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("添加食物", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setImage(UIImage.init(named: "question_arrow_right_theme"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.imagePosition(style: .right, spacing: kFitWidth(14))
        
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var detailLabel : UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        
        return lab
    }()
}

extension QuestionnairePlanFoodsTableViewCell{
    @objc func addAction(){
        if self.addBlock != nil{
            self.addBlock!()
        }
    }
    func updateUI(dict:NSDictionary) {
        titleLabel.text = dict["name"]as? String ?? ""
        
        let foodsArray =  dict["foods"]as? NSArray ?? []
        var foods = ""
        
        for i in 0..<foodsArray.count{
            let dict = foodsArray[i]as? NSDictionary ?? [:]
            if dict["select"]as? String ?? "" == "1"{
                let name = dict["fname"]as? String ?? ""
                foods = "\(foods)\(name)\n"
            }
        }
        
        if foods == ""{
            detailLabel.text = ""
            detailLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(kFitWidth(56))
                make.right.equalTo(kFitWidth(-16))
                make.bottom.equalToSuperview()
            }
        }else{
            foods = foods.mc_clipFromPrefix(to: foods.count-1)
            detailLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(kFitWidth(69))
                make.right.equalTo(kFitWidth(-16))
                make.bottom.equalTo(kFitWidth(-20))
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = kFitWidth(12)
            
            // 创建NSAttributedString并设置字体和行高
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .paragraphStyle: paragraphStyle
            ]
            let attributedString = NSMutableAttributedString(string: foods)
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: foods.count))
             
            // 将设置好的NSAttributedString赋值给UILabel的attributedText属性
            detailLabel.attributedText = attributedString
        }
    }
}

extension QuestionnairePlanFoodsTableViewCell{
    func initUI() {
        contentView.addSubview(bottomView)
        bottomView.addSubview(titleLabel)
//        bottomView.addSubview(addBtn)
//        bottomView.addSubview(arrowImgView)
//        bottomView.addSubview(addTapView)
        bottomView.addSubview(addFoodsButton)
        
        bottomView.addSubview(lineView)
        bottomView.addSubview(detailLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bottomView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.top.equalTo(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-6))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(16))
        }
//        arrowImgView.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
//            make.centerY.lessThanOrEqualTo(titleLabel)
//            make.width.height.equalTo(kFitWidth(16))
//        }
//        addBtn.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-36))
//            make.centerY.lessThanOrEqualTo(titleLabel)
//        }
//        addTapView.snp.makeConstraints { make in
//            make.top.right.equalToSuperview()
//            make.height.equalTo(kFitWidth(40))
//            make.left.equalTo(addBtn)
//        }
        addFoodsButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.width.equalTo(kFitWidth(108))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(56))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(1))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(69))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-20))
        }
    }
}
