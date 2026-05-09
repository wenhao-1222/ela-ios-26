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
    ///教程列表页面--点击立即购买  2025年11月25日14:19
    case course_list_buy_action
    ///教程下单  页面
    case course_create_order_page_view
    ///教程下单
    case course_create_order
    ///教程下单页面  购买协议
    case course_create_order_protocal
    ///教程详情页
    case course_detail
    ///教程详情页停留时间
    case course_detail_duration
    ///教程详情页  视频介绍
    case course_detail_video_desc
    ///教程列表
    case course_list
    ///商品列表页
    case mall_list
    ///商品详情页
    case mall_detail
    ///商品下单
    case mall_create_order
    ///轻断食提醒--展示
    case logs_meals_alert_show
    ///轻断食提醒--点击
    case logs_meals_alert_click
    ///概览页
    case main_view
    ///自律习惯养成
    case habit_view
    ///自律习惯养成--添加好友
    case habit_view_friends
    ///会员订阅付费墙
    ///text传付费墙场景值：1-新用户问卷入口；2-AI教练问卷入口；3-食谱计划问卷入口；4-AI食物识图入口
    case ela_pro_view
    ///AI教练问卷
    case ai_coach_guide
}

class EventLogModel: NSObject {
    var eventName:String = ""
    var scenario:String = ""
    var text:String = ""
    var result:String = "SUCCESS"
    
}

class EventLogUtils {
    func sendGuidanceV2PageView(pageIndex: String, pageTitle: String, bizType: String) {
        let text = "{\"pageIndex\":\"\(pageIndex)\",\"pageTitle\":\"\(pageTitle)\",\"bizType\":\"\(bizType)\"}"
        let param = ["eventName":"PAGE_VIEW",
                     "params":["scenario":"引导页v2",
                               "text":text,
                               "result":""]] as [String : Any]
        DLLog(message: "sendGuidanceV2PageView:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_event_log, parameters: param as [String : AnyObject]) { responseObject in

        }
    }

    func sendEventLogRequest(eventName:EVENT_TYPE,scenarioType:SCENARIO_TYPE,text:String?,result:Bool=true){
        if UserInfoModel.shared.uId.count > 1 && UserInfoModel.shared.token.count > 1{
            
        }else{
            return
        }
        let model = EventLogModel()
        model.scenario = getScenario(type: scenarioType)
        model.text = text ?? ""
        model.result = result ? "SUCCESS" : "FAILED"
        
        //显示了教程一级列表的时候，将开屏页点击的sessionId置空
        if scenarioType == .course_list{
            UserInfoModel.shared.event_log_session_id = ""
        }
        
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
        if scenarioType == .course_detail || scenarioType == .course_create_order || scenarioType == .course_detail_duration || scenarioType == .course_create_order_page_view{
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
        case .course_list_buy_action:
            return "教程详情页开始课程"
        case .course_create_order_page_view:
            return "教程确认订单页"
        case .course_create_order_protocal:
            return "教程购买协议"
        case .mall_list:
            return "商品列表页"
        case .mall_detail:
            return "商品详情页"
        case .launch_App:
            return "启动页"
        case .course_detail:
            return "教程详情页"
        case .course_detail_video_desc:
            return "教程详情页视频介绍"
        case .course_detail_duration:
            return "教程详情页停留时间"
        case .mall_create_order:
            return "商品下单"
        case .course_list:
            return "教程一级菜单列表"
        case .logs_meals_alert_show:
            return "记录饮食提醒"
        case .logs_meals_alert_click:
            return "记录饮食提醒"
        case .main_view:
            return "概览"
        case .habit_view:
            return "自律习惯养成"
        case .habit_view_friends:
            return "自律习惯养成-添加好友"
        case .ela_pro_view:
            return "会员订阅付费墙"
        case .ai_coach_guide:
            return "AI教练问卷"
        }
    }
}
