//
//  BodyDataImageCollectionCell.swift
//  lns
//
//  Created by Elavatine on 2024/10/9.
//


import Foundation
import UIKit
//import ShowBigImg

class BodyDataImageCollectionCell: UICollectionViewCell {
    
    var queryDay = ""
    var changeIndexBlock:((Int)->())?
    var imgsArray:[String] = [String]()
    var imgsIndexArray:[Int] = [Int]()
    var showImgView = WHShowBigImgBackView(urlArr: [""], number: 0)
    
    override init(frame: CGRect) {
        //        selectMealsIndex = 0
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
//        initUI()
        contentView.addSubview(imgAbbreVm)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var label: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 20, weight: .bold)
        return lab
    }()
    lazy var imgAbbreVm: BodyDataImageAbbreVM = {
        let vm = BodyDataImageAbbreVM.init(frame: .zero)
        return vm
    }()
}

extension BodyDataImageCollectionCell{
    func initUI() {
        contentView.addSubview(imgAbbreVm)
//        contentView.addSubview(showImgView)
//        
//        contentView.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(200))
//        }
    }
    func setImgIndex(index:Int) {
//        DLLog(message: "----------------------")
//        DLLog(message: "-----\(index)")
//        DLLog(message: "-----\(self.imgsIndexArray)")
//        DLLog(message: "-----\(self.imgsArray)")
//        DLLog(message: "----------------------")
//        if self.imgsIndexArray.count > index{
            for i in 0..<self.imgsIndexArray.count{
                let imgsIndex = self.imgsIndexArray[i]
                if imgsIndex == index{
                    self.imgAbbreVm.updateSelectIndex(index: index)
                    self.showImgView.collectionView.scrollToItem(at: IndexPath.init(row: i, section: 0), at: .right, animated: false)
                }
            }
            
//        }
    }
    func updateUI(dict:NSDictionary) {
        let imgsArr = dict["imgs"]as? [String] ?? []
        imgsIndexArray.removeAll()
        imgsArray.removeAll()
        for i in 0..<imgsArr.count{
            let imgUrl = imgsArr[i]
            if imgUrl.count > 2{
                imgsArray.append(imgUrl)
                imgsIndexArray.append(i)
            }
        }
        
        showImgView = WHShowBigImgBackView.init(urlArr: imgsArray, number: 0)
        contentView.addSubview(showImgView)
        
        showImgView.scrollBlock = {(index)in
            self.imgAbbreVm.updateSelectIndex(index: self.imgsIndexArray[index])
            if self.changeIndexBlock != nil{
                self.changeIndexBlock!(self.imgsIndexArray[index])
            }
        }
        imgAbbreVm.aliasArray = dict["alias"]as? NSArray ?? []
        imgAbbreVm.updateUI(imgs: imgsArr as NSArray)
        imgAbbreVm.updateSelectIndex(index: imgsIndexArray[0])
        contentView.bringSubviewToFront(imgAbbreVm)
//        contentView.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(200))
//        }
//        
//        label.text = dict.stringValueForKey(key: "ctime")
//        showImgView.refreshUrls(urls: dict["imgs"]as? [String] ?? [])
    }
}
