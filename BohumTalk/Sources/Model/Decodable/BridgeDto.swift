//
//  BridgeDto.swift
//  BohumTalk
//
//  Created by 홍성진 on 4/3/25.
//

struct BridgeDto: Codable {
    // app to web
    let snsId: String?
    let accessToken: String?
    let loginCompany: String?

    let alarmYN: Bool?
    
    let start: Int?
    let end: Int?
    
    let serverUserId: String?
    
    let appUrlString: String?
    let webUrlString: String?
    
    
    //web to app
}
