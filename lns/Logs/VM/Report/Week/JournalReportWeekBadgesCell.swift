//
//  JournalReportWeekBadgesCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/15.
//


class JournalReportWeekBadgesCell: UITableViewCell {
    
    let whiteViewWidth = SCREEN_WIDHT-kFitWidth(32)
    let imgWidth = kFitWidth(145)
    
    /// 回调：所有徽章图片加载完成
      var loadImagesComplete: (() -> Void)?
      private var imgTotalCount = 0
      private var imgLoadedCount = 0
      private var imgViews: [UIImageView] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.isSkeletonable = true
        contentView.isSkeletonable = true
        initUI()
    }
    lazy var topBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        lab.adjustsFontSizeToFitWidth = true
        lab.isSkeletonable = true
        lab.text = "本周成就"

        return lab
    }()
}

extension JournalReportWeekBadgesCell{
    
    private func loadImage(into imgView: UIImageView, urlString: String) {
        var signUrl = urlString
        let completion: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.imgLoadedCount += 1
            if self.imgLoadedCount >= self.imgTotalCount {
                self.loadImagesComplete?()
            }
        }
        if urlString.contains("aliyuncs.com") {
            DSImageUploader().dealImgUrlSignForOss(urlStr: urlString) { str in
                signUrl = str
                guard let url = URL(string: signUrl) else { completion(); return }
                imgView.kf.setImage(with: url, placeholder: nil, options: [.cacheOriginalImage,.keepCurrentImageWhileLoading]) { _ in
                    DLLog(message: "JournalReportWeekBadgesCell 加载图片:\(signUrl)")
//                    DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
//                        DLLog(message: "JournalReportWeekBadgesCell 加载图片:(延时回调)\(signUrl)")
                        completion()
//                    })
                }
            }
        } else {
            guard let url = URL(string: signUrl) else { completion(); return }
            imgView.kf.setImage(with: url, placeholder: nil, options: [.cacheOriginalImage,.keepCurrentImageWhileLoading]) { _ in
                DLLog(message: "JournalReportWeekBadgesCell 加载图片:\(signUrl)")
                completion()
            }
        }
    }

    func cancelLoad() {
        for img in imgViews { img.kf.cancelDownloadTask() }
        imgViews.removeAll()
    }
    func updateUI(dict:NSDictionary) {
        let badgesArray = dict["badges"]as? NSArray ?? []
        let viewHeight = kFitWidth(45) + (imgWidth + kFitWidth(16))*CGFloat((badgesArray.count+1)/2)
        
        bgView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.height.equalTo(viewHeight)
            make.bottom.equalToSuperview()
        }
        
        for vi in bgView.subviews{
            vi.removeFromSuperview()
        }
        
        var originX = kFitWidth(16)
        var originY = kFitWidth(45)
        let imgGap = ((SCREEN_WIDHT-kFitWidth(32)) - imgWidth*2-kFitWidth(20))*0.5
        
        for i in 0..<badgesArray.count{
            if i % 2 == 0 {
                if i == badgesArray.count - 1 {//居中显示
                    originX = (SCREEN_WIDHT-kFitWidth(32))*0.5-imgWidth*0.5
                }else{//靠左
                    originX = imgGap
                }
            }else{//靠右
                originX = (SCREEN_WIDHT-kFitWidth(32)) - imgGap - imgWidth
            }
            originY = kFitWidth(45) + CGFloat(i/2) * (imgWidth + kFitWidth(16))
            
            let imgView = UIImageView.init(frame: CGRectMake(originX, originY, imgWidth, imgWidth))
            bgView.addSubview(imgView)
            imgView.setImgUrl(urlString: badgesArray[i]as? String ?? "")
//            imgViews.append(imgView)
//            loadImage(into: imgView, urlString: badgesArray[i]as? String ?? "")
        }
    }
    func updateUIForShare(dict:NSDictionary) {
        let badgesArray = dict["badges"]as? NSArray ?? []//[dataArr[0],dataArr[0],dataArr[0],dataArr[0],dataArr[0]]
        let viewHeight = kFitWidth(45) + (imgWidth + kFitWidth(16))*CGFloat((badgesArray.count+1)/2)
        
        bgView.layer.cornerRadius = 0
        bgView.clipsToBounds = false
        bgView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.height.equalTo(viewHeight)
            make.bottom.equalToSuperview()
        }
        
        
        for vi in bgView.subviews{ vi.removeFromSuperview() }
        imgTotalCount = badgesArray.count
        imgLoadedCount = 0
        imgViews.forEach { $0.kf.cancelDownloadTask() }
        imgViews.removeAll()
//        if badgesArray.count == 0 {
//            loadImagesComplete?()
//            return
//        }
        
        var originX = kFitWidth(16)
        var originY = kFitWidth(45)
        let imgGap = ((SCREEN_WIDHT-kFitWidth(32)) - imgWidth*2-kFitWidth(20))*0.5
        for i in 0..<badgesArray.count{
            if i % 2 == 0 {
                if i == badgesArray.count - 1 {//居中显示
                    originX = (SCREEN_WIDHT-kFitWidth(32))*0.5-imgWidth*0.5
                }else{//靠左
                    originX = imgGap
                }
            }else{//靠右
                originX = (SCREEN_WIDHT-kFitWidth(32)) - imgGap - imgWidth
            }
            originY = kFitWidth(45) + CGFloat(i/2) * (imgWidth + kFitWidth(16))
            
//            let imgView = UIImageView.init(frame: CGRectMake(originX, originY, kFitWidth(90), kFitWidth(90)))
            let imgView = UIImageView.init(frame: CGRectMake(originX, originY, imgWidth, imgWidth))
            bgView.addSubview(imgView)
            
            imgViews.append(imgView)
            loadImage(into: imgView, urlString: badgesArray[i]as? String ?? "")
        }
    }
}

extension JournalReportWeekBadgesCell{
    func initUI() {
        contentView.addSubview(topBgView)
        contentView.addSubview(bgView)
        contentView.addSubview(circleView)
        contentView.addSubview(titleLabel)
        
        setConstrait()
    }
    func setConstrait() {
        topBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(30))
        }
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(26))
            make.width.height.equalTo(kFitWidth(6))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.centerY.lessThanOrEqualTo(circleView)
        }
    }
}
