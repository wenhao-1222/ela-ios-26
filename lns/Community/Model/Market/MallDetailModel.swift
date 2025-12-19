//
//  MallDetailModel.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//


enum BUY_BUTTON_STATUS {
    ///预售    ： 可以直接购买
    case sale_pre
    ///预售无库存   ：产品需求，预售也要受到库存的限制
    case sale_pre_no_stoke
    ///开售提醒
    case sale_remind
    ///开售提醒--已订阅
    case sale_remind_subscribe
    ///有库存，能直接购买
    case sale_normal
    ///无库存，不能直接购买
    case sale_no_stoke
    ///无库存，不能直接购买  并且已订阅到货通知
    case sale_no_stoke_subscribe
}



class MallDetailModel: NSObject {
    
    var id = ""
    ///⚠️前端用不上
    var sn = ""
    ///相当于商品名称
    var skuName = ""
    ///skuCode
    var skuCode = ""
    ///是否预售
    var isBooking = false
    ///预售的发货时间
    var saleStartTime = ""
    ///是否开售提醒
    var isSaleRemind = false
    ///是否有未通知的到货提醒
    var isRestockAlertSubscribed = false
    ///是否有未通知的开售提醒
    var isStartSaleAlertSubscribed = false
    ///购买按钮的状态
    var buyButtonStatus = BUY_BUTTON_STATUS.sale_normal
    ///运费的文案
    var shippingNotice = ""
    ///是否需要清关
    var isNeedLegalName = false
    ///购买按钮的显示文案
    var buyButtonText = "立即购买"
    
    var spuId = ""
    ///banner图
    var image_arr_banner : [String] = [String]()
    ///详情图
    var image_arr_detail : [String] = [String]()
    ///订单的图片  用在选规格的弹窗，和订单列表
    var image_order = ""
    ///创建订单页面用的图片
    var image_order_create = ""
    
    var subtitle = ""
    ///原价 ⚠️前端用不上
    var price_original = ""
    ///售价
    var price_sale = ""
    ///库存 真实 ⚠️前端用不上
    var stock_real = ""
    ///库存
    var stock_dummy = ""
    ///上架状态 ⚠️前端用不上  1 上架  0 下架  
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
        model.isBooking = dict.stringValueForKey(key: "isBooking") == "1" ? true : false
        model.saleStartTime = dict.stringValueForKey(key: "saleStartTime")
        model.isSaleRemind = dict.stringValueForKey(key: "isSaleRemind") == "1" ? true : false
        model.isRestockAlertSubscribed = dict.stringValueForKey(key: "isRestockAlertSubscribed") == "1" ? true : false
        model.isStartSaleAlertSubscribed = dict.stringValueForKey(key: "isStartSaleAlertSubscribed") == "1" ? true : false
        model.isNeedLegalName = dict.stringValueForKey(key: "isNeedLegalName") == "1" ? true : false
        model.shippingNotice = dict.stringValueForKey(key: "shippingNotice")
        
        let status = MallDetailModel().dealBuyButtonStatus(dict: dict)
        model.buyButtonStatus = status
        model.buyButtonText = MallDetailModel().getBuyButtonTest(status: status)
        
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
//        model.image_order = dict.stringValueForKey(key: "squareImage")
//        model.image_order_create = dict.stringValueForKey(key: "rectangleImage")
        let orderList = dict["squareImage"]as? NSArray ?? []
        if orderList.count > 0{
            model.image_order = orderList[0]as? String ?? ""
        }
        let orderListRect = dict["rectangleImage"]as? NSArray ?? []
        if orderListRect.count > 0{
            model.image_order_create = orderListRect[0]as? String ?? ""
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
        let imgList = dict["squareImage"]as? NSArray ?? []
        
        if imgList.count > 0 {
            model.image_order = imgList[0]as? String ?? ""
        }
        model.skuName = dict.stringValueForKey(key: "skuName")
        model.subtitle = dict.stringValueForKey(key: "subtitle")
        
        return model
    }
    ///处理购买按钮的状态
    func dealBuyButtonStatus(dict:NSDictionary) -> BUY_BUTTON_STATUS {
        //预售商品
        if dict.stringValueForKey(key: "isBooking") == "1"{
            //有库存
            if dict.doubleValueForKey(key: "dummyStock") > 0{
                return .sale_pre    //“预售购买 +  "deliveryNotice"”
            }else{
                return .sale_pre_no_stoke   // “库存不足”
            }
        }else if dict.stringValueForKey(key: "isSaleRemind") == "1"{//是否开售提醒
            if dict.stringValueForKey(key: "isStartSaleAlertSubscribed") == "1"{
                return .sale_remind_subscribe  //显示“已设置开售提醒”
            }else{
                return .sale_remind    //显示“开售提醒”
            }
        }else{//非预售、非开售提醒的商品
            //判断库存
            if dict.doubleValueForKey(key: "dummyStock") > 0{
                return .sale_normal   //有库存   “立即购买”
            }else{
                if dict.stringValueForKey(key: "isRestockAlertSubscribed") == "1"{
                    return .sale_no_stoke_subscribe  //无库存   “已设置到货通知”
                }else{
                    return .sale_no_stoke  //无库存   “到货通知”
                }
            }
        }
    }
    
    func getBuyButtonTest(status:BUY_BUTTON_STATUS) -> String {
        switch status {
        case .sale_pre:
            return "预售购买"
        case .sale_pre_no_stoke:
            return "库存不足"
        case .sale_remind:
            return "开售提醒"
        case .sale_remind_subscribe:
            return "已设置开售提醒"
        case .sale_normal:
            return "立即购买"
        case .sale_no_stoke:
            return "到货通知"
        case .sale_no_stoke_subscribe:
            return "已设置到货提醒"
        }
    }
}

