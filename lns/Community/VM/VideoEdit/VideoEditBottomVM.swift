//
//  VideoEditBottomVM.swift
//  lns
//
//  Created by Elavatine on 2025/2/19.
//


class VideoEditBottomVM: UIView {
    
    var selfHeight = kFitWidth(120)+WHUtils().getBottomSafeAreaHeight()
    let imgHeight = kFitWidth(44)
    var controller = WHBaseViewVC()
    
    var saveAssetIds:[String] = [String]()
    
    var choiceImgBlock:((UIImage)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.08)
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight+kFitWidth(16)))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.18)
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "左右滑动，选择封面"
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .white
        return lab
    }()
    lazy var fromAlbumImageView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.backgroundColor = .clear//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.25)
//        img.layer.cornerRadius = kFitWidth(8)
//        img.clipsToBounds = true
        img.setImgLocal(imgName: "video_edit_album_icon")
        
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(choiceImgFromAlbum))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var keyFrameVm: VideoEditKeyFrameVM = {
//        let vm = VideoEditKeyFrameVM.init(frame: CGRect.init(x: kFitWidth(16)*2+kFitWidth(56), y: self.fromAlbumImageView.frame.minY, width: SCREEN_WIDHT-kFitWidth(16)*3-kFitWidth(56), height: kFitWidth(56)))
        let vm = VideoEditKeyFrameVM.init(frame: CGRect.init(x: kFitWidth(16)*2+imgHeight, y: kFitWidth(50), width: SCREEN_WIDHT-kFitWidth(16)*3-imgHeight, height: imgHeight))
//        let vm = VideoEditKeyFrameVM.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(50), width: SCREEN_WIDHT-kFitWidth(16)*2, height: imgHeight))
        return vm
    }()
}

extension VideoEditBottomVM{
    @objc func choiceImgFromAlbum() {
        let vc = RITLPhotosViewController()
        vc.configuration.maxCount = 1
        vc.configuration.containVideo = false
        vc.configuration.hiddenGroupWhenNoPhotos = true
        vc.photo_delegate = self
        vc.thumbnailSize = CGSize.init(width: SCREEN_WIDHT*0.7*0.333, height: SCREEN_WIDHT*0.7*0.333)
        vc.defaultIdentifers = self.saveAssetIds
        self.controller.present(vc, animated: true)
    }
}

extension VideoEditBottomVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(fromAlbumImageView)
        bgView.addSubview(keyFrameVm)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
        }
        fromAlbumImageView.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(16))
            make.width.equalTo(imgHeight)
            make.height.equalTo(imgHeight)
        }
    }
}

extension VideoEditBottomVM:RITLPhotosViewControllerDelegate{
    func photosViewController(_ viewController: UIViewController, assetIdentifiers identifiers: [String]) {
        self.saveAssetIds = identifiers
    }
    func photosViewController(_ viewController: UIViewController, images: [UIImage], infos: [[AnyHashable : Any]]) {
        if images.count > 0 {
            if let img = images.first{
                self.choiceImgBlock?(img)
            }
        }
    }
}
