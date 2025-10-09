//
//  AIBottomFuncVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AIBottomFuncVM: UIView {
    
    let selfHeight = kFitHeight(68)
    
    var flashBlock:(()->())?
    var captureBlock:(()->())?
    var albumBlock:(()->())?
    var tapIndex = 0
    
    var flashIsOn = false//闪光灯是否打开
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.8)
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var cameraImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ai_photo_take_icon")
        img.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(capturePhoto))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var flashImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ai_camera_flash_normal_icon")
        img.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(toggleFlash))
        img.addGestureRecognizer(tap)
        return img
    }()
    lazy var albumImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ai_camera_album_icon")
        img.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(openAlbum))
        img.addGestureRecognizer(tap)
        return img
    }()
}

extension AIBottomFuncVM{
    @objc func toggleFlash() {
//        self.flashBlock?()
        self.flashIsOn = !self.flashIsOn
        self.updateFlashStatus(isOn: self.flashIsOn)
    }
    @objc func capturePhoto() {
        self.captureBlock?()
        cameraImgView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.cameraImgView.isUserInteractionEnabled = true
        })
    }
    @objc func openAlbum() {
        self.albumBlock?()
    }
    func updateFlashStatus(isOn:Bool?=false) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        try? device.lockForConfiguration()
        
        if isOn == true{
            self.flashIsOn = true
            if device.isTorchModeSupported(.on){
                device.torchMode = .on
            }
            
            flashImgView.setImgLocal(imgName: "ai_camera_flash_icon")
        }else{
            self.flashIsOn = false
            if device.isTorchModeSupported(.on){
                device.torchMode = .off
            }
//            device.torchMode = .off
            flashImgView.setImgLocal(imgName: "ai_camera_flash_normal_icon")
        }
        
//        device.torchMode = device.torchMode == .on ? .off : .on
        device.unlockForConfiguration()
//        if isOn == true{
//            flashImgView.setImgLocal(imgName: "ai_camera_flash_icon")
//        }else{
//            flashImgView.setImgLocal(imgName: "ai_camera_flash_normal_icon")
//        }
    }
    func refreshShowStatus(isShow:Bool) {
        if isShow{
            self.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.alpha = 1
            }
        }else{
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.alpha = 0
            }completion: { t in
                self.isHidden = true
            }
        }
    }
}

extension AIBottomFuncVM{
    func initUI() {
        addSubview(flashImgView)
        addSubview(cameraImgView)
        addSubview(albumImgView)
        
        setConstrait()
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if !device.isTorchModeSupported(.on){
            flashImgView.isHidden = true
        }
    }
    func setConstrait() {
        cameraImgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitHeight(68))
        }
        flashImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(53))
            make.width.height.equalTo(kFitWidth(30))
        }
        albumImgView.snp.makeConstraints { make in
            make.width.height.equalTo(flashImgView)
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-53))
        }
    }
}
