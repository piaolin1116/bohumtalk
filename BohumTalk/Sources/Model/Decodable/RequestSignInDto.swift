//
//  RequestSignInDto.swift
//  BohumTalk
//
//  Created by 조유진 on 3/19/25.
//

struct RequestSignInDto: Decodable {
    let snsId: String
    let accessToken: String
    let loginCompany: String
}
