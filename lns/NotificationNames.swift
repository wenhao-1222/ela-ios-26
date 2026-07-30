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
/// 主 TabBar 已完成 root 切换并进入稳定展示状态，适合触发系统权限弹窗。
public let  NOTIFI_NAME_MAIN_TABBAR_DID_STABILIZE = NSNotification.Name(rawValue: "main_tabbar_did_stabilize")
///刷新日志今日数据
public let  NOTIFI_NAME_REFRESH_TODAY_JOUNAL = NSNotification.Name(rawValue: "refresh_today_logs_data")
///AI Coach 更新营养目标后，从服务端同步日志页数据
public let  NOTIFI_NAME_REFRESH_LOGS_FROM_SERVER = NSNotification.Name(rawValue: "refresh_logs_data_from_server")
///微量元素默认目标更新后，刷新日报营养详情目标值
public let  NOTIFI_NAME_NUTRITION_DEFAULT_MINERAL_DID_CHANGE = NSNotification.Name(rawValue: "nutrition_default_mineral_did_change")
///进入最新 AI Coach 报告后，刷新日志页 AI Coach 入口未读状态
public let  NOTIFI_NAME_REFRESH_AI_COACH_REPORT_UNREAD_STATUS = NSNotification.Name(rawValue: "refresh_ai_coach_report_unread_status")
//支付成功后，刷新课程列表
public let  NOTIFI_NAME_REFRESH_COURSE_STATUS = NSNotification.Name(rawValue: "refresh_course_status")
// Ela Pro 订阅成功后，刷新食谱页
public let  NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS = NSNotification.Name(rawValue: "refresh_diet_plan_status")
// 首次创建食谱流程中开通 Ela Pro 后，食谱页优先展示未生成计划状态
public let  NOTIFI_NAME_DIET_PLAN_SHOW_NONE_PLAN_AFTER_PRO_SUCCESS = NSNotification.Name(rawValue: "diet_plan_show_none_plan_after_pro_success")
// Ela Pro 绑定/订阅成功后，刷新会员状态
public let  NOTIFI_NAME_REFRESH_VIP_STATUS = NSNotification.Name(rawValue: "refresh_vip_status")
// 进入 AI Coach 前刷新日志页会员状态
public let  NOTIFI_NAME_REFRESH_JOURNAL_VIP_STATUS = NSNotification.Name(rawValue: "refresh_journal_vip_status")
// 二次创建食谱成功后，返回食谱页时让旧列表先淡出
public let  NOTIFI_NAME_DIET_PLAN_CREATE_SUCCESS = NSNotification.Name(rawValue: "diet_plan_create_success")
// 生成购物清单成功后，刷新食谱页购物清单缓存
public let  NOTIFI_NAME_DIET_PLAN_BUY_LIST_CREATE_SUCCESS = NSNotification.Name(rawValue: "diet_plan_buy_list_create_success")
// 刷新“我的”tab 红点聚合状态
public let  NOTIFI_NAME_REFRESH_MINE_TAB_RED_DOT = NSNotification.Name(rawValue: "refresh_mine_tab_red_dot")
///添加地址成功
public let  NOTIFI_NAME_ADD_ADDRESS = NSNotification.Name(rawValue: "add_address")
