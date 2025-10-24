//
//  ServiceImgView.swift
//  lns
//
//  Created by LNS2 on 2024/5/16.
//

import Foundation
import PhotosUI


class ServiceImgView: UIView {
    
    let selfHeight = kFitWidth(122)
    var imgViewArray = [ServiewImageView]()
    var imgArray  = [UIImage]()
    
    var imgTapBlock:((UIImage)->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        
        initUI()
    }
    lazy var addImgButton : UIButton = {
        let img = UIButton()
        img.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(7), width: kFitWidth(108), height: kFitWidth(108))
//        img.backgroundColor = .clear
        img.setImage(UIImage(named: "service_img_add_icon"), for: .normal)
        img.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.02)), for: .highlighted)
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        
        return img
    }()
}

extension ServiceImgView{
    func setImgs(results: [PHPickerResult]) {
        var index = 0
        imgArray.removeAll()
        for result in results{
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    
                    guard let self = self else { return }
                    guard let image = image as? UIImage else {
                        /// 错误处理
                        return
                    }
                    self.updateImg(image: image, index: index)
                    index = index + 1
                }
            } else {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier,
                                                           completionHandler: { [weak self] url, error  in
                    do {
                        if let url = url {
                            let imageData = try Data(contentsOf: url)
                            if let image = UIImage(data: imageData) {
                                self?.updateImg(image: image, index: index)
                                index = index + 1
                            } else {
                                /// 错误处理
                            }
                        } else {
                            /// 错误处理
                        }
                    } catch let error {
                        /// 错误处理
                    }
                })
            }
        }
        //
    }
    func updateImg(image:UIImage,index:Int) {
        imgArray.append(image)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            for i in index..<self.imgViewArray.count{
                let img = self.imgViewArray[i]
                img.isHidden = true
            }
            let imgView = self.imgViewArray[index]
            imgView.imgView.image = image
            imgView.isHidden = false
            
            if index < self.imgViewArray.count-1{
                let img = self.imgViewArray[index+1]
                self.addImgButton.frame = img.frame
                self.addImgButton.isHidden = false
            }else{
                self.addImgButton.isHidden = true
            }
        })
    }
    @objc func imgTapAction(tapSender:UITapGestureRecognizer){
        let tapView = tapSender.view as! UIImageView
        
        if self.imgTapBlock != nil{
            self.imgTapBlock!(tapView.image!)
        }
    }
    func imgDelete(index:Int) {
        imgArray.remove(at: index)
        if index == 2 {
            let imgView = self.imgViewArray[2]
            imgView.isHidden = true
            self.addImgButton.frame = imgView.frame
            self.addImgButton.isHidden = false
        }else{
            for i in 0..<imgViewArray.count{
                let imgView = self.imgViewArray[i]
                if i >= imgArray.count{
                    imgView.isHidden = true
                }else{
                    imgView.imgView.image = imgArray[i]
                    imgView.isHidden = false
                }
            }
            let img = self.imgViewArray[imgArray.count]
            self.addImgButton.frame = img.frame
            self.addImgButton.isHidden = false
        }
    }
}
extension ServiceImgView{
    func initUI() {
        addSubview(addImgButton)
        initImgViewArray()
    }
    func initImgViewArray() {
        var originX = kFitWidth(16)
        for i in 0..<3{
            let imgView = ServiewImageView()
            imgView.frame = CGRect.init(x: originX, y: kFitWidth(7), width: kFitWidth(108), height: kFitWidth(108))
            imgView.tag = 4010 + i
            imgView.isUserInteractionEnabled = true
            
            imgView.tapBlock = {()in
                if self.imgTapBlock != nil{
                    self.imgTapBlock!(imgView.imgView.image!)
                }
            }
            imgView.deleteBlock = {()in
                self.imgDelete(index: i)
            }
            
//            let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction(tapSender: )))
//            imgView.addGestureRecognizer(tap)
            
            addSubview(imgView)
            imgViewArray.append(imgView)
            originX = originX + kFitWidth(108) + kFitWidth(8)
        }
    }
}
