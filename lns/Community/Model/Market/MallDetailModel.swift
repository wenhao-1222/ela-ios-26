//
//  MallDetailModel.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//


class MallDetailModel: NSObject {
    
    var id = ""
    
    var sn = ""
    ///相当于商品名称
    var skuName = ""
    ///skuCode
    var skuCode = ""
    
    var spuId = ""
    ///banner图
    var image_arr_banner : [String] = [String]()
    ///详情图
    var image_arr_detail : [String] = [String]()
    ///订单的图片
    var image_order = ""
    
    var subtitle = ""
    ///原价
    var price_original = ""
    ///售价
    var price_sale = ""
    ///库存 真实
    var stock_real = ""
    ///库存
    var stock_dummy = ""
    ///上架状态  1 上架  0 下架
    var status = ""
    ///物流预计：预计发货时间
    var deliveryNotice = ""
    ///售后政策:七天无理由
    var warrantyPolicyNotice = ""
    ///单次最大购买数量
    var maxPurchaseQuantity = 1
    ///所有规格
    var specList:[MallDetailSpecModel] = [MallDetailSpecModel]()
    ///主规格
    var mainSpecModel = MallDetailSpecModel()
    ///主规格  已选中的
    var mainSpecValueModel = MallDetailSpecValueModel()
    ///主规格  已选中的  index
    var mainSpecValueIndex = 0
    ///已选中规格列表
    var selectedSpecList:[[String:String]] = []
    
    func dealModelWithDict(dict:NSDictionary) -> MallDetailModel {
        let model = MallDetailModel()
        model.id = dict.stringValueForKey(key: "id")
        model.skuName = dict.stringValueForKey(key: "name")
        model.spuId = dict.stringValueForKey(key: "spuId")
        model.skuCode = dict.stringValueForKey(key: "skuCode")
        model.image_arr_banner = dict["image"]as? [String] ?? [String]()//WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "image")) as? [String] ?? [String]()
        model.image_arr_detail = dict["detailImage"]as? [String] ?? [String]()//WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "detailImage")) as? [String] ?? [String]()
        model.subtitle = dict.stringValueForKey(key: "subtitle")
        model.price_original = dict.stringValueForKey(key: "originalPrice")
        model.price_sale = dict.stringValueForKey(key: "salePrice")
        model.stock_real = dict.stringValueForKey(key: "realStock")
        model.stock_dummy = dict.stringValueForKey(key: "dummyStock")
        model.sn = dict.stringValueForKey(key: "sn")
        model.status = dict.stringValueForKey(key: "status")
        model.deliveryNotice = dict.stringValueForKey(key: "deliveryNotice")
        model.warrantyPolicyNotice = dict.stringValueForKey(key: "warrantyPolicyNotice")
        model.maxPurchaseQuantity = Int(dict.doubleValueForKey(key: "maxPurchaseQuantity"))
        
        let orderList = dict["orderImage"]as? NSArray ?? []
        if orderList.count > 0{
            model.image_order = orderList[0]as? String ?? ""
        }
        
        let specList = dict["specList"]as? NSArray ?? []
        
        for i in 0..<specList.count{
            let dict = specList[i]as? NSDictionary ?? [:]
            let specModel = MallDetailSpecModel().dealSpecWithDict(dict: dict)
            model.specList.append(specModel)
            
            for specValueModel in specModel.specValueList {
                if specValueModel.specSelectStatus {
                    model.selectedSpecList.append(["specId": specModel.specId,
                                                  "specValueId": specValueModel.specValueId,
                                                   "specValueName": specValueModel.specValue])
                }
            }

            if specModel.isMainSpec == true{
                model.mainSpecModel = MallDetailSpecModel().dealSpecWithDict(dict: dict)
                
                for i in 0..<model.mainSpecModel.specValueList.count{
                    let specValueModel = model.mainSpecModel.specValueList[i]
                    if specValueModel.specSelectStatus{
                        model.mainSpecValueModel = specValueModel
                        model.mainSpecValueIndex = i
                        break
                    }
                }
            }
        }
        
        return model
    }
    
    func dealDataForOrderList(dict:NSDictionary) -> MallDetailModel {
        let model = MallDetailModel()
        
        model.id = dict.stringValueForKey(key: "id")
        let imgList = dict["image"]as? NSArray ?? []
        
        if imgList.count > 0 {
            model.image_order = imgList[0]as? String ?? ""
        }
        model.skuName = dict.stringValueForKey(key: "skuName")
        model.subtitle = dict.stringValueForKey(key: "subtitle")
        
        
        return model
    }
}

