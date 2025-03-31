//
//  AccessToken.swift
//  BohumTalk
//
//  Created by 조유진 on 3/12/25.
//

import RealmSwift
import Foundation

final class AccessToken: Object {
    @Persisted(primaryKey: true) var snsId: String
    @Persisted var accessToken: String
    @Persisted var loginCompany: String
    
    convenience init(
        snsId: String,
        accessToken: String,
        loginCompany: String
    ) {
        self.init()
        self.snsId = snsId
        self.accessToken = accessToken
        self.loginCompany = loginCompany
    }
}
