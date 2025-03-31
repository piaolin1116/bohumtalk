//
//  User.swift
//  BohumTalk
//
//  Created by 조유진 on 3/12/25.
//

import RealmSwift
import Foundation

final class User: Object {
    @Persisted(primaryKey: true) var snsId: String
    @Persisted var serverUserId: String?
    @Persisted var alarmYN: Bool?
    @Persisted var loginDate: Date
    @Persisted var logoutDate: Date?
    
    convenience init(
        snsId: String,
        serverUserId: String? = nil,
        alarmYN: Bool = false,
        loginDate: Date,
        logoutDate: Date? = nil
    ) {
        self.init()
        self.snsId = snsId
        self.serverUserId = serverUserId
        self.alarmYN = alarmYN
        self.loginDate = loginDate
        self.logoutDate = logoutDate
    }
}

// 현재 사용자의 serverUserId 업데이트
// 현재 사용자의 serverUserId 조회
// 현재 사용자의 alarmYN 업데이트
// 현재 사용자의 alarmYN 조회
// 로그인 현재 시간으로 업데이트
// 로그아웃 현재 시간으로 업데이트
// 현재 사용자의 alarms 조회
