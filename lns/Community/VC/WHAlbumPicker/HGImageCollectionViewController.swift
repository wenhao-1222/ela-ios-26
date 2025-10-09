//
//  HGImageCollectionViewController.swift
//  hangge_1512
//
//  Created by hangge on 2017/1/7.
//  Copyright © 2017年 hangge.com. All rights reserved.
//

import UIKit
import Photos
import MCToast

struct AssetModel{
    var assets = PHAsset()
    var isSelect = false
    var selectIndex = 0
    var indexPath = IndexPath()
}

//图片缩略图集合页控制器
class HGImageCollectionViewController: UIViewController {
    //用于显示所有图片缩略图的collectionView
    @IBOutlet weak var collectionView:UICollectionView!
    
    //下方工具栏
    @IBOutlet weak var toolBar:UIToolbar!

    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>?
    var dataSourceArray:[AssetModel] = [AssetModel]()
    var selectItems:[AssetModel] = [AssetModel]()
    
    var selectStatusArray:[Int] = [Int]()
    var selectCount = 0
    
    //带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    //缩略图大小
    var assetGridThumbnailSize:CGSize!
    
    //每次最多可选择的照片数量
    var maxSelected:Int = Int.max
    
    //照片选择完毕后的回调
    var completeHandler:((_ assets:[PHAsset])->())?
    
    //完成按钮
    var completeButton:HGImageCompleteButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //根据单元格的尺寸计算我们需要的缩略图大小
        let scale = UIScreen.main.scale
        let cellSize = (self.collectionView.collectionViewLayout as!
            UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width: cellSize.width*scale ,
                                        height: cellSize.height*scale)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //背景色设置为白色（默认是黑色）
        self.collectionView.backgroundColor = UIColor.white
        
        //初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        
        //设置单元格尺寸
        let layout = (self.collectionView.collectionViewLayout as!
            UICollectionViewFlowLayout)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/4-1,
                                 height: UIScreen.main.bounds.size.width/4-1)
        //允许多选
        self.collectionView.allowsMultipleSelection = true
        
        //添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain,
                                           target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = rightBarItem
      
        //添加下方工具栏的完成按钮
        completeButton = HGImageCompleteButton()
        completeButton.addTarget(target: self, action: #selector(finishSelect))
        completeButton.center = CGPoint(x: UIScreen.main.bounds.width - 50, y: 22)
        completeButton.isEnabled = false
        toolBar.addSubview(completeButton)
    }

    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    
    //取消按钮点击
    @objc func cancel() {
        //退出当前视图控制器
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //获取已选择个数
    func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems?.count ?? 0
    }

    //完成按钮点击
    @objc func finishSelect(){
        //取出已选择的图片资源
        var assets:[PHAsset] = []
//        if let indexPaths = self.collectionView.indexPathsForSelectedItems{
//            for indexPath in indexPaths{
//                assets.append(assetsFetchResults![indexPath.row] )
//            }
//        }
        
        for model in self.selectItems{
            assets.append(model.assets)
        }
        
        //调用回调函数
        self.navigationController?.dismiss(animated: true, completion: {
            self.completeHandler?(assets)
        })
    }
}

//图片缩略图集合页控制器UICollectionViewDataSource,UICollectionViewDelegate协议方法的实现
extension HGImageCollectionViewController:UICollectionViewDataSource
,UICollectionViewDelegate{
    //CollectionView项目
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults?.count ?? 0
    }
    
    // 获取单元格
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //获取storyboard里设计的单元格，不需要再动态添加界面元素
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                    for: indexPath) as! HGImageCollectionViewCell
        let asset = self.assetsFetchResults![indexPath.row]
        
        //获取缩略图
        if assetGridThumbnailSize == nil {
            assetGridThumbnailSize = CGSize(width: SCREEN_WIDHT*0.24, height: SCREEN_WIDHT*0.24)
        }
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                                       contentMode: .aspectFill, options: nil) {
                                        (image, nfo) in
            cell.imageView.image = image
        }
        
        if asset.mediaType == .video{
            self.getVideoDuration(for: asset) { duration in
                let minute = (Int(duration))/Int(60)
                let seconds = (Int(duration.rounded())) - minute * 60
                DispatchQueue.main.async {
                    if seconds < 10 {
                        cell.timeLabel.text = "\(Int(minute)):0\(seconds)"
                    }else{
                        cell.timeLabel.text = "\(Int(minute)):\(seconds)"
                    }
                }
            }
        }else{
            cell.timeLabel.text = ""
        }
        
        if self.selectStatusArray[indexPath.row] == 1{
            cell.selectedIcon.image = UIImage(named: "hg_image_selected")
            cell.selectedIndexLabel.isHidden = false
            for i in 0..<self.selectItems.count{
                if asset == self.selectItems[i].assets{
                    cell.selectedIndexLabel.text = "\(self.selectItems[i].selectIndex+1)"
                    break
                }
            }
        }else{
            cell.selectedIndexLabel.isHidden = true
            cell.selectedIcon.image = UIImage(named: "hg_image_not_selected")
        }
        
        if UserConfigModel.shared.selectType == .IMAGE{
            if asset.mediaType == .video && selectCount > 0{
                cell.showCoverView(isShow: true)
            }else{
                if self.selectCount >= maxSelected{
                    if self.selectStatusArray[indexPath.row] == 1{
                        cell.showCoverView(isShow: false)
                    }else{
                        cell.showCoverView(isShow: true)
                    }
                }else{
                    cell.showCoverView(isShow: false)
                }
            }
        }else{
            if asset.mediaType == .image{
                cell.showCoverView(isShow: true)
            }else{
                if self.selectStatusArray[indexPath.row] == 1{
                    cell.showCoverView(isShow: false)
                }else{
                    cell.showCoverView(isShow: true)
                }
            }
        }
        return cell
    }
    
    //单元格选中响应
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)
            as? HGImageCollectionViewCell{
            
            let asset = self.assetsFetchResults![indexPath.row]
            let status = self.selectStatusArray[indexPath.row]
            
            UserConfigModel.shared.selectType = asset.mediaType == .video ? .VIDEO : .IMAGE
            if status == 0 {
                if selectCount >= maxSelected{
                    return
                }
                selectStatusArray[indexPath.row] = 1
                selectCount = selectCount + 1
                //改变完成按钮数字，并播放动画
                completeButton.num = selectCount
                if selectCount > 0 && !self.completeButton.isEnabled{
                    completeButton.isEnabled = true
                }
//                cell.playAnimate()
                selectItems.append(AssetModel(assets: asset,isSelect: status != 1,selectIndex: selectCount-1,indexPath: indexPath))
                if selectItems.count == maxSelected || selectCount == 1{
                    self.collectionView.reloadData()
                }else{
                    cell.selectedIndexLabel.isHidden = false
                    cell.selectedIndexLabel.text = "\(selectCount)"
                }
            }else{
                selectStatusArray[indexPath.row] = 0
                selectCount = selectCount - 1
                if selectCount == 0 {
                    UserConfigModel.shared.selectType = .IMAGE
                }
                dealSelectArrayForRemoveItem(asset: asset)
            }
            
//            self.collectionView.reloadData()
//            
//            return
//            
//            //获取选中的数量
//            let count = self.selectedCount()
//            if count > 0{
//                if UserConfigModel.shared.selectType == .VIDEO{
//                    collectionView.deselectItem(at: indexPath, animated: false)
//                    MCToast.mc_text("最多选择 \( UserConfigModel.shared.forumVideoNumMax) 个视频")
//                    return
//                }
//                if count == 1{
//                    if asset.mediaType == .video{
//                        UserConfigModel.shared.selectType = .VIDEO
//                    }else{
//                        UserConfigModel.shared.selectType = .IMAGE
//                    }
//                }
//                
//                if asset.mediaType == .video && count > 1{
//                    collectionView.deselectItem(at: indexPath, animated: false)
//                    MCToast.mc_text("不能同时选择照片和视频")
//                }else if count > maxSelected{
//                    collectionView.deselectItem(at: indexPath, animated: false)
//                    MCToast.mc_text("照片不能超过 \(UserConfigModel.shared.forumPictureNumMax) 张")
//                }else{
//                    //改变完成按钮数字，并播放动画
//                    completeButton.num = count
//                    if count > 0 && !self.completeButton.isEnabled{
//                        completeButton.isEnabled = true
//                    }
//                    cell.playAnimate()
//                }
//            }else{
//                if asset.mediaType == .video{
//                    UserConfigModel.shared.selectType = .VIDEO
//                }else{
//                    UserConfigModel.shared.selectType = .IMAGE
//                }
//            }
        }
    }
    
    //单元格取消选中响应
//    func collectionView(_ collectionView: UICollectionView,
//                        didDeselectItemAt indexPath: IndexPath) {
//        if let cell = collectionView.cellForItem(at: indexPath)
//            as? HGImageCollectionViewCell{
//             //获取选中的数量
//            let count = self.selectedCount()
//            completeButton.num = count
//             //改变完成按钮数字，并播放动画
//            if count == 0{
//                completeButton.isEnabled = false
//                UserConfigModel.shared.selectType = .IMAGE
//            }
//            cell.playAnimate()
//        }
//    }
}

extension HGImageCollectionViewController{
    func getVideoDuration(for asset: PHAsset, completion: @escaping (Double) -> Void) {
        // 请求视频时长
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, info) in
            if let asset = asset as? AVAsset {
                // 获取视频时长
                let duration = asset.duration.seconds
                completion(duration)
            } else {
                // 如果无法获取视频资产，则完成并返回nil
                completion(0)
            }
        }
    }
    //取消选中某张照片时，对所有选中的照片序号，重新计算
    func dealSelectArrayForRemoveItem(asset:PHAsset) {
        var deleteIndex = 0
        var reloadIndexPath:[IndexPath] = [IndexPath]()
        for i in 0..<self.selectItems.count{
            let model = self.selectItems[i]
            if model.assets == asset{
                deleteIndex = model.selectIndex
                reloadIndexPath.append(model.indexPath)
                self.selectItems.remove(at: i)
                break
            }
        }
        
        for i in 0..<self.selectItems.count{
            var model = self.selectItems[i]
            
            if model.selectIndex > deleteIndex{
                model.selectIndex = model.selectIndex - 1
                self.selectItems[i] = model
            }
            
            reloadIndexPath.append(model.indexPath)
        }
        
        if self.selectItems.count == 0{
            self.collectionView.reloadData()
        }else{
            if self.selectItems.count == maxSelected - 1{
                self.collectionView.reloadData()
            }else{
                self.collectionView.reloadItems(at: reloadIndexPath)
            }
        }
    }
}



