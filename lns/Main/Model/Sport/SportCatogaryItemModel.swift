//
//  SportCatogaryItemModel.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//

import HealthKit


class SportCatogaryItemModel: NSObject {
    
    var sn = ""
    
    var id = ""
    
    var ctime = ""
    
    var icon = ""
    
    var met = ""
    
    var menuId = ""
    
    var name = ""
    
    var minute = ""
    
    var calories = ""
    
    var durationLast = ""
    
    var caloriesLast = ""
    
    var workType = HKWorkoutActivityType.other
    
    
    func dealDictForModel(dict:NSDictionary) -> SportCatogaryItemModel {
        let model = SportCatogaryItemModel()
        model.sn = dict.stringValueForKey(key: "sn")
        model.id = dict.stringValueForKey(key: "id")
        model.ctime = dict.stringValueForKey(key: "ctime")
        model.menuId = dict.stringValueForKey(key: "menuId")
        model.name = dict.stringValueForKey(key: "name")
        model.met = dict.stringValueForKey(key: "met")
        
        model.minute = dict.stringValueForKey(key: "duration")
        model.calories = dict.stringValueForKey(key: "calories")
        
        model.durationLast = dict.stringValueForKey(key: "durationLast")
        model.caloriesLast = dict.stringValueForKey(key: "caloriesLast")
        
        model.workType = dealWorkType(appleType: dict.stringValueForKey(key: "appleType"))
        
        return model
    }
    
    func dealWorkType(appleType:String) -> HKWorkoutActivityType {
        if appleType == "pilates"{
            return .pilates
        }else if appleType == "yoga"{
            return .yoga
        }else if appleType == "walking"{
            return .walking
        }else if appleType == "running"{
            return .running
        }else if appleType == "cycling"{
            return .cycling
        }else if appleType == "elliptical"{
            return .elliptical
        }else if appleType == "rowing"{
            return .rowing
        }else if appleType == "stairs"{
            return .stairs
        }else if appleType == "tableTennis"{
            return .tableTennis
        }else if appleType == "tennis"{
            return .tennis
        }else if appleType == "badminton"{
            return .badminton
        }else if appleType == "soccer"{
            return .soccer
        }else if appleType == "basketball"{
            return .basketball
        }else if appleType == "volleyball"{
            return .volleyball
        }else if appleType == "traditionalStrengthTraining"{
            return .traditionalStrengthTraining
        }else if appleType == "highIntensityIntervalTraining"{
            return .highIntensityIntervalTraining
        }else if appleType == "jumpRope"{
            return .jumpRope
        }else if appleType == "taiChi"{
            return .taiChi
        }else if appleType == "cardioDance"{
            return .cardioDance
        }else if appleType == "martialArts"{
            return .martialArts
        }else if appleType == "snowboarding"{
            return .snowboarding
        }else if appleType == "downhillSkiing"{
            return .downhillSkiing
        }else if appleType == "skatingSports"{
            return .skatingSports
        }else if appleType == "climbing"{
            return .climbing
        }else if appleType == "hiking"{
            return .hiking
        }else if appleType == "surfingSports"{
            return .surfingSports
        }else if appleType == "paddleSports"{
            return .paddleSports
        }else if appleType == "waterSports"{
            return .waterSports
        }else if appleType == "boxing"{
            return .boxing
        }else if appleType == "fencing"{
            return .fencing
        }else if appleType == "discSports"{
            return .discSports
        }else if appleType == "rugby"{
            return .rugby
        }else if appleType == "pickleball"{
            return .pickleball
        }else if appleType == "squash"{
            return .squash
        }else if appleType == "golf"{
            return .golf
        }else if appleType == "baseball"{
            return .baseball
        }else if appleType == "softball"{
            return .softball
        }else if appleType == "hockey"{
            return .hockey
        }else if appleType == "swimming"{
            return .swimming
        }

        return .other
    }
    
    func dealTypeName(type:HKWorkoutActivityType) -> String {
        
        switch type{
        case .pilates:
            return "普拉提"
        case .yoga:
            return "瑜伽"
        case .walking:
            return "步行"
        case .running:
            return "跑步"
        case .cycling:
            return "骑单车"
        case .elliptical:
            return "椭圆机"
        case .rowing:
            return "划船"
        case .stairs:
            return "楼梯"
        case .tableTennis:
            return "乒乓球"
        case .tennis:
            return "网球"
        case .badminton:
            return "羽毛球"
        case .soccer:
            return "足球"
        case .basketball:
            return "篮球"
        case .volleyball:
            return "排球"
        case .traditionalStrengthTraining:
            return "传统力量训练"
        case .highIntensityIntervalTraining:
            return "高强度间歇训练"
        case .jumpRope:
            return "跳绳"
        case .taiChi:
            return "太极"
        case .cardioDance:
            return "跳舞"
        case .dance:
            return "跳舞"
        case .martialArts:
            return "武术"
        case .snowboarding:
            return "单板滑雪"
        case .downhillSkiing:
            return "高山滑雪"
        case .skatingSports:
            return "滑冰"
        case .climbing:
            return "攀岩"
        case .hiking:
            return "徒步"
        case .surfingSports:
            return "冲浪"
        case .paddleSports:
            return "皮划艇"
//        case .waterSports:
//            return "水上健身"
        case .boxing:
            return "拳击"
        case .fencing:
            return "剑术"
        case .discSports:
            return "飞盘运动"
        case .rugby:
            return "橄榄球"
        case .pickleball:
            return "匹克球"
        case .squash:
            return "壁球"
        case .golf:
            return "高尔夫"
        case .baseball:
            return "棒球"
        case .softball:
            return "垒球"
        case .hockey:
            return "曲棍球"
        case .swimming:
            return "游泳"
        case .crossTraining:
            return "交叉训练"
        case .bowling:
            return "保龄球"
        case .curling:
            return "冰壶"
        case .cricket:
            return "板球"
        case .barre:
            return "芭蕾"
        case .australianFootball:
            return "澳式足球"
        case .sailing:
            return "帆船运动"
        case .racquetball:
            return "短柄墙球"
        case .hunting:
            return "打猎"
        case .fishing:
            return "钓鱼"
        case .coreTraining:
            return "核心训练"
        case .functionalStrengthTraining:
            return "功能性力量训练"
        case .lacrosse:
            return "棍网球"
        case .fitnessGaming:
            return "健身游戏"
        case .archery:
            return "箭术"
        case .mixedCardio:
            return "混合有氧"
        case .wheelchairWalkPace:
            return "轮椅配速步行"
        case .wheelchairRunPace:
            return "轮椅配速跑"
        case .equestrianSports:
            return "马术运动"
        case .americanFootball:
            return "美式橄榄球"
        case .flexibility:
            return "柔韧度"
        case .socialDance:
            return "社交舞蹈"
        case .handball:
            return "手球"
        case .underwaterDiving:
            return "潜水"
        case .mindAndBody:
            return "柔缓冥想类运动"
        case .handCycling:
            return "手摇车"
        case .wrestling:
            return "摔跤"
        case .waterFitness:
            return "水上健身"
        case .waterSports:
            return "水上运动"
        case .stepTraining:
            return "踏板训练"
        case .waterPolo:
            return "水球"
        case .stairClimbing:
            return "踏步机"
        case .kickboxing:
            return "踢拳"
        case .gymnastics:
            return "体操"
        case .trackAndField:
            return "田径"
        case .crossCountrySkiing:
            return "越野滑雪"
        case .cooldown :
            return "整理放松"
        case .snowSports:
            return "雪上运动"
        case .play:
            return "休闲运动"
        default :
            return "其他"
        }
        /*
         体操
         */
    }
}
