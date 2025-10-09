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
