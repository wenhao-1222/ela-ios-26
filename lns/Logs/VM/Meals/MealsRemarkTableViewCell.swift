//
//  MealsRemarkTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/7/24.
//

import Foundation

class MealsRemarkTableViewCell: UITableViewCell {
    
    var heightChangeBlock:((String)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var remarkTextField: UITextView = {
        let text = UITextView()
        
        text.textColor = .COLOR_GRAY_BLACK_65
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.textContainer.lineBreakMode = .byWordWrapping
//        text.text = "这里输入食谱制作教程"
//        text.textNumber = 120
//        text.placeholder = "这里输入您的注释说明"
        
        return text
    }()
    lazy var placeHoldLabel: UILabel = {
        let lab = UILabel()//.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(14), width: kFitWidth(200), height: kFitWidth(20)))
        lab.text = "这里输入食谱制作教程"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
}

extension MealsRemarkTableViewCell{
    func initUI() {
        contentView.addSubview(remarkTextField)
        contentView.addSubview(placeHoldLabel)
        remarkTextField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.greaterThanOrEqualTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(0))
        }
        placeHoldLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.centerY.lessThanOrEqualTo(remarkTextField)
        }
    }
    func updateContentString(content:String){
        remarkTextField.text = content
        placeHoldLabel.isHidden = remarkTextField.text.count > 0 ? true : false
    }
}

extension MealsRemarkTableViewCell:UITextViewDelegate{
    // 当文本改变时，动态调整高度
    func textViewDidChange(_ textView: UITextView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        // 计算文本高度
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        placeHoldLabel.isHidden = textView.text.count > 0 ? true : false
        
        if self.heightChangeBlock != nil{
            self.heightChangeBlock!(textView.text)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            self.remarkTextField.resignFirstResponder()
        }
        
        return true
    }
}
