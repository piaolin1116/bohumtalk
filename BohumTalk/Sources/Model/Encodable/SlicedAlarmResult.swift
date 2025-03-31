//
//  SlicedAlarmResult.swift
//  BohumTalk
//
//  Created by 조유진 on 3/20/25.
//

struct SlicedAlarmResult: Encodable {
    let totalCount: Int
    let start: Int
    let end: Int
    
    let alarmList: [AlarmInfoDto]
}
