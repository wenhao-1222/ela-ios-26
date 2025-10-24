//
//  ShowBigImgController.swift
//  rebate
//
//  Created by jingjun on 2020/4/20.
//  Copyright © 2020 寻宝天行. All rights reserved.
//

import UIKit
import Photos
import MBProgressHUD

public class ShowBigImgController: UIViewController {
    
    private let SystemNaviBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height + 24
    public var dateString = ""
    
    var isDelete = false
    
    var deleteBlock:((Int)->())?

    
    /// 默认不显示
    public var showSaveBtn: Bool = false {
        didSet {
            if showSaveBtn {
                self.saveBtn.isHidden = false
            }else{
                self.saveBtn.isHidden = true
            }
        }
    }
    /// 可重写saveBtn样式
    public lazy var saveBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("保存至相册", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.isHidden = true
        return button
    }()
    
    internal var showView: ShowBigImgBackView
    internal var number: Int
    
    var isNavi = false
    
    lazy var backImgView: UIImageView = {
        let img = UIImageView()
        img.frame = CGRect.init(x: 10, y: 0, width: 24, height: 24)
        img.image = UIImage(named: "back_arrow")
        img.isUserInteractionEnabled = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backTapAction))
//        img.addGestureRecognizer(tap)
        
        return img
    }()
//    lazy var backTapView: UIView = {
//        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenW, height: ScreenH))
//        vi.backgroundColor = .clear
//        vi.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backTapAction))
//        vi.addGestureRecognizer(tap)
//        return vi
//    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: UIApplication.shared.statusBarFrame.height, width: ScreenW, height: 44))
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textColor = UIColor(red: 34.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        return lab
    }()
    
    public init(imgs: [UIImage],img: UIImage,isNavi:Bool?=false) {
        var number = 0
        _ = imgs.enumerated().map { (index,urlStr) in
            if urlStr == img {
                number = index
            }
        }
        self.isNavi = isNavi ?? false
        self.number = number
        self.showView = ShowBigImgBackView(imgArr: imgs, number: number,isNavi: self.isNavi)
//        self.showView.isNavi = self.isNavi
        super.init(nibName: nil, bundle: nil)
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(showActionSheet))
        self.showView.addGestureRecognizer(tap)
    }
    
    public init(urls: [String],url: String,isNavi:Bool?=false) {
        var number = 0
        _ = urls.enumerated().map { (index,urlStr) in
            if urlStr == url {
                number = index
            }
        }
        self.isNavi = isNavi ?? false
        self.number = number
        self.showView = ShowBigImgBackView.init(urlArr: urls, number: number,isNavi: self.isNavi)
        
        super.init(nibName: nil, bundle: nil)
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(showActionSheet))
        self.showView.addGestureRecognizer(tap)
    }
    public func setImgsMsgArray(imgsArr:NSArray,date:String){
        self.showView.imgMsgArray = imgsArr
//        self.showView.updateDesripContent(index: 0)
//        self.titleLabel.text = date
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.fd_interactivePopDisabled = false
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
//    }
//    public override func viewDidDisappear(_ animated: Bool) {
//        self.navigationController?.fd_interactivePopDisabled = true
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
//    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black//.white
        self.layoutViews()
        self.saveBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backTapAction))
//        self.view.addGestureRecognizer(tap)
        
//        self.view.addSubview(backTapView)
    }
    @objc func backTapAction() {
        self.showView.backRemoveAnimation(0.3)
//        self.dismiss(animated: false, completion: nil)
    }
    
    
    func layoutViews() {
        self.view.addSubview(self.showView)
        self.view.addSubview(self.saveBtn)
        self.showView.dismissCallBack = { [weak self] in
            if self?.navigationController != nil{
                self?.navigationController?.popViewController(animated: true)
            }else{
                self?.dismiss(animated: false, completion: nil)
            }
        }
        self.saveBtn.translatesAutoresizingMaskIntoConstraints = false
        self.saveBtn.heightAnchor.constraint(equalToConstant: 16).isActive = true
        self.saveBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.saveBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: SystemNaviBarHeight).isActive = true
        self.saveBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        
//        self.view.addSubview(titleLabel)
//        self.view.addSubview(backImgView)
//        
//        backImgView.center = CGPoint.init(x: 22, y: titleLabel.center.y)
    }
    
    @objc func showActionSheet(){
        let alertVc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // MARK: - iPad 专属配置
        if let popover = alertVc.popoverPresentationController {
            // 锚点设置为触发按钮
            popover.sourceView = self.view
            // 允许箭头方向（可选）
            popover.permittedArrowDirections = []
        }
        let saveAction = UIAlertAction(title: "保存至相册", style: .default) { action in
            self.saveBtnClick()
        }
        let delAction = UIAlertAction(title: "删除", style: .destructive) { action in
            self.delClick()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        if isDelete{
            alertVc.addAction(delAction)
        }else{
            alertVc.addAction(saveAction)
        }
        
        alertVc.addAction(cancelAction)
        
        self.present(alertVc, animated: true)
    }
    
    @objc func delClick() {
        if self.deleteBlock != nil{
            let index = Int(self.showView.collectionView.contentOffset.x / ScreenW)
            self.deleteBlock!(index)
            
//            self.number = self.number - 1
//            if self.number <= 0{
//                self.dismiss(animated: false, completion: nil)
//                return
//            }
            
            if self.showView.urlArr.count > 0 {
                var urls = self.showView.urlArr
                urls.remove(at: index)
                
                if urls.count <= 0{
                    self.dismiss(animated: false, completion: nil)
                    return
                }
                
                self.showView.removeFromSuperview()
                if urls.count > index{
                    self.showView = ShowBigImgBackView(urlArr: urls , number: index)
                }else{
                    self.showView = ShowBigImgBackView(urlArr: urls , number: index-1)
                }
                
                let tap = UILongPressGestureRecognizer(target: self, action: #selector(showActionSheet))
                self.showView.addGestureRecognizer(tap)
            }else{
                var imgArr = self.showView.imgArr
                imgArr.remove(at: index)
                if imgArr.count <= 0{
                    if self.navigationController != nil{
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.dismiss(animated: false, completion: nil)
                    }
                    return
                }
                self.showView.removeFromSuperview()
                if imgArr.count > index{
                    self.showView = ShowBigImgBackView(imgArr: imgArr, number: index)
                }else{
                    self.showView = ShowBigImgBackView(imgArr: imgArr, number: index-1)
                }
                
                let tap = UILongPressGestureRecognizer(target: self, action: #selector(showActionSheet))
                self.showView.addGestureRecognizer(tap)
            }
            self.view.addSubview(self.showView)
            self.showView.dismissCallBack = { [weak self] in
                if self?.navigationController != nil{
                    self?.navigationController?.popViewController(animated: true)
                }else{
                    self?.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    // 保存图片
    @objc func saveBtnClick() {
        DispatchQueue.main.async {
            MBProgressHUD.xy_show(activity: "保存中...")
        }
        let index = Int(self.showView.collectionView.contentOffset.x / ScreenW)
        
        if self.showView.urlArr.count > 0 {
            let url = self.showView.urlArr[index]
            guard let data = try? Data.init(contentsOf: URL(string: url)!) else {
                return
            }
            self.savePhotos(image: nil, data: data)
        }else{
            let img = self.showView.imgArr[index]
            self.savePhotos(image: img, data: nil)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.isHidden = false
//        self.navigationController?.navigationBar.tintColor = .COLOR_HIGHTLIGHT_GRAY
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.showView.transformAnimation()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
//    deinit {
//        print("ShowController Deinit")
//    }
    
    func savePhotos(image: UIImage?,data: Data?) {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == PHAuthorizationStatus.authorized || status == PHAuthorizationStatus.notDetermined {
                PHPhotoLibrary.shared().performChanges {
                    if let imgData = data {
                        let req = PHAssetCreationRequest.forAsset()
                        req.addResource(with: .photo, data: imgData, options: nil)
                    }else if let img = image{
                        _ = PHAssetChangeRequest.creationRequestForAsset(from: img)
                    }else{
                        MBProgressHUD.xy_hide()
                        return
                    }
                } completionHandler: { (finish, error) in
                    DispatchQueue.main.async {
                        if finish {
                            MBProgressHUD.xy_hide()
                            MBProgressHUD.xy_show("保存成功")
                        }else{
                            MBProgressHUD.xy_hide()
                            MBProgressHUD.xy_show("保存失败")
                        }
                    }
                };
            }else{
                MBProgressHUD.xy_hide()
                //去设置
                self.openSystemSettingPhotoLibrary()
            }
        }
    }
    
    func openSystemSettingPhotoLibrary() {
        let alert = UIAlertController(title:"未获得权限访问您的照片", message:"请在设置选项中允许访问您的照片", preferredStyle: .alert)
        let confirm = UIAlertAction(title:"去设置", style: .default) { (_)in
            let url=URL.init(string: UIApplication.openSettingsURLString)
            if  UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:], completionHandler: { (ist)in
                })
            }
        }
        let cancel = UIAlertAction(title:"取消", style: .cancel, handler:nil)
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated:true, completion:nil)
    }
}
