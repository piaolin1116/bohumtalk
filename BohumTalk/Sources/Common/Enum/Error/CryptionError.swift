//
//  CryptionError.swift
//  BohumTalk
//
//  Created by 조유진 on 3/19/25.
//

import Foundation

enum CryptionError: LocalizedError {
    case encryptError
    case decryptError
    case getAESObjectError
    
    var errorDescription: String? {
        switch self {
        case .encryptError: return "암호화 실패"
        case .decryptError: return "복호화 실패"
        case .getAESObjectError: return "AES 객체 생성 실패"
        }
    }
}
