//
//  DietPlanCondimentVC.swift
//  lns
//   酱料
//  Created by LNS2 on 2026/3/16.
//


class DietPlanCondimentVC: WHBaseViewVC {
    private var sauceArray = NSArray()
    private var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.sendSauceListRequest()
        })
    }

    private lazy var tipDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .THEME
        view.layer.cornerRadius = kFitWidth(3)
        return view
    }()

    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = "每餐建议用量：≤2份"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = kFitWidth(12)
        layout.minimumInteritemSpacing = kFitWidth(12)
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: kFitWidth(16),
                                           bottom: kFitWidth(24) + self.getBottomSafeAreaHeight(),
                                           right: kFitWidth(16))
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.dataSource = self
        view.delegate = self
        view.register(DietPlanCondimentCell.self, forCellWithReuseIdentifier: DietPlanCondimentCell.reuseId)
        return view
    }()
}

extension DietPlanCondimentVC{
    func initUI() {
        initNavi(titleStr: "酱料")
        view.backgroundColor = .COLOR_BG_F2

        view.addSubview(tipDotView)
        view.addSubview(tipLabel)
        view.addSubview(collectionView)

        tipDotView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(self.getNavigationBarHeight() + kFitWidth(27))
            make.width.height.equalTo(kFitWidth(6))
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(tipDotView.snp.right).offset(kFitWidth(6))
            make.centerY.equalTo(tipDotView)
            make.right.lessThanOrEqualTo(kFitWidth(-16))
        }
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tipLabel.snp.bottom).offset(kFitWidth(24))
        }
    }
}

extension DietPlanCondimentVC{
    func sendSauceListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_condiment, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendSauceListRequest:\(dataArray)")

            self.isLoading = false
            self.sauceArray = dataArray as NSArray
            self.collectionView.reloadData()
        }
    }
}

extension DietPlanCondimentVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 6
        }
        return sauceArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DietPlanCondimentCell.reuseId, for: indexPath) as? DietPlanCondimentCell ?? DietPlanCondimentCell()
        let dict = isLoading ? nil : (sauceArray[indexPath.item] as? NSDictionary ?? [:])
        cell.updateUI(dict: dict, isLoading: isLoading)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding = kFitWidth(16) * 2
        let itemSpacing = kFitWidth(12)
        let itemWidth = floor((SCREEN_WIDHT - horizontalPadding - itemSpacing) * 0.5)
        return CGSize(width: itemWidth, height: kFitWidth(190))
    }
}
