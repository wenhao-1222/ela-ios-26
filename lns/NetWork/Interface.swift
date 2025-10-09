//
//  Interface.swift
//  kxf
//
//  Created by 文 on 2023/5/22.
//  Copyright © 2023 kxf. All rights reserved.
//

import Foundation

let URL_Type       = WHGetInterface_javaWithType()

//MARK:
//登录  手机号
public let URL_Login_phone                = URL_Type + "users/phone/login"
public let URL_Login_wechat               = URL_Type + "users/wx/access_token"
public let URL_Login_appid                = URL_Type + "users/apple/is_user_registered"

public let URL_Login_out                  = URL_Type + "users/profile/logout"

public let URL_idc_list                   = URL_Type + "tools/idc/list"
public let URL_send_sms                   = URL_Type + "tools/sms"
public let URL_verify_sms                 = URL_Type + "users/phone/verify"
public let URL_bind_phone_wx              = URL_Type + "users/wx/bind_phone"
public let URL_bind_phone_apple           = URL_Type + "users/apple/bind_phone"
//换绑手机号
public let URL_bind_phone_new             = URL_Type + "users/phone/update"
//绑定微信
public let URL_wechat_bind                = URL_Type + "users/wx/connect"
public let URL_wechat_unbind                = URL_Type + "users/wx/disconnect"
//绑定apple id
public let URL_appleid_bind                = URL_Type + "users/apple/connect"
public let URL_appleid_unbind                = URL_Type + "users/apple/disconnect"
//获取OSS参数
public let URL_OSS_sts                   = URL_Type + "tools/oss/sts"
//判断手机号是否注册过
public let URL_judge_phone_regist         = URL_Type + "users/phone/isregistered"
//绑定邀请码
public let URL_bind_inviteCode           = URL_Type + "users/fission/invcode"
//模糊查询食物列表
public let URL_foods_list                 = URL_Type + "foods/query_foods_by_name"
//创建食物
public let URL_foods_save                 = URL_Type + "foods/save_personal_foods"
//查询我的食物
public let URL_foods_list_my              = URL_Type + "foods/query_personal_foods_by_name"
//获取食物规格列表
public let URL_foods_spec_enum                 = URL_Type + "tools/app/foodsunit"
//最近添加的食物
public let URL_foods_history_add                 = URL_Type + "foods/recently/save"
public let URL_foods_history_del                 = URL_Type + "foods/recently/delete"
public let URL_foods_history_list                 = URL_Type + "foods/recently/query"

//微信提现
public let URL_wx_withdraw                 = URL_Type + "users/wx/transfer"

public let URL_foods_query_id             = URL_Type + "foods/query_foods_by_id"
//删除个人创建的食物
public let URL_foods_delete               = URL_Type + "foods/delete_personal_foods"
//获取用户基础消耗热量
public let URL_question_basic_consumption   = URL_Type + "users/nutrition/basic_daily_consumption"
//用户问卷调查保存
public let URL_question_survey_save       = URL_Type + "users/survey/save"
//保存用户部分问卷
public let URL_question_survey_savepart       = URL_Type + "users/survey/savepart"
//部分问卷调查保存，获取营养目标
public let URL_question_survey_part_save       = URL_Type + "users/nutrition/goals"
//用户自定义目标
public let URL_question_custom_save       = URL_Type + "users/survey/custom"
//保存周目标
public let URL_goal_week_save       = URL_Type + "users/survey/custom_week"
//保存碳循环目标
public let URL_goal_circle_save       = URL_Type + "users/survey/custom_cc"
//获取饮食计划列表
public let URL_dietplan_list              = URL_Type + "plans/dietplan/list"
//获取激活的饮食计划
public let URL_dietplan_plan_active              = URL_Type + "plans/dietplan/get_active_one"
//获取饮食计划明细
public let URL_dietplan_detail              = URL_Type + "plans/dietplan/details"
//修改计划名称
public let URL_dietplan_rename              = URL_Type + "plans/dietplan/rename"
//修改计划
public let URL_dietplan_update              = URL_Type + "plans/dietplan/update"
//删除饮食计划
public let URL_dietplan_del              = URL_Type + "plans/dietplan/del"
//激活饮食计划
public let URL_dietplan_active              = URL_Type + "plans/dietplan/active"
//获取激活的计划详情
public let URL_dietplan_detail_active       = URL_Type + "plans/dietplan/get_active_one"
//制定饮食计划
public let URL_create_plan_custom           = URL_Type + "plans/dietplan/custom"
//导入计划
public let URL_plan_leadinto           = URL_Type + "plans/dietplan/copy"
//获取海报信息
public let URL_plan_poster          = URL_Type + "plans/dietplan/poster"

public let URL_plan_brief           = URL_Type + "plans/dietplan/brief"
//获取每日营养元素
public let URL_get_nutrition_data           = URL_Type + "users/nutrition/data"
//概览，获取当日营养日志  代替  users/nutrition/data  接口
public let URL_get_current_nutrition           = URL_Type + "plans/log/today_nutrition"
//获取用户默认营养目标
public let URL_get_default_nutrition           = URL_Type + "users/nutrition/default"
//获取用户碳循环目标
public let URL_get_default_nutrition_circle           = URL_Type + "users/nutrition/cc"
//保存身体测量数据
public let URL_bodystat_save               = URL_Type + "users/bodystat/save"
//查询身体测量数据
public let URL_bodystat_query               = URL_Type + "users/bodystat/query"
//查询最后14条数据
public let URL_bodystat_query_14            = URL_Type + "users/bodystat/query14"
//删除身体测量数据
public let URL_bodystat_delete              = URL_Type + "users/bodystat/del"
//获取用户资料
public let URL_User_Center                 = URL_Type + "users/profile/get"
//更新用户资料
public let URL_User_Material_Update        = URL_Type + "users/profile/set"

//获取用户配置
public let URL_config_msg                = URL_Type + "users/config/get"
//更新用户配置
public let URL_config_set        = URL_Type + "users/config/set"
///常量接口获取
public let URL_constant_get        = URL_Type + "tools/app/constant"
//分佣详情
public let URL_User_fission_detail         = URL_Type + "users/fission/data"
//获取日志信息
public let URL_User_logs_detail            = URL_Type + "plans/log/details"
//最近七天的日志信息  小组件用
public let URL_User_logs_last7Days         = URL_Type + "plans/log/last7days"
//获取用户的所有日志数据
public let URL_User_logs_all               = URL_Type + "plans/log/details3y"
//更新笔记
public let URL_User_logs_update_notes      = URL_Type + "plans/log/update_notes"
//更新饮水
public let URL_User_logs_update_water      = URL_Type + "plans/log/intake_water"
//更新日志食物
public let URL_User_logs_update_details      = URL_Type + "plans/log/update_details"
//更新日志用餐时间
public let URL_User_logs_update_meal_time      = URL_Type + "plans/log/update_meal_time"
///下餐饮食建议
public let URL_User_logs_next_meal_advice      = URL_Type + "plans/log/next_meal_advice"
///更新单天的饮食目标、碳循环标签
public let URL_User_logs_goal_update      = URL_Type + "plans/log/update_goal"

//提交建议
public let URL_Uer_sugestion                = URL_Type + "users/suggestion/save"
//注销账号
public let URL_Uer_Cancel                   = URL_Type + "users/account/delete"
//注销账号--前置检查
public let URL_Uer_Cancel_pre               = URL_Type + "users/account/delete_pre_check"
//联系客服欢迎语 和回复语
public let URL_User_Service_config          = URL_Type + "tools/app/chat/welcome"
//消息列表
public let URL_User_Service_Msg_List        = URL_Type + "users/suggestion/list"
//清除日志
public let URL_clear_logs                   = URL_Type + "plans/log/clear"

//MARK: 餐食
//添加餐食
public let URL_meals_add                    = URL_Type + "plans/meals/add"
//修改餐食
public let URL_meals_update                 = URL_Type + "plans/meals/update"
//删除餐食
public let URL_meals_delete                 = URL_Type + "plans/meals/delete"
//餐食列表
public let URL_meals_list                   = URL_Type + "plans/meals/list"

//食物被选择次数计数器
public let URL_increment_count              = URL_Type + "foods/selected_count_increment"
//MARK: 统计
public let URL_stat                         = URL_Type + "plans/log/query"
//最喜欢的食物  TOP5
public let URL_stat_favorite_foods          = URL_Type + "foods/favorite/top5"
//图片识别营养成分
public let URL_foods_ai_identify          = URL_Type + "foods/ai_identify_image"
//日报
public let URL_daily_nutrition_report     = URL_Type + "plans/log/daily_nutrition_report"
//周报
public let URL_weekly_nutrition_report     = URL_Type + "plans/log/weekly_nutrition_report"
//日报 好友榜
public let URL_report_daily_ranking              = URL_Type + "plans/log/daily_nutrition_report_ranking"
//周报  好友榜
public let URL_report_weekly_ranking             = URL_Type + "plans/log/weekly_nutrition_report_ranking"



//MARK: 运动记录
public let URL_sport_catogary_list          = URL_Type + "users/sport/list"
public let URL_sport_catogary_add           = URL_Type + "users/sport/add"
public let URL_sport_catogary_update        = URL_Type + "users/sport/update"
public let URL_sport_catogary_delete        = URL_Type + "users/sport/delete"

//用户记录运动
public let URL_sport_list          = URL_Type + "users/sport/log/list"
public let URL_sport_add          = URL_Type + "users/sport/log/add"
public let URL_sport_update       = URL_Type + "users/sport/log/update"
public let URL_sport_delete       = URL_Type + "users/sport/log/delete"
//删除最近添加
public let URL_sport_recently_delete       = URL_Type + "users/sport/recently/delete"
//MARK: 社区
//公告帖子列表
public let URL_community_forum_notice_list         = URL_Type + "forum/post/notice_list"
//帖子列表
public let URL_community_forum_list         = URL_Type + "forum/post/list"
//帖子详情
public let URL_community_forum_detail         = URL_Type + "forum/post/details"
//帖子点赞
public let URL_community_forum_thumb        = URL_Type + "forum/post/like"
//帖子曝光
public let URL_community_forum_impression   = URL_Type + "forum/post/impression"
//帖子分享--生成
public let URL_community_forum_share_create   = URL_Type + "forum/post/pre_share"
//帖子分享
public let URL_community_forum_share       = URL_Type + "forum/post/share"
//帖子评论
public let URL_community_comment_add       = URL_Type + "forum/post/comment/add"

public let URL_community_comment_delete   = URL_Type + "forum/post/comment/delete"
//帖子回复
public let URL_community_reply_add       = URL_Type + "forum/post/comment/reply/add"
public let URL_community_reply_delete     = URL_Type + "forum/post/comment/reply/delete"

//帖子评论列表
public let URL_community_comment_list      = URL_Type + "forum/post/comment/list"
//评论置顶
public let URL_community_comment_set_top   = URL_Type + "forum/post/comment/set_top"
//帖子评论列表   跳转用
public let URL_community_comment_list_push = URL_Type + "forum/post/comment/one"
//帖子回复列表
public let URL_community_reply_list      = URL_Type + "forum/post/comment/reply/list"
//发帖
public let URL_forum_add     = URL_Type + "forum/post/add"
//删帖子
public let URL_forum_delete     = URL_Type + "forum/post/delete"
//投票
public let URL_forum_poll_vote       = URL_Type + "forum/post/poll/do"
//举报帖子   类型
public let URL_forum_report_type     = URL_Type + "tools/app/forum_post/report_type"
//举报
public let URL_forum_report          = URL_Type + "forum/post/report"
//站内信数量
public let URL_forum_msg_count          = URL_Type + "forum/post/msg/count"
//站内信列表
public let URL_forum_msg_list          = URL_Type + "forum/post/msg/list"
//站内信删除
public let URL_forum_msg_delete        = URL_Type + "forum/post/msg/delete"
//论坛发帖权限
public let URL_forum_allowes_poster     = URL_Type + "tools/app/forum_post/is_allowed_poster"
//优惠券应用
public let URL_tutorial_coupon_apply       = URL_Type + "forum/order/coupon_apply"
//支付宝支付
public let URL_forum_alipay_order       = URL_Type + "forum/order/alipay_place_order"
///支付宝重新下单
public let URL_forum_alipay_order_re    = URL_Type + "forum/order/alipay_re_place_order"
//微信支付
public let URL_forum_wechat_order       = URL_Type + "forum/order/wechatpay_place_order"
///微信重新下单
public let URL_forum_wechat_order_re    = URL_Type + "forum/order/wechatpay_re_place_order"
//订单查询支付状态
public let URL_forum_pay_order_query       = URL_Type + "forum/order/query"
//订单列表查询
public let URL_forum_order_list          = URL_Type + "forum/order/list"
//订单详情
public let URL_forum_order_detail         = URL_Type + "forum/order/detail"
//申请售后
public let URL_forum_order_refund         = URL_Type + "forum/order/submit_after_sales_request"
//关闭订单
public let URL_forum_order_close          = URL_Type + "forum/order/close"
//绑定设备
public let URL_forum_order_bind_device          = URL_Type + "forum/order/tutorial/binding_device"
///换绑设备
public let URL_forum_order_rebind_device          = URL_Type + "forum/order/tutorial/rebinding_device"


//MARK: 社区--教程
//教程类目分类
public let URL_tutorial_menu_list     = URL_Type + "forum/tutorial/menu1/list"
//教程--详情列表
public let URL_tutorial_menu_briefing = URL_Type + "forum/tutorial/menu1/briefing"

public let URL_tutorial_menu_catogary_list     = URL_Type + "forum/tutorial/menu2/list"
//教程分享
public let URL_tutorial_share        = URL_Type + "forum/tutorial/share"
//教程--点击计数
public let URL_tutorial_click_count  = URL_Type + "forum/tutorial/click_count"

//MARK: 好友
///通过id  查询账号（uid后5位）   suffixUid   5位   正则匹配  ^[a-zA-Z0-9]{5}$
public let URL_friend_id_query       = URL_Type + "users/account/query_by_suffix_uid"
///添加好友请求    followeeUid   好友uid
public let URL_friend_add            = URL_Type + "users/account/send_friend_request"
///处理好友请求
///followerUid 申请人 uid
/// status  2 通过   3 拒绝
public let URL_friend_handle         = URL_Type + "users/account/handle_friend_request"
///好友请求列表
public let URL_friend_pengding_list  = URL_Type + "users/account/friend_request_pending_list"
///删除好友   followerUid
public let URL_friend_delete         = URL_Type + "users/account/unfriend_each_other"


//MARK: 商城
///商城列表
public let URL_mall_list               = URL_Type + "forum/mall/spu/list"
//默认SKU
public let URL_mall_sku_default         = URL_Type + "forum/mall/sku/default"
//切换SKU
public let URL_mall_sku_select         = URL_Type + "forum/mall/sku/select"

//MARK: 地址
///地址--列表
public let URL_user_address_list         = URL_Type + "users/address/list"
///地址--新增 or 更新
public let URL_user_address_addOrUpdate  = URL_Type + "users/address/addOrUpdate"
///地址--删除
public let URL_user_address_delete       = URL_Type + "users/address/delete"
///地址--设置默认
public let URL_user_address_setDefault   = URL_Type + "users/address/setDefault"
///地址---获取默认地址
public let URL_user_address_getDefault   = URL_Type + "users/address/getDefault"


//开屏页信息
public let URL_splash_ad                = URL_Type + "tools/app/splash_ad/list"
//上报异常信息
public let URL_error_msg                    = URL_Type + "tools/device/log"
//事件埋点
public let URL_event_log        = URL_Type + "tools/app/event/log"
//极光推送测试
public let URL_jpush_test                   = URL_Type + "tools/jpush/test"
//获取最新的APP版本信息
public let URL_app_version      = URL_Type + "tools/app/version"

public let URL_app_version_new      = URL_Type + "tools/app/ver_info"
//注册协议
public let URL_agreement                   = "https://static.leungnutritionsciences.cn/agreements/agreement.html"
//隐私协议
public let URL_privacy                   = "https://static.leungnutritionsciences.cn/agreements/privacy.html"
//注销协议
public let URL_cancelAccount                = "https://static.leungnutritionsciences.cn/agreements/acc_del_agreement.html"
//奖励规则
public let URL_reward_rule              = "https://static.leungnutritionsciences.cn/agreements/invitation_reward_rules.html"
//知识付费 课程购买协议
public let URL_turorial_purchase_agreement = "https://static.leungnutritionsciences.cn/agreements/ela_tutorial_purchase_agreement.html"
