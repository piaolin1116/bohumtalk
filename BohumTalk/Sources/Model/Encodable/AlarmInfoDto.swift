//
//  AlarmInfoDto.swift
//  BohumTalk
//
//  Created by 조유진 on 3/19/25.
//

import Foundation

struct AlarmInfoDto: Encodable {
    let alarmId: String
    let title: String
    let content: String
    let imageUrl: String?
    let iconUrl: String?
    let alarmDate: Date
    let readDate: Date?
    let alarmData: String
}
