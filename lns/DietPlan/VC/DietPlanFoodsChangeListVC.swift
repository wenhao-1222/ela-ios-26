//
//  DietPlanFoodsChangeListVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/13.
//  URL_diet_plan_foods_change_list
//

import UIKit
import MCToast
import SnapKit

struct DietPlanFoodsChangeItem {
    let mealId: String
    let mealImage: String
    let mealName: String
}

class DietPlanFoodsChangeListVC: WHBaseViewVC {
    private let loadingCount = 4
    private let sectionInset = UIEdgeInsets(top: kFitWidth(14), left: kFitWidth(16), bottom: kFitWidth(24), right: kFitWidth(16))
    private let itemSpacing = kFitWidth(12)
    
    var id = ""
    var templateMealId = ""
    var choiceDate = ""//选择的日期
    var replaceSuccessBlock: ((NSDictionary) -> Void)?
    
    private var isLoading = true
    private var mealItems: [DietPlanFoodsChangeItem] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = sectionInset
        layout.minimumLineSpacing = itemSpacing
        layout.minimumInteritemSpacing = itemSpacing
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.dataSource = self
        view.delegate = self
        view.register(DietPlanFoodsChangeCell.self, forCellWithReuseIdentifier: DietPlanFoodsChangeCell.reuseId)
        return view
    }()
    
//    private lazy var skipButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.setTitle("跳过这餐", for: .normal)
//        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
//        button.backgroundColor = .COLOR_BG_F2
//        button.layer.cornerRadius = kFitWidth(24)
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.COLOR_BG_BLACK_06.cgColor
//        button.clipsToBounds = true
//        button.enablePressEffect()
//        button.addTarget(self, action: #selector(skipMealAction), for: .touchUpInside)
//        return button
//    }()
    
//    private lazy var refreshButton: GJVerButtonNoneFeedBack = {
//        let button = GJVerButtonNoneFeedBack(type: .custom)
//        button.setTitle("换一批", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
//        let icon = UIImage(named: "dietplan_foods_refresh_icon")?.withRenderingMode(.alwaysTemplate)
//        button.setImage(icon, for: .normal)
//        button.tintColor = .white
//        button.backgroundColor = .THEME
//        button.layer.cornerRadius = kFitWidth(22)
//        button.clipsToBounds = true
//        button.enablePressEffect()
//        button.addTarget(self, action: #selector(refreshListAction), for: .touchUpInside)
//        return button
//    }()
    
    lazy var refreshButton: GJVerButtonNoneFeedBack = {
        let frame = CGRect(x: kFitWidth(16),
                           y: kFitWidth(61) + statusBarHeight,
                           width: kFitWidth(106),
                           height: kFitWidth(71))
        let button = makeRecipeActionButton(title: "换一批",
                                      imageName: "dietplan_foods_refresh_icon",
                                      imageSize: CGSize(width: kFitWidth(20), height: kFitWidth(20)),
                                      frame: frame)
        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.tintColor = .white
        button.backgroundColor = .THEME
        button.layer.cornerRadius = kFitWidth(22)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(refreshListAction), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无可替换食谱"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        beginLoadingState()
        sendDietPlanFoodsChangeListRequest()
    }
}

extension DietPlanFoodsChangeListVC {
    func initUI() {
        initNavi(titleStr: "选择替换")
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
//        view.addSubview(skipButton)
        view.addSubview(refreshButton)
        
        refreshButton.layoutIfNeeded()
        refreshButton.imagePosition(style: .left, spacing: kFitWidth(10))
        updateRefreshButtonState(isEnabled: false)
        
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(getNavigationBarHeight())
            make.bottom.equalTo(refreshButton.snp.top).offset(kFitWidth(-18))
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(collectionView)
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
        }
        
        refreshButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(-(getBottomSafeAreaHeight() + kFitWidth(16)))
            make.height.equalTo(kFitWidth(44))
            make.right.equalTo(kFitWidth(-16))
//            make.width.equalTo((SCREEN_WIDHT - kFitWidth(44)) * 0.5)
        }
        
//        refreshButton.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
//            make.centerY.height.width.equalTo(skipButton)
//        }
    }
    
    func beginLoadingState() {
        isLoading = true
        mealItems.removeAll()
        emptyLabel.isHidden = true
        updateRefreshButtonState(isEnabled: false)
        collectionView.reloadForSkeleton()
    }
    
    func endLoadingState(items: [DietPlanFoodsChangeItem]) {
        isLoading = false
        mealItems = Array(items.prefix(loadingCount))
        emptyLabel.isHidden = !mealItems.isEmpty
        updateRefreshButtonState(isEnabled: true)
        collectionView.reloadData()
    }
    
    func updateRefreshButtonState(isEnabled: Bool) {
        refreshButton.isEnabled = isEnabled
        refreshButton.alpha = isEnabled ? 1.0 : 0.55
    }
    
    func makeRecipeActionButton(title: String,
                                imageName: String,
                                imageSize: CGSize,
                                frame: CGRect) -> GJVerButtonNoneFeedBack {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = frame
        btn.setTitle(title, for: .normal)
        let image = resizedImage(named: imageName, size: imageSize) ?? UIImage(named: imageName)
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .disabled)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(16)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layoutIfNeeded()
        btn.imagePosition(style: .top, spacing: kFitWidth(8))
        return btn
    }
    
    func resizedImage(named: String, size: CGSize) -> UIImage? {
        guard let image = UIImage(named: named),
              size.width > 0,
              size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension DietPlanFoodsChangeListVC {
    @objc func skipMealAction() {
        backTapAction()
    }
    
    @objc func refreshListAction() {
        guard !templateMealId.isEmpty else {
            MCToast.mc_text("餐食信息异常")
            return
        }
        beginLoadingState()
        sendDietPlanFoodsChangeListRequest()
    }
    
    func handleSelectMeal(_ item: DietPlanFoodsChangeItem) {
        DLLog(message: "select replacement meal: \(item.mealId)")
        self.sendReplaceFoodsRequest(mealId: "\(item.mealId)")
    }
}

extension DietPlanFoodsChangeListVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isLoading ? loadingCount : mealItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DietPlanFoodsChangeCell.reuseId, for: indexPath) as? DietPlanFoodsChangeCell ?? DietPlanFoodsChangeCell()
        
        if isLoading {
            cell.updateUI(item: nil, isLoading: true)
            return cell
        }
        
        let item = indexPath.item < mealItems.count ? mealItems[indexPath.item] : nil
        cell.updateUI(item: item, isLoading: false)
        cell.chooseTapBlock = { [weak self] in
//            guard let item = item else { return }
            self?.handleSelectMeal(item!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = indexPath.item < mealItems.count ? mealItems[indexPath.item] : nil
        
        let vc = DietPlanFoodsDetailVC()
        vc.mealId = item?.mealId ?? ""
        vc.replacePlanItemId = id
        vc.replaceSuccessBlock = replaceSuccessBlock
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let width = floor((contentWidth - itemSpacing) * 0.5)
        return CGSize(width: width, height: kFitWidth(195))
    }
}

extension DietPlanFoodsChangeListVC {
    func sendDietPlanFoodsChangeListRequest() {
        let param = ["templateMealId": templateMealId]
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_foods_change_list,
                                          parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDietPlanFoodsChangeListRequest:\(dataObj)")
            
            let items = self.parseMealItems(from: dataObj)
            self.endLoadingState(items: items)
        }
    }
    
    func sendReplaceFoodsRequest(mealId:String) {
        let param = ["userMealPlanItemId": id,
                     "mealId":mealId]
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_foods_replace, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendReplaceFoodsRequest:\(dataString)")
            self.replaceSuccessBlock?(dataObj)
            self.backTapAction()
        }
    }
    
    func parseMealItems(from source: NSArray?) -> [DietPlanFoodsChangeItem] {
        let array = source ?? []
        return array.compactMap { obj in
            let dict = obj as? NSDictionary ?? [:]
            let mealId = dict.stringValueForKey(key: "mealId")
            guard !mealId.isEmpty else { return nil }
            return DietPlanFoodsChangeItem(mealId: mealId,
                                           mealImage: dict.stringValueForKey(key: "mealImage"),
                                           mealName: dict.stringValueForKey(key: "mealName"))
        }
    }
}
