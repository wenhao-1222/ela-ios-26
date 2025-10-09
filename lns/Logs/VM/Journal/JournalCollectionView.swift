//
//  JournalCollectionView.swift
//  lns
//
//  Created by LNS2 on 2024/5/10.
//

import Foundation

class JournalCollectionView : UICollectionView{
    var canScroll = true
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if canScroll == false{
            self.isScrollEnabled = false
            return view
        }
        if view != nil {
            if containsSuperview(ofClass: JournalFoodsTableView.self, startingFrom: view!){
                self.isScrollEnabled = false
            }else{
                self.isScrollEnabled = true
            }
        }
        return view
    }
    // 判断视图的所有superview是否包含特定的类
    func containsSuperview(ofClass targetClass: AnyClass, startingFrom view: UIView) -> Bool {
        if view.isKind(of: targetClass){
            return true
        }
        
        if let superview = view.superview {
            if superview.isKind(of: targetClass) {
                return true
            } else {
                return containsSuperview(ofClass: targetClass, startingFrom: superview)
            }
        }
        return false
    }
    func setContentOffsetPage(index:Int,animated:Bool,direction:UICollectionView.ScrollPosition) {
        if isIpad(){
//            let layoutAttr = self.collectionViewLayout.layoutAttributesForItem(at: IndexPath.init(row: index, section: 0))
//            self.setContentOffset(layoutAttr?.frame.origin ?? CGPoint.init(x: 0, y: 0), animated: animated)
            let offsetX = CGFloat(index) * bounds.width
            setContentOffset(CGPoint(x: offsetX, y: contentOffset.y), animated: animated)
        }else{
            self.scrollToItem(at: IndexPath.init(row: index, section: 0), at: direction, animated: animated)
        }
    }
}
