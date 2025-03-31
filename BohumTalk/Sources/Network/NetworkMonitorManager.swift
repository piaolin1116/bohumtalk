//
//  NetworkMonitorManager.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import Network

final class NetworkMonitorManager {
    static let shared = NetworkMonitorManager()
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor: NWPathMonitor
    
    func startMonitoring(statusUpdateHandler: @escaping (NWPath.Status) -> Void) {
        print("모니터링 시작")
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                statusUpdateHandler(path.status)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        print("모니터링 중지")
        monitor.cancel()
    }
}
