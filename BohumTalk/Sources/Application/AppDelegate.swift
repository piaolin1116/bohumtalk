//
//  AppDelegate.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit
import UserNotifications

import FirebaseCore
import FirebaseMessaging
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(#function)
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            switch settings.authorizationStatus {
            case .notDetermined:
                print("사용자가 아직 권한 요청을 받지 않음")
                requestAlarmGrant()
            case .denied:
                print("사용자가 알림 권한을 거부함")
                saveAlarmYN(false)
            case .authorized, .provisional:
                print("알림 권한이 허용됨")
                saveAlarmYN(true)
            case .ephemeral:
                print("임시 권한 상태 (앱 클립 등)")
            @unknown default:
                print("알 수 없는 상태")
            }
        }

        application.registerForRemoteNotifications()
        
        return true
    }
    
    private func saveAlarmYN(_ isGranted: Bool) {
        UserDefaults.standard.set(isGranted, forKey: "alarmYN")
        NotificationCenter.default.post(name: .updateAlarmStatus, object: isGranted)
    }
    
    private func requestAlarmGrant() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions){ [weak self] granted, error in
            guard let self else { return }
            saveAlarmYN(granted)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

    // 백그라운드에서 알림을 받았을 떄
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
          print(#function)
          print(userInfo)
          
          Task {
              try await AlarmManager.shared.saveAlarm(userInfo: userInfo)
          }
              
          DispatchQueue.main.async {
              UIApplication.shared.applicationIconBadgeNumber += 1
          }
          
          return UIBackgroundFetchResult.newData
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    // 앱이 실행 중일 때 (Foreground) 알림을 받을 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        print(#function)
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
        
        Task {
            if let alarmId = try await AlarmManager.shared.saveAlarm(userInfo: userInfo) {
                NotificationCenter.default.post(name: .receiveForegroundAlarm, object: alarmId)
            }
        }
        
        return [.sound, .banner, .list]
    }

    // 사용자가 푸시 알림을 클릭했을 때 동작
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
        print(#function)
        let userInfo = response.notification.request.content.userInfo
        
        let badgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1 < 0 ? 0 : UIApplication.shared.applicationIconBadgeNumber - 1
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber
        
        Task {  // 클릭한 알림 읽음처리
            try await AlarmManager.shared.postClickedAlarmToServer(userInfo: userInfo)
            if let alarmId = AlarmManager.shared.getAlarmId(userInfo: userInfo) {
                UserDefaults.standard.set(alarmId, forKey: "clickedAlarmId")
                try await AlarmManager.shared.readNewAlarm(alarmId: alarmId)
               
                NotificationCenter.default.post(name: .clickedAlarm, object: nil)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("🟢", #function, deviceTokenString)
    }
}

extension AppDelegate: MessagingDelegate {
    // 디바이스 토큰이 업데이트 되었을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        if let fcmToken {
            do {
                let encryptedToken = try AES256Cryption.encrypt(string: fcmToken)
                try KeyChain.create(key: KeyChainName.deviceToken.rawValue, data: encryptedToken)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
