//
//  UserRepository.swift
//  BohumTalk
//
//  Created by 조유진 on 3/12/25.
//

import RealmSwift
import Foundation

protocol UserRepositoryProtocol: AnyObject {
    associatedtype ITEM
    
    func createItem(item: ITEM) async throws
    func readItem(snsId: String) -> User?
    func readServerUserId(snsId: String) -> String?
    func readAlarmYN(snsId: String) -> Bool?
    func updateServerUserId(snsId: String, serverUserId: String) throws
    func updateAlarmYN(snsId: String, alarmYN: Bool) throws
    func updateLoginDate(snsId: String) throws
    func updateLogoutDate(snsId: String) async throws
    func deleteItem(snsId: String) async throws
}

final class UserRepository: UserRepositoryProtocol {
    typealias ITEM = User
    
    private let realm = try! Realm()
    
    
    // Create User
    func createItem(item: ITEM) async throws {
        do {
            try await realm.asyncWrite {
                realm.add(item)
                print("User Create")
            }
        } catch {
            print(error)
            throw error
        }
    }
    
    // Read User by snsId
    func readItem(snsId: String) -> User? {
        return realm.object(ofType: ITEM.self, forPrimaryKey: snsId)
    }
    
    // Read serverUserId by snsId
    func readServerUserId(snsId: String) -> String? {
        return readItem(snsId: snsId)?.serverUserId
    }
    
    // Read alarmYN by snsId
    func readAlarmYN(snsId: String) -> Bool? {
        return readItem(snsId: snsId)?.alarmYN
    }
    
    // Read snsIds by serverUserId
    func readSnsIds(serverUserId: String) -> [String] {
        let snsIds = Array(realm.objects(ITEM.self).where {
            $0.serverUserId == serverUserId
        }).map { $0.snsId }
        return snsIds
    }
    
    // Update serverUserId
    func updateServerUserId(snsId: String, serverUserId: String) throws {
        if let item = realm.object(ofType: ITEM.self, forPrimaryKey: snsId) {
            do {
                try realm.write {
                    item.serverUserId = serverUserId
                }
            } catch {
                print(error)
                throw error
            }
        }
    }
    
    // Update alarmYN
    func updateAlarmYN(snsId: String, alarmYN: Bool) throws {
        if let item = realm.object(ofType: ITEM.self, forPrimaryKey: snsId) {
            do {
                try realm.write {
                    item.alarmYN = alarmYN
                }
            } catch {
                print(error)
                throw error
            }
        }
    }
    
    // Update loginDate
    func updateLoginDate(snsId: String) throws {
        if let item = realm.object(ofType: ITEM.self, forPrimaryKey: snsId) {
            do {
                try realm.write {
                    item.loginDate = Date()
                }
            } catch {
                print(error)
                throw error
            }
        }
    }
    
    // Update logoutDate
    func updateLogoutDate(snsId: String) async throws {
        if let item = realm.object(ofType: ITEM.self, forPrimaryKey: snsId) {
            do {
                try await realm.asyncWrite {
                    item.logoutDate = Date()
                }
            } catch {
                print(error)
                throw error
            }
        }
    }
    
    // Delete User
    func deleteItem(snsId: String) async throws {
        if let item = realm.object(ofType: ITEM.self, forPrimaryKey: snsId) {
            do {
                try await realm.asyncWrite {
                  realm.delete(item)
                }
            } catch {
                print(error)
                throw error
            }
        }
    }
}
