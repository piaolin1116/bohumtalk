//
//  AES256Cryption.swift
//  BohumTalk
//
//  Created by 조유진 on 3/11/25.
//

import CryptoSwift
import Foundation

public class AES256Cryption {
    private static var AES_KEY: String {
        guard let aesKey = Bundle.main.infoDictionary?["AES_KEY"] as? String else {
            fatalError("AES_KEY not found in Info.plist")
        }
        return aesKey
    }
    private static var IV: String {
        String(AES_KEY.prefix(16))
    }
    
    static func encrypt(string: String) throws -> String {
        guard !string.isEmpty else { return "" }
        
        do {
            return try getAESObject().encrypt(string.bytes).toBase64()
        } catch {
            throw CryptionError.encryptError
        }
    }
    
    static func decrypt(string: String) throws -> String {
        guard !string.isEmpty else { return "" }
        
        let data = Data(base64Encoded: string)
        
        do {
            let decrypted = try getAESObject().decrypt([UInt8](data!))
            return String(bytes: decrypted, encoding: .utf8) ?? ""
        } catch {
            throw CryptionError.decryptError
        }
    }
    
    private static func getAESObject() throws -> AES {
        let keyDecodes: Array<UInt8> = Array(AES_KEY.utf8)
        let ivDecodes: Array<UInt8> = Array(IV.utf8)
        
        do {
            let aesObject = try AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs5)
            return aesObject
        } catch {
            throw CryptionError.getAESObjectError
        }
    }
}
