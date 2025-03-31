//
//  UserInfoDto.swift
//  BohumTalk
//
//  Created by 조유진 on 3/19/25.
//

struct UserInfoDto: Encodable {
    let snsId: String?
    let serverUserId: String?
    let accessToken: String?
    let deviceToken: String?
    let alarmYN: Bool
    let unreadAlarmList: [AlarmInfoDto]
    let canUpdateApp: Bool
    let appVersion: String?
}
