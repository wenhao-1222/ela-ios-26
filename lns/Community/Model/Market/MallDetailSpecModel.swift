//
//  MallDetailSpecModel.swift
//  lns
//   商品规格
//  Created by Elavatine on 2025/9/8.
//


class MallDetailSpecModel: NSObject {
    
    ///id
    var specId = ""
    ///规格名称
    var specName = ""
    ///规格明细列表
    var specValueList:[MallDetailSpecValueModel] = [MallDetailSpecValueModel]()
    ///是否为主规格
    var isMainSpec = false
    ///如果是主规格，是否需要弹窗切换
    var needPopUp = false
    ///如果是主规格，是否用图片链接展示
    var isUrl = false
    
    func dealSpecWithDict(dict:NSDictionary) -> MallDetailSpecModel {
        let model = MallDetailSpecModel()
        model.specId = dict.stringValueForKey(key: "specId")
        model.specName = dict.stringValueForKey(key: "specName")
        model.isMainSpec = dict.stringValueForKey(key: "isPrimary") == "1" ? true : false
        model.needPopUp = dict.stringValueForKey(key: "needPopup") == "1" ? true : false
        model.isUrl = dict.stringValueForKey(key: "isUrl") == "1" ? true : false
        
        let specValueList = dict["specValueList"]as? NSArray ?? []
        
        for i in 0..<specValueList.count{
            let specDict = specValueList[i]as? NSDictionary ?? [:]
            let specModel = MallDetailSpecValueModel().dealSpecWithDict(dict: specDict)
            
            model.specValueList.append(specModel)
        }
        
        return model
    }
    
}

class MallDetailSpecValueModel: NSObject {
    ///规格id
    var specValueId = ""
    ///规格名
    var specValue = ""
    ///规格图片链接  ，只有主规格的时候才有，显示在商品详情页
    var specValueUrl = ""
    ///是否有库存
    var specHasStock = true
    ///是否已选中
    var specSelectStatus = false
    
    func dealSpecWithDict(dict:NSDictionary) -> MallDetailSpecValueModel {
        let model = MallDetailSpecValueModel()
        model.specValueId = dict.stringValueForKey(key: "specValueId")
        model.specValue = dict.stringValueForKey(key: "specValue")
        model.specValueUrl = dict.stringValueForKey(key: "specValueUrl")
        model.specSelectStatus = dict.stringValueForKey(key: "selected") == "1" ? true : false
        model.specHasStock = dict.stringValueForKey(key: "disabled") == "1" ? false : true
        
        return model
    }
}
