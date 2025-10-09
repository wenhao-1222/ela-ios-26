//
//  WHAlbumPickerVC.swift
//  lns
//
//  Created by Elavatine on 2024/12/5.
//

import Photos

//相簿列表项
struct WHImageAlbumItem {
    //相簿名称
    var title:String?
    //相簿内的资源
    var fetchResults:PHFetchResult<PHAsset>
}

class WHAlbumPickerVC: UIViewController {
    
    //相簿列表项集合
    var items:[WHImageAlbumItem] = []
    
    //每次最多可选择的照片数量
    var maxSelected:Int = 9
    
    //照片选择完毕后的回调
    var completeHandler:((_ assets:[PHAsset])->())?
    
    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>?
    
    //带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    //缩略图大小
    var assetGridThumbnailSize:CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        //根据单元格的尺寸计算我们需要的缩略图大小
        let scale = UIScreen.main.scale
        let cellSize = CGSize(width: SCREEN_WIDHT*0.25, height: SCREEN_WIDHT*0.25)
        assetGridThumbnailSize = CGSize(width: cellSize.width*scale ,
                                        height: cellSize.height*scale)
        
        initUI()
        initData()
    }
    public lazy var collectionView : UICollectionView = {
        let layout = CollectionPageFlowLayout.init() // 给分页添加间距
//        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = kFitWidth(2)
        layout.minimumInteritemSpacing = kFitWidth(2)
        layout.itemSize = CGSize(width: (SCREEN_WIDHT - kFitWidth(6))*0.25, height: SCREEN_WIDHT*0.25)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kFitWidth(4), right: 0)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
//        collectionView.keyboardDismissMode = .onDrag
//        collectionView.alwaysBounceVertical = false // 不允许上下弹跳
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(WHAlbumPickerCollectionCell.self, forCellWithReuseIdentifier: "WHAlbumPickerCollectionCell")
        
        return collectionView
    }()
}

extension WHAlbumPickerVC{
    func initUI() {
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight())

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    func initData() {
        //申请权限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            
            // 列出所有系统的智能相册
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                              subtype: .albumRegular,
                                                              options: smartOptions)
            self.convertCollection(collection: smartAlbums)
            
            //列出所有用户创建的相册
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self.convertCollection(collection: userCollections
                as! PHFetchResult<PHAssetCollection>)
            
            //相册按包含的照片数量排序（降序）
            self.items.sort { (item1, item2) -> Bool in
                return item1.fetchResults.count > item2.fetchResults.count
            }
            
            //异步加载表格数据,需要在主线程中调用reloadData() 方法
            DispatchQueue.main.async{
                self.assetsFetchResults = self.items.first?.fetchResults
                self.collectionView.reloadData()
            }
        })
    }
}

extension WHAlbumPickerVC:UICollectionViewDelegate,UICollectionViewDataSource{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WHAlbumPickerCollectionCell", for: indexPath) as! WHAlbumPickerCollectionCell
        let asset = self.assetsFetchResults![indexPath.row]
        //获取缩略图
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                                       contentMode: .aspectFill, options: nil) {
                                        (image, info) in
            DLLog(message: "imageManager.requestImage:\(image)   ----- \(info)")
            cell.imgView.image = image
        }
        
        return cell
    }
}

extension WHAlbumPickerVC{
    //转化处理获取到的相簿
    private func convertCollection(collection:PHFetchResult<PHAssetCollection>){
        for i in 0..<collection.count{
            //获取当前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                               ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                   PHAssetMediaType.image.rawValue)
//            resultsOptions.predicate = NSPredicate(format: "mediaType = %d",
//                                                   PHAssetMediaType.video.rawValue)
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0 {
                let title = titleOfAlbumForChinse(title: c.localizedTitle)
                items.append(WHImageAlbumItem(title: title,
                                              fetchResults: assetsFetchResult))
                DLLog(message: "assetsFetchResult items:\(items)")
            }
        }
    }
    
    //由于系统返回的相册集名称为英文，我们需要转换为中文
    private func titleOfAlbumForChinse(title:String?) -> String? {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }
}
