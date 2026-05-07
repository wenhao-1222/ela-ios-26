//
//  NotificationNames.swift
//  lns
//
//  Created by Elavatine on 2025/3/26.
//

//APP进入后台挂起
public let  NOTIFI_NAME_ENTER_BACKGROUND = NSNotification.Name(rawValue: "applicationDidEnterBackground")
//APP进入前台 活跃
public let  NOTIFI_NAME_DID_BECOME_ACTIVE = NSNotification.Name(rawValue: "applicationDidBecomeActive")
//日报 周报点击添加食物，返回到日志页时，需要展示引导弹窗
public let  NOTIFI_NAME_REPORT_ADD_FOODS = NSNotification.Name(rawValue: "reprot_add_foods")
//获取到用户ABTEST身份
public let  NOTIFI_NAME_ABTEST = NSNotification.Name(rawValue: "ab_test_msg")

public let  NOTIFI_NAME_SHORTCUTITEMS = NSNotification.Name(rawValue: "shortcutItems")

public let  NOTIFI_NAME_GUIDE = NSNotification.Name(rawValue: "onboarding_flow_status")
///刷新日志今日数据
public let  NOTIFI_NAME_REFRESH_TODAY_JOUNAL = NSNotification.Name(rawValue: "refresh_today_logs_data")
//支付成功后，刷新课程列表
public let  NOTIFI_NAME_REFRESH_COURSE_STATUS = NSNotification.Name(rawValue: "refresh_course_status")
// Ela Pro 订阅成功后，刷新食谱页
public let  NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS = NSNotification.Name(rawValue: "refresh_diet_plan_status")
// Ela Pro 绑定/订阅成功后，刷新会员状态
public let  NOTIFI_NAME_REFRESH_VIP_STATUS = NSNotification.Name(rawValue: "refresh_vip_status")
// 二次创建食谱成功后，返回食谱页时让旧列表先淡出
public let  NOTIFI_NAME_DIET_PLAN_CREATE_SUCCESS = NSNotification.Name(rawValue: "diet_plan_create_success")
// 生成购物清单成功后，刷新食谱页购物清单缓存
public let  NOTIFI_NAME_DIET_PLAN_BUY_LIST_CREATE_SUCCESS = NSNotification.Name(rawValue: "diet_plan_buy_list_create_success")
///添加地址成功
public let  NOTIFI_NAME_ADD_ADDRESS = NSNotification.Name(rawValue: "add_address")
