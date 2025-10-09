//
//  QuestionnaireSurveyFoodsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation

class QuestionnaireSurveyFoodsTableViewCell: UITableViewCell {
    
    
    var choiceBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        
        return lab
    }()
    lazy var choiceLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "请选择2-7种食物"
        return lab
    }()
    lazy var choiceBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("选择", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = kFitWidth(2)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(choiceAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var foodsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_GREY
         
        return vi
    }()
}

extension QuestionnaireSurveyFoodsTableViewCell{
    func updateUI(dict:NSDictionary){
        nameLabel.text = "\(dict["name"]as? String ?? "")"
        
        let foods = dict["foods"]as? String ?? ""
        if foods.count > 0 {
            choiceLabel.text = "已选择食物"
            foodsLabel.text = "\(foods)"
        }else{
            choiceLabel.text = "请选择2-7种食物"
            foodsLabel.text = ""
        }
//        
    }
}

extension QuestionnaireSurveyFoodsTableViewCell{
    @objc func choiceAction() {
        if self.choiceBlock != nil{
            self.choiceBlock!()
        }
    }
}

extension QuestionnaireSurveyFoodsTableViewCell{
    func initUI(){
        contentView.addSubview(nameLabel)
        contentView.addSubview(choiceLabel)
        contentView.addSubview(choiceBtn)
        contentView.addSubview(foodsLabel)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(22))
        }
        choiceLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(6))
        }
        choiceBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(kFitWidth(30))
            make.width.equalTo(kFitWidth(54))
            make.height.equalTo(kFitWidth(24))
        }
        foodsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(kFitWidth(64))
            make.bottom.equalTo(kFitWidth(-10))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(0.6))
        }
    }
}
