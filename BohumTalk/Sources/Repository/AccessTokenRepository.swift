//
//  AccessTokenRepository.swift
//  BohumTalk
//
//  Created by 조유진 on 3/12/25.
//

import RealmSwift

protocol AccessTokenRepositoryProtocol: AnyObject {
    associatedtype ITEM
    
    func createItem(item: ITEM) async throws
    func readAccessToken(snsId: String) -> String?
    func deleteAccessToken(snsId: String) async throws
}

final class AccessTokenRepository: AccessTokenRepositoryProtocol {
    typealias ITEM = AccessToken
    private let realm = try! Realm()
    
    // Create AccessToken
    func createItem(item: ITEM) async throws {
        do {
            try await realm.asyncWrite {
                realm.add(item)
                print("Data Create")
            }
        } catch {
            print(error)
            throw error
        }
    }
    
    // Read accessToken by snsId
    func readAccessToken(snsId: String) -> String? {
        return realm.object(ofType: ITEM.self, forPrimaryKey: snsId)?.accessToken
    }
    
    // Update accessToken
    func updateAccessToken(snsId: String, accessToken: String) async throws {
        if let item = realm.object(ofType: ITEM.self, forPrimaryKey: snsId) {
            do {
                try await realm.asyncWrite {
                    item.accessToken = accessToken
                }
            } catch {
                print(error)
                throw error
            }
        }
    }
    
    // Delete accessToken
    func deleteAccessToken(snsId: String) async throws {
        let accessToken = realm.objects(ITEM.self).where {
            $0.snsId == snsId
        }
        
        do {
            try await realm.asyncWrite {
                realm.delete(accessToken)
            }
        } catch {
            throw error
        }
    }
}
