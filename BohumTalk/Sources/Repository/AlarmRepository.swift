//
//  AlarmRepository.swift
//  BohumTalk
//
//  Created by 조유진 on 3/12/25.
//

import RealmSwift
import Foundation

protocol AlarmRepositoryProtocol: AnyObject {
    associatedtype ITEM
    
    func createAlarm(item: ITEM) throws
    func readAlarms(snsIds: [String]) -> [ITEM]
    func searchUnReadAlarms(snsIds: [String]) -> [ITEM]
    func updateReadDateByAlarmId(alarmId: String) async throws
    func updateReadDate(snsIds: [String]) async throws
    func deleteAlarm(alarmId: String)
    func deleteAlarms(snsIds: [String]) async throws
}

@MainActor final class AlarmRepository: AlarmRepositoryProtocol {
    typealias ITEM = Alarm
    
    private let realm = try! Realm()
    
    // Create Alarm
    func createAlarm(item: ITEM) throws {
        do {
            try realm.write {
                realm.add(item)
                print("Alarm Create")
            }
        } catch {
            print(error)
            throw error
        }
    }
    
    // Read Alarms by alarmId
    func readAlarm(alarmId: String) -> ITEM? {
        let item = realm.object(ofType: ITEM.self, forPrimaryKey: alarmId)
        return item
    }
    
    // Read Alarms by snsIds
    func readAlarms(snsIds: [String]) -> [ITEM] {
        let Items = Array(realm.objects(ITEM.self).where {
            $0.snsId.in(snsIds)
        }.sorted(byKeyPath: "alarmDate", ascending: false))
        return Items
    }
    
    // Read Unread Alarms by snsIds
    func searchUnReadAlarms(snsIds: [String]) -> [ITEM] {
        let alarms: [ITEM] = Array(realm.objects(ITEM.self).where {
            $0.snsId.in(snsIds) &&
            $0.readDate == nil
        }.sorted(byKeyPath: "alarmDate",ascending: false))
        
        return alarms
    }
    
    // Update readDate
    func updateReadDate(snsIds: [String]) async throws {
        let alarms = realm.objects(ITEM.self).where {
            $0.snsId.in(snsIds) &&
            $0.readDate == nil
        }
        
        do {
            try await realm.asyncWrite {
                for alarm in alarms {
                    alarm.readDate = Date()
                }
            }
        } catch {
            throw error
        }
    }
    
    func updateReadDateByAlarmId(alarmId: String) async throws {
        if let item = realm.object(ofType: ITEM.self, forPrimaryKey: alarmId) {
            do {
                try await realm.asyncWrite {
                    item.readDate = Date()
                }
            } catch {
                throw error
            }
        }
    }
    
    // Delete Alarm
    func deleteAlarm(alarmId: String) {
        if let item = realm.object(ofType: ITEM.self, forPrimaryKey: alarmId) {
            do {
                try realm.write  {
                  realm.delete(item)
                }
            } catch {
                print(error)
            }
        }
    }
    
    // Delete Alams Of snsIds
    func deleteAlarms(snsIds: [String]) async throws {
        let alarms = realm.objects(ITEM.self).where {
            $0.snsId.in(snsIds)
        }
        
        do {
            try await realm.asyncWrite {
                realm.delete(alarms)
            }
        } catch {
            throw error
        }
    }
}
