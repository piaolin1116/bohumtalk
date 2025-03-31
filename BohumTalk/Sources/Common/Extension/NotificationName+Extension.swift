//
//  NotificationName+Extension.swift
//  BohumTalk
//
//  Created by 조유진 on 3/11/25.
//

import Foundation

extension Notification.Name {
    static let reloadURL = Notification.Name("reloadURL")
    static let receiveForegroundAlarm = Notification.Name("receiveForegroundAlarm")
    static let clickedAlarm = Notification.Name("clickedAlarm")
    static let updateAlarmStatus = Notification.Name("updateAlarmStatus")
}
