//
//  MarketListModel.swift
//  lns
//
//  Created by Elavatine on 2025/9/5.
//

class MarketListModel: NSObject {
    
    
    var id = ""
    
    var name = ""
    
    var descript = ""
    
    var imgUrlSmall = ""
    
    var imgUrlLarge = ""
    
    var imgUrlForListShow = ""
    
    var detailImgArray = NSArray()
    
    var price = ""
    
    var status = 1
    
    var isTop = false
    
    func dealDictForModel(dict:NSDictionary) -> MarketListModel {
        let model = MarketListModel()
        
        model.name = dict.stringValueForKey(key: "name")
        model.id = dict.stringValueForKey(key: "id")
        model.descript = dict.stringValueForKey(key: "description")
        model.price = dict.stringValueForKey(key: "price")
        
        model.isTop = dict.stringValueForKey(key: "top") == "1" ? true : false
        model.imgUrlLarge = dict.stringValueForKey(key: "largeImageUrl")
        model.imgUrlSmall = dict.stringValueForKey(key: "smallImageUrl")
        
        if model.isTop{
            model.imgUrlForListShow = model.imgUrlLarge
        }else{
            model.imgUrlForListShow = model.imgUrlSmall
        }
        
        return model
    }
}
