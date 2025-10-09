//
//  VideoEditVC.swift
//  lns
//
//  Created by Elavatine on 2025/2/18.
//

class VideoEditVC: WHBaseViewVC {
    
    var videoRect = CGRect()
    var videoUrl : URL?
    var videoDuration = Double(0)
    
    var videoAllFrames:[UIImage] = [UIImage]()
    var cropDoneBlock:((UIImage)->())?
    
    private var croper: Croper!
    var cropWHRatio = CGFloat(1)
    
    var coverSource = "video"//封面图片来源 video 视频选取  album 相册选取
//    override func viewDidAppear(_ animated: Bool) {
//        self.croper.scrollView.contentOffset = .zero
//        self.croper.imageView.center = CGPointMake(self.croper.cropFrame.midX, self.croper.cropFrame.midY)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        backArrowButton.backImgView.setImgLocal(imgName: "back_arrow_white_icon")
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setupCroper()
        
        let asset = AVAsset(url: videoUrl!)
        self.videoDuration = Double(asset.duration.value)/Double(asset.duration.timescale)
    }
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var configure: Croper.Configure? = {
        guard let image = coverImgView.image else { return nil }
        return Croper.Configure(image)
    }()
    lazy var coverImgView: UIImageView = {
        let img = UIImageView()
        img.layer.shadowRadius = 8
        img.layer.shadowOffset = CGSize(width: 0, height: 5)
        img.layer.shadowColor = UIColor.black.cgColor
        img.layer.shadowOpacity = 0.5
        img.image = VideoEditModel.shared.keyFrames.first
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    lazy var bottomVm: VideoEditBottomVM = {
        let vm = VideoEditBottomVM.init(frame: .zero)
        vm.controller = self
        vm.keyFrameVm.valueChangedBlock = {(percent)in
            self.coverSource = "video"
            var time = Double(percent) * self.videoDuration
            if time < 0 {
                time = 0
            }
            if time > self.videoDuration{
                time = self.videoDuration
            }
            DLLog(message: "valueChanged:\(time)")
            VideoUtils().getFrameForSeconds(seconds: time, videoUrl: self.videoUrl) { image in
                if image != nil{
                    self.coverImgView.image = image
                    self.bottomVm.keyFrameVm.currentImgView.image = image
//                    self.configure = self.croper.getCurrentConfigure()
                    self.configure?.image = image!
                    self.croper.removeFromSuperview()
//                    Croper.margin = UIEdgeInsets(top: self.getNavigationBarHeight()+kFitWidth(15),
//                                                 left: kFitWidth(15),
//                                                 bottom: self.bottomVm.selfHeight + kFitWidth(15),
//                                                 right: kFitWidth(15))
                    self.croper = Croper(frame: CGRect(origin: .zero, size: CGSize.init(width: SCREEN_WIDHT, height: SCREEN_HEIGHT)), configure: self.configure!,idleGridCount: (0,0))
                    self.croper.clipsToBounds = false
                    self.view.insertSubview(self.croper, at: 0)
                }
            }
        }
        vm.choiceImgBlock = {(image)in
            self.coverSource = "album"
            self.coverImgView.image = image
            self.bottomVm.keyFrameVm.currentImgView.image = image
            self.croper.updateImgView(image: image)
        }
        return vm
    }()
}

extension VideoEditVC{
    @objc func saveAction(){
        if self.coverSource == "video"{
            guard let image = self.croper.crop() else {
                DLLog(message: "裁剪失败！")
                return
            }
            self.cropDoneBlock?(image)
        }else{
            guard let image = self.cropImage(from: self.view, frame: self.croper.cropFrame) else {
                DLLog(message: "裁剪失败！")
                return
            }
            self.cropDoneBlock?(image)
        }
        
        self.backTapAction()
    }
    func setupCroper() {
        Croper.margin = UIEdgeInsets(top: getNavigationBarHeight()+kFitWidth(15),
                                     left: kFitWidth(15),
                                     bottom: self.bottomVm.selfHeight + kFitWidth(15),
                                     right: kFitWidth(15))
        
        self.croper = Croper(frame: CGRect(origin: .zero, size: CGSize.init(width: SCREEN_WIDHT, height: SCREEN_HEIGHT)), configure: configure!,idleGridCount: (0,0))
        self.croper.clipsToBounds = false
        self.cropWHRatio = self.configure?.cropWHRatio ?? 1
        view.insertSubview(self.croper, at: 0)
    }
}

extension VideoEditVC{
    func initUI() {
        initNavi(titleStr: "设置封面",isWhite: true)
        view.backgroundColor = .black
        view.clipsToBounds = true
        self.navigationView.backgroundColor = .black
        self.navigationView.addSubview(saveButton)
        view.addSubview(bottomVm)
//        view.addSubview(coverImgView)
        
        setConstrait()
    }
    func setConstrait() {
        saveButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.lessThanOrEqualTo(self.naviTitleLabel)
            make.width.equalTo(kFitWidth(60))
            make.height.equalTo(kFitWidth(44))
        }
//        coverImgView.snp.makeConstraints { make in
//            make.top.equalTo(WHUtils().getNavigationBarHeight())
//            make.bottom.equalTo(bottomVm.snp.top)
//            make.width.equalToSuperview()
//            make.left.equalToSuperview()
//        }
    }
}

extension VideoEditVC{
    func cropImage(from view: UIView, frame: CGRect) -> UIImage? {
        // 确保视图布局更新
        view.layoutIfNeeded()
        
        // 创建渲染器并生成视图的完整图片
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        // 获取图片的缩放因子
        let scale = image.scale
        // 根据缩放因子调整裁剪区域
        let cropRect = CGRect(
            x: frame.origin.x * scale,
            y: frame.origin.y * scale,
            width: frame.width * scale,
            height: frame.height * scale
        )
        
        // 裁剪图片
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        // 生成裁剪后的 UIImage
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}
