//
//  HGImageCollectionViewCell.swift
//  hangge_1512
//
//  Created by hangge on 2017/1/7.
//  Copyright © 2017年 hangge.com. All rights reserved.
//

import UIKit

//图片缩略图集合页单元格
open class HGImageCollectionViewCell: UICollectionViewCell {
    //显示缩略图
    @IBOutlet weak var imageView:UIImageView!
    
    //显示选中状态的图标
    @IBOutlet weak var selectedIcon:UIImageView!
    
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.95)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.backgroundColor = .COLOR_GRAY_BLACK_25
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        
        return lab
    }()
    lazy var coverView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_85
        vi.isHidden = true
        vi.isUserInteractionEnabled = false
        
        return vi
    }()
    lazy var selectedIndexLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .THEME
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = .center
        lab.layer.cornerRadius = kFitWidth(9)
        lab.clipsToBounds = true
        lab.isHidden = true
        
        return lab
    }()
    
    func showCoverView(isShow:Bool) {
        if isShow{
            self.coverView.isHidden = false
            self.isUserInteractionEnabled = false
        }else{
            self.coverView.isHidden = true
            self.isUserInteractionEnabled = true
        }
    }
    func setSelectIndex(index:Int) {
        self.selectedIndexLabel.text = "\(index)"
    }
    
    //设置是否选中
//    open override var isSelected: Bool {
//        didSet{
//            if isSelected {
//                selectedIcon.image = UIImage(named: "hg_image_selected")
//            }else{
//                selectedIcon.image = UIImage(named: "hg_image_not_selected")
//            }
//        }
//    }
    
    //播放动画，是否选中的图标改变时使用
    func playAnimate() {
        //图标先缩小，再放大
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction,
                                animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2,
                               animations: {
                self.selectedIcon.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4,
                               animations: {
                self.selectedIcon.transform = CGAffineTransform.identity
            })
            }, completion: nil)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        selectedIcon.isHidden = true
        contentView.addSubview(timeLabel)
        contentView.addSubview(selectedIndexLabel)
        contentView.addSubview(coverView)
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-4))
            make.right.equalTo(kFitWidth(-6))
            make.width.equalTo(kFitWidth(48))
        }
        coverView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        selectedIndexLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(selectedIcon)
//            make.right.equalTo(kFitWidth(-10))
//            make.top.equalTo(kFitWidth(10))
            make.width.height.equalTo(kFitWidth(18))
        }
    }
}
