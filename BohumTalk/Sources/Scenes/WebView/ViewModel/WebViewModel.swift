//
//  WebViewModel.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import Combine
import Foundation
import WebKit

final class WebViewModel: ViewModelType {
    private var cancellables = Set<AnyCancellable>()
    let errorMessageSubject = PassthroughSubject<String, Never>()
    private let userRepository: UserRepository
    private let accessTokenRepository: AccessTokenRepository
    private let alarmRepository: AlarmRepository
    
    init(
        userRepository: UserRepository,
        accessTokenRepository: AccessTokenRepository,
        alarmRepository: AlarmRepository
    ) {
        self.userRepository = userRepository
        self.accessTokenRepository = accessTokenRepository
        self.alarmRepository = alarmRepository
    }
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let errorMessage: AnyPublisher<String, Never>
        let requestUserInfo: AnyPublisher<WKScriptMessage, Never>
        let requestWithdrawal: AnyPublisher<WKScriptMessage, Never>
        let requestUpdateAccessToken: AnyPublisher<WKScriptMessage, Never>
        let requestSignIn: AnyPublisher<WKScriptMessage, Never>
        let requestSignOut: AnyPublisher<WKScriptMessage, Never>
        let requestUpdateServerUserId: AnyPublisher<WKScriptMessage, Never>
        let requestAlarmList: AnyPublisher<WKScriptMessage, Never>
        let receiveForgroundAlarm: AnyPublisher<NotificationCenter.Publisher.Output, Never>
        let clickedAlarm: AnyPublisher<NotificationCenter.Publisher.Output, Never>
        let requestUpdateAlarmStatus: AnyPublisher<WKScriptMessage, Never>
        let enterForeground: AnyPublisher<Void, Never>
        let updateAlarmStatus: AnyPublisher<NotificationCenter.Publisher.Output, Never>
    }
    
    struct Output {
        let loadUrlSubject: AnyPublisher<URL?, Never>
        let showErrorMessage: AnyPublisher<String, Never>
        let sendMessageToWeb: AnyPublisher<String, Never>
        let settingAction: AnyPublisher<Void, Never>
    }
    
    func transform(input: Input) -> Output {
        let loadUrlSubject = CurrentValueSubject<URL?, Never>(nil)
        let showErrorMessageSubject = PassthroughSubject<String, Never>()
        let sendMessageToWeb = PassthroughSubject<String, Never>()
        let settingAction = PassthroughSubject<Void, Never>()
        
        
        let alarmStatusSubject = PassthroughSubject<Bool, Never>()

        alarmStatusSubject
            .removeDuplicates { oldValue, newValue in
                return oldValue == newValue
            }
            .sink { [weak self] alarmStatus in
                guard let self else { return }
                Task {
                    do {
                        UserDefaults.standard.set(alarmStatus, forKey: "alarmYN")
                        try await self.updateAlarmYN(alarmStatus)
                        if let jsonString = try MessageCodableManager.shared.encodeToJSONString(object: alarmStatus) {
                            sendMessageToWeb.send("receiveClickedAlarmInfo('\(jsonString)')")
                        }
                    } catch {
                        showErrorMessageSubject.send(error.localizedDescription)
                    }
                }
            }
            .store(in: &cancellables)
        
        
        input.errorMessage.sink { errorMessage in
            showErrorMessageSubject.send(errorMessage)
        }
        .store(in: &cancellables)
        
        input.viewDidLoad.sink { _ in
            guard let homeUrlString = Bundle.main.infoDictionary?["HOME_URL"] as? String else {
                fatalError("HOME_URL not found in Info.plist")
            }
            print(homeUrlString)
            guard let url = URL(string: homeUrlString) else {
                showErrorMessageSubject.send("URL을 찾을 수 없습니다.")
                return
            }
            loadUrlSubject.send(url)
        }
        .store(in: &cancellables)
        
        input.updateAlarmStatus.sink { notification in
            if let status = notification.userInfo?["isGranted"] as? Bool {
                alarmStatusSubject.send(status)
            }
        }

        .store(in: &cancellables)
        
        input.enterForeground.sink { _ in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined: print("사용자가 아직 권한 요청을 받지 않음")
                case .denied:
                    print("사용자가 알림 권한을 거부함")
                    alarmStatusSubject.send(false)
                case .authorized, .provisional:
                    print("알림 권한이 허용됨")
                    alarmStatusSubject.send(true)
                case .ephemeral: print("임시 권한 상태 (앱 클립 등)")
                @unknown default: print("알 수 없는 상태")
                }
            }
        }
        .store(in: &cancellables)
        
        input.requestUserInfo.sink { [weak self] _  in
            guard let self else { return }
            Task {
                do {
                    let userInfo = try await self.getUserInfo()
                    if let jsonString = try MessageCodableManager.shared.encodeToJSONString(object: userInfo) {
                        sendMessageToWeb.send("receiveUserData('\(jsonString)')")
                    }
                } catch {
                    print("requestUserInfo Error")
                    showErrorMessageSubject.send(error.localizedDescription)
                }
            }
        }
        .store(in: &cancellables)
        
        input.requestWithdrawal.sink { [weak self] _ in
            guard let self else { return }
            Task {
                var withdrawalResultDto: WithdrawalResultDto
                do {
                    try await self.removeUserInfo()
                    withdrawalResultDto = WithdrawalResultDto(isSuccess: true)
                } catch {
                    print("requestWithdrawal Error")
                    showErrorMessageSubject.send(error.localizedDescription)
                    withdrawalResultDto = WithdrawalResultDto(isSuccess: false)
                }
                if let jsonString = try MessageCodableManager.shared.encodeToJSONString(object: withdrawalResultDto) {
                    sendMessageToWeb.send("receiveWithdrawalResult('\(jsonString)')")
                }
            }
        }
        .store(in: &cancellables)
        
        input.requestUpdateAccessToken.sink { [weak self] message in
            guard let self else { return }
            Task {
                do {
                    let requestUpdateAccessTokenDto = try MessageCodableManager.shared.decodeMessage(message, type: RequestUpdateAccessTokenDto.self)
                    try await self.updateAccessToken(requestUpdateAccessTokenDto.accessToken)
                } catch {
                    print("requestUpdateAccessToken Error")
                   showErrorMessageSubject.send(error.localizedDescription)
                }
            }
        }
        .store(in: &cancellables)
        
        input.requestSignIn.sink { [weak self] message in
            guard let self else { return }
            Task {
                do {
                    let requestSignInDto = try MessageCodableManager.shared.decodeMessage(message, type: RequestSignInDto.self)
                    try await self.signIn(requestSignInDto: requestSignInDto)
                    
                    let userInfo = try await self.getUserInfo()
                    if let jsonString = try MessageCodableManager.shared.encodeToJSONString(object: userInfo) {
                        sendMessageToWeb.send("receiveUserData('\(jsonString)')")
                    }
                } catch {
                    print("requestSignIn Error")
                   showErrorMessageSubject.send(error.localizedDescription)
                }
            }
        }
        .store(in: &cancellables)
        
        input.requestSignOut.sink { [weak self] message in
            guard let self else { return }
            Task {
                var signOutResultDto: SignOutResultDto
                do {
                    try await self.signOut()
                    signOutResultDto = SignOutResultDto(isSuccess: true)
                } catch {
                    print("requestSignOut Error")
                    signOutResultDto = SignOutResultDto(isSuccess: false)
                    showErrorMessageSubject.send(error.localizedDescription)
                }
                
                if let jsonString = try MessageCodableManager.shared.encodeToJSONString(object: signOutResultDto) {
                    sendMessageToWeb.send("receiveSignOutResult('\(jsonString)')")
                }
            }
        }
        .store(in: &cancellables)
        
        input.requestUpdateServerUserId.sink { [weak self] message in
            guard let self else { return }
            Task {
                do {
                    let requestUpdateServerUserIdDto = try MessageCodableManager.shared.decodeMessage(message, type: RequestUpdateServerUserIdDto.self)
                    try await self.updateServerUserId(requestUpdateServerUserIdDto: requestUpdateServerUserIdDto)
                } catch {
                    showErrorMessageSubject.send(error.localizedDescription)
                }
            }
        }
        .store(in: &cancellables)
        
        input.requestAlarmList.sink { [weak self] message in
            guard let self else { return }
            Task {
                do {
                    let requestAlarmListDto = try MessageCodableManager.shared.decodeMessage(message, type: RequestAlarmListDto.self)
                    let slicedAlarmResult = try await self.getSlicedAlarmInfoDtoList(requestAlarmListDto: requestAlarmListDto)
                    if let jsonString = try MessageCodableManager.shared.encodeToJSONString(object: slicedAlarmResult) {
                        sendMessageToWeb.send("receiveAlarmList('\(jsonString)')")
                    }
                } catch {
                    showErrorMessageSubject.send(error.localizedDescription)
                }
            }
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        .store(in: &cancellables)
        
        input.receiveForgroundAlarm.sink { [weak self] notification in
            guard let self else { return }
            if let userInfo = notification.userInfo, let alarmId = userInfo["alarmId"] as? String {
                Task {
                    do {
                        let alarmInfo = try await self.getAlarmInfo(alarmId: alarmId)
                        if let jsonString = try MessageCodableManager.shared.encodeToJSONString(object: alarmInfo) {
                            sendMessageToWeb.send("receiveForegroundAlarm('\(jsonString)')")
                        }
                    } catch {
                        showErrorMessageSubject.send(error.localizedDescription)
                    }
                }
            }
        }
        .store(in: &cancellables)
        
        input.clickedAlarm.sink { [weak self] notification in
            guard let self else { return }
            if let alarmId = UserDefaults.standard.string(forKey: "clickedAlarmId") {
                Task {
                    do {
                        if let alarmInfo = try await self.getAlarmInfo(alarmId: alarmId) {
                            let userInfo = try await self.getUserInfo()
                            let clickedAlarmInfo = ClickedAlarmInfo(alarmInfo: alarmInfo, userInfo: userInfo)
                            print(clickedAlarmInfo)
                            if let jsonString = try MessageCodableManager.shared.encodeToJSONString(object: clickedAlarmInfo) {
                                sendMessageToWeb.send("receiveClickedAlarmInfo('\(jsonString)')")
                            }
                            UserDefaults.standard.removeObject(forKey: "clickedAlarmId")
                            UserDefaults.standard.synchronize()
                        }
                    } catch {
                        showErrorMessageSubject.send(error.localizedDescription)
                    }
                }
            }
        }
        .store(in: &cancellables)
        
        input.requestUpdateAlarmStatus.sink { [weak self] message in
            guard let self else { return }
            do {
                let requestUpdateAlarmStatusDto = try MessageCodableManager.shared.decodeMessage(message, type: RequestUpdateAlarmStatusDto.self)
                let alarmStatus = requestUpdateAlarmStatusDto.alarmYN
                if alarmStatus {   // 알림
                    settingAction.send(())
                } else {
                    alarmStatusSubject.send(false)
                }
            } catch {
                errorMessageSubject.send(error.localizedDescription)
            }
        }
        .store(in: &cancellables)
        
        return Output(
            loadUrlSubject: loadUrlSubject.eraseToAnyPublisher(),
            showErrorMessage: showErrorMessageSubject.eraseToAnyPublisher(),
            sendMessageToWeb: sendMessageToWeb.eraseToAnyPublisher(),
            settingAction: settingAction.eraseToAnyPublisher()
        )
    }
}

// MARK: FEATURE
extension WebViewModel {
    // requestUserInfo
    private func getUserInfo() async throws -> UserInfoDto {
        var snsId: String?
        var serverUserId: String?
        var accessToken: String?
        var deviceToken: String?
        deviceToken = try KeyChain.read(key: KeyChainName.deviceToken.rawValue)
        var unreadAlarmsOfServerUser: [Alarm] = []
        
        if let readedSnsId = try KeyChain.read(key: KeyChainName.currentUserId.rawValue) {
            snsId = readedSnsId
            accessToken = accessTokenRepository.readAccessToken(snsId: readedSnsId)
            serverUserId = userRepository.readServerUserId(snsId: readedSnsId)
            let snsIds = getSnsIdsByServerUserId(serverUserId: serverUserId)
            unreadAlarmsOfServerUser = await alarmRepository.searchUnReadAlarms(snsIds: snsIds)
        }
        
        let updateManager = UpdateAppManager()
        let canUpdateApp = await updateManager.checkCanUpdate()
        let appVersion = updateManager.getCurrentAppVersion()
        
        let alarmYN = UserDefaults.standard.bool(forKey: "alarmYN")
        
        let userInfo = UserInfoDto(
            snsId: snsId,
            serverUserId: serverUserId,
            accessToken: accessToken,
            deviceToken: deviceToken,
            alarmYN: alarmYN,
            unreadAlarmList: getAlarmInfos(unreadAlarmsOfServerUser),
            canUpdateApp: canUpdateApp,
            appVersion: appVersion
        )
        return userInfo
    }
    
    // requestWithdrawal
    private func removeUserInfo() async throws {
        if let snsId = try KeyChain.read(key: KeyChainName.currentUserId.rawValue) {
            let serverUserId = userRepository.readServerUserId(snsId: snsId)
            let snsIds = getSnsIdsByServerUserId(serverUserId: serverUserId)
            try await alarmRepository.deleteAlarms(snsIds: snsIds)
            try await accessTokenRepository.deleteAccessToken(snsId: snsId)
            try await userRepository.deleteItem(snsId: snsId)
            try KeyChain.delete(key: KeyChainName.currentUserId.rawValue)
        }
    }
    
    // requestUpdateAccessToken
    private func updateAccessToken(_ accessToken: String) async throws {
        let encryptedAccessToken = try AES256Cryption.encrypt(string: accessToken)
        if let snsId = try KeyChain.read(key: KeyChainName.currentUserId.rawValue) {
            try await accessTokenRepository.updateAccessToken(snsId: snsId, accessToken: encryptedAccessToken)
        }
    }
    
    // requestSignIn
    private func signIn(requestSignInDto: RequestSignInDto) async throws {
        let encryptedAccessToken = try AES256Cryption.encrypt(string: requestSignInDto.accessToken)
        try KeyChain.create(key: KeyChainName.currentUserId.rawValue, data: requestSignInDto.snsId)
        
        if let _ = userRepository.readItem(snsId: requestSignInDto.snsId) {  // 이미 로그인 헀던 사용자일 경우
            try await updateSignInInfo(snsId: requestSignInDto.snsId, accessToken: encryptedAccessToken)
        } else {    // 최초 로그인일 경우
            try await createSignInInfo(snsId: requestSignInDto.snsId, accessToken: encryptedAccessToken, loginCompany: requestSignInDto.loginCompany)
        }
    }
    
    // requestSignOut
    private func signOut() async throws {
        if let snsId = try KeyChain.read(key: KeyChainName.currentUserId.rawValue) {
            try await userRepository.updateLogoutDate(snsId: snsId)
            try KeyChain.delete(key: KeyChainName.currentUserId.rawValue)
        }
    }
    
    // requestUpdateServerUserId
    private func updateServerUserId(requestUpdateServerUserIdDto: RequestUpdateServerUserIdDto) async throws {
        if let snsId = try KeyChain.read(key: KeyChainName.currentUserId.rawValue) {
            try userRepository.updateServerUserId(snsId: snsId, serverUserId: requestUpdateServerUserIdDto.serverUserId)
        }
    }
    
    // requestAlarmList
    private func getSlicedAlarmInfoDtoList(requestAlarmListDto: RequestAlarmListDto) async throws -> SlicedAlarmResult {
        guard let snsId = try KeyChain.read(key: KeyChainName.currentUserId.rawValue) else {
            throw KeyChainError.readError
        }
        
        let startIndex = requestAlarmListDto.start - 1 < 0 ? 0 : requestAlarmListDto.start - 1
        let endIndex = requestAlarmListDto.end - 1 < 0 ? 0 : requestAlarmListDto.end - 1
        
        var slicedAlarmList: [Alarm] = []
        
        let serverUserId = userRepository.readServerUserId(snsId: snsId)
        let snsIds = getSnsIdsByServerUserId(serverUserId: serverUserId)
        let alarmList = await alarmRepository.readAlarms(snsIds: snsIds)
        
        try await alarmRepository.updateReadDate(snsIds: snsIds)    // 알림리스트 가져온 후, 읽지 않은 알림 업데이트
        
        slicedAlarmList = Array(alarmList[startIndex...endIndex])
        
        let slicedAlarmResult = SlicedAlarmResult(
            totalCount: alarmList.count,
            start: requestAlarmListDto.start,
            end: requestAlarmListDto.end,
            alarmList: getAlarmInfos(slicedAlarmList)
        )
        
        return slicedAlarmResult
    }
    
    // receiveForegroundAlarm
    private func getAlarmInfo(alarmId: String) async throws -> AlarmInfoDto? {
        if let alarm = await alarmRepository.readAlarm(alarmId: alarmId) {
            return alarmToAlarmInfo(alarm)
        }
        return nil
    }
    
    // alarmStatusSubject
    private func updateAlarmYN(_ alarmYN: Bool) async throws {
        if let snsId = try KeyChain.read(key: KeyChainName.currentUserId.rawValue) {
            try userRepository.updateAlarmYN(snsId: snsId, alarmYN: alarmYN)
        }
    }
}

// MARK: 공통 메서드
extension WebViewModel {
    private func getSnsIdsByServerUserId(serverUserId: String?) -> [String] {
        var snsIds: [String] = []
        if let serverUserId {
            snsIds = userRepository.readSnsIds(serverUserId: serverUserId)
        }
        return snsIds
    }
    
    private func getAlarmInfos(_ alarms: [Alarm]) -> [AlarmInfoDto] {
        return alarms.map { alarm in
            alarmToAlarmInfo(alarm)
        }
    }
    
    private func alarmToAlarmInfo(_ alarm: Alarm) -> AlarmInfoDto {
        return AlarmInfoDto(
            alarmId: alarm.alarmId,
            title: alarm.title,
            content: alarm.content,
            imageUrl: alarm.imageUrl,
            iconUrl: alarm.iconUrl,
            alarmDate: alarm.alarmDate,
            readDate: nil,
            alarmData: alarm.alarmData
        )
    }
    
    private func updateSignInInfo(snsId: String, accessToken: String) async throws {
        try userRepository.updateLoginDate(snsId: snsId)
        try await accessTokenRepository.updateAccessToken(snsId: snsId, accessToken: accessToken)
    }
    
    private func createSignInInfo(snsId: String, accessToken: String, loginCompany: String) async throws {
        let alarmYN = UserDefaults.standard.bool(forKey: "alarmYN")
        try await userRepository.createItem(
            item: User(
                snsId: snsId,
                serverUserId: nil,
                alarmYN: alarmYN,
                loginDate: Date(),
                logoutDate: nil
            )
        )
        try await accessTokenRepository.createItem(
            item: AccessToken(
                snsId: snsId,
                accessToken: accessToken,
                loginCompany: loginCompany
            )
        )
    }
}
