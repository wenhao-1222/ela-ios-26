//
//  QuestionnairePlanFoodsAlertTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/4/1.
//

import Foundation

class QuestionnairePlanFoodsAlertTableViewCell: UITableViewCell {
    
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
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.bottomView.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT
        }else{
            self.bottomView.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        }
    }
    lazy var bottomView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds  = true
        vi.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var foodsNameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var verifyImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_foods_verify_icon")
        
        return img
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        
        return lab
    }()
    lazy var selectedImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_foods_normal_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var selectTapView : FeedBackView = {
        let vi = FeedBackView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(choiceAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
}

extension QuestionnairePlanFoodsAlertTableViewCell{
    func updateUI(dict:NSDictionary,selecFoodsArray:NSArray) {
        foodsNameLabel.text = dict["fname"]as? String ?? ""
        
        if dict.stringValueForKey(key: "verified") == "1"{
            verifyImgView.isHidden = false
        }else{
            verifyImgView.isHidden = true
        }
        selectedImgView.setImgLocal(imgName: "question_foods_normal_icon")
        for i in 0..<selecFoodsArray.count{
            let foodsDict = selecFoodsArray[i]as? NSDictionary ?? [:]
            if foodsDict.stringValueForKey(key: "fid") == dict.stringValueForKey(key: "fid"){
                selectedImgView.setImgLocal(imgName: "question_foods_selected_icon")
                break
            }
        }
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: dict)
        numberLabel.text = "\(dict.stringValueForKey(key: "calories"))千卡/\(WHUtils.convertStringToString(specDefault["specNum"]as? String ?? "") ?? "0")\(specDefault["specName"]as? String ?? "")"
    }
    @objc func choiceAction(){
        if self.choiceBlock != nil{
            self.choiceBlock!()
        }
    }
}

extension QuestionnairePlanFoodsAlertTableViewCell{
    func initUI() {
        contentView.addSubview(bottomView)
        bottomView.addSubview(foodsNameLabel)
        bottomView.addSubview(verifyImgView)
        bottomView.addSubview(numberLabel)
        bottomView.addSubview(selectedImgView)
        bottomView.addSubview(selectTapView)
        
        setConstrait()
    }
    func setConstrait() {
        bottomView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(72))
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        verifyImgView.snp.makeConstraints { make in
            make.left.equalTo(foodsNameLabel.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(foodsNameLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(40))
        }
        selectedImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        selectTapView.snp.makeConstraints { make in
            make.top.right.height.equalToSuperview()
            make.width.equalTo(kFitWidth(56))
        }
    }
}
