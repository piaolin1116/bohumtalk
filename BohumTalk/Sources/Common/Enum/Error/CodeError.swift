//
//  CodeError.swift
//  BohumTalk
//
//  Created by 조유진 on 3/17/25.
//

import Foundation

enum CodeError: LocalizedError {
    case failedDecodeMessage
    case failedEncodeMessage
    
    var errorDescription: String? {
        switch self {
        case .failedDecodeMessage: return "메시지를 디코딩하는 데 실패했습니다."
        case .failedEncodeMessage: return "메시지를 인코딩하는 데 실패했습니다."
        }
    }
}
