//
//  UIImageView+Extension.swift
//  ttjx
//
//  Created by 文 on 2021/5/17.
//  Copyright © 2021 ttjx. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView{
    public func setImgUrl(urlString:String,placeHolder:UIImage?=nil,needTransiton:Bool?=true){
//        DLLog(message: "图片加载地址：\(urlString)")
        ImageCache.default.retrieveImage(forKey: urlString) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                // 获取到缓存图片
                if let image = value.image{
                    DLLog(message: "setImgUrl(urlString:   找到了缓存的图片  \(image)  --- \(urlString)")
                    DispatchQueue.main.async {
    //                    imageView.image = image
                        self.image = image
                    }
                }else{
//                    self.loadImg(urlString: urlString, placeHolder: placeHolder,needTransiton: needTransiton, completeHandler: {
//                        
//                    })
                    DispatchQueue.main.async {
                        self.loadImg(urlString: urlString,
                                     placeHolder: placeHolder,
                                     needTransiton: needTransiton,
                                     completeHandler: {})
                    }
                }
            case .failure(let error):
                DLLog(message: "setImgUrl(urlString:\(error)  --- \(urlString)")
//                self.loadImg(urlString: urlString, placeHolder: placeHolder,needTransiton: needTransiton, completeHandler: {
//                    
//                })
                DispatchQueue.main.async {
                    self.loadImg(urlString: urlString,
                                 placeHolder: placeHolder,
                                 needTransiton: needTransiton,
                                 completeHandler: {})
                }
                break
            }
        }
    }
    func loadImg(urlString:String,
                 placeHolder:UIImage?=nil,
                    needTransiton:Bool?=true,
                 completeHandler: @escaping () -> ()) {
        var signUrl = urlString
        var optionsInfo: KingfisherOptionsInfo = [.cacheOriginalImage,
                                                  .keepCurrentImageWhileLoading,
                                                  .transition(.fade(0.2))]
        if needTransiton == false{
            optionsInfo = [.cacheOriginalImage,
                          .keepCurrentImageWhileLoading]
        }
        
        DLLog(message: "setImgUrl(urlString:加载图片  \(urlString)")
        let setImageOnMain: (_ task: @escaping () -> Void) -> Void = { task in
            if Thread.isMainThread {
                task()
            } else {
                DispatchQueue.main.async { task() }
            }
        }
        if urlString.contains("aliyuncs.com"){
            DSImageUploader().dealImgUrlSignForOss(urlStr: urlString) { [weak self] str in
                guard let self = self else { return }
                signUrl = str
                guard let resourceUrl = URL(string: signUrl) else{
                    return
                }
                
                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: urlString)
                DLLog(message: "图片加载地址 私有桶链接：\(signUrl)")
//                guard let imgUrl = URL(string: signUrl) else { return }
//                self.kf.setImage(with: resource, placeholder: placeHolder, options: optionsInfo)
//                self.kf.setImage(with: resource, placeholder: placeHolder, options: optionsInfo) { _ in
//                    completeHandler()
//                }
                setImageOnMain {
                    self.kf.setImage(with: resource, placeholder: placeHolder, options: optionsInfo) { _ in
                        completeHandler()
                    }
                }
            }
        }else{
            guard let imgUrl = URL(string: signUrl) else { return }
//            self.kf.setImage(with: imgUrl, placeholder: nil, options: optionsInfo)
            setImageOnMain {
                self.kf.setImage(with: imgUrl, placeholder: nil, options: optionsInfo) { _ in
                    completeHandler()
                }
            }
        }
    }
    public func setImgLocal(imgName:String){
        self.image = UIImage.init(named: imgName)
    }
    
    public func setImgUrlWithComplete(urlString:String,
                          placeHolder:UIImage?=nil,
                          completeHandler: @escaping () -> ()){
        ImageCache.default.retrieveImage(forKey: urlString) { result in
            switch result {
            case .success(let value):
                // 获取到缓存图片
                if let image = value.image{
                    DLLog(message: "setImgUrl(urlString:   找到了缓存的图片  \(image)  --- \(urlString)")
                    DispatchQueue.main.async {
    //                    imageView.image = image
                        self.image = image
                        completeHandler()
                    }
                }else{
                    self.loadImg(urlString: urlString, placeHolder: placeHolder, completeHandler: {
                        completeHandler()
                    })
                }
            case .failure(let error):
                DLLog(message: "setImgUrl(urlString:\(error)  --- \(urlString)")
                self.loadImg(urlString: urlString, placeHolder: placeHolder, completeHandler: {
                    completeHandler()
                })
                break
            }
        }
    }
    /// Animates a checkbox transition with a spring effect when toggling.
    /// - Parameters:
    ///   - checked: Target check state.
    ///   - checkedImageName: Image when checkbox is checked.
    ///   - uncheckedImageName: Image when checkbox is unchecked.
    ///   - animated: Whether to animate the transition. Defaults to true.
    func setCheckState(_ checked: Bool,
                       checkedImageName: String,
                       uncheckedImageName: String,
                       animated: Bool = true) {
        let target = checked ? checkedImageName : uncheckedImageName
        if checked {
            setImgLocal(imgName: target)
            guard animated else { return }
            transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            alpha = 0
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.8,
                           options: .curveEaseInOut,
                           animations: {
                               self.transform = .identity
                               self.alpha = 1
                           },
                           completion: nil)
        } else {
            guard animated else {
                setImgLocal(imgName: target)
                return
            }
            UIView.transition(with: self,
                              duration: 0.15,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.setImgLocal(imgName: target)
                              },
                              completion: nil)
        }
    }
}
