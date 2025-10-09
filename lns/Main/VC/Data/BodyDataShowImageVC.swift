//
//  BodyDataShowImageVC.swift
//  lns
//
//  Created by Elavatine on 2024/10/9.
//


class BodyDataShowImageVC: WHBaseViewVC {
    
    var sdate = ""
    var dataSourceArray = NSArray()
    
    var imgIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    let collectView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let vi = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT), collectionViewLayout: layout)
        
        vi.collectionViewLayout = layout
        vi.isPagingEnabled = true
        vi.showsHorizontalScrollIndicator = false
        vi.showsVerticalScrollIndicator = false
        
        vi.contentInsetAdjustmentBehavior = .never
        
//        vi.register(BodyDataImageCollectionCell.classForCoder(), forCellWithReuseIdentifier: "BodyDataImageCollectionCell")
        
        return vi
    }()
}

extension BodyDataShowImageVC{
    func initUI() {
        initNavi(titleStr: "",naviBgColor: WHColorWithAlpha(colorStr: "000000", alpha: 0.45),isWhite: true)
        
        view.backgroundColor = .black
        
        view.addSubview(collectView)
        view.insertSubview(collectView, belowSubview: self.navigationView)
        
        collectView.delegate = self
        collectView.dataSource = self
        for i in 0..<dataSourceArray.count{
            self.collectView.register(BodyDataImageCollectionCell.classForCoder(), forCellWithReuseIdentifier: "BodyDataImageCollectionCell\(i)")
        }
        calculateCurrentIndex()
        setDate(date: sdate)
        
    }
    func setDate(date:String){
        self.naviTitleLabel.text = date
    }
    func calculateCurrentIndex()  {
        for i in 0..<self.dataSourceArray.count{
            let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "ctime") == self.sdate{
//                self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
                collectView.scrollToItem(at: IndexPath.init(row: i, section: 0), at: .bottom, animated: false)
                break
            }
        }
        collectView.reloadData()
    }
    func reloadIndex() {
        for i in 0..<dataSourceArray.count{
            let indexPath = IndexPath(row: i, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? BodyDataImageCollectionCell
            cell?.setImgIndex(index: self.imgIndex)
        }
    }
}

extension BodyDataShowImageVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BodyDataImageCollectionCell\(indexPath.row)", for: indexPath)as? BodyDataImageCollectionCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        
        cell?.updateUI(dict: dict)
        cell?.setImgIndex(index: self.imgIndex)
        cell?.changeIndexBlock = {(index)in
            if self.imgIndex != index{
                self.imgIndex = index
                self.reloadIndex()
            }
        }
        
        return cell ?? BodyDataImageCollectionCell()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let currentPage = Int((collectView.contentOffset.y + SCREEN_HEIGHT*0.5)/SCREEN_HEIGHT)
//        let dict = self.dataSourceArray[currentPage]as? NSDictionary ?? [:]
//        self.sdate = dict.stringValueForKey(key: "ctime")
//        self.setDate(date: self.sdate)
        calculatePageIndex()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let currentPage = Int((collectView.contentOffset.y + SCREEN_HEIGHT*0.5)/SCREEN_HEIGHT)
//        let dict = self.dataSourceArray[currentPage]as? NSDictionary ?? [:]
//        self.sdate = dict.stringValueForKey(key: "ctime")
//        self.setDate(date: self.sdate)
        calculatePageIndex()
    }
    func calculatePageIndex() {
        let currentPage = Int((collectView.contentOffset.y + SCREEN_HEIGHT*0.5)/SCREEN_HEIGHT)
        let dict = self.dataSourceArray[currentPage]as? NSDictionary ?? [:]
        self.sdate = dict.stringValueForKey(key: "ctime")
        self.setDate(date: self.sdate)
    }
}
