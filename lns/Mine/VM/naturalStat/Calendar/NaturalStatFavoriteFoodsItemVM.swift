//
//  NaturalStatFavoriteFoodsItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/13.
//

import Foundation

class NaturalStatFavoriteFoodsItemVM: UIView {
    
    let selfHeight = kFitWidth(36)
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(12), y: kFitWidth(4), width: SCREEN_WIDHT-kFitWidth(24), height: kFitWidth(32)))
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        
        return vi
    }()
    
    lazy var indexLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        
        return lab
    }()
    lazy var indexBottomImgView: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var foodsNameLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .bold)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_GRAY_BLACK_65
        
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var weightLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    
}

extension NaturalStatFavoriteFoodsItemVM{
    func updateUI(dict:NSDictionary){
        indexLabel.text = dict.stringValueForKey(key: "sn")
        foodsNameLabel.text = dict.stringValueForKey(key: "fname")
        numberLabel.text = "\(dict.stringValueForKey(key: "selected_count"))次"
        weightLabel.text = dict.stringValueForKey(key: "total_qty")
        
        if dict.stringValueForKey(key: "sn") == "1"{
            indexLabel.textColor = WHColor_16(colorStr: "D54941")
            foodsNameLabel.textColor = WHColor_16(colorStr: "D54941")
            indexBottomImgView.setImgLocal(imgName: "stat_top_foods_first")
            bgView.setLayerColors([WHColorWithAlpha(colorStr: "D54941", alpha: 0.1).cgColor,WHColorWithAlpha(colorStr: "D54941", alpha: 0).cgColor])
        }else if dict.stringValueForKey(key: "sn") == "2"{
            indexLabel.textColor = WHColor_16(colorStr: "E37318")
            foodsNameLabel.textColor = WHColor_16(colorStr: "E37318")
            indexBottomImgView.setImgLocal(imgName: "stat_top_foods_second")
            bgView.setLayerColors([WHColorWithAlpha(colorStr: "E37318", alpha: 0.1).cgColor,WHColorWithAlpha(colorStr: "E37318", alpha: 0).cgColor])
        }else if dict.stringValueForKey(key: "sn") == "3"{
            indexLabel.textColor = WHColor_16(colorStr: "F5BA18")
            foodsNameLabel.textColor = WHColor_16(colorStr: "F5BA18")
            indexBottomImgView.setImgLocal(imgName: "stat_top_foods_third")
            bgView.setLayerColors([WHColorWithAlpha(colorStr: "F5BA18", alpha: 0.1).cgColor,WHColorWithAlpha(colorStr: "F5BA18", alpha: 0).cgColor])
        }else{
            indexLabel.textColor = .COLOR_GRAY_BLACK_65
        }
    }
}

extension NaturalStatFavoriteFoodsItemVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(indexBottomImgView)
        bgView.addSubview(indexLabel)
        bgView.addSubview(foodsNameLabel)
        bgView.addSubview(numberLabel)
        bgView.addSubview(weightLabel)
        
        setConstrait()
    }
    func setConstrait() {
//        bgView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(12))
//            make.right.equalTo(kFitWidth(-12))
//            make.height.equalTo(kFitWidth(32))
//            make.top.equalTo(kFitWidth(4))
//        }
        indexBottomImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(10))
            make.top.equalTo(kFitWidth(15))
            make.width.equalTo(kFitWidth(12))
            make.height.equalTo(kFitWidth(10))
        }
        indexLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(indexBottomImgView)
            make.bottom.equalTo(indexBottomImgView).offset(kFitWidth(0))
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(44))
            make.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(128))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(184))
            make.centerY.lessThanOrEqualToSuperview()
        }
        weightLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(264))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalToSuperview()
        }
    }
}
