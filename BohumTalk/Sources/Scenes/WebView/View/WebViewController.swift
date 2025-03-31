//
//  WebViewController.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit
import Combine
import WebKit

enum MessageHandlerName: String, CaseIterable {
    case requestUserInfo
    case requestWithdrawal
    case requestSignIn
    case requestSignOut
    case requestAlarmList
    case requestUpdateAccessToken
    case requestUpdateAlarmSetting
    case requestUpdateServerUserId
    case requestUpdateAlarmStatus
     
    static var messageNames: [String] {
        return MessageHandlerName.allCases.map { messageHandlerNames in
            messageHandlerNames.rawValue
        }
    }
}

final class WebViewController: BaseViewController {
    private let webViewWrapper = WKWebViewWrapper(messageHandlerNames: MessageHandlerName.messageNames)
    private let viewModel: WebViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let requestUserInfo = PassthroughSubject<WKScriptMessage, Never>()
    private let requestWithdrawal = PassthroughSubject<WKScriptMessage, Never>()
    private let requestSignIn = PassthroughSubject<WKScriptMessage, Never>()
    private let requestSignOut = PassthroughSubject<WKScriptMessage, Never>()
    private let requestAlarmList = PassthroughSubject<WKScriptMessage, Never>()
    private let requestUpdateAccessToken = PassthroughSubject<WKScriptMessage, Never>()
    private let requestUpdateAlarmSetting = PassthroughSubject<WKScriptMessage, Never>()
    private let requestUpdateServerUserId = PassthroughSubject<WKScriptMessage, Never>()
    private let receiveForgroundAlarm = PassthroughSubject<NotificationCenter.Publisher.Output, Never>()
    private let clickedAlarm = PassthroughSubject<NotificationCenter.Publisher.Output, Never>()
    private let requestUpdateAlarmStatus = PassthroughSubject<WKScriptMessage, Never>()
    private let enterForeground = PassthroughSubject<Void, Never>()
    private let updateAlarmStatus = PassthroughSubject<NotificationCenter.Publisher.Output, Never>()
    
    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    override func bind() {
        print(#function)
        let input = WebViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            errorMessage: viewModel.errorMessageSubject.eraseToAnyPublisher(),
            requestUserInfo: requestUserInfo.eraseToAnyPublisher(),
            requestWithdrawal: requestWithdrawal.eraseToAnyPublisher(),
            requestUpdateAccessToken: requestUpdateAccessToken.eraseToAnyPublisher(),
            requestSignIn: requestSignIn.eraseToAnyPublisher(),
            requestSignOut: requestSignOut.eraseToAnyPublisher(),
            requestUpdateServerUserId: requestUpdateServerUserId.eraseToAnyPublisher(),
            requestAlarmList: requestAlarmList.eraseToAnyPublisher(),
            receiveForgroundAlarm: receiveForgroundAlarm.eraseToAnyPublisher(),
            clickedAlarm: clickedAlarm.eraseToAnyPublisher(),
            requestUpdateAlarmStatus: requestUpdateAlarmStatus.eraseToAnyPublisher(),
            enterForeground: enterForeground.eraseToAnyPublisher(),
            updateAlarmStatus: updateAlarmStatus.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.loadUrlSubject
            .sink { [weak self] url in
                guard let self else { return }
                guard let url else {
                    viewModel.errorMessageSubject.send("유효하지 않은 url 입니다.")
                    return
                }
                webViewWrapper.loadURL(url)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .reloadURL)
            .sink { [weak self] _ in
                guard let self else { return }
                webViewWrapper.reloadURL()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .updateAlarmStatus)
            .sink { [weak self] notification in
                guard let self else { return }
                updateAlarmStatus.send(notification)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .receiveForegroundAlarm)
            .sink { [weak self] notification in
                guard let self else { return }
                receiveForgroundAlarm.send(notification)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self else { return }
                enterForeground.send(())
            }
            .store(in: &cancellables)
        
        webViewWrapper.didFinishPublisher
            .combineLatest(NotificationCenter.default.publisher(for: .clickedAlarm))
            .sink { [weak self] (navigation, notification) in
                guard let self else { return }
                clickedAlarm.send(notification)
            }
            .store(in: &cancellables)
        
        webViewWrapper.decidePolicyForNavigationActionPublisher
            .sink { action, decisionHandler in
                let url = action.request.url?.absoluteString ?? ""
                
                // 특정 URL의 로드를 막을 수 있음
                if url.contains("tel:") || url.contains("apps.apple.com") {
                    UIApplication.shared.open(URL(string: url)!)
                    decisionHandler(.cancel)
                    return
                }
                
                decisionHandler(.allow)
            }
            .store(in: &cancellables)
        
        webViewWrapper.decidePolicyForNavigationResponsePublisher
            .sink { response, decisionHandler in
                if let httpResponse = response.response as? HTTPURLResponse, (200..<400).contains(httpResponse.statusCode) {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                }
            }
            .store(in: &cancellables)
        
        webViewWrapper.didReceiveMessage
            .sink { [weak self] message in
                guard let self else { return }
                if let name = MessageHandlerName(rawValue: message.name) {
                    switch name {
                    case .requestUserInfo: requestUserInfo.send(message)
                    case .requestWithdrawal: requestWithdrawal.send(message)
                    case .requestSignIn: requestSignIn.send(message)
                    case .requestSignOut: requestSignOut.send(message)
                    case .requestAlarmList: requestAlarmList.send(message)
                    case .requestUpdateAccessToken: requestUpdateAccessToken.send(message)
                    case .requestUpdateAlarmSetting: break
                    case .requestUpdateServerUserId: requestUpdateServerUserId.send(message)
                    case .requestUpdateAlarmStatus: requestUpdateAlarmStatus.send(message)
                    }
                }
            }
            .store(in: &cancellables)
    
        output.sendMessageToWeb
            .sink { [weak self] jsCode in
                guard let self else { return }
                sendMessageToJavaScript(jsCode: jsCode)
            }
            .store(in: &cancellables)
        
        output.showErrorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] errorMessage in
                guard let self else { return }
                showAlert(message: errorMessage)
            }
            .store(in: &cancellables)
        
        output.settingAction
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                showAlert(message: "앱에서 푸시 알림을 받으려면 설정 > 알림에서 허용해주세요.") { _ in
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
                          UIApplication.shared.canOpenURL(settingsURL) else { return }
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
            .store(in: &cancellables)
    }
    
    private func sendMessageToJavaScript(jsCode: String) {
        webViewWrapper.sendMessageToWeb(jsCode)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    print("✅ JavaScript 호출 성공")
                case .failure(let error):
                    viewModel.errorMessageSubject.send(error.localizedDescription)
                    print("❌ JS 호출 에러:", error.localizedDescription)
                }
            }, receiveValue: { result in
                print("JS 실행 결과:", result ?? "결과 없음")
            })
            .store(in: &cancellables)
    }
    
    private func configureHierarchy() {
        view.addSubview(webViewWrapper.webView)
    }
    
    private func configureLayout() {
        webViewWrapper.webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        view.backgroundColor = .white
    }
}
