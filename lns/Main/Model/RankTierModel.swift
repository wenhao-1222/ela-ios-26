//
//  RankTierModel.swift
//  lns
//
//  Created by LNS2 on 2026/1/21.
//


class RankTierModel: NSObject {
    
    /// 段位 1 ~ 9
    var tier : Int = 1
    /// 为当前段位时的图片
    var tierImg : String = ""
    /// 锁的图片
    var tierLockedImg : String = "rank_locked_img"
    var tierLockedIcon : String = "rank_locked_icon"
    /// 是否为锁定状态
    var isLocked : Bool = true
    /// 段位名称
    var tierName : String = ""
    /// 是否为当前段位
    var isCurrentTier : Bool = false
    /// 图片的透明度
    var tierAlpha : CGFloat = 1.0
    
    func initModel(tier:Int,tierName:String,currentTier:Int) -> RankTierModel {
        let model = RankTierModel()
        model.tier = tier
        model.tierName = tierName
        model.isCurrentTier = tier == currentTier
        model.isLocked = false
        
        if tier < currentTier{
            model.tierImg = "rank_\(tier)_reached"
        }else if tier == currentTier{
            model.tierImg = "rank_\(tier)"
        }else{
            model.isLocked = true
            model.tierImg = "rank_unlock"
            
            if tier - currentTier == 1{
                model.tierAlpha = 0.5
            }else if tier - currentTier == 2{
                model.tierAlpha = 0.3
            }else{
                model.tierAlpha = 0.2
            }
        }
        
        return model
    }
    
}
