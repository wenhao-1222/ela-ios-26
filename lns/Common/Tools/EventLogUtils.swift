//
//  EventLogUtils.swift
//  lns
//
//  Created by Elavatine on 2025/5/23.
//

enum EVENT_TYPE {
    case PAGE_VIEW
    case CLICK_BUTTON
}
enum SCENARIO_TYPE {
    ///日报
    case report_daily
    ///周报
    case report_weekly
    ///启动页  冷启动
    case launch_App
    ///引导页
    case guide_view
    ///开屏页
    case launch_view
    ///教程下单
    case course_create_order
    ///教程详情页
    case course_detail
    ///商品列表页
    case mall_list
    ///商品详情页
    case mall_detail
    ///商品下单
    case mall_create_order
}

class EventLogModel: NSObject {
    var eventName:String = ""
    var scenario:String = ""
    var text:String = ""
    var result:String = "SUCCESS"
    
}

class EventLogUtils {
    func sendEventLogRequest(eventName:EVENT_TYPE,scenarioType:SCENARIO_TYPE,text:String?,result:Bool=true){
        let model = EventLogModel()
        model.scenario = getScenario(type: scenarioType)
        model.text = text ?? ""
        model.result = result ? "SUCCESS" : "FAILED"
        
        switch eventName{
        case .PAGE_VIEW:
            model.eventName = "PAGE_VIEW"
        case .CLICK_BUTTON:
            model.eventName = "CLICK_BUTTON"
        }
        var param = ["eventName":model.eventName,
                     "params":["scenario":model.scenario,
                               "text":model.text,
                               "result":model.result]] as [String : Any]
        if scenarioType == .launch_view{
            //统计开屏页的点击，如果有sessionid，则统计
            if UserInfoModel.shared.event_log_session_id.count > 0 {
                param = ["eventName":model.eventName,
                         "sessionId":UserInfoModel.shared.event_log_session_id,
                         "params":["scenario":model.scenario,
                                   "text":model.text,
                                   "result":model.result]] as [String : Any]
            }else{
                //如果没有sessionid
                param = ["eventName":model.eventName,
                         "params":["scenario":model.scenario,
                                   "text":model.text,
                                   "result":model.result]] as [String : Any]
//                return
            }
        }else if scenarioType == .course_create_order && UserInfoModel.shared.event_log_session_id.count > 0{
            param = ["eventName":model.eventName,
                     "sessionId":UserInfoModel.shared.event_log_session_id,
                     "params":["scenario":model.scenario,
                               "text":model.text,
                               "result":model.result]] as [String : Any]
//            UserInfoModel.shared.event_log_session_id = ""
        }
        
        DLLog(message: "sendEventLogRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_event_log, parameters: param as [String : AnyObject]) { responseObject in
            
        }
    }
    private func getScenario(type:SCENARIO_TYPE) -> String {
        switch type{
        case .report_daily:
            return "日报"
        case .report_weekly:
            return "周报"
        case .guide_view:
            return "引导页"
        case .launch_view:
            return "开屏页"
        case .course_create_order:
            return "教程下单"
        case .mall_list:
            return "商品列表页"
        case .mall_detail:
            return "商品详情页"
        case .launch_App:
            return "启动页"
        case .course_detail:
            return "教程详情页"
            
        case .mall_create_order:
            return "商品下单"
        }
    }
}
