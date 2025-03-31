//
//  MessageCodableManager.swift
//  BohumTalk
//
//  Created by 조유진 on 3/17/25.
//

import WebKit

final class MessageCodableManager {
    static let shared = MessageCodableManager()
    
    private init() {}
    
    func decodeMessage<D: Decodable>(_ message: WKScriptMessage, type: D.Type) throws -> D {
        if let jsonString = message.body as? String,
           let jsonData = jsonString.data(using: .utf8) {
            let object = try JSONDecoder().decode(D.self, from: jsonData)
            return object
        } else {
            throw CodeError.failedDecodeMessage
        }
    }
    
    func encodeToJSONString<E: Encodable>(object: E) throws -> String? {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(object)         // struct -> JSON Data
            let jsonString = String(data: data, encoding: .utf8) // Data -> String
            return jsonString
        } catch {
            print("Encoding failed: \(error)")
            throw CodeError.failedEncodeMessage
        }
    }
    
    func convertDictionaryToString(_ dictionary: [AnyHashable: Any]) -> String? {
        guard let stringKeyDict = dictionary as? [String: Any] else {
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: stringKeyDict, options: [.prettyPrinted])
            let jsonString = String(data: data, encoding: .utf8)
            return jsonString
        } catch {
            print("JSON 직렬화 중 오류 발생: \(error)")
            return nil
        }
    }
}
