//
//  HonorIconVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//


import Foundation

struct HonorIconModel {
    let iconName: String
    let percentText: String
    let title: String
    let dateText: String?
    let isAchieved: Bool
}

class HonorIconVM: UIView {
    
    var selfHeight = kFitWidth(100)
    
    var dataBlock:((NSDictionary)->())?
    
    private var dataSource: [HonorIconModel] = []
    
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
        collectionView.register(HonorIconCell.self,
                                forCellWithReuseIdentifier: HonorIconCell.identifier)
        return collectionView
    }()
}

extension HonorIconVM{
    func initUI() {
        addSubview(bgWhiteView)
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
//        setupCollection()
//        mockData()
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


extension HonorIconVM{
    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func mockData() {
        for i in 0..<16{
            if i < 4 {
                dataSource.append(HonorIconModel(iconName: "icon_95_blue",
                                                 percentText: "95%",
                                                 title: "精准掌控者",
                                                 dateText: "2025.01.15",
                                                 isAchieved: true))
            }else{
                dataSource.append(HonorIconModel(iconName: "icon_90_gray",
                                                 percentText: "90%",
                                                 title: "达标新秀",
                                                 dateText: nil,
                                                 isAchieved: false))
            }
        }
        collectionView.reloadData()
    }
}

extension HonorIconVM: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HonorIconCell.identifier,
            for: indexPath
        ) as! HonorIconCell
        
        cell.config(model: dataSource[indexPath.item])
        return cell
    }
}

extension HonorIconVM{
    func sendDataRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_user_achievement_badgeWall, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let dataArray = dataDict["badgeList"]as? NSArray ?? []
            DLLog(message: "sendDataRequest:\(dataArray)")
            
            self.dealDataSource(dataArray: dataArray)
            self.dataBlock?(dataDict)
        }
    }
    
    func dealDataSource(dataArray:NSArray) {
        for i in 0..<dataArray.count{
            let dataDict = dataArray[i]as? NSDictionary ?? [:]
            dataSource.append(HonorIconModel(iconName: dataDict.stringValueForKey(key: "badgeIconUrl"),
                                             percentText: "",
                                             title: dataDict.stringValueForKey(key: "badgeName"),
                                             dateText: dataDict.stringValueForKey(key: "ctime"),
                                             isAchieved: dataDict.stringValueForKey(key: "earned") == "1"))
        }
        self.collectionView.reloadData()
    }
}
