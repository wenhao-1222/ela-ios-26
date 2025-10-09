//
//  PublishPollItemCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/12.
//

import AppIntents
import SwiftUI
import Photos


class PublishPollItemCell: UITableViewCell {
    
    var tapBlock:(()->())?
    var imgTapBlock:(()->())?
    var textChangedBlock:((String)->())?
    var imgCompleteBlock:((UIImage)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var snLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        
        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.isHidden = true
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        img.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        img.image = UIImage(named: "forum_add_image_icon")
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var pollTitleText: UITextView = {
        let text = UITextView()
        
        text.textColor = .COLOR_GRAY_BLACK_65
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.textContainer.lineBreakMode = .byWordWrapping
        
        return text
    }()
    lazy var placeHoldLabel: UILabel = {
        let lab = UILabel()//.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(14), width: kFitWidth(200), height: kFitWidth(20)))
        lab.text = "添加标题(必填)"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LIGHT_GREY
        return vi
    }()
}

extension PublishPollItemCell{
    func updateUI(model:ForumPollModel,index:Int,hasImage:Bool) {
        imgView.isHidden = hasImage ? false : true
        snLabel.text = "选项\(index+1)"
        
        pollTitleText.text = model.title
        placeHoldLabel.isHidden = pollTitleText.text.count > 0 ? true : false
        if model.hasPhoto{
            updatePhoto(model: model)
        }else{
            imgView.image = UIImage(named: "forum_add_image_icon")
        }
    }
    func updateUIForHasImage(hasImage:Bool) {
        setConstrait(hasImage: hasImage)
    }
    func updateUIForPublish(model:ForumPollModel,index:Int,hasImage:Bool) {
        imgView.isHidden = hasImage ? false : true
        snLabel.text = "选项\(index+1)"
        
        pollTitleText.text = model.title
        placeHoldLabel.isHidden = pollTitleText.text.count > 0 ? true : false
        if model.hasPhoto{
            imgView.image = model.image
            setConstrait(hasImage: true)
        }else{
            imgView.image = UIImage(named: "forum_add_image_icon")
            setConstrait(hasImage: false)
        }
    }
    func updateUIForForumDetail(model:ForumPollModel,index:Int,hasImage:Bool){
        imgView.isHidden = hasImage ? false : true
        snLabel.text = "选项\(index+1)"
        
        pollTitleText.text = model.title
        placeHoldLabel.isHidden = pollTitleText.text.count > 0 ? true : false
        if hasImage{
            imgView.setImgUrl(urlString: model.imageUrl)
            setConstrait(hasImage: true)
        }else{
            imgView.image = UIImage(named: "forum_add_image_icon")
            setConstrait(hasImage: false)
        }
    }
    func updatePhoto(model:ForumPollModel) {
        // 创建 PHCachingImageManager 实例
        let imageManager = PHCachingImageManager.default()
        let option = PHImageRequestOptions.init()
        option.resizeMode = .exact
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
        imageManager.requestImage(for: model.photoAsset, targetSize: CGSize(width: SCREEN_WIDHT*UIScreen.main.scale, height: SCREEN_HEIGHT*UIScreen.main.scale), contentMode: .aspectFit, options: option) { image, info in
            DispatchQueue.main.async {
                self.imgView.image = image
                if self.imgCompleteBlock != nil{
                    self.imgCompleteBlock!(image!)
                }
            }
        }
    }
    @objc func imgTapAction() {
        if self.imgTapBlock != nil{
            self.imgTapBlock!()
        }
    }
}
extension PublishPollItemCell{
    func initUI() {
        contentView.addSubview(snLabel)
        contentView.addSubview(imgView)
        contentView.addSubview(pollTitleText)
        contentView.addSubview(placeHoldLabel)
        contentView.addSubview(lineView)
        
        snLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(18))
            make.width.equalTo(kFitWidth(44))
        }
        imgView.snp.makeConstraints { make in
            make.left.equalTo(snLabel.snp.right).offset(kFitWidth(12))
            make.width.height.equalTo(kFitWidth(64))
            make.centerY.lessThanOrEqualToSuperview()
        }
//        lineView.snp.makeConstraints { make in
//            make.left.equalTo(snLabel)
//            make.right.equalTo(kFitWidth(-16))
//            make.height.equalTo(kFitWidth(1))
//            make.top.equalTo(pollTitleText.snp.bottom).offset(kFitWidth(8))
//        }
//        imgView.image = UIImage(systemName: "photo.badge.plus")
        setConstrait(hasImage:false)
    }
    func setConstrait(hasImage:Bool) {
        if hasImage{
            imgView.isHidden = false
            pollTitleText.snp.remakeConstraints { make in
                make.left.equalTo(imgView.snp.right).offset(kFitWidth(12))
                make.right.equalTo(kFitWidth(-16))
                make.centerY.lessThanOrEqualToSuperview()
            }
        }else{
            imgView.isHidden = true
            pollTitleText.snp.remakeConstraints { make in
                make.left.equalTo(snLabel.snp.right).offset(kFitWidth(12))
                make.right.equalTo(kFitWidth(-16))
                make.centerY.lessThanOrEqualToSuperview()
            }
        }
        
        placeHoldLabel.snp.remakeConstraints { make in
            make.left.equalTo(pollTitleText.snp.left).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(pollTitleText)
//            make.top.equalTo(pollTitleText)
        }
        lineView.snp.remakeConstraints { make in
            make.left.equalTo(pollTitleText)
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(pollTitleText.snp.bottom).offset(kFitWidth(4))
        }
    }
}

extension PublishPollItemCell:UITextViewDelegate{
    // 当文本改变时，动态调整高度
    func textViewDidChange(_ textView: UITextView) {
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//        // 计算文本高度
//        let fixedWidth = textView.frame.size.width
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        placeHoldLabel.isHidden = textView.text.count > 0 ? true : false
        
        if self.textChangedBlock != nil{
            self.textChangedBlock!(self.pollTitleText.text)
        }
//
//        if self.heightChangeBlock != nil{
//            self.heightChangeBlock!(textView.text)
//        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            self.pollTitleText.resignFirstResponder()
            
        }else if text == ""{//   换行   "\r\r"
            return true
        }
        //非markedText才继续往下处理
        guard let _: UITextRange = textView.markedTextRange else{
            if textView.text.count >= 20{
                return false
            }
            
            return true
        }
        return true
    }
}
