//
//  AlarmManager.swift
//  BohumTalk
//
//  Created by 조유진 on 3/21/25.
//

import Foundation
import RealmSwift

@MainActor final class AlarmManager {
    static let shared = AlarmManager()
    
    func getAlarmId(userInfo: [AnyHashable : Any]) -> String?{
        
        if let alarmId = userInfo["alarmId"] as? String {
            return alarmId
        } else {
            return nil
        }
    }
    
    func getAlarm(userInfo: [AnyHashable : Any]) throws -> Alarm?{
        
        if let aps = userInfo["aps"] as? [String: Any],
           let alarmId = userInfo["alarmId"] as? String,
           let alert = aps["alert"] as? [String: Any],
           let title = alert["title"] as? String,
           let body = alert["body"] as? String,
           let snsId = try KeyChain.read(key: KeyChainName.currentUserId.rawValue)
        {
            let alarmDataString = MessageCodableManager.shared.convertDictionaryToString(userInfo) ?? ""
            let imageUrl = aps["imageUrl"] as? String
            let iconUrl = aps["iconUrl"] as? String
            print("알림 제목: \(title)")
            print("알림 내용: \(body)")
            
            return Alarm(alarmId: alarmId, snsId: snsId, title: title, content: body, imageUrl: imageUrl, iconUrl: iconUrl, alarmDate: Date(), alarmData: alarmDataString)
        } else {
            return nil
        }
    }
    
    func saveAlarm(userInfo: [AnyHashable : Any]) async throws -> String? {
        print(#function)
        if let alarm = try getAlarm(userInfo: userInfo) {
            let alarmRepository = AlarmRepository()
            try alarmRepository.createAlarm(item: alarm)
            print(alarm)
            return alarm.alarmId
        }
        return nil
    }
    
    func readNewAlarm(alarmId: String) async throws {
        let alarmRepository = AlarmRepository()
        try await alarmRepository.updateReadDateByAlarmId(alarmId: alarmId)
    }
    
    func postClickedAlarmToServer(userInfo: [AnyHashable : Any]) async throws {
        if let alarm = try getAlarm(userInfo: userInfo) {
            let body: [String: Any] = [
                "alarmId": alarm.alarmId,
                "snsId": alarm.snsId,
                "title": alarm.title,
                "content": alarm.content,
                "imageUrl": alarm.imageUrl ?? "",
                "iconUrl": alarm.iconUrl ?? "",
                "alarmDate": alarm.alarmDate,
                "alarmData": alarm.alarmData
            ]
            let resultString = try await NetworkRequestManager.shared.requestPostToServer(url: "/alarm/clicked", parameters: [:])
            print(resultString)
        }
    }
}
