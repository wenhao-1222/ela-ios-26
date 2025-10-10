//
//  MarketListVM.swift
//  lns
//  商品列表
//  Created by Elavatine on 2025/9/5.
//

import MJRefresh

class MarketListVM : UIView{
    
    let selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()//-WHUtils().getTabbarHeight()
    
    var controller = WHBaseViewVC()
    
    var pageNum = 1
    var pageSize = 10
    
    var dataSourceArray:[MarketListModel] = [MarketListModel]()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        initUI()
        
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW, scenarioType: .mall_list, text: "商品列表页")
        self.sendMallListRequest()
        
        collectView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.pageNum = 1
            self.sendMallListRequest()
        })
        collectView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
            self.pageNum += 1
            self.sendMallListRequest()
        })
    }
    let collectView : JournalCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (SCREEN_WIDHT-kFitWidth(29))*0.5, height: kFitWidth(278))
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let vi = JournalCollectionView.init(frame: CGRect.init(x: kFitWidth(9), y: 0, width: SCREEN_WIDHT-kFitWidth(29), height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()), collectionViewLayout: layout)
//        let vi = JournalCollectionView.init(frame: CGRect.init(x: kFitWidth(9), y: 0, width: SCREEN_WIDHT-kFitWidth(29), height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-WHUtils().getTabbarHeight()), collectionViewLayout: layout)
        
        vi.collectionViewLayout = layout
        vi.backgroundColor = .white
        vi.showsVerticalScrollIndicator = false
        
        vi.register(MarketListGridCell.classForCoder(), forCellWithReuseIdentifier: "MarketListGridCell")
        vi.register(MarketListHeroCell.classForCoder(), forCellWithReuseIdentifier: "MarketListHeroCell")
        
        vi.contentInsetAdjustmentBehavior = .never
        
        return vi
    }()
}

extension MarketListVM:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.dataSourceArray[indexPath.row]
        if indexPath.row == 0 && model.isTop{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketListHeroCell", for: indexPath) as? MarketListHeroCell
            
            cell?.updateUI(model: model)
            
            return cell ?? MarketListHeroCell()
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketListGridCell", for: indexPath)as? MarketListGridCell
            
            cell?.updateUI(model: model)
            
            return cell  ?? MarketListGridCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = self.dataSourceArray[indexPath.row]
        if indexPath.row == 0 && model.isTop{
            return CGSize(width: collectionView.frame.width, height: kFitWidth(310))
        }else{
            return CGSize(width: collectionView.frame.width * 0.5, height: kFitWidth(278))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.dataSourceArray[indexPath.row]
        let vc = MallDetailVC()
        vc.listModel = model
        self.controller.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MarketListVM{
    func initUI() {
        addSubview(collectView)
        collectView.delegate = self
        collectView.dataSource = self
    }
}

extension MarketListVM{
    func sendMallListRequest() {
        
        let param = ["page":"\(pageNum)",
                     "pageSize":"\(pageSize)"]
        
//        WHNetworkUtil.shareManager().POST(urlString: URL_mall_list, parameters: param as [String:AnyObject]) { responseObject in
        WHNetworkUtil.shareManager().POST(urlString: URL_mall_list, parameters: param as [String:AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendMallListRequest:\(dataArr)")
            
//            self.collectView.mj_header?.endRefreshing()
//            
//            if dataArr.count < self.pageNum{
//                self.collectView.mj_footer?.endRefreshingWithNoMoreData()
//            }else{
//                self.collectView.mj_footer?.endRefreshing()
//            }
//            if self.pageNum == 1{
//                self.dataSourceArray.removeAll()
//            }
            
//            for i in 0..<dataArr.count{
//                let dict = dataArr[i]as? NSDictionary ?? [:]
//                let model = MarketListModel().dealDictForModel(dict: dict)
//                self.dataSourceArray.append(model)
//            }
//            
//            self.collectView.reloadData()
            
            

              let isFirstPage = self.pageNum == 1
              var newModels: [MarketListModel] = []
            for i in 0..<dataArr.count{
                let dict = dataArr[i]as? NSDictionary ?? [:]
                let model = MarketListModel().dealDictForModel(dict: dict)
//                self.dataSourceArray.append(model)
                newModels.append(model)
            }
            
            DispatchQueue.main.async {
                let previousModels = self.dataSourceArray
                let hasMore = newModels.count >= self.pageSize

                self.collectView.mj_header?.endRefreshing()

                if isFirstPage {
                    if hasMore {
                        self.collectView.mj_footer?.resetNoMoreData()
                    } else {
                        self.collectView.mj_footer?.endRefreshingWithNoMoreData()
                    }

                    self.applyFirstPageUpdate(previousModels: previousModels, newModels: newModels)
                } else {
                    if hasMore {
                        self.collectView.mj_footer?.endRefreshing()
                    } else {
                        self.collectView.mj_footer?.endRefreshingWithNoMoreData()
                    }

                    guard !newModels.isEmpty else { return }

                    let previousCount = previousModels.count
                    self.dataSourceArray.append(contentsOf: newModels)

                    let indexPaths = newModels.enumerated().map { IndexPath(item: previousCount + $0.offset, section: 0) }

                    self.collectView.performBatchUpdates({
                        self.collectView.insertItems(at: indexPaths)
                    }, completion: nil)
                }
            }
        }
    }
}

extension MarketListVM {
    private func applyFirstPageUpdate(previousModels: [MarketListModel], newModels: [MarketListModel]) {
        var shouldReloadAll = false
        var changedIndexPaths: [IndexPath] = []

        let sharedCount = min(previousModels.count, newModels.count)

        if sharedCount > 0 {
            for index in 0..<sharedCount {
                let previousModel = previousModels[index]
                let newModel = newModels[index]

                if previousModel.id != newModel.id || previousModel.isTop != newModel.isTop {
                    shouldReloadAll = true
                    break
                }

                if previousModel.imgUrlForListShow != newModel.imgUrlForListShow {
                    changedIndexPaths.append(IndexPath(item: index, section: 0))
                }
            }
        }

        if shouldReloadAll {
            self.dataSourceArray = newModels
            self.collectView.reloadData()
            return
        }

        let previousCount = previousModels.count
        let newCount = newModels.count

        let deletions: [IndexPath]
        if previousCount > newCount {
            deletions = (newCount..<previousCount).map { IndexPath(item: $0, section: 0) }
        } else {
            deletions = []
        }

        let insertions: [IndexPath]
        if newCount > previousCount {
            insertions = (previousCount..<newCount).map { IndexPath(item: $0, section: 0) }
        } else {
            insertions = []
        }

        let changedIndexPathSet = Set(changedIndexPaths)

        let performUpdates = !deletions.isEmpty || !insertions.isEmpty

        let updateVisibleCells = {
            self.refreshVisibleCells(with: newModels, skipping: changedIndexPathSet)
        }

        if performUpdates {
            self.collectView.performBatchUpdates({
                self.dataSourceArray = newModels
                if !deletions.isEmpty {
                    self.collectView.deleteItems(at: deletions)
                }

                if !insertions.isEmpty {
                    self.collectView.insertItems(at: insertions)
                }
            }, completion: { _ in
                if !changedIndexPaths.isEmpty {
                    self.collectView.reloadItems(at: changedIndexPaths)
                }

                updateVisibleCells()
            })
        } else {
            self.dataSourceArray = newModels
            if !changedIndexPaths.isEmpty {
                self.collectView.reloadItems(at: changedIndexPaths)
            }

            updateVisibleCells()
        }
    }

    private func refreshVisibleCells(with models: [MarketListModel], skipping skippedIndexPaths: Set<IndexPath>) {
        for indexPath in self.collectView.indexPathsForVisibleItems {
            guard indexPath.section == 0,
                  indexPath.item < models.count,
                  !skippedIndexPaths.contains(indexPath) else { continue }

            let model = models[indexPath.item]
            guard let cell = self.collectView.cellForItem(at: indexPath) else { continue }

            if let heroCell = cell as? MarketListHeroCell {
                heroCell.updateUI(model: model)
            } else if let gridCell = cell as? MarketListGridCell {
                gridCell.updateUI(model: model)
            }
        }
    }
}
