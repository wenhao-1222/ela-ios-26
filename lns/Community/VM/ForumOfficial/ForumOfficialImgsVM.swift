//
//  ForumOfficialImgsVM.swift
//  lns
//
//  Created by Elavatine on 2025/1/19.
//

import CHIPageControl

class ForumOfficialImgsVM: UIView {
    
    var selfHeight = kFitWidth(150)
    
    public var spinChainBlock: ((NSDictionary)->())?
    var remotePathGroup = NSArray()
    var imagesForUpload:[UIImage] = [UIImage]()
    var tapBlock:((Int)->())?
    
    var list: [HeroBrowserViewModule] = []
    var imgList:[UIImageView] = [UIImageView]()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.height))
        selfHeight = frame.height
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var scrollView: UIScrollView = {
//        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight-kFitWidth(10)))
        let scro = UIScrollView()
        scro.delegate = self
        
        return scro
    }()
    private(set) lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .COLOR_GRAY_BLACK_25//.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT//WHColor_RGB(r: 241, g: 181, b: 190 )
        pageControl.currentPageIndicatorTintColor = .THEME//WHColor_RGB(r: 255, g: 83, b: 107 )
        pageControl.hidesForSinglePage = true
//        pageControl.indica
//        pageControl.isHidden = true
//        pageControl.addTarget(self, action: #selector(self.pageControlChanged(_:)), for: .valueChanged)
        return pageControl
    }()
    lazy var pageControlTopbanner: CHIPageControlAleppo = {
        let zhView = CHIPageControlAleppo()
        zhView.padding = 8.0
        zhView.inactiveTransparency = 1.0
        zhView.hidesForSinglePage = true
        zhView.radius = kFitWidth(6)
        zhView.tintColor = WHColor_16(colorStr: "999999")//WHColor_RGB(r: 241, g: 181, b: 190 )
        zhView.currentPageTintColor = .THEME//WHColor_RGB(r: 255, g: 83, b: 107 )
        zhView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        return zhView
    }()
}

extension ForumOfficialImgsVM{
    @objc func imgTapAction(tapSender:UITapGestureRecognizer) {
        let img = tapSender.view as? UIImageView
        
        if self.tapBlock != nil{
            self.tapBlock!((img?.tag ?? 0) - 3500)
        }
    }
}

extension ForumOfficialImgsVM{
    func initUI() {
        addSubview(scrollView)
//        addSubview(pageControl)
        addSubview(pageControlTopbanner)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-12))
        }
    }
    func updateUI(dataArray:NSArray){
        self.remotePathGroup = dataArray
        for vi in scrollView.subviews{
            vi.removeFromSuperview()
        }
        self.pageControlTopbanner.numberOfPages = remotePathGroup.count
        self.pageControlTopbanner.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(100))
            make.bottom.equalTo(kFitWidth(0))
            make.height.equalTo(kFitWidth(6))
        }
        list.removeAll()
        imgList.removeAll()
        for i in 0..<self.remotePathGroup.count{
            let img = UIImageView()
            scrollView.addSubview(img)
            img.contentMode = .scaleAspectFit
            img.isUserInteractionEnabled = true
            img.setImgUrl(urlString: self.remotePathGroup[i]as? String ?? "")
            
            img.snp.makeConstraints { make in
                make.left.equalTo(SCREEN_WIDHT*CGFloat(i))
                make.top.height.equalToSuperview()
                make.width.equalTo(SCREEN_WIDHT)
            }
            img.tag = 3500 + i
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction(tapSender: )))
            img.addGestureRecognizer(tap)
            
            imgList.append(img)
            
            DSImageUploader().dealImgUrlSignForOss(urlStr: "\(self.remotePathGroup[i]as? String ?? "")") { signUrl in
                self.list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: signUrl, originImgUrl: signUrl))
            }
        }
        scrollView.contentSize = CGSize.init(width: SCREEN_WIDHT*CGFloat(self.remotePathGroup.count), height: 0)
    }
    func setDataSourcePreview(dataSourceArr:[UIImage]){
        self.remotePathGroup = dataSourceArr as NSArray
        for vi in scrollView.subviews{
            vi.removeFromSuperview()
        }
//        self.pageControl.numberOfPages = remotePathGroup.count
//        
//        var size = self.pageControl.size(forNumberOfPages: self.pageControl.numberOfPages)
//        size.width = min(SCREEN_WIDHT, size.width)
//        self.pageControl.frame = CGRect.init(x: SCREEN_WIDHT*0.5 - size.width*0.5, y: self.bounds.height - kFitWidth(8), width: size.width, height: kFitWidth(6))
        self.pageControlTopbanner.numberOfPages = remotePathGroup.count
//        self.pageControlTopbanner.frame = CGRect.init(x: SCREEN_WIDHT*0.5-kFitWidth(50), y: self.bounds.height-kFitWidth(8), width: kFitWidth(100), height: kFitWidth(6))
        self.pageControlTopbanner.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(100))
            make.bottom.equalTo(kFitWidth(-8))
            make.height.equalTo(kFitWidth(6))
        }
        for i in 0..<self.remotePathGroup.count{
            let img = UIImageView()
            scrollView.addSubview(img)
            img.contentMode = .scaleAspectFit
            img.image = self.remotePathGroup[i]as? UIImage ?? UIImage()
//            img.setImgUrl(urlString: self.remotePathGroup[i]as? String ?? "")
            
            img.snp.makeConstraints { make in
                make.left.equalTo(SCREEN_WIDHT*CGFloat(i))
                make.top.height.equalToSuperview()
                make.width.equalTo(SCREEN_WIDHT)
            }
        }
        scrollView.contentSize = CGSize.init(width: SCREEN_WIDHT*CGFloat(self.remotePathGroup.count), height: 0)
    }
}

extension ForumOfficialImgsVM:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
//        pageControl.currentPage = currentPage
        pageControlTopbanner.progress = Double(currentPage)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
//        pageControl.currentPage = currentPage
        pageControlTopbanner.progress = Double(currentPage)
    }
}
