//
//  MallDetailBannerVM.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//


import CHIPageControl

class MallDetailBannerVM: UIView {
    
    var selfHeight = kFitWidth(150)
    
    public var spinChainBlock: ((NSDictionary)->())?
    var remotePathGroup = NSArray()
    var imagesForUpload:[UIImage] = [UIImage]()
    private var currentUrls: [String] = []
    var tapBlock:((Int)->())?
    
    var list: [HeroBrowserViewModule] = []
    var imgList:[UIImageView] = [UIImageView]()
    // MARK: - ⭐️ 新增：自动播放配置
    public var isAutoPlayEnabled: Bool = false {
        didSet { isAutoPlayEnabled ? startAutoPlayTimer() : stopAutoPlayTimer() }
    }
/// 单位：秒，默认 3 秒
    public var autoPlayInterval: TimeInterval = 3.0 {
        didSet {
            // 间隔变化后，如已启用自动播则重启计时器
            if isAutoPlayEnabled { restartAutoPlayTimer() }
        }
    }
    private var autoPlayTimer: Timer?
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
    // MARK: - ⭐️ 新增：进入/离开窗口时的计时器管理
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopAutoPlayTimer()
        } else if isAutoPlayEnabled {
            startAutoPlayTimer()
        }
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.delegate = self
        
        return scro
    }()
    lazy var pageControlTopbanner: CHIPageControlJaloro = {
        let zhView = CHIPageControlJaloro()
        zhView.padding = kFitWidth(6)
        zhView.elementWidth = kFitWidth(32)
        zhView.elementHeight = kFitWidth(2)
//        zhView.inactiveTransparency = 1.0
        zhView.hidesForSinglePage = true
        zhView.radius = kFitWidth(0.5)
        zhView.tintColor = .COLOR_TEXT_TITLE_0f1214_20
        zhView.currentPageTintColor = .THEME//WHColor_RGB(r: 255, g: 83, b: 107 )
//        zhView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        return zhView
    }()
}

extension MallDetailBannerVM{
    @objc func imgTapAction(tapSender:UITapGestureRecognizer) {
        let img = tapSender.view as? UIImageView
        
        if self.tapBlock != nil{
            self.tapBlock!((img?.tag ?? 0) - 3500)
        }
    }
}

extension MallDetailBannerVM{
    func initUI() {
        addSubview(scrollView)
        addSubview(pageControlTopbanner)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
    }
    func updateUI(dataArray:NSArray){
        let newUrls = dataArray.compactMap { $0 as? String }
        if newUrls == currentUrls { return }
        currentUrls = newUrls
        self.remotePathGroup = dataArray
        for vi in scrollView.subviews{
            vi.removeFromSuperview()
        }
        self.pageControlTopbanner.numberOfPages = remotePathGroup.count
        self.pageControlTopbanner.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(100))
            make.left.equalTo(kFitWidth(75))
            make.right.equalTo(kFitWidth(-75))
            make.bottom.equalTo(kFitWidth(-39))
            make.height.equalTo(kFitWidth(2))
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
        scrollView.setContentOffset(CGPoint.zero, animated: false)
        // ⭐️ 数据刷新后，如需自动播放，则重启计时器（只有多页才有意义）
       if isAutoPlayEnabled { restartAutoPlayTimer() }
    }
}

extension MallDetailBannerVM:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        pageControlTopbanner.progress = Double(currentPage)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        pageControlTopbanner.progress = Double(currentPage)
        // 用户惯性滚动停止后，如开启自动播放则恢复
        if isAutoPlayEnabled { startAutoPlayTimer() }
    }
    // ⭐️ 新增：开始拖动时暂停；结束拖动后在上面恢复
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoPlayTimer()
    }
}

// MARK: - ⭐️ 自动播放实现
private extension MallDetailBannerVM {
    func startAutoPlayTimer() {
        guard autoPlayTimer == nil else { return }
        guard pageControlTopbanner.numberOfPages > 1 else { return }
        // 使用 commonModes，确保计时器在 runloop 模式切换时也能运行；
        // 我们在用户拖动时会手动 stop，所以这里无副作用。
        autoPlayTimer = Timer.scheduledTimer(withTimeInterval: autoPlayInterval, repeats: true, block: { [weak self] _ in
            self?.autoScrollToNext()
        })
        RunLoop.main.add(autoPlayTimer!, forMode: .common)
    }
    
    func stopAutoPlayTimer() {
        autoPlayTimer?.invalidate()
        autoPlayTimer = nil
    }
    
    func restartAutoPlayTimer() {
        stopAutoPlayTimer()
        startAutoPlayTimer()
    }
    
    func autoScrollToNext() {
        let pageCount = pageControlTopbanner.numberOfPages
        guard pageCount > 1 else { return }
        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        let nextIndex = currentPage + 1
        if nextIndex >= pageCount {
            // 回到第 0 页（无动画避免“闪回”）
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            pageControlTopbanner.progress = 0
        } else {
            let nextOffset = CGPoint(x: CGFloat(nextIndex) * SCREEN_WIDHT, y: 0)
            scrollView.setContentOffset(nextOffset, animated: true)
            pageControlTopbanner.progress = Double(nextIndex)
        }
    }
}
