//
//  PublishImagesCellCollection.swift
//  lns
//
//  Created by Elavatine on 2024/12/13.
//

import Photos

class PublishImagesCellCollection: UITableViewCell {
    
    var addImgBlock:(()->())?
    var heightChangeBlock:(()->())?
    var deleteImgBlock:((Int)->())?
    var imgTapBlock:((Int)->())?
    var loadImgBlock:((UIImage,Int)->())?
    var changeImgIndexBlock:(([UIImage],Int,Int)->())?
    
    let itemHeight = SCREEN_WIDHT*0.7*0.333
//    var imgArray:[PHAsset] = [PHAsset]()
    var imgDateArray:[UIImage] = [UIImage]()
    var videoAsset : PHAsset?
    // 创建 PHCachingImageManager 实例
    let imageManager = PHCachingImageManager.default()
    /// 开始拖动时的数据暂存
    private var dragingIndexPath: IndexPath?
    var isDragItem = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var collectionView: UICollectionView = {
        let layout = LXReorderableCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
//        layout.da
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white//.WIDGET_COLOR_GRAY_BLACK_06
//        collectionView.keyboardDismissMode = .onDrag
        collectionView.bounces = false
//        collectionView.alwaysBounceVertical = false // 不允许上下弹跳
        collectionView.showsVerticalScrollIndicator = false
//        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PublishImageCollectionCell.self, forCellWithReuseIdentifier: "PublishImageCollectionCell")
        
        return collectionView
    }()
}

extension PublishImagesCellCollection{
    @objc func addAction() {
        if self.addImgBlock != nil{
            self.addImgBlock!()
        }
    }
    func updateImages(imgs:NSArray) {
        if imgs.count > 0 {
            self.imgDateArray = imgs as? [UIImage] ?? [UIImage]()
        }else{
            self.imgDateArray.removeAll()
        }
        self.collectionView.reloadData()
    }
    func updateUI(assts:[PHAsset]) {
//        self.imgArray = assts
//        self.updateUI()
    }
    func updateVideo(asset:PHAsset){
        self.videoAsset = asset
    }
    
    func updateUI() {
        self.collectionView.reloadData()
        
        if self.heightChangeBlock != nil{
            self.heightChangeBlock!()
        }
    }
}

extension PublishImagesCellCollection{
    func initUI() {
        contentView.addSubview(collectionView)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        collectionView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(itemHeight*3)
            make.height.equalTo(itemHeight)
            make.left.right.equalToSuperview()
        }
    }
}

extension PublishImagesCellCollection:UICollectionViewDelegate,UICollectionViewDataSource{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(imgDateArray.count + 1,9)//imgArray.count < 9 ?  (imgArray.count + 1) : 9
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PublishImageCollectionCell", for: indexPath) as? PublishImageCollectionCell
        
        let option = PHImageRequestOptions.init()
        option.resizeMode = .exact
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
        if imgDateArray.count > 0{
            if indexPath.row == imgDateArray.count && imgDateArray.count < 9{
                cell?.imgView.image = UIImage(named: "forum_add_image_icon")
                cell?.snLabel.isHidden = true
            }else{
                cell?.imgView.image = imgDateArray[indexPath.row]
                cell?.snLabel.isHidden = false
                cell?.snLabel.text = "\(indexPath.row + 1)"
            }
        }else{
            cell?.imgView.image = UIImage(named: "forum_add_image_icon")
            cell?.snLabel.isHidden = true
        }
        
        return cell ?? PublishImageCollectionCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == imgDateArray.count{
            if self.addImgBlock != nil{
                self.addImgBlock!()
            }
        }else{
            if self.imgTapBlock != nil{
                self.imgTapBlock!(indexPath.row)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

extension PublishImagesCellCollection:LXReorderableCollectionViewDataSource,LXReorderableCollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, canMoveTo toIndexPath: IndexPath!) -> Bool {
        if toIndexPath.row == imgDateArray.count{
            return false
        }else{
            return true
        }
    }
    func collectionView(_ collectionView: UICollectionView!, canMoveItemAt indexPath: IndexPath!) -> Bool {
        if indexPath.row == imgDateArray.count{
            return false
        }else{
            return true
        }
    }
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, willMoveTo toIndexPath: IndexPath!) {
//        if toIndexPath.item < self.imgDateArray.count{
//            self.isDragItem = true
//            let asset = imgDateArray[fromIndexPath.item]
//            
//            self.imgDateArray.remove(at: fromIndexPath.item)
//            self.imgDateArray.insert(asset, at: toIndexPath.item)
//            self.collectionView.reloadData()
//            if self.changeImgIndexBlock != nil{
//                self.changeImgIndexBlock!(self.imgDateArray,fromIndexPath.item,toIndexPath.item)
//            }
//        }
    }
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, didMoveTo toIndexPath: IndexPath!) {
        if toIndexPath.item < self.imgDateArray.count{
            self.isDragItem = true
            let asset = imgDateArray[fromIndexPath.item]
            
            self.imgDateArray.remove(at: fromIndexPath.item)
            self.imgDateArray.insert(asset, at: toIndexPath.item)
            self.collectionView.reloadData()
            if self.changeImgIndexBlock != nil{
                self.changeImgIndexBlock!(self.imgDateArray,fromIndexPath.item,toIndexPath.item)
            }
        }
    }
}
