//
//  KeyChainError.swift
//  BohumTalk
//
//  Created by 조유진 on 3/19/25.
//

import Foundation

enum KeyChainError: LocalizedError {
    case createError
    case readError
    case updateError
    case deleteError
    
    var errorDescription: String? {
        switch self {
        case .createError:
            return "KeyChain Create Error"
        case .readError:
            return "KeyChain Read Error"
        case .updateError:
            return "KeyChain Update Error"
        case .deleteError:
            return "KeyChain Delete Error"
        }
    }
}
