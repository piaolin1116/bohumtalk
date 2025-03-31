//
//  Alarm.swift
//  BohumTalk
//
//  Created by 조유진 on 3/12/25.
//

import RealmSwift
import Foundation

final class Alarm: Object {
    @Persisted(primaryKey: true) var alarmId: String
    @Persisted var snsId: String
    @Persisted var title: String
    @Persisted var content: String
    @Persisted var imageUrl: String?
    @Persisted var iconUrl: String?
    @Persisted var alarmDate: Date
    @Persisted var readDate: Date?
    @Persisted var alarmData: String
    
    convenience init(
        alarmId: String,
        snsId: String,
        title: String,
        content: String,
        imageUrl: String? = nil,
        iconUrl: String? = nil,
        readDate: Date? = nil,
        alarmDate: Date,
        alarmData: String
    ) {
        self.init()
        self.alarmId = alarmId
        self.snsId = snsId
        self.title = title
        self.content = content
        self.imageUrl = imageUrl
        self.iconUrl = iconUrl
        self.readDate = readDate
        self.alarmData = alarmData
    }
}
