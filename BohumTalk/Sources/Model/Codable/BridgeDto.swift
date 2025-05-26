//
//  BridgeDto.swift
//  BohumTalk
//
//  Created by 홍성진 on 4/3/25.
//

struct BridgeDto: Codable {
    // Native to Web
    // String to Json
    // 이떄는 web to app 인 js 요청밖에 없음.. 그래서 구조체로 운영하면 될듯
    let vuexCallType: String?
    let navtiveCallType: String?
    let snsId: String?
    let serverUserId: String?
    
    let accessToken: String?
    let loginCompany: String?
    
    let alarmYN: Bool?
    
    let searchType: String?
    let start: Int?
    let end: Int?
    
    let appUrlString: String?
    let webUrlString: String?
    
    let url: String?
    
    let isSuccess: Bool?
}
