//
//  TutorialTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/6/4.
//

import Foundation
import AVFoundation
import UIKit

class TutorialTableViewCell: UITableViewCell {
    
    var imgWidth = kFitWidth(112)
    var imgHeight = kFitWidth(241)
    var imgGap = kFitWidth(6)
    
    var isPlaying = false
    
    var catalogueType = catalogue_type.catalogue_12
    
    var imgTapBlock:((UIImageView)->())?
    var buttonTapBlock:((catalogue_type)->())?
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var topLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
//        lab.backgroundColor = WHColor_ARC()
        
        return lab
    }()
    lazy var imgBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var imgScrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT-kFitWidth(14), height: imgHeight+kFitWidth(25)))
        scro.backgroundColor = .clear
        return scro
    }()
}

extension TutorialTableViewCell{
    func updateUI(attr:NSAttributedString,bottomGap:CGFloat) {
        topLabel.attributedText = attr
        topLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-45))
            make.bottom.equalTo(-bottomGap)
        }
        
        for vi in imgBottomView.subviews{
            vi.removeFromSuperview()
        }
    }
    func updateUI(dict:NSDictionary,isFourLayout:Bool? = false) {
        playerLayer.isHidden = true
        let attr = dict["attr"]as! NSMutableAttributedString
        let bottomGap = dict["bottomGap"]as? CGFloat ?? kFitWidth(287)
        topLabel.attributedText = attr
        topLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-45))
            make.bottom.equalTo(-bottomGap)
        }
        imgBottomView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-14))
            make.top.equalTo(topLabel.snp.bottom).offset(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-10))
        }
        for vi in imgScrollView.subviews{
            vi.removeFromSuperview()
        }
        imgScrollView.contentSize = CGSize.init(width: 0.0, height: 0.0)
        updateImgs(dict: dict)
        updateCatalogue(dict: dict)
        
    }
    func updateUIForAVPlayer(dict:NSDictionary) {
        isPlaying = true
        let attr = dict["attr"]as! NSMutableAttributedString
        let bottomGap = dict["bottomGap"]as? CGFloat ?? kFitWidth(287)
        topLabel.attributedText = attr
        topLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-45))
            make.bottom.equalTo(-bottomGap)
        }
        imgBottomView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-14))
            make.top.equalTo(topLabel.snp.bottom).offset(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-10))
        }
        for vi in imgScrollView.subviews{
            vi.removeFromSuperview()
        }
        playerLayer.isHidden = false
        playerActive()
    }
    /**
          图片
     */
    func updateImgs(dict:NSDictionary) {
        let imgsArray = dict["imgs"]as? NSArray ?? []
        let stepsArray = dict["steps"]as? NSArray ?? []
        
        var originX = kFitWidth(0)
        var originY = kFitWidth(0)

        for i in 0..<imgsArray.count{
            let imgName = imgsArray[i]as? String ?? ""
            let imgView = FeedBackUIImageView.init(frame: CGRect.init(x: originX, y: originY, width: imgWidth, height: imgHeight))
            imgView.setImgLocal(imgName: imgName)
            imgScrollView.addSubview(imgView)
            
            imgView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction(sender: )))
            imgView.addGestureRecognizer(tap)
            
            if stepsArray.count > 0{
                let lab = UILabel.init(frame: CGRect.init(x: originX, y: originY+imgHeight, width: imgWidth, height: kFitWidth(23)))
                lab.text = stepsArray[i]as? String ?? ""
                lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
                lab.font = .systemFont(ofSize: 11, weight: .regular)
                lab.textAlignment = .center
                imgScrollView.addSubview(lab)
            }
            originX = originX + kFitWidth(6) + imgWidth
        }
//        if imgsArray.count > 3 {
            imgScrollView.contentSize = CGSize.init(width: (kFitWidth(6) + imgWidth)*CGFloat(imgsArray.count), height: 0.0)
//        }else{
//            imgScrollView.contentSize = CGSize.init(width: 0.0, height: 0.0)
//        }
    }
    /**
         可点击弹窗的蓝色按钮
     */
    func updateCatalogue(dict:NSDictionary) {
        let buttonMsg = dict["button"]as? NSDictionary ?? [:]
        if buttonMsg.stringValueForKey(key: "title").count > 0 {
            
            topLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(14))
                make.top.equalToSuperview()
                make.right.equalTo(kFitWidth(-45))
                make.height.equalTo(kFitWidth(24))
                make.bottom.equalTo(-kFitWidth(43))
            }
            imgBottomView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(14))
                make.right.equalTo(kFitWidth(-14))
                make.top.equalTo(topLabel.snp.bottom).offset(kFitWidth(3))
                make.bottom.equalTo(kFitWidth(-10))
            }
            catalogueType = buttonMsg["catalogue"]as! catalogue_type
            let button = FeedBackButton()
            button.setTitle(buttonMsg.stringValueForKey(key: "title"), for: .normal)
            button.setTitleColor(.THEME, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
            button.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
            
            imgScrollView.addSubview(button)
            button.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(1))
                make.top.equalTo(kFitWidth(0))
            }
            
            button.addTarget(self, action: #selector(catalogueTypeTapAction), for: .touchUpInside)
        }
    }
    @objc func imgTapAction(sender:UITapGestureRecognizer) {
        let imgView = sender.view as? UIImageView
        if self.imgTapBlock != nil && imgView != nil{
            self.imgTapBlock!(imgView!)
        }
    }
    @objc func catalogueTypeTapAction() {
        if self.buttonTapBlock != nil{
            self.buttonTapBlock!(self.catalogueType)
        }
    }
}
extension TutorialTableViewCell{
    func initUI() {
        contentView.addSubview(topLabel)
        contentView.addSubview(imgBottomView)
        imgBottomView.addSubview(imgScrollView)
        
        initMp4Player()
        imgBottomView.layer.addSublayer(playerLayer)
        playerLayer.isHidden = true
        
        setConstrait()
    }
    func setConstrait() {
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-45))
        }
        imgBottomView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-14))
            make.top.equalTo(topLabel.snp.bottom).offset(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-10))
        }
    }
    
    func initMp4Player() {
        // 假设你的MP4文件名为localVideo.mp4，并且该文件已经添加到项目的Bundle中
        let urlString = "https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/forum/material/widget_demo.mp4"
        // 创建AVPlayer实例
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = imgScrollView.frame
        DSImageUploader().dealImgUrlSignForOss(urlStr: urlString) { signStr in
            if let url = URL(string: signStr) {
                self.player = AVPlayer(url: url)
                self.playerLayer = AVPlayerLayer(player: self.player)
            }
        }
    }
    func playerActive(){
        if isPlaying == false{
            player = nil
            return
        }
        player.seek(to: .zero)
        player.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+18, execute: {
            self.playerActive()
        })
    }
}
