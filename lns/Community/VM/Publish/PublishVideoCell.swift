//
//  PublishVideoCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/27.
//

import Photos


class PublishVideoCell: UITableViewCell {
    
    let videoHeight = kFitWidth(180)
    var clearImgBlock:(()->())?
    var editCoverBlock:(()->())?
    var refreshHeightBlock:((CGRect)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
        img.layer.cornerRadius = kFitWidth(2)
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var clearImageIcon : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "data_img_clear_icon")

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clearImgAction))
        img.addGestureRecognizer(tap)

        return img
    }()
    lazy var setCoverButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("选封面", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .COLOR_GRAY_BLACK_65
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
//        btn.isHidden = true
        btn.addTarget(self, action: #selector(editCoverAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.95)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.backgroundColor = .COLOR_GRAY_BLACK_25
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension PublishVideoCell{
    @objc func editCoverAction() {
        self.editCoverBlock?()
    }
    @objc func clearImgAction(){
        if self.clearImgBlock != nil{
            self.clearImgBlock!()
        }
    }
    func updateVideo(asset:PHAsset) {
//        self.imgView.image = self.gp_getVideoPreViewImage(path: asset.)
    }
    func updateVideo(assetUrl:URL) {
        let img = VideoUtils().gp_getVideoPreViewImage(path: assetUrl)
        
        self.imgView.image = img
//        self.timeLabel.text = VideoUtils().wm_getFileDuration(assetUrl)
        DLLog(message: "获取视频第一帧：\(assetUrl)")
        DLLog(message: "获取视频第一帧： 尺寸\(img.size.width) -- \(img.size.height)")
        let videoRect = self.dealVideoFrame(img: img)
        DLLog(message: "获取视频第一帧： 尺寸\(videoRect.width) -- \(videoRect.height)")
        ForumPublishManager.shared.saveVideoCoverImg(image: img)
        VideoEditModel.shared.videoCoverImage = img
        VideoEditModel.shared.videoCoverImageSize = CGSize.init(width: videoRect.width, height: videoRect.height)
        
//        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_w", data: "\(Int(videoRect.width))", cTime: ForumPublishManager.shared.cTime)
//        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_h", data: "\(Int(videoRect.height))", cTime: ForumPublishManager.shared.cTime)
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_w", data: "\(Int(img.size.width))", cTime: ForumPublishManager.shared.cTime)
        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_h", data: "\(Int(img.size.height))", cTime: ForumPublishManager.shared.cTime)
        DLLog(message: "updateVideo(assetUrl: \(videoRect.width) --- \(videoRect.height)")
        imgView.snp.remakeConstraints { make in
            make.height.equalTo(videoRect.height)
            make.width.equalTo(videoRect.width)
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(0))
            make.top.equalTo(kFitWidth(0))
        }
        self.refreshHeightBlock?(videoRect)
    }
    func updateVideo(img:UIImage) {
//        let videoRect = self.dealVideoFrame(img: img)
        self.imgView.image = img
        ForumPublishManager.shared.saveVideoCoverImg(image: img)
//        DLLog(message: "updateVideo(assetUrl: \(videoRect.width) --- \(videoRect.height)")
//        imgView.snp.remakeConstraints { make in
////            make.left.top.right.bottom.equalToSuperview()
////            make.top.equalTo(kFitWidth(5))
////            make.bottom.equalTo(kFitWidth(-5))
////            make.left.equalTo(videoRect.origin.x)
//            make.height.equalTo(videoRect.height)
//            make.width.equalTo(videoRect.width)
//            make.centerX.lessThanOrEqualToSuperview()
//            make.bottom.equalTo(kFitWidth(0))
//            make.top.equalTo(kFitWidth(0))
//        }
    }
    func dealVideoFrame(img:UIImage) -> CGRect {
        let videoMaxWidth = kFitWidth(343)
        let imgOriginWidth = img.size.width > 0 ? img.size.width : 1
        let imgOriginHeight = img.size.height > 0 ? img.size.height : 1
        
        if imgOriginHeight > imgOriginWidth{
            let imgWidth = imgOriginWidth/imgOriginHeight*videoMaxWidth
            return CGRect.init(x: (SCREEN_WIDHT-imgWidth)*0.5, y: 0, width: imgWidth, height: videoMaxWidth)
        }
        if imgOriginWidth > videoMaxWidth{
            let imgHeight = imgOriginHeight*videoMaxWidth/imgOriginWidth
            return CGRect.init(x: kFitWidth(16), y: 0, width: videoMaxWidth, height: imgHeight)
        }
        
        return CGRect.init(x: (SCREEN_WIDHT-imgOriginWidth)*0.5, y: 0, width: imgOriginWidth, height: imgOriginHeight)
    }
}

extension PublishVideoCell{
    func initUI() {
        contentView.addSubview(imgView)
        contentView.addSubview(clearImageIcon)
        imgView.addSubview(timeLabel)
        imgView.addSubview(setCoverButton)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
//            make.left.top.right.bottom.equalToSuperview()
            make.top.equalTo(kFitWidth(5))
            make.bottom.equalTo(kFitWidth(-5))
//            make.height.equalTo(kFitWidth(180))
//            make.width.equalTo(kFitWidth(200))
            make.centerX.lessThanOrEqualToSuperview()
        }
        clearImageIcon.snp.makeConstraints { make in
            make.right.top.equalTo(imgView)
            make.width.height.equalTo(kFitWidth(22))
        }
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-9))
            make.right.equalTo(kFitWidth(-6))
            make.width.equalTo(kFitWidth(48))
        }
        setCoverButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-6))
            make.width.equalTo(kFitWidth(82))
            make.height.equalTo(kFitWidth(24))
        }
    }
}
