//
//  HonorDonationVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//


import Foundation

class HonorDonationVM: UIView {
    
    var selfHeight = kFitWidth(100)
    
    private var dataSource = NSArray()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        selfHeight = frame.size.height
        self.backgroundColor = .COLOR_CARD_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
        sendDataRequest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    lazy var bgWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        
        return view
    }()
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: flowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HonorDonationCell.self,
                                forCellWithReuseIdentifier: HonorDonationCell.identifier)
        collectionView.register(HonorDonationEmptyCell.self, forCellWithReuseIdentifier: HonorDonationEmptyCell.identifier)
        return collectionView
    }()
}

extension HonorDonationVM{
    func initUI() {
        addSubview(bgWhiteView)
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    func setConstrait() {
        bgWhiteView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
    }
    /// 根据宽度动态计算列数
    private func calculateColumnCount(
        containerWidth: CGFloat,
        minItemWidth: CGFloat,
        spacing: CGFloat,
        sectionInset: UIEdgeInsets
    ) -> Int {
        
        let availableWidth =
            containerWidth
            - sectionInset.left
            - sectionInset.right
        
        let column = Int(
            (availableWidth + spacing) / (minItemWidth + spacing)
        )
        
        return max(column, 3) // 最少 3 个
    }
    private func updateLayout() {
        let sectionInset = UIEdgeInsets(
            top: kFitWidth(20),
            left: kFitWidth(16),
            bottom: kFitWidth(20),
            right: kFitWidth(16)
        )
        
        let minItemWidth = kFitWidth(95)
        let spacing = kFitWidth(12)
        
        let columnCount = calculateColumnCount(
            containerWidth: collectionView.bounds.width,
            minItemWidth: minItemWidth,
            spacing: spacing,
            sectionInset: sectionInset
        )
        
        let totalSpacing =
            sectionInset.left
            + sectionInset.right
            + CGFloat(columnCount - 1) * spacing
        
        let itemWidth =
            (collectionView.bounds.width - totalSpacing)
            / CGFloat(columnCount)
        
        flowLayout.itemSize = CGSize(
            width: floor(itemWidth),
            height: kFitWidth(150)
        )
        
        flowLayout.sectionInset = sectionInset
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = kFitWidth(24)
    }

}

extension HonorDonationVM: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count == 0 ? 1 : dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dataSource.count == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HonorDonationEmptyCell.identifier,
                for: indexPath
            ) as! HonorDonationEmptyCell
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HonorDonationCell.identifier,
                for: indexPath
            ) as! HonorDonationCell
            
            let dict = self.dataSource[indexPath.row]as? NSDictionary ?? [:]
            cell.config(dict: dict)
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataSource.count == 0 {
            return
        }
        let dict = self.dataSource[indexPath.row]as? NSDictionary ?? [:]
//        let previewView = HonorDonationPreviewView(dict: dict)
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow else {
            return
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? HonorDonationCell else {
               return
           }
           let originFrame = cell.msgContainerFrame(in: window)
           let previewView = HonorDonationPreviewView(
               dict: dict,
               originFrame: originFrame,
               originFrameProvider: { [weak collectionView, weak window] in
                   guard let window = window else { return nil }
                   guard let cell = collectionView?.cellForItem(at: indexPath) as? HonorDonationCell else {
                       return nil
                   }
                   return cell.msgContainerFrame(in: window)
               }
           )
        window.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        window.layoutIfNeeded()
        previewView.layoutIfNeeded()
        let targetFrame = previewView.msgContainerFrame(in: window)
        let snapshot = cell.msgContainerSnapshot() ?? UIView()
        snapshot.frame = originFrame
        window.addSubview(snapshot)
        previewView.prepareForPresentation()
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.2,
            options: [.curveEaseInOut]
        ) {
            snapshot.frame = targetFrame
            previewView.finishPresentation()
        } completion: { _ in
            snapshot.removeFromSuperview()
        }
    }
}

extension HonorDonationVM{
    func sendDataRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_user_achievement_donationCertificate, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDataRequest:\(dataDict)")
            
            self.dataSource = dataDict["donationCertificateList"]as? NSArray ?? []
            self.collectionView.reloadData()
        }
    }
}
