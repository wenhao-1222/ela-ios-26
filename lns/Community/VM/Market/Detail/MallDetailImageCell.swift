//
//  MallDetailImageCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//


class MallDetailImageCell: UITableViewCell {
    
    var viewModules:[HeroBrowserViewModule] = []
    
    private var currentImgUrl: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_WHITE
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleToFill
        img.backgroundColor = .COLOR_TEXT_TITLE_0f1214_03
        img.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapAction))
        img.addGestureRecognizer(tap)

        return img
    }()
}
extension MallDetailImageCell{
    func updateText(imgUrl:String) {
        if currentImgUrl == imgUrl { return }
        currentImgUrl = imgUrl
        self.viewModules.removeAll()
        DSImageUploader().dealImgUrlSignForOss(urlStr: "\(imgUrl)") { signUrl in
            self.viewModules.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: signUrl, originImgUrl: signUrl))
        }
        
        imgView.setImgUrlWithComplete(urlString: imgUrl) {
            let imgW = self.imgView.image?.size.width ?? 1
            let imgH = self.imgView.image?.size.height ?? 0
            let finalHeight = imgH / imgW * SCREEN_WIDHT
            self.imgView.snp.remakeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(finalHeight)
                make.bottom.equalToSuperview()
            }
            if let tableView = self.superview as? UITableView {
                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    tableView.layoutIfNeeded()
                }
            }
        }
    }
    @objc func imgTapAction() {
        guard let vc = UIApplication.topViewController() else { return }
        vc.hero.browserPhoto(viewModules: viewModules, initIndex: 0) {
            [
                .pageControlType(.pageControl),
                .heroView(self.imgView)
            ]
        }
    }
}

extension MallDetailImageCell{
    func initUI() {
        contentView.addSubview(imgView)
        
        imgView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
}
