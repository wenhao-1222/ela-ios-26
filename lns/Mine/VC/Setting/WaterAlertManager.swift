//
//  WaterAlertManager.swift
//  lns
//
//  Created by Elavatine on 2025/5/26.
//

import UserNotifications

class WaterAlertManager {
    static let shared = WaterAlertManager()
    private init() {}

    func refreshWaterAlerts() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let times = UserDefaults.getWaterAlerts()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                for t in times {
                    self.schedule(time: t)
                }
            }
        }
    }

    private func schedule(time:String){
        let comps = time.split(separator: ":")
        guard comps.count >= 2,
              let hour = Int(comps[0]),
              let minute = Int(comps[1]) else { return }
        var dc = DateComponents()
        dc.hour = hour
        dc.minute = minute
        let content = UNMutableNotificationContent()
        content.title = "喝水提醒"
        content.body = "点击记录今日饮水量"
        content.sound = .default
        content.userInfo = ["action":"water_reminder"]
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let request = UNNotificationRequest(identifier: "water_reminder_\(time)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
