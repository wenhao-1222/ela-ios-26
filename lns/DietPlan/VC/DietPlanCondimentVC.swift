//
//  DietPlanCondimentVC.swift
//  lns
//   酱料
//  Created by LNS2 on 2026/3/16.
//


class DietPlanCondimentVC: WHBaseViewVC {
    private var sauceArray = NSArray()
    private var isLoading = true
    private let recommendAlertShownKey = "dietplan_condiment_recommend_alert_shown"

    private lazy var recommendAlertVM = DietPlanCondimentAlertVM(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.sendSauceListRequest()
        })
        showRecommendAlertIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bottomGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        topGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
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
    
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
}

extension DietPlanCondimentVC{
    func initUI() {
        initNavi(titleStr: "酱料")
        self.navigationView.backgroundColor = .COLOR_BG_F2
        view.backgroundColor = .COLOR_BG_F2

        view.addSubview(tipDotView)
        view.addSubview(tipLabel)
        view.addSubview(collectionView)
        view.addSubview(topGradientView)
        view.addSubview(bottomGradientView)
        view.addSubview(recommendAlertVM)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)

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
            make.top.equalTo(tipLabel.snp.bottom)//.offset(kFitWidth(24))
        }
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(collectionView.snp.top)//.offset(kFitWidth(-10))
            make.height.equalTo(kFitWidth(15))
        }
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(35)+self.getTopSafeAreaHeight())
        }
    }

    func showRecommendAlertIfNeeded() {
        guard UserDefaults.standard.bool(forKey: recommendAlertShownKey) == false else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard UserDefaults.standard.bool(forKey: self.recommendAlertShownKey) == false else { return }

            UserDefaults.standard.set(true, forKey: self.recommendAlertShownKey)
            self.recommendAlertVM.showSelf()
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(SCREEN_WIDHT, kFitWidth(30))
    }
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
