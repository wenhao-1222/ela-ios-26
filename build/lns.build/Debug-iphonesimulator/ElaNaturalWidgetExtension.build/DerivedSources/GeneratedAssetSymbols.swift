import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

    /// The "WidgetBackground" asset catalog color resource.
    static let widgetBackground = ColorResource(name: "WidgetBackground", bundle: resourceBundle)

    /// The "black_color_01" asset catalog color resource.
    static let blackColor01 = ColorResource(name: "black_color_01", bundle: resourceBundle)

    /// The "color_alert_bg_black" asset catalog color resource.
    static let colorAlertBgBlack = ColorResource(name: "color_alert_bg_black", bundle: resourceBundle)

    /// The "color_bg_black" asset catalog color resource.
    static let colorBgBlack = ColorResource(name: "color_bg_black", bundle: resourceBundle)

    /// The "color_bg_c4" asset catalog color resource.
    static let colorBgC4 = ColorResource(name: "color_bg_c4", bundle: resourceBundle)

    /// The "color_bg_e8" asset catalog color resource.
    static let colorBgE8 = ColorResource(name: "color_bg_e8", bundle: resourceBundle)

    /// The "color_bg_ef" asset catalog color resource.
    static let colorBgEf = ColorResource(name: "color_bg_ef", bundle: resourceBundle)

    /// The "color_bg_f2" asset catalog color resource.
    static let colorBgF2 = ColorResource(name: "color_bg_f2", bundle: resourceBundle)

    /// The "color_bg_f5" asset catalog color resource.
    static let colorBgF5 = ColorResource(name: "color_bg_f5", bundle: resourceBundle)

    /// The "color_bg_f5_course_list_end" asset catalog color resource.
    static let colorBgF5CourseListEnd = ColorResource(name: "color_bg_f5_course_list_end", bundle: resourceBundle)

    /// The "color_bg_f5_course_list_start" asset catalog color resource.
    static let colorBgF5CourseListStart = ColorResource(name: "color_bg_f5_course_list_start", bundle: resourceBundle)

    /// The "color_bg_f5_fitness_bg" asset catalog color resource.
    static let colorBgF5FitnessBg = ColorResource(name: "color_bg_f5_fitness_bg", bundle: resourceBundle)

    /// The "color_bg_f5_segment" asset catalog color resource.
    static let colorBgF5Segment = ColorResource(name: "color_bg_f5_segment", bundle: resourceBundle)

    /// The "color_bg_fa" asset catalog color resource.
    static let colorBgFa = ColorResource(name: "color_bg_fa", bundle: resourceBundle)

    /// The "color_bg_theme" asset catalog color resource.
    static let colorBgTheme = ColorResource(name: "color_bg_theme", bundle: resourceBundle)

    /// The "color_bg_theme_share" asset catalog color resource.
    static let colorBgThemeShare = ColorResource(name: "color_bg_theme_share", bundle: resourceBundle)

    /// The "color_bg_white" asset catalog color resource.
    static let colorBgWhite = ColorResource(name: "color_bg_white", bundle: resourceBundle)

    /// The "color_bg_white_95" asset catalog color resource.
    static let colorBgWhite95 = ColorResource(name: "color_bg_white_95", bundle: resourceBundle)

    /// The "color_bg_white_lequid_seg" asset catalog color resource.
    static let colorBgWhiteLequidSeg = ColorResource(name: "color_bg_white_lequid_seg", bundle: resourceBundle)

    /// The "color_black_04" asset catalog color resource.
    static let colorBlack04 = ColorResource(name: "color_black_04", bundle: resourceBundle)

    /// The "color_black_045" asset catalog color resource.
    static let colorBlack045 = ColorResource(name: "color_black_045", bundle: resourceBundle)

    /// The "color_black_04_goal_bg" asset catalog color resource.
    static let colorBlack04GoalBg = ColorResource(name: "color_black_04_goal_bg", bundle: resourceBundle)

    /// The "color_black_06" asset catalog color resource.
    static let colorBlack06 = ColorResource(name: "color_black_06", bundle: resourceBundle)

    /// The "color_black_15" asset catalog color resource.
    static let colorBlack15 = ColorResource(name: "color_black_15", bundle: resourceBundle)

    /// The "color_black_30" asset catalog color resource.
    static let colorBlack30 = ColorResource(name: "color_black_30", bundle: resourceBundle)

    /// The "color_black_40" asset catalog color resource.
    static let colorBlack40 = ColorResource(name: "color_black_40", bundle: resourceBundle)

    /// The "color_black_65" asset catalog color resource.
    static let colorBlack65 = ColorResource(name: "color_black_65", bundle: resourceBundle)

    /// The "color_button_disable_bg" asset catalog color resource.
    static let colorButtonDisableBg = ColorResource(name: "color_button_disable_bg", bundle: resourceBundle)

    /// The "color_card_bg_alert" asset catalog color resource.
    static let colorCardBgAlert = ColorResource(name: "color_card_bg_alert", bundle: resourceBundle)

    /// The "color_card_bg_clear" asset catalog color resource.
    static let colorCardBgClear = ColorResource(name: "color_card_bg_clear", bundle: resourceBundle)

    /// The "color_card_bg_f5_comment_func" asset catalog color resource.
    static let colorCardBgF5CommentFunc = ColorResource(name: "color_card_bg_f5_comment_func", bundle: resourceBundle)

    /// The "color_card_bg_f5_guide" asset catalog color resource.
    static let colorCardBgF5Guide = ColorResource(name: "color_card_bg_f5_guide", bundle: resourceBundle)

    /// The "color_card_bg_ff" asset catalog color resource.
    static let colorCardBgFf = ColorResource(name: "color_card_bg_ff", bundle: resourceBundle)

    /// The "color_card_bg_sport_category" asset catalog color resource.
    static let colorCardBgSportCategory = ColorResource(name: "color_card_bg_sport_category", bundle: resourceBundle)

    /// The "color_cell_current_bg" asset catalog color resource.
    static let colorCellCurrentBg = ColorResource(name: "color_cell_current_bg", bundle: resourceBundle)

    /// The "color_habit_item_img_bg" asset catalog color resource.
    static let colorHabitItemImgBg = ColorResource(name: "color_habit_item_img_bg", bundle: resourceBundle)

    /// The "color_line_f0" asset catalog color resource.
    static let colorLineF0 = ColorResource(name: "color_line_f0", bundle: resourceBundle)

    /// The "color_line_f0_30" asset catalog color resource.
    static let colorLineF030 = ColorResource(name: "color_line_f0_30", bundle: resourceBundle)

    /// The "color_natural_calories" asset catalog color resource.
    static let colorNaturalCalories = ColorResource(name: "color_natural_calories", bundle: resourceBundle)

    /// The "color_natural_carbo" asset catalog color resource.
    static let colorNaturalCarbo = ColorResource(name: "color_natural_carbo", bundle: resourceBundle)

    /// The "color_natural_fat" asset catalog color resource.
    static let colorNaturalFat = ColorResource(name: "color_natural_fat", bundle: resourceBundle)

    /// The "color_natural_protein" asset catalog color resource.
    static let colorNaturalProtein = ColorResource(name: "color_natural_protein", bundle: resourceBundle)

    /// The "color_natural_theme_white" asset catalog color resource.
    static let colorNaturalThemeWhite = ColorResource(name: "color_natural_theme_white", bundle: resourceBundle)

    /// The "color_sex_femal" asset catalog color resource.
    static let colorSexFemal = ColorResource(name: "color_sex_femal", bundle: resourceBundle)

    /// The "color_share_msg_bg" asset catalog color resource.
    static let colorShareMsgBg = ColorResource(name: "color_share_msg_bg", bundle: resourceBundle)

    /// The "color_text_0f1214" asset catalog color resource.
    static let colorText0F1214 = ColorResource(name: "color_text_0f1214", bundle: resourceBundle)

    /// The "color_text_0f1214_03" asset catalog color resource.
    static let colorText0F121403 = ColorResource(name: "color_text_0f1214_03", bundle: resourceBundle)

    /// The "color_text_0f1214_05" asset catalog color resource.
    static let colorText0F121405 = ColorResource(name: "color_text_0f1214_05", bundle: resourceBundle)

    /// The "color_text_0f1214_06" asset catalog color resource.
    static let colorText0F121406 = ColorResource(name: "color_text_0f1214_06", bundle: resourceBundle)

    /// The "color_text_0f1214_10" asset catalog color resource.
    static let colorText0F121410 = ColorResource(name: "color_text_0f1214_10", bundle: resourceBundle)

    /// The "color_text_0f1214_20" asset catalog color resource.
    static let colorText0F121420 = ColorResource(name: "color_text_0f1214_20", bundle: resourceBundle)

    /// The "color_text_0f1214_25" asset catalog color resource.
    static let colorText0F121425 = ColorResource(name: "color_text_0f1214_25", bundle: resourceBundle)

    /// The "color_text_0f1214_30" asset catalog color resource.
    static let colorText0F121430 = ColorResource(name: "color_text_0f1214_30", bundle: resourceBundle)

    /// The "color_text_0f1214_35" asset catalog color resource.
    static let colorText0F121435 = ColorResource(name: "color_text_0f1214_35", bundle: resourceBundle)

    /// The "color_text_0f1214_50" asset catalog color resource.
    static let colorText0F121450 = ColorResource(name: "color_text_0f1214_50", bundle: resourceBundle)

    /// The "color_text_0f1214_60" asset catalog color resource.
    static let colorText0F121460 = ColorResource(name: "color_text_0f1214_60", bundle: resourceBundle)

    /// The "color_text_0f1214_tabbar" asset catalog color resource.
    static let colorText0F1214Tabbar = ColorResource(name: "color_text_0f1214_tabbar", bundle: resourceBundle)

    /// The "color_text_main_calories" asset catalog color resource.
    static let colorTextMainCalories = ColorResource(name: "color_text_main_calories", bundle: resourceBundle)

    /// The "color_text_main_line" asset catalog color resource.
    static let colorTextMainLine = ColorResource(name: "color_text_main_line", bundle: resourceBundle)

    /// The "color_text_main_natural" asset catalog color resource.
    static let colorTextMainNatural = ColorResource(name: "color_text_main_natural", bundle: resourceBundle)

    /// The "color_text_main_natural_over" asset catalog color resource.
    static let colorTextMainNaturalOver = ColorResource(name: "color_text_main_natural_over", bundle: resourceBundle)

    /// The "color_text_white" asset catalog color resource.
    static let colorTextWhite = ColorResource(name: "color_text_white", bundle: resourceBundle)

    /// The "color_text_white_d234_50" asset catalog color resource.
    static let colorTextWhiteD23450 = ColorResource(name: "color_text_white_d234_50", bundle: resourceBundle)

    /// The "color_white_04" asset catalog color resource.
    static let colorWhite04 = ColorResource(name: "color_white_04", bundle: resourceBundle)

    /// The "color_white_20_pro" asset catalog color resource.
    static let colorWhite20Pro = ColorResource(name: "color_white_20_pro", bundle: resourceBundle)

    /// The "color_white_20_pro_border" asset catalog color resource.
    static let colorWhite20ProBorder = ColorResource(name: "color_white_20_pro_border", bundle: resourceBundle)

    /// The "color_white_20_pro_select" asset catalog color resource.
    static let colorWhite20ProSelect = ColorResource(name: "color_white_20_pro_select", bundle: resourceBundle)

    /// The "color_white_45" asset catalog color resource.
    static let colorWhite45 = ColorResource(name: "color_white_45", bundle: resourceBundle)

    /// The "color_white_65" asset catalog color resource.
    static let colorWhite65 = ColorResource(name: "color_white_65", bundle: resourceBundle)

    /// The "color_white_75" asset catalog color resource.
    static let colorWhite75 = ColorResource(name: "color_white_75", bundle: resourceBundle)

    /// The "text_color_06" asset catalog color resource.
    static let textColor06 = ColorResource(name: "text_color_06", bundle: resourceBundle)

    /// The "text_color_45" asset catalog color resource.
    static let textColor45 = ColorResource(name: "text_color_45", bundle: resourceBundle)

    /// The "text_color_65" asset catalog color resource.
    static let textColor65 = ColorResource(name: "text_color_65", bundle: resourceBundle)

    /// The "text_color_85" asset catalog color resource.
    static let textColor85 = ColorResource(name: "text_color_85", bundle: resourceBundle)

    /// The "white_color_85" asset catalog color resource.
    static let whiteColor85 = ColorResource(name: "white_color_85", bundle: resourceBundle)

    /// The "widget_bg_color" asset catalog color resource.
    static let widgetBg = ColorResource(name: "widget_bg_color", bundle: resourceBundle)

    /// The "widget_text_color" asset catalog color resource.
    static let widgetText = ColorResource(name: "widget_text_color", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "Image" asset catalog image resource.
    static let image = ImageResource(name: "Image", bundle: resourceBundle)

    /// The "ai_alert_close_icon" asset catalog image resource.
    static let aiAlertCloseIcon = ImageResource(name: "ai_alert_close_icon", bundle: resourceBundle)

    /// The "ai_back_icon" asset catalog image resource.
    static let aiBackIcon = ImageResource(name: "ai_back_icon", bundle: resourceBundle)

    /// The "ai_camera_album_icon" asset catalog image resource.
    static let aiCameraAlbumIcon = ImageResource(name: "ai_camera_album_icon", bundle: resourceBundle)

    /// The "ai_camera_box_foods" asset catalog image resource.
    static let aiCameraBoxFoods = ImageResource(name: "ai_camera_box_foods", bundle: resourceBundle)

    /// The "ai_camera_box_ingredient" asset catalog image resource.
    static let aiCameraBoxIngredient = ImageResource(name: "ai_camera_box_ingredient", bundle: resourceBundle)

    /// The "ai_camera_box_ingredient_tran" asset catalog image resource.
    static let aiCameraBoxIngredientTran = ImageResource(name: "ai_camera_box_ingredient_tran", bundle: resourceBundle)

    /// The "ai_camera_flash_icon" asset catalog image resource.
    static let aiCameraFlashIcon = ImageResource(name: "ai_camera_flash_icon", bundle: resourceBundle)

    /// The "ai_camera_flash_normal_icon" asset catalog image resource.
    static let aiCameraFlashNormalIcon = ImageResource(name: "ai_camera_flash_normal_icon", bundle: resourceBundle)

    /// The "ai_identify_fail_img" asset catalog image resource.
    static let aiIdentifyFailImg = ImageResource(name: "ai_identify_fail_img", bundle: resourceBundle)

    /// The "ai_photo_take_icon" asset catalog image resource.
    static let aiPhotoTakeIcon = ImageResource(name: "ai_photo_take_icon", bundle: resourceBundle)

    /// The "ai_progress_cancel_icon" asset catalog image resource.
    static let aiProgressCancelIcon = ImageResource(name: "ai_progress_cancel_icon", bundle: resourceBundle)

    /// The "ai_progress_complete_icon" asset catalog image resource.
    static let aiProgressCompleteIcon = ImageResource(name: "ai_progress_complete_icon", bundle: resourceBundle)

    /// The "ai_tips_alert_error_icon" asset catalog image resource.
    static let aiTipsAlertErrorIcon = ImageResource(name: "ai_tips_alert_error_icon", bundle: resourceBundle)

    /// The "ai_tips_alert_error_img" asset catalog image resource.
    static let aiTipsAlertErrorImg = ImageResource(name: "ai_tips_alert_error_img", bundle: resourceBundle)

    /// The "ai_tips_alert_right_icon" asset catalog image resource.
    static let aiTipsAlertRightIcon = ImageResource(name: "ai_tips_alert_right_icon", bundle: resourceBundle)

    /// The "ai_tips_alert_right_img" asset catalog image resource.
    static let aiTipsAlertRightImg = ImageResource(name: "ai_tips_alert_right_img", bundle: resourceBundle)

    /// The "ai_tips_icon" asset catalog image resource.
    static let aiTipsIcon = ImageResource(name: "ai_tips_icon", bundle: resourceBundle)

    /// The "ai_type_foods_icon" asset catalog image resource.
    static let aiTypeFoodsIcon = ImageResource(name: "ai_type_foods_icon", bundle: resourceBundle)

    /// The "ai_type_foods_normal_icon" asset catalog image resource.
    static let aiTypeFoodsNormalIcon = ImageResource(name: "ai_type_foods_normal_icon", bundle: resourceBundle)

    /// The "ai_type_ingredient_icon" asset catalog image resource.
    static let aiTypeIngredientIcon = ImageResource(name: "ai_type_ingredient_icon", bundle: resourceBundle)

    /// The "ai_type_ingredient_normal_icon" asset catalog image resource.
    static let aiTypeIngredientNormalIcon = ImageResource(name: "ai_type_ingredient_normal_icon", bundle: resourceBundle)

    /// The "alert_close_icon" asset catalog image resource.
    static let alertCloseIcon = ImageResource(name: "alert_close_icon", bundle: resourceBundle)

    /// The "alert_warning_icon" asset catalog image resource.
    static let alertWarningIcon = ImageResource(name: "alert_warning_icon", bundle: resourceBundle)

    /// The "arrow_img_down" asset catalog image resource.
    static let arrowImgDown = ImageResource(name: "arrow_img_down", bundle: resourceBundle)

    /// The "avatar_default" asset catalog image resource.
    static let avatarDefault = ImageResource(name: "avatar_default", bundle: resourceBundle)

    /// The "avatar_default_new" asset catalog image resource.
    static let avatarDefaultNew = ImageResource(name: "avatar_default_new", bundle: resourceBundle)

    /// The "back_arrow" asset catalog image resource.
    static let backArrow = ImageResource(name: "back_arrow", bundle: resourceBundle)

    /// The "back_arrow_highlight" asset catalog image resource.
    static let backArrowHighlight = ImageResource(name: "back_arrow_highlight", bundle: resourceBundle)

    /// The "back_arrow_white_icon" asset catalog image resource.
    static let backArrowWhiteIcon = ImageResource(name: "back_arrow_white_icon", bundle: resourceBundle)

    /// The "back_arrow_white_icon_light" asset catalog image resource.
    static let backArrowWhiteIconLight = ImageResource(name: "back_arrow_white_icon_light", bundle: resourceBundle)

    /// The "back_arrow_white_icon_max" asset catalog image resource.
    static let backArrowWhiteIconMax = ImageResource(name: "back_arrow_white_icon_max", bundle: resourceBundle)

    /// The "back_arrow_white_shadow" asset catalog image resource.
    static let backArrowWhiteShadow = ImageResource(name: "back_arrow_white_shadow", bundle: resourceBundle)

    /// The "back_close_icon" asset catalog image resource.
    static let backCloseIcon = ImageResource(name: "back_close_icon", bundle: resourceBundle)

    /// The "body_fat_feman_1" asset catalog image resource.
    static let bodyFatFeman1 = ImageResource(name: "body_fat_feman_1", bundle: resourceBundle)

    /// The "body_fat_feman_2" asset catalog image resource.
    static let bodyFatFeman2 = ImageResource(name: "body_fat_feman_2", bundle: resourceBundle)

    /// The "body_fat_feman_3" asset catalog image resource.
    static let bodyFatFeman3 = ImageResource(name: "body_fat_feman_3", bundle: resourceBundle)

    /// The "body_fat_feman_4" asset catalog image resource.
    static let bodyFatFeman4 = ImageResource(name: "body_fat_feman_4", bundle: resourceBundle)

    /// The "body_fat_feman_5" asset catalog image resource.
    static let bodyFatFeman5 = ImageResource(name: "body_fat_feman_5", bundle: resourceBundle)

    /// The "body_fat_feman_6" asset catalog image resource.
    static let bodyFatFeman6 = ImageResource(name: "body_fat_feman_6", bundle: resourceBundle)

    /// The "body_fat_feman_7" asset catalog image resource.
    static let bodyFatFeman7 = ImageResource(name: "body_fat_feman_7", bundle: resourceBundle)

    /// The "body_fat_feman_8" asset catalog image resource.
    static let bodyFatFeman8 = ImageResource(name: "body_fat_feman_8", bundle: resourceBundle)

    /// The "body_fat_feman_9" asset catalog image resource.
    static let bodyFatFeman9 = ImageResource(name: "body_fat_feman_9", bundle: resourceBundle)

    /// The "body_fat_img_cover" asset catalog image resource.
    static let bodyFatImgCover = ImageResource(name: "body_fat_img_cover", bundle: resourceBundle)

    /// The "body_fat_man_1" asset catalog image resource.
    static let bodyFatMan1 = ImageResource(name: "body_fat_man_1", bundle: resourceBundle)

    /// The "body_fat_man_2" asset catalog image resource.
    static let bodyFatMan2 = ImageResource(name: "body_fat_man_2", bundle: resourceBundle)

    /// The "body_fat_man_3" asset catalog image resource.
    static let bodyFatMan3 = ImageResource(name: "body_fat_man_3", bundle: resourceBundle)

    /// The "body_fat_man_4" asset catalog image resource.
    static let bodyFatMan4 = ImageResource(name: "body_fat_man_4", bundle: resourceBundle)

    /// The "body_fat_man_5" asset catalog image resource.
    static let bodyFatMan5 = ImageResource(name: "body_fat_man_5", bundle: resourceBundle)

    /// The "body_fat_man_6" asset catalog image resource.
    static let bodyFatMan6 = ImageResource(name: "body_fat_man_6", bundle: resourceBundle)

    /// The "body_fat_man_7" asset catalog image resource.
    static let bodyFatMan7 = ImageResource(name: "body_fat_man_7", bundle: resourceBundle)

    /// The "body_fat_man_8" asset catalog image resource.
    static let bodyFatMan8 = ImageResource(name: "body_fat_man_8", bundle: resourceBundle)

    /// The "body_fat_man_9" asset catalog image resource.
    static let bodyFatMan9 = ImageResource(name: "body_fat_man_9", bundle: resourceBundle)

    /// The "body_fat_select_icon" asset catalog image resource.
    static let bodyFatSelectIcon = ImageResource(name: "body_fat_select_icon", bundle: resourceBundle)

    /// The "bottom_cover_img" asset catalog image resource.
    static let bottomCoverImg = ImageResource(name: "bottom_cover_img", bundle: resourceBundle)

    /// The "button_bg_white" asset catalog image resource.
    static let buttonBgWhite = ImageResource(name: "button_bg_white", bundle: resourceBundle)

    /// The "calories_widget_icon" asset catalog image resource.
    static let caloriesWidgetIcon = ImageResource(name: "calories_widget_icon", bundle: resourceBundle)

    /// The "cancel_account_normal" asset catalog image resource.
    static let cancelAccountNormal = ImageResource(name: "cancel_account_normal", bundle: resourceBundle)

    /// The "cancel_account_selected" asset catalog image resource.
    static let cancelAccountSelected = ImageResource(name: "cancel_account_selected", bundle: resourceBundle)

    /// The "cancel_account_tips" asset catalog image resource.
    static let cancelAccountTips = ImageResource(name: "cancel_account_tips", bundle: resourceBundle)

    /// The "circle_change_icon" asset catalog image resource.
    static let circleChangeIcon = ImageResource(name: "circle_change_icon", bundle: resourceBundle)

    /// The "circle_days_icon" asset catalog image resource.
    static let circleDaysIcon = ImageResource(name: "circle_days_icon", bundle: resourceBundle)

    /// The "circle_today_normal_icon" asset catalog image resource.
    static let circleTodayNormalIcon = ImageResource(name: "circle_today_normal_icon", bundle: resourceBundle)

    /// The "circle_today_select_icon" asset catalog image resource.
    static let circleTodaySelectIcon = ImageResource(name: "circle_today_select_icon", bundle: resourceBundle)

    /// The "comment_func_copy_icon" asset catalog image resource.
    static let commentFuncCopyIcon = ImageResource(name: "comment_func_copy_icon", bundle: resourceBundle)

    /// The "comment_func_delete_icon" asset catalog image resource.
    static let commentFuncDeleteIcon = ImageResource(name: "comment_func_delete_icon", bundle: resourceBundle)

    /// The "comment_func_report_icon" asset catalog image resource.
    static let commentFuncReportIcon = ImageResource(name: "comment_func_report_icon", bundle: resourceBundle)

    /// The "control_widget_icon" asset catalog image resource.
    static let controlWidgetIcon = ImageResource(name: "control_widget_icon", bundle: resourceBundle)

    /// The "course_avtivity_bg" asset catalog image resource.
    static let courseAvtivityBg = ImageResource(name: "course_avtivity_bg", bundle: resourceBundle)

    /// The "course_avtivity_bg_left" asset catalog image resource.
    static let courseAvtivityBgLeft = ImageResource(name: "course_avtivity_bg_left", bundle: resourceBundle)

    /// The "course_avtivity_bg_right" asset catalog image resource.
    static let courseAvtivityBgRight = ImageResource(name: "course_avtivity_bg_right", bundle: resourceBundle)

    /// The "course_coupon_delete_icon" asset catalog image resource.
    static let courseCouponDeleteIcon = ImageResource(name: "course_coupon_delete_icon", bundle: resourceBundle)

    /// The "course_last_close_icon" asset catalog image resource.
    static let courseLastCloseIcon = ImageResource(name: "course_last_close_icon", bundle: resourceBundle)

    /// The "course_last_play_icon" asset catalog image resource.
    static let courseLastPlayIcon = ImageResource(name: "course_last_play_icon", bundle: resourceBundle)

    /// The "course_left_arrow_icon" asset catalog image resource.
    static let courseLeftArrowIcon = ImageResource(name: "course_left_arrow_icon", bundle: resourceBundle)

    /// The "course_locked_icon" asset catalog image resource.
    static let courseLockedIcon = ImageResource(name: "course_locked_icon", bundle: resourceBundle)

    /// The "course_number_icon" asset catalog image resource.
    static let courseNumberIcon = ImageResource(name: "course_number_icon", bundle: resourceBundle)

    /// The "course_order_delete_icon" asset catalog image resource.
    static let courseOrderDeleteIcon = ImageResource(name: "course_order_delete_icon", bundle: resourceBundle)

    /// The "course_pay_icon" asset catalog image resource.
    static let coursePayIcon = ImageResource(name: "course_pay_icon", bundle: resourceBundle)

    /// The "course_pay_tips_close_icon" asset catalog image resource.
    static let coursePayTipsCloseIcon = ImageResource(name: "course_pay_tips_close_icon", bundle: resourceBundle)

    /// The "course_pay_tips_ela_icon" asset catalog image resource.
    static let coursePayTipsElaIcon = ImageResource(name: "course_pay_tips_ela_icon", bundle: resourceBundle)

    /// The "course_pay_type_alipay" asset catalog image resource.
    static let coursePayTypeAlipay = ImageResource(name: "course_pay_type_alipay", bundle: resourceBundle)

    /// The "course_pay_type_normal" asset catalog image resource.
    static let coursePayTypeNormal = ImageResource(name: "course_pay_type_normal", bundle: resourceBundle)

    /// The "course_pay_type_select" asset catalog image resource.
    static let coursePayTypeSelect = ImageResource(name: "course_pay_type_select", bundle: resourceBundle)

    /// The "course_pay_type_wechat" asset catalog image resource.
    static let coursePayTypeWechat = ImageResource(name: "course_pay_type_wechat", bundle: resourceBundle)

    /// The "course_pdf_download_icon" asset catalog image resource.
    static let coursePdfDownloadIcon = ImageResource(name: "course_pdf_download_icon", bundle: resourceBundle)

    /// The "course_play_icon" asset catalog image resource.
    static let coursePlayIcon = ImageResource(name: "course_play_icon", bundle: resourceBundle)

    /// The "course_right_arrow_icon" asset catalog image resource.
    static let courseRightArrowIcon = ImageResource(name: "course_right_arrow_icon", bundle: resourceBundle)

    /// The "course_share_icon" asset catalog image resource.
    static let courseShareIcon = ImageResource(name: "course_share_icon", bundle: resourceBundle)

    /// The "course_title_avatar_icon" asset catalog image resource.
    static let courseTitleAvatarIcon = ImageResource(name: "course_title_avatar_icon", bundle: resourceBundle)

    /// The "course_video_play_icon" asset catalog image resource.
    static let courseVideoPlayIcon = ImageResource(name: "course_video_play_icon", bundle: resourceBundle)

    /// The "course_video_playing_icon" asset catalog image resource.
    static let courseVideoPlayingIcon = ImageResource(name: "course_video_playing_icon", bundle: resourceBundle)

    /// The "create_plan_add_foods_icon" asset catalog image resource.
    static let createPlanAddFoodsIcon = ImageResource(name: "create_plan_add_foods_icon", bundle: resourceBundle)

    /// The "create_plan_arrow_down" asset catalog image resource.
    static let createPlanArrowDown = ImageResource(name: "create_plan_arrow_down", bundle: resourceBundle)

    /// The "create_plan_name_icon" asset catalog image resource.
    static let createPlanNameIcon = ImageResource(name: "create_plan_name_icon", bundle: resourceBundle)

    /// The "create_plan_syn_select" asset catalog image resource.
    static let createPlanSynSelect = ImageResource(name: "create_plan_syn_select", bundle: resourceBundle)

    /// The "create_plan_weeks_icon" asset catalog image resource.
    static let createPlanWeeksIcon = ImageResource(name: "create_plan_weeks_icon", bundle: resourceBundle)

    /// The "data_add_icon" asset catalog image resource.
    static let dataAddIcon = ImageResource(name: "data_add_icon", bundle: resourceBundle)

    /// The "data_add_icon_black" asset catalog image resource.
    static let dataAddIconBlack = ImageResource(name: "data_add_icon_black", bundle: resourceBundle)

    /// The "data_asc_icon" asset catalog image resource.
    static let dataAscIcon = ImageResource(name: "data_asc_icon", bundle: resourceBundle)

    /// The "data_custom_icon" asset catalog image resource.
    static let dataCustomIcon = ImageResource(name: "data_custom_icon", bundle: resourceBundle)

    /// The "data_desc_icon" asset catalog image resource.
    static let dataDescIcon = ImageResource(name: "data_desc_icon", bundle: resourceBundle)

    /// The "data_img_clear_icon" asset catalog image resource.
    static let dataImgClearIcon = ImageResource(name: "data_img_clear_icon", bundle: resourceBundle)

    /// The "data_photo_default" asset catalog image resource.
    static let dataPhotoDefault = ImageResource(name: "data_photo_default", bundle: resourceBundle)

    /// The "data_ping_icon" asset catalog image resource.
    static let dataPingIcon = ImageResource(name: "data_ping_icon", bundle: resourceBundle)

    /// The "data_share_asc_icon" asset catalog image resource.
    static let dataShareAscIcon = ImageResource(name: "data_share_asc_icon", bundle: resourceBundle)

    /// The "data_share_bg" asset catalog image resource.
    static let dataShareBg = ImageResource(name: "data_share_bg", bundle: resourceBundle)

    /// The "data_share_desc_icon" asset catalog image resource.
    static let dataShareDescIcon = ImageResource(name: "data_share_desc_icon", bundle: resourceBundle)

    /// The "data_share_highlight_circle" asset catalog image resource.
    static let dataShareHighlightCircle = ImageResource(name: "data_share_highlight_circle", bundle: resourceBundle)

    /// The "data_share_ping_icon" asset catalog image resource.
    static let dataSharePingIcon = ImageResource(name: "data_share_ping_icon", bundle: resourceBundle)

    /// The "date_fliter_cancel_img" asset catalog image resource.
    static let dateFliterCancelImg = ImageResource(name: "date_fliter_cancel_img", bundle: resourceBundle)

    /// The "date_fliter_confirm_img" asset catalog image resource.
    static let dateFliterConfirmImg = ImageResource(name: "date_fliter_confirm_img", bundle: resourceBundle)

    /// The "dietplan_bg_img" asset catalog image resource.
    static let dietplanBgImg = ImageResource(name: "dietplan_bg_img", bundle: resourceBundle)

    /// The "dietplan_empty_img" asset catalog image resource.
    static let dietplanEmptyImg = ImageResource(name: "dietplan_empty_img", bundle: resourceBundle)

    /// The "dietplan_pro_icon" asset catalog image resource.
    static let dietplanProIcon = ImageResource(name: "dietplan_pro_icon", bundle: resourceBundle)

    /// The "donation_baby_img" asset catalog image resource.
    static let donationBabyImg = ImageResource(name: "donation_baby_img", bundle: resourceBundle)

    /// The "donation_bg_img" asset catalog image resource.
    static let donationBgImg = ImageResource(name: "donation_bg_img", bundle: resourceBundle)

    /// The "donation_cell_bottom" asset catalog image resource.
    static let donationCellBottom = ImageResource(name: "donation_cell_bottom", bundle: resourceBundle)

    /// The "donation_date_bg" asset catalog image resource.
    static let donationDateBg = ImageResource(name: "donation_date_bg", bundle: resourceBundle)

    /// The "donation_date_circle_icon" asset catalog image resource.
    static let donationDateCircleIcon = ImageResource(name: "donation_date_circle_icon", bundle: resourceBundle)

    /// The "donation_empty_icon_1" asset catalog image resource.
    static let donationEmptyIcon1 = ImageResource(name: "donation_empty_icon_1", bundle: resourceBundle)

    /// The "donation_empty_icon_2" asset catalog image resource.
    static let donationEmptyIcon2 = ImageResource(name: "donation_empty_icon_2", bundle: resourceBundle)

    /// The "donation_juanzeng_text" asset catalog image resource.
    static let donationJuanzengText = ImageResource(name: "donation_juanzeng_text", bundle: resourceBundle)

    /// The "donation_text_img" asset catalog image resource.
    static let donationTextImg = ImageResource(name: "donation_text_img", bundle: resourceBundle)

    /// The "donation_top_logo" asset catalog image resource.
    static let donationTopLogo = ImageResource(name: "donation_top_logo", bundle: resourceBundle)

    /// The "ela_clear_icon" asset catalog image resource.
    static let elaClearIcon = ImageResource(name: "ela_clear_icon", bundle: resourceBundle)

    /// The "ela_icon_img" asset catalog image resource.
    static let elaIconImg = ImageResource(name: "ela_icon_img", bundle: resourceBundle)

    /// The "ela_price_per_bg" asset catalog image resource.
    static let elaPricePerBg = ImageResource(name: "ela_price_per_bg", bundle: resourceBundle)

    /// The "ela_pro_2_bg" asset catalog image resource.
    static let elaPro2Bg = ImageResource(name: "ela_pro_2_bg", bundle: resourceBundle)

    /// The "ela_pro_4_bg" asset catalog image resource.
    static let elaPro4Bg = ImageResource(name: "ela_pro_4_bg", bundle: resourceBundle)

    /// The "ela_pro_bg" asset catalog image resource.
    static let elaProBg = ImageResource(name: "ela_pro_bg", bundle: resourceBundle)

    /// The "ela_pro_icon" asset catalog image resource.
    static let elaProIcon = ImageResource(name: "ela_pro_icon", bundle: resourceBundle)

    /// The "ela_pro_icon_2_1" asset catalog image resource.
    static let elaProIcon21 = ImageResource(name: "ela_pro_icon_2_1", bundle: resourceBundle)

    /// The "ela_pro_icon_2_2" asset catalog image resource.
    static let elaProIcon22 = ImageResource(name: "ela_pro_icon_2_2", bundle: resourceBundle)

    /// The "ela_pro_icon_2_3" asset catalog image resource.
    static let elaProIcon23 = ImageResource(name: "ela_pro_icon_2_3", bundle: resourceBundle)

    /// The "ela_pro_icon_2_4" asset catalog image resource.
    static let elaProIcon24 = ImageResource(name: "ela_pro_icon_2_4", bundle: resourceBundle)

    /// The "ela_pro_progress_bg" asset catalog image resource.
    static let elaProProgressBg = ImageResource(name: "ela_pro_progress_bg", bundle: resourceBundle)

    /// The "ela_tag_label_left_icon" asset catalog image resource.
    static let elaTagLabelLeftIcon = ImageResource(name: "ela_tag_label_left_icon", bundle: resourceBundle)

    /// The "ela_tag_label_right_icon" asset catalog image resource.
    static let elaTagLabelRightIcon = ImageResource(name: "ela_tag_label_right_icon", bundle: resourceBundle)

    /// The "fitness_tips_icon" asset catalog image resource.
    static let fitnessTipsIcon = ImageResource(name: "fitness_tips_icon", bundle: resourceBundle)

    /// The "foods_add_quickly_icon" asset catalog image resource.
    static let foodsAddQuicklyIcon = ImageResource(name: "foods_add_quickly_icon", bundle: resourceBundle)

    /// The "foods_ai_icon" asset catalog image resource.
    static let foodsAiIcon = ImageResource(name: "foods_ai_icon", bundle: resourceBundle)

    /// The "foods_calori_type_carbo" asset catalog image resource.
    static let foodsCaloriTypeCarbo = ImageResource(name: "foods_calori_type_carbo", bundle: resourceBundle)

    /// The "foods_calori_type_fats" asset catalog image resource.
    static let foodsCaloriTypeFats = ImageResource(name: "foods_calori_type_fats", bundle: resourceBundle)

    /// The "foods_calori_type_protein" asset catalog image resource.
    static let foodsCaloriTypeProtein = ImageResource(name: "foods_calori_type_protein", bundle: resourceBundle)

    /// The "foods_create_icon_normal" asset catalog image resource.
    static let foodsCreateIconNormal = ImageResource(name: "foods_create_icon_normal", bundle: resourceBundle)

    /// The "foods_create_icon_soon" asset catalog image resource.
    static let foodsCreateIconSoon = ImageResource(name: "foods_create_icon_soon", bundle: resourceBundle)

    /// The "foods_merge_add_icon" asset catalog image resource.
    static let foodsMergeAddIcon = ImageResource(name: "foods_merge_add_icon", bundle: resourceBundle)

    /// The "foods_merge_add_icon_white" asset catalog image resource.
    static let foodsMergeAddIconWhite = ImageResource(name: "foods_merge_add_icon_white", bundle: resourceBundle)

    /// The "foods_merge_arrow_icon" asset catalog image resource.
    static let foodsMergeArrowIcon = ImageResource(name: "foods_merge_arrow_icon", bundle: resourceBundle)

    /// The "foods_merge_calories_icon" asset catalog image resource.
    static let foodsMergeCaloriesIcon = ImageResource(name: "foods_merge_calories_icon", bundle: resourceBundle)

    /// The "foods_merge_edit_digit_icon" asset catalog image resource.
    static let foodsMergeEditDigitIcon = ImageResource(name: "foods_merge_edit_digit_icon", bundle: resourceBundle)

    /// The "foods_merge_icon" asset catalog image resource.
    static let foodsMergeIcon = ImageResource(name: "foods_merge_icon", bundle: resourceBundle)

    /// The "foods_new_func_icon" asset catalog image resource.
    static let foodsNewFuncIcon = ImageResource(name: "foods_new_func_icon", bundle: resourceBundle)

    /// The "foods_search_quickly_icon" asset catalog image resource.
    static let foodsSearchQuicklyIcon = ImageResource(name: "foods_search_quickly_icon", bundle: resourceBundle)

    /// The "foods_type_selected_icon" asset catalog image resource.
    static let foodsTypeSelectedIcon = ImageResource(name: "foods_type_selected_icon", bundle: resourceBundle)

    /// The "forum_ tutorial_img" asset catalog image resource.
    static let forumTutorialImg = ImageResource(name: "forum_ tutorial_img", bundle: resourceBundle)

    /// The "forum_add_image_icon" asset catalog image resource.
    static let forumAddImageIcon = ImageResource(name: "forum_add_image_icon", bundle: resourceBundle)

    /// The "forum_aite_icon" asset catalog image resource.
    static let forumAiteIcon = ImageResource(name: "forum_aite_icon", bundle: resourceBundle)

    /// The "forum_aiticle_icon" asset catalog image resource.
    static let forumAiticleIcon = ImageResource(name: "forum_aiticle_icon", bundle: resourceBundle)

    /// The "forum_comment_icon" asset catalog image resource.
    static let forumCommentIcon = ImageResource(name: "forum_comment_icon", bundle: resourceBundle)

    /// The "forum_comment_icon_max" asset catalog image resource.
    static let forumCommentIconMax = ImageResource(name: "forum_comment_icon_max", bundle: resourceBundle)

    /// The "forum_comment_icon_min" asset catalog image resource.
    static let forumCommentIconMin = ImageResource(name: "forum_comment_icon_min", bundle: resourceBundle)

    /// The "forum_commom_img_close_icon" asset catalog image resource.
    static let forumCommomImgCloseIcon = ImageResource(name: "forum_commom_img_close_icon", bundle: resourceBundle)

    /// The "forum_commom_img_icon" asset catalog image resource.
    static let forumCommomImgIcon = ImageResource(name: "forum_commom_img_icon", bundle: resourceBundle)

    /// The "forum_commone_icon" asset catalog image resource.
    static let forumCommoneIcon = ImageResource(name: "forum_commone_icon", bundle: resourceBundle)

    /// The "forum_location_icon" asset catalog image resource.
    static let forumLocationIcon = ImageResource(name: "forum_location_icon", bundle: resourceBundle)

    /// The "forum_msg_icon" asset catalog image resource.
    static let forumMsgIcon = ImageResource(name: "forum_msg_icon", bundle: resourceBundle)

    /// The "forum_notice_arrow_icon" asset catalog image resource.
    static let forumNoticeArrowIcon = ImageResource(name: "forum_notice_arrow_icon", bundle: resourceBundle)

    /// The "forum_player_mute_no_icon" asset catalog image resource.
    static let forumPlayerMuteNoIcon = ImageResource(name: "forum_player_mute_no_icon", bundle: resourceBundle)

    /// The "forum_player_mute_yes_icon" asset catalog image resource.
    static let forumPlayerMuteYesIcon = ImageResource(name: "forum_player_mute_yes_icon", bundle: resourceBundle)

    /// The "forum_poll_icon" asset catalog image resource.
    static let forumPollIcon = ImageResource(name: "forum_poll_icon", bundle: resourceBundle)

    /// The "forum_publish_icon" asset catalog image resource.
    static let forumPublishIcon = ImageResource(name: "forum_publish_icon", bundle: resourceBundle)

    /// The "forum_set_top_cancel_icon" asset catalog image resource.
    static let forumSetTopCancelIcon = ImageResource(name: "forum_set_top_cancel_icon", bundle: resourceBundle)

    /// The "forum_set_top_icon" asset catalog image resource.
    static let forumSetTopIcon = ImageResource(name: "forum_set_top_icon", bundle: resourceBundle)

    /// The "forum_share_black_icon" asset catalog image resource.
    static let forumShareBlackIcon = ImageResource(name: "forum_share_black_icon", bundle: resourceBundle)

    /// The "forum_share_circle_icon" asset catalog image resource.
    static let forumShareCircleIcon = ImageResource(name: "forum_share_circle_icon", bundle: resourceBundle)

    /// The "forum_share_copy_icon" asset catalog image resource.
    static let forumShareCopyIcon = ImageResource(name: "forum_share_copy_icon", bundle: resourceBundle)

    /// The "forum_share_delete_icon" asset catalog image resource.
    static let forumShareDeleteIcon = ImageResource(name: "forum_share_delete_icon", bundle: resourceBundle)

    /// The "forum_share_icon" asset catalog image resource.
    static let forumShareIcon = ImageResource(name: "forum_share_icon", bundle: resourceBundle)

    /// The "forum_share_report_icon" asset catalog image resource.
    static let forumShareReportIcon = ImageResource(name: "forum_share_report_icon", bundle: resourceBundle)

    /// The "forum_share_wechat_icon" asset catalog image resource.
    static let forumShareWechatIcon = ImageResource(name: "forum_share_wechat_icon", bundle: resourceBundle)

    /// The "forum_thumbs_up_highlight" asset catalog image resource.
    static let forumThumbsUpHighlight = ImageResource(name: "forum_thumbs_up_highlight", bundle: resourceBundle)

    /// The "forum_thumbs_up_highlight_max" asset catalog image resource.
    static let forumThumbsUpHighlightMax = ImageResource(name: "forum_thumbs_up_highlight_max", bundle: resourceBundle)

    /// The "forum_thumbs_up_highlight_min" asset catalog image resource.
    static let forumThumbsUpHighlightMin = ImageResource(name: "forum_thumbs_up_highlight_min", bundle: resourceBundle)

    /// The "forum_thumbs_up_max" asset catalog image resource.
    static let forumThumbsUpMax = ImageResource(name: "forum_thumbs_up_max", bundle: resourceBundle)

    /// The "forum_thumbs_up_normal" asset catalog image resource.
    static let forumThumbsUpNormal = ImageResource(name: "forum_thumbs_up_normal", bundle: resourceBundle)

    /// The "forum_thumbs_up_normal_min" asset catalog image resource.
    static let forumThumbsUpNormalMin = ImageResource(name: "forum_thumbs_up_normal_min", bundle: resourceBundle)

    /// The "forum_top_icon" asset catalog image resource.
    static let forumTopIcon = ImageResource(name: "forum_top_icon", bundle: resourceBundle)

    /// The "forum_tutorial_default_cover" asset catalog image resource.
    static let forumTutorialDefaultCover = ImageResource(name: "forum_tutorial_default_cover", bundle: resourceBundle)

    /// The "forum_user_verify_icon" asset catalog image resource.
    static let forumUserVerifyIcon = ImageResource(name: "forum_user_verify_icon", bundle: resourceBundle)

    /// The "forum_video_play_icon" asset catalog image resource.
    static let forumVideoPlayIcon = ImageResource(name: "forum_video_play_icon", bundle: resourceBundle)

    /// The "forum_visible_icon" asset catalog image resource.
    static let forumVisibleIcon = ImageResource(name: "forum_visible_icon", bundle: resourceBundle)

    /// The "frame_0000" asset catalog image resource.
    static let frame0000 = ImageResource(name: "frame_0000", bundle: resourceBundle)

    /// The "frame_0001" asset catalog image resource.
    static let frame0001 = ImageResource(name: "frame_0001", bundle: resourceBundle)

    /// The "frame_0002" asset catalog image resource.
    static let frame0002 = ImageResource(name: "frame_0002", bundle: resourceBundle)

    /// The "frame_0003" asset catalog image resource.
    static let frame0003 = ImageResource(name: "frame_0003", bundle: resourceBundle)

    /// The "frame_0004" asset catalog image resource.
    static let frame0004 = ImageResource(name: "frame_0004", bundle: resourceBundle)

    /// The "frame_0005" asset catalog image resource.
    static let frame0005 = ImageResource(name: "frame_0005", bundle: resourceBundle)

    /// The "frame_0006" asset catalog image resource.
    static let frame0006 = ImageResource(name: "frame_0006", bundle: resourceBundle)

    /// The "frame_0007" asset catalog image resource.
    static let frame0007 = ImageResource(name: "frame_0007", bundle: resourceBundle)

    /// The "frame_0008" asset catalog image resource.
    static let frame0008 = ImageResource(name: "frame_0008", bundle: resourceBundle)

    /// The "frame_0009" asset catalog image resource.
    static let frame0009 = ImageResource(name: "frame_0009", bundle: resourceBundle)

    /// The "frame_0010" asset catalog image resource.
    static let frame0010 = ImageResource(name: "frame_0010", bundle: resourceBundle)

    /// The "frame_0011" asset catalog image resource.
    static let frame0011 = ImageResource(name: "frame_0011", bundle: resourceBundle)

    /// The "frame_0012" asset catalog image resource.
    static let frame0012 = ImageResource(name: "frame_0012", bundle: resourceBundle)

    /// The "frame_0013" asset catalog image resource.
    static let frame0013 = ImageResource(name: "frame_0013", bundle: resourceBundle)

    /// The "frame_0014" asset catalog image resource.
    static let frame0014 = ImageResource(name: "frame_0014", bundle: resourceBundle)

    /// The "frame_0015" asset catalog image resource.
    static let frame0015 = ImageResource(name: "frame_0015", bundle: resourceBundle)

    /// The "frame_0016" asset catalog image resource.
    static let frame0016 = ImageResource(name: "frame_0016", bundle: resourceBundle)

    /// The "frame_0017" asset catalog image resource.
    static let frame0017 = ImageResource(name: "frame_0017", bundle: resourceBundle)

    /// The "frame_0018" asset catalog image resource.
    static let frame0018 = ImageResource(name: "frame_0018", bundle: resourceBundle)

    /// The "frame_0019" asset catalog image resource.
    static let frame0019 = ImageResource(name: "frame_0019", bundle: resourceBundle)

    /// The "frame_0020" asset catalog image resource.
    static let frame0020 = ImageResource(name: "frame_0020", bundle: resourceBundle)

    /// The "frame_0021" asset catalog image resource.
    static let frame0021 = ImageResource(name: "frame_0021", bundle: resourceBundle)

    /// The "frame_0022" asset catalog image resource.
    static let frame0022 = ImageResource(name: "frame_0022", bundle: resourceBundle)

    /// The "frame_0023" asset catalog image resource.
    static let frame0023 = ImageResource(name: "frame_0023", bundle: resourceBundle)

    /// The "frame_0024" asset catalog image resource.
    static let frame0024 = ImageResource(name: "frame_0024", bundle: resourceBundle)

    /// The "frame_0025" asset catalog image resource.
    static let frame0025 = ImageResource(name: "frame_0025", bundle: resourceBundle)

    /// The "frame_0026" asset catalog image resource.
    static let frame0026 = ImageResource(name: "frame_0026", bundle: resourceBundle)

    /// The "frame_0027" asset catalog image resource.
    static let frame0027 = ImageResource(name: "frame_0027", bundle: resourceBundle)

    /// The "frame_0028" asset catalog image resource.
    static let frame0028 = ImageResource(name: "frame_0028", bundle: resourceBundle)

    /// The "frame_0029" asset catalog image resource.
    static let frame0029 = ImageResource(name: "frame_0029", bundle: resourceBundle)

    /// The "frame_0030" asset catalog image resource.
    static let frame0030 = ImageResource(name: "frame_0030", bundle: resourceBundle)

    /// The "frame_0031" asset catalog image resource.
    static let frame0031 = ImageResource(name: "frame_0031", bundle: resourceBundle)

    /// The "friend_list_edit_icon" asset catalog image resource.
    static let friendListEditIcon = ImageResource(name: "friend_list_edit_icon", bundle: resourceBundle)

    /// The "friend_list_first" asset catalog image resource.
    static let friendListFirst = ImageResource(name: "friend_list_first", bundle: resourceBundle)

    /// The "friend_list_img" asset catalog image resource.
    static let friendListImg = ImageResource(name: "friend_list_img", bundle: resourceBundle)

    /// The "friend_list_second" asset catalog image resource.
    static let friendListSecond = ImageResource(name: "friend_list_second", bundle: resourceBundle)

    /// The "friend_list_status_add" asset catalog image resource.
    static let friendListStatusAdd = ImageResource(name: "friend_list_status_add", bundle: resourceBundle)

    /// The "friend_list_status_agree" asset catalog image resource.
    static let friendListStatusAgree = ImageResource(name: "friend_list_status_agree", bundle: resourceBundle)

    /// The "friend_list_status_disagree" asset catalog image resource.
    static let friendListStatusDisagree = ImageResource(name: "friend_list_status_disagree", bundle: resourceBundle)

    /// The "friend_list_status_pending" asset catalog image resource.
    static let friendListStatusPending = ImageResource(name: "friend_list_status_pending", bundle: resourceBundle)

    /// The "friend_list_status_succesd" asset catalog image resource.
    static let friendListStatusSuccesd = ImageResource(name: "friend_list_status_succesd", bundle: resourceBundle)

    /// The "friend_list_third" asset catalog image resource.
    static let friendListThird = ImageResource(name: "friend_list_third", bundle: resourceBundle)

    /// The "friend_list_top_1" asset catalog image resource.
    static let friendListTop1 = ImageResource(name: "friend_list_top_1", bundle: resourceBundle)

    /// The "friend_top_bg_img" asset catalog image resource.
    static let friendTopBgImg = ImageResource(name: "friend_top_bg_img", bundle: resourceBundle)

    /// The "goal_circle_icon" asset catalog image resource.
    static let goalCircleIcon = ImageResource(name: "goal_circle_icon", bundle: resourceBundle)

    /// The "goal_circle_question" asset catalog image resource.
    static let goalCircleQuestion = ImageResource(name: "goal_circle_question", bundle: resourceBundle)

    /// The "goal_zhineng_icon" asset catalog image resource.
    static let goalZhinengIcon = ImageResource(name: "goal_zhineng_icon", bundle: resourceBundle)

    /// The "guide_back_button" asset catalog image resource.
    static let guideBackButton = ImageResource(name: "guide_back_button", bundle: resourceBundle)

    /// The "guide_chat_box" asset catalog image resource.
    static let guideChatBox = ImageResource(name: "guide_chat_box", bundle: resourceBundle)

    /// The "guide_chat_box_2" asset catalog image resource.
    static let guideChatBox2 = ImageResource(name: "guide_chat_box_2", bundle: resourceBundle)

    /// The "guide_chat_box_3" asset catalog image resource.
    static let guideChatBox3 = ImageResource(name: "guide_chat_box_3", bundle: resourceBundle)

    /// The "guide_first_page_chart" asset catalog image resource.
    static let guideFirstPageChart = ImageResource(name: "guide_first_page_chart", bundle: resourceBundle)

    /// The "guide_first_page_down_icon" asset catalog image resource.
    static let guideFirstPageDownIcon = ImageResource(name: "guide_first_page_down_icon", bundle: resourceBundle)

    /// The "guide_first_page_logo_icon" asset catalog image resource.
    static let guideFirstPageLogoIcon = ImageResource(name: "guide_first_page_logo_icon", bundle: resourceBundle)

    /// The "guide_first_page_up_icon" asset catalog image resource.
    static let guideFirstPageUpIcon = ImageResource(name: "guide_first_page_up_icon", bundle: resourceBundle)

    /// The "guide_img_step_3" asset catalog image resource.
    static let guideImgStep3 = ImageResource(name: "guide_img_step_3", bundle: resourceBundle)

    /// The "guide_img_step_4" asset catalog image resource.
    static let guideImgStep4 = ImageResource(name: "guide_img_step_4", bundle: resourceBundle)

    /// The "guide_img_step_5" asset catalog image resource.
    static let guideImgStep5 = ImageResource(name: "guide_img_step_5", bundle: resourceBundle)

    /// The "guide_img_step_6" asset catalog image resource.
    static let guideImgStep6 = ImageResource(name: "guide_img_step_6", bundle: resourceBundle)

    /// The "guide_img_step_7" asset catalog image resource.
    static let guideImgStep7 = ImageResource(name: "guide_img_step_7", bundle: resourceBundle)

    /// The "guide_img_step_7_circle" asset catalog image resource.
    static let guideImgStep7Circle = ImageResource(name: "guide_img_step_7_circle", bundle: resourceBundle)

    /// The "guide_second_img_1" asset catalog image resource.
    static let guideSecondImg1 = ImageResource(name: "guide_second_img_1", bundle: resourceBundle)

    /// The "guide_second_img_2" asset catalog image resource.
    static let guideSecondImg2 = ImageResource(name: "guide_second_img_2", bundle: resourceBundle)

    /// The "guide_second_img_3" asset catalog image resource.
    static let guideSecondImg3 = ImageResource(name: "guide_second_img_3", bundle: resourceBundle)

    /// The "guide_second_img_4" asset catalog image resource.
    static let guideSecondImg4 = ImageResource(name: "guide_second_img_4", bundle: resourceBundle)

    /// The "guide_second_jijian" asset catalog image resource.
    static let guideSecondJijian = ImageResource(name: "guide_second_jijian", bundle: resourceBundle)

    /// The "guide_second_zhuanye" asset catalog image resource.
    static let guideSecondZhuanye = ImageResource(name: "guide_second_zhuanye", bundle: resourceBundle)

    /// The "guide_third_add_icon" asset catalog image resource.
    static let guideThirdAddIcon = ImageResource(name: "guide_third_add_icon", bundle: resourceBundle)

    /// The "habit_bg_ela_img" asset catalog image resource.
    static let habitBgElaImg = ImageResource(name: "habit_bg_ela_img", bundle: resourceBundle)

    /// The "habit_exchange_tips_bg" asset catalog image resource.
    static let habitExchangeTipsBg = ImageResource(name: "habit_exchange_tips_bg", bundle: resourceBundle)

    /// The "habit_exchange_tips_ela_bg" asset catalog image resource.
    static let habitExchangeTipsElaBg = ImageResource(name: "habit_exchange_tips_ela_bg", bundle: resourceBundle)

    /// The "habit_exchange_tips_title" asset catalog image resource.
    static let habitExchangeTipsTitle = ImageResource(name: "habit_exchange_tips_title", bundle: resourceBundle)

    /// The "habit_guide_1_bg" asset catalog image resource.
    static let habitGuide1Bg = ImageResource(name: "habit_guide_1_bg", bundle: resourceBundle)

    /// The "habit_guide_2_img" asset catalog image resource.
    static let habitGuide2Img = ImageResource(name: "habit_guide_2_img", bundle: resourceBundle)

    /// The "habit_guide_3_img" asset catalog image resource.
    static let habitGuide3Img = ImageResource(name: "habit_guide_3_img", bundle: resourceBundle)

    /// The "habit_guide_4_img" asset catalog image resource.
    static let habitGuide4Img = ImageResource(name: "habit_guide_4_img", bundle: resourceBundle)

    /// The "habit_guide_5_img" asset catalog image resource.
    static let habitGuide5Img = ImageResource(name: "habit_guide_5_img", bundle: resourceBundle)

    /// The "habit_guide_back_icon" asset catalog image resource.
    static let habitGuideBackIcon = ImageResource(name: "habit_guide_back_icon", bundle: resourceBundle)

    /// The "habit_guide_ela_icon" asset catalog image resource.
    static let habitGuideElaIcon = ImageResource(name: "habit_guide_ela_icon", bundle: resourceBundle)

    /// The "habit_number_add_icon" asset catalog image resource.
    static let habitNumberAddIcon = ImageResource(name: "habit_number_add_icon", bundle: resourceBundle)

    /// The "habit_number_sub_icon" asset catalog image resource.
    static let habitNumberSubIcon = ImageResource(name: "habit_number_sub_icon", bundle: resourceBundle)

    /// The "habit_rank_down_icon" asset catalog image resource.
    static let habitRankDownIcon = ImageResource(name: "habit_rank_down_icon", bundle: resourceBundle)

    /// The "habit_rank_right_icon" asset catalog image resource.
    static let habitRankRightIcon = ImageResource(name: "habit_rank_right_icon", bundle: resourceBundle)

    /// The "habit_rank_time_icon" asset catalog image resource.
    static let habitRankTimeIcon = ImageResource(name: "habit_rank_time_icon", bundle: resourceBundle)

    /// The "habit_rank_up_icon" asset catalog image resource.
    static let habitRankUpIcon = ImageResource(name: "habit_rank_up_icon", bundle: resourceBundle)

    /// The "habit_ranklist_empty_img" asset catalog image resource.
    static let habitRanklistEmptyImg = ImageResource(name: "habit_ranklist_empty_img", bundle: resourceBundle)

    /// The "habit_ranklist_heart_icon" asset catalog image resource.
    static let habitRanklistHeartIcon = ImageResource(name: "habit_ranklist_heart_icon", bundle: resourceBundle)

    /// The "habit_ranklist_one" asset catalog image resource.
    static let habitRanklistOne = ImageResource(name: "habit_ranklist_one", bundle: resourceBundle)

    /// The "habit_ranklist_three" asset catalog image resource.
    static let habitRanklistThree = ImageResource(name: "habit_ranklist_three", bundle: resourceBundle)

    /// The "habit_ranklist_two" asset catalog image resource.
    static let habitRanklistTwo = ImageResource(name: "habit_ranklist_two", bundle: resourceBundle)

    /// The "habit_rule_img_1" asset catalog image resource.
    static let habitRuleImg1 = ImageResource(name: "habit_rule_img_1", bundle: resourceBundle)

    /// The "habit_rule_img_2" asset catalog image resource.
    static let habitRuleImg2 = ImageResource(name: "habit_rule_img_2", bundle: resourceBundle)

    /// The "habit_settle_bg_img" asset catalog image resource.
    static let habitSettleBgImg = ImageResource(name: "habit_settle_bg_img", bundle: resourceBundle)

    /// The "habit_settle_cup_shadow" asset catalog image resource.
    static let habitSettleCupShadow = ImageResource(name: "habit_settle_cup_shadow", bundle: resourceBundle)

    /// The "habit_settle_degree_left_icon" asset catalog image resource.
    static let habitSettleDegreeLeftIcon = ImageResource(name: "habit_settle_degree_left_icon", bundle: resourceBundle)

    /// The "habit_settle_degree_right_icon" asset catalog image resource.
    static let habitSettleDegreeRightIcon = ImageResource(name: "habit_settle_degree_right_icon", bundle: resourceBundle)

    /// The "habit_settle_desk" asset catalog image resource.
    static let habitSettleDesk = ImageResource(name: "habit_settle_desk", bundle: resourceBundle)

    /// The "habit_settle_list_bg" asset catalog image resource.
    static let habitSettleListBg = ImageResource(name: "habit_settle_list_bg", bundle: resourceBundle)

    /// The "haibit_body_data_icon" asset catalog image resource.
    static let haibitBodyDataIcon = ImageResource(name: "haibit_body_data_icon", bundle: resourceBundle)

    /// The "haibit_fitness_icon" asset catalog image resource.
    static let haibitFitnessIcon = ImageResource(name: "haibit_fitness_icon", bundle: resourceBundle)

    /// The "haibit_friend_icon" asset catalog image resource.
    static let haibitFriendIcon = ImageResource(name: "haibit_friend_icon", bundle: resourceBundle)

    /// The "haibit_friend_protein_icon" asset catalog image resource.
    static let haibitFriendProteinIcon = ImageResource(name: "haibit_friend_protein_icon", bundle: resourceBundle)

    /// The "haibit_journal_icon" asset catalog image resource.
    static let haibitJournalIcon = ImageResource(name: "haibit_journal_icon", bundle: resourceBundle)

    /// The "haibit_protein_icon" asset catalog image resource.
    static let haibitProteinIcon = ImageResource(name: "haibit_protein_icon", bundle: resourceBundle)

    /// The "haibit_streak_normal_icon" asset catalog image resource.
    static let haibitStreakNormalIcon = ImageResource(name: "haibit_streak_normal_icon", bundle: resourceBundle)

    /// The "honor_top_img" asset catalog image resource.
    static let honorTopImg = ImageResource(name: "honor_top_img", bundle: resourceBundle)

    /// The "icon_90_gray" asset catalog image resource.
    static let icon90Gray = ImageResource(name: "icon_90_gray", bundle: resourceBundle)

    /// The "icon_95_blue" asset catalog image resource.
    static let icon95Blue = ImageResource(name: "icon_95_blue", bundle: resourceBundle)

    /// The "icon_calendar_gray" asset catalog image resource.
    static let iconCalendarGray = ImageResource(name: "icon_calendar_gray", bundle: resourceBundle)

    /// The "idc_icon_china" asset catalog image resource.
    static let idcIconChina = ImageResource(name: "idc_icon_china", bundle: resourceBundle)

    /// The "img_close_icon" asset catalog image resource.
    static let imgCloseIcon = ImageResource(name: "img_close_icon", bundle: resourceBundle)

    /// The "invite_rewards_code_bg" asset catalog image resource.
    static let inviteRewardsCodeBg = ImageResource(name: "invite_rewards_code_bg", bundle: resourceBundle)

    /// The "journal_share_calories_icon" asset catalog image resource.
    static let journalShareCaloriesIcon = ImageResource(name: "journal_share_calories_icon", bundle: resourceBundle)

    /// The "journal_share_shadow_view" asset catalog image resource.
    static let journalShareShadowView = ImageResource(name: "journal_share_shadow_view", bundle: resourceBundle)

    /// The "launch_bg_img" asset catalog image resource.
    static let launchBgImg = ImageResource(name: "launch_bg_img", bundle: resourceBundle)

    /// The "launch_slogan_img" asset catalog image resource.
    static let launchSloganImg = ImageResource(name: "launch_slogan_img", bundle: resourceBundle)

    /// The "launch_welcome_bg" asset catalog image resource.
    static let launchWelcomeBg = ImageResource(name: "launch_welcome_bg", bundle: resourceBundle)

    /// The "launch_welcome_img_1" asset catalog image resource.
    static let launchWelcomeImg1 = ImageResource(name: "launch_welcome_img_1", bundle: resourceBundle)

    /// The "launch_welcome_img_2" asset catalog image resource.
    static let launchWelcomeImg2 = ImageResource(name: "launch_welcome_img_2", bundle: resourceBundle)

    /// The "launch_welcome_img_3" asset catalog image resource.
    static let launchWelcomeImg3 = ImageResource(name: "launch_welcome_img_3", bundle: resourceBundle)

    /// The "log_share_bg_img" asset catalog image resource.
    static let logShareBgImg = ImageResource(name: "log_share_bg_img", bundle: resourceBundle)

    /// The "login_alert_apple_icon" asset catalog image resource.
    static let loginAlertAppleIcon = ImageResource(name: "login_alert_apple_icon", bundle: resourceBundle)

    /// The "login_alert_phone_icon" asset catalog image resource.
    static let loginAlertPhoneIcon = ImageResource(name: "login_alert_phone_icon", bundle: resourceBundle)

    /// The "login_alert_wechat_icon" asset catalog image resource.
    static let loginAlertWechatIcon = ImageResource(name: "login_alert_wechat_icon", bundle: resourceBundle)

    /// The "login_apple_icon" asset catalog image resource.
    static let loginAppleIcon = ImageResource(name: "login_apple_icon", bundle: resourceBundle)

    /// The "login_arrow_down_icon" asset catalog image resource.
    static let loginArrowDownIcon = ImageResource(name: "login_arrow_down_icon", bundle: resourceBundle)

    /// The "login_close_img" asset catalog image resource.
    static let loginCloseImg = ImageResource(name: "login_close_img", bundle: resourceBundle)

    /// The "login_wechat_icon" asset catalog image resource.
    static let loginWechatIcon = ImageResource(name: "login_wechat_icon", bundle: resourceBundle)

    /// The "logs_add_icon_theme" asset catalog image resource.
    static let logsAddIconTheme = ImageResource(name: "logs_add_icon_theme", bundle: resourceBundle)

    /// The "logs_add_icon_theme_cj" asset catalog image resource.
    static let logsAddIconThemeCj = ImageResource(name: "logs_add_icon_theme_cj", bundle: resourceBundle)

    /// The "logs_circle_cover" asset catalog image resource.
    static let logsCircleCover = ImageResource(name: "logs_circle_cover", bundle: resourceBundle)

    /// The "logs_create_plan_icon" asset catalog image resource.
    static let logsCreatePlanIcon = ImageResource(name: "logs_create_plan_icon", bundle: resourceBundle)

    /// The "logs_edit_all_normal" asset catalog image resource.
    static let logsEditAllNormal = ImageResource(name: "logs_edit_all_normal", bundle: resourceBundle)

    /// The "logs_edit_selected" asset catalog image resource.
    static let logsEditSelected = ImageResource(name: "logs_edit_selected", bundle: resourceBundle)

    /// The "logs_foods_copy_icon" asset catalog image resource.
    static let logsFoodsCopyIcon = ImageResource(name: "logs_foods_copy_icon", bundle: resourceBundle)

    /// The "logs_foods_eat_icon" asset catalog image resource.
    static let logsFoodsEatIcon = ImageResource(name: "logs_foods_eat_icon", bundle: resourceBundle)

    /// The "logs_foods_eat_icon_cj" asset catalog image resource.
    static let logsFoodsEatIconCj = ImageResource(name: "logs_foods_eat_icon_cj", bundle: resourceBundle)

    /// The "logs_foods_meals_create_icon" asset catalog image resource.
    static let logsFoodsMealsCreateIcon = ImageResource(name: "logs_foods_meals_create_icon", bundle: resourceBundle)

    /// The "logs_natural_icon" asset catalog image resource.
    static let logsNaturalIcon = ImageResource(name: "logs_natural_icon", bundle: resourceBundle)

    /// The "logs_natural_icon_cj" asset catalog image resource.
    static let logsNaturalIconCj = ImageResource(name: "logs_natural_icon_cj", bundle: resourceBundle)

    /// The "logs_navi_list_icon" asset catalog image resource.
    static let logsNaviListIcon = ImageResource(name: "logs_navi_list_icon", bundle: resourceBundle)

    /// The "logs_navi_share_icon" asset catalog image resource.
    static let logsNaviShareIcon = ImageResource(name: "logs_navi_share_icon", bundle: resourceBundle)

    /// The "logs_pen_icon" asset catalog image resource.
    static let logsPenIcon = ImageResource(name: "logs_pen_icon", bundle: resourceBundle)

    /// The "logs_remark_add_icon" asset catalog image resource.
    static let logsRemarkAddIcon = ImageResource(name: "logs_remark_add_icon", bundle: resourceBundle)

    /// The "logs_remark_arrow_down" asset catalog image resource.
    static let logsRemarkArrowDown = ImageResource(name: "logs_remark_arrow_down", bundle: resourceBundle)

    /// The "logs_share_bg_img" asset catalog image resource.
    static let logsShareBgImg = ImageResource(name: "logs_share_bg_img", bundle: resourceBundle)

    /// The "logs_share_time_icon" asset catalog image resource.
    static let logsShareTimeIcon = ImageResource(name: "logs_share_time_icon", bundle: resourceBundle)

    /// The "main_add_data_button" asset catalog image resource.
    static let mainAddDataButton = ImageResource(name: "main_add_data_button", bundle: resourceBundle)

    /// The "main_circle_bg" asset catalog image resource.
    static let mainCircleBg = ImageResource(name: "main_circle_bg", bundle: resourceBundle)

    /// The "main_edit_icon" asset catalog image resource.
    static let mainEditIcon = ImageResource(name: "main_edit_icon", bundle: resourceBundle)

    /// The "main_edit_icon_theme" asset catalog image resource.
    static let mainEditIconTheme = ImageResource(name: "main_edit_icon_theme", bundle: resourceBundle)

    /// The "main_nutrient_span_img" asset catalog image resource.
    static let mainNutrientSpanImg = ImageResource(name: "main_nutrient_span_img", bundle: resourceBundle)

    /// The "main_nutrient_span_img_2" asset catalog image resource.
    static let mainNutrientSpanImg2 = ImageResource(name: "main_nutrient_span_img_2", bundle: resourceBundle)

    /// The "main_pencil_icon" asset catalog image resource.
    static let mainPencilIcon = ImageResource(name: "main_pencil_icon", bundle: resourceBundle)

    /// The "main_search_icon" asset catalog image resource.
    static let mainSearchIcon = ImageResource(name: "main_search_icon", bundle: resourceBundle)

    /// The "main_top_bg" asset catalog image resource.
    static let mainTopBg = ImageResource(name: "main_top_bg", bundle: resourceBundle)

    /// The "main_top_bg_cj" asset catalog image resource.
    static let mainTopBgCj = ImageResource(name: "main_top_bg_cj", bundle: resourceBundle)

    /// The "main_top_logo" asset catalog image resource.
    static let mainTopLogo = ImageResource(name: "main_top_logo", bundle: resourceBundle)

    /// The "main_top_logo_cj" asset catalog image resource.
    static let mainTopLogoCj = ImageResource(name: "main_top_logo_cj", bundle: resourceBundle)

    /// The "main_top_logo_launch" asset catalog image resource.
    static let mainTopLogoLaunch = ImageResource(name: "main_top_logo_launch", bundle: resourceBundle)

    /// The "mall_address_default_icon" asset catalog image resource.
    static let mallAddressDefaultIcon = ImageResource(name: "mall_address_default_icon", bundle: resourceBundle)

    /// The "mall_address_delete_icon" asset catalog image resource.
    static let mallAddressDeleteIcon = ImageResource(name: "mall_address_delete_icon", bundle: resourceBundle)

    /// The "mall_address_edit_icon" asset catalog image resource.
    static let mallAddressEditIcon = ImageResource(name: "mall_address_edit_icon", bundle: resourceBundle)

    /// The "mall_address_normal_icon" asset catalog image resource.
    static let mallAddressNormalIcon = ImageResource(name: "mall_address_normal_icon", bundle: resourceBundle)

    /// The "mall_detail_back_icon" asset catalog image resource.
    static let mallDetailBackIcon = ImageResource(name: "mall_detail_back_icon", bundle: resourceBundle)

    /// The "mall_detail_service_icon" asset catalog image resource.
    static let mallDetailServiceIcon = ImageResource(name: "mall_detail_service_icon", bundle: resourceBundle)

    /// The "mall_detail_share_icon" asset catalog image resource.
    static let mallDetailShareIcon = ImageResource(name: "mall_detail_share_icon", bundle: resourceBundle)

    /// The "mall_order_address_icon" asset catalog image resource.
    static let mallOrderAddressIcon = ImageResource(name: "mall_order_address_icon", bundle: resourceBundle)

    /// The "mall_order_detail_arrow_down" asset catalog image resource.
    static let mallOrderDetailArrowDown = ImageResource(name: "mall_order_detail_arrow_down", bundle: resourceBundle)

    /// The "mall_order_detail_arrow_top" asset catalog image resource.
    static let mallOrderDetailArrowTop = ImageResource(name: "mall_order_detail_arrow_top", bundle: resourceBundle)

    /// The "mall_order_idcard_icon" asset catalog image resource.
    static let mallOrderIdcardIcon = ImageResource(name: "mall_order_idcard_icon", bundle: resourceBundle)

    /// The "mall_order_img_add_icon" asset catalog image resource.
    static let mallOrderImgAddIcon = ImageResource(name: "mall_order_img_add_icon", bundle: resourceBundle)

    /// The "mall_order_img_clear_icon" asset catalog image resource.
    static let mallOrderImgClearIcon = ImageResource(name: "mall_order_img_clear_icon", bundle: resourceBundle)

    /// The "mall_order_num_add_icon" asset catalog image resource.
    static let mallOrderNumAddIcon = ImageResource(name: "mall_order_num_add_icon", bundle: resourceBundle)

    /// The "mall_order_num_sub_icon" asset catalog image resource.
    static let mallOrderNumSubIcon = ImageResource(name: "mall_order_num_sub_icon", bundle: resourceBundle)

    /// The "mall_order_success_icon" asset catalog image resource.
    static let mallOrderSuccessIcon = ImageResource(name: "mall_order_success_icon", bundle: resourceBundle)

    /// The "mall_spec_arrow_down_icon" asset catalog image resource.
    static let mallSpecArrowDownIcon = ImageResource(name: "mall_spec_arrow_down_icon", bundle: resourceBundle)

    /// The "meals_create_camera" asset catalog image resource.
    static let mealsCreateCamera = ImageResource(name: "meals_create_camera", bundle: resourceBundle)

    /// The "meals_create_icon" asset catalog image resource.
    static let mealsCreateIcon = ImageResource(name: "meals_create_icon", bundle: resourceBundle)

    /// The "meals_eat_add_icon" asset catalog image resource.
    static let mealsEatAddIcon = ImageResource(name: "meals_eat_add_icon", bundle: resourceBundle)

    /// The "meals_eat_add_icon_theme" asset catalog image resource.
    static let mealsEatAddIconTheme = ImageResource(name: "meals_eat_add_icon_theme", bundle: resourceBundle)

    /// The "meals_eat_add_icon_white" asset catalog image resource.
    static let mealsEatAddIconWhite = ImageResource(name: "meals_eat_add_icon_white", bundle: resourceBundle)

    /// The "meals_eat_icon" asset catalog image resource.
    static let mealsEatIcon = ImageResource(name: "meals_eat_icon", bundle: resourceBundle)

    /// The "meals_eat_right_icon" asset catalog image resource.
    static let mealsEatRightIcon = ImageResource(name: "meals_eat_right_icon", bundle: resourceBundle)

    /// The "meals_foods_default" asset catalog image resource.
    static let mealsFoodsDefault = ImageResource(name: "meals_foods_default", bundle: resourceBundle)

    /// The "meals_foods_photo" asset catalog image resource.
    static let mealsFoodsPhoto = ImageResource(name: "meals_foods_photo", bundle: resourceBundle)

    /// The "meals_icon_default" asset catalog image resource.
    static let mealsIconDefault = ImageResource(name: "meals_icon_default", bundle: resourceBundle)

    /// The "meals_top_bg" asset catalog image resource.
    static let mealsTopBg = ImageResource(name: "meals_top_bg", bundle: resourceBundle)

    /// The "mian_top_bg_whole" asset catalog image resource.
    static let mianTopBgWhole = ImageResource(name: "mian_top_bg_whole", bundle: resourceBundle)

    /// The "mine_boday_data" asset catalog image resource.
    static let mineBodayData = ImageResource(name: "mine_boday_data", bundle: resourceBundle)

    /// The "mine_func_arrow" asset catalog image resource.
    static let mineFuncArrow = ImageResource(name: "mine_func_arrow", bundle: resourceBundle)

    /// The "mine_func_arrow_icon" asset catalog image resource.
    static let mineFuncArrowIcon = ImageResource(name: "mine_func_arrow_icon", bundle: resourceBundle)

    /// The "mine_func_create_plan" asset catalog image resource.
    static let mineFuncCreatePlan = ImageResource(name: "mine_func_create_plan", bundle: resourceBundle)

    /// The "mine_func_fasting" asset catalog image resource.
    static let mineFuncFasting = ImageResource(name: "mine_func_fasting", bundle: resourceBundle)

    /// The "mine_func_foods" asset catalog image resource.
    static let mineFuncFoods = ImageResource(name: "mine_func_foods", bundle: resourceBundle)

    /// The "mine_func_forum_msg_icon" asset catalog image resource.
    static let mineFuncForumMsgIcon = ImageResource(name: "mine_func_forum_msg_icon", bundle: resourceBundle)

    /// The "mine_func_friends" asset catalog image resource.
    static let mineFuncFriends = ImageResource(name: "mine_func_friends", bundle: resourceBundle)

    /// The "mine_func_goal" asset catalog image resource.
    static let mineFuncGoal = ImageResource(name: "mine_func_goal", bundle: resourceBundle)

    /// The "mine_func_honor" asset catalog image resource.
    static let mineFuncHonor = ImageResource(name: "mine_func_honor", bundle: resourceBundle)

    /// The "mine_func_invite" asset catalog image resource.
    static let mineFuncInvite = ImageResource(name: "mine_func_invite", bundle: resourceBundle)

    /// The "mine_func_meal" asset catalog image resource.
    static let mineFuncMeal = ImageResource(name: "mine_func_meal", bundle: resourceBundle)

    /// The "mine_func_order_list" asset catalog image resource.
    static let mineFuncOrderList = ImageResource(name: "mine_func_order_list", bundle: resourceBundle)

    /// The "mine_func_personal_setting" asset catalog image resource.
    static let mineFuncPersonalSetting = ImageResource(name: "mine_func_personal_setting", bundle: resourceBundle)

    /// The "mine_func_plan" asset catalog image resource.
    static let mineFuncPlan = ImageResource(name: "mine_func_plan", bundle: resourceBundle)

    /// The "mine_func_service" asset catalog image resource.
    static let mineFuncService = ImageResource(name: "mine_func_service", bundle: resourceBundle)

    /// The "mine_func_setting" asset catalog image resource.
    static let mineFuncSetting = ImageResource(name: "mine_func_setting", bundle: resourceBundle)

    /// The "mine_func_stat" asset catalog image resource.
    static let mineFuncStat = ImageResource(name: "mine_func_stat", bundle: resourceBundle)

    /// The "mine_func_tutorials" asset catalog image resource.
    static let mineFuncTutorials = ImageResource(name: "mine_func_tutorials", bundle: resourceBundle)

    /// The "mine_setting_logo" asset catalog image resource.
    static let mineSettingLogo = ImageResource(name: "mine_setting_logo", bundle: resourceBundle)

    /// The "mine_top_bg" asset catalog image resource.
    static let mineTopBg = ImageResource(name: "mine_top_bg", bundle: resourceBundle)

    /// The "mine_top_func_arrow" asset catalog image resource.
    static let mineTopFuncArrow = ImageResource(name: "mine_top_func_arrow", bundle: resourceBundle)

    /// The "navi_back_white_icon" asset catalog image resource.
    static let naviBackWhiteIcon = ImageResource(name: "navi_back_white_icon", bundle: resourceBundle)

    /// The "navi_close_icon" asset catalog image resource.
    static let naviCloseIcon = ImageResource(name: "navi_close_icon", bundle: resourceBundle)

    /// The "navi_logo_img" asset catalog image resource.
    static let naviLogoImg = ImageResource(name: "navi_logo_img", bundle: resourceBundle)

    /// The "notifi_tips_img" asset catalog image resource.
    static let notifiTipsImg = ImageResource(name: "notifi_tips_img", bundle: resourceBundle)

    /// The "peacock_img" asset catalog image resource.
    static let peacockImg = ImageResource(name: "peacock_img", bundle: resourceBundle)

    /// The "plan_arrow_gray" asset catalog image resource.
    static let planArrowGray = ImageResource(name: "plan_arrow_gray", bundle: resourceBundle)

    /// The "plan_arrow_gray_whole" asset catalog image resource.
    static let planArrowGrayWhole = ImageResource(name: "plan_arrow_gray_whole", bundle: resourceBundle)

    /// The "plan_arrow_theme" asset catalog image resource.
    static let planArrowTheme = ImageResource(name: "plan_arrow_theme", bundle: resourceBundle)

    /// The "plan_create_icon" asset catalog image resource.
    static let planCreateIcon = ImageResource(name: "plan_create_icon", bundle: resourceBundle)

    /// The "plan_detail_arrow_blace_icon" asset catalog image resource.
    static let planDetailArrowBlaceIcon = ImageResource(name: "plan_detail_arrow_blace_icon", bundle: resourceBundle)

    /// The "plan_detail_arrow_highlight_icon" asset catalog image resource.
    static let planDetailArrowHighlightIcon = ImageResource(name: "plan_detail_arrow_highlight_icon", bundle: resourceBundle)

    /// The "plan_detail_arrow_highlight_icon_left" asset catalog image resource.
    static let planDetailArrowHighlightIconLeft = ImageResource(name: "plan_detail_arrow_highlight_icon_left", bundle: resourceBundle)

    /// The "plan_detail_arrow_icon_left" asset catalog image resource.
    static let planDetailArrowIconLeft = ImageResource(name: "plan_detail_arrow_icon_left", bundle: resourceBundle)

    /// The "plan_detail_arrow_icon_right" asset catalog image resource.
    static let planDetailArrowIconRight = ImageResource(name: "plan_detail_arrow_icon_right", bundle: resourceBundle)

    /// The "plan_detail_cancel_icon" asset catalog image resource.
    static let planDetailCancelIcon = ImageResource(name: "plan_detail_cancel_icon", bundle: resourceBundle)

    /// The "plan_detail_circle_img" asset catalog image resource.
    static let planDetailCircleImg = ImageResource(name: "plan_detail_circle_img", bundle: resourceBundle)

    /// The "plan_detail_delete_icon" asset catalog image resource.
    static let planDetailDeleteIcon = ImageResource(name: "plan_detail_delete_icon", bundle: resourceBundle)

    /// The "plan_detail_share_icon" asset catalog image resource.
    static let planDetailShareIcon = ImageResource(name: "plan_detail_share_icon", bundle: resourceBundle)

    /// The "plan_get_alert_bg_img" asset catalog image resource.
    static let planGetAlertBgImg = ImageResource(name: "plan_get_alert_bg_img", bundle: resourceBundle)

    /// The "plan_get_alert_calori_bg_img" asset catalog image resource.
    static let planGetAlertCaloriBgImg = ImageResource(name: "plan_get_alert_calori_bg_img", bundle: resourceBundle)

    /// The "plan_get_alert_calori_icon" asset catalog image resource.
    static let planGetAlertCaloriIcon = ImageResource(name: "plan_get_alert_calori_icon", bundle: resourceBundle)

    /// The "plan_get_alert_clock_icon" asset catalog image resource.
    static let planGetAlertClockIcon = ImageResource(name: "plan_get_alert_clock_icon", bundle: resourceBundle)

    /// The "plan_get_alert_natural_line" asset catalog image resource.
    static let planGetAlertNaturalLine = ImageResource(name: "plan_get_alert_natural_line", bundle: resourceBundle)

    /// The "plan_get_icon" asset catalog image resource.
    static let planGetIcon = ImageResource(name: "plan_get_icon", bundle: resourceBundle)

    /// The "plan_lead_icon" asset catalog image resource.
    static let planLeadIcon = ImageResource(name: "plan_lead_icon", bundle: resourceBundle)

    /// The "plan_share_bg_img" asset catalog image resource.
    static let planShareBgImg = ImageResource(name: "plan_share_bg_img", bundle: resourceBundle)

    /// The "plan_share_bg_img_rect" asset catalog image resource.
    static let planShareBgImgRect = ImageResource(name: "plan_share_bg_img_rect", bundle: resourceBundle)

    /// The "plan_share_circle_icon" asset catalog image resource.
    static let planShareCircleIcon = ImageResource(name: "plan_share_circle_icon", bundle: resourceBundle)

    /// The "plan_share_circle_icon_white" asset catalog image resource.
    static let planShareCircleIconWhite = ImageResource(name: "plan_share_circle_icon_white", bundle: resourceBundle)

    /// The "plan_share_close_icon" asset catalog image resource.
    static let planShareCloseIcon = ImageResource(name: "plan_share_close_icon", bundle: resourceBundle)

    /// The "plan_share_copy_icon" asset catalog image resource.
    static let planShareCopyIcon = ImageResource(name: "plan_share_copy_icon", bundle: resourceBundle)

    /// The "plan_share_save_icon" asset catalog image resource.
    static let planShareSaveIcon = ImageResource(name: "plan_share_save_icon", bundle: resourceBundle)

    /// The "plan_share_save_icon_white" asset catalog image resource.
    static let planShareSaveIconWhite = ImageResource(name: "plan_share_save_icon_white", bundle: resourceBundle)

    /// The "plan_share_wechat_icon" asset catalog image resource.
    static let planShareWechatIcon = ImageResource(name: "plan_share_wechat_icon", bundle: resourceBundle)

    /// The "plan_share_wechat_icon_white" asset catalog image resource.
    static let planShareWechatIconWhite = ImageResource(name: "plan_share_wechat_icon_white", bundle: resourceBundle)

    /// The "question_alert_arrow_down_icon" asset catalog image resource.
    static let questionAlertArrowDownIcon = ImageResource(name: "question_alert_arrow_down_icon", bundle: resourceBundle)

    /// The "question_alert_close_icon" asset catalog image resource.
    static let questionAlertCloseIcon = ImageResource(name: "question_alert_close_icon", bundle: resourceBundle)

    /// The "question_arrow_right" asset catalog image resource.
    static let questionArrowRight = ImageResource(name: "question_arrow_right", bundle: resourceBundle)

    /// The "question_arrow_right_theme" asset catalog image resource.
    static let questionArrowRightTheme = ImageResource(name: "question_arrow_right_theme", bundle: resourceBundle)

    /// The "question_bg" asset catalog image resource.
    static let questionBg = ImageResource(name: "question_bg", bundle: resourceBundle)

    /// The "question_checkbox_normal" asset catalog image resource.
    static let questionCheckboxNormal = ImageResource(name: "question_checkbox_normal", bundle: resourceBundle)

    /// The "question_checkbox_selected" asset catalog image resource.
    static let questionCheckboxSelected = ImageResource(name: "question_checkbox_selected", bundle: resourceBundle)

    /// The "question_foods_normal_icon" asset catalog image resource.
    static let questionFoodsNormalIcon = ImageResource(name: "question_foods_normal_icon", bundle: resourceBundle)

    /// The "question_foods_selected_icon" asset catalog image resource.
    static let questionFoodsSelectedIcon = ImageResource(name: "question_foods_selected_icon", bundle: resourceBundle)

    /// The "question_foods_verify_icon" asset catalog image resource.
    static let questionFoodsVerifyIcon = ImageResource(name: "question_foods_verify_icon", bundle: resourceBundle)

    /// The "question_goal_selected" asset catalog image resource.
    static let questionGoalSelected = ImageResource(name: "question_goal_selected", bundle: resourceBundle)

    /// The "question_plan_tips_content" asset catalog image resource.
    static let questionPlanTipsContent = ImageResource(name: "question_plan_tips_content", bundle: resourceBundle)

    /// The "question_pre_img" asset catalog image resource.
    static let questionPreImg = ImageResource(name: "question_pre_img", bundle: resourceBundle)

    /// The "rank_1_reached" asset catalog image resource.
    static let rank1Reached = ImageResource(name: "rank_1_reached", bundle: resourceBundle)

    /// The "rank_2_reached" asset catalog image resource.
    static let rank2Reached = ImageResource(name: "rank_2_reached", bundle: resourceBundle)

    /// The "rank_3_reached" asset catalog image resource.
    static let rank3Reached = ImageResource(name: "rank_3_reached", bundle: resourceBundle)

    /// The "rank_4_reached" asset catalog image resource.
    static let rank4Reached = ImageResource(name: "rank_4_reached", bundle: resourceBundle)

    /// The "rank_5_reached" asset catalog image resource.
    static let rank5Reached = ImageResource(name: "rank_5_reached", bundle: resourceBundle)

    /// The "rank_6_reached" asset catalog image resource.
    static let rank6Reached = ImageResource(name: "rank_6_reached", bundle: resourceBundle)

    /// The "rank_7_reached" asset catalog image resource.
    static let rank7Reached = ImageResource(name: "rank_7_reached", bundle: resourceBundle)

    /// The "rank_8_reached" asset catalog image resource.
    static let rank8Reached = ImageResource(name: "rank_8_reached", bundle: resourceBundle)

    /// The "rank_9_reached" asset catalog image resource.
    static let rank9Reached = ImageResource(name: "rank_9_reached", bundle: resourceBundle)

    /// The "rank_locked_icon" asset catalog image resource.
    static let rankLockedIcon = ImageResource(name: "rank_locked_icon", bundle: resourceBundle)

    /// The "rank_locked_img" asset catalog image resource.
    static let rankLockedImg = ImageResource(name: "rank_locked_img", bundle: resourceBundle)

    /// The "rank_unlock" asset catalog image resource.
    static let rankUnlock = ImageResource(name: "rank_unlock", bundle: resourceBundle)

    /// The "report_calories_source_icon" asset catalog image resource.
    static let reportCaloriesSourceIcon = ImageResource(name: "report_calories_source_icon", bundle: resourceBundle)

    /// The "report_daily_calories_bg_icon" asset catalog image resource.
    static let reportDailyCaloriesBgIcon = ImageResource(name: "report_daily_calories_bg_icon", bundle: resourceBundle)

    /// The "report_daily_carbo_icon" asset catalog image resource.
    static let reportDailyCarboIcon = ImageResource(name: "report_daily_carbo_icon", bundle: resourceBundle)

    /// The "report_daily_fat_icon" asset catalog image resource.
    static let reportDailyFatIcon = ImageResource(name: "report_daily_fat_icon", bundle: resourceBundle)

    /// The "report_daily_protein_icon" asset catalog image resource.
    static let reportDailyProteinIcon = ImageResource(name: "report_daily_protein_icon", bundle: resourceBundle)

    /// The "report_ela_img" asset catalog image resource.
    static let reportElaImg = ImageResource(name: "report_ela_img", bundle: resourceBundle)

    /// The "report_week_nodata_img" asset catalog image resource.
    static let reportWeekNodataImg = ImageResource(name: "report_week_nodata_img", bundle: resourceBundle)

    /// The "report_weight_down_icon" asset catalog image resource.
    static let reportWeightDownIcon = ImageResource(name: "report_weight_down_icon", bundle: resourceBundle)

    /// The "report_weight_up_icon" asset catalog image resource.
    static let reportWeightUpIcon = ImageResource(name: "report_weight_up_icon", bundle: resourceBundle)

    /// The "rule_journal_alert_img" asset catalog image resource.
    static let ruleJournalAlertImg = ImageResource(name: "rule_journal_alert_img", bundle: resourceBundle)

    /// The "rule_journal_alert_img_protein" asset catalog image resource.
    static let ruleJournalAlertImgProtein = ImageResource(name: "rule_journal_alert_img_protein", bundle: resourceBundle)

    /// The "ruler_cover_bottom" asset catalog image resource.
    static let rulerCoverBottom = ImageResource(name: "ruler_cover_bottom", bundle: resourceBundle)

    /// The "ruler_cover_top" asset catalog image resource.
    static let rulerCoverTop = ImageResource(name: "ruler_cover_top", bundle: resourceBundle)

    /// The "seach_icon" asset catalog image resource.
    static let seachIcon = ImageResource(name: "seach_icon", bundle: resourceBundle)

    /// The "search_clear_icon" asset catalog image resource.
    static let searchClearIcon = ImageResource(name: "search_clear_icon", bundle: resourceBundle)

    /// The "search_icon" asset catalog image resource.
    static let searchIcon = ImageResource(name: "search_icon", bundle: resourceBundle)

    /// The "service_add_bg" asset catalog image resource.
    static let serviceAddBg = ImageResource(name: "service_add_bg", bundle: resourceBundle)

    /// The "service_album_icon" asset catalog image resource.
    static let serviceAlbumIcon = ImageResource(name: "service_album_icon", bundle: resourceBundle)

    /// The "service_camera_icon" asset catalog image resource.
    static let serviceCameraIcon = ImageResource(name: "service_camera_icon", bundle: resourceBundle)

    /// The "service_img_add_icon" asset catalog image resource.
    static let serviceImgAddIcon = ImageResource(name: "service_img_add_icon", bundle: resourceBundle)

    /// The "service_img_add_icon 1" asset catalog image resource.
    static let serviceImgAddIcon1 = ImageResource(name: "service_img_add_icon 1", bundle: resourceBundle)

    /// The "service_order_icon" asset catalog image resource.
    static let serviceOrderIcon = ImageResource(name: "service_order_icon", bundle: resourceBundle)

    /// The "service_type_advice" asset catalog image resource.
    static let serviceTypeAdvice = ImageResource(name: "service_type_advice", bundle: resourceBundle)

    /// The "service_type_market" asset catalog image resource.
    static let serviceTypeMarket = ImageResource(name: "service_type_market", bundle: resourceBundle)

    /// The "sex_icon_feman" asset catalog image resource.
    static let sexIconFeman = ImageResource(name: "sex_icon_feman", bundle: resourceBundle)

    /// The "sex_icon_feman_normal" asset catalog image resource.
    static let sexIconFemanNormal = ImageResource(name: "sex_icon_feman_normal", bundle: resourceBundle)

    /// The "sex_icon_man" asset catalog image resource.
    static let sexIconMan = ImageResource(name: "sex_icon_man", bundle: resourceBundle)

    /// The "sex_icon_man_normal" asset catalog image resource.
    static let sexIconManNormal = ImageResource(name: "sex_icon_man_normal", bundle: resourceBundle)

    /// The "share_icon_shadow" asset catalog image resource.
    static let shareIconShadow = ImageResource(name: "share_icon_shadow", bundle: resourceBundle)

    /// The "slogan_notext" asset catalog image resource.
    static let sloganNotext = ImageResource(name: "slogan_notext", bundle: resourceBundle)

    /// The "sport_add_icon" asset catalog image resource.
    static let sportAddIcon = ImageResource(name: "sport_add_icon", bundle: resourceBundle)

    /// The "sport_calories_icon" asset catalog image resource.
    static let sportCaloriesIcon = ImageResource(name: "sport_calories_icon", bundle: resourceBundle)

    /// The "sport_time_icon" asset catalog image resource.
    static let sportTimeIcon = ImageResource(name: "sport_time_icon", bundle: resourceBundle)

    /// The "stat_calendar_close_icon" asset catalog image resource.
    static let statCalendarCloseIcon = ImageResource(name: "stat_calendar_close_icon", bundle: resourceBundle)

    /// The "stat_fitness_tips_alert_img" asset catalog image resource.
    static let statFitnessTipsAlertImg = ImageResource(name: "stat_fitness_tips_alert_img", bundle: resourceBundle)

    /// The "stat_top_foods_first" asset catalog image resource.
    static let statTopFoodsFirst = ImageResource(name: "stat_top_foods_first", bundle: resourceBundle)

    /// The "stat_top_foods_second" asset catalog image resource.
    static let statTopFoodsSecond = ImageResource(name: "stat_top_foods_second", bundle: resourceBundle)

    /// The "stat_top_foods_third" asset catalog image resource.
    static let statTopFoodsThird = ImageResource(name: "stat_top_foods_third", bundle: resourceBundle)

    /// The "streak_close_icon" asset catalog image resource.
    static let streakCloseIcon = ImageResource(name: "streak_close_icon", bundle: resourceBundle)

    /// The "streak_icon_1" asset catalog image resource.
    static let streakIcon1 = ImageResource(name: "streak_icon_1", bundle: resourceBundle)

    /// The "streak_icon_2" asset catalog image resource.
    static let streakIcon2 = ImageResource(name: "streak_icon_2", bundle: resourceBundle)

    /// The "streak_icon_3" asset catalog image resource.
    static let streakIcon3 = ImageResource(name: "streak_icon_3", bundle: resourceBundle)

    /// The "streak_icon_4" asset catalog image resource.
    static let streakIcon4 = ImageResource(name: "streak_icon_4", bundle: resourceBundle)

    /// The "streak_icon_5" asset catalog image resource.
    static let streakIcon5 = ImageResource(name: "streak_icon_5", bundle: resourceBundle)

    /// The "streak_icon_6" asset catalog image resource.
    static let streakIcon6 = ImageResource(name: "streak_icon_6", bundle: resourceBundle)

    /// The "streak_icon_gray_1" asset catalog image resource.
    static let streakIconGray1 = ImageResource(name: "streak_icon_gray_1", bundle: resourceBundle)

    /// The "streak_icon_gray_2" asset catalog image resource.
    static let streakIconGray2 = ImageResource(name: "streak_icon_gray_2", bundle: resourceBundle)

    /// The "streak_icon_gray_3" asset catalog image resource.
    static let streakIconGray3 = ImageResource(name: "streak_icon_gray_3", bundle: resourceBundle)

    /// The "streak_icon_gray_4" asset catalog image resource.
    static let streakIconGray4 = ImageResource(name: "streak_icon_gray_4", bundle: resourceBundle)

    /// The "streak_icon_gray_5" asset catalog image resource.
    static let streakIconGray5 = ImageResource(name: "streak_icon_gray_5", bundle: resourceBundle)

    /// The "streak_icon_gray_6" asset catalog image resource.
    static let streakIconGray6 = ImageResource(name: "streak_icon_gray_6", bundle: resourceBundle)

    /// The "tabbar_center_icon" asset catalog image resource.
    static let tabbarCenterIcon = ImageResource(name: "tabbar_center_icon", bundle: resourceBundle)

    /// The "tabbar_forum_normal" asset catalog image resource.
    static let tabbarForumNormal = ImageResource(name: "tabbar_forum_normal", bundle: resourceBundle)

    /// The "tabbar_forum_normal_dark" asset catalog image resource.
    static let tabbarForumNormalDark = ImageResource(name: "tabbar_forum_normal_dark", bundle: resourceBundle)

    /// The "tabbar_forum_selected" asset catalog image resource.
    static let tabbarForumSelected = ImageResource(name: "tabbar_forum_selected", bundle: resourceBundle)

    /// The "tabbar_forum_selected_dark" asset catalog image resource.
    static let tabbarForumSelectedDark = ImageResource(name: "tabbar_forum_selected_dark", bundle: resourceBundle)

    /// The "tabbar_logs_normal" asset catalog image resource.
    static let tabbarLogsNormal = ImageResource(name: "tabbar_logs_normal", bundle: resourceBundle)

    /// The "tabbar_logs_normal_dark" asset catalog image resource.
    static let tabbarLogsNormalDark = ImageResource(name: "tabbar_logs_normal_dark", bundle: resourceBundle)

    /// The "tabbar_logs_selected" asset catalog image resource.
    static let tabbarLogsSelected = ImageResource(name: "tabbar_logs_selected", bundle: resourceBundle)

    /// The "tabbar_logs_selected_dark" asset catalog image resource.
    static let tabbarLogsSelectedDark = ImageResource(name: "tabbar_logs_selected_dark", bundle: resourceBundle)

    /// The "tabbar_main_normal" asset catalog image resource.
    static let tabbarMainNormal = ImageResource(name: "tabbar_main_normal", bundle: resourceBundle)

    /// The "tabbar_main_normal_dark" asset catalog image resource.
    static let tabbarMainNormalDark = ImageResource(name: "tabbar_main_normal_dark", bundle: resourceBundle)

    /// The "tabbar_main_selected" asset catalog image resource.
    static let tabbarMainSelected = ImageResource(name: "tabbar_main_selected", bundle: resourceBundle)

    /// The "tabbar_main_selected_dark" asset catalog image resource.
    static let tabbarMainSelectedDark = ImageResource(name: "tabbar_main_selected_dark", bundle: resourceBundle)

    /// The "tabbar_mine_normal" asset catalog image resource.
    static let tabbarMineNormal = ImageResource(name: "tabbar_mine_normal", bundle: resourceBundle)

    /// The "tabbar_mine_normal_dark" asset catalog image resource.
    static let tabbarMineNormalDark = ImageResource(name: "tabbar_mine_normal_dark", bundle: resourceBundle)

    /// The "tabbar_mine_selected" asset catalog image resource.
    static let tabbarMineSelected = ImageResource(name: "tabbar_mine_selected", bundle: resourceBundle)

    /// The "tabbar_mine_selected_dark" asset catalog image resource.
    static let tabbarMineSelectedDark = ImageResource(name: "tabbar_mine_selected_dark", bundle: resourceBundle)

    /// The "tips_gray_icon" asset catalog image resource.
    static let tipsGrayIcon = ImageResource(name: "tips_gray_icon", bundle: resourceBundle)

    /// The "tips_gray_icon_w" asset catalog image resource.
    static let tipsGrayIconW = ImageResource(name: "tips_gray_icon_w", bundle: resourceBundle)

    /// The "tutorial_arrow_down" asset catalog image resource.
    static let tutorialArrowDown = ImageResource(name: "tutorial_arrow_down", bundle: resourceBundle)

    /// The "tutorial_arrow_up" asset catalog image resource.
    static let tutorialArrowUp = ImageResource(name: "tutorial_arrow_up", bundle: resourceBundle)

    /// The "tutorial_back_10_seconds" asset catalog image resource.
    static let tutorialBack10Seconds = ImageResource(name: "tutorial_back_10_seconds", bundle: resourceBundle)

    /// The "tutorial_back_10_seconds_highlight" asset catalog image resource.
    static let tutorialBack10SecondsHighlight = ImageResource(name: "tutorial_back_10_seconds_highlight", bundle: resourceBundle)

    /// The "tutorial_back_icon" asset catalog image resource.
    static let tutorialBackIcon = ImageResource(name: "tutorial_back_icon", bundle: resourceBundle)

    /// The "tutorial_forward_10_seconds" asset catalog image resource.
    static let tutorialForward10Seconds = ImageResource(name: "tutorial_forward_10_seconds", bundle: resourceBundle)

    /// The "tutorial_forward_10_seconds_highlight" asset catalog image resource.
    static let tutorialForward10SecondsHighlight = ImageResource(name: "tutorial_forward_10_seconds_highlight", bundle: resourceBundle)

    /// The "tutorial_full_screen_icon" asset catalog image resource.
    static let tutorialFullScreenIcon = ImageResource(name: "tutorial_full_screen_icon", bundle: resourceBundle)

    /// The "tutorial_mini_screen_icon" asset catalog image resource.
    static let tutorialMiniScreenIcon = ImageResource(name: "tutorial_mini_screen_icon", bundle: resourceBundle)

    /// The "tutorial_next_icon" asset catalog image resource.
    static let tutorialNextIcon = ImageResource(name: "tutorial_next_icon", bundle: resourceBundle)

    /// The "tutorial_playing_icon" asset catalog image resource.
    static let tutorialPlayingIcon = ImageResource(name: "tutorial_playing_icon", bundle: resourceBundle)

    /// The "tutorial_share_icon" asset catalog image resource.
    static let tutorialShareIcon = ImageResource(name: "tutorial_share_icon", bundle: resourceBundle)

    /// The "tutorial_visible_icon" asset catalog image resource.
    static let tutorialVisibleIcon = ImageResource(name: "tutorial_visible_icon", bundle: resourceBundle)

    /// The "tutorials_1_1_1" asset catalog image resource.
    static let tutorials111 = ImageResource(name: "tutorials_1_1_1", bundle: resourceBundle)

    /// The "tutorials_1_1_2" asset catalog image resource.
    static let tutorials112 = ImageResource(name: "tutorials_1_1_2", bundle: resourceBundle)

    /// The "tutorials_1_2_1" asset catalog image resource.
    static let tutorials121 = ImageResource(name: "tutorials_1_2_1", bundle: resourceBundle)

    /// The "tutorials_1_2_2" asset catalog image resource.
    static let tutorials122 = ImageResource(name: "tutorials_1_2_2", bundle: resourceBundle)

    /// The "tutorials_1_2_3" asset catalog image resource.
    static let tutorials123 = ImageResource(name: "tutorials_1_2_3", bundle: resourceBundle)

    /// The "tutorials_1_3_1" asset catalog image resource.
    static let tutorials131 = ImageResource(name: "tutorials_1_3_1", bundle: resourceBundle)

    /// The "tutorials_1_3_1_1" asset catalog image resource.
    static let tutorials1311 = ImageResource(name: "tutorials_1_3_1_1", bundle: resourceBundle)

    /// The "tutorials_1_3_1_2" asset catalog image resource.
    static let tutorials1312 = ImageResource(name: "tutorials_1_3_1_2", bundle: resourceBundle)

    /// The "tutorials_1_3_1_3" asset catalog image resource.
    static let tutorials1313 = ImageResource(name: "tutorials_1_3_1_3", bundle: resourceBundle)

    /// The "tutorials_1_3_2" asset catalog image resource.
    static let tutorials132 = ImageResource(name: "tutorials_1_3_2", bundle: resourceBundle)

    /// The "tutorials_1_4_1" asset catalog image resource.
    static let tutorials141 = ImageResource(name: "tutorials_1_4_1", bundle: resourceBundle)

    /// The "tutorials_1_4_2" asset catalog image resource.
    static let tutorials142 = ImageResource(name: "tutorials_1_4_2", bundle: resourceBundle)

    /// The "tutorials_1_4_3" asset catalog image resource.
    static let tutorials143 = ImageResource(name: "tutorials_1_4_3", bundle: resourceBundle)

    /// The "tutorials_1_4_4" asset catalog image resource.
    static let tutorials144 = ImageResource(name: "tutorials_1_4_4", bundle: resourceBundle)

    /// The "tutorials_1_4_4_2" asset catalog image resource.
    static let tutorials1442 = ImageResource(name: "tutorials_1_4_4_2", bundle: resourceBundle)

    /// The "tutorials_1_4_4_3" asset catalog image resource.
    static let tutorials1443 = ImageResource(name: "tutorials_1_4_4_3", bundle: resourceBundle)

    /// The "tutorials_1_4_5" asset catalog image resource.
    static let tutorials145 = ImageResource(name: "tutorials_1_4_5", bundle: resourceBundle)

    /// The "tutorials_1_4_6" asset catalog image resource.
    static let tutorials146 = ImageResource(name: "tutorials_1_4_6", bundle: resourceBundle)

    /// The "tutorials_1_5_1" asset catalog image resource.
    static let tutorials151 = ImageResource(name: "tutorials_1_5_1", bundle: resourceBundle)

    /// The "tutorials_1_5_2" asset catalog image resource.
    static let tutorials152 = ImageResource(name: "tutorials_1_5_2", bundle: resourceBundle)

    /// The "tutorials_1_5_3" asset catalog image resource.
    static let tutorials153 = ImageResource(name: "tutorials_1_5_3", bundle: resourceBundle)

    /// The "tutorials_1_6_1" asset catalog image resource.
    static let tutorials161 = ImageResource(name: "tutorials_1_6_1", bundle: resourceBundle)

    /// The "tutorials_1_6_2" asset catalog image resource.
    static let tutorials162 = ImageResource(name: "tutorials_1_6_2", bundle: resourceBundle)

    /// The "tutorials_1_6_3" asset catalog image resource.
    static let tutorials163 = ImageResource(name: "tutorials_1_6_3", bundle: resourceBundle)

    /// The "tutorials_1_7_1" asset catalog image resource.
    static let tutorials171 = ImageResource(name: "tutorials_1_7_1", bundle: resourceBundle)

    /// The "tutorials_1_7_2" asset catalog image resource.
    static let tutorials172 = ImageResource(name: "tutorials_1_7_2", bundle: resourceBundle)

    /// The "tutorials_1_7_3" asset catalog image resource.
    static let tutorials173 = ImageResource(name: "tutorials_1_7_3", bundle: resourceBundle)

    /// The "tutorials_1_8_1" asset catalog image resource.
    static let tutorials181 = ImageResource(name: "tutorials_1_8_1", bundle: resourceBundle)

    /// The "tutorials_1_8_2" asset catalog image resource.
    static let tutorials182 = ImageResource(name: "tutorials_1_8_2", bundle: resourceBundle)

    /// The "tutorials_2_1_1" asset catalog image resource.
    static let tutorials211 = ImageResource(name: "tutorials_2_1_1", bundle: resourceBundle)

    /// The "tutorials_2_1_2" asset catalog image resource.
    static let tutorials212 = ImageResource(name: "tutorials_2_1_2", bundle: resourceBundle)

    /// The "tutorials_2_1_3" asset catalog image resource.
    static let tutorials213 = ImageResource(name: "tutorials_2_1_3", bundle: resourceBundle)

    /// The "tutorials_3_1_1" asset catalog image resource.
    static let tutorials311 = ImageResource(name: "tutorials_3_1_1", bundle: resourceBundle)

    /// The "tutorials_3_1_2" asset catalog image resource.
    static let tutorials312 = ImageResource(name: "tutorials_3_1_2", bundle: resourceBundle)

    /// The "tutorials_3_1_3" asset catalog image resource.
    static let tutorials313 = ImageResource(name: "tutorials_3_1_3", bundle: resourceBundle)

    /// The "tutorials_4_1_1" asset catalog image resource.
    static let tutorials411 = ImageResource(name: "tutorials_4_1_1", bundle: resourceBundle)

    /// The "tutorials_4_1_2" asset catalog image resource.
    static let tutorials412 = ImageResource(name: "tutorials_4_1_2", bundle: resourceBundle)

    /// The "tutorials_4_2_1" asset catalog image resource.
    static let tutorials421 = ImageResource(name: "tutorials_4_2_1", bundle: resourceBundle)

    /// The "tutorials_4_2_2" asset catalog image resource.
    static let tutorials422 = ImageResource(name: "tutorials_4_2_2", bundle: resourceBundle)

    /// The "tutorials_4_2_3" asset catalog image resource.
    static let tutorials423 = ImageResource(name: "tutorials_4_2_3", bundle: resourceBundle)

    /// The "tutorials_4_2_4" asset catalog image resource.
    static let tutorials424 = ImageResource(name: "tutorials_4_2_4", bundle: resourceBundle)

    /// The "tutorials_4_3_1" asset catalog image resource.
    static let tutorials431 = ImageResource(name: "tutorials_4_3_1", bundle: resourceBundle)

    /// The "tutorials_4_3_2" asset catalog image resource.
    static let tutorials432 = ImageResource(name: "tutorials_4_3_2", bundle: resourceBundle)

    /// The "tutorials_5_1_1" asset catalog image resource.
    static let tutorials511 = ImageResource(name: "tutorials_5_1_1", bundle: resourceBundle)

    /// The "tutorials_5_1_2" asset catalog image resource.
    static let tutorials512 = ImageResource(name: "tutorials_5_1_2", bundle: resourceBundle)

    /// The "tutorials_add_icon" asset catalog image resource.
    static let tutorialsAddIcon = ImageResource(name: "tutorials_add_icon", bundle: resourceBundle)

    /// The "tutorials_down_arrow_icon" asset catalog image resource.
    static let tutorialsDownArrowIcon = ImageResource(name: "tutorials_down_arrow_icon", bundle: resourceBundle)

    /// The "tutorials_eat_icon" asset catalog image resource.
    static let tutorialsEatIcon = ImageResource(name: "tutorials_eat_icon", bundle: resourceBundle)

    /// The "tutorials_edit_icon" asset catalog image resource.
    static let tutorialsEditIcon = ImageResource(name: "tutorials_edit_icon", bundle: resourceBundle)

    /// The "tutorials_plan_list_icon" asset catalog image resource.
    static let tutorialsPlanListIcon = ImageResource(name: "tutorials_plan_list_icon", bundle: resourceBundle)

    /// The "tutorials_setting_icon" asset catalog image resource.
    static let tutorialsSettingIcon = ImageResource(name: "tutorials_setting_icon", bundle: resourceBundle)

    /// The "tutorials_share_icon" asset catalog image resource.
    static let tutorialsShareIcon = ImageResource(name: "tutorials_share_icon", bundle: resourceBundle)

    /// The "tutorials_share_icon_theme" asset catalog image resource.
    static let tutorialsShareIconTheme = ImageResource(name: "tutorials_share_icon_theme", bundle: resourceBundle)

    /// The "tutorials_step_1" asset catalog image resource.
    static let tutorialsStep1 = ImageResource(name: "tutorials_step_1", bundle: resourceBundle)

    /// The "tutorials_step_2" asset catalog image resource.
    static let tutorialsStep2 = ImageResource(name: "tutorials_step_2", bundle: resourceBundle)

    /// The "tutorials_step_3" asset catalog image resource.
    static let tutorialsStep3 = ImageResource(name: "tutorials_step_3", bundle: resourceBundle)

    /// The "tutorials_step_4" asset catalog image resource.
    static let tutorialsStep4 = ImageResource(name: "tutorials_step_4", bundle: resourceBundle)

    /// The "tutorials_step_5" asset catalog image resource.
    static let tutorialsStep5 = ImageResource(name: "tutorials_step_5", bundle: resourceBundle)

    /// The "video_edit_album_icon" asset catalog image resource.
    static let videoEditAlbumIcon = ImageResource(name: "video_edit_album_icon", bundle: resourceBundle)

    /// The "video_pause_icon" asset catalog image resource.
    static let videoPauseIcon = ImageResource(name: "video_pause_icon", bundle: resourceBundle)

    /// The "video_pause_icon_1" asset catalog image resource.
    static let videoPauseIcon1 = ImageResource(name: "video_pause_icon_1", bundle: resourceBundle)

    /// The "video_pause_icon_landscap" asset catalog image resource.
    static let videoPauseIconLandscap = ImageResource(name: "video_pause_icon_landscap", bundle: resourceBundle)

    /// The "video_pause_icon_landscap_1" asset catalog image resource.
    static let videoPauseIconLandscap1 = ImageResource(name: "video_pause_icon_landscap_1", bundle: resourceBundle)

    /// The "video_play_icon" asset catalog image resource.
    static let videoPlayIcon = ImageResource(name: "video_play_icon", bundle: resourceBundle)

    /// The "video_play_icon_1" asset catalog image resource.
    static let videoPlayIcon1 = ImageResource(name: "video_play_icon_1", bundle: resourceBundle)

    /// The "video_play_icon_landscap" asset catalog image resource.
    static let videoPlayIconLandscap = ImageResource(name: "video_play_icon_landscap", bundle: resourceBundle)

    /// The "video_play_icon_landscap_1" asset catalog image resource.
    static let videoPlayIconLandscap1 = ImageResource(name: "video_play_icon_landscap_1", bundle: resourceBundle)

    /// The "welcome_logo_icon" asset catalog image resource.
    static let welcomeLogoIcon = ImageResource(name: "welcome_logo_icon", bundle: resourceBundle)

    /// The "widget_bg_bottom" asset catalog image resource.
    static let widgetBgBottom = ImageResource(name: "widget_bg_bottom", bundle: resourceBundle)

    /// The "withdraw_bank_icon" asset catalog image resource.
    static let withdrawBankIcon = ImageResource(name: "withdraw_bank_icon", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "WidgetBackground" asset catalog color.
    static var widgetBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .widgetBackground)
#else
        .init()
#endif
    }

    /// The "black_color_01" asset catalog color.
    static var blackColor01: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .blackColor01)
#else
        .init()
#endif
    }

    /// The "color_alert_bg_black" asset catalog color.
    static var colorAlertBgBlack: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorAlertBgBlack)
#else
        .init()
#endif
    }

    /// The "color_bg_black" asset catalog color.
    static var colorBgBlack: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgBlack)
#else
        .init()
#endif
    }

    /// The "color_bg_c4" asset catalog color.
    static var colorBgC4: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgC4)
#else
        .init()
#endif
    }

    /// The "color_bg_e8" asset catalog color.
    static var colorBgE8: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgE8)
#else
        .init()
#endif
    }

    /// The "color_bg_ef" asset catalog color.
    static var colorBgEf: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgEf)
#else
        .init()
#endif
    }

    /// The "color_bg_f2" asset catalog color.
    static var colorBgF2: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgF2)
#else
        .init()
#endif
    }

    /// The "color_bg_f5" asset catalog color.
    static var colorBgF5: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgF5)
#else
        .init()
#endif
    }

    /// The "color_bg_f5_course_list_end" asset catalog color.
    static var colorBgF5CourseListEnd: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgF5CourseListEnd)
#else
        .init()
#endif
    }

    /// The "color_bg_f5_course_list_start" asset catalog color.
    static var colorBgF5CourseListStart: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgF5CourseListStart)
#else
        .init()
#endif
    }

    /// The "color_bg_f5_fitness_bg" asset catalog color.
    static var colorBgF5FitnessBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgF5FitnessBg)
#else
        .init()
#endif
    }

    /// The "color_bg_f5_segment" asset catalog color.
    static var colorBgF5Segment: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgF5Segment)
#else
        .init()
#endif
    }

    /// The "color_bg_fa" asset catalog color.
    static var colorBgFa: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgFa)
#else
        .init()
#endif
    }

    /// The "color_bg_theme" asset catalog color.
    static var colorBgTheme: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgTheme)
#else
        .init()
#endif
    }

    /// The "color_bg_theme_share" asset catalog color.
    static var colorBgThemeShare: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgThemeShare)
#else
        .init()
#endif
    }

    /// The "color_bg_white" asset catalog color.
    static var colorBgWhite: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgWhite)
#else
        .init()
#endif
    }

    /// The "color_bg_white_95" asset catalog color.
    static var colorBgWhite95: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgWhite95)
#else
        .init()
#endif
    }

    /// The "color_bg_white_lequid_seg" asset catalog color.
    static var colorBgWhiteLequidSeg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBgWhiteLequidSeg)
#else
        .init()
#endif
    }

    /// The "color_black_04" asset catalog color.
    static var colorBlack04: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBlack04)
#else
        .init()
#endif
    }

    /// The "color_black_045" asset catalog color.
    static var colorBlack045: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBlack045)
#else
        .init()
#endif
    }

    /// The "color_black_04_goal_bg" asset catalog color.
    static var colorBlack04GoalBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBlack04GoalBg)
#else
        .init()
#endif
    }

    /// The "color_black_06" asset catalog color.
    static var colorBlack06: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBlack06)
#else
        .init()
#endif
    }

    /// The "color_black_15" asset catalog color.
    static var colorBlack15: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBlack15)
#else
        .init()
#endif
    }

    /// The "color_black_30" asset catalog color.
    static var colorBlack30: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBlack30)
#else
        .init()
#endif
    }

    /// The "color_black_40" asset catalog color.
    static var colorBlack40: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBlack40)
#else
        .init()
#endif
    }

    /// The "color_black_65" asset catalog color.
    static var colorBlack65: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorBlack65)
#else
        .init()
#endif
    }

    /// The "color_button_disable_bg" asset catalog color.
    static var colorButtonDisableBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorButtonDisableBg)
#else
        .init()
#endif
    }

    /// The "color_card_bg_alert" asset catalog color.
    static var colorCardBgAlert: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorCardBgAlert)
#else
        .init()
#endif
    }

    /// The "color_card_bg_clear" asset catalog color.
    static var colorCardBgClear: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorCardBgClear)
#else
        .init()
#endif
    }

    /// The "color_card_bg_f5_comment_func" asset catalog color.
    static var colorCardBgF5CommentFunc: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorCardBgF5CommentFunc)
#else
        .init()
#endif
    }

    /// The "color_card_bg_f5_guide" asset catalog color.
    static var colorCardBgF5Guide: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorCardBgF5Guide)
#else
        .init()
#endif
    }

    /// The "color_card_bg_ff" asset catalog color.
    static var colorCardBgFf: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorCardBgFf)
#else
        .init()
#endif
    }

    /// The "color_card_bg_sport_category" asset catalog color.
    static var colorCardBgSportCategory: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorCardBgSportCategory)
#else
        .init()
#endif
    }

    /// The "color_cell_current_bg" asset catalog color.
    static var colorCellCurrentBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorCellCurrentBg)
#else
        .init()
#endif
    }

    /// The "color_habit_item_img_bg" asset catalog color.
    static var colorHabitItemImgBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorHabitItemImgBg)
#else
        .init()
#endif
    }

    /// The "color_line_f0" asset catalog color.
    static var colorLineF0: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorLineF0)
#else
        .init()
#endif
    }

    /// The "color_line_f0_30" asset catalog color.
    static var colorLineF030: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorLineF030)
#else
        .init()
#endif
    }

    /// The "color_natural_calories" asset catalog color.
    static var colorNaturalCalories: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorNaturalCalories)
#else
        .init()
#endif
    }

    /// The "color_natural_carbo" asset catalog color.
    static var colorNaturalCarbo: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorNaturalCarbo)
#else
        .init()
#endif
    }

    /// The "color_natural_fat" asset catalog color.
    static var colorNaturalFat: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorNaturalFat)
#else
        .init()
#endif
    }

    /// The "color_natural_protein" asset catalog color.
    static var colorNaturalProtein: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorNaturalProtein)
#else
        .init()
#endif
    }

    /// The "color_natural_theme_white" asset catalog color.
    static var colorNaturalThemeWhite: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorNaturalThemeWhite)
#else
        .init()
#endif
    }

    /// The "color_sex_femal" asset catalog color.
    static var colorSexFemal: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorSexFemal)
#else
        .init()
#endif
    }

    /// The "color_share_msg_bg" asset catalog color.
    static var colorShareMsgBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorShareMsgBg)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214" asset catalog color.
    static var colorText0F1214: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F1214)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_03" asset catalog color.
    static var colorText0F121403: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121403)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_05" asset catalog color.
    static var colorText0F121405: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121405)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_06" asset catalog color.
    static var colorText0F121406: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121406)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_10" asset catalog color.
    static var colorText0F121410: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121410)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_20" asset catalog color.
    static var colorText0F121420: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121420)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_25" asset catalog color.
    static var colorText0F121425: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121425)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_30" asset catalog color.
    static var colorText0F121430: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121430)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_35" asset catalog color.
    static var colorText0F121435: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121435)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_50" asset catalog color.
    static var colorText0F121450: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121450)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_60" asset catalog color.
    static var colorText0F121460: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F121460)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_tabbar" asset catalog color.
    static var colorText0F1214Tabbar: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorText0F1214Tabbar)
#else
        .init()
#endif
    }

    /// The "color_text_main_calories" asset catalog color.
    static var colorTextMainCalories: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorTextMainCalories)
#else
        .init()
#endif
    }

    /// The "color_text_main_line" asset catalog color.
    static var colorTextMainLine: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorTextMainLine)
#else
        .init()
#endif
    }

    /// The "color_text_main_natural" asset catalog color.
    static var colorTextMainNatural: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorTextMainNatural)
#else
        .init()
#endif
    }

    /// The "color_text_main_natural_over" asset catalog color.
    static var colorTextMainNaturalOver: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorTextMainNaturalOver)
#else
        .init()
#endif
    }

    /// The "color_text_white" asset catalog color.
    static var colorTextWhite: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorTextWhite)
#else
        .init()
#endif
    }

    /// The "color_text_white_d234_50" asset catalog color.
    static var colorTextWhiteD23450: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorTextWhiteD23450)
#else
        .init()
#endif
    }

    /// The "color_white_04" asset catalog color.
    static var colorWhite04: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorWhite04)
#else
        .init()
#endif
    }

    /// The "color_white_20_pro" asset catalog color.
    static var colorWhite20Pro: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorWhite20Pro)
#else
        .init()
#endif
    }

    /// The "color_white_20_pro_border" asset catalog color.
    static var colorWhite20ProBorder: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorWhite20ProBorder)
#else
        .init()
#endif
    }

    /// The "color_white_20_pro_select" asset catalog color.
    static var colorWhite20ProSelect: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorWhite20ProSelect)
#else
        .init()
#endif
    }

    /// The "color_white_45" asset catalog color.
    static var colorWhite45: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorWhite45)
#else
        .init()
#endif
    }

    /// The "color_white_65" asset catalog color.
    static var colorWhite65: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorWhite65)
#else
        .init()
#endif
    }

    /// The "color_white_75" asset catalog color.
    static var colorWhite75: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .colorWhite75)
#else
        .init()
#endif
    }

    /// The "text_color_06" asset catalog color.
    static var textColor06: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textColor06)
#else
        .init()
#endif
    }

    /// The "text_color_45" asset catalog color.
    static var textColor45: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textColor45)
#else
        .init()
#endif
    }

    /// The "text_color_65" asset catalog color.
    static var textColor65: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textColor65)
#else
        .init()
#endif
    }

    /// The "text_color_85" asset catalog color.
    static var textColor85: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textColor85)
#else
        .init()
#endif
    }

    /// The "white_color_85" asset catalog color.
    static var whiteColor85: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .whiteColor85)
#else
        .init()
#endif
    }

    /// The "widget_bg_color" asset catalog color.
    static var widgetBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .widgetBg)
#else
        .init()
#endif
    }

    /// The "widget_text_color" asset catalog color.
    static var widgetText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .widgetText)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "WidgetBackground" asset catalog color.
    static var widgetBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .widgetBackground)
#else
        .init()
#endif
    }

    /// The "black_color_01" asset catalog color.
    static var blackColor01: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .blackColor01)
#else
        .init()
#endif
    }

    /// The "color_alert_bg_black" asset catalog color.
    static var colorAlertBgBlack: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorAlertBgBlack)
#else
        .init()
#endif
    }

    /// The "color_bg_black" asset catalog color.
    static var colorBgBlack: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgBlack)
#else
        .init()
#endif
    }

    /// The "color_bg_c4" asset catalog color.
    static var colorBgC4: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgC4)
#else
        .init()
#endif
    }

    /// The "color_bg_e8" asset catalog color.
    static var colorBgE8: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgE8)
#else
        .init()
#endif
    }

    /// The "color_bg_ef" asset catalog color.
    static var colorBgEf: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgEf)
#else
        .init()
#endif
    }

    /// The "color_bg_f2" asset catalog color.
    static var colorBgF2: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgF2)
#else
        .init()
#endif
    }

    /// The "color_bg_f5" asset catalog color.
    static var colorBgF5: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgF5)
#else
        .init()
#endif
    }

    /// The "color_bg_f5_course_list_end" asset catalog color.
    static var colorBgF5CourseListEnd: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgF5CourseListEnd)
#else
        .init()
#endif
    }

    /// The "color_bg_f5_course_list_start" asset catalog color.
    static var colorBgF5CourseListStart: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgF5CourseListStart)
#else
        .init()
#endif
    }

    /// The "color_bg_f5_fitness_bg" asset catalog color.
    static var colorBgF5FitnessBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgF5FitnessBg)
#else
        .init()
#endif
    }

    /// The "color_bg_f5_segment" asset catalog color.
    static var colorBgF5Segment: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgF5Segment)
#else
        .init()
#endif
    }

    /// The "color_bg_fa" asset catalog color.
    static var colorBgFa: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgFa)
#else
        .init()
#endif
    }

    /// The "color_bg_theme" asset catalog color.
    static var colorBgTheme: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgTheme)
#else
        .init()
#endif
    }

    /// The "color_bg_theme_share" asset catalog color.
    static var colorBgThemeShare: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgThemeShare)
#else
        .init()
#endif
    }

    /// The "color_bg_white" asset catalog color.
    static var colorBgWhite: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgWhite)
#else
        .init()
#endif
    }

    /// The "color_bg_white_95" asset catalog color.
    static var colorBgWhite95: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgWhite95)
#else
        .init()
#endif
    }

    /// The "color_bg_white_lequid_seg" asset catalog color.
    static var colorBgWhiteLequidSeg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBgWhiteLequidSeg)
#else
        .init()
#endif
    }

    /// The "color_black_04" asset catalog color.
    static var colorBlack04: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBlack04)
#else
        .init()
#endif
    }

    /// The "color_black_045" asset catalog color.
    static var colorBlack045: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBlack045)
#else
        .init()
#endif
    }

    /// The "color_black_04_goal_bg" asset catalog color.
    static var colorBlack04GoalBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBlack04GoalBg)
#else
        .init()
#endif
    }

    /// The "color_black_06" asset catalog color.
    static var colorBlack06: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBlack06)
#else
        .init()
#endif
    }

    /// The "color_black_15" asset catalog color.
    static var colorBlack15: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBlack15)
#else
        .init()
#endif
    }

    /// The "color_black_30" asset catalog color.
    static var colorBlack30: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBlack30)
#else
        .init()
#endif
    }

    /// The "color_black_40" asset catalog color.
    static var colorBlack40: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBlack40)
#else
        .init()
#endif
    }

    /// The "color_black_65" asset catalog color.
    static var colorBlack65: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorBlack65)
#else
        .init()
#endif
    }

    /// The "color_button_disable_bg" asset catalog color.
    static var colorButtonDisableBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorButtonDisableBg)
#else
        .init()
#endif
    }

    /// The "color_card_bg_alert" asset catalog color.
    static var colorCardBgAlert: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorCardBgAlert)
#else
        .init()
#endif
    }

    /// The "color_card_bg_clear" asset catalog color.
    static var colorCardBgClear: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorCardBgClear)
#else
        .init()
#endif
    }

    /// The "color_card_bg_f5_comment_func" asset catalog color.
    static var colorCardBgF5CommentFunc: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorCardBgF5CommentFunc)
#else
        .init()
#endif
    }

    /// The "color_card_bg_f5_guide" asset catalog color.
    static var colorCardBgF5Guide: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorCardBgF5Guide)
#else
        .init()
#endif
    }

    /// The "color_card_bg_ff" asset catalog color.
    static var colorCardBgFf: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorCardBgFf)
#else
        .init()
#endif
    }

    /// The "color_card_bg_sport_category" asset catalog color.
    static var colorCardBgSportCategory: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorCardBgSportCategory)
#else
        .init()
#endif
    }

    /// The "color_cell_current_bg" asset catalog color.
    static var colorCellCurrentBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorCellCurrentBg)
#else
        .init()
#endif
    }

    /// The "color_habit_item_img_bg" asset catalog color.
    static var colorHabitItemImgBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorHabitItemImgBg)
#else
        .init()
#endif
    }

    /// The "color_line_f0" asset catalog color.
    static var colorLineF0: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorLineF0)
#else
        .init()
#endif
    }

    /// The "color_line_f0_30" asset catalog color.
    static var colorLineF030: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorLineF030)
#else
        .init()
#endif
    }

    /// The "color_natural_calories" asset catalog color.
    static var colorNaturalCalories: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorNaturalCalories)
#else
        .init()
#endif
    }

    /// The "color_natural_carbo" asset catalog color.
    static var colorNaturalCarbo: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorNaturalCarbo)
#else
        .init()
#endif
    }

    /// The "color_natural_fat" asset catalog color.
    static var colorNaturalFat: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorNaturalFat)
#else
        .init()
#endif
    }

    /// The "color_natural_protein" asset catalog color.
    static var colorNaturalProtein: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorNaturalProtein)
#else
        .init()
#endif
    }

    /// The "color_natural_theme_white" asset catalog color.
    static var colorNaturalThemeWhite: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorNaturalThemeWhite)
#else
        .init()
#endif
    }

    /// The "color_sex_femal" asset catalog color.
    static var colorSexFemal: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorSexFemal)
#else
        .init()
#endif
    }

    /// The "color_share_msg_bg" asset catalog color.
    static var colorShareMsgBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorShareMsgBg)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214" asset catalog color.
    static var colorText0F1214: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F1214)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_03" asset catalog color.
    static var colorText0F121403: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121403)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_05" asset catalog color.
    static var colorText0F121405: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121405)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_06" asset catalog color.
    static var colorText0F121406: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121406)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_10" asset catalog color.
    static var colorText0F121410: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121410)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_20" asset catalog color.
    static var colorText0F121420: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121420)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_25" asset catalog color.
    static var colorText0F121425: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121425)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_30" asset catalog color.
    static var colorText0F121430: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121430)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_35" asset catalog color.
    static var colorText0F121435: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121435)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_50" asset catalog color.
    static var colorText0F121450: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121450)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_60" asset catalog color.
    static var colorText0F121460: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F121460)
#else
        .init()
#endif
    }

    /// The "color_text_0f1214_tabbar" asset catalog color.
    static var colorText0F1214Tabbar: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorText0F1214Tabbar)
#else
        .init()
#endif
    }

    /// The "color_text_main_calories" asset catalog color.
    static var colorTextMainCalories: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorTextMainCalories)
#else
        .init()
#endif
    }

    /// The "color_text_main_line" asset catalog color.
    static var colorTextMainLine: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorTextMainLine)
#else
        .init()
#endif
    }

    /// The "color_text_main_natural" asset catalog color.
    static var colorTextMainNatural: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorTextMainNatural)
#else
        .init()
#endif
    }

    /// The "color_text_main_natural_over" asset catalog color.
    static var colorTextMainNaturalOver: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorTextMainNaturalOver)
#else
        .init()
#endif
    }

    /// The "color_text_white" asset catalog color.
    static var colorTextWhite: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorTextWhite)
#else
        .init()
#endif
    }

    /// The "color_text_white_d234_50" asset catalog color.
    static var colorTextWhiteD23450: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorTextWhiteD23450)
#else
        .init()
#endif
    }

    /// The "color_white_04" asset catalog color.
    static var colorWhite04: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorWhite04)
#else
        .init()
#endif
    }

    /// The "color_white_20_pro" asset catalog color.
    static var colorWhite20Pro: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorWhite20Pro)
#else
        .init()
#endif
    }

    /// The "color_white_20_pro_border" asset catalog color.
    static var colorWhite20ProBorder: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorWhite20ProBorder)
#else
        .init()
#endif
    }

    /// The "color_white_20_pro_select" asset catalog color.
    static var colorWhite20ProSelect: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorWhite20ProSelect)
#else
        .init()
#endif
    }

    /// The "color_white_45" asset catalog color.
    static var colorWhite45: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorWhite45)
#else
        .init()
#endif
    }

    /// The "color_white_65" asset catalog color.
    static var colorWhite65: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorWhite65)
#else
        .init()
#endif
    }

    /// The "color_white_75" asset catalog color.
    static var colorWhite75: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .colorWhite75)
#else
        .init()
#endif
    }

    /// The "text_color_06" asset catalog color.
    static var textColor06: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textColor06)
#else
        .init()
#endif
    }

    /// The "text_color_45" asset catalog color.
    static var textColor45: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textColor45)
#else
        .init()
#endif
    }

    /// The "text_color_65" asset catalog color.
    static var textColor65: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textColor65)
#else
        .init()
#endif
    }

    /// The "text_color_85" asset catalog color.
    static var textColor85: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textColor85)
#else
        .init()
#endif
    }

    /// The "white_color_85" asset catalog color.
    static var whiteColor85: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .whiteColor85)
#else
        .init()
#endif
    }

    /// The "widget_bg_color" asset catalog color.
    static var widgetBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .widgetBg)
#else
        .init()
#endif
    }

    /// The "widget_text_color" asset catalog color.
    static var widgetText: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .widgetText)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// The "WidgetBackground" asset catalog color.
    static var widgetBackground: SwiftUI.Color { .init(.widgetBackground) }

    /// The "black_color_01" asset catalog color.
    static var blackColor01: SwiftUI.Color { .init(.blackColor01) }

    /// The "color_alert_bg_black" asset catalog color.
    static var colorAlertBgBlack: SwiftUI.Color { .init(.colorAlertBgBlack) }

    /// The "color_bg_black" asset catalog color.
    static var colorBgBlack: SwiftUI.Color { .init(.colorBgBlack) }

    /// The "color_bg_c4" asset catalog color.
    static var colorBgC4: SwiftUI.Color { .init(.colorBgC4) }

    /// The "color_bg_e8" asset catalog color.
    static var colorBgE8: SwiftUI.Color { .init(.colorBgE8) }

    /// The "color_bg_ef" asset catalog color.
    static var colorBgEf: SwiftUI.Color { .init(.colorBgEf) }

    /// The "color_bg_f2" asset catalog color.
    static var colorBgF2: SwiftUI.Color { .init(.colorBgF2) }

    /// The "color_bg_f5" asset catalog color.
    static var colorBgF5: SwiftUI.Color { .init(.colorBgF5) }

    /// The "color_bg_f5_course_list_end" asset catalog color.
    static var colorBgF5CourseListEnd: SwiftUI.Color { .init(.colorBgF5CourseListEnd) }

    /// The "color_bg_f5_course_list_start" asset catalog color.
    static var colorBgF5CourseListStart: SwiftUI.Color { .init(.colorBgF5CourseListStart) }

    /// The "color_bg_f5_fitness_bg" asset catalog color.
    static var colorBgF5FitnessBg: SwiftUI.Color { .init(.colorBgF5FitnessBg) }

    /// The "color_bg_f5_segment" asset catalog color.
    static var colorBgF5Segment: SwiftUI.Color { .init(.colorBgF5Segment) }

    /// The "color_bg_fa" asset catalog color.
    static var colorBgFa: SwiftUI.Color { .init(.colorBgFa) }

    /// The "color_bg_theme" asset catalog color.
    static var colorBgTheme: SwiftUI.Color { .init(.colorBgTheme) }

    /// The "color_bg_theme_share" asset catalog color.
    static var colorBgThemeShare: SwiftUI.Color { .init(.colorBgThemeShare) }

    /// The "color_bg_white" asset catalog color.
    static var colorBgWhite: SwiftUI.Color { .init(.colorBgWhite) }

    /// The "color_bg_white_95" asset catalog color.
    static var colorBgWhite95: SwiftUI.Color { .init(.colorBgWhite95) }

    /// The "color_bg_white_lequid_seg" asset catalog color.
    static var colorBgWhiteLequidSeg: SwiftUI.Color { .init(.colorBgWhiteLequidSeg) }

    /// The "color_black_04" asset catalog color.
    static var colorBlack04: SwiftUI.Color { .init(.colorBlack04) }

    /// The "color_black_045" asset catalog color.
    static var colorBlack045: SwiftUI.Color { .init(.colorBlack045) }

    /// The "color_black_04_goal_bg" asset catalog color.
    static var colorBlack04GoalBg: SwiftUI.Color { .init(.colorBlack04GoalBg) }

    /// The "color_black_06" asset catalog color.
    static var colorBlack06: SwiftUI.Color { .init(.colorBlack06) }

    /// The "color_black_15" asset catalog color.
    static var colorBlack15: SwiftUI.Color { .init(.colorBlack15) }

    /// The "color_black_30" asset catalog color.
    static var colorBlack30: SwiftUI.Color { .init(.colorBlack30) }

    /// The "color_black_40" asset catalog color.
    static var colorBlack40: SwiftUI.Color { .init(.colorBlack40) }

    /// The "color_black_65" asset catalog color.
    static var colorBlack65: SwiftUI.Color { .init(.colorBlack65) }

    /// The "color_button_disable_bg" asset catalog color.
    static var colorButtonDisableBg: SwiftUI.Color { .init(.colorButtonDisableBg) }

    /// The "color_card_bg_alert" asset catalog color.
    static var colorCardBgAlert: SwiftUI.Color { .init(.colorCardBgAlert) }

    /// The "color_card_bg_clear" asset catalog color.
    static var colorCardBgClear: SwiftUI.Color { .init(.colorCardBgClear) }

    /// The "color_card_bg_f5_comment_func" asset catalog color.
    static var colorCardBgF5CommentFunc: SwiftUI.Color { .init(.colorCardBgF5CommentFunc) }

    /// The "color_card_bg_f5_guide" asset catalog color.
    static var colorCardBgF5Guide: SwiftUI.Color { .init(.colorCardBgF5Guide) }

    /// The "color_card_bg_ff" asset catalog color.
    static var colorCardBgFf: SwiftUI.Color { .init(.colorCardBgFf) }

    /// The "color_card_bg_sport_category" asset catalog color.
    static var colorCardBgSportCategory: SwiftUI.Color { .init(.colorCardBgSportCategory) }

    /// The "color_cell_current_bg" asset catalog color.
    static var colorCellCurrentBg: SwiftUI.Color { .init(.colorCellCurrentBg) }

    /// The "color_habit_item_img_bg" asset catalog color.
    static var colorHabitItemImgBg: SwiftUI.Color { .init(.colorHabitItemImgBg) }

    /// The "color_line_f0" asset catalog color.
    static var colorLineF0: SwiftUI.Color { .init(.colorLineF0) }

    /// The "color_line_f0_30" asset catalog color.
    static var colorLineF030: SwiftUI.Color { .init(.colorLineF030) }

    /// The "color_natural_calories" asset catalog color.
    static var colorNaturalCalories: SwiftUI.Color { .init(.colorNaturalCalories) }

    /// The "color_natural_carbo" asset catalog color.
    static var colorNaturalCarbo: SwiftUI.Color { .init(.colorNaturalCarbo) }

    /// The "color_natural_fat" asset catalog color.
    static var colorNaturalFat: SwiftUI.Color { .init(.colorNaturalFat) }

    /// The "color_natural_protein" asset catalog color.
    static var colorNaturalProtein: SwiftUI.Color { .init(.colorNaturalProtein) }

    /// The "color_natural_theme_white" asset catalog color.
    static var colorNaturalThemeWhite: SwiftUI.Color { .init(.colorNaturalThemeWhite) }

    /// The "color_sex_femal" asset catalog color.
    static var colorSexFemal: SwiftUI.Color { .init(.colorSexFemal) }

    /// The "color_share_msg_bg" asset catalog color.
    static var colorShareMsgBg: SwiftUI.Color { .init(.colorShareMsgBg) }

    /// The "color_text_0f1214" asset catalog color.
    static var colorText0F1214: SwiftUI.Color { .init(.colorText0F1214) }

    /// The "color_text_0f1214_03" asset catalog color.
    static var colorText0F121403: SwiftUI.Color { .init(.colorText0F121403) }

    /// The "color_text_0f1214_05" asset catalog color.
    static var colorText0F121405: SwiftUI.Color { .init(.colorText0F121405) }

    /// The "color_text_0f1214_06" asset catalog color.
    static var colorText0F121406: SwiftUI.Color { .init(.colorText0F121406) }

    /// The "color_text_0f1214_10" asset catalog color.
    static var colorText0F121410: SwiftUI.Color { .init(.colorText0F121410) }

    /// The "color_text_0f1214_20" asset catalog color.
    static var colorText0F121420: SwiftUI.Color { .init(.colorText0F121420) }

    /// The "color_text_0f1214_25" asset catalog color.
    static var colorText0F121425: SwiftUI.Color { .init(.colorText0F121425) }

    /// The "color_text_0f1214_30" asset catalog color.
    static var colorText0F121430: SwiftUI.Color { .init(.colorText0F121430) }

    /// The "color_text_0f1214_35" asset catalog color.
    static var colorText0F121435: SwiftUI.Color { .init(.colorText0F121435) }

    /// The "color_text_0f1214_50" asset catalog color.
    static var colorText0F121450: SwiftUI.Color { .init(.colorText0F121450) }

    /// The "color_text_0f1214_60" asset catalog color.
    static var colorText0F121460: SwiftUI.Color { .init(.colorText0F121460) }

    /// The "color_text_0f1214_tabbar" asset catalog color.
    static var colorText0F1214Tabbar: SwiftUI.Color { .init(.colorText0F1214Tabbar) }

    /// The "color_text_main_calories" asset catalog color.
    static var colorTextMainCalories: SwiftUI.Color { .init(.colorTextMainCalories) }

    /// The "color_text_main_line" asset catalog color.
    static var colorTextMainLine: SwiftUI.Color { .init(.colorTextMainLine) }

    /// The "color_text_main_natural" asset catalog color.
    static var colorTextMainNatural: SwiftUI.Color { .init(.colorTextMainNatural) }

    /// The "color_text_main_natural_over" asset catalog color.
    static var colorTextMainNaturalOver: SwiftUI.Color { .init(.colorTextMainNaturalOver) }

    /// The "color_text_white" asset catalog color.
    static var colorTextWhite: SwiftUI.Color { .init(.colorTextWhite) }

    /// The "color_text_white_d234_50" asset catalog color.
    static var colorTextWhiteD23450: SwiftUI.Color { .init(.colorTextWhiteD23450) }

    /// The "color_white_04" asset catalog color.
    static var colorWhite04: SwiftUI.Color { .init(.colorWhite04) }

    /// The "color_white_20_pro" asset catalog color.
    static var colorWhite20Pro: SwiftUI.Color { .init(.colorWhite20Pro) }

    /// The "color_white_20_pro_border" asset catalog color.
    static var colorWhite20ProBorder: SwiftUI.Color { .init(.colorWhite20ProBorder) }

    /// The "color_white_20_pro_select" asset catalog color.
    static var colorWhite20ProSelect: SwiftUI.Color { .init(.colorWhite20ProSelect) }

    /// The "color_white_45" asset catalog color.
    static var colorWhite45: SwiftUI.Color { .init(.colorWhite45) }

    /// The "color_white_65" asset catalog color.
    static var colorWhite65: SwiftUI.Color { .init(.colorWhite65) }

    /// The "color_white_75" asset catalog color.
    static var colorWhite75: SwiftUI.Color { .init(.colorWhite75) }

    /// The "text_color_06" asset catalog color.
    static var textColor06: SwiftUI.Color { .init(.textColor06) }

    /// The "text_color_45" asset catalog color.
    static var textColor45: SwiftUI.Color { .init(.textColor45) }

    /// The "text_color_65" asset catalog color.
    static var textColor65: SwiftUI.Color { .init(.textColor65) }

    /// The "text_color_85" asset catalog color.
    static var textColor85: SwiftUI.Color { .init(.textColor85) }

    /// The "white_color_85" asset catalog color.
    static var whiteColor85: SwiftUI.Color { .init(.whiteColor85) }

    /// The "widget_bg_color" asset catalog color.
    static var widgetBg: SwiftUI.Color { .init(.widgetBg) }

    /// The "widget_text_color" asset catalog color.
    static var widgetText: SwiftUI.Color { .init(.widgetText) }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "WidgetBackground" asset catalog color.
    static var widgetBackground: SwiftUI.Color { .init(.widgetBackground) }

    /// The "black_color_01" asset catalog color.
    static var blackColor01: SwiftUI.Color { .init(.blackColor01) }

    /// The "color_alert_bg_black" asset catalog color.
    static var colorAlertBgBlack: SwiftUI.Color { .init(.colorAlertBgBlack) }

    /// The "color_bg_black" asset catalog color.
    static var colorBgBlack: SwiftUI.Color { .init(.colorBgBlack) }

    /// The "color_bg_c4" asset catalog color.
    static var colorBgC4: SwiftUI.Color { .init(.colorBgC4) }

    /// The "color_bg_e8" asset catalog color.
    static var colorBgE8: SwiftUI.Color { .init(.colorBgE8) }

    /// The "color_bg_ef" asset catalog color.
    static var colorBgEf: SwiftUI.Color { .init(.colorBgEf) }

    /// The "color_bg_f2" asset catalog color.
    static var colorBgF2: SwiftUI.Color { .init(.colorBgF2) }

    /// The "color_bg_f5" asset catalog color.
    static var colorBgF5: SwiftUI.Color { .init(.colorBgF5) }

    /// The "color_bg_f5_course_list_end" asset catalog color.
    static var colorBgF5CourseListEnd: SwiftUI.Color { .init(.colorBgF5CourseListEnd) }

    /// The "color_bg_f5_course_list_start" asset catalog color.
    static var colorBgF5CourseListStart: SwiftUI.Color { .init(.colorBgF5CourseListStart) }

    /// The "color_bg_f5_fitness_bg" asset catalog color.
    static var colorBgF5FitnessBg: SwiftUI.Color { .init(.colorBgF5FitnessBg) }

    /// The "color_bg_f5_segment" asset catalog color.
    static var colorBgF5Segment: SwiftUI.Color { .init(.colorBgF5Segment) }

    /// The "color_bg_fa" asset catalog color.
    static var colorBgFa: SwiftUI.Color { .init(.colorBgFa) }

    /// The "color_bg_theme" asset catalog color.
    static var colorBgTheme: SwiftUI.Color { .init(.colorBgTheme) }

    /// The "color_bg_theme_share" asset catalog color.
    static var colorBgThemeShare: SwiftUI.Color { .init(.colorBgThemeShare) }

    /// The "color_bg_white" asset catalog color.
    static var colorBgWhite: SwiftUI.Color { .init(.colorBgWhite) }

    /// The "color_bg_white_95" asset catalog color.
    static var colorBgWhite95: SwiftUI.Color { .init(.colorBgWhite95) }

    /// The "color_bg_white_lequid_seg" asset catalog color.
    static var colorBgWhiteLequidSeg: SwiftUI.Color { .init(.colorBgWhiteLequidSeg) }

    /// The "color_black_04" asset catalog color.
    static var colorBlack04: SwiftUI.Color { .init(.colorBlack04) }

    /// The "color_black_045" asset catalog color.
    static var colorBlack045: SwiftUI.Color { .init(.colorBlack045) }

    /// The "color_black_04_goal_bg" asset catalog color.
    static var colorBlack04GoalBg: SwiftUI.Color { .init(.colorBlack04GoalBg) }

    /// The "color_black_06" asset catalog color.
    static var colorBlack06: SwiftUI.Color { .init(.colorBlack06) }

    /// The "color_black_15" asset catalog color.
    static var colorBlack15: SwiftUI.Color { .init(.colorBlack15) }

    /// The "color_black_30" asset catalog color.
    static var colorBlack30: SwiftUI.Color { .init(.colorBlack30) }

    /// The "color_black_40" asset catalog color.
    static var colorBlack40: SwiftUI.Color { .init(.colorBlack40) }

    /// The "color_black_65" asset catalog color.
    static var colorBlack65: SwiftUI.Color { .init(.colorBlack65) }

    /// The "color_button_disable_bg" asset catalog color.
    static var colorButtonDisableBg: SwiftUI.Color { .init(.colorButtonDisableBg) }

    /// The "color_card_bg_alert" asset catalog color.
    static var colorCardBgAlert: SwiftUI.Color { .init(.colorCardBgAlert) }

    /// The "color_card_bg_clear" asset catalog color.
    static var colorCardBgClear: SwiftUI.Color { .init(.colorCardBgClear) }

    /// The "color_card_bg_f5_comment_func" asset catalog color.
    static var colorCardBgF5CommentFunc: SwiftUI.Color { .init(.colorCardBgF5CommentFunc) }

    /// The "color_card_bg_f5_guide" asset catalog color.
    static var colorCardBgF5Guide: SwiftUI.Color { .init(.colorCardBgF5Guide) }

    /// The "color_card_bg_ff" asset catalog color.
    static var colorCardBgFf: SwiftUI.Color { .init(.colorCardBgFf) }

    /// The "color_card_bg_sport_category" asset catalog color.
    static var colorCardBgSportCategory: SwiftUI.Color { .init(.colorCardBgSportCategory) }

    /// The "color_cell_current_bg" asset catalog color.
    static var colorCellCurrentBg: SwiftUI.Color { .init(.colorCellCurrentBg) }

    /// The "color_habit_item_img_bg" asset catalog color.
    static var colorHabitItemImgBg: SwiftUI.Color { .init(.colorHabitItemImgBg) }

    /// The "color_line_f0" asset catalog color.
    static var colorLineF0: SwiftUI.Color { .init(.colorLineF0) }

    /// The "color_line_f0_30" asset catalog color.
    static var colorLineF030: SwiftUI.Color { .init(.colorLineF030) }

    /// The "color_natural_calories" asset catalog color.
    static var colorNaturalCalories: SwiftUI.Color { .init(.colorNaturalCalories) }

    /// The "color_natural_carbo" asset catalog color.
    static var colorNaturalCarbo: SwiftUI.Color { .init(.colorNaturalCarbo) }

    /// The "color_natural_fat" asset catalog color.
    static var colorNaturalFat: SwiftUI.Color { .init(.colorNaturalFat) }

    /// The "color_natural_protein" asset catalog color.
    static var colorNaturalProtein: SwiftUI.Color { .init(.colorNaturalProtein) }

    /// The "color_natural_theme_white" asset catalog color.
    static var colorNaturalThemeWhite: SwiftUI.Color { .init(.colorNaturalThemeWhite) }

    /// The "color_sex_femal" asset catalog color.
    static var colorSexFemal: SwiftUI.Color { .init(.colorSexFemal) }

    /// The "color_share_msg_bg" asset catalog color.
    static var colorShareMsgBg: SwiftUI.Color { .init(.colorShareMsgBg) }

    /// The "color_text_0f1214" asset catalog color.
    static var colorText0F1214: SwiftUI.Color { .init(.colorText0F1214) }

    /// The "color_text_0f1214_03" asset catalog color.
    static var colorText0F121403: SwiftUI.Color { .init(.colorText0F121403) }

    /// The "color_text_0f1214_05" asset catalog color.
    static var colorText0F121405: SwiftUI.Color { .init(.colorText0F121405) }

    /// The "color_text_0f1214_06" asset catalog color.
    static var colorText0F121406: SwiftUI.Color { .init(.colorText0F121406) }

    /// The "color_text_0f1214_10" asset catalog color.
    static var colorText0F121410: SwiftUI.Color { .init(.colorText0F121410) }

    /// The "color_text_0f1214_20" asset catalog color.
    static var colorText0F121420: SwiftUI.Color { .init(.colorText0F121420) }

    /// The "color_text_0f1214_25" asset catalog color.
    static var colorText0F121425: SwiftUI.Color { .init(.colorText0F121425) }

    /// The "color_text_0f1214_30" asset catalog color.
    static var colorText0F121430: SwiftUI.Color { .init(.colorText0F121430) }

    /// The "color_text_0f1214_35" asset catalog color.
    static var colorText0F121435: SwiftUI.Color { .init(.colorText0F121435) }

    /// The "color_text_0f1214_50" asset catalog color.
    static var colorText0F121450: SwiftUI.Color { .init(.colorText0F121450) }

    /// The "color_text_0f1214_60" asset catalog color.
    static var colorText0F121460: SwiftUI.Color { .init(.colorText0F121460) }

    /// The "color_text_0f1214_tabbar" asset catalog color.
    static var colorText0F1214Tabbar: SwiftUI.Color { .init(.colorText0F1214Tabbar) }

    /// The "color_text_main_calories" asset catalog color.
    static var colorTextMainCalories: SwiftUI.Color { .init(.colorTextMainCalories) }

    /// The "color_text_main_line" asset catalog color.
    static var colorTextMainLine: SwiftUI.Color { .init(.colorTextMainLine) }

    /// The "color_text_main_natural" asset catalog color.
    static var colorTextMainNatural: SwiftUI.Color { .init(.colorTextMainNatural) }

    /// The "color_text_main_natural_over" asset catalog color.
    static var colorTextMainNaturalOver: SwiftUI.Color { .init(.colorTextMainNaturalOver) }

    /// The "color_text_white" asset catalog color.
    static var colorTextWhite: SwiftUI.Color { .init(.colorTextWhite) }

    /// The "color_text_white_d234_50" asset catalog color.
    static var colorTextWhiteD23450: SwiftUI.Color { .init(.colorTextWhiteD23450) }

    /// The "color_white_04" asset catalog color.
    static var colorWhite04: SwiftUI.Color { .init(.colorWhite04) }

    /// The "color_white_20_pro" asset catalog color.
    static var colorWhite20Pro: SwiftUI.Color { .init(.colorWhite20Pro) }

    /// The "color_white_20_pro_border" asset catalog color.
    static var colorWhite20ProBorder: SwiftUI.Color { .init(.colorWhite20ProBorder) }

    /// The "color_white_20_pro_select" asset catalog color.
    static var colorWhite20ProSelect: SwiftUI.Color { .init(.colorWhite20ProSelect) }

    /// The "color_white_45" asset catalog color.
    static var colorWhite45: SwiftUI.Color { .init(.colorWhite45) }

    /// The "color_white_65" asset catalog color.
    static var colorWhite65: SwiftUI.Color { .init(.colorWhite65) }

    /// The "color_white_75" asset catalog color.
    static var colorWhite75: SwiftUI.Color { .init(.colorWhite75) }

    /// The "text_color_06" asset catalog color.
    static var textColor06: SwiftUI.Color { .init(.textColor06) }

    /// The "text_color_45" asset catalog color.
    static var textColor45: SwiftUI.Color { .init(.textColor45) }

    /// The "text_color_65" asset catalog color.
    static var textColor65: SwiftUI.Color { .init(.textColor65) }

    /// The "text_color_85" asset catalog color.
    static var textColor85: SwiftUI.Color { .init(.textColor85) }

    /// The "white_color_85" asset catalog color.
    static var whiteColor85: SwiftUI.Color { .init(.whiteColor85) }

    /// The "widget_bg_color" asset catalog color.
    static var widgetBg: SwiftUI.Color { .init(.widgetBg) }

    /// The "widget_text_color" asset catalog color.
    static var widgetText: SwiftUI.Color { .init(.widgetText) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Image" asset catalog image.
    static var image: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .image)
#else
        .init()
#endif
    }

    /// The "ai_alert_close_icon" asset catalog image.
    static var aiAlertCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiAlertCloseIcon)
#else
        .init()
#endif
    }

    /// The "ai_back_icon" asset catalog image.
    static var aiBackIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiBackIcon)
#else
        .init()
#endif
    }

    /// The "ai_camera_album_icon" asset catalog image.
    static var aiCameraAlbumIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiCameraAlbumIcon)
#else
        .init()
#endif
    }

    /// The "ai_camera_box_foods" asset catalog image.
    static var aiCameraBoxFoods: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiCameraBoxFoods)
#else
        .init()
#endif
    }

    /// The "ai_camera_box_ingredient" asset catalog image.
    static var aiCameraBoxIngredient: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiCameraBoxIngredient)
#else
        .init()
#endif
    }

    /// The "ai_camera_box_ingredient_tran" asset catalog image.
    static var aiCameraBoxIngredientTran: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiCameraBoxIngredientTran)
#else
        .init()
#endif
    }

    /// The "ai_camera_flash_icon" asset catalog image.
    static var aiCameraFlashIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiCameraFlashIcon)
#else
        .init()
#endif
    }

    /// The "ai_camera_flash_normal_icon" asset catalog image.
    static var aiCameraFlashNormalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiCameraFlashNormalIcon)
#else
        .init()
#endif
    }

    /// The "ai_identify_fail_img" asset catalog image.
    static var aiIdentifyFailImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiIdentifyFailImg)
#else
        .init()
#endif
    }

    /// The "ai_photo_take_icon" asset catalog image.
    static var aiPhotoTakeIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiPhotoTakeIcon)
#else
        .init()
#endif
    }

    /// The "ai_progress_cancel_icon" asset catalog image.
    static var aiProgressCancelIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiProgressCancelIcon)
#else
        .init()
#endif
    }

    /// The "ai_progress_complete_icon" asset catalog image.
    static var aiProgressCompleteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiProgressCompleteIcon)
#else
        .init()
#endif
    }

    /// The "ai_tips_alert_error_icon" asset catalog image.
    static var aiTipsAlertErrorIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTipsAlertErrorIcon)
#else
        .init()
#endif
    }

    /// The "ai_tips_alert_error_img" asset catalog image.
    static var aiTipsAlertErrorImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTipsAlertErrorImg)
#else
        .init()
#endif
    }

    /// The "ai_tips_alert_right_icon" asset catalog image.
    static var aiTipsAlertRightIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTipsAlertRightIcon)
#else
        .init()
#endif
    }

    /// The "ai_tips_alert_right_img" asset catalog image.
    static var aiTipsAlertRightImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTipsAlertRightImg)
#else
        .init()
#endif
    }

    /// The "ai_tips_icon" asset catalog image.
    static var aiTipsIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTipsIcon)
#else
        .init()
#endif
    }

    /// The "ai_type_foods_icon" asset catalog image.
    static var aiTypeFoodsIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTypeFoodsIcon)
#else
        .init()
#endif
    }

    /// The "ai_type_foods_normal_icon" asset catalog image.
    static var aiTypeFoodsNormalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTypeFoodsNormalIcon)
#else
        .init()
#endif
    }

    /// The "ai_type_ingredient_icon" asset catalog image.
    static var aiTypeIngredientIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTypeIngredientIcon)
#else
        .init()
#endif
    }

    /// The "ai_type_ingredient_normal_icon" asset catalog image.
    static var aiTypeIngredientNormalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aiTypeIngredientNormalIcon)
#else
        .init()
#endif
    }

    /// The "alert_close_icon" asset catalog image.
    static var alertCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .alertCloseIcon)
#else
        .init()
#endif
    }

    /// The "alert_warning_icon" asset catalog image.
    static var alertWarningIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .alertWarningIcon)
#else
        .init()
#endif
    }

    /// The "arrow_img_down" asset catalog image.
    static var arrowImgDown: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .arrowImgDown)
#else
        .init()
#endif
    }

    /// The "avatar_default" asset catalog image.
    static var avatarDefault: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .avatarDefault)
#else
        .init()
#endif
    }

    /// The "avatar_default_new" asset catalog image.
    static var avatarDefaultNew: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .avatarDefaultNew)
#else
        .init()
#endif
    }

    /// The "back_arrow" asset catalog image.
    static var backArrow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backArrow)
#else
        .init()
#endif
    }

    /// The "back_arrow_highlight" asset catalog image.
    static var backArrowHighlight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backArrowHighlight)
#else
        .init()
#endif
    }

    /// The "back_arrow_white_icon" asset catalog image.
    static var backArrowWhiteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backArrowWhiteIcon)
#else
        .init()
#endif
    }

    /// The "back_arrow_white_icon_light" asset catalog image.
    static var backArrowWhiteIconLight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backArrowWhiteIconLight)
#else
        .init()
#endif
    }

    /// The "back_arrow_white_icon_max" asset catalog image.
    static var backArrowWhiteIconMax: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backArrowWhiteIconMax)
#else
        .init()
#endif
    }

    /// The "back_arrow_white_shadow" asset catalog image.
    static var backArrowWhiteShadow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backArrowWhiteShadow)
#else
        .init()
#endif
    }

    /// The "back_close_icon" asset catalog image.
    static var backCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backCloseIcon)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_1" asset catalog image.
    static var bodyFatFeman1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman1)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_2" asset catalog image.
    static var bodyFatFeman2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman2)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_3" asset catalog image.
    static var bodyFatFeman3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman3)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_4" asset catalog image.
    static var bodyFatFeman4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman4)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_5" asset catalog image.
    static var bodyFatFeman5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman5)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_6" asset catalog image.
    static var bodyFatFeman6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman6)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_7" asset catalog image.
    static var bodyFatFeman7: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman7)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_8" asset catalog image.
    static var bodyFatFeman8: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman8)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_9" asset catalog image.
    static var bodyFatFeman9: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatFeman9)
#else
        .init()
#endif
    }

    /// The "body_fat_img_cover" asset catalog image.
    static var bodyFatImgCover: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatImgCover)
#else
        .init()
#endif
    }

    /// The "body_fat_man_1" asset catalog image.
    static var bodyFatMan1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan1)
#else
        .init()
#endif
    }

    /// The "body_fat_man_2" asset catalog image.
    static var bodyFatMan2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan2)
#else
        .init()
#endif
    }

    /// The "body_fat_man_3" asset catalog image.
    static var bodyFatMan3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan3)
#else
        .init()
#endif
    }

    /// The "body_fat_man_4" asset catalog image.
    static var bodyFatMan4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan4)
#else
        .init()
#endif
    }

    /// The "body_fat_man_5" asset catalog image.
    static var bodyFatMan5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan5)
#else
        .init()
#endif
    }

    /// The "body_fat_man_6" asset catalog image.
    static var bodyFatMan6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan6)
#else
        .init()
#endif
    }

    /// The "body_fat_man_7" asset catalog image.
    static var bodyFatMan7: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan7)
#else
        .init()
#endif
    }

    /// The "body_fat_man_8" asset catalog image.
    static var bodyFatMan8: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan8)
#else
        .init()
#endif
    }

    /// The "body_fat_man_9" asset catalog image.
    static var bodyFatMan9: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatMan9)
#else
        .init()
#endif
    }

    /// The "body_fat_select_icon" asset catalog image.
    static var bodyFatSelectIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bodyFatSelectIcon)
#else
        .init()
#endif
    }

    /// The "bottom_cover_img" asset catalog image.
    static var bottomCoverImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bottomCoverImg)
#else
        .init()
#endif
    }

    /// The "button_bg_white" asset catalog image.
    static var buttonBgWhite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .buttonBgWhite)
#else
        .init()
#endif
    }

    /// The "calories_widget_icon" asset catalog image.
    static var caloriesWidgetIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .caloriesWidgetIcon)
#else
        .init()
#endif
    }

    /// The "cancel_account_normal" asset catalog image.
    static var cancelAccountNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cancelAccountNormal)
#else
        .init()
#endif
    }

    /// The "cancel_account_selected" asset catalog image.
    static var cancelAccountSelected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cancelAccountSelected)
#else
        .init()
#endif
    }

    /// The "cancel_account_tips" asset catalog image.
    static var cancelAccountTips: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cancelAccountTips)
#else
        .init()
#endif
    }

    /// The "circle_change_icon" asset catalog image.
    static var circleChangeIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .circleChangeIcon)
#else
        .init()
#endif
    }

    /// The "circle_days_icon" asset catalog image.
    static var circleDaysIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .circleDaysIcon)
#else
        .init()
#endif
    }

    /// The "circle_today_normal_icon" asset catalog image.
    static var circleTodayNormalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .circleTodayNormalIcon)
#else
        .init()
#endif
    }

    /// The "circle_today_select_icon" asset catalog image.
    static var circleTodaySelectIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .circleTodaySelectIcon)
#else
        .init()
#endif
    }

    /// The "comment_func_copy_icon" asset catalog image.
    static var commentFuncCopyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .commentFuncCopyIcon)
#else
        .init()
#endif
    }

    /// The "comment_func_delete_icon" asset catalog image.
    static var commentFuncDeleteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .commentFuncDeleteIcon)
#else
        .init()
#endif
    }

    /// The "comment_func_report_icon" asset catalog image.
    static var commentFuncReportIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .commentFuncReportIcon)
#else
        .init()
#endif
    }

    /// The "control_widget_icon" asset catalog image.
    static var controlWidgetIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .controlWidgetIcon)
#else
        .init()
#endif
    }

    /// The "course_avtivity_bg" asset catalog image.
    static var courseAvtivityBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseAvtivityBg)
#else
        .init()
#endif
    }

    /// The "course_avtivity_bg_left" asset catalog image.
    static var courseAvtivityBgLeft: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseAvtivityBgLeft)
#else
        .init()
#endif
    }

    /// The "course_avtivity_bg_right" asset catalog image.
    static var courseAvtivityBgRight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseAvtivityBgRight)
#else
        .init()
#endif
    }

    /// The "course_coupon_delete_icon" asset catalog image.
    static var courseCouponDeleteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseCouponDeleteIcon)
#else
        .init()
#endif
    }

    /// The "course_last_close_icon" asset catalog image.
    static var courseLastCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseLastCloseIcon)
#else
        .init()
#endif
    }

    /// The "course_last_play_icon" asset catalog image.
    static var courseLastPlayIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseLastPlayIcon)
#else
        .init()
#endif
    }

    /// The "course_left_arrow_icon" asset catalog image.
    static var courseLeftArrowIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseLeftArrowIcon)
#else
        .init()
#endif
    }

    /// The "course_locked_icon" asset catalog image.
    static var courseLockedIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseLockedIcon)
#else
        .init()
#endif
    }

    /// The "course_number_icon" asset catalog image.
    static var courseNumberIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseNumberIcon)
#else
        .init()
#endif
    }

    /// The "course_order_delete_icon" asset catalog image.
    static var courseOrderDeleteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseOrderDeleteIcon)
#else
        .init()
#endif
    }

    /// The "course_pay_icon" asset catalog image.
    static var coursePayIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePayIcon)
#else
        .init()
#endif
    }

    /// The "course_pay_tips_close_icon" asset catalog image.
    static var coursePayTipsCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePayTipsCloseIcon)
#else
        .init()
#endif
    }

    /// The "course_pay_tips_ela_icon" asset catalog image.
    static var coursePayTipsElaIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePayTipsElaIcon)
#else
        .init()
#endif
    }

    /// The "course_pay_type_alipay" asset catalog image.
    static var coursePayTypeAlipay: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePayTypeAlipay)
#else
        .init()
#endif
    }

    /// The "course_pay_type_normal" asset catalog image.
    static var coursePayTypeNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePayTypeNormal)
#else
        .init()
#endif
    }

    /// The "course_pay_type_select" asset catalog image.
    static var coursePayTypeSelect: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePayTypeSelect)
#else
        .init()
#endif
    }

    /// The "course_pay_type_wechat" asset catalog image.
    static var coursePayTypeWechat: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePayTypeWechat)
#else
        .init()
#endif
    }

    /// The "course_pdf_download_icon" asset catalog image.
    static var coursePdfDownloadIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePdfDownloadIcon)
#else
        .init()
#endif
    }

    /// The "course_play_icon" asset catalog image.
    static var coursePlayIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coursePlayIcon)
#else
        .init()
#endif
    }

    /// The "course_right_arrow_icon" asset catalog image.
    static var courseRightArrowIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseRightArrowIcon)
#else
        .init()
#endif
    }

    /// The "course_share_icon" asset catalog image.
    static var courseShareIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseShareIcon)
#else
        .init()
#endif
    }

    /// The "course_title_avatar_icon" asset catalog image.
    static var courseTitleAvatarIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseTitleAvatarIcon)
#else
        .init()
#endif
    }

    /// The "course_video_play_icon" asset catalog image.
    static var courseVideoPlayIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseVideoPlayIcon)
#else
        .init()
#endif
    }

    /// The "course_video_playing_icon" asset catalog image.
    static var courseVideoPlayingIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .courseVideoPlayingIcon)
#else
        .init()
#endif
    }

    /// The "create_plan_add_foods_icon" asset catalog image.
    static var createPlanAddFoodsIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .createPlanAddFoodsIcon)
#else
        .init()
#endif
    }

    /// The "create_plan_arrow_down" asset catalog image.
    static var createPlanArrowDown: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .createPlanArrowDown)
#else
        .init()
#endif
    }

    /// The "create_plan_name_icon" asset catalog image.
    static var createPlanNameIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .createPlanNameIcon)
#else
        .init()
#endif
    }

    /// The "create_plan_syn_select" asset catalog image.
    static var createPlanSynSelect: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .createPlanSynSelect)
#else
        .init()
#endif
    }

    /// The "create_plan_weeks_icon" asset catalog image.
    static var createPlanWeeksIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .createPlanWeeksIcon)
#else
        .init()
#endif
    }

    /// The "data_add_icon" asset catalog image.
    static var dataAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataAddIcon)
#else
        .init()
#endif
    }

    /// The "data_add_icon_black" asset catalog image.
    static var dataAddIconBlack: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataAddIconBlack)
#else
        .init()
#endif
    }

    /// The "data_asc_icon" asset catalog image.
    static var dataAscIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataAscIcon)
#else
        .init()
#endif
    }

    /// The "data_custom_icon" asset catalog image.
    static var dataCustomIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataCustomIcon)
#else
        .init()
#endif
    }

    /// The "data_desc_icon" asset catalog image.
    static var dataDescIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataDescIcon)
#else
        .init()
#endif
    }

    /// The "data_img_clear_icon" asset catalog image.
    static var dataImgClearIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataImgClearIcon)
#else
        .init()
#endif
    }

    /// The "data_photo_default" asset catalog image.
    static var dataPhotoDefault: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataPhotoDefault)
#else
        .init()
#endif
    }

    /// The "data_ping_icon" asset catalog image.
    static var dataPingIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataPingIcon)
#else
        .init()
#endif
    }

    /// The "data_share_asc_icon" asset catalog image.
    static var dataShareAscIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataShareAscIcon)
#else
        .init()
#endif
    }

    /// The "data_share_bg" asset catalog image.
    static var dataShareBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataShareBg)
#else
        .init()
#endif
    }

    /// The "data_share_desc_icon" asset catalog image.
    static var dataShareDescIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataShareDescIcon)
#else
        .init()
#endif
    }

    /// The "data_share_highlight_circle" asset catalog image.
    static var dataShareHighlightCircle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataShareHighlightCircle)
#else
        .init()
#endif
    }

    /// The "data_share_ping_icon" asset catalog image.
    static var dataSharePingIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataSharePingIcon)
#else
        .init()
#endif
    }

    /// The "date_fliter_cancel_img" asset catalog image.
    static var dateFliterCancelImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dateFliterCancelImg)
#else
        .init()
#endif
    }

    /// The "date_fliter_confirm_img" asset catalog image.
    static var dateFliterConfirmImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dateFliterConfirmImg)
#else
        .init()
#endif
    }

    /// The "dietplan_bg_img" asset catalog image.
    static var dietplanBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dietplanBgImg)
#else
        .init()
#endif
    }

    /// The "dietplan_empty_img" asset catalog image.
    static var dietplanEmptyImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dietplanEmptyImg)
#else
        .init()
#endif
    }

    /// The "dietplan_pro_icon" asset catalog image.
    static var dietplanProIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dietplanProIcon)
#else
        .init()
#endif
    }

    /// The "donation_baby_img" asset catalog image.
    static var donationBabyImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationBabyImg)
#else
        .init()
#endif
    }

    /// The "donation_bg_img" asset catalog image.
    static var donationBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationBgImg)
#else
        .init()
#endif
    }

    /// The "donation_cell_bottom" asset catalog image.
    static var donationCellBottom: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationCellBottom)
#else
        .init()
#endif
    }

    /// The "donation_date_bg" asset catalog image.
    static var donationDateBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationDateBg)
#else
        .init()
#endif
    }

    /// The "donation_date_circle_icon" asset catalog image.
    static var donationDateCircleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationDateCircleIcon)
#else
        .init()
#endif
    }

    /// The "donation_empty_icon_1" asset catalog image.
    static var donationEmptyIcon1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationEmptyIcon1)
#else
        .init()
#endif
    }

    /// The "donation_empty_icon_2" asset catalog image.
    static var donationEmptyIcon2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationEmptyIcon2)
#else
        .init()
#endif
    }

    /// The "donation_juanzeng_text" asset catalog image.
    static var donationJuanzengText: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationJuanzengText)
#else
        .init()
#endif
    }

    /// The "donation_text_img" asset catalog image.
    static var donationTextImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationTextImg)
#else
        .init()
#endif
    }

    /// The "donation_top_logo" asset catalog image.
    static var donationTopLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationTopLogo)
#else
        .init()
#endif
    }

    /// The "ela_clear_icon" asset catalog image.
    static var elaClearIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaClearIcon)
#else
        .init()
#endif
    }

    /// The "ela_icon_img" asset catalog image.
    static var elaIconImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaIconImg)
#else
        .init()
#endif
    }

    /// The "ela_price_per_bg" asset catalog image.
    static var elaPricePerBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaPricePerBg)
#else
        .init()
#endif
    }

    /// The "ela_pro_2_bg" asset catalog image.
    static var elaPro2Bg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaPro2Bg)
#else
        .init()
#endif
    }

    /// The "ela_pro_4_bg" asset catalog image.
    static var elaPro4Bg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaPro4Bg)
#else
        .init()
#endif
    }

    /// The "ela_pro_bg" asset catalog image.
    static var elaProBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaProBg)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon" asset catalog image.
    static var elaProIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaProIcon)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon_2_1" asset catalog image.
    static var elaProIcon21: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaProIcon21)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon_2_2" asset catalog image.
    static var elaProIcon22: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaProIcon22)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon_2_3" asset catalog image.
    static var elaProIcon23: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaProIcon23)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon_2_4" asset catalog image.
    static var elaProIcon24: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaProIcon24)
#else
        .init()
#endif
    }

    /// The "ela_pro_progress_bg" asset catalog image.
    static var elaProProgressBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaProProgressBg)
#else
        .init()
#endif
    }

    /// The "ela_tag_label_left_icon" asset catalog image.
    static var elaTagLabelLeftIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaTagLabelLeftIcon)
#else
        .init()
#endif
    }

    /// The "ela_tag_label_right_icon" asset catalog image.
    static var elaTagLabelRightIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .elaTagLabelRightIcon)
#else
        .init()
#endif
    }

    /// The "fitness_tips_icon" asset catalog image.
    static var fitnessTipsIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fitnessTipsIcon)
#else
        .init()
#endif
    }

    /// The "foods_add_quickly_icon" asset catalog image.
    static var foodsAddQuicklyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsAddQuicklyIcon)
#else
        .init()
#endif
    }

    /// The "foods_ai_icon" asset catalog image.
    static var foodsAiIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsAiIcon)
#else
        .init()
#endif
    }

    /// The "foods_calori_type_carbo" asset catalog image.
    static var foodsCaloriTypeCarbo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsCaloriTypeCarbo)
#else
        .init()
#endif
    }

    /// The "foods_calori_type_fats" asset catalog image.
    static var foodsCaloriTypeFats: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsCaloriTypeFats)
#else
        .init()
#endif
    }

    /// The "foods_calori_type_protein" asset catalog image.
    static var foodsCaloriTypeProtein: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsCaloriTypeProtein)
#else
        .init()
#endif
    }

    /// The "foods_create_icon_normal" asset catalog image.
    static var foodsCreateIconNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsCreateIconNormal)
#else
        .init()
#endif
    }

    /// The "foods_create_icon_soon" asset catalog image.
    static var foodsCreateIconSoon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsCreateIconSoon)
#else
        .init()
#endif
    }

    /// The "foods_merge_add_icon" asset catalog image.
    static var foodsMergeAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsMergeAddIcon)
#else
        .init()
#endif
    }

    /// The "foods_merge_add_icon_white" asset catalog image.
    static var foodsMergeAddIconWhite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsMergeAddIconWhite)
#else
        .init()
#endif
    }

    /// The "foods_merge_arrow_icon" asset catalog image.
    static var foodsMergeArrowIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsMergeArrowIcon)
#else
        .init()
#endif
    }

    /// The "foods_merge_calories_icon" asset catalog image.
    static var foodsMergeCaloriesIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsMergeCaloriesIcon)
#else
        .init()
#endif
    }

    /// The "foods_merge_edit_digit_icon" asset catalog image.
    static var foodsMergeEditDigitIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsMergeEditDigitIcon)
#else
        .init()
#endif
    }

    /// The "foods_merge_icon" asset catalog image.
    static var foodsMergeIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsMergeIcon)
#else
        .init()
#endif
    }

    /// The "foods_new_func_icon" asset catalog image.
    static var foodsNewFuncIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsNewFuncIcon)
#else
        .init()
#endif
    }

    /// The "foods_search_quickly_icon" asset catalog image.
    static var foodsSearchQuicklyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsSearchQuicklyIcon)
#else
        .init()
#endif
    }

    /// The "foods_type_selected_icon" asset catalog image.
    static var foodsTypeSelectedIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .foodsTypeSelectedIcon)
#else
        .init()
#endif
    }

    /// The "forum_ tutorial_img" asset catalog image.
    static var forumTutorialImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumTutorialImg)
#else
        .init()
#endif
    }

    /// The "forum_add_image_icon" asset catalog image.
    static var forumAddImageIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumAddImageIcon)
#else
        .init()
#endif
    }

    /// The "forum_aite_icon" asset catalog image.
    static var forumAiteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumAiteIcon)
#else
        .init()
#endif
    }

    /// The "forum_aiticle_icon" asset catalog image.
    static var forumAiticleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumAiticleIcon)
#else
        .init()
#endif
    }

    /// The "forum_comment_icon" asset catalog image.
    static var forumCommentIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumCommentIcon)
#else
        .init()
#endif
    }

    /// The "forum_comment_icon_max" asset catalog image.
    static var forumCommentIconMax: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumCommentIconMax)
#else
        .init()
#endif
    }

    /// The "forum_comment_icon_min" asset catalog image.
    static var forumCommentIconMin: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumCommentIconMin)
#else
        .init()
#endif
    }

    /// The "forum_commom_img_close_icon" asset catalog image.
    static var forumCommomImgCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumCommomImgCloseIcon)
#else
        .init()
#endif
    }

    /// The "forum_commom_img_icon" asset catalog image.
    static var forumCommomImgIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumCommomImgIcon)
#else
        .init()
#endif
    }

    /// The "forum_commone_icon" asset catalog image.
    static var forumCommoneIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumCommoneIcon)
#else
        .init()
#endif
    }

    /// The "forum_location_icon" asset catalog image.
    static var forumLocationIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumLocationIcon)
#else
        .init()
#endif
    }

    /// The "forum_msg_icon" asset catalog image.
    static var forumMsgIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumMsgIcon)
#else
        .init()
#endif
    }

    /// The "forum_notice_arrow_icon" asset catalog image.
    static var forumNoticeArrowIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumNoticeArrowIcon)
#else
        .init()
#endif
    }

    /// The "forum_player_mute_no_icon" asset catalog image.
    static var forumPlayerMuteNoIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumPlayerMuteNoIcon)
#else
        .init()
#endif
    }

    /// The "forum_player_mute_yes_icon" asset catalog image.
    static var forumPlayerMuteYesIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumPlayerMuteYesIcon)
#else
        .init()
#endif
    }

    /// The "forum_poll_icon" asset catalog image.
    static var forumPollIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumPollIcon)
#else
        .init()
#endif
    }

    /// The "forum_publish_icon" asset catalog image.
    static var forumPublishIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumPublishIcon)
#else
        .init()
#endif
    }

    /// The "forum_set_top_cancel_icon" asset catalog image.
    static var forumSetTopCancelIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumSetTopCancelIcon)
#else
        .init()
#endif
    }

    /// The "forum_set_top_icon" asset catalog image.
    static var forumSetTopIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumSetTopIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_black_icon" asset catalog image.
    static var forumShareBlackIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumShareBlackIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_circle_icon" asset catalog image.
    static var forumShareCircleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumShareCircleIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_copy_icon" asset catalog image.
    static var forumShareCopyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumShareCopyIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_delete_icon" asset catalog image.
    static var forumShareDeleteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumShareDeleteIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_icon" asset catalog image.
    static var forumShareIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumShareIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_report_icon" asset catalog image.
    static var forumShareReportIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumShareReportIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_wechat_icon" asset catalog image.
    static var forumShareWechatIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumShareWechatIcon)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_highlight" asset catalog image.
    static var forumThumbsUpHighlight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumThumbsUpHighlight)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_highlight_max" asset catalog image.
    static var forumThumbsUpHighlightMax: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumThumbsUpHighlightMax)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_highlight_min" asset catalog image.
    static var forumThumbsUpHighlightMin: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumThumbsUpHighlightMin)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_max" asset catalog image.
    static var forumThumbsUpMax: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumThumbsUpMax)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_normal" asset catalog image.
    static var forumThumbsUpNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumThumbsUpNormal)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_normal_min" asset catalog image.
    static var forumThumbsUpNormalMin: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumThumbsUpNormalMin)
#else
        .init()
#endif
    }

    /// The "forum_top_icon" asset catalog image.
    static var forumTopIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumTopIcon)
#else
        .init()
#endif
    }

    /// The "forum_tutorial_default_cover" asset catalog image.
    static var forumTutorialDefaultCover: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumTutorialDefaultCover)
#else
        .init()
#endif
    }

    /// The "forum_user_verify_icon" asset catalog image.
    static var forumUserVerifyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumUserVerifyIcon)
#else
        .init()
#endif
    }

    /// The "forum_video_play_icon" asset catalog image.
    static var forumVideoPlayIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumVideoPlayIcon)
#else
        .init()
#endif
    }

    /// The "forum_visible_icon" asset catalog image.
    static var forumVisibleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .forumVisibleIcon)
#else
        .init()
#endif
    }

    /// The "frame_0000" asset catalog image.
    static var frame0000: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0000)
#else
        .init()
#endif
    }

    /// The "frame_0001" asset catalog image.
    static var frame0001: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0001)
#else
        .init()
#endif
    }

    /// The "frame_0002" asset catalog image.
    static var frame0002: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0002)
#else
        .init()
#endif
    }

    /// The "frame_0003" asset catalog image.
    static var frame0003: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0003)
#else
        .init()
#endif
    }

    /// The "frame_0004" asset catalog image.
    static var frame0004: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0004)
#else
        .init()
#endif
    }

    /// The "frame_0005" asset catalog image.
    static var frame0005: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0005)
#else
        .init()
#endif
    }

    /// The "frame_0006" asset catalog image.
    static var frame0006: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0006)
#else
        .init()
#endif
    }

    /// The "frame_0007" asset catalog image.
    static var frame0007: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0007)
#else
        .init()
#endif
    }

    /// The "frame_0008" asset catalog image.
    static var frame0008: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0008)
#else
        .init()
#endif
    }

    /// The "frame_0009" asset catalog image.
    static var frame0009: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0009)
#else
        .init()
#endif
    }

    /// The "frame_0010" asset catalog image.
    static var frame0010: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0010)
#else
        .init()
#endif
    }

    /// The "frame_0011" asset catalog image.
    static var frame0011: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0011)
#else
        .init()
#endif
    }

    /// The "frame_0012" asset catalog image.
    static var frame0012: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0012)
#else
        .init()
#endif
    }

    /// The "frame_0013" asset catalog image.
    static var frame0013: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0013)
#else
        .init()
#endif
    }

    /// The "frame_0014" asset catalog image.
    static var frame0014: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0014)
#else
        .init()
#endif
    }

    /// The "frame_0015" asset catalog image.
    static var frame0015: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0015)
#else
        .init()
#endif
    }

    /// The "frame_0016" asset catalog image.
    static var frame0016: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0016)
#else
        .init()
#endif
    }

    /// The "frame_0017" asset catalog image.
    static var frame0017: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0017)
#else
        .init()
#endif
    }

    /// The "frame_0018" asset catalog image.
    static var frame0018: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0018)
#else
        .init()
#endif
    }

    /// The "frame_0019" asset catalog image.
    static var frame0019: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0019)
#else
        .init()
#endif
    }

    /// The "frame_0020" asset catalog image.
    static var frame0020: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0020)
#else
        .init()
#endif
    }

    /// The "frame_0021" asset catalog image.
    static var frame0021: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0021)
#else
        .init()
#endif
    }

    /// The "frame_0022" asset catalog image.
    static var frame0022: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0022)
#else
        .init()
#endif
    }

    /// The "frame_0023" asset catalog image.
    static var frame0023: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0023)
#else
        .init()
#endif
    }

    /// The "frame_0024" asset catalog image.
    static var frame0024: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0024)
#else
        .init()
#endif
    }

    /// The "frame_0025" asset catalog image.
    static var frame0025: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0025)
#else
        .init()
#endif
    }

    /// The "frame_0026" asset catalog image.
    static var frame0026: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0026)
#else
        .init()
#endif
    }

    /// The "frame_0027" asset catalog image.
    static var frame0027: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0027)
#else
        .init()
#endif
    }

    /// The "frame_0028" asset catalog image.
    static var frame0028: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0028)
#else
        .init()
#endif
    }

    /// The "frame_0029" asset catalog image.
    static var frame0029: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0029)
#else
        .init()
#endif
    }

    /// The "frame_0030" asset catalog image.
    static var frame0030: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0030)
#else
        .init()
#endif
    }

    /// The "frame_0031" asset catalog image.
    static var frame0031: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frame0031)
#else
        .init()
#endif
    }

    /// The "friend_list_edit_icon" asset catalog image.
    static var friendListEditIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListEditIcon)
#else
        .init()
#endif
    }

    /// The "friend_list_first" asset catalog image.
    static var friendListFirst: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListFirst)
#else
        .init()
#endif
    }

    /// The "friend_list_img" asset catalog image.
    static var friendListImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListImg)
#else
        .init()
#endif
    }

    /// The "friend_list_second" asset catalog image.
    static var friendListSecond: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListSecond)
#else
        .init()
#endif
    }

    /// The "friend_list_status_add" asset catalog image.
    static var friendListStatusAdd: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListStatusAdd)
#else
        .init()
#endif
    }

    /// The "friend_list_status_agree" asset catalog image.
    static var friendListStatusAgree: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListStatusAgree)
#else
        .init()
#endif
    }

    /// The "friend_list_status_disagree" asset catalog image.
    static var friendListStatusDisagree: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListStatusDisagree)
#else
        .init()
#endif
    }

    /// The "friend_list_status_pending" asset catalog image.
    static var friendListStatusPending: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListStatusPending)
#else
        .init()
#endif
    }

    /// The "friend_list_status_succesd" asset catalog image.
    static var friendListStatusSuccesd: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListStatusSuccesd)
#else
        .init()
#endif
    }

    /// The "friend_list_third" asset catalog image.
    static var friendListThird: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListThird)
#else
        .init()
#endif
    }

    /// The "friend_list_top_1" asset catalog image.
    static var friendListTop1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendListTop1)
#else
        .init()
#endif
    }

    /// The "friend_top_bg_img" asset catalog image.
    static var friendTopBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .friendTopBgImg)
#else
        .init()
#endif
    }

    /// The "goal_circle_icon" asset catalog image.
    static var goalCircleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .goalCircleIcon)
#else
        .init()
#endif
    }

    /// The "goal_circle_question" asset catalog image.
    static var goalCircleQuestion: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .goalCircleQuestion)
#else
        .init()
#endif
    }

    /// The "goal_zhineng_icon" asset catalog image.
    static var goalZhinengIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .goalZhinengIcon)
#else
        .init()
#endif
    }

    /// The "guide_back_button" asset catalog image.
    static var guideBackButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideBackButton)
#else
        .init()
#endif
    }

    /// The "guide_chat_box" asset catalog image.
    static var guideChatBox: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideChatBox)
#else
        .init()
#endif
    }

    /// The "guide_chat_box_2" asset catalog image.
    static var guideChatBox2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideChatBox2)
#else
        .init()
#endif
    }

    /// The "guide_chat_box_3" asset catalog image.
    static var guideChatBox3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideChatBox3)
#else
        .init()
#endif
    }

    /// The "guide_first_page_chart" asset catalog image.
    static var guideFirstPageChart: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideFirstPageChart)
#else
        .init()
#endif
    }

    /// The "guide_first_page_down_icon" asset catalog image.
    static var guideFirstPageDownIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideFirstPageDownIcon)
#else
        .init()
#endif
    }

    /// The "guide_first_page_logo_icon" asset catalog image.
    static var guideFirstPageLogoIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideFirstPageLogoIcon)
#else
        .init()
#endif
    }

    /// The "guide_first_page_up_icon" asset catalog image.
    static var guideFirstPageUpIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideFirstPageUpIcon)
#else
        .init()
#endif
    }

    /// The "guide_img_step_3" asset catalog image.
    static var guideImgStep3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideImgStep3)
#else
        .init()
#endif
    }

    /// The "guide_img_step_4" asset catalog image.
    static var guideImgStep4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideImgStep4)
#else
        .init()
#endif
    }

    /// The "guide_img_step_5" asset catalog image.
    static var guideImgStep5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideImgStep5)
#else
        .init()
#endif
    }

    /// The "guide_img_step_6" asset catalog image.
    static var guideImgStep6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideImgStep6)
#else
        .init()
#endif
    }

    /// The "guide_img_step_7" asset catalog image.
    static var guideImgStep7: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideImgStep7)
#else
        .init()
#endif
    }

    /// The "guide_img_step_7_circle" asset catalog image.
    static var guideImgStep7Circle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideImgStep7Circle)
#else
        .init()
#endif
    }

    /// The "guide_second_img_1" asset catalog image.
    static var guideSecondImg1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideSecondImg1)
#else
        .init()
#endif
    }

    /// The "guide_second_img_2" asset catalog image.
    static var guideSecondImg2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideSecondImg2)
#else
        .init()
#endif
    }

    /// The "guide_second_img_3" asset catalog image.
    static var guideSecondImg3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideSecondImg3)
#else
        .init()
#endif
    }

    /// The "guide_second_img_4" asset catalog image.
    static var guideSecondImg4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideSecondImg4)
#else
        .init()
#endif
    }

    /// The "guide_second_jijian" asset catalog image.
    static var guideSecondJijian: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideSecondJijian)
#else
        .init()
#endif
    }

    /// The "guide_second_zhuanye" asset catalog image.
    static var guideSecondZhuanye: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideSecondZhuanye)
#else
        .init()
#endif
    }

    /// The "guide_third_add_icon" asset catalog image.
    static var guideThirdAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guideThirdAddIcon)
#else
        .init()
#endif
    }

    /// The "habit_bg_ela_img" asset catalog image.
    static var habitBgElaImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitBgElaImg)
#else
        .init()
#endif
    }

    /// The "habit_exchange_tips_bg" asset catalog image.
    static var habitExchangeTipsBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitExchangeTipsBg)
#else
        .init()
#endif
    }

    /// The "habit_exchange_tips_ela_bg" asset catalog image.
    static var habitExchangeTipsElaBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitExchangeTipsElaBg)
#else
        .init()
#endif
    }

    /// The "habit_exchange_tips_title" asset catalog image.
    static var habitExchangeTipsTitle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitExchangeTipsTitle)
#else
        .init()
#endif
    }

    /// The "habit_guide_1_bg" asset catalog image.
    static var habitGuide1Bg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitGuide1Bg)
#else
        .init()
#endif
    }

    /// The "habit_guide_2_img" asset catalog image.
    static var habitGuide2Img: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitGuide2Img)
#else
        .init()
#endif
    }

    /// The "habit_guide_3_img" asset catalog image.
    static var habitGuide3Img: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitGuide3Img)
#else
        .init()
#endif
    }

    /// The "habit_guide_4_img" asset catalog image.
    static var habitGuide4Img: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitGuide4Img)
#else
        .init()
#endif
    }

    /// The "habit_guide_5_img" asset catalog image.
    static var habitGuide5Img: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitGuide5Img)
#else
        .init()
#endif
    }

    /// The "habit_guide_back_icon" asset catalog image.
    static var habitGuideBackIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitGuideBackIcon)
#else
        .init()
#endif
    }

    /// The "habit_guide_ela_icon" asset catalog image.
    static var habitGuideElaIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitGuideElaIcon)
#else
        .init()
#endif
    }

    /// The "habit_number_add_icon" asset catalog image.
    static var habitNumberAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitNumberAddIcon)
#else
        .init()
#endif
    }

    /// The "habit_number_sub_icon" asset catalog image.
    static var habitNumberSubIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitNumberSubIcon)
#else
        .init()
#endif
    }

    /// The "habit_rank_down_icon" asset catalog image.
    static var habitRankDownIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRankDownIcon)
#else
        .init()
#endif
    }

    /// The "habit_rank_right_icon" asset catalog image.
    static var habitRankRightIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRankRightIcon)
#else
        .init()
#endif
    }

    /// The "habit_rank_time_icon" asset catalog image.
    static var habitRankTimeIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRankTimeIcon)
#else
        .init()
#endif
    }

    /// The "habit_rank_up_icon" asset catalog image.
    static var habitRankUpIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRankUpIcon)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_empty_img" asset catalog image.
    static var habitRanklistEmptyImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRanklistEmptyImg)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_heart_icon" asset catalog image.
    static var habitRanklistHeartIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRanklistHeartIcon)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_one" asset catalog image.
    static var habitRanklistOne: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRanklistOne)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_three" asset catalog image.
    static var habitRanklistThree: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRanklistThree)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_two" asset catalog image.
    static var habitRanklistTwo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRanklistTwo)
#else
        .init()
#endif
    }

    /// The "habit_rule_img_1" asset catalog image.
    static var habitRuleImg1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRuleImg1)
#else
        .init()
#endif
    }

    /// The "habit_rule_img_2" asset catalog image.
    static var habitRuleImg2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitRuleImg2)
#else
        .init()
#endif
    }

    /// The "habit_settle_bg_img" asset catalog image.
    static var habitSettleBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitSettleBgImg)
#else
        .init()
#endif
    }

    /// The "habit_settle_cup_shadow" asset catalog image.
    static var habitSettleCupShadow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitSettleCupShadow)
#else
        .init()
#endif
    }

    /// The "habit_settle_degree_left_icon" asset catalog image.
    static var habitSettleDegreeLeftIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitSettleDegreeLeftIcon)
#else
        .init()
#endif
    }

    /// The "habit_settle_degree_right_icon" asset catalog image.
    static var habitSettleDegreeRightIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitSettleDegreeRightIcon)
#else
        .init()
#endif
    }

    /// The "habit_settle_desk" asset catalog image.
    static var habitSettleDesk: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitSettleDesk)
#else
        .init()
#endif
    }

    /// The "habit_settle_list_bg" asset catalog image.
    static var habitSettleListBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .habitSettleListBg)
#else
        .init()
#endif
    }

    /// The "haibit_body_data_icon" asset catalog image.
    static var haibitBodyDataIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .haibitBodyDataIcon)
#else
        .init()
#endif
    }

    /// The "haibit_fitness_icon" asset catalog image.
    static var haibitFitnessIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .haibitFitnessIcon)
#else
        .init()
#endif
    }

    /// The "haibit_friend_icon" asset catalog image.
    static var haibitFriendIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .haibitFriendIcon)
#else
        .init()
#endif
    }

    /// The "haibit_friend_protein_icon" asset catalog image.
    static var haibitFriendProteinIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .haibitFriendProteinIcon)
#else
        .init()
#endif
    }

    /// The "haibit_journal_icon" asset catalog image.
    static var haibitJournalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .haibitJournalIcon)
#else
        .init()
#endif
    }

    /// The "haibit_protein_icon" asset catalog image.
    static var haibitProteinIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .haibitProteinIcon)
#else
        .init()
#endif
    }

    /// The "haibit_streak_normal_icon" asset catalog image.
    static var haibitStreakNormalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .haibitStreakNormalIcon)
#else
        .init()
#endif
    }

    /// The "honor_top_img" asset catalog image.
    static var honorTopImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .honorTopImg)
#else
        .init()
#endif
    }

    /// The "icon_90_gray" asset catalog image.
    static var icon90Gray: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon90Gray)
#else
        .init()
#endif
    }

    /// The "icon_95_blue" asset catalog image.
    static var icon95Blue: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .icon95Blue)
#else
        .init()
#endif
    }

    /// The "icon_calendar_gray" asset catalog image.
    static var iconCalendarGray: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconCalendarGray)
#else
        .init()
#endif
    }

    /// The "idc_icon_china" asset catalog image.
    static var idcIconChina: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .idcIconChina)
#else
        .init()
#endif
    }

    /// The "img_close_icon" asset catalog image.
    static var imgCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .imgCloseIcon)
#else
        .init()
#endif
    }

    /// The "invite_rewards_code_bg" asset catalog image.
    static var inviteRewardsCodeBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .inviteRewardsCodeBg)
#else
        .init()
#endif
    }

    /// The "journal_share_calories_icon" asset catalog image.
    static var journalShareCaloriesIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .journalShareCaloriesIcon)
#else
        .init()
#endif
    }

    /// The "journal_share_shadow_view" asset catalog image.
    static var journalShareShadowView: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .journalShareShadowView)
#else
        .init()
#endif
    }

    /// The "launch_bg_img" asset catalog image.
    static var launchBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchBgImg)
#else
        .init()
#endif
    }

    /// The "launch_slogan_img" asset catalog image.
    static var launchSloganImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchSloganImg)
#else
        .init()
#endif
    }

    /// The "launch_welcome_bg" asset catalog image.
    static var launchWelcomeBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchWelcomeBg)
#else
        .init()
#endif
    }

    /// The "launch_welcome_img_1" asset catalog image.
    static var launchWelcomeImg1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchWelcomeImg1)
#else
        .init()
#endif
    }

    /// The "launch_welcome_img_2" asset catalog image.
    static var launchWelcomeImg2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchWelcomeImg2)
#else
        .init()
#endif
    }

    /// The "launch_welcome_img_3" asset catalog image.
    static var launchWelcomeImg3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchWelcomeImg3)
#else
        .init()
#endif
    }

    /// The "log_share_bg_img" asset catalog image.
    static var logShareBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logShareBgImg)
#else
        .init()
#endif
    }

    /// The "login_alert_apple_icon" asset catalog image.
    static var loginAlertAppleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginAlertAppleIcon)
#else
        .init()
#endif
    }

    /// The "login_alert_phone_icon" asset catalog image.
    static var loginAlertPhoneIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginAlertPhoneIcon)
#else
        .init()
#endif
    }

    /// The "login_alert_wechat_icon" asset catalog image.
    static var loginAlertWechatIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginAlertWechatIcon)
#else
        .init()
#endif
    }

    /// The "login_apple_icon" asset catalog image.
    static var loginAppleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginAppleIcon)
#else
        .init()
#endif
    }

    /// The "login_arrow_down_icon" asset catalog image.
    static var loginArrowDownIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginArrowDownIcon)
#else
        .init()
#endif
    }

    /// The "login_close_img" asset catalog image.
    static var loginCloseImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginCloseImg)
#else
        .init()
#endif
    }

    /// The "login_wechat_icon" asset catalog image.
    static var loginWechatIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginWechatIcon)
#else
        .init()
#endif
    }

    /// The "logs_add_icon_theme" asset catalog image.
    static var logsAddIconTheme: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsAddIconTheme)
#else
        .init()
#endif
    }

    /// The "logs_add_icon_theme_cj" asset catalog image.
    static var logsAddIconThemeCj: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsAddIconThemeCj)
#else
        .init()
#endif
    }

    /// The "logs_circle_cover" asset catalog image.
    static var logsCircleCover: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsCircleCover)
#else
        .init()
#endif
    }

    /// The "logs_create_plan_icon" asset catalog image.
    static var logsCreatePlanIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsCreatePlanIcon)
#else
        .init()
#endif
    }

    /// The "logs_edit_all_normal" asset catalog image.
    static var logsEditAllNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsEditAllNormal)
#else
        .init()
#endif
    }

    /// The "logs_edit_selected" asset catalog image.
    static var logsEditSelected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsEditSelected)
#else
        .init()
#endif
    }

    /// The "logs_foods_copy_icon" asset catalog image.
    static var logsFoodsCopyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsFoodsCopyIcon)
#else
        .init()
#endif
    }

    /// The "logs_foods_eat_icon" asset catalog image.
    static var logsFoodsEatIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsFoodsEatIcon)
#else
        .init()
#endif
    }

    /// The "logs_foods_eat_icon_cj" asset catalog image.
    static var logsFoodsEatIconCj: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsFoodsEatIconCj)
#else
        .init()
#endif
    }

    /// The "logs_foods_meals_create_icon" asset catalog image.
    static var logsFoodsMealsCreateIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsFoodsMealsCreateIcon)
#else
        .init()
#endif
    }

    /// The "logs_natural_icon" asset catalog image.
    static var logsNaturalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsNaturalIcon)
#else
        .init()
#endif
    }

    /// The "logs_natural_icon_cj" asset catalog image.
    static var logsNaturalIconCj: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsNaturalIconCj)
#else
        .init()
#endif
    }

    /// The "logs_navi_list_icon" asset catalog image.
    static var logsNaviListIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsNaviListIcon)
#else
        .init()
#endif
    }

    /// The "logs_navi_share_icon" asset catalog image.
    static var logsNaviShareIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsNaviShareIcon)
#else
        .init()
#endif
    }

    /// The "logs_pen_icon" asset catalog image.
    static var logsPenIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsPenIcon)
#else
        .init()
#endif
    }

    /// The "logs_remark_add_icon" asset catalog image.
    static var logsRemarkAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsRemarkAddIcon)
#else
        .init()
#endif
    }

    /// The "logs_remark_arrow_down" asset catalog image.
    static var logsRemarkArrowDown: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsRemarkArrowDown)
#else
        .init()
#endif
    }

    /// The "logs_share_bg_img" asset catalog image.
    static var logsShareBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsShareBgImg)
#else
        .init()
#endif
    }

    /// The "logs_share_time_icon" asset catalog image.
    static var logsShareTimeIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logsShareTimeIcon)
#else
        .init()
#endif
    }

    /// The "main_add_data_button" asset catalog image.
    static var mainAddDataButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainAddDataButton)
#else
        .init()
#endif
    }

    /// The "main_circle_bg" asset catalog image.
    static var mainCircleBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainCircleBg)
#else
        .init()
#endif
    }

    /// The "main_edit_icon" asset catalog image.
    static var mainEditIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainEditIcon)
#else
        .init()
#endif
    }

    /// The "main_edit_icon_theme" asset catalog image.
    static var mainEditIconTheme: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainEditIconTheme)
#else
        .init()
#endif
    }

    /// The "main_nutrient_span_img" asset catalog image.
    static var mainNutrientSpanImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainNutrientSpanImg)
#else
        .init()
#endif
    }

    /// The "main_nutrient_span_img_2" asset catalog image.
    static var mainNutrientSpanImg2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainNutrientSpanImg2)
#else
        .init()
#endif
    }

    /// The "main_pencil_icon" asset catalog image.
    static var mainPencilIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainPencilIcon)
#else
        .init()
#endif
    }

    /// The "main_search_icon" asset catalog image.
    static var mainSearchIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainSearchIcon)
#else
        .init()
#endif
    }

    /// The "main_top_bg" asset catalog image.
    static var mainTopBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainTopBg)
#else
        .init()
#endif
    }

    /// The "main_top_bg_cj" asset catalog image.
    static var mainTopBgCj: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainTopBgCj)
#else
        .init()
#endif
    }

    /// The "main_top_logo" asset catalog image.
    static var mainTopLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainTopLogo)
#else
        .init()
#endif
    }

    /// The "main_top_logo_cj" asset catalog image.
    static var mainTopLogoCj: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainTopLogoCj)
#else
        .init()
#endif
    }

    /// The "main_top_logo_launch" asset catalog image.
    static var mainTopLogoLaunch: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainTopLogoLaunch)
#else
        .init()
#endif
    }

    /// The "mall_address_default_icon" asset catalog image.
    static var mallAddressDefaultIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallAddressDefaultIcon)
#else
        .init()
#endif
    }

    /// The "mall_address_delete_icon" asset catalog image.
    static var mallAddressDeleteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallAddressDeleteIcon)
#else
        .init()
#endif
    }

    /// The "mall_address_edit_icon" asset catalog image.
    static var mallAddressEditIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallAddressEditIcon)
#else
        .init()
#endif
    }

    /// The "mall_address_normal_icon" asset catalog image.
    static var mallAddressNormalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallAddressNormalIcon)
#else
        .init()
#endif
    }

    /// The "mall_detail_back_icon" asset catalog image.
    static var mallDetailBackIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallDetailBackIcon)
#else
        .init()
#endif
    }

    /// The "mall_detail_service_icon" asset catalog image.
    static var mallDetailServiceIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallDetailServiceIcon)
#else
        .init()
#endif
    }

    /// The "mall_detail_share_icon" asset catalog image.
    static var mallDetailShareIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallDetailShareIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_address_icon" asset catalog image.
    static var mallOrderAddressIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderAddressIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_detail_arrow_down" asset catalog image.
    static var mallOrderDetailArrowDown: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderDetailArrowDown)
#else
        .init()
#endif
    }

    /// The "mall_order_detail_arrow_top" asset catalog image.
    static var mallOrderDetailArrowTop: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderDetailArrowTop)
#else
        .init()
#endif
    }

    /// The "mall_order_idcard_icon" asset catalog image.
    static var mallOrderIdcardIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderIdcardIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_img_add_icon" asset catalog image.
    static var mallOrderImgAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderImgAddIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_img_clear_icon" asset catalog image.
    static var mallOrderImgClearIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderImgClearIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_num_add_icon" asset catalog image.
    static var mallOrderNumAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderNumAddIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_num_sub_icon" asset catalog image.
    static var mallOrderNumSubIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderNumSubIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_success_icon" asset catalog image.
    static var mallOrderSuccessIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallOrderSuccessIcon)
#else
        .init()
#endif
    }

    /// The "mall_spec_arrow_down_icon" asset catalog image.
    static var mallSpecArrowDownIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mallSpecArrowDownIcon)
#else
        .init()
#endif
    }

    /// The "meals_create_camera" asset catalog image.
    static var mealsCreateCamera: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsCreateCamera)
#else
        .init()
#endif
    }

    /// The "meals_create_icon" asset catalog image.
    static var mealsCreateIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsCreateIcon)
#else
        .init()
#endif
    }

    /// The "meals_eat_add_icon" asset catalog image.
    static var mealsEatAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsEatAddIcon)
#else
        .init()
#endif
    }

    /// The "meals_eat_add_icon_theme" asset catalog image.
    static var mealsEatAddIconTheme: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsEatAddIconTheme)
#else
        .init()
#endif
    }

    /// The "meals_eat_add_icon_white" asset catalog image.
    static var mealsEatAddIconWhite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsEatAddIconWhite)
#else
        .init()
#endif
    }

    /// The "meals_eat_icon" asset catalog image.
    static var mealsEatIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsEatIcon)
#else
        .init()
#endif
    }

    /// The "meals_eat_right_icon" asset catalog image.
    static var mealsEatRightIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsEatRightIcon)
#else
        .init()
#endif
    }

    /// The "meals_foods_default" asset catalog image.
    static var mealsFoodsDefault: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsFoodsDefault)
#else
        .init()
#endif
    }

    /// The "meals_foods_photo" asset catalog image.
    static var mealsFoodsPhoto: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsFoodsPhoto)
#else
        .init()
#endif
    }

    /// The "meals_icon_default" asset catalog image.
    static var mealsIconDefault: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsIconDefault)
#else
        .init()
#endif
    }

    /// The "meals_top_bg" asset catalog image.
    static var mealsTopBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mealsTopBg)
#else
        .init()
#endif
    }

    /// The "mian_top_bg_whole" asset catalog image.
    static var mianTopBgWhole: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mianTopBgWhole)
#else
        .init()
#endif
    }

    /// The "mine_boday_data" asset catalog image.
    static var mineBodayData: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineBodayData)
#else
        .init()
#endif
    }

    /// The "mine_func_arrow" asset catalog image.
    static var mineFuncArrow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncArrow)
#else
        .init()
#endif
    }

    /// The "mine_func_arrow_icon" asset catalog image.
    static var mineFuncArrowIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncArrowIcon)
#else
        .init()
#endif
    }

    /// The "mine_func_create_plan" asset catalog image.
    static var mineFuncCreatePlan: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncCreatePlan)
#else
        .init()
#endif
    }

    /// The "mine_func_fasting" asset catalog image.
    static var mineFuncFasting: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncFasting)
#else
        .init()
#endif
    }

    /// The "mine_func_foods" asset catalog image.
    static var mineFuncFoods: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncFoods)
#else
        .init()
#endif
    }

    /// The "mine_func_forum_msg_icon" asset catalog image.
    static var mineFuncForumMsgIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncForumMsgIcon)
#else
        .init()
#endif
    }

    /// The "mine_func_friends" asset catalog image.
    static var mineFuncFriends: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncFriends)
#else
        .init()
#endif
    }

    /// The "mine_func_goal" asset catalog image.
    static var mineFuncGoal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncGoal)
#else
        .init()
#endif
    }

    /// The "mine_func_honor" asset catalog image.
    static var mineFuncHonor: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncHonor)
#else
        .init()
#endif
    }

    /// The "mine_func_invite" asset catalog image.
    static var mineFuncInvite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncInvite)
#else
        .init()
#endif
    }

    /// The "mine_func_meal" asset catalog image.
    static var mineFuncMeal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncMeal)
#else
        .init()
#endif
    }

    /// The "mine_func_order_list" asset catalog image.
    static var mineFuncOrderList: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncOrderList)
#else
        .init()
#endif
    }

    /// The "mine_func_personal_setting" asset catalog image.
    static var mineFuncPersonalSetting: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncPersonalSetting)
#else
        .init()
#endif
    }

    /// The "mine_func_plan" asset catalog image.
    static var mineFuncPlan: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncPlan)
#else
        .init()
#endif
    }

    /// The "mine_func_service" asset catalog image.
    static var mineFuncService: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncService)
#else
        .init()
#endif
    }

    /// The "mine_func_setting" asset catalog image.
    static var mineFuncSetting: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncSetting)
#else
        .init()
#endif
    }

    /// The "mine_func_stat" asset catalog image.
    static var mineFuncStat: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncStat)
#else
        .init()
#endif
    }

    /// The "mine_func_tutorials" asset catalog image.
    static var mineFuncTutorials: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineFuncTutorials)
#else
        .init()
#endif
    }

    /// The "mine_setting_logo" asset catalog image.
    static var mineSettingLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineSettingLogo)
#else
        .init()
#endif
    }

    /// The "mine_top_bg" asset catalog image.
    static var mineTopBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineTopBg)
#else
        .init()
#endif
    }

    /// The "mine_top_func_arrow" asset catalog image.
    static var mineTopFuncArrow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mineTopFuncArrow)
#else
        .init()
#endif
    }

    /// The "navi_back_white_icon" asset catalog image.
    static var naviBackWhiteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .naviBackWhiteIcon)
#else
        .init()
#endif
    }

    /// The "navi_close_icon" asset catalog image.
    static var naviCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .naviCloseIcon)
#else
        .init()
#endif
    }

    /// The "navi_logo_img" asset catalog image.
    static var naviLogoImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .naviLogoImg)
#else
        .init()
#endif
    }

    /// The "notifi_tips_img" asset catalog image.
    static var notifiTipsImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .notifiTipsImg)
#else
        .init()
#endif
    }

    /// The "peacock_img" asset catalog image.
    static var peacockImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .peacockImg)
#else
        .init()
#endif
    }

    /// The "plan_arrow_gray" asset catalog image.
    static var planArrowGray: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planArrowGray)
#else
        .init()
#endif
    }

    /// The "plan_arrow_gray_whole" asset catalog image.
    static var planArrowGrayWhole: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planArrowGrayWhole)
#else
        .init()
#endif
    }

    /// The "plan_arrow_theme" asset catalog image.
    static var planArrowTheme: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planArrowTheme)
#else
        .init()
#endif
    }

    /// The "plan_create_icon" asset catalog image.
    static var planCreateIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planCreateIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_blace_icon" asset catalog image.
    static var planDetailArrowBlaceIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailArrowBlaceIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_highlight_icon" asset catalog image.
    static var planDetailArrowHighlightIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailArrowHighlightIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_highlight_icon_left" asset catalog image.
    static var planDetailArrowHighlightIconLeft: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailArrowHighlightIconLeft)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_icon_left" asset catalog image.
    static var planDetailArrowIconLeft: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailArrowIconLeft)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_icon_right" asset catalog image.
    static var planDetailArrowIconRight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailArrowIconRight)
#else
        .init()
#endif
    }

    /// The "plan_detail_cancel_icon" asset catalog image.
    static var planDetailCancelIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailCancelIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_circle_img" asset catalog image.
    static var planDetailCircleImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailCircleImg)
#else
        .init()
#endif
    }

    /// The "plan_detail_delete_icon" asset catalog image.
    static var planDetailDeleteIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailDeleteIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_share_icon" asset catalog image.
    static var planDetailShareIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planDetailShareIcon)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_bg_img" asset catalog image.
    static var planGetAlertBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planGetAlertBgImg)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_calori_bg_img" asset catalog image.
    static var planGetAlertCaloriBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planGetAlertCaloriBgImg)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_calori_icon" asset catalog image.
    static var planGetAlertCaloriIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planGetAlertCaloriIcon)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_clock_icon" asset catalog image.
    static var planGetAlertClockIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planGetAlertClockIcon)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_natural_line" asset catalog image.
    static var planGetAlertNaturalLine: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planGetAlertNaturalLine)
#else
        .init()
#endif
    }

    /// The "plan_get_icon" asset catalog image.
    static var planGetIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planGetIcon)
#else
        .init()
#endif
    }

    /// The "plan_lead_icon" asset catalog image.
    static var planLeadIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planLeadIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_bg_img" asset catalog image.
    static var planShareBgImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareBgImg)
#else
        .init()
#endif
    }

    /// The "plan_share_bg_img_rect" asset catalog image.
    static var planShareBgImgRect: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareBgImgRect)
#else
        .init()
#endif
    }

    /// The "plan_share_circle_icon" asset catalog image.
    static var planShareCircleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareCircleIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_circle_icon_white" asset catalog image.
    static var planShareCircleIconWhite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareCircleIconWhite)
#else
        .init()
#endif
    }

    /// The "plan_share_close_icon" asset catalog image.
    static var planShareCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareCloseIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_copy_icon" asset catalog image.
    static var planShareCopyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareCopyIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_save_icon" asset catalog image.
    static var planShareSaveIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareSaveIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_save_icon_white" asset catalog image.
    static var planShareSaveIconWhite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareSaveIconWhite)
#else
        .init()
#endif
    }

    /// The "plan_share_wechat_icon" asset catalog image.
    static var planShareWechatIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareWechatIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_wechat_icon_white" asset catalog image.
    static var planShareWechatIconWhite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planShareWechatIconWhite)
#else
        .init()
#endif
    }

    /// The "question_alert_arrow_down_icon" asset catalog image.
    static var questionAlertArrowDownIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionAlertArrowDownIcon)
#else
        .init()
#endif
    }

    /// The "question_alert_close_icon" asset catalog image.
    static var questionAlertCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionAlertCloseIcon)
#else
        .init()
#endif
    }

    /// The "question_arrow_right" asset catalog image.
    static var questionArrowRight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionArrowRight)
#else
        .init()
#endif
    }

    /// The "question_arrow_right_theme" asset catalog image.
    static var questionArrowRightTheme: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionArrowRightTheme)
#else
        .init()
#endif
    }

    /// The "question_bg" asset catalog image.
    static var questionBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionBg)
#else
        .init()
#endif
    }

    /// The "question_checkbox_normal" asset catalog image.
    static var questionCheckboxNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionCheckboxNormal)
#else
        .init()
#endif
    }

    /// The "question_checkbox_selected" asset catalog image.
    static var questionCheckboxSelected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionCheckboxSelected)
#else
        .init()
#endif
    }

    /// The "question_foods_normal_icon" asset catalog image.
    static var questionFoodsNormalIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionFoodsNormalIcon)
#else
        .init()
#endif
    }

    /// The "question_foods_selected_icon" asset catalog image.
    static var questionFoodsSelectedIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionFoodsSelectedIcon)
#else
        .init()
#endif
    }

    /// The "question_foods_verify_icon" asset catalog image.
    static var questionFoodsVerifyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionFoodsVerifyIcon)
#else
        .init()
#endif
    }

    /// The "question_goal_selected" asset catalog image.
    static var questionGoalSelected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionGoalSelected)
#else
        .init()
#endif
    }

    /// The "question_plan_tips_content" asset catalog image.
    static var questionPlanTipsContent: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionPlanTipsContent)
#else
        .init()
#endif
    }

    /// The "question_pre_img" asset catalog image.
    static var questionPreImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .questionPreImg)
#else
        .init()
#endif
    }

    /// The "rank_1_reached" asset catalog image.
    static var rank1Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank1Reached)
#else
        .init()
#endif
    }

    /// The "rank_2_reached" asset catalog image.
    static var rank2Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank2Reached)
#else
        .init()
#endif
    }

    /// The "rank_3_reached" asset catalog image.
    static var rank3Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank3Reached)
#else
        .init()
#endif
    }

    /// The "rank_4_reached" asset catalog image.
    static var rank4Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank4Reached)
#else
        .init()
#endif
    }

    /// The "rank_5_reached" asset catalog image.
    static var rank5Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank5Reached)
#else
        .init()
#endif
    }

    /// The "rank_6_reached" asset catalog image.
    static var rank6Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank6Reached)
#else
        .init()
#endif
    }

    /// The "rank_7_reached" asset catalog image.
    static var rank7Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank7Reached)
#else
        .init()
#endif
    }

    /// The "rank_8_reached" asset catalog image.
    static var rank8Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank8Reached)
#else
        .init()
#endif
    }

    /// The "rank_9_reached" asset catalog image.
    static var rank9Reached: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rank9Reached)
#else
        .init()
#endif
    }

    /// The "rank_locked_icon" asset catalog image.
    static var rankLockedIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rankLockedIcon)
#else
        .init()
#endif
    }

    /// The "rank_locked_img" asset catalog image.
    static var rankLockedImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rankLockedImg)
#else
        .init()
#endif
    }

    /// The "rank_unlock" asset catalog image.
    static var rankUnlock: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rankUnlock)
#else
        .init()
#endif
    }

    /// The "report_calories_source_icon" asset catalog image.
    static var reportCaloriesSourceIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportCaloriesSourceIcon)
#else
        .init()
#endif
    }

    /// The "report_daily_calories_bg_icon" asset catalog image.
    static var reportDailyCaloriesBgIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportDailyCaloriesBgIcon)
#else
        .init()
#endif
    }

    /// The "report_daily_carbo_icon" asset catalog image.
    static var reportDailyCarboIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportDailyCarboIcon)
#else
        .init()
#endif
    }

    /// The "report_daily_fat_icon" asset catalog image.
    static var reportDailyFatIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportDailyFatIcon)
#else
        .init()
#endif
    }

    /// The "report_daily_protein_icon" asset catalog image.
    static var reportDailyProteinIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportDailyProteinIcon)
#else
        .init()
#endif
    }

    /// The "report_ela_img" asset catalog image.
    static var reportElaImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportElaImg)
#else
        .init()
#endif
    }

    /// The "report_week_nodata_img" asset catalog image.
    static var reportWeekNodataImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportWeekNodataImg)
#else
        .init()
#endif
    }

    /// The "report_weight_down_icon" asset catalog image.
    static var reportWeightDownIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportWeightDownIcon)
#else
        .init()
#endif
    }

    /// The "report_weight_up_icon" asset catalog image.
    static var reportWeightUpIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reportWeightUpIcon)
#else
        .init()
#endif
    }

    /// The "rule_journal_alert_img" asset catalog image.
    static var ruleJournalAlertImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ruleJournalAlertImg)
#else
        .init()
#endif
    }

    /// The "rule_journal_alert_img_protein" asset catalog image.
    static var ruleJournalAlertImgProtein: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ruleJournalAlertImgProtein)
#else
        .init()
#endif
    }

    /// The "ruler_cover_bottom" asset catalog image.
    static var rulerCoverBottom: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rulerCoverBottom)
#else
        .init()
#endif
    }

    /// The "ruler_cover_top" asset catalog image.
    static var rulerCoverTop: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rulerCoverTop)
#else
        .init()
#endif
    }

    /// The "seach_icon" asset catalog image.
    static var seachIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .seachIcon)
#else
        .init()
#endif
    }

    /// The "search_clear_icon" asset catalog image.
    static var searchClearIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .searchClearIcon)
#else
        .init()
#endif
    }

    /// The "search_icon" asset catalog image.
    static var searchIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .searchIcon)
#else
        .init()
#endif
    }

    /// The "service_add_bg" asset catalog image.
    static var serviceAddBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .serviceAddBg)
#else
        .init()
#endif
    }

    /// The "service_album_icon" asset catalog image.
    static var serviceAlbumIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .serviceAlbumIcon)
#else
        .init()
#endif
    }

    /// The "service_camera_icon" asset catalog image.
    static var serviceCameraIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .serviceCameraIcon)
#else
        .init()
#endif
    }

    /// The "service_img_add_icon" asset catalog image.
    static var serviceImgAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .serviceImgAddIcon)
#else
        .init()
#endif
    }

    /// The "service_img_add_icon 1" asset catalog image.
    static var serviceImgAddIcon1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .serviceImgAddIcon1)
#else
        .init()
#endif
    }

    /// The "service_order_icon" asset catalog image.
    static var serviceOrderIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .serviceOrderIcon)
#else
        .init()
#endif
    }

    /// The "service_type_advice" asset catalog image.
    static var serviceTypeAdvice: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .serviceTypeAdvice)
#else
        .init()
#endif
    }

    /// The "service_type_market" asset catalog image.
    static var serviceTypeMarket: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .serviceTypeMarket)
#else
        .init()
#endif
    }

    /// The "sex_icon_feman" asset catalog image.
    static var sexIconFeman: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sexIconFeman)
#else
        .init()
#endif
    }

    /// The "sex_icon_feman_normal" asset catalog image.
    static var sexIconFemanNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sexIconFemanNormal)
#else
        .init()
#endif
    }

    /// The "sex_icon_man" asset catalog image.
    static var sexIconMan: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sexIconMan)
#else
        .init()
#endif
    }

    /// The "sex_icon_man_normal" asset catalog image.
    static var sexIconManNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sexIconManNormal)
#else
        .init()
#endif
    }

    /// The "share_icon_shadow" asset catalog image.
    static var shareIconShadow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .shareIconShadow)
#else
        .init()
#endif
    }

    /// The "slogan_notext" asset catalog image.
    static var sloganNotext: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sloganNotext)
#else
        .init()
#endif
    }

    /// The "sport_add_icon" asset catalog image.
    static var sportAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sportAddIcon)
#else
        .init()
#endif
    }

    /// The "sport_calories_icon" asset catalog image.
    static var sportCaloriesIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sportCaloriesIcon)
#else
        .init()
#endif
    }

    /// The "sport_time_icon" asset catalog image.
    static var sportTimeIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sportTimeIcon)
#else
        .init()
#endif
    }

    /// The "stat_calendar_close_icon" asset catalog image.
    static var statCalendarCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .statCalendarCloseIcon)
#else
        .init()
#endif
    }

    /// The "stat_fitness_tips_alert_img" asset catalog image.
    static var statFitnessTipsAlertImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .statFitnessTipsAlertImg)
#else
        .init()
#endif
    }

    /// The "stat_top_foods_first" asset catalog image.
    static var statTopFoodsFirst: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .statTopFoodsFirst)
#else
        .init()
#endif
    }

    /// The "stat_top_foods_second" asset catalog image.
    static var statTopFoodsSecond: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .statTopFoodsSecond)
#else
        .init()
#endif
    }

    /// The "stat_top_foods_third" asset catalog image.
    static var statTopFoodsThird: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .statTopFoodsThird)
#else
        .init()
#endif
    }

    /// The "streak_close_icon" asset catalog image.
    static var streakCloseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakCloseIcon)
#else
        .init()
#endif
    }

    /// The "streak_icon_1" asset catalog image.
    static var streakIcon1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIcon1)
#else
        .init()
#endif
    }

    /// The "streak_icon_2" asset catalog image.
    static var streakIcon2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIcon2)
#else
        .init()
#endif
    }

    /// The "streak_icon_3" asset catalog image.
    static var streakIcon3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIcon3)
#else
        .init()
#endif
    }

    /// The "streak_icon_4" asset catalog image.
    static var streakIcon4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIcon4)
#else
        .init()
#endif
    }

    /// The "streak_icon_5" asset catalog image.
    static var streakIcon5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIcon5)
#else
        .init()
#endif
    }

    /// The "streak_icon_6" asset catalog image.
    static var streakIcon6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIcon6)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_1" asset catalog image.
    static var streakIconGray1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIconGray1)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_2" asset catalog image.
    static var streakIconGray2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIconGray2)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_3" asset catalog image.
    static var streakIconGray3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIconGray3)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_4" asset catalog image.
    static var streakIconGray4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIconGray4)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_5" asset catalog image.
    static var streakIconGray5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIconGray5)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_6" asset catalog image.
    static var streakIconGray6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .streakIconGray6)
#else
        .init()
#endif
    }

    /// The "tabbar_center_icon" asset catalog image.
    static var tabbarCenterIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarCenterIcon)
#else
        .init()
#endif
    }

    /// The "tabbar_forum_normal" asset catalog image.
    static var tabbarForumNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarForumNormal)
#else
        .init()
#endif
    }

    /// The "tabbar_forum_normal_dark" asset catalog image.
    static var tabbarForumNormalDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarForumNormalDark)
#else
        .init()
#endif
    }

    /// The "tabbar_forum_selected" asset catalog image.
    static var tabbarForumSelected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarForumSelected)
#else
        .init()
#endif
    }

    /// The "tabbar_forum_selected_dark" asset catalog image.
    static var tabbarForumSelectedDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarForumSelectedDark)
#else
        .init()
#endif
    }

    /// The "tabbar_logs_normal" asset catalog image.
    static var tabbarLogsNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarLogsNormal)
#else
        .init()
#endif
    }

    /// The "tabbar_logs_normal_dark" asset catalog image.
    static var tabbarLogsNormalDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarLogsNormalDark)
#else
        .init()
#endif
    }

    /// The "tabbar_logs_selected" asset catalog image.
    static var tabbarLogsSelected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarLogsSelected)
#else
        .init()
#endif
    }

    /// The "tabbar_logs_selected_dark" asset catalog image.
    static var tabbarLogsSelectedDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarLogsSelectedDark)
#else
        .init()
#endif
    }

    /// The "tabbar_main_normal" asset catalog image.
    static var tabbarMainNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarMainNormal)
#else
        .init()
#endif
    }

    /// The "tabbar_main_normal_dark" asset catalog image.
    static var tabbarMainNormalDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarMainNormalDark)
#else
        .init()
#endif
    }

    /// The "tabbar_main_selected" asset catalog image.
    static var tabbarMainSelected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarMainSelected)
#else
        .init()
#endif
    }

    /// The "tabbar_main_selected_dark" asset catalog image.
    static var tabbarMainSelectedDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarMainSelectedDark)
#else
        .init()
#endif
    }

    /// The "tabbar_mine_normal" asset catalog image.
    static var tabbarMineNormal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarMineNormal)
#else
        .init()
#endif
    }

    /// The "tabbar_mine_normal_dark" asset catalog image.
    static var tabbarMineNormalDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarMineNormalDark)
#else
        .init()
#endif
    }

    /// The "tabbar_mine_selected" asset catalog image.
    static var tabbarMineSelected: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarMineSelected)
#else
        .init()
#endif
    }

    /// The "tabbar_mine_selected_dark" asset catalog image.
    static var tabbarMineSelectedDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarMineSelectedDark)
#else
        .init()
#endif
    }

    /// The "tips_gray_icon" asset catalog image.
    static var tipsGrayIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tipsGrayIcon)
#else
        .init()
#endif
    }

    /// The "tips_gray_icon_w" asset catalog image.
    static var tipsGrayIconW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tipsGrayIconW)
#else
        .init()
#endif
    }

    /// The "tutorial_arrow_down" asset catalog image.
    static var tutorialArrowDown: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialArrowDown)
#else
        .init()
#endif
    }

    /// The "tutorial_arrow_up" asset catalog image.
    static var tutorialArrowUp: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialArrowUp)
#else
        .init()
#endif
    }

    /// The "tutorial_back_10_seconds" asset catalog image.
    static var tutorialBack10Seconds: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialBack10Seconds)
#else
        .init()
#endif
    }

    /// The "tutorial_back_10_seconds_highlight" asset catalog image.
    static var tutorialBack10SecondsHighlight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialBack10SecondsHighlight)
#else
        .init()
#endif
    }

    /// The "tutorial_back_icon" asset catalog image.
    static var tutorialBackIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialBackIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_forward_10_seconds" asset catalog image.
    static var tutorialForward10Seconds: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialForward10Seconds)
#else
        .init()
#endif
    }

    /// The "tutorial_forward_10_seconds_highlight" asset catalog image.
    static var tutorialForward10SecondsHighlight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialForward10SecondsHighlight)
#else
        .init()
#endif
    }

    /// The "tutorial_full_screen_icon" asset catalog image.
    static var tutorialFullScreenIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialFullScreenIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_mini_screen_icon" asset catalog image.
    static var tutorialMiniScreenIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialMiniScreenIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_next_icon" asset catalog image.
    static var tutorialNextIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialNextIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_playing_icon" asset catalog image.
    static var tutorialPlayingIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialPlayingIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_share_icon" asset catalog image.
    static var tutorialShareIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialShareIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_visible_icon" asset catalog image.
    static var tutorialVisibleIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialVisibleIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_1_1_1" asset catalog image.
    static var tutorials111: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials111)
#else
        .init()
#endif
    }

    /// The "tutorials_1_1_2" asset catalog image.
    static var tutorials112: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials112)
#else
        .init()
#endif
    }

    /// The "tutorials_1_2_1" asset catalog image.
    static var tutorials121: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials121)
#else
        .init()
#endif
    }

    /// The "tutorials_1_2_2" asset catalog image.
    static var tutorials122: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials122)
#else
        .init()
#endif
    }

    /// The "tutorials_1_2_3" asset catalog image.
    static var tutorials123: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials123)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_1" asset catalog image.
    static var tutorials131: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials131)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_1_1" asset catalog image.
    static var tutorials1311: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials1311)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_1_2" asset catalog image.
    static var tutorials1312: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials1312)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_1_3" asset catalog image.
    static var tutorials1313: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials1313)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_2" asset catalog image.
    static var tutorials132: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials132)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_1" asset catalog image.
    static var tutorials141: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials141)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_2" asset catalog image.
    static var tutorials142: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials142)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_3" asset catalog image.
    static var tutorials143: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials143)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_4" asset catalog image.
    static var tutorials144: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials144)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_4_2" asset catalog image.
    static var tutorials1442: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials1442)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_4_3" asset catalog image.
    static var tutorials1443: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials1443)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_5" asset catalog image.
    static var tutorials145: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials145)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_6" asset catalog image.
    static var tutorials146: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials146)
#else
        .init()
#endif
    }

    /// The "tutorials_1_5_1" asset catalog image.
    static var tutorials151: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials151)
#else
        .init()
#endif
    }

    /// The "tutorials_1_5_2" asset catalog image.
    static var tutorials152: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials152)
#else
        .init()
#endif
    }

    /// The "tutorials_1_5_3" asset catalog image.
    static var tutorials153: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials153)
#else
        .init()
#endif
    }

    /// The "tutorials_1_6_1" asset catalog image.
    static var tutorials161: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials161)
#else
        .init()
#endif
    }

    /// The "tutorials_1_6_2" asset catalog image.
    static var tutorials162: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials162)
#else
        .init()
#endif
    }

    /// The "tutorials_1_6_3" asset catalog image.
    static var tutorials163: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials163)
#else
        .init()
#endif
    }

    /// The "tutorials_1_7_1" asset catalog image.
    static var tutorials171: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials171)
#else
        .init()
#endif
    }

    /// The "tutorials_1_7_2" asset catalog image.
    static var tutorials172: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials172)
#else
        .init()
#endif
    }

    /// The "tutorials_1_7_3" asset catalog image.
    static var tutorials173: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials173)
#else
        .init()
#endif
    }

    /// The "tutorials_1_8_1" asset catalog image.
    static var tutorials181: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials181)
#else
        .init()
#endif
    }

    /// The "tutorials_1_8_2" asset catalog image.
    static var tutorials182: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials182)
#else
        .init()
#endif
    }

    /// The "tutorials_2_1_1" asset catalog image.
    static var tutorials211: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials211)
#else
        .init()
#endif
    }

    /// The "tutorials_2_1_2" asset catalog image.
    static var tutorials212: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials212)
#else
        .init()
#endif
    }

    /// The "tutorials_2_1_3" asset catalog image.
    static var tutorials213: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials213)
#else
        .init()
#endif
    }

    /// The "tutorials_3_1_1" asset catalog image.
    static var tutorials311: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials311)
#else
        .init()
#endif
    }

    /// The "tutorials_3_1_2" asset catalog image.
    static var tutorials312: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials312)
#else
        .init()
#endif
    }

    /// The "tutorials_3_1_3" asset catalog image.
    static var tutorials313: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials313)
#else
        .init()
#endif
    }

    /// The "tutorials_4_1_1" asset catalog image.
    static var tutorials411: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials411)
#else
        .init()
#endif
    }

    /// The "tutorials_4_1_2" asset catalog image.
    static var tutorials412: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials412)
#else
        .init()
#endif
    }

    /// The "tutorials_4_2_1" asset catalog image.
    static var tutorials421: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials421)
#else
        .init()
#endif
    }

    /// The "tutorials_4_2_2" asset catalog image.
    static var tutorials422: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials422)
#else
        .init()
#endif
    }

    /// The "tutorials_4_2_3" asset catalog image.
    static var tutorials423: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials423)
#else
        .init()
#endif
    }

    /// The "tutorials_4_2_4" asset catalog image.
    static var tutorials424: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials424)
#else
        .init()
#endif
    }

    /// The "tutorials_4_3_1" asset catalog image.
    static var tutorials431: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials431)
#else
        .init()
#endif
    }

    /// The "tutorials_4_3_2" asset catalog image.
    static var tutorials432: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials432)
#else
        .init()
#endif
    }

    /// The "tutorials_5_1_1" asset catalog image.
    static var tutorials511: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials511)
#else
        .init()
#endif
    }

    /// The "tutorials_5_1_2" asset catalog image.
    static var tutorials512: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorials512)
#else
        .init()
#endif
    }

    /// The "tutorials_add_icon" asset catalog image.
    static var tutorialsAddIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsAddIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_down_arrow_icon" asset catalog image.
    static var tutorialsDownArrowIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsDownArrowIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_eat_icon" asset catalog image.
    static var tutorialsEatIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsEatIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_edit_icon" asset catalog image.
    static var tutorialsEditIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsEditIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_plan_list_icon" asset catalog image.
    static var tutorialsPlanListIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsPlanListIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_setting_icon" asset catalog image.
    static var tutorialsSettingIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsSettingIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_share_icon" asset catalog image.
    static var tutorialsShareIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsShareIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_share_icon_theme" asset catalog image.
    static var tutorialsShareIconTheme: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsShareIconTheme)
#else
        .init()
#endif
    }

    /// The "tutorials_step_1" asset catalog image.
    static var tutorialsStep1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsStep1)
#else
        .init()
#endif
    }

    /// The "tutorials_step_2" asset catalog image.
    static var tutorialsStep2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsStep2)
#else
        .init()
#endif
    }

    /// The "tutorials_step_3" asset catalog image.
    static var tutorialsStep3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsStep3)
#else
        .init()
#endif
    }

    /// The "tutorials_step_4" asset catalog image.
    static var tutorialsStep4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsStep4)
#else
        .init()
#endif
    }

    /// The "tutorials_step_5" asset catalog image.
    static var tutorialsStep5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tutorialsStep5)
#else
        .init()
#endif
    }

    /// The "video_edit_album_icon" asset catalog image.
    static var videoEditAlbumIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoEditAlbumIcon)
#else
        .init()
#endif
    }

    /// The "video_pause_icon" asset catalog image.
    static var videoPauseIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoPauseIcon)
#else
        .init()
#endif
    }

    /// The "video_pause_icon_1" asset catalog image.
    static var videoPauseIcon1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoPauseIcon1)
#else
        .init()
#endif
    }

    /// The "video_pause_icon_landscap" asset catalog image.
    static var videoPauseIconLandscap: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoPauseIconLandscap)
#else
        .init()
#endif
    }

    /// The "video_pause_icon_landscap_1" asset catalog image.
    static var videoPauseIconLandscap1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoPauseIconLandscap1)
#else
        .init()
#endif
    }

    /// The "video_play_icon" asset catalog image.
    static var videoPlayIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoPlayIcon)
#else
        .init()
#endif
    }

    /// The "video_play_icon_1" asset catalog image.
    static var videoPlayIcon1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoPlayIcon1)
#else
        .init()
#endif
    }

    /// The "video_play_icon_landscap" asset catalog image.
    static var videoPlayIconLandscap: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoPlayIconLandscap)
#else
        .init()
#endif
    }

    /// The "video_play_icon_landscap_1" asset catalog image.
    static var videoPlayIconLandscap1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .videoPlayIconLandscap1)
#else
        .init()
#endif
    }

    /// The "welcome_logo_icon" asset catalog image.
    static var welcomeLogoIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .welcomeLogoIcon)
#else
        .init()
#endif
    }

    /// The "widget_bg_bottom" asset catalog image.
    static var widgetBgBottom: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .widgetBgBottom)
#else
        .init()
#endif
    }

    /// The "withdraw_bank_icon" asset catalog image.
    static var withdrawBankIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .withdrawBankIcon)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Image" asset catalog image.
    static var image: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .image)
#else
        .init()
#endif
    }

    /// The "ai_alert_close_icon" asset catalog image.
    static var aiAlertCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiAlertCloseIcon)
#else
        .init()
#endif
    }

    /// The "ai_back_icon" asset catalog image.
    static var aiBackIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiBackIcon)
#else
        .init()
#endif
    }

    /// The "ai_camera_album_icon" asset catalog image.
    static var aiCameraAlbumIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiCameraAlbumIcon)
#else
        .init()
#endif
    }

    /// The "ai_camera_box_foods" asset catalog image.
    static var aiCameraBoxFoods: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiCameraBoxFoods)
#else
        .init()
#endif
    }

    /// The "ai_camera_box_ingredient" asset catalog image.
    static var aiCameraBoxIngredient: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiCameraBoxIngredient)
#else
        .init()
#endif
    }

    /// The "ai_camera_box_ingredient_tran" asset catalog image.
    static var aiCameraBoxIngredientTran: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiCameraBoxIngredientTran)
#else
        .init()
#endif
    }

    /// The "ai_camera_flash_icon" asset catalog image.
    static var aiCameraFlashIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiCameraFlashIcon)
#else
        .init()
#endif
    }

    /// The "ai_camera_flash_normal_icon" asset catalog image.
    static var aiCameraFlashNormalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiCameraFlashNormalIcon)
#else
        .init()
#endif
    }

    /// The "ai_identify_fail_img" asset catalog image.
    static var aiIdentifyFailImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiIdentifyFailImg)
#else
        .init()
#endif
    }

    /// The "ai_photo_take_icon" asset catalog image.
    static var aiPhotoTakeIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiPhotoTakeIcon)
#else
        .init()
#endif
    }

    /// The "ai_progress_cancel_icon" asset catalog image.
    static var aiProgressCancelIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiProgressCancelIcon)
#else
        .init()
#endif
    }

    /// The "ai_progress_complete_icon" asset catalog image.
    static var aiProgressCompleteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiProgressCompleteIcon)
#else
        .init()
#endif
    }

    /// The "ai_tips_alert_error_icon" asset catalog image.
    static var aiTipsAlertErrorIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTipsAlertErrorIcon)
#else
        .init()
#endif
    }

    /// The "ai_tips_alert_error_img" asset catalog image.
    static var aiTipsAlertErrorImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTipsAlertErrorImg)
#else
        .init()
#endif
    }

    /// The "ai_tips_alert_right_icon" asset catalog image.
    static var aiTipsAlertRightIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTipsAlertRightIcon)
#else
        .init()
#endif
    }

    /// The "ai_tips_alert_right_img" asset catalog image.
    static var aiTipsAlertRightImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTipsAlertRightImg)
#else
        .init()
#endif
    }

    /// The "ai_tips_icon" asset catalog image.
    static var aiTipsIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTipsIcon)
#else
        .init()
#endif
    }

    /// The "ai_type_foods_icon" asset catalog image.
    static var aiTypeFoodsIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTypeFoodsIcon)
#else
        .init()
#endif
    }

    /// The "ai_type_foods_normal_icon" asset catalog image.
    static var aiTypeFoodsNormalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTypeFoodsNormalIcon)
#else
        .init()
#endif
    }

    /// The "ai_type_ingredient_icon" asset catalog image.
    static var aiTypeIngredientIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTypeIngredientIcon)
#else
        .init()
#endif
    }

    /// The "ai_type_ingredient_normal_icon" asset catalog image.
    static var aiTypeIngredientNormalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aiTypeIngredientNormalIcon)
#else
        .init()
#endif
    }

    /// The "alert_close_icon" asset catalog image.
    static var alertCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .alertCloseIcon)
#else
        .init()
#endif
    }

    /// The "alert_warning_icon" asset catalog image.
    static var alertWarningIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .alertWarningIcon)
#else
        .init()
#endif
    }

    /// The "arrow_img_down" asset catalog image.
    static var arrowImgDown: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .arrowImgDown)
#else
        .init()
#endif
    }

    /// The "avatar_default" asset catalog image.
    static var avatarDefault: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .avatarDefault)
#else
        .init()
#endif
    }

    /// The "avatar_default_new" asset catalog image.
    static var avatarDefaultNew: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .avatarDefaultNew)
#else
        .init()
#endif
    }

    /// The "back_arrow" asset catalog image.
    static var backArrow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backArrow)
#else
        .init()
#endif
    }

    /// The "back_arrow_highlight" asset catalog image.
    static var backArrowHighlight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backArrowHighlight)
#else
        .init()
#endif
    }

    /// The "back_arrow_white_icon" asset catalog image.
    static var backArrowWhiteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backArrowWhiteIcon)
#else
        .init()
#endif
    }

    /// The "back_arrow_white_icon_light" asset catalog image.
    static var backArrowWhiteIconLight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backArrowWhiteIconLight)
#else
        .init()
#endif
    }

    /// The "back_arrow_white_icon_max" asset catalog image.
    static var backArrowWhiteIconMax: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backArrowWhiteIconMax)
#else
        .init()
#endif
    }

    /// The "back_arrow_white_shadow" asset catalog image.
    static var backArrowWhiteShadow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backArrowWhiteShadow)
#else
        .init()
#endif
    }

    /// The "back_close_icon" asset catalog image.
    static var backCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backCloseIcon)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_1" asset catalog image.
    static var bodyFatFeman1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman1)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_2" asset catalog image.
    static var bodyFatFeman2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman2)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_3" asset catalog image.
    static var bodyFatFeman3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman3)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_4" asset catalog image.
    static var bodyFatFeman4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman4)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_5" asset catalog image.
    static var bodyFatFeman5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman5)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_6" asset catalog image.
    static var bodyFatFeman6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman6)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_7" asset catalog image.
    static var bodyFatFeman7: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman7)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_8" asset catalog image.
    static var bodyFatFeman8: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman8)
#else
        .init()
#endif
    }

    /// The "body_fat_feman_9" asset catalog image.
    static var bodyFatFeman9: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatFeman9)
#else
        .init()
#endif
    }

    /// The "body_fat_img_cover" asset catalog image.
    static var bodyFatImgCover: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatImgCover)
#else
        .init()
#endif
    }

    /// The "body_fat_man_1" asset catalog image.
    static var bodyFatMan1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan1)
#else
        .init()
#endif
    }

    /// The "body_fat_man_2" asset catalog image.
    static var bodyFatMan2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan2)
#else
        .init()
#endif
    }

    /// The "body_fat_man_3" asset catalog image.
    static var bodyFatMan3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan3)
#else
        .init()
#endif
    }

    /// The "body_fat_man_4" asset catalog image.
    static var bodyFatMan4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan4)
#else
        .init()
#endif
    }

    /// The "body_fat_man_5" asset catalog image.
    static var bodyFatMan5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan5)
#else
        .init()
#endif
    }

    /// The "body_fat_man_6" asset catalog image.
    static var bodyFatMan6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan6)
#else
        .init()
#endif
    }

    /// The "body_fat_man_7" asset catalog image.
    static var bodyFatMan7: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan7)
#else
        .init()
#endif
    }

    /// The "body_fat_man_8" asset catalog image.
    static var bodyFatMan8: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan8)
#else
        .init()
#endif
    }

    /// The "body_fat_man_9" asset catalog image.
    static var bodyFatMan9: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatMan9)
#else
        .init()
#endif
    }

    /// The "body_fat_select_icon" asset catalog image.
    static var bodyFatSelectIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bodyFatSelectIcon)
#else
        .init()
#endif
    }

    /// The "bottom_cover_img" asset catalog image.
    static var bottomCoverImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bottomCoverImg)
#else
        .init()
#endif
    }

    /// The "button_bg_white" asset catalog image.
    static var buttonBgWhite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .buttonBgWhite)
#else
        .init()
#endif
    }

    /// The "calories_widget_icon" asset catalog image.
    static var caloriesWidgetIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .caloriesWidgetIcon)
#else
        .init()
#endif
    }

    /// The "cancel_account_normal" asset catalog image.
    static var cancelAccountNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cancelAccountNormal)
#else
        .init()
#endif
    }

    /// The "cancel_account_selected" asset catalog image.
    static var cancelAccountSelected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cancelAccountSelected)
#else
        .init()
#endif
    }

    /// The "cancel_account_tips" asset catalog image.
    static var cancelAccountTips: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cancelAccountTips)
#else
        .init()
#endif
    }

    /// The "circle_change_icon" asset catalog image.
    static var circleChangeIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .circleChangeIcon)
#else
        .init()
#endif
    }

    /// The "circle_days_icon" asset catalog image.
    static var circleDaysIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .circleDaysIcon)
#else
        .init()
#endif
    }

    /// The "circle_today_normal_icon" asset catalog image.
    static var circleTodayNormalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .circleTodayNormalIcon)
#else
        .init()
#endif
    }

    /// The "circle_today_select_icon" asset catalog image.
    static var circleTodaySelectIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .circleTodaySelectIcon)
#else
        .init()
#endif
    }

    /// The "comment_func_copy_icon" asset catalog image.
    static var commentFuncCopyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .commentFuncCopyIcon)
#else
        .init()
#endif
    }

    /// The "comment_func_delete_icon" asset catalog image.
    static var commentFuncDeleteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .commentFuncDeleteIcon)
#else
        .init()
#endif
    }

    /// The "comment_func_report_icon" asset catalog image.
    static var commentFuncReportIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .commentFuncReportIcon)
#else
        .init()
#endif
    }

    /// The "control_widget_icon" asset catalog image.
    static var controlWidgetIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .controlWidgetIcon)
#else
        .init()
#endif
    }

    /// The "course_avtivity_bg" asset catalog image.
    static var courseAvtivityBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseAvtivityBg)
#else
        .init()
#endif
    }

    /// The "course_avtivity_bg_left" asset catalog image.
    static var courseAvtivityBgLeft: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseAvtivityBgLeft)
#else
        .init()
#endif
    }

    /// The "course_avtivity_bg_right" asset catalog image.
    static var courseAvtivityBgRight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseAvtivityBgRight)
#else
        .init()
#endif
    }

    /// The "course_coupon_delete_icon" asset catalog image.
    static var courseCouponDeleteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseCouponDeleteIcon)
#else
        .init()
#endif
    }

    /// The "course_last_close_icon" asset catalog image.
    static var courseLastCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseLastCloseIcon)
#else
        .init()
#endif
    }

    /// The "course_last_play_icon" asset catalog image.
    static var courseLastPlayIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseLastPlayIcon)
#else
        .init()
#endif
    }

    /// The "course_left_arrow_icon" asset catalog image.
    static var courseLeftArrowIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseLeftArrowIcon)
#else
        .init()
#endif
    }

    /// The "course_locked_icon" asset catalog image.
    static var courseLockedIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseLockedIcon)
#else
        .init()
#endif
    }

    /// The "course_number_icon" asset catalog image.
    static var courseNumberIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseNumberIcon)
#else
        .init()
#endif
    }

    /// The "course_order_delete_icon" asset catalog image.
    static var courseOrderDeleteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseOrderDeleteIcon)
#else
        .init()
#endif
    }

    /// The "course_pay_icon" asset catalog image.
    static var coursePayIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePayIcon)
#else
        .init()
#endif
    }

    /// The "course_pay_tips_close_icon" asset catalog image.
    static var coursePayTipsCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePayTipsCloseIcon)
#else
        .init()
#endif
    }

    /// The "course_pay_tips_ela_icon" asset catalog image.
    static var coursePayTipsElaIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePayTipsElaIcon)
#else
        .init()
#endif
    }

    /// The "course_pay_type_alipay" asset catalog image.
    static var coursePayTypeAlipay: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePayTypeAlipay)
#else
        .init()
#endif
    }

    /// The "course_pay_type_normal" asset catalog image.
    static var coursePayTypeNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePayTypeNormal)
#else
        .init()
#endif
    }

    /// The "course_pay_type_select" asset catalog image.
    static var coursePayTypeSelect: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePayTypeSelect)
#else
        .init()
#endif
    }

    /// The "course_pay_type_wechat" asset catalog image.
    static var coursePayTypeWechat: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePayTypeWechat)
#else
        .init()
#endif
    }

    /// The "course_pdf_download_icon" asset catalog image.
    static var coursePdfDownloadIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePdfDownloadIcon)
#else
        .init()
#endif
    }

    /// The "course_play_icon" asset catalog image.
    static var coursePlayIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coursePlayIcon)
#else
        .init()
#endif
    }

    /// The "course_right_arrow_icon" asset catalog image.
    static var courseRightArrowIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseRightArrowIcon)
#else
        .init()
#endif
    }

    /// The "course_share_icon" asset catalog image.
    static var courseShareIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseShareIcon)
#else
        .init()
#endif
    }

    /// The "course_title_avatar_icon" asset catalog image.
    static var courseTitleAvatarIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseTitleAvatarIcon)
#else
        .init()
#endif
    }

    /// The "course_video_play_icon" asset catalog image.
    static var courseVideoPlayIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseVideoPlayIcon)
#else
        .init()
#endif
    }

    /// The "course_video_playing_icon" asset catalog image.
    static var courseVideoPlayingIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .courseVideoPlayingIcon)
#else
        .init()
#endif
    }

    /// The "create_plan_add_foods_icon" asset catalog image.
    static var createPlanAddFoodsIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .createPlanAddFoodsIcon)
#else
        .init()
#endif
    }

    /// The "create_plan_arrow_down" asset catalog image.
    static var createPlanArrowDown: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .createPlanArrowDown)
#else
        .init()
#endif
    }

    /// The "create_plan_name_icon" asset catalog image.
    static var createPlanNameIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .createPlanNameIcon)
#else
        .init()
#endif
    }

    /// The "create_plan_syn_select" asset catalog image.
    static var createPlanSynSelect: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .createPlanSynSelect)
#else
        .init()
#endif
    }

    /// The "create_plan_weeks_icon" asset catalog image.
    static var createPlanWeeksIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .createPlanWeeksIcon)
#else
        .init()
#endif
    }

    /// The "data_add_icon" asset catalog image.
    static var dataAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataAddIcon)
#else
        .init()
#endif
    }

    /// The "data_add_icon_black" asset catalog image.
    static var dataAddIconBlack: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataAddIconBlack)
#else
        .init()
#endif
    }

    /// The "data_asc_icon" asset catalog image.
    static var dataAscIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataAscIcon)
#else
        .init()
#endif
    }

    /// The "data_custom_icon" asset catalog image.
    static var dataCustomIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataCustomIcon)
#else
        .init()
#endif
    }

    /// The "data_desc_icon" asset catalog image.
    static var dataDescIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataDescIcon)
#else
        .init()
#endif
    }

    /// The "data_img_clear_icon" asset catalog image.
    static var dataImgClearIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataImgClearIcon)
#else
        .init()
#endif
    }

    /// The "data_photo_default" asset catalog image.
    static var dataPhotoDefault: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataPhotoDefault)
#else
        .init()
#endif
    }

    /// The "data_ping_icon" asset catalog image.
    static var dataPingIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataPingIcon)
#else
        .init()
#endif
    }

    /// The "data_share_asc_icon" asset catalog image.
    static var dataShareAscIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataShareAscIcon)
#else
        .init()
#endif
    }

    /// The "data_share_bg" asset catalog image.
    static var dataShareBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataShareBg)
#else
        .init()
#endif
    }

    /// The "data_share_desc_icon" asset catalog image.
    static var dataShareDescIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataShareDescIcon)
#else
        .init()
#endif
    }

    /// The "data_share_highlight_circle" asset catalog image.
    static var dataShareHighlightCircle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataShareHighlightCircle)
#else
        .init()
#endif
    }

    /// The "data_share_ping_icon" asset catalog image.
    static var dataSharePingIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataSharePingIcon)
#else
        .init()
#endif
    }

    /// The "date_fliter_cancel_img" asset catalog image.
    static var dateFliterCancelImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dateFliterCancelImg)
#else
        .init()
#endif
    }

    /// The "date_fliter_confirm_img" asset catalog image.
    static var dateFliterConfirmImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dateFliterConfirmImg)
#else
        .init()
#endif
    }

    /// The "dietplan_bg_img" asset catalog image.
    static var dietplanBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dietplanBgImg)
#else
        .init()
#endif
    }

    /// The "dietplan_empty_img" asset catalog image.
    static var dietplanEmptyImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dietplanEmptyImg)
#else
        .init()
#endif
    }

    /// The "dietplan_pro_icon" asset catalog image.
    static var dietplanProIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dietplanProIcon)
#else
        .init()
#endif
    }

    /// The "donation_baby_img" asset catalog image.
    static var donationBabyImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationBabyImg)
#else
        .init()
#endif
    }

    /// The "donation_bg_img" asset catalog image.
    static var donationBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationBgImg)
#else
        .init()
#endif
    }

    /// The "donation_cell_bottom" asset catalog image.
    static var donationCellBottom: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationCellBottom)
#else
        .init()
#endif
    }

    /// The "donation_date_bg" asset catalog image.
    static var donationDateBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationDateBg)
#else
        .init()
#endif
    }

    /// The "donation_date_circle_icon" asset catalog image.
    static var donationDateCircleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationDateCircleIcon)
#else
        .init()
#endif
    }

    /// The "donation_empty_icon_1" asset catalog image.
    static var donationEmptyIcon1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationEmptyIcon1)
#else
        .init()
#endif
    }

    /// The "donation_empty_icon_2" asset catalog image.
    static var donationEmptyIcon2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationEmptyIcon2)
#else
        .init()
#endif
    }

    /// The "donation_juanzeng_text" asset catalog image.
    static var donationJuanzengText: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationJuanzengText)
#else
        .init()
#endif
    }

    /// The "donation_text_img" asset catalog image.
    static var donationTextImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationTextImg)
#else
        .init()
#endif
    }

    /// The "donation_top_logo" asset catalog image.
    static var donationTopLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationTopLogo)
#else
        .init()
#endif
    }

    /// The "ela_clear_icon" asset catalog image.
    static var elaClearIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaClearIcon)
#else
        .init()
#endif
    }

    /// The "ela_icon_img" asset catalog image.
    static var elaIconImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaIconImg)
#else
        .init()
#endif
    }

    /// The "ela_price_per_bg" asset catalog image.
    static var elaPricePerBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaPricePerBg)
#else
        .init()
#endif
    }

    /// The "ela_pro_2_bg" asset catalog image.
    static var elaPro2Bg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaPro2Bg)
#else
        .init()
#endif
    }

    /// The "ela_pro_4_bg" asset catalog image.
    static var elaPro4Bg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaPro4Bg)
#else
        .init()
#endif
    }

    /// The "ela_pro_bg" asset catalog image.
    static var elaProBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaProBg)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon" asset catalog image.
    static var elaProIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaProIcon)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon_2_1" asset catalog image.
    static var elaProIcon21: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaProIcon21)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon_2_2" asset catalog image.
    static var elaProIcon22: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaProIcon22)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon_2_3" asset catalog image.
    static var elaProIcon23: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaProIcon23)
#else
        .init()
#endif
    }

    /// The "ela_pro_icon_2_4" asset catalog image.
    static var elaProIcon24: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaProIcon24)
#else
        .init()
#endif
    }

    /// The "ela_pro_progress_bg" asset catalog image.
    static var elaProProgressBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaProProgressBg)
#else
        .init()
#endif
    }

    /// The "ela_tag_label_left_icon" asset catalog image.
    static var elaTagLabelLeftIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaTagLabelLeftIcon)
#else
        .init()
#endif
    }

    /// The "ela_tag_label_right_icon" asset catalog image.
    static var elaTagLabelRightIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .elaTagLabelRightIcon)
#else
        .init()
#endif
    }

    /// The "fitness_tips_icon" asset catalog image.
    static var fitnessTipsIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fitnessTipsIcon)
#else
        .init()
#endif
    }

    /// The "foods_add_quickly_icon" asset catalog image.
    static var foodsAddQuicklyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsAddQuicklyIcon)
#else
        .init()
#endif
    }

    /// The "foods_ai_icon" asset catalog image.
    static var foodsAiIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsAiIcon)
#else
        .init()
#endif
    }

    /// The "foods_calori_type_carbo" asset catalog image.
    static var foodsCaloriTypeCarbo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsCaloriTypeCarbo)
#else
        .init()
#endif
    }

    /// The "foods_calori_type_fats" asset catalog image.
    static var foodsCaloriTypeFats: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsCaloriTypeFats)
#else
        .init()
#endif
    }

    /// The "foods_calori_type_protein" asset catalog image.
    static var foodsCaloriTypeProtein: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsCaloriTypeProtein)
#else
        .init()
#endif
    }

    /// The "foods_create_icon_normal" asset catalog image.
    static var foodsCreateIconNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsCreateIconNormal)
#else
        .init()
#endif
    }

    /// The "foods_create_icon_soon" asset catalog image.
    static var foodsCreateIconSoon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsCreateIconSoon)
#else
        .init()
#endif
    }

    /// The "foods_merge_add_icon" asset catalog image.
    static var foodsMergeAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsMergeAddIcon)
#else
        .init()
#endif
    }

    /// The "foods_merge_add_icon_white" asset catalog image.
    static var foodsMergeAddIconWhite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsMergeAddIconWhite)
#else
        .init()
#endif
    }

    /// The "foods_merge_arrow_icon" asset catalog image.
    static var foodsMergeArrowIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsMergeArrowIcon)
#else
        .init()
#endif
    }

    /// The "foods_merge_calories_icon" asset catalog image.
    static var foodsMergeCaloriesIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsMergeCaloriesIcon)
#else
        .init()
#endif
    }

    /// The "foods_merge_edit_digit_icon" asset catalog image.
    static var foodsMergeEditDigitIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsMergeEditDigitIcon)
#else
        .init()
#endif
    }

    /// The "foods_merge_icon" asset catalog image.
    static var foodsMergeIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsMergeIcon)
#else
        .init()
#endif
    }

    /// The "foods_new_func_icon" asset catalog image.
    static var foodsNewFuncIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsNewFuncIcon)
#else
        .init()
#endif
    }

    /// The "foods_search_quickly_icon" asset catalog image.
    static var foodsSearchQuicklyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsSearchQuicklyIcon)
#else
        .init()
#endif
    }

    /// The "foods_type_selected_icon" asset catalog image.
    static var foodsTypeSelectedIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .foodsTypeSelectedIcon)
#else
        .init()
#endif
    }

    /// The "forum_ tutorial_img" asset catalog image.
    static var forumTutorialImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumTutorialImg)
#else
        .init()
#endif
    }

    /// The "forum_add_image_icon" asset catalog image.
    static var forumAddImageIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumAddImageIcon)
#else
        .init()
#endif
    }

    /// The "forum_aite_icon" asset catalog image.
    static var forumAiteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumAiteIcon)
#else
        .init()
#endif
    }

    /// The "forum_aiticle_icon" asset catalog image.
    static var forumAiticleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumAiticleIcon)
#else
        .init()
#endif
    }

    /// The "forum_comment_icon" asset catalog image.
    static var forumCommentIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumCommentIcon)
#else
        .init()
#endif
    }

    /// The "forum_comment_icon_max" asset catalog image.
    static var forumCommentIconMax: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumCommentIconMax)
#else
        .init()
#endif
    }

    /// The "forum_comment_icon_min" asset catalog image.
    static var forumCommentIconMin: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumCommentIconMin)
#else
        .init()
#endif
    }

    /// The "forum_commom_img_close_icon" asset catalog image.
    static var forumCommomImgCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumCommomImgCloseIcon)
#else
        .init()
#endif
    }

    /// The "forum_commom_img_icon" asset catalog image.
    static var forumCommomImgIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumCommomImgIcon)
#else
        .init()
#endif
    }

    /// The "forum_commone_icon" asset catalog image.
    static var forumCommoneIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumCommoneIcon)
#else
        .init()
#endif
    }

    /// The "forum_location_icon" asset catalog image.
    static var forumLocationIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumLocationIcon)
#else
        .init()
#endif
    }

    /// The "forum_msg_icon" asset catalog image.
    static var forumMsgIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumMsgIcon)
#else
        .init()
#endif
    }

    /// The "forum_notice_arrow_icon" asset catalog image.
    static var forumNoticeArrowIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumNoticeArrowIcon)
#else
        .init()
#endif
    }

    /// The "forum_player_mute_no_icon" asset catalog image.
    static var forumPlayerMuteNoIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumPlayerMuteNoIcon)
#else
        .init()
#endif
    }

    /// The "forum_player_mute_yes_icon" asset catalog image.
    static var forumPlayerMuteYesIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumPlayerMuteYesIcon)
#else
        .init()
#endif
    }

    /// The "forum_poll_icon" asset catalog image.
    static var forumPollIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumPollIcon)
#else
        .init()
#endif
    }

    /// The "forum_publish_icon" asset catalog image.
    static var forumPublishIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumPublishIcon)
#else
        .init()
#endif
    }

    /// The "forum_set_top_cancel_icon" asset catalog image.
    static var forumSetTopCancelIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumSetTopCancelIcon)
#else
        .init()
#endif
    }

    /// The "forum_set_top_icon" asset catalog image.
    static var forumSetTopIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumSetTopIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_black_icon" asset catalog image.
    static var forumShareBlackIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumShareBlackIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_circle_icon" asset catalog image.
    static var forumShareCircleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumShareCircleIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_copy_icon" asset catalog image.
    static var forumShareCopyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumShareCopyIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_delete_icon" asset catalog image.
    static var forumShareDeleteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumShareDeleteIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_icon" asset catalog image.
    static var forumShareIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumShareIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_report_icon" asset catalog image.
    static var forumShareReportIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumShareReportIcon)
#else
        .init()
#endif
    }

    /// The "forum_share_wechat_icon" asset catalog image.
    static var forumShareWechatIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumShareWechatIcon)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_highlight" asset catalog image.
    static var forumThumbsUpHighlight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumThumbsUpHighlight)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_highlight_max" asset catalog image.
    static var forumThumbsUpHighlightMax: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumThumbsUpHighlightMax)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_highlight_min" asset catalog image.
    static var forumThumbsUpHighlightMin: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumThumbsUpHighlightMin)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_max" asset catalog image.
    static var forumThumbsUpMax: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumThumbsUpMax)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_normal" asset catalog image.
    static var forumThumbsUpNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumThumbsUpNormal)
#else
        .init()
#endif
    }

    /// The "forum_thumbs_up_normal_min" asset catalog image.
    static var forumThumbsUpNormalMin: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumThumbsUpNormalMin)
#else
        .init()
#endif
    }

    /// The "forum_top_icon" asset catalog image.
    static var forumTopIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumTopIcon)
#else
        .init()
#endif
    }

    /// The "forum_tutorial_default_cover" asset catalog image.
    static var forumTutorialDefaultCover: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumTutorialDefaultCover)
#else
        .init()
#endif
    }

    /// The "forum_user_verify_icon" asset catalog image.
    static var forumUserVerifyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumUserVerifyIcon)
#else
        .init()
#endif
    }

    /// The "forum_video_play_icon" asset catalog image.
    static var forumVideoPlayIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumVideoPlayIcon)
#else
        .init()
#endif
    }

    /// The "forum_visible_icon" asset catalog image.
    static var forumVisibleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .forumVisibleIcon)
#else
        .init()
#endif
    }

    /// The "frame_0000" asset catalog image.
    static var frame0000: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0000)
#else
        .init()
#endif
    }

    /// The "frame_0001" asset catalog image.
    static var frame0001: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0001)
#else
        .init()
#endif
    }

    /// The "frame_0002" asset catalog image.
    static var frame0002: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0002)
#else
        .init()
#endif
    }

    /// The "frame_0003" asset catalog image.
    static var frame0003: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0003)
#else
        .init()
#endif
    }

    /// The "frame_0004" asset catalog image.
    static var frame0004: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0004)
#else
        .init()
#endif
    }

    /// The "frame_0005" asset catalog image.
    static var frame0005: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0005)
#else
        .init()
#endif
    }

    /// The "frame_0006" asset catalog image.
    static var frame0006: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0006)
#else
        .init()
#endif
    }

    /// The "frame_0007" asset catalog image.
    static var frame0007: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0007)
#else
        .init()
#endif
    }

    /// The "frame_0008" asset catalog image.
    static var frame0008: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0008)
#else
        .init()
#endif
    }

    /// The "frame_0009" asset catalog image.
    static var frame0009: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0009)
#else
        .init()
#endif
    }

    /// The "frame_0010" asset catalog image.
    static var frame0010: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0010)
#else
        .init()
#endif
    }

    /// The "frame_0011" asset catalog image.
    static var frame0011: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0011)
#else
        .init()
#endif
    }

    /// The "frame_0012" asset catalog image.
    static var frame0012: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0012)
#else
        .init()
#endif
    }

    /// The "frame_0013" asset catalog image.
    static var frame0013: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0013)
#else
        .init()
#endif
    }

    /// The "frame_0014" asset catalog image.
    static var frame0014: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0014)
#else
        .init()
#endif
    }

    /// The "frame_0015" asset catalog image.
    static var frame0015: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0015)
#else
        .init()
#endif
    }

    /// The "frame_0016" asset catalog image.
    static var frame0016: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0016)
#else
        .init()
#endif
    }

    /// The "frame_0017" asset catalog image.
    static var frame0017: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0017)
#else
        .init()
#endif
    }

    /// The "frame_0018" asset catalog image.
    static var frame0018: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0018)
#else
        .init()
#endif
    }

    /// The "frame_0019" asset catalog image.
    static var frame0019: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0019)
#else
        .init()
#endif
    }

    /// The "frame_0020" asset catalog image.
    static var frame0020: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0020)
#else
        .init()
#endif
    }

    /// The "frame_0021" asset catalog image.
    static var frame0021: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0021)
#else
        .init()
#endif
    }

    /// The "frame_0022" asset catalog image.
    static var frame0022: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0022)
#else
        .init()
#endif
    }

    /// The "frame_0023" asset catalog image.
    static var frame0023: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0023)
#else
        .init()
#endif
    }

    /// The "frame_0024" asset catalog image.
    static var frame0024: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0024)
#else
        .init()
#endif
    }

    /// The "frame_0025" asset catalog image.
    static var frame0025: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0025)
#else
        .init()
#endif
    }

    /// The "frame_0026" asset catalog image.
    static var frame0026: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0026)
#else
        .init()
#endif
    }

    /// The "frame_0027" asset catalog image.
    static var frame0027: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0027)
#else
        .init()
#endif
    }

    /// The "frame_0028" asset catalog image.
    static var frame0028: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0028)
#else
        .init()
#endif
    }

    /// The "frame_0029" asset catalog image.
    static var frame0029: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0029)
#else
        .init()
#endif
    }

    /// The "frame_0030" asset catalog image.
    static var frame0030: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0030)
#else
        .init()
#endif
    }

    /// The "frame_0031" asset catalog image.
    static var frame0031: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frame0031)
#else
        .init()
#endif
    }

    /// The "friend_list_edit_icon" asset catalog image.
    static var friendListEditIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListEditIcon)
#else
        .init()
#endif
    }

    /// The "friend_list_first" asset catalog image.
    static var friendListFirst: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListFirst)
#else
        .init()
#endif
    }

    /// The "friend_list_img" asset catalog image.
    static var friendListImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListImg)
#else
        .init()
#endif
    }

    /// The "friend_list_second" asset catalog image.
    static var friendListSecond: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListSecond)
#else
        .init()
#endif
    }

    /// The "friend_list_status_add" asset catalog image.
    static var friendListStatusAdd: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListStatusAdd)
#else
        .init()
#endif
    }

    /// The "friend_list_status_agree" asset catalog image.
    static var friendListStatusAgree: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListStatusAgree)
#else
        .init()
#endif
    }

    /// The "friend_list_status_disagree" asset catalog image.
    static var friendListStatusDisagree: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListStatusDisagree)
#else
        .init()
#endif
    }

    /// The "friend_list_status_pending" asset catalog image.
    static var friendListStatusPending: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListStatusPending)
#else
        .init()
#endif
    }

    /// The "friend_list_status_succesd" asset catalog image.
    static var friendListStatusSuccesd: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListStatusSuccesd)
#else
        .init()
#endif
    }

    /// The "friend_list_third" asset catalog image.
    static var friendListThird: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListThird)
#else
        .init()
#endif
    }

    /// The "friend_list_top_1" asset catalog image.
    static var friendListTop1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendListTop1)
#else
        .init()
#endif
    }

    /// The "friend_top_bg_img" asset catalog image.
    static var friendTopBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .friendTopBgImg)
#else
        .init()
#endif
    }

    /// The "goal_circle_icon" asset catalog image.
    static var goalCircleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .goalCircleIcon)
#else
        .init()
#endif
    }

    /// The "goal_circle_question" asset catalog image.
    static var goalCircleQuestion: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .goalCircleQuestion)
#else
        .init()
#endif
    }

    /// The "goal_zhineng_icon" asset catalog image.
    static var goalZhinengIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .goalZhinengIcon)
#else
        .init()
#endif
    }

    /// The "guide_back_button" asset catalog image.
    static var guideBackButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideBackButton)
#else
        .init()
#endif
    }

    /// The "guide_chat_box" asset catalog image.
    static var guideChatBox: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideChatBox)
#else
        .init()
#endif
    }

    /// The "guide_chat_box_2" asset catalog image.
    static var guideChatBox2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideChatBox2)
#else
        .init()
#endif
    }

    /// The "guide_chat_box_3" asset catalog image.
    static var guideChatBox3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideChatBox3)
#else
        .init()
#endif
    }

    /// The "guide_first_page_chart" asset catalog image.
    static var guideFirstPageChart: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideFirstPageChart)
#else
        .init()
#endif
    }

    /// The "guide_first_page_down_icon" asset catalog image.
    static var guideFirstPageDownIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideFirstPageDownIcon)
#else
        .init()
#endif
    }

    /// The "guide_first_page_logo_icon" asset catalog image.
    static var guideFirstPageLogoIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideFirstPageLogoIcon)
#else
        .init()
#endif
    }

    /// The "guide_first_page_up_icon" asset catalog image.
    static var guideFirstPageUpIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideFirstPageUpIcon)
#else
        .init()
#endif
    }

    /// The "guide_img_step_3" asset catalog image.
    static var guideImgStep3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideImgStep3)
#else
        .init()
#endif
    }

    /// The "guide_img_step_4" asset catalog image.
    static var guideImgStep4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideImgStep4)
#else
        .init()
#endif
    }

    /// The "guide_img_step_5" asset catalog image.
    static var guideImgStep5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideImgStep5)
#else
        .init()
#endif
    }

    /// The "guide_img_step_6" asset catalog image.
    static var guideImgStep6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideImgStep6)
#else
        .init()
#endif
    }

    /// The "guide_img_step_7" asset catalog image.
    static var guideImgStep7: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideImgStep7)
#else
        .init()
#endif
    }

    /// The "guide_img_step_7_circle" asset catalog image.
    static var guideImgStep7Circle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideImgStep7Circle)
#else
        .init()
#endif
    }

    /// The "guide_second_img_1" asset catalog image.
    static var guideSecondImg1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideSecondImg1)
#else
        .init()
#endif
    }

    /// The "guide_second_img_2" asset catalog image.
    static var guideSecondImg2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideSecondImg2)
#else
        .init()
#endif
    }

    /// The "guide_second_img_3" asset catalog image.
    static var guideSecondImg3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideSecondImg3)
#else
        .init()
#endif
    }

    /// The "guide_second_img_4" asset catalog image.
    static var guideSecondImg4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideSecondImg4)
#else
        .init()
#endif
    }

    /// The "guide_second_jijian" asset catalog image.
    static var guideSecondJijian: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideSecondJijian)
#else
        .init()
#endif
    }

    /// The "guide_second_zhuanye" asset catalog image.
    static var guideSecondZhuanye: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideSecondZhuanye)
#else
        .init()
#endif
    }

    /// The "guide_third_add_icon" asset catalog image.
    static var guideThirdAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guideThirdAddIcon)
#else
        .init()
#endif
    }

    /// The "habit_bg_ela_img" asset catalog image.
    static var habitBgElaImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitBgElaImg)
#else
        .init()
#endif
    }

    /// The "habit_exchange_tips_bg" asset catalog image.
    static var habitExchangeTipsBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitExchangeTipsBg)
#else
        .init()
#endif
    }

    /// The "habit_exchange_tips_ela_bg" asset catalog image.
    static var habitExchangeTipsElaBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitExchangeTipsElaBg)
#else
        .init()
#endif
    }

    /// The "habit_exchange_tips_title" asset catalog image.
    static var habitExchangeTipsTitle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitExchangeTipsTitle)
#else
        .init()
#endif
    }

    /// The "habit_guide_1_bg" asset catalog image.
    static var habitGuide1Bg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitGuide1Bg)
#else
        .init()
#endif
    }

    /// The "habit_guide_2_img" asset catalog image.
    static var habitGuide2Img: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitGuide2Img)
#else
        .init()
#endif
    }

    /// The "habit_guide_3_img" asset catalog image.
    static var habitGuide3Img: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitGuide3Img)
#else
        .init()
#endif
    }

    /// The "habit_guide_4_img" asset catalog image.
    static var habitGuide4Img: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitGuide4Img)
#else
        .init()
#endif
    }

    /// The "habit_guide_5_img" asset catalog image.
    static var habitGuide5Img: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitGuide5Img)
#else
        .init()
#endif
    }

    /// The "habit_guide_back_icon" asset catalog image.
    static var habitGuideBackIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitGuideBackIcon)
#else
        .init()
#endif
    }

    /// The "habit_guide_ela_icon" asset catalog image.
    static var habitGuideElaIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitGuideElaIcon)
#else
        .init()
#endif
    }

    /// The "habit_number_add_icon" asset catalog image.
    static var habitNumberAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitNumberAddIcon)
#else
        .init()
#endif
    }

    /// The "habit_number_sub_icon" asset catalog image.
    static var habitNumberSubIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitNumberSubIcon)
#else
        .init()
#endif
    }

    /// The "habit_rank_down_icon" asset catalog image.
    static var habitRankDownIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRankDownIcon)
#else
        .init()
#endif
    }

    /// The "habit_rank_right_icon" asset catalog image.
    static var habitRankRightIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRankRightIcon)
#else
        .init()
#endif
    }

    /// The "habit_rank_time_icon" asset catalog image.
    static var habitRankTimeIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRankTimeIcon)
#else
        .init()
#endif
    }

    /// The "habit_rank_up_icon" asset catalog image.
    static var habitRankUpIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRankUpIcon)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_empty_img" asset catalog image.
    static var habitRanklistEmptyImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRanklistEmptyImg)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_heart_icon" asset catalog image.
    static var habitRanklistHeartIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRanklistHeartIcon)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_one" asset catalog image.
    static var habitRanklistOne: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRanklistOne)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_three" asset catalog image.
    static var habitRanklistThree: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRanklistThree)
#else
        .init()
#endif
    }

    /// The "habit_ranklist_two" asset catalog image.
    static var habitRanklistTwo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRanklistTwo)
#else
        .init()
#endif
    }

    /// The "habit_rule_img_1" asset catalog image.
    static var habitRuleImg1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRuleImg1)
#else
        .init()
#endif
    }

    /// The "habit_rule_img_2" asset catalog image.
    static var habitRuleImg2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitRuleImg2)
#else
        .init()
#endif
    }

    /// The "habit_settle_bg_img" asset catalog image.
    static var habitSettleBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitSettleBgImg)
#else
        .init()
#endif
    }

    /// The "habit_settle_cup_shadow" asset catalog image.
    static var habitSettleCupShadow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitSettleCupShadow)
#else
        .init()
#endif
    }

    /// The "habit_settle_degree_left_icon" asset catalog image.
    static var habitSettleDegreeLeftIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitSettleDegreeLeftIcon)
#else
        .init()
#endif
    }

    /// The "habit_settle_degree_right_icon" asset catalog image.
    static var habitSettleDegreeRightIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitSettleDegreeRightIcon)
#else
        .init()
#endif
    }

    /// The "habit_settle_desk" asset catalog image.
    static var habitSettleDesk: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitSettleDesk)
#else
        .init()
#endif
    }

    /// The "habit_settle_list_bg" asset catalog image.
    static var habitSettleListBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .habitSettleListBg)
#else
        .init()
#endif
    }

    /// The "haibit_body_data_icon" asset catalog image.
    static var haibitBodyDataIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .haibitBodyDataIcon)
#else
        .init()
#endif
    }

    /// The "haibit_fitness_icon" asset catalog image.
    static var haibitFitnessIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .haibitFitnessIcon)
#else
        .init()
#endif
    }

    /// The "haibit_friend_icon" asset catalog image.
    static var haibitFriendIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .haibitFriendIcon)
#else
        .init()
#endif
    }

    /// The "haibit_friend_protein_icon" asset catalog image.
    static var haibitFriendProteinIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .haibitFriendProteinIcon)
#else
        .init()
#endif
    }

    /// The "haibit_journal_icon" asset catalog image.
    static var haibitJournalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .haibitJournalIcon)
#else
        .init()
#endif
    }

    /// The "haibit_protein_icon" asset catalog image.
    static var haibitProteinIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .haibitProteinIcon)
#else
        .init()
#endif
    }

    /// The "haibit_streak_normal_icon" asset catalog image.
    static var haibitStreakNormalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .haibitStreakNormalIcon)
#else
        .init()
#endif
    }

    /// The "honor_top_img" asset catalog image.
    static var honorTopImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .honorTopImg)
#else
        .init()
#endif
    }

    /// The "icon_90_gray" asset catalog image.
    static var icon90Gray: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon90Gray)
#else
        .init()
#endif
    }

    /// The "icon_95_blue" asset catalog image.
    static var icon95Blue: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .icon95Blue)
#else
        .init()
#endif
    }

    /// The "icon_calendar_gray" asset catalog image.
    static var iconCalendarGray: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconCalendarGray)
#else
        .init()
#endif
    }

    /// The "idc_icon_china" asset catalog image.
    static var idcIconChina: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .idcIconChina)
#else
        .init()
#endif
    }

    /// The "img_close_icon" asset catalog image.
    static var imgCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .imgCloseIcon)
#else
        .init()
#endif
    }

    /// The "invite_rewards_code_bg" asset catalog image.
    static var inviteRewardsCodeBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .inviteRewardsCodeBg)
#else
        .init()
#endif
    }

    /// The "journal_share_calories_icon" asset catalog image.
    static var journalShareCaloriesIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .journalShareCaloriesIcon)
#else
        .init()
#endif
    }

    /// The "journal_share_shadow_view" asset catalog image.
    static var journalShareShadowView: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .journalShareShadowView)
#else
        .init()
#endif
    }

    /// The "launch_bg_img" asset catalog image.
    static var launchBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchBgImg)
#else
        .init()
#endif
    }

    /// The "launch_slogan_img" asset catalog image.
    static var launchSloganImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchSloganImg)
#else
        .init()
#endif
    }

    /// The "launch_welcome_bg" asset catalog image.
    static var launchWelcomeBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchWelcomeBg)
#else
        .init()
#endif
    }

    /// The "launch_welcome_img_1" asset catalog image.
    static var launchWelcomeImg1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchWelcomeImg1)
#else
        .init()
#endif
    }

    /// The "launch_welcome_img_2" asset catalog image.
    static var launchWelcomeImg2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchWelcomeImg2)
#else
        .init()
#endif
    }

    /// The "launch_welcome_img_3" asset catalog image.
    static var launchWelcomeImg3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchWelcomeImg3)
#else
        .init()
#endif
    }

    /// The "log_share_bg_img" asset catalog image.
    static var logShareBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logShareBgImg)
#else
        .init()
#endif
    }

    /// The "login_alert_apple_icon" asset catalog image.
    static var loginAlertAppleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginAlertAppleIcon)
#else
        .init()
#endif
    }

    /// The "login_alert_phone_icon" asset catalog image.
    static var loginAlertPhoneIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginAlertPhoneIcon)
#else
        .init()
#endif
    }

    /// The "login_alert_wechat_icon" asset catalog image.
    static var loginAlertWechatIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginAlertWechatIcon)
#else
        .init()
#endif
    }

    /// The "login_apple_icon" asset catalog image.
    static var loginAppleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginAppleIcon)
#else
        .init()
#endif
    }

    /// The "login_arrow_down_icon" asset catalog image.
    static var loginArrowDownIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginArrowDownIcon)
#else
        .init()
#endif
    }

    /// The "login_close_img" asset catalog image.
    static var loginCloseImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginCloseImg)
#else
        .init()
#endif
    }

    /// The "login_wechat_icon" asset catalog image.
    static var loginWechatIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginWechatIcon)
#else
        .init()
#endif
    }

    /// The "logs_add_icon_theme" asset catalog image.
    static var logsAddIconTheme: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsAddIconTheme)
#else
        .init()
#endif
    }

    /// The "logs_add_icon_theme_cj" asset catalog image.
    static var logsAddIconThemeCj: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsAddIconThemeCj)
#else
        .init()
#endif
    }

    /// The "logs_circle_cover" asset catalog image.
    static var logsCircleCover: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsCircleCover)
#else
        .init()
#endif
    }

    /// The "logs_create_plan_icon" asset catalog image.
    static var logsCreatePlanIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsCreatePlanIcon)
#else
        .init()
#endif
    }

    /// The "logs_edit_all_normal" asset catalog image.
    static var logsEditAllNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsEditAllNormal)
#else
        .init()
#endif
    }

    /// The "logs_edit_selected" asset catalog image.
    static var logsEditSelected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsEditSelected)
#else
        .init()
#endif
    }

    /// The "logs_foods_copy_icon" asset catalog image.
    static var logsFoodsCopyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsFoodsCopyIcon)
#else
        .init()
#endif
    }

    /// The "logs_foods_eat_icon" asset catalog image.
    static var logsFoodsEatIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsFoodsEatIcon)
#else
        .init()
#endif
    }

    /// The "logs_foods_eat_icon_cj" asset catalog image.
    static var logsFoodsEatIconCj: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsFoodsEatIconCj)
#else
        .init()
#endif
    }

    /// The "logs_foods_meals_create_icon" asset catalog image.
    static var logsFoodsMealsCreateIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsFoodsMealsCreateIcon)
#else
        .init()
#endif
    }

    /// The "logs_natural_icon" asset catalog image.
    static var logsNaturalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsNaturalIcon)
#else
        .init()
#endif
    }

    /// The "logs_natural_icon_cj" asset catalog image.
    static var logsNaturalIconCj: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsNaturalIconCj)
#else
        .init()
#endif
    }

    /// The "logs_navi_list_icon" asset catalog image.
    static var logsNaviListIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsNaviListIcon)
#else
        .init()
#endif
    }

    /// The "logs_navi_share_icon" asset catalog image.
    static var logsNaviShareIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsNaviShareIcon)
#else
        .init()
#endif
    }

    /// The "logs_pen_icon" asset catalog image.
    static var logsPenIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsPenIcon)
#else
        .init()
#endif
    }

    /// The "logs_remark_add_icon" asset catalog image.
    static var logsRemarkAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsRemarkAddIcon)
#else
        .init()
#endif
    }

    /// The "logs_remark_arrow_down" asset catalog image.
    static var logsRemarkArrowDown: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsRemarkArrowDown)
#else
        .init()
#endif
    }

    /// The "logs_share_bg_img" asset catalog image.
    static var logsShareBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsShareBgImg)
#else
        .init()
#endif
    }

    /// The "logs_share_time_icon" asset catalog image.
    static var logsShareTimeIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logsShareTimeIcon)
#else
        .init()
#endif
    }

    /// The "main_add_data_button" asset catalog image.
    static var mainAddDataButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainAddDataButton)
#else
        .init()
#endif
    }

    /// The "main_circle_bg" asset catalog image.
    static var mainCircleBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainCircleBg)
#else
        .init()
#endif
    }

    /// The "main_edit_icon" asset catalog image.
    static var mainEditIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainEditIcon)
#else
        .init()
#endif
    }

    /// The "main_edit_icon_theme" asset catalog image.
    static var mainEditIconTheme: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainEditIconTheme)
#else
        .init()
#endif
    }

    /// The "main_nutrient_span_img" asset catalog image.
    static var mainNutrientSpanImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainNutrientSpanImg)
#else
        .init()
#endif
    }

    /// The "main_nutrient_span_img_2" asset catalog image.
    static var mainNutrientSpanImg2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainNutrientSpanImg2)
#else
        .init()
#endif
    }

    /// The "main_pencil_icon" asset catalog image.
    static var mainPencilIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainPencilIcon)
#else
        .init()
#endif
    }

    /// The "main_search_icon" asset catalog image.
    static var mainSearchIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainSearchIcon)
#else
        .init()
#endif
    }

    /// The "main_top_bg" asset catalog image.
    static var mainTopBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainTopBg)
#else
        .init()
#endif
    }

    /// The "main_top_bg_cj" asset catalog image.
    static var mainTopBgCj: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainTopBgCj)
#else
        .init()
#endif
    }

    /// The "main_top_logo" asset catalog image.
    static var mainTopLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainTopLogo)
#else
        .init()
#endif
    }

    /// The "main_top_logo_cj" asset catalog image.
    static var mainTopLogoCj: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainTopLogoCj)
#else
        .init()
#endif
    }

    /// The "main_top_logo_launch" asset catalog image.
    static var mainTopLogoLaunch: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainTopLogoLaunch)
#else
        .init()
#endif
    }

    /// The "mall_address_default_icon" asset catalog image.
    static var mallAddressDefaultIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallAddressDefaultIcon)
#else
        .init()
#endif
    }

    /// The "mall_address_delete_icon" asset catalog image.
    static var mallAddressDeleteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallAddressDeleteIcon)
#else
        .init()
#endif
    }

    /// The "mall_address_edit_icon" asset catalog image.
    static var mallAddressEditIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallAddressEditIcon)
#else
        .init()
#endif
    }

    /// The "mall_address_normal_icon" asset catalog image.
    static var mallAddressNormalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallAddressNormalIcon)
#else
        .init()
#endif
    }

    /// The "mall_detail_back_icon" asset catalog image.
    static var mallDetailBackIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallDetailBackIcon)
#else
        .init()
#endif
    }

    /// The "mall_detail_service_icon" asset catalog image.
    static var mallDetailServiceIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallDetailServiceIcon)
#else
        .init()
#endif
    }

    /// The "mall_detail_share_icon" asset catalog image.
    static var mallDetailShareIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallDetailShareIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_address_icon" asset catalog image.
    static var mallOrderAddressIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderAddressIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_detail_arrow_down" asset catalog image.
    static var mallOrderDetailArrowDown: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderDetailArrowDown)
#else
        .init()
#endif
    }

    /// The "mall_order_detail_arrow_top" asset catalog image.
    static var mallOrderDetailArrowTop: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderDetailArrowTop)
#else
        .init()
#endif
    }

    /// The "mall_order_idcard_icon" asset catalog image.
    static var mallOrderIdcardIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderIdcardIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_img_add_icon" asset catalog image.
    static var mallOrderImgAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderImgAddIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_img_clear_icon" asset catalog image.
    static var mallOrderImgClearIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderImgClearIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_num_add_icon" asset catalog image.
    static var mallOrderNumAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderNumAddIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_num_sub_icon" asset catalog image.
    static var mallOrderNumSubIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderNumSubIcon)
#else
        .init()
#endif
    }

    /// The "mall_order_success_icon" asset catalog image.
    static var mallOrderSuccessIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallOrderSuccessIcon)
#else
        .init()
#endif
    }

    /// The "mall_spec_arrow_down_icon" asset catalog image.
    static var mallSpecArrowDownIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mallSpecArrowDownIcon)
#else
        .init()
#endif
    }

    /// The "meals_create_camera" asset catalog image.
    static var mealsCreateCamera: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsCreateCamera)
#else
        .init()
#endif
    }

    /// The "meals_create_icon" asset catalog image.
    static var mealsCreateIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsCreateIcon)
#else
        .init()
#endif
    }

    /// The "meals_eat_add_icon" asset catalog image.
    static var mealsEatAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsEatAddIcon)
#else
        .init()
#endif
    }

    /// The "meals_eat_add_icon_theme" asset catalog image.
    static var mealsEatAddIconTheme: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsEatAddIconTheme)
#else
        .init()
#endif
    }

    /// The "meals_eat_add_icon_white" asset catalog image.
    static var mealsEatAddIconWhite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsEatAddIconWhite)
#else
        .init()
#endif
    }

    /// The "meals_eat_icon" asset catalog image.
    static var mealsEatIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsEatIcon)
#else
        .init()
#endif
    }

    /// The "meals_eat_right_icon" asset catalog image.
    static var mealsEatRightIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsEatRightIcon)
#else
        .init()
#endif
    }

    /// The "meals_foods_default" asset catalog image.
    static var mealsFoodsDefault: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsFoodsDefault)
#else
        .init()
#endif
    }

    /// The "meals_foods_photo" asset catalog image.
    static var mealsFoodsPhoto: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsFoodsPhoto)
#else
        .init()
#endif
    }

    /// The "meals_icon_default" asset catalog image.
    static var mealsIconDefault: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsIconDefault)
#else
        .init()
#endif
    }

    /// The "meals_top_bg" asset catalog image.
    static var mealsTopBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mealsTopBg)
#else
        .init()
#endif
    }

    /// The "mian_top_bg_whole" asset catalog image.
    static var mianTopBgWhole: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mianTopBgWhole)
#else
        .init()
#endif
    }

    /// The "mine_boday_data" asset catalog image.
    static var mineBodayData: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineBodayData)
#else
        .init()
#endif
    }

    /// The "mine_func_arrow" asset catalog image.
    static var mineFuncArrow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncArrow)
#else
        .init()
#endif
    }

    /// The "mine_func_arrow_icon" asset catalog image.
    static var mineFuncArrowIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncArrowIcon)
#else
        .init()
#endif
    }

    /// The "mine_func_create_plan" asset catalog image.
    static var mineFuncCreatePlan: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncCreatePlan)
#else
        .init()
#endif
    }

    /// The "mine_func_fasting" asset catalog image.
    static var mineFuncFasting: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncFasting)
#else
        .init()
#endif
    }

    /// The "mine_func_foods" asset catalog image.
    static var mineFuncFoods: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncFoods)
#else
        .init()
#endif
    }

    /// The "mine_func_forum_msg_icon" asset catalog image.
    static var mineFuncForumMsgIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncForumMsgIcon)
#else
        .init()
#endif
    }

    /// The "mine_func_friends" asset catalog image.
    static var mineFuncFriends: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncFriends)
#else
        .init()
#endif
    }

    /// The "mine_func_goal" asset catalog image.
    static var mineFuncGoal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncGoal)
#else
        .init()
#endif
    }

    /// The "mine_func_honor" asset catalog image.
    static var mineFuncHonor: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncHonor)
#else
        .init()
#endif
    }

    /// The "mine_func_invite" asset catalog image.
    static var mineFuncInvite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncInvite)
#else
        .init()
#endif
    }

    /// The "mine_func_meal" asset catalog image.
    static var mineFuncMeal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncMeal)
#else
        .init()
#endif
    }

    /// The "mine_func_order_list" asset catalog image.
    static var mineFuncOrderList: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncOrderList)
#else
        .init()
#endif
    }

    /// The "mine_func_personal_setting" asset catalog image.
    static var mineFuncPersonalSetting: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncPersonalSetting)
#else
        .init()
#endif
    }

    /// The "mine_func_plan" asset catalog image.
    static var mineFuncPlan: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncPlan)
#else
        .init()
#endif
    }

    /// The "mine_func_service" asset catalog image.
    static var mineFuncService: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncService)
#else
        .init()
#endif
    }

    /// The "mine_func_setting" asset catalog image.
    static var mineFuncSetting: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncSetting)
#else
        .init()
#endif
    }

    /// The "mine_func_stat" asset catalog image.
    static var mineFuncStat: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncStat)
#else
        .init()
#endif
    }

    /// The "mine_func_tutorials" asset catalog image.
    static var mineFuncTutorials: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineFuncTutorials)
#else
        .init()
#endif
    }

    /// The "mine_setting_logo" asset catalog image.
    static var mineSettingLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineSettingLogo)
#else
        .init()
#endif
    }

    /// The "mine_top_bg" asset catalog image.
    static var mineTopBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineTopBg)
#else
        .init()
#endif
    }

    /// The "mine_top_func_arrow" asset catalog image.
    static var mineTopFuncArrow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mineTopFuncArrow)
#else
        .init()
#endif
    }

    /// The "navi_back_white_icon" asset catalog image.
    static var naviBackWhiteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .naviBackWhiteIcon)
#else
        .init()
#endif
    }

    /// The "navi_close_icon" asset catalog image.
    static var naviCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .naviCloseIcon)
#else
        .init()
#endif
    }

    /// The "navi_logo_img" asset catalog image.
    static var naviLogoImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .naviLogoImg)
#else
        .init()
#endif
    }

    /// The "notifi_tips_img" asset catalog image.
    static var notifiTipsImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .notifiTipsImg)
#else
        .init()
#endif
    }

    /// The "peacock_img" asset catalog image.
    static var peacockImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .peacockImg)
#else
        .init()
#endif
    }

    /// The "plan_arrow_gray" asset catalog image.
    static var planArrowGray: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planArrowGray)
#else
        .init()
#endif
    }

    /// The "plan_arrow_gray_whole" asset catalog image.
    static var planArrowGrayWhole: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planArrowGrayWhole)
#else
        .init()
#endif
    }

    /// The "plan_arrow_theme" asset catalog image.
    static var planArrowTheme: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planArrowTheme)
#else
        .init()
#endif
    }

    /// The "plan_create_icon" asset catalog image.
    static var planCreateIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planCreateIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_blace_icon" asset catalog image.
    static var planDetailArrowBlaceIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailArrowBlaceIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_highlight_icon" asset catalog image.
    static var planDetailArrowHighlightIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailArrowHighlightIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_highlight_icon_left" asset catalog image.
    static var planDetailArrowHighlightIconLeft: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailArrowHighlightIconLeft)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_icon_left" asset catalog image.
    static var planDetailArrowIconLeft: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailArrowIconLeft)
#else
        .init()
#endif
    }

    /// The "plan_detail_arrow_icon_right" asset catalog image.
    static var planDetailArrowIconRight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailArrowIconRight)
#else
        .init()
#endif
    }

    /// The "plan_detail_cancel_icon" asset catalog image.
    static var planDetailCancelIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailCancelIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_circle_img" asset catalog image.
    static var planDetailCircleImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailCircleImg)
#else
        .init()
#endif
    }

    /// The "plan_detail_delete_icon" asset catalog image.
    static var planDetailDeleteIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailDeleteIcon)
#else
        .init()
#endif
    }

    /// The "plan_detail_share_icon" asset catalog image.
    static var planDetailShareIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planDetailShareIcon)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_bg_img" asset catalog image.
    static var planGetAlertBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planGetAlertBgImg)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_calori_bg_img" asset catalog image.
    static var planGetAlertCaloriBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planGetAlertCaloriBgImg)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_calori_icon" asset catalog image.
    static var planGetAlertCaloriIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planGetAlertCaloriIcon)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_clock_icon" asset catalog image.
    static var planGetAlertClockIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planGetAlertClockIcon)
#else
        .init()
#endif
    }

    /// The "plan_get_alert_natural_line" asset catalog image.
    static var planGetAlertNaturalLine: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planGetAlertNaturalLine)
#else
        .init()
#endif
    }

    /// The "plan_get_icon" asset catalog image.
    static var planGetIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planGetIcon)
#else
        .init()
#endif
    }

    /// The "plan_lead_icon" asset catalog image.
    static var planLeadIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planLeadIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_bg_img" asset catalog image.
    static var planShareBgImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareBgImg)
#else
        .init()
#endif
    }

    /// The "plan_share_bg_img_rect" asset catalog image.
    static var planShareBgImgRect: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareBgImgRect)
#else
        .init()
#endif
    }

    /// The "plan_share_circle_icon" asset catalog image.
    static var planShareCircleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareCircleIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_circle_icon_white" asset catalog image.
    static var planShareCircleIconWhite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareCircleIconWhite)
#else
        .init()
#endif
    }

    /// The "plan_share_close_icon" asset catalog image.
    static var planShareCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareCloseIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_copy_icon" asset catalog image.
    static var planShareCopyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareCopyIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_save_icon" asset catalog image.
    static var planShareSaveIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareSaveIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_save_icon_white" asset catalog image.
    static var planShareSaveIconWhite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareSaveIconWhite)
#else
        .init()
#endif
    }

    /// The "plan_share_wechat_icon" asset catalog image.
    static var planShareWechatIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareWechatIcon)
#else
        .init()
#endif
    }

    /// The "plan_share_wechat_icon_white" asset catalog image.
    static var planShareWechatIconWhite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planShareWechatIconWhite)
#else
        .init()
#endif
    }

    /// The "question_alert_arrow_down_icon" asset catalog image.
    static var questionAlertArrowDownIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionAlertArrowDownIcon)
#else
        .init()
#endif
    }

    /// The "question_alert_close_icon" asset catalog image.
    static var questionAlertCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionAlertCloseIcon)
#else
        .init()
#endif
    }

    /// The "question_arrow_right" asset catalog image.
    static var questionArrowRight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionArrowRight)
#else
        .init()
#endif
    }

    /// The "question_arrow_right_theme" asset catalog image.
    static var questionArrowRightTheme: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionArrowRightTheme)
#else
        .init()
#endif
    }

    /// The "question_bg" asset catalog image.
    static var questionBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionBg)
#else
        .init()
#endif
    }

    /// The "question_checkbox_normal" asset catalog image.
    static var questionCheckboxNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionCheckboxNormal)
#else
        .init()
#endif
    }

    /// The "question_checkbox_selected" asset catalog image.
    static var questionCheckboxSelected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionCheckboxSelected)
#else
        .init()
#endif
    }

    /// The "question_foods_normal_icon" asset catalog image.
    static var questionFoodsNormalIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionFoodsNormalIcon)
#else
        .init()
#endif
    }

    /// The "question_foods_selected_icon" asset catalog image.
    static var questionFoodsSelectedIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionFoodsSelectedIcon)
#else
        .init()
#endif
    }

    /// The "question_foods_verify_icon" asset catalog image.
    static var questionFoodsVerifyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionFoodsVerifyIcon)
#else
        .init()
#endif
    }

    /// The "question_goal_selected" asset catalog image.
    static var questionGoalSelected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionGoalSelected)
#else
        .init()
#endif
    }

    /// The "question_plan_tips_content" asset catalog image.
    static var questionPlanTipsContent: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionPlanTipsContent)
#else
        .init()
#endif
    }

    /// The "question_pre_img" asset catalog image.
    static var questionPreImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .questionPreImg)
#else
        .init()
#endif
    }

    /// The "rank_1_reached" asset catalog image.
    static var rank1Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank1Reached)
#else
        .init()
#endif
    }

    /// The "rank_2_reached" asset catalog image.
    static var rank2Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank2Reached)
#else
        .init()
#endif
    }

    /// The "rank_3_reached" asset catalog image.
    static var rank3Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank3Reached)
#else
        .init()
#endif
    }

    /// The "rank_4_reached" asset catalog image.
    static var rank4Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank4Reached)
#else
        .init()
#endif
    }

    /// The "rank_5_reached" asset catalog image.
    static var rank5Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank5Reached)
#else
        .init()
#endif
    }

    /// The "rank_6_reached" asset catalog image.
    static var rank6Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank6Reached)
#else
        .init()
#endif
    }

    /// The "rank_7_reached" asset catalog image.
    static var rank7Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank7Reached)
#else
        .init()
#endif
    }

    /// The "rank_8_reached" asset catalog image.
    static var rank8Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank8Reached)
#else
        .init()
#endif
    }

    /// The "rank_9_reached" asset catalog image.
    static var rank9Reached: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rank9Reached)
#else
        .init()
#endif
    }

    /// The "rank_locked_icon" asset catalog image.
    static var rankLockedIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rankLockedIcon)
#else
        .init()
#endif
    }

    /// The "rank_locked_img" asset catalog image.
    static var rankLockedImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rankLockedImg)
#else
        .init()
#endif
    }

    /// The "rank_unlock" asset catalog image.
    static var rankUnlock: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rankUnlock)
#else
        .init()
#endif
    }

    /// The "report_calories_source_icon" asset catalog image.
    static var reportCaloriesSourceIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportCaloriesSourceIcon)
#else
        .init()
#endif
    }

    /// The "report_daily_calories_bg_icon" asset catalog image.
    static var reportDailyCaloriesBgIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportDailyCaloriesBgIcon)
#else
        .init()
#endif
    }

    /// The "report_daily_carbo_icon" asset catalog image.
    static var reportDailyCarboIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportDailyCarboIcon)
#else
        .init()
#endif
    }

    /// The "report_daily_fat_icon" asset catalog image.
    static var reportDailyFatIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportDailyFatIcon)
#else
        .init()
#endif
    }

    /// The "report_daily_protein_icon" asset catalog image.
    static var reportDailyProteinIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportDailyProteinIcon)
#else
        .init()
#endif
    }

    /// The "report_ela_img" asset catalog image.
    static var reportElaImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportElaImg)
#else
        .init()
#endif
    }

    /// The "report_week_nodata_img" asset catalog image.
    static var reportWeekNodataImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportWeekNodataImg)
#else
        .init()
#endif
    }

    /// The "report_weight_down_icon" asset catalog image.
    static var reportWeightDownIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportWeightDownIcon)
#else
        .init()
#endif
    }

    /// The "report_weight_up_icon" asset catalog image.
    static var reportWeightUpIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reportWeightUpIcon)
#else
        .init()
#endif
    }

    /// The "rule_journal_alert_img" asset catalog image.
    static var ruleJournalAlertImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ruleJournalAlertImg)
#else
        .init()
#endif
    }

    /// The "rule_journal_alert_img_protein" asset catalog image.
    static var ruleJournalAlertImgProtein: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ruleJournalAlertImgProtein)
#else
        .init()
#endif
    }

    /// The "ruler_cover_bottom" asset catalog image.
    static var rulerCoverBottom: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rulerCoverBottom)
#else
        .init()
#endif
    }

    /// The "ruler_cover_top" asset catalog image.
    static var rulerCoverTop: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rulerCoverTop)
#else
        .init()
#endif
    }

    /// The "seach_icon" asset catalog image.
    static var seachIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .seachIcon)
#else
        .init()
#endif
    }

    /// The "search_clear_icon" asset catalog image.
    static var searchClearIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .searchClearIcon)
#else
        .init()
#endif
    }

    /// The "search_icon" asset catalog image.
    static var searchIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .searchIcon)
#else
        .init()
#endif
    }

    /// The "service_add_bg" asset catalog image.
    static var serviceAddBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .serviceAddBg)
#else
        .init()
#endif
    }

    /// The "service_album_icon" asset catalog image.
    static var serviceAlbumIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .serviceAlbumIcon)
#else
        .init()
#endif
    }

    /// The "service_camera_icon" asset catalog image.
    static var serviceCameraIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .serviceCameraIcon)
#else
        .init()
#endif
    }

    /// The "service_img_add_icon" asset catalog image.
    static var serviceImgAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .serviceImgAddIcon)
#else
        .init()
#endif
    }

    /// The "service_img_add_icon 1" asset catalog image.
    static var serviceImgAddIcon1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .serviceImgAddIcon1)
#else
        .init()
#endif
    }

    /// The "service_order_icon" asset catalog image.
    static var serviceOrderIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .serviceOrderIcon)
#else
        .init()
#endif
    }

    /// The "service_type_advice" asset catalog image.
    static var serviceTypeAdvice: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .serviceTypeAdvice)
#else
        .init()
#endif
    }

    /// The "service_type_market" asset catalog image.
    static var serviceTypeMarket: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .serviceTypeMarket)
#else
        .init()
#endif
    }

    /// The "sex_icon_feman" asset catalog image.
    static var sexIconFeman: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sexIconFeman)
#else
        .init()
#endif
    }

    /// The "sex_icon_feman_normal" asset catalog image.
    static var sexIconFemanNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sexIconFemanNormal)
#else
        .init()
#endif
    }

    /// The "sex_icon_man" asset catalog image.
    static var sexIconMan: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sexIconMan)
#else
        .init()
#endif
    }

    /// The "sex_icon_man_normal" asset catalog image.
    static var sexIconManNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sexIconManNormal)
#else
        .init()
#endif
    }

    /// The "share_icon_shadow" asset catalog image.
    static var shareIconShadow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .shareIconShadow)
#else
        .init()
#endif
    }

    /// The "slogan_notext" asset catalog image.
    static var sloganNotext: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sloganNotext)
#else
        .init()
#endif
    }

    /// The "sport_add_icon" asset catalog image.
    static var sportAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sportAddIcon)
#else
        .init()
#endif
    }

    /// The "sport_calories_icon" asset catalog image.
    static var sportCaloriesIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sportCaloriesIcon)
#else
        .init()
#endif
    }

    /// The "sport_time_icon" asset catalog image.
    static var sportTimeIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sportTimeIcon)
#else
        .init()
#endif
    }

    /// The "stat_calendar_close_icon" asset catalog image.
    static var statCalendarCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .statCalendarCloseIcon)
#else
        .init()
#endif
    }

    /// The "stat_fitness_tips_alert_img" asset catalog image.
    static var statFitnessTipsAlertImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .statFitnessTipsAlertImg)
#else
        .init()
#endif
    }

    /// The "stat_top_foods_first" asset catalog image.
    static var statTopFoodsFirst: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .statTopFoodsFirst)
#else
        .init()
#endif
    }

    /// The "stat_top_foods_second" asset catalog image.
    static var statTopFoodsSecond: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .statTopFoodsSecond)
#else
        .init()
#endif
    }

    /// The "stat_top_foods_third" asset catalog image.
    static var statTopFoodsThird: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .statTopFoodsThird)
#else
        .init()
#endif
    }

    /// The "streak_close_icon" asset catalog image.
    static var streakCloseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakCloseIcon)
#else
        .init()
#endif
    }

    /// The "streak_icon_1" asset catalog image.
    static var streakIcon1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIcon1)
#else
        .init()
#endif
    }

    /// The "streak_icon_2" asset catalog image.
    static var streakIcon2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIcon2)
#else
        .init()
#endif
    }

    /// The "streak_icon_3" asset catalog image.
    static var streakIcon3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIcon3)
#else
        .init()
#endif
    }

    /// The "streak_icon_4" asset catalog image.
    static var streakIcon4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIcon4)
#else
        .init()
#endif
    }

    /// The "streak_icon_5" asset catalog image.
    static var streakIcon5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIcon5)
#else
        .init()
#endif
    }

    /// The "streak_icon_6" asset catalog image.
    static var streakIcon6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIcon6)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_1" asset catalog image.
    static var streakIconGray1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIconGray1)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_2" asset catalog image.
    static var streakIconGray2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIconGray2)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_3" asset catalog image.
    static var streakIconGray3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIconGray3)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_4" asset catalog image.
    static var streakIconGray4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIconGray4)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_5" asset catalog image.
    static var streakIconGray5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIconGray5)
#else
        .init()
#endif
    }

    /// The "streak_icon_gray_6" asset catalog image.
    static var streakIconGray6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .streakIconGray6)
#else
        .init()
#endif
    }

    /// The "tabbar_center_icon" asset catalog image.
    static var tabbarCenterIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarCenterIcon)
#else
        .init()
#endif
    }

    /// The "tabbar_forum_normal" asset catalog image.
    static var tabbarForumNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarForumNormal)
#else
        .init()
#endif
    }

    /// The "tabbar_forum_normal_dark" asset catalog image.
    static var tabbarForumNormalDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarForumNormalDark)
#else
        .init()
#endif
    }

    /// The "tabbar_forum_selected" asset catalog image.
    static var tabbarForumSelected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarForumSelected)
#else
        .init()
#endif
    }

    /// The "tabbar_forum_selected_dark" asset catalog image.
    static var tabbarForumSelectedDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarForumSelectedDark)
#else
        .init()
#endif
    }

    /// The "tabbar_logs_normal" asset catalog image.
    static var tabbarLogsNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarLogsNormal)
#else
        .init()
#endif
    }

    /// The "tabbar_logs_normal_dark" asset catalog image.
    static var tabbarLogsNormalDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarLogsNormalDark)
#else
        .init()
#endif
    }

    /// The "tabbar_logs_selected" asset catalog image.
    static var tabbarLogsSelected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarLogsSelected)
#else
        .init()
#endif
    }

    /// The "tabbar_logs_selected_dark" asset catalog image.
    static var tabbarLogsSelectedDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarLogsSelectedDark)
#else
        .init()
#endif
    }

    /// The "tabbar_main_normal" asset catalog image.
    static var tabbarMainNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarMainNormal)
#else
        .init()
#endif
    }

    /// The "tabbar_main_normal_dark" asset catalog image.
    static var tabbarMainNormalDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarMainNormalDark)
#else
        .init()
#endif
    }

    /// The "tabbar_main_selected" asset catalog image.
    static var tabbarMainSelected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarMainSelected)
#else
        .init()
#endif
    }

    /// The "tabbar_main_selected_dark" asset catalog image.
    static var tabbarMainSelectedDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarMainSelectedDark)
#else
        .init()
#endif
    }

    /// The "tabbar_mine_normal" asset catalog image.
    static var tabbarMineNormal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarMineNormal)
#else
        .init()
#endif
    }

    /// The "tabbar_mine_normal_dark" asset catalog image.
    static var tabbarMineNormalDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarMineNormalDark)
#else
        .init()
#endif
    }

    /// The "tabbar_mine_selected" asset catalog image.
    static var tabbarMineSelected: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarMineSelected)
#else
        .init()
#endif
    }

    /// The "tabbar_mine_selected_dark" asset catalog image.
    static var tabbarMineSelectedDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarMineSelectedDark)
#else
        .init()
#endif
    }

    /// The "tips_gray_icon" asset catalog image.
    static var tipsGrayIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tipsGrayIcon)
#else
        .init()
#endif
    }

    /// The "tips_gray_icon_w" asset catalog image.
    static var tipsGrayIconW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tipsGrayIconW)
#else
        .init()
#endif
    }

    /// The "tutorial_arrow_down" asset catalog image.
    static var tutorialArrowDown: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialArrowDown)
#else
        .init()
#endif
    }

    /// The "tutorial_arrow_up" asset catalog image.
    static var tutorialArrowUp: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialArrowUp)
#else
        .init()
#endif
    }

    /// The "tutorial_back_10_seconds" asset catalog image.
    static var tutorialBack10Seconds: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialBack10Seconds)
#else
        .init()
#endif
    }

    /// The "tutorial_back_10_seconds_highlight" asset catalog image.
    static var tutorialBack10SecondsHighlight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialBack10SecondsHighlight)
#else
        .init()
#endif
    }

    /// The "tutorial_back_icon" asset catalog image.
    static var tutorialBackIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialBackIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_forward_10_seconds" asset catalog image.
    static var tutorialForward10Seconds: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialForward10Seconds)
#else
        .init()
#endif
    }

    /// The "tutorial_forward_10_seconds_highlight" asset catalog image.
    static var tutorialForward10SecondsHighlight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialForward10SecondsHighlight)
#else
        .init()
#endif
    }

    /// The "tutorial_full_screen_icon" asset catalog image.
    static var tutorialFullScreenIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialFullScreenIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_mini_screen_icon" asset catalog image.
    static var tutorialMiniScreenIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialMiniScreenIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_next_icon" asset catalog image.
    static var tutorialNextIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialNextIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_playing_icon" asset catalog image.
    static var tutorialPlayingIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialPlayingIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_share_icon" asset catalog image.
    static var tutorialShareIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialShareIcon)
#else
        .init()
#endif
    }

    /// The "tutorial_visible_icon" asset catalog image.
    static var tutorialVisibleIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialVisibleIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_1_1_1" asset catalog image.
    static var tutorials111: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials111)
#else
        .init()
#endif
    }

    /// The "tutorials_1_1_2" asset catalog image.
    static var tutorials112: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials112)
#else
        .init()
#endif
    }

    /// The "tutorials_1_2_1" asset catalog image.
    static var tutorials121: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials121)
#else
        .init()
#endif
    }

    /// The "tutorials_1_2_2" asset catalog image.
    static var tutorials122: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials122)
#else
        .init()
#endif
    }

    /// The "tutorials_1_2_3" asset catalog image.
    static var tutorials123: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials123)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_1" asset catalog image.
    static var tutorials131: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials131)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_1_1" asset catalog image.
    static var tutorials1311: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials1311)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_1_2" asset catalog image.
    static var tutorials1312: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials1312)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_1_3" asset catalog image.
    static var tutorials1313: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials1313)
#else
        .init()
#endif
    }

    /// The "tutorials_1_3_2" asset catalog image.
    static var tutorials132: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials132)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_1" asset catalog image.
    static var tutorials141: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials141)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_2" asset catalog image.
    static var tutorials142: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials142)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_3" asset catalog image.
    static var tutorials143: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials143)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_4" asset catalog image.
    static var tutorials144: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials144)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_4_2" asset catalog image.
    static var tutorials1442: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials1442)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_4_3" asset catalog image.
    static var tutorials1443: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials1443)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_5" asset catalog image.
    static var tutorials145: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials145)
#else
        .init()
#endif
    }

    /// The "tutorials_1_4_6" asset catalog image.
    static var tutorials146: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials146)
#else
        .init()
#endif
    }

    /// The "tutorials_1_5_1" asset catalog image.
    static var tutorials151: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials151)
#else
        .init()
#endif
    }

    /// The "tutorials_1_5_2" asset catalog image.
    static var tutorials152: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials152)
#else
        .init()
#endif
    }

    /// The "tutorials_1_5_3" asset catalog image.
    static var tutorials153: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials153)
#else
        .init()
#endif
    }

    /// The "tutorials_1_6_1" asset catalog image.
    static var tutorials161: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials161)
#else
        .init()
#endif
    }

    /// The "tutorials_1_6_2" asset catalog image.
    static var tutorials162: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials162)
#else
        .init()
#endif
    }

    /// The "tutorials_1_6_3" asset catalog image.
    static var tutorials163: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials163)
#else
        .init()
#endif
    }

    /// The "tutorials_1_7_1" asset catalog image.
    static var tutorials171: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials171)
#else
        .init()
#endif
    }

    /// The "tutorials_1_7_2" asset catalog image.
    static var tutorials172: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials172)
#else
        .init()
#endif
    }

    /// The "tutorials_1_7_3" asset catalog image.
    static var tutorials173: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials173)
#else
        .init()
#endif
    }

    /// The "tutorials_1_8_1" asset catalog image.
    static var tutorials181: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials181)
#else
        .init()
#endif
    }

    /// The "tutorials_1_8_2" asset catalog image.
    static var tutorials182: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials182)
#else
        .init()
#endif
    }

    /// The "tutorials_2_1_1" asset catalog image.
    static var tutorials211: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials211)
#else
        .init()
#endif
    }

    /// The "tutorials_2_1_2" asset catalog image.
    static var tutorials212: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials212)
#else
        .init()
#endif
    }

    /// The "tutorials_2_1_3" asset catalog image.
    static var tutorials213: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials213)
#else
        .init()
#endif
    }

    /// The "tutorials_3_1_1" asset catalog image.
    static var tutorials311: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials311)
#else
        .init()
#endif
    }

    /// The "tutorials_3_1_2" asset catalog image.
    static var tutorials312: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials312)
#else
        .init()
#endif
    }

    /// The "tutorials_3_1_3" asset catalog image.
    static var tutorials313: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials313)
#else
        .init()
#endif
    }

    /// The "tutorials_4_1_1" asset catalog image.
    static var tutorials411: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials411)
#else
        .init()
#endif
    }

    /// The "tutorials_4_1_2" asset catalog image.
    static var tutorials412: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials412)
#else
        .init()
#endif
    }

    /// The "tutorials_4_2_1" asset catalog image.
    static var tutorials421: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials421)
#else
        .init()
#endif
    }

    /// The "tutorials_4_2_2" asset catalog image.
    static var tutorials422: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials422)
#else
        .init()
#endif
    }

    /// The "tutorials_4_2_3" asset catalog image.
    static var tutorials423: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials423)
#else
        .init()
#endif
    }

    /// The "tutorials_4_2_4" asset catalog image.
    static var tutorials424: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials424)
#else
        .init()
#endif
    }

    /// The "tutorials_4_3_1" asset catalog image.
    static var tutorials431: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials431)
#else
        .init()
#endif
    }

    /// The "tutorials_4_3_2" asset catalog image.
    static var tutorials432: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials432)
#else
        .init()
#endif
    }

    /// The "tutorials_5_1_1" asset catalog image.
    static var tutorials511: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials511)
#else
        .init()
#endif
    }

    /// The "tutorials_5_1_2" asset catalog image.
    static var tutorials512: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorials512)
#else
        .init()
#endif
    }

    /// The "tutorials_add_icon" asset catalog image.
    static var tutorialsAddIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsAddIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_down_arrow_icon" asset catalog image.
    static var tutorialsDownArrowIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsDownArrowIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_eat_icon" asset catalog image.
    static var tutorialsEatIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsEatIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_edit_icon" asset catalog image.
    static var tutorialsEditIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsEditIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_plan_list_icon" asset catalog image.
    static var tutorialsPlanListIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsPlanListIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_setting_icon" asset catalog image.
    static var tutorialsSettingIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsSettingIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_share_icon" asset catalog image.
    static var tutorialsShareIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsShareIcon)
#else
        .init()
#endif
    }

    /// The "tutorials_share_icon_theme" asset catalog image.
    static var tutorialsShareIconTheme: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsShareIconTheme)
#else
        .init()
#endif
    }

    /// The "tutorials_step_1" asset catalog image.
    static var tutorialsStep1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsStep1)
#else
        .init()
#endif
    }

    /// The "tutorials_step_2" asset catalog image.
    static var tutorialsStep2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsStep2)
#else
        .init()
#endif
    }

    /// The "tutorials_step_3" asset catalog image.
    static var tutorialsStep3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsStep3)
#else
        .init()
#endif
    }

    /// The "tutorials_step_4" asset catalog image.
    static var tutorialsStep4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsStep4)
#else
        .init()
#endif
    }

    /// The "tutorials_step_5" asset catalog image.
    static var tutorialsStep5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tutorialsStep5)
#else
        .init()
#endif
    }

    /// The "video_edit_album_icon" asset catalog image.
    static var videoEditAlbumIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoEditAlbumIcon)
#else
        .init()
#endif
    }

    /// The "video_pause_icon" asset catalog image.
    static var videoPauseIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoPauseIcon)
#else
        .init()
#endif
    }

    /// The "video_pause_icon_1" asset catalog image.
    static var videoPauseIcon1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoPauseIcon1)
#else
        .init()
#endif
    }

    /// The "video_pause_icon_landscap" asset catalog image.
    static var videoPauseIconLandscap: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoPauseIconLandscap)
#else
        .init()
#endif
    }

    /// The "video_pause_icon_landscap_1" asset catalog image.
    static var videoPauseIconLandscap1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoPauseIconLandscap1)
#else
        .init()
#endif
    }

    /// The "video_play_icon" asset catalog image.
    static var videoPlayIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoPlayIcon)
#else
        .init()
#endif
    }

    /// The "video_play_icon_1" asset catalog image.
    static var videoPlayIcon1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoPlayIcon1)
#else
        .init()
#endif
    }

    /// The "video_play_icon_landscap" asset catalog image.
    static var videoPlayIconLandscap: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoPlayIconLandscap)
#else
        .init()
#endif
    }

    /// The "video_play_icon_landscap_1" asset catalog image.
    static var videoPlayIconLandscap1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .videoPlayIconLandscap1)
#else
        .init()
#endif
    }

    /// The "welcome_logo_icon" asset catalog image.
    static var welcomeLogoIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .welcomeLogoIcon)
#else
        .init()
#endif
    }

    /// The "widget_bg_bottom" asset catalog image.
    static var widgetBgBottom: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .widgetBgBottom)
#else
        .init()
#endif
    }

    /// The "withdraw_bank_icon" asset catalog image.
    static var withdrawBankIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .withdrawBankIcon)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif