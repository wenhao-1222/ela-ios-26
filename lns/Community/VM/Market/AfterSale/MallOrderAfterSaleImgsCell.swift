//
//  MallOrderAfterSaleImgsCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/26.
//


import Photos

class MallOrderAfterSaleImgsCell: UITableViewCell {
    
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
    var uploadProgresses:[CGFloat] = []
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
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "上传相关图片"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return lab
    }()
    lazy var collectionView: UICollectionView = {
        let layout = LXReorderableCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white//.WIDGET_COLOR_GRAY_BLACK_06
//        collectionView.keyboardDismissMode = .onDrag
        collectionView.bounces = false
//        collectionView.alwaysBounceVertical = false // 不允许上下弹跳
        collectionView.showsVerticalScrollIndicator = false
//        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MallOrderAfterSaleImgsCollectionCell.self, forCellWithReuseIdentifier: "MallOrderAfterSaleImgsCollectionCell")
        
        return collectionView
    }()
}

extension MallOrderAfterSaleImgsCell{
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
    func updateUploadProgresses(progresses:[CGFloat]) {
        self.uploadProgresses = progresses
        self.collectionView.reloadData()
    }
    func updateProgress(progress:CGFloat, index:Int) {
        if index >= self.imgDateArray.count { return }
        while index >= self.uploadProgresses.count {
            self.uploadProgresses.append(CGFloat(-1))
        }
        self.uploadProgresses[index] = progress
        if let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MallOrderAfterSaleImgsCollectionCell {
            cell.updateUploadProgress(progress: progress)
        }
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

extension MallOrderAfterSaleImgsCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(collectionView)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
//            make.top.equalTo(kFitWidth(11))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(7))
            make.height.equalTo(itemHeight)
            make.right.equalToSuperview()
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-16))
        }
    }
}

extension MallOrderAfterSaleImgsCell:UICollectionViewDelegate,UICollectionViewDataSource{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(imgDateArray.count + 1,3)//imgArray.count < 9 ?  (imgArray.count + 1) : 9
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MallOrderAfterSaleImgsCollectionCell", for: indexPath) as? MallOrderAfterSaleImgsCollectionCell
        
        if imgDateArray.count > 0{
            if indexPath.row == imgDateArray.count && imgDateArray.count < 3{
//                cell?.imgView.image = UIImage(named: "forum_add_image_icon")
//                cell?.clearImageIcon.isHidden = true
                cell?.updateNum(hiddenIconImg:false,num: imgDateArray.count)
                cell?.updateUploadProgress(progress: CGFloat(-1))
            }else{
                cell?.imgView.image = imgDateArray[indexPath.row]
//                cell?.clearImageIcon.isHidden = false
                cell?.updateNum(hiddenIconImg:true,num: imgDateArray.count)
                let progress = indexPath.row < uploadProgresses.count ? uploadProgresses[indexPath.row] : CGFloat(-1)
                cell?.updateUploadProgress(progress: progress)
            }
        }else{
//            cell?.imgView.image = UIImage(named: "forum_add_image_icon")
//            cell?.clearImageIcon.isHidden = true
            cell?.updateNum(hiddenIconImg:false,num: imgDateArray.count)
            cell?.updateUploadProgress(progress: CGFloat(-1))
        }
        
        cell?.clearImgBlock = {()in
            self.deleteImgBlock?(indexPath.row)
//            DispatchQueue.main.async(execute: {
//                self.imgDateArray.remove(at: indexPath.row)
//                self.collectionView.deleteItems(at: [indexPath])
//                self.deleteImgBlock?(indexPath.row)
//            })
        }
        
        return cell ?? MallOrderAfterSaleImgsCollectionCell()
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
}
//
//extension MallOrderAfterSaleImgsCell:LXReorderableCollectionViewDataSource,LXReorderableCollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, canMoveTo toIndexPath: IndexPath!) -> Bool {
//        if toIndexPath.row == imgDateArray.count{
//            return false
//        }else{
//            return true
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView!, canMoveItemAt indexPath: IndexPath!) -> Bool {
//        if indexPath.row == imgDateArray.count{
//            return false
//        }else{
//            return true
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, willMoveTo toIndexPath: IndexPath!) {
////        if toIndexPath.item < self.imgDateArray.count{
////            self.isDragItem = true
////            let asset = imgDateArray[fromIndexPath.item]
////
////            self.imgDateArray.remove(at: fromIndexPath.item)
////            self.imgDateArray.insert(asset, at: toIndexPath.item)
////            self.collectionView.reloadData()
////            if self.changeImgIndexBlock != nil{
////                self.changeImgIndexBlock!(self.imgDateArray,fromIndexPath.item,toIndexPath.item)
////            }
////        }
//    }
//    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, didMoveTo toIndexPath: IndexPath!) {
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
//    }
//}
