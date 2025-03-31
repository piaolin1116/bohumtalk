//
//  KeyChain.swift
//  BohumTalk
//
//  Created by 조유진 on 3/11/25.
//

import Foundation
import Security

enum KeyChainName: String {
    case currentUserId
    case deviceToken
}

final class KeyChain {
    
    // Create
    static func create(key: String, data: String) throws {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        SecItemDelete(query) // Keychain은 Key값에 중복이 생기면 저장할 수 없기 때문에 먼저 Delete
        
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess { throw KeyChainError.createError }
    }
    
    // Read
    static func read(key: String) throws -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData: Data = dataTypeRef as? Data {
                let value = String(data: retrievedData, encoding: String.Encoding.utf8)
                return value
            } else { return nil }
        } else {
            throw KeyChainError.readError
        }
    }
    
    // Update
    static func update(key: String, data: String) throws {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        let attributes: NSDictionary = [
            kSecValueData: data.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        
        let status = SecItemUpdate(query, attributes)
        if status != errSecSuccess {
            throw KeyChainError.updateError
        }
    }
    
    // Delete
    static func delete(key: String) throws {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let status = SecItemDelete(query)
        if status == noErr { throw KeyChainError.deleteError }
    }
}
