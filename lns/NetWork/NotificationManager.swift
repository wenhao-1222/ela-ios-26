//
//  NotificationManager.swift
//  lns
//
//  Created by LNS2 on 2025/12/1.
//

import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()
    private let mealPrefix = "meal_reminder_"

    /// 来自 LogsMealsAlertSetManage 的 placeholder 用餐提醒
    private let lunchPlaceholders = LogsMealsAlertSetManage().lunchPlaceHoderArrays
    private let dinnerPlaceholders = LogsMealsAlertSetManage().dinnerPlaceHoderArrays

    /// App 回到前台 OR 启动时调用：上报通知栏中已展示但未处理的本地通知
    func reportDeliveredMealNotificationsIfNeeded() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            
            let mealNotifications = notifications.filter {
                $0.request.identifier.hasPrefix(self.mealPrefix)
            }
            
            guard mealNotifications.count > 0 else { return }

            for n in mealNotifications {
                let content = n.request.content
                self.reportShowIfNeeded(content)
            }

            // 避免重复上报
            let ids = mealNotifications.map { $0.request.identifier }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        }
    }

    /// 用户点击通知上报
    func reportMealNotificationClick(_ content: UNNotificationContent) {
        reportClickIfNeeded(content)
    }
}

extension NotificationManager {

    /// 显示曝光：只上报用餐提醒
    private func reportShowIfNeeded(_ content: UNNotificationContent) {
        guard let cleanedText = extractValidMealText(from: content.body) else {
            return  // ❌ 非用餐提醒，不上报
        }

        EventLogUtils().sendEventLogRequest(
            eventName: .PAGE_VIEW,
            scenarioType: .logs_meals_alert_show,
            text: cleanedText
        )
    }

    /// 点击曝光：只上报用餐提醒
    private func reportClickIfNeeded(_ content: UNNotificationContent) {
        guard let cleanedText = extractValidMealText(from: content.body) else {
            return  // ❌ 非用餐提醒，不上报
        }
        EventLogUtils().sendEventLogRequest(
            eventName: .PAGE_VIEW,
            scenarioType: .logs_meals_alert_show,
            text: cleanedText
        )
        EventLogUtils().sendEventLogRequest(
            eventName: .CLICK_BUTTON,
            scenarioType: .logs_meals_alert_click,
            text: cleanedText
        )
    }
}

extension NotificationManager {

    /// 核心：判断是否属于午餐/晚餐占位文案，并进行文本清洗
    private func extractValidMealText(from body: String) -> String? {

        // 3) 是否是我们定义的占位文案（“清洗后完全相等”）
        let isLunch = lunchPlaceholders.contains(body)
        let isDinner = dinnerPlaceholders.contains(body)
        if !isLunch && !isDinner {
            return nil // ❌ 非我们需要的文案，不上报
        }
        
        // 1) 去除 emoji
        let noEmoji = body.removingEmojiByRegex()

        // 2) 去除前后空格
        let trimmed = noEmoji.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed
    }
}
