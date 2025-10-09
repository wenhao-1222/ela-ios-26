//
//  ForumOfficialPollCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/19.
//

import Photos


class ForumOfficialPollCell: UITableViewCell {
    
    var progressWidth = kFitWidth(0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var bottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_01
        vi.layer.cornerRadius = kFitWidth(5)
        vi.clipsToBounds = true
        vi.layer.borderWidth = kFitWidth(1)
        vi.layer.borderColor = UIColor.COLOR_GRAY_BLACK_25.cgColor
        
        return vi
    }()
    lazy var detailLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var progressView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT//WHColorWithAlpha(colorStr: "007AFF", alpha: 0.08)
        vi.isHidden = true
        return vi
    }()
}

extension ForumOfficialPollCell{
    func updateUI(model:ForumPollModel,index:Int,hasImage:Bool){
        imgView.isHidden = hasImage ? false : true
        
        detailLab.text = model.title

        if hasImage{
            progressWidth = SCREEN_WIDHT - kFitWidth(32) - kFitWidth(64)
            imgView.setImgUrl(urlString: model.imageUrl)
        }else{
            progressWidth = SCREEN_WIDHT - kFitWidth(32)
            detailLab.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(8))
                make.right.equalTo(kFitWidth(-60))
                make.centerY.lessThanOrEqualToSuperview()
            }
        }
    }
    func updateUIForPreview(model:ForumPollModel,index:Int,hasImage:Bool){
        imgView.isHidden = hasImage ? false : true
        
        detailLab.text = model.title

        if hasImage{
            progressWidth = SCREEN_WIDHT - kFitWidth(32) - kFitWidth(64)
//            imgView.setImgUrl(urlString: model.imageUrl)
            updatePhoto(model: model)
        }else{
            progressWidth = SCREEN_WIDHT - kFitWidth(32)
            detailLab.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(8))
                make.right.equalTo(kFitWidth(-60))
                make.centerY.lessThanOrEqualToSuperview()
            }
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
            }
        }
    }
    func updatePercent(model:ForumPollResultModel, hasImage: Bool) {
        progressView.snp.remakeConstraints { make in
            make.left.equalTo(detailLab)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        progressView.isHidden = true
        bottomView.layer.borderColor = UIColor.COLOR_GRAY_BLACK_25.cgColor
        numberLabel.textColor = .COLOR_GRAY_BLACK_45
        detailLab.textColor = .COLOR_GRAY_BLACK_65
        for i in 0..<model.statistics.count{
            let dict = model.statistics[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "content") == detailLab.text{
                
                let width = CGFloat(dict.stringValueForKey(key: "percentage").floatValue)*0.01*progressWidth
                if hasImage{
                    progressView.snp.remakeConstraints { make in
                        make.left.equalTo(imgView.snp.right)
                        make.top.bottom.equalToSuperview()
                        make.width.equalTo(width)
                    }
                }else{
                    progressView.snp.remakeConstraints { make in
                        make.left.equalToSuperview()
                        make.top.bottom.equalToSuperview()
                        make.width.equalTo(width)
                    }
                }
                
                numberLabel.text = "\(dict.stringValueForKey(key: "count").intValue)(\(WHUtils.convertStringToString("\(dict.stringValueForKey(key: "percentage"))") ?? "0.00")%)"
                
                progressView.isHidden = false
                return
            }
        }
    }
    func updateSelfChoice(model:ForumPostPollModel) {
        for i in 0..<model.pollArray.count{
            let pollItemModel = model.pollArray[i]
            
            if pollItemModel.title == self.detailLab.text{
                bottomView.layer.borderColor = UIColor.THEME.cgColor
                numberLabel.textColor = .THEME
                detailLab.textColor = .THEME
                progressView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.15)
            }
        }
    }
    func updateMultipleSelectStatus(isSelect:Bool) {
        if isSelect{
            bottomView.layer.borderColor = UIColor.THEME.cgColor
            detailLab.textColor = .THEME
        }else{
            bottomView.layer.borderColor = UIColor.COLOR_GRAY_BLACK_25.cgColor
            detailLab.textColor = .COLOR_GRAY_BLACK_65
        }
    }
}
extension ForumOfficialPollCell{
    func initUI() {
        contentView.addSubview(bottomView)
        bottomView.addSubview(imgView)
        bottomView.addSubview(progressView)
        bottomView.addSubview(detailLab)
        bottomView.addSubview(numberLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bottomView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(5))
            make.bottom.equalTo(kFitWidth(-5))
            make.height.equalTo(kFitWidth(64))
        }
        imgView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(64))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(kFitWidth(8))
            make.right.equalTo(numberLabel.snp.left).offset(kFitWidth(-10))
            make.centerY.lessThanOrEqualToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
