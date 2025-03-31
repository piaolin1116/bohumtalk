//
//  UpdateAppManager.swift
//  BohumTalk
//
//  Created by 조유진 on 3/11/25.
//

import Foundation
import UIKit

enum AppStoreInfo {
    static let appID = "1234"
    static let appStoreVersionURL = "https://itunes.apple.com/lookup?id=\(appID)&country=kr"
    static let appStoreOpenUrlString = "itms-apps://itunes.apple.com/app/id\(appID)"
}

final class UpdateAppManager {
    
    // 앱 업데이트 가능 여부
    func checkCanUpdate() async -> Bool {
        guard let marketingVersion = await fetchLatestVersion(),
              let currentAppVersion = getCurrentAppVersion() else {
            print("버전 정보 없음")
            return false
        }
        return compareVersion(currentVersion: currentAppVersion, marketVersion: marketingVersion)
    }
    
    // 현재 앱 버전
    func getCurrentAppVersion() -> String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    // 앱스토어의 최신 버전 가져오기
    private func fetchLatestVersion() async -> String? {
        guard let url = URL(string: AppStoreInfo.appStoreVersionURL) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let firstResult = results.first,
               let version = firstResult["version"] as? String {
                return version
            }
        } catch {
            print("에러 발생: \(error)")
        }
        return nil
    }

    // 업데이트 필요 여부 비교
    private func compareVersion(currentVersion: String, marketVersion: String) -> Bool {
        let currentVersionArray = currentVersion.split(separator: ".").compactMap { Int($0) }
        let marketVersionArray = marketVersion.split(separator: ".").compactMap { Int($0) }
        
        for (current, market) in zip(currentVersionArray, marketVersionArray) {
            if current < market { return true }
            if current > market { return false }
        }
        
        return marketVersionArray.count > currentVersionArray.count
    }
}
