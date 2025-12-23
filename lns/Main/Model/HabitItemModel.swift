//
//  HabitItemModel.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//

enum HABIT_TYPE {
    ///今日饮食是否完整记录
    case log_food
    ///今日力量训练是否记录
    case log_fitness
    ///今日身体数据是否记录
    case log_bodydata
    ///今日蛋白质是否达标
    case protein_target
    ///初次与好友达成目标
    case protein_target_friend_first
    ///与好友一起达成目标
    case protein_target_friend
}


class HabitItemModel: NSObject {
    
    
    var iconImg : String = ""
    var title   : String = ""
    var point   : String = ""
    var isComplete : Bool = false
    var type    : HABIT_TYPE = HABIT_TYPE.log_food
    var vm       = HabitItemVM()
    
    func createModel(vm:HabitItemVM,isComplete:Bool,type:HABIT_TYPE,point:String="1") -> HabitItemModel {
        let model = HabitItemModel()
        model.vm = vm
        model.isComplete = isComplete
        model.point = point
        model.type = type
        
        return model
    }
}
